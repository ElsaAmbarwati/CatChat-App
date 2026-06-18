// Penjelasan file dan tujuannya:
// Nama file: auth.js
// Deskripsi: Mengatur logika server backend.
// Mengarahkan ke/Keterkaitan:
// Berhubungan dengan komponen backend lainnya.

const jwt = require('jsonwebtoken');
require('dotenv').config();

/**
 * JWT Authentication Middleware
 * Extracts and verifies JWT token from Authorization header
 * Adds user data (id, email_hash, username) to req.user
 */
const authMiddleware = (req, res, next) => {
  try {
    // Get token from header
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        success: false,
        message: 'Akses ditolak. Token tidak ditemukan.',
      });
    }

    const token = authHeader.split(' ')[1];

    // Verify token
    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    // Attach user data to request
    req.user = {
      id: decoded.id,
      email_hash: decoded.email_hash,
      username: decoded.username,
    };

    next();
  } catch (error) {
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({
        success: false,
        message: 'Token sudah kadaluarsa. Silakan login kembali.',
      });
    }

    return res.status(401).json({
      success: false,
      message: 'Token tidak valid.',
    });
  }
};

module.exports = authMiddleware;
