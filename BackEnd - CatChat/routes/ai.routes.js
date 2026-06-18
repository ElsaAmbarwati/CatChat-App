// Penjelasan file dan tujuannya:
// Nama file: ai.routes.js
// Deskripsi: File ini bertugas sebagai 'pintu masuk' atau pengatur lalu lintas (router) URL API.
// Mengarahkan ke/Keterkaitan:
// - Menerima permintaan dari Frontend.
// - Mengarahkan (memanggil) fungsi spesifik yang ada di dalam folder controllers.

const express = require('express');
const router = express.Router();
const { generateAIResponse } = require('../controllers/ai.controller');

// Route untuk mengirim pesan ke AI
router.post('/chat', generateAIResponse);

module.exports = router;
