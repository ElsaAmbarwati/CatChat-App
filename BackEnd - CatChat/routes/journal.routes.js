// Penjelasan file dan tujuannya:
// Nama file: journal.routes.js
// Deskripsi: File ini bertugas sebagai 'pintu masuk' atau pengatur lalu lintas (router) URL API.
// Mengarahkan ke/Keterkaitan:
// - Menerima permintaan dari Frontend.
// - Mengarahkan (memanggil) fungsi spesifik yang ada di dalam folder controllers.

const express = require('express');
const router = express.Router();
const journalController = require('../controllers/journal.controller');
const authMiddleware = require('../middleware/auth');

// All journal routes require authentication
router.use(authMiddleware);

// Analytics Route (should be before /:id)
router.get('/mood-summary', journalController.getMoodSummary);

// CRUD Routes
router.get('/', journalController.getJournals);
router.post('/', journalController.createJournal);
router.put('/:id', journalController.updateJournal);
router.delete('/:id', journalController.deleteJournal);

module.exports = router;
