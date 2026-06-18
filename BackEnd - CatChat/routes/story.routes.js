// Penjelasan file dan tujuannya:
// Nama file: story.routes.js
// Deskripsi: File ini bertugas sebagai 'pintu masuk' atau pengatur lalu lintas (router) URL API.
// Mengarahkan ke/Keterkaitan:
// - Menerima permintaan dari Frontend.
// - Mengarahkan (memanggil) fungsi spesifik yang ada di dalam folder controllers.

const express = require('express');
const router = express.Router();
const storyController = require('../controllers/story.controller');
const authMiddleware = require('../middleware/auth');

// All story routes require authentication
router.use(authMiddleware);

// Get stories
router.get('/', storyController.getAllPublicStories);         // Public anonymous stories
router.get('/mine', storyController.getMyStories);            // My own stories (with prayer count)
router.get('/latest', storyController.getLatestStories);      // Latest stories for home page

// CRUD operations
router.post('/', storyController.createStory);                // Create story
router.put('/:id', storyController.updateStory);              // Edit own story
router.delete('/:id', storyController.deleteStory);           // Delete own story

// Special actions
router.patch('/:id/privacy', storyController.togglePrivacy);  // Toggle public/private
router.post('/:id/pray', storyController.togglePrayer);       // Toggle prayer (doa)

module.exports = router;
