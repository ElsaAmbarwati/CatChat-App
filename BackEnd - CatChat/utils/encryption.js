// Penjelasan file dan tujuannya:
// Nama file: encryption.js
// Deskripsi: Mengatur logika server backend.
// Mengarahkan ke/Keterkaitan:
// Berhubungan dengan komponen backend lainnya.

const crypto = require('crypto');
require('dotenv').config();

const ENCRYPTION_KEY = process.env.ENCRYPTION_KEY || 'AnonHeartCatChat2026SecureKey32!';
const IV_LENGTH = 16; // AES block size

/**
 * Encrypt a string using AES-256-CBC
 * @param {string} text - The plaintext to encrypt
 * @returns {string} - The encrypted string (iv:encrypted format, hex encoded)
 */
const encrypt = (text) => {
  const iv = crypto.randomBytes(IV_LENGTH);
  const cipher = crypto.createCipheriv('aes-256-cbc', Buffer.from(ENCRYPTION_KEY, 'utf-8'), iv);
  let encrypted = cipher.update(text, 'utf8', 'hex');
  encrypted += cipher.final('hex');
  return iv.toString('hex') + ':' + encrypted;
};

/**
 * Decrypt a string encrypted with AES-256-CBC
 * @param {string} encryptedText - The encrypted string (iv:encrypted format)
 * @returns {string} - The decrypted plaintext
 */
const decrypt = (encryptedText) => {
  const parts = encryptedText.split(':');
  const iv = Buffer.from(parts[0], 'hex');
  const encrypted = parts[1];
  const decipher = crypto.createDecipheriv('aes-256-cbc', Buffer.from(ENCRYPTION_KEY, 'utf-8'), iv);
  let decrypted = decipher.update(encrypted, 'hex', 'utf8');
  decrypted += decipher.final('utf8');
  return decrypted;
};

/**
 * Create a SHA-256 hash of a string (for email lookup)
 * @param {string} text - The string to hash
 * @returns {string} - The hex-encoded SHA-256 hash
 */
const hashSHA256 = (text) => {
  return crypto.createHash('sha256').update(text.toLowerCase().trim()).digest('hex');
};

module.exports = { encrypt, decrypt, hashSHA256 };
