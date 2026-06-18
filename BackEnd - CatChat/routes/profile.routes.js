// Penjelasan file dan tujuannya:
// Nama file: profile.routes.js
// Deskripsi: File ini bertugas sebagai 'pintu masuk' atau pengatur lalu lintas (router) URL API.
// Mengarahkan ke/Keterkaitan:
// - Menerima permintaan dari Frontend.
// - Mengarahkan (memanggil) fungsi spesifik yang ada di dalam folder controllers.

const express = require('express');
const router = express.Router();
const profileController = require('../controllers/profile.controller');
const authMiddleware = require('../middleware/auth');

// All profile routes require authentication
router.use(authMiddleware);

router.get('/', profileController.getProfile);                  // Get profile with stats
router.put('/avatar', profileController.updateAvatar);          // Update avatar
router.put('/password', profileController.changePassword);      // Change password
router.delete('/account', profileController.deleteAccount);     // Delete account

module.exports = router;
