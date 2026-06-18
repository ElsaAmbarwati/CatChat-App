// Penjelasan file dan tujuannya:
// Nama file: story.controller.js
// Deskripsi: File ini adalah pengatur logika utama (otak) untuk fitur tertentu di sisi server.
// Mengarahkan ke/Keterkaitan:
// - Mengarah ke Frontend: Menerima data (Request) dari HP pengguna dan mengirimkan balasan (Response).
// - Berhubungan dengan Database: Membaca atau menyimpan data ke MySQL.
// - Berhubungan dengan Routes: Dipanggil oleh rute yang sesuai.

const { pool } = require('../config/database');

/**
 * GET /api/stories
 * Get all public stories (anonymous - no user identity exposed)
 * Sorted by newest first
 */
const getAllPublicStories = async (req, res) => {
  try {
    const userId = req.user.id;

    const [stories] = await pool.query(`
      SELECT 
        s.id,
        s.content,
        s.created_at,
        CASE WHEN p.id IS NOT NULL THEN TRUE ELSE FALSE END AS has_prayed
      FROM stories s
      LEFT JOIN prayers p ON p.story_id = s.id AND p.user_id = ?
      WHERE s.is_private = 0 AND s.user_id != ?
      ORDER BY s.created_at DESC
    `, [userId, userId]);

    res.status(200).json({
      success: true,
      data: stories,
    });
  } catch (error) {
    console.error('GetAllPublicStories error:', error);
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan server.',
    });
  }
};

/**
 * GET /api/stories/mine
 * Get current user's own stories (with prayer count visible)
 * Sorted by newest first
 */
const getMyStories = async (req, res) => {
  try {
    const userId = req.user.id;

    const [stories] = await pool.query(`
      SELECT 
        s.id,
        s.content,
        s.is_private,
        s.created_at,
        s.updated_at,
        COUNT(p.id) AS prayer_count
      FROM stories s
      LEFT JOIN prayers p ON p.story_id = s.id
      WHERE s.user_id = ?
      GROUP BY s.id
      ORDER BY s.created_at DESC
    `, [userId]);

    res.status(200).json({
      success: true,
      data: stories,
    });
  } catch (error) {
    console.error('GetMyStories error:', error);
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan server.',
    });
  }
};

/**
 * GET /api/stories/latest
 * Get latest public stories for home page preview (anonymous)
 * Returns max 5 stories
 */
const getLatestStories = async (req, res) => {
  try {
    const userId = req.user.id;

    const [stories] = await pool.query(`
      SELECT 
        s.id,
        s.content,
        s.created_at,
        CASE WHEN p.id IS NOT NULL THEN TRUE ELSE FALSE END AS has_prayed
      FROM stories s
      LEFT JOIN prayers p ON p.story_id = s.id AND p.user_id = ?
      WHERE s.is_private = 0 AND s.user_id != ?
      ORDER BY s.created_at DESC
      LIMIT 5
    `, [userId, userId]);

    res.status(200).json({
      success: true,
      data: stories,
    });
  } catch (error) {
    console.error('GetLatestStories error:', error);
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan server.',
    });
  }
};

/**
 * POST /api/stories
 * Create a new story
 */
const createStory = async (req, res) => {
  try {
    const { content } = req.body;
    const userId = req.user.id;

    if (!content || content.trim().length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Konten cerita tidak boleh kosong.',
      });
    }

    const [result] = await pool.query(
      'INSERT INTO stories (user_id, content) VALUES (?, ?)',
      [userId, content.trim()]
    );

    res.status(201).json({
      success: true,
      message: 'Cerita berhasil dibuat!',
      data: {
        id: result.insertId,
        content: content.trim(),
        is_private: false,
        prayer_count: 0,
        created_at: new Date().toISOString(),
      },
    });
  } catch (error) {
    console.error('CreateStory error:', error);
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan server.',
    });
  }
};

/**
 * PUT /api/stories/:id
 * Edit own story
 */
const updateStory = async (req, res) => {
  try {
    const { id } = req.params;
    const { content } = req.body;
    const userId = req.user.id;

    if (!content || content.trim().length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Konten cerita tidak boleh kosong.',
      });
    }

    // Check ownership
    const [stories] = await pool.query(
      'SELECT id, user_id FROM stories WHERE id = ?',
      [id]
    );

    if (stories.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Cerita tidak ditemukan.',
      });
    }

    if (stories[0].user_id !== userId) {
      return res.status(403).json({
        success: false,
        message: 'Anda tidak memiliki izin untuk mengedit cerita ini.',
      });
    }

    await pool.query(
      'UPDATE stories SET content = ? WHERE id = ?',
      [content.trim(), id]
    );

    res.status(200).json({
      success: true,
      message: 'Cerita berhasil diperbarui!',
    });
  } catch (error) {
    console.error('UpdateStory error:', error);
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan server.',
    });
  }
};

/**
 * DELETE /api/stories/:id
 * Delete own story
 */
const deleteStory = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;

    // Check ownership
    const [stories] = await pool.query(
      'SELECT id, user_id FROM stories WHERE id = ?',
      [id]
    );

    if (stories.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Cerita tidak ditemukan.',
      });
    }

    if (stories[0].user_id !== userId) {
      return res.status(403).json({
        success: false,
        message: 'Anda tidak memiliki izin untuk menghapus cerita ini.',
      });
    }

    // Delete story (prayers will cascade)
    await pool.query('DELETE FROM stories WHERE id = ?', [id]);

    res.status(200).json({
      success: true,
      message: 'Cerita berhasil dihapus.',
    });
  } catch (error) {
    console.error('DeleteStory error:', error);
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan server.',
    });
  }
};

/**
 * PATCH /api/stories/:id/privacy
 * Toggle story privacy (public/private)
 */
const togglePrivacy = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;

    // Check ownership
    const [stories] = await pool.query(
      'SELECT id, user_id, is_private FROM stories WHERE id = ?',
      [id]
    );

    if (stories.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Cerita tidak ditemukan.',
      });
    }

    if (stories[0].user_id !== userId) {
      return res.status(403).json({
        success: false,
        message: 'Anda tidak memiliki izin untuk mengubah cerita ini.',
      });
    }

    const newPrivacy = !stories[0].is_private;

    await pool.query(
      'UPDATE stories SET is_private = ? WHERE id = ?',
      [newPrivacy ? 1 : 0, id]
    );

    res.status(200).json({
      success: true,
      message: newPrivacy ? 'Cerita diprivasi.' : 'Cerita dipublikasikan.',
      data: { is_private: newPrivacy },
    });
  } catch (error) {
    console.error('TogglePrivacy error:', error);
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan server.',
    });
  }
};

/**
 * POST /api/stories/:id/pray
 * Toggle prayer (doa) on a story
 * Only for stories owned by OTHER users
 */
const togglePrayer = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;

    // Check story exists and is not own story
    const [stories] = await pool.query(
      'SELECT id, user_id, is_private FROM stories WHERE id = ?',
      [id]
    );

    if (stories.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Cerita tidak ditemukan.',
      });
    }

    if (stories[0].user_id === userId) {
      return res.status(400).json({
        success: false,
        message: 'Tidak bisa mendoakan cerita sendiri.',
      });
    }

    if (stories[0].is_private) {
      return res.status(403).json({
        success: false,
        message: 'Cerita ini bersifat privat.',
      });
    }

    // Check if already prayed
    const [existingPrayer] = await pool.query(
      'SELECT id FROM prayers WHERE story_id = ? AND user_id = ?',
      [id, userId]
    );

    if (existingPrayer.length > 0) {
      // Remove prayer (un-pray)
      await pool.query(
        'DELETE FROM prayers WHERE story_id = ? AND user_id = ?',
        [id, userId]
      );

      res.status(200).json({
        success: true,
        message: 'Doa dibatalkan.',
        data: { prayed: false },
      });
    } else {
      // Add prayer
      await pool.query(
        'INSERT INTO prayers (story_id, user_id) VALUES (?, ?)',
        [id, userId]
      );

      res.status(200).json({
        success: true,
        message: 'Doa dikirimkan. 🤲',
        data: { prayed: true },
      });
    }
  } catch (error) {
    console.error('TogglePrayer error:', error);
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan server.',
    });
  }
};

module.exports = {
  getAllPublicStories,
  getMyStories,
  getLatestStories,
  createStory,
  updateStory,
  deleteStory,
  togglePrivacy,
  togglePrayer,
};
