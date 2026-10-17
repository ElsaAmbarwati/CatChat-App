// Penjelasan file dan tujuannya:
// Nama file: peer-chat.routes.js
// Deskripsi: Definisi endpoint untuk fitur Ruang Curhat (Peer Chat).
// Mengarahkan ke/Keterkaitan:
// - Digunakan di server.js
// - Memanggil fungsi dari peer-chat.controller.js

const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/auth');
const peerChatController = require('../controllers/peer-chat.controller');

// Semua rute ini memerlukan otentikasi
router.use(authMiddleware);

// Polling and Chat endpoints
router.post('/join', peerChatController.joinQueue);
router.get('/status', peerChatController.checkStatus);
router.post('/leave', peerChatController.leaveQueue);
router.post('/send', peerChatController.sendMessage);
router.get('/messages/:roomId', peerChatController.getMessages);
router.post('/consent/request', peerChatController.requestConsent);
router.post('/consent/respond', peerChatController.respondConsent);
router.post('/end', peerChatController.endChat);
router.post('/report', peerChatController.reportUser);
router.post('/block', peerChatController.blockUser);

// Endpoint untuk daftar pengguna yang diblokir
router.get('/blocked', peerChatController.getBlockedUsers);
router.delete('/blocked/:id', peerChatController.unblockUser);

module.exports = router;
