// Penjelasan file dan tujuannya:
// Nama file: peer-chat.controller.js
// Deskripsi: Controller untuk REST API fitur Ruang Curhat (Blocked Users & Polling).
// Mengarahkan ke/Keterkaitan:
// - Dipanggil oleh rute peer-chat.routes.js

const { pool } = require('../config/database');
const { v4: uuidv4 } = require('uuid');

// Matching queue: topic -> array of { userId, userAlias, timestamp }
const matchingQueue = new Map();

// Helper to remove user from all queues
const removeUserFromQueues = (userId) => {
  for (const [topic, queue] of matchingQueue.entries()) {
    matchingQueue.set(topic, queue.filter(u => u.userId !== userId));
  }
};

const joinQueue = async (req, res) => {
  try {
    const userId = req.user.id;
    const { topic = 'bebas', userAlias = 'Anonim' } = req.body;

    // Remove from existing queues just in case
    removeUserFromQueues(userId);

    if (!matchingQueue.has(topic)) {
      matchingQueue.set(topic, []);
    }
    const queue = matchingQueue.get(topic);

    // Look for a match (not me, not blocked)
    let partnerIdx = -1;
    for (let i = 0; i < queue.length; i++) {
      const partner = queue[i];
      if (partner.userId === userId) continue;

      // Check blocked
      const [blocked] = await pool.query(
        'SELECT id FROM blocked_users WHERE (blocker_id = ? AND blocked_id = ?) OR (blocker_id = ? AND blocked_id = ?)',
        [userId, partner.userId, partner.userId, userId]
      );
      if (blocked.length === 0) {
        partnerIdx = i;
        break;
      }
    }

    if (partnerIdx !== -1) {
      // Match found
      const partner = queue[partnerIdx];
      queue.splice(partnerIdx, 1);
      
      const roomId = uuidv4();
      await pool.query(
        `INSERT INTO chat_rooms (id, user1_id, user2_id, user1_alias, user2_alias, topic, status)
        VALUES (?, ?, ?, ?, ?, ?, 'active')`,
        [roomId, partner.userId, userId, partner.userAlias, userAlias, topic]
      );

      return res.json({
        success: true,
        matched: true,
        roomId,
        partnerAlias: partner.userAlias,
        topic
      });
    }

    // No match, join queue
    queue.push({ userId, userAlias, timestamp: Date.now() });
    res.json({ success: true, matched: false });

  } catch (error) {
    console.error('❌ Error joining queue:', error);
    res.status(500).json({ success: false, message: 'Gagal join queue' });
  }
};

const checkStatus = async (req, res) => {
  try {
    const userId = req.user.id;

    // Check if in active room
    const [rooms] = await pool.query(
      `SELECT * FROM chat_rooms 
      WHERE (user1_id = ? OR user2_id = ?) AND status = 'active'
      ORDER BY created_at DESC LIMIT 1`,
      [userId, userId]
    );

    if (rooms.length > 0) {
      const room = rooms[0];
      const partnerAlias = room.user1_id === userId ? room.user2_alias : room.user1_alias;
      return res.json({
        success: true,
        matched: true,
        roomId: room.id,
        partnerAlias,
        topic: room.topic
      });
    }

    // Not in active room, check if still in queue
    let inQueue = false;
    for (const queue of matchingQueue.values()) {
      if (queue.some(u => u.userId === userId)) {
        inQueue = true;
        break;
      }
    }

    if (inQueue) {
      return res.json({ success: true, matched: false });
    } else {
      return res.json({ success: true, matched: false, dropped: true });
    }
  } catch (error) {
    console.error('❌ Error checking status:', error);
    res.status(500).json({ success: false, message: 'Gagal cek status' });
  }
};

const leaveQueue = async (req, res) => {
  try {
    removeUserFromQueues(req.user.id);
    res.json({ success: true, message: 'Keluar dari antrean' });
  } catch (error) {
    console.error('❌ Error leaving queue:', error);
    res.status(500).json({ success: false, message: 'Gagal keluar antrean' });
  }
};

const sendMessage = async (req, res) => {
  try {
    const userId = req.user.id;
    const { roomId, text, type = 'text' } = req.body;
    
    await pool.query(
      'INSERT INTO peer_messages (room_id, sender_id, text, type) VALUES (?, ?, ?, ?)',
      [roomId, userId, text, type]
    );

    res.json({ success: true, message: 'Pesan terkirim' });
  } catch (error) {
    console.error('❌ Error sending message:', error);
    res.status(500).json({ success: false, message: 'Gagal kirim pesan' });
  }
};

const getMessages = async (req, res) => {
  try {
    const { roomId } = req.params;
    const { after } = req.query; // message ID to poll from

    let query = 'SELECT * FROM peer_messages WHERE room_id = ?';
    const params = [roomId];

    if (after) {
      query += ' AND id > ?';
      params.push(after);
    }
    query += ' ORDER BY created_at ASC';

    const [messages] = await pool.query(query, params);
    
    // Check if room ended
    const [roomInfo] = await pool.query('SELECT status, consent_status FROM chat_rooms WHERE id = ?', [roomId]);
    const status = roomInfo.length ? roomInfo[0].status : 'ended';
    const consentStatus = roomInfo.length ? roomInfo[0].consent_status : 'none';

    res.json({ success: true, data: messages, status, consentStatus });
  } catch (error) {
    console.error('❌ Error getting messages:', error);
    res.status(500).json({ success: false, message: 'Gagal mengambil pesan' });
  }
};

const requestConsent = async (req, res) => {
  try {
    const userId = req.user.id;
    const { roomId } = req.body;
    
    const [rooms] = await pool.query('SELECT * FROM chat_rooms WHERE id = ?', [roomId]);
    if (!rooms.length) return res.status(404).json({ success: false, message: 'Room not found' });
    const room = rooms[0];

    const targetStatus = room.user1_id === userId ? 'pending_user2' : 'pending_user1';
    
    await pool.query('UPDATE chat_rooms SET consent_status = ? WHERE id = ?', [targetStatus, roomId]);
    
    const alias = room.user1_id === userId ? room.user1_alias : room.user2_alias;
    const msgText = `${alias} meminta izin untuk mengungkapkan identitas asli.`;

    await pool.query(
      "INSERT INTO peer_messages (room_id, sender_id, text, type) VALUES (?, ?, ?, 'consent_request')",
      [roomId, userId, msgText]
    );

    res.json({ success: true });
  } catch (error) {
    console.error('❌ Error requesting consent:', error);
    res.status(500).json({ success: false, message: 'Gagal request consent' });
  }
};

const respondConsent = async (req, res) => {
  try {
    const userId = req.user.id;
    const { roomId, accept } = req.body;

    const [rooms] = await pool.query('SELECT * FROM chat_rooms WHERE id = ?', [roomId]);
    if (!rooms.length) return res.status(404).json({ success: false, message: 'Room not found' });
    const room = rooms[0];

    const newStatus = accept ? 'accepted' : 'rejected';
    await pool.query('UPDATE chat_rooms SET consent_status = ? WHERE id = ?', [newStatus, roomId]);

    const alias = room.user1_id === userId ? room.user1_alias : room.user2_alias;
    const msgText = accept ? `${alias} menerima permintaan identitas. Identitas kini terbuka.` : `${alias} menolak permintaan identitas.`;

    await pool.query(
      "INSERT INTO peer_messages (room_id, sender_id, text, type) VALUES (?, ?, ?, 'system')",
      [roomId, userId, msgText]
    );

    res.json({ success: true });
  } catch (error) {
    console.error('❌ Error responding consent:', error);
    res.status(500).json({ success: false, message: 'Gagal respond consent' });
  }
};

const endChat = async (req, res) => {
  try {
    const userId = req.user.id;
    const { roomId } = req.body;

    const [rooms] = await pool.query('SELECT * FROM chat_rooms WHERE id = ?', [roomId]);
    if (rooms.length > 0) {
        const room = rooms[0];
        const alias = room.user1_id === userId ? room.user1_alias : room.user2_alias;
        
        await pool.query("UPDATE chat_rooms SET status = 'ended', ended_at = CURRENT_TIMESTAMP WHERE id = ?", [roomId]);
        
        await pool.query(
        "INSERT INTO peer_messages (room_id, sender_id, text, type) VALUES (?, ?, ?, 'system')",
        [roomId, userId, `${alias} telah meninggalkan obrolan.`]
        );
    }
    res.json({ success: true });
  } catch (error) {
    console.error('❌ Error ending chat:', error);
    res.status(500).json({ success: false, message: 'Gagal mengakhiri chat' });
  }
};

const reportUser = async (req, res) => {
    try {
      const reporterId = req.user.id;
      const { reportedId, roomId, reason } = req.body;
      
      await pool.query(
        'INSERT INTO reports (reporter_id, reported_id, room_id, reason) VALUES (?, ?, ?, ?)',
        [reporterId, reportedId, roomId, reason]
      );
      
      res.json({ success: true, message: 'Laporan berhasil dikirim' });
    } catch (error) {
      console.error('❌ Error reporting user:', error);
      res.status(500).json({ success: false, message: 'Gagal melaporkan pengguna' });
    }
};
  
const blockUser = async (req, res) => {
    try {
      const blockerId = req.user.id;
      const { blockedId } = req.body;
  
      await pool.query(
        'INSERT IGNORE INTO blocked_users (blocker_id, blocked_id) VALUES (?, ?)',
        [blockerId, blockedId]
      );
  
      res.json({ success: true, message: 'Pengguna berhasil diblokir' });
    } catch (error) {
      console.error('❌ Error blocking user:', error);
      res.status(500).json({ success: false, message: 'Gagal memblokir pengguna' });
    }
};

const getBlockedUsers = async (req, res) => {
  try {
    const userId = req.user.id; 

    const [blocked] = await pool.query(`
      SELECT b.id as block_id, u.id as user_id, u.username, b.created_at
      FROM blocked_users b
      JOIN users u ON b.blocked_id = u.id
      WHERE b.blocker_id = ?
    `, [userId]);

    res.json({
      success: true,
      data: blocked,
    });
  } catch (error) {
    console.error('❌ Error getting blocked users:', error);
    res.status(500).json({ success: false, message: 'Gagal mengambil data pengguna yang diblokir.' });
  }
};

const unblockUser = async (req, res) => {
  try {
    const userId = req.user.id;
    const blockId = req.params.id;

    await pool.query(
      'DELETE FROM blocked_users WHERE id = ? AND blocker_id = ?',
      [blockId, userId]
    );

    res.json({
      success: true,
      message: 'Berhasil membuka blokir pengguna.',
    });
  } catch (error) {
    console.error('❌ Error unblocking user:', error);
    res.status(500).json({ success: false, message: 'Gagal membuka blokir pengguna.' });
  }
};

module.exports = {
  joinQueue,
  checkStatus,
  leaveQueue,
  sendMessage,
  getMessages,
  requestConsent,
  respondConsent,
  endChat,
  reportUser,
  blockUser,
  getBlockedUsers,
  unblockUser
};
