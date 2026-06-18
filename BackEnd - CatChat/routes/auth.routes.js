// Penjelasan file dan tujuannya:
// Nama file: auth.routes.js
// Deskripsi: File ini bertugas sebagai 'pintu masuk' atau pengatur lalu lintas (router) URL API.
// Mengarahkan ke/Keterkaitan:
// - Menerima permintaan dari Frontend.
// - Mengarahkan (memanggil) fungsi spesifik yang ada di dalam folder controllers.

const express = require('express');
const router = express.Router();
const authController = require('../controllers/auth.controller');
const authMiddleware = require('../middleware/auth');

// Public routes (no auth required)
router.post('/register', authController.register);
router.post('/login', authController.login);
router.get('/generate-username', authController.getRandomUsername);

// Protected routes (auth required)
router.post('/logout', authMiddleware, authController.logout);
router.get('/me', authMiddleware, authController.getMe);
router.put('/pin', authMiddleware, authController.updatePin);
router.post('/verify-pin', authMiddleware, authController.verifyPin);

module.exports = router;
