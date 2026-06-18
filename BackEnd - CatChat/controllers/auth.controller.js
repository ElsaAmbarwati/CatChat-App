// Penjelasan file dan tujuannya:
// Nama file: auth.controller.js
// Deskripsi: File ini adalah pengatur logika utama (otak) untuk fitur tertentu di sisi server.
// Mengarahkan ke/Keterkaitan:
// - Mengarah ke Frontend: Menerima data (Request) dari HP pengguna dan mengirimkan balasan (Response).
// - Berhubungan dengan Database: Membaca atau menyimpan data ke MySQL.
// - Berhubungan dengan Routes: Dipanggil oleh rute yang sesuai.

const bcrypt = require('bcryptjs'); // Mengimpor library bcryptjs untuk hashing password
const jwt = require('jsonwebtoken'); // Mengimpor library jsonwebtoken untuk membuat dan memverifikasi token
const { pool } = require('../config/database'); // Mengimpor objek pool koneksi database dari konfigurasi
const { encrypt, decrypt, hashSHA256 } = require('../utils/encryption'); // Mengimpor fungsi enkripsi dan hashing dari utility
const { generateUsername } = require('../utils/username-generator'); // Mengimpor fungsi untuk menghasilkan username acak
require('dotenv').config(); // Memuat variabel lingkungan dari file .env

/**
 * Fungsi generateToken
 * Digunakan untuk membuat tiket masuk berupa JWT Token.
 * Token ini akan dipakai pengguna di aplikasi agar tidak perlu login berulang kali.
 */
const generateToken = (user) => {
  // Menggunakan jwt.sign untuk membuat token JWT
  return jwt.sign(
    { id: user.id, email_hash: user.email_hash, username: user.username }, // Payload token: berisi informasi pengguna
    process.env.JWT_SECRET, // Kunci rahasia untuk menandatangani token, diambil dari environment variable
    { expiresIn: '30d' } // Opsi: token akan kedaluwarsa dalam 30 hari
  );
};

/**
 * Rute POST /api/auth/register
 * Fungsi ini bertugas menerima data pendaftaran dari pengguna baru di aplikasi.
 * Terhubung dengan halaman Register di Frontend.
 */
const register = async (req, res) => {
  try {
    // Menangkap data dari body permintaan: email, username, dan password
    const { email, username, password } = req.body;

    // Pengecekan awal: Jika ada kolom yang kosong, tolak pendaftaran.
    if (!email || !username || !password) {
      // Mengirim respons error dengan status 400 (Bad Request) jika ada kolom yang kosong
      return res.status(400).json({
        success: false,
        message: 'Email, username, dan password wajib diisi.',
      });
    }

    // Validate email format
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/; // Pola regex untuk memvalidasi format email
    if (!emailRegex.test(email)) {
      // Mengirim respons error jika format email tidak valid
      return res.status(400).json({
        success: false,
        message: 'Format email tidak valid.',
      });
    }

    // Validate username length
    if (username.length < 3) {
      // Mengirim respons error jika panjang username kurang dari 3 karakter
      return res.status(400).json({
        success: false,
        message: 'Username minimal 3 karakter.',
      });
    }

    // Validate password length
    if (password.length < 6) {
      // Mengirim respons error jika panjang password kurang dari 6 karakter
      return res.status(400).json({
        success: false,
        message: 'Password minimal 6 karakter.',
      });
    }

    // Hash email: Menyembunyikan email asli untuk keperluan pencarian di MySQL
    const emailHash = hashSHA256(email); // Menghasilkan hash SHA256 dari email untuk pencarian yang aman

    // Mengecek ke database apakah email sudah pernah dipakai orang lain
    const [existingEmail] = await pool.query(
      'SELECT id FROM users WHERE email_hash = ?', // Query untuk mencari pengguna dengan email_hash yang sama
      [emailHash] // Mengirim emailHash sebagai parameter query
    );
    if (existingEmail.length > 0) {
      // Mengirim respons error jika email sudah terdaftar
      return res.status(409).json({
        success: false,
        message: 'Email sudah terdaftar.',
      });
    }

    // Mengecek ke database apakah username sudah dipakai orang lain
    const [existingUsername] = await pool.query(
      'SELECT id FROM users WHERE username = ?', // Query untuk mencari pengguna dengan username yang sama
      [username] // Mengirim username sebagai parameter query
    );
    if (existingUsername.length > 0) {
      // Mengirim respons error jika username sudah digunakan
      return res.status(409).json({
        success: false,
        message: 'Username sudah digunakan.',
      });
    }

    // Mengenkripsi email asli pengguna agar aman jika database bocor (Privacy)
    const encryptedEmail = encrypt(email); // Mengenkripsi email asli menggunakan fungsi encrypt

    // Mengacak password menggunakan Bcrypt (Hashing) agar tidak bisa dibaca siapa pun
    const salt = await bcrypt.genSalt(12); // Menghasilkan salt (nilai acak) untuk proses hashing
    const hashedPassword = await bcrypt.hash(password, salt); // Menghasilkan hash dari password menggunakan bcrypt

    // Menyimpan data akun baru ke dalam tabel 'users' di MySQL
    const [result] = await pool.query(
      'INSERT INTO users (email, email_hash, username, password) VALUES (?, ?, ?, ?)', // Query untuk memasukkan data pengguna baru ke database
      [encryptedEmail, emailHash, username, hashedPassword] // Nilai yang akan dimasukkan ke dalam tabel
    );

    // Membuat objek user baru dengan informasi yang relevan setelah berhasil mendaftar
    const newUser = {
      id: result.insertId, // Mengambil ID pengguna yang baru saja dimasukkan
      email_hash: emailHash, // Menyimpan email_hash
      username: username, // Menyimpan username
      avatar: 'pf1', // Menyimpan avatar default
    };

    // Generate JWT
    const token = generateToken(newUser); // Membuat token JWT untuk pengguna baru menggunakan fungsi generateToken

    // Mengirim respons sukses dengan token dan data pengguna
    res.status(201).json({
      success: true,
      message: 'Registrasi berhasil!',
      data: {
        token, // Token JWT yang dihasilkan
        user: {
          id: newUser.id, // ID pengguna
          username: newUser.username, // Username pengguna
          avatar: newUser.avatar, // Avatar pengguna
        },
      },
    });
  } catch (error) {
    // Menangkap dan mencatat error jika terjadi kesalahan selama proses registrasi
    console.error('Register error:', error);
    // Mengirim respons error server
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan server.',
    });
  }
};

/**
 * Rute POST /api/auth/login
 * Fungsi ini digunakan ketika pengguna mencoba masuk (Login) ke aplikasi.
 * Berhubungan dengan halaman Login di Flutter.
 */
const login = async (req, res) => {
  try {
    // Mengambil email dan password dari input aplikasi Flutter
    const { email, password } = req.body;

    // Pengecekan: Tolak jika email atau password tidak diisi
    if (!email || !password) {
      // Mengirim respons error jika email atau password tidak diisi
      return res.status(400).json({
        success: false,
        message: 'Email dan password wajib diisi.',
      });
    }

    // Mengubah email menjadi kode hash untuk dicari kecocokannya di MySQL
    const emailHash = hashSHA256(email); // Menghasilkan hash SHA256 dari email untuk pencarian

    // Mencari data pengguna di database berdasarkan email_hash
    const [users] = await pool.query(
      'SELECT * FROM users WHERE email_hash = ?', // Query untuk mencari pengguna berdasarkan email_hash
      [emailHash] // Mengirim emailHash sebagai parameter query
    );

    // Jika tidak ada pengguna yang ditemukan dengan email_hash tersebut
    if (users.length === 0) {
      // Mengirim respons error otentikasi gagal
      return res.status(401).json({
        success: false,
        message: 'Email atau password salah.',
      });
    }

    const user = users[0]; // Mengambil data pengguna yang ditemukan

    // Membandingkan password yang diketik user dengan password acak di database (Bcrypt)
    const isPasswordValid = await bcrypt.compare(password, user.password); // Membandingkan password yang dimasukkan dengan hash password di database
    if (!isPasswordValid) {
      // Mengirim respons error jika password tidak cocok
      return res.status(401).json({
        success: false,
        message: 'Email atau password salah.',
      });
    }

    // Jika password benar, buatkan JWT Token sebagai tanda masuk
    const token = generateToken(user); // Menghasilkan token JWT menggunakan fungsi generateToken

    // Mengirim respons sukses login dengan token dan data pengguna
    res.status(200).json({
      success: true,
      message: 'Login berhasil!',
      data: {
        token, // Token JWT
        user: {
          id: user.id, // ID pengguna
          username: user.username, // Username pengguna
          avatar: user.avatar, // Avatar pengguna
          has_pin: !!user.pin, // Mengecek apakah pengguna memiliki PIN
        },
      },
    });
  } catch (error) {
    // Menangkap dan mencatat error jika terjadi kesalahan selama proses login
    console.error('Login error:', error);
    // Mengirim respons error server
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan server.',
    });
  }
};

/**
 * POST /api/auth/logout
 * Logout (client-side token invalidation)
 */
const logout = async (req, res) => {
  // JWT is stateless - client just discards the token
  // This endpoint exists for API completeness
  // Token JWT bersifat stateless, jadi logout di sisi server tidak perlu melakukan apa-apa.
  // Klien hanya perlu menghapus token dari penyimpanan lokalnya.
  // Endpoint ini ada untuk kelengkapan API.
  res.status(200).json({
    success: true,
    message: 'Logout berhasil.',
  });
};

/**
 * GET /api/auth/me
 * Get current authenticated user profile
 */
const getMe = async (req, res) => {
  try {
    // Mengambil data pengguna saat ini berdasarkan ID pengguna yang ada di payload token (req.user.id)
    const [users] = await pool.query(
      'SELECT id, username, avatar, pin, created_at FROM users WHERE id = ?', // Query untuk mengambil detail pengguna
      [req.user.id] // Menggunakan ID pengguna dari token
    );

    // Jika tidak ada pengguna yang ditemukan
    if (users.length === 0) {
      // Mengirim respons error not found
      return res.status(404).json({
        success: false,
        message: 'User tidak ditemukan.',
      });
    }

    const user = users[0]; // Mengambil data pengguna

    // Mengirim respons sukses dengan data profil pengguna
    res.status(200).json({
      success: true,
      data: {
        id: user.id, // ID pengguna
        username: user.username, // Username pengguna
        avatar: user.avatar, // Avatar pengguna
        has_pin: !!user.pin, // Mengecek apakah pengguna memiliki PIN
        created_at: user.created_at, // Tanggal pembuatan akun
      },
    });
  } catch (error) {
    // Menangkap dan mencatat error jika terjadi kesalahan
    console.error('GetMe error:', error);
    // Mengirim respons error server
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan server.',
    });
  }
};

/**
 * PUT /api/auth/pin
 * Set or update user PIN
 */
const updatePin = async (req, res) => {
  try {
    const { pin } = req.body; // Mengambil PIN dari body permintaan

    // Validasi PIN: harus ada dan minimal 4 digit
    if (!pin || pin.length < 4) {
      // Mengirim respons error jika PIN tidak valid
      return res.status(400).json({
        success: false,
        message: 'PIN minimal 4 digit.',
      });
    }

    // Hash PIN with SHA-256 (consistent with Flutter frontend)
    const hashedPin = hashSHA256(pin); // Menghash PIN menggunakan SHA256

    // Memperbarui PIN pengguna di database
    await pool.query(
      'UPDATE users SET pin = ? WHERE id = ?', // Query untuk memperbarui PIN
      [hashedPin, req.user.id] // Mengirim hash PIN dan ID pengguna
    );

    // Mengirim respons sukses
    res.status(200).json({
      success: true,
      message: 'PIN berhasil diperbarui.',
    });
  } catch (error) {
    // Menangkap dan mencatat error jika terjadi kesalahan
    console.error('UpdatePin error:', error);
    // Mengirim respons error server
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan server.',
    });
  }
};

/**
 * POST /api/auth/verify-pin
 * Verify user PIN
 */
const verifyPin = async (req, res) => {
  try {
    const { pin } = req.body; // Mengambil PIN dari body permintaan

    // Validasi PIN: harus ada
    if (!pin) {
      // Mengirim respons error jika PIN tidak diisi
      return res.status(400).json({
        success: false,
        message: 'PIN wajib diisi.',
      });
    }

    // Mengambil PIN yang tersimpan di database untuk pengguna yang sedang login
    const [users] = await pool.query(
      'SELECT pin FROM users WHERE id = ?', // Query untuk mengambil PIN pengguna
      [req.user.id] // Menggunakan ID pengguna dari token
    );

    // Jika pengguna tidak ditemukan
    if (users.length === 0) {
      // Mengirim respons error not found
      return res.status(404).json({
        success: false,
        message: 'User tidak ditemukan.',
      });
    }

    // Menghash PIN yang dimasukkan oleh pengguna
    const hashedInputPin = hashSHA256(pin);
    // Membandingkan hash PIN yang dimasukkan dengan hash PIN yang tersimpan di database
    const isValid = users[0].pin === hashedInputPin;

    // Mengirim respons yang berisi status validitas PIN
    res.status(200).json({
      success: true,
      data: { valid: isValid },
    });
  } catch (error) {
    // Menangkap dan mencatat error jika terjadi kesalahan
    console.error('VerifyPin error:', error);
    // Mengirim respons error server
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan server.',
    });
  }
};

/**
 * GET /api/auth/generate-username
 * Generate a random anonymous username
 */
const getRandomUsername = async (req, res) => {
  try {
    let username; // Variabel untuk menyimpan username yang dihasilkan
    let isUnique = false; // Flag untuk menandakan apakah username unik

    // Keep generating until we find a unique one
    // Terus menghasilkan username hingga ditemukan yang unik
    while (!isUnique) {
      username = generateUsername(); // Menghasilkan username acak
      const [existing] = await pool.query(
        'SELECT id FROM users WHERE username = ?', // Mengecek apakah username sudah ada di database
        [username] // Menggunakan username yang dihasilkan
      );
      // Jika tidak ada pengguna dengan username tersebut, maka username itu unik
      if (existing.length === 0) {
        isUnique = true; // Set flag menjadi true untuk keluar dari loop
      }
    }

    // Mengirim respons sukses dengan username yang unik
    res.status(200).json({
      success: true,
      data: { username },
    });
  } catch (error) {
    // Menangkap dan mencatat error jika terjadi kesalahan
    console.error('GenerateUsername error:', error);
    // Mengirim respons error server
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan server.',
    });
  }
};

// Mengekspor semua fungsi controller agar bisa digunakan di file lain (misalnya route handler)
module.exports = {
  register,
  login,
  logout,
  getMe,
  updatePin,
  verifyPin,
  getRandomUsername,
};