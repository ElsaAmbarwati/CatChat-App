// Penjelasan file dan tujuannya:
// Nama file: profile.controller.js
// Deskripsi: File ini adalah pengatur logika utama (otak) untuk fitur tertentu di sisi server.
// Mengarahkan ke/Keterkaitan:
// - Mengarah ke Frontend: Menerima data (Request) dari HP pengguna dan mengirimkan balasan (Response).
// - Berhubungan dengan Database: Membaca atau menyimpan data ke MySQL.
// - Berhubungan dengan Routes: Dipanggil oleh rute yang sesuai.

const { pool } = require('../config/database'); // Mengimpor objek 'pool' dari konfigurasi database untuk berinteraksi dengan database MySQL.
const bcrypt = require('bcryptjs'); // Mengimpor library bcryptjs untuk hashing password.
const { encrypt, decrypt, hashSHA256 } = require('../utils/encryption'); // Mengimpor fungsi-fungsi enkripsi dan hashing dari file utilitas.

/**
 * GET /api/profile
 * Get current user's full profile
 */
const getProfile = async (req, res) => { // Mendefinisikan fungsi asinkron 'getProfile' yang akan menangani permintaan GET ke endpoint /api/profile.
  try { // Memulai blok try-catch untuk menangani potensi error.
    const [users] = await pool.query( // Mengeksekusi query SQL untuk mengambil data profil pengguna dari tabel 'users'.
      'SELECT id, username, avatar, pin, created_at FROM users WHERE id = ?', // Memilih kolom id, username, avatar, pin, dan created_at dari tabel users, difilter berdasarkan id pengguna yang didapat dari req.user.id.
      [req.user.id] // Parameter untuk query, yaitu ID pengguna yang sedang login yang didapat dari objek request.
    );

    if (users.length === 0) { // Memeriksa apakah query mengembalikan hasil (apakah pengguna ditemukan).
      return res.status(404).json({ // Jika pengguna tidak ditemukan, kirim respons dengan status 404 (Not Found).
        success: false, // Menandakan bahwa operasi gagal.
        message: 'User tidak ditemukan.', // Pesan error yang menjelaskan bahwa user tidak ditemukan.
      });
    }

    const user = users[0]; // Mengambil objek pengguna pertama dari hasil query.

    // Count total stories and total prayers received // Komentar ini menjelaskan tujuan blok kode selanjutnya, yaitu menghitung total cerita dan total doa yang diterima.
    const [stats] = await pool.query(` // Mengeksekusi query SQL untuk menghitung statistik pengguna.
      SELECT 
        COUNT(DISTINCT s.id) AS total_stories, // Menghitung jumlah cerita unik dari tabel 'stories' yang terkait dengan pengguna.
        COUNT(p.id) AS total_prayers_received // Menghitung jumlah doa yang diterima dari tabel 'prayers' yang terkait dengan cerita pengguna.
      FROM stories s // Mengambil data dari tabel 'stories' dengan alias 's'.
      LEFT JOIN prayers p ON p.story_id = s.id // Menggabungkan tabel 'stories' dengan tabel 'prayers' berdasarkan story_id, menggunakan LEFT JOIN agar cerita tanpa doa tetap terhitung.
      WHERE s.user_id = ? // Memfilter hasil agar hanya menyertakan cerita yang dimiliki oleh pengguna yang sedang login.
    `, [req.user.id]); // Parameter untuk query, yaitu ID pengguna yang sedang login.

    res.status(200).json({ // Mengirim respons sukses dengan status 200 (OK) dalam format JSON.
      success: true, // Menandakan bahwa operasi berhasil.
      data: { // Objek yang berisi data profil pengguna.
        id: user.id, // ID pengguna.
        username: user.username, // Nama pengguna.
        avatar: user.avatar, // URL atau nama file avatar pengguna.
        has_pin: !!user.pin, // Mengecek apakah pengguna memiliki PIN (nilai boolean). '!!' mengkonversi nilai truthy/falsy menjadi boolean.
        created_at: user.created_at, // Tanggal pembuatan akun pengguna.
        stats: { // Objek yang berisi statistik pengguna.
          total_stories: stats[0].total_stories, // Jumlah total cerita yang dibuat pengguna.
          total_prayers_received: stats[0].total_prayers_received, // Jumlah total doa yang diterima pengguna.
        },
      },
    });
  } catch (error) { // Menangkap error yang terjadi di dalam blok try.
    console.error('GetProfile error:', error); // Mencatat error ke konsol server untuk debugging.
    res.status(500).json({ // Mengirim respons error dengan status 500 (Internal Server Error).
      success: false, // Menandakan bahwa operasi gagal.
      message: 'Terjadi kesalahan server.', // Pesan error umum untuk klien.
    });
  }
};

/**
 * PUT /api/profile/avatar
 * Update user avatar
 */
const updateAvatar = async (req, res) => { // Mendefinisikan fungsi asinkron 'updateAvatar' untuk menangani permintaan PUT ke endpoint /api/profile/avatar.
  try { // Memulai blok try-catch untuk penanganan error.
    const { avatar } = req.body; // Mengambil data 'avatar' dari body request.

    // Validate avatar name // Komentar menjelaskan bahwa blok kode ini bertujuan untuk memvalidasi nama avatar yang dikirim.
    const validAvatars = ['pf1', 'pf2', 'pf3', 'pf4', 'pf5', 'pf6', 'pf7']; // Mendefinisikan array berisi daftar nama avatar yang valid.
    if (!avatar || !validAvatars.includes(avatar)) { // Memeriksa apakah 'avatar' ada di body request dan apakah nama avatar termasuk dalam daftar avatar yang valid.
      return res.status(400).json({ // Jika validasi gagal, kirim respons dengan status 400 (Bad Request).
        success: false, // Menandakan operasi gagal.
        message: 'Avatar tidak valid. Pilih antara pf1-pf7.', // Pesan error yang memberitahu pengguna tentang avatar yang valid.
      });
    }

    await pool.query( // Mengeksekusi query SQL untuk memperbarui kolom 'avatar' di tabel 'users'.
      'UPDATE users SET avatar = ? WHERE id = ?', // Perintah SQL untuk memperbarui kolom 'avatar' dengan nilai baru dan memfilter berdasarkan 'id' pengguna.
      [avatar, req.user.id] // Parameter untuk query: nama avatar baru dan ID pengguna yang sedang login.
    );

    res.status(200).json({ // Mengirim respons sukses dengan status 200 (OK).
      success: true, // Menandakan operasi berhasil.
      message: 'Avatar berhasil diperbarui!', // Pesan sukses.
      data: { avatar }, // Data avatar yang baru saja diperbarui untuk konfirmasi.
    });
  } catch (error) { // Menangkap error yang terjadi di dalam blok try.
    console.error('UpdateAvatar error:', error); // Mencatat error ke konsol server.
    res.status(500).json({ // Mengirim respons error dengan status 500 (Internal Server Error).
      success: false, // Menandakan operasi gagal.
      message: 'Terjadi kesalahan server.', // Pesan error umum.
    });
  }
};

/**
 * PUT /api/profile/password
 * Change password
 */
const changePassword = async (req, res) => { // Mendefinisikan fungsi asinkron 'changePassword' untuk menangani permintaan PUT ke endpoint /api/profile/password.
  try { // Memulai blok try-catch untuk penanganan error.
    const { current_password, new_password } = req.body; // Mengambil 'current_password' dan 'new_password' dari body request.

    if (!current_password || !new_password) { // Memeriksa apakah kedua field password telah diisi.
      return res.status(400).json({ // Jika salah satu atau keduanya kosong, kirim respons 400 (Bad Request).
        success: false, // Operasi gagal.
        message: 'Password lama dan baru wajib diisi.', // Pesan error.
      });
    }

    if (new_password.length < 6) { // Memeriksa apakah panjang password baru memenuhi syarat minimal 6 karakter.
      return res.status(400).json({ // Jika tidak memenuhi, kirim respons 400 (Bad Request).
        success: false, // Operasi gagal.
        message: 'Password baru minimal 6 karakter.', // Pesan error.
      });
    }

    // Get current password hash // Komentar menjelaskan bahwa blok kode ini akan mengambil hash password pengguna yang tersimpan di database.
    const [users] = await pool.query( // Mengeksekusi query SQL untuk mengambil hash password pengguna.
      'SELECT password FROM users WHERE id = ?', // Memilih kolom 'password' dari tabel 'users' berdasarkan ID pengguna.
      [req.user.id] // Parameter ID pengguna.
    );

    if (users.length === 0) { // Memeriksa apakah pengguna ditemukan.
      return res.status(404).json({ // Jika tidak ditemukan, kirim respons 404 (Not Found).
        success: false, // Operasi gagal.
        message: 'User tidak ditemukan.', // Pesan error.
      });
    }

    // Verify current password // Komentar menjelaskan bahwa blok kode ini akan membandingkan password lama yang dikirim dengan hash password yang tersimpan.
    const isValid = await bcrypt.compare(current_password, users[0].password); // Menggunakan bcrypt.compare untuk membandingkan password lama yang di-hash dengan password lama yang dimasukkan pengguna.
    if (!isValid) { // Memeriksa apakah perbandingan password lama valid.
      return res.status(401).json({ // Jika tidak valid, kirim respons 401 (Unauthorized).
        success: false, // Operasi gagal.
        message: 'Password lama salah.', // Pesan error.
      });
    }

    // Hash new password // Komentar menjelaskan bahwa blok kode ini akan membuat hash untuk password baru.
    const salt = await bcrypt.genSalt(12); // Menghasilkan salt (string acak) untuk proses hashing, dengan tingkat kompleksitas 12.
    const hashedPassword = await bcrypt.hash(new_password, salt); // Melakukan hashing pada password baru menggunakan salt yang telah dibuat.

    await pool.query( // Mengeksekusi query SQL untuk memperbarui password pengguna dengan hash password baru.
      'UPDATE users SET password = ? WHERE id = ?', // Perintah SQL untuk memperbarui kolom 'password' berdasarkan ID pengguna.
      [hashedPassword, req.user.id] // Parameter: hash password baru dan ID pengguna.
    );

    res.status(200).json({ // Mengirim respons sukses dengan status 200 (OK).
      success: true, // Operasi berhasil.
      message: 'Password berhasil diperbarui!', // Pesan sukses.
    });
  } catch (error) { // Menangkap error yang terjadi di dalam blok try.
    console.error('ChangePassword error:', error); // Mencatat error ke konsol server.
    res.status(500).json({ // Mengirim respons error dengan status 500 (Internal Server Error).
      success: false, // Operasi gagal.
      message: 'Terjadi kesalahan server.', // Pesan error umum.
    });
  }
};

/**
 * DELETE /api/profile/account
 * Delete user account and all associated data
 */
const deleteAccount = async (req, res) => { // Mendefinisikan fungsi asinkron 'deleteAccount' untuk menangani permintaan DELETE ke endpoint /api/profile/account.
  try { // Memulai blok try-catch untuk penanganan error.
    const userId = req.user.id; // Mengambil ID pengguna yang sedang login dari objek request.

    // Delete user (stories and prayers cascade) // Komentar menjelaskan bahwa perintah SQL berikutnya akan menghapus pengguna, dan relasi (stories, prayers) akan dihapus secara cascade.
    await pool.query('DELETE FROM users WHERE id = ?', [userId]); // Mengeksekusi query SQL untuk menghapus pengguna dari tabel 'users' berdasarkan ID pengguna.

    res.status(200).json({ // Mengirim respons sukses dengan status 200 (OK).
      success: true, // Operasi berhasil.
      message: 'Akun berhasil dihapus. Semua data telah dihapus.', // Pesan sukses yang memberitahukan bahwa akun dan data terkait telah dihapus.
    });
  } catch (error) { // Menangkap error yang terjadi di dalam blok try.
    console.error('DeleteAccount error:', error); // Mencatat error ke konsol server.
    res.status(500).json({ // Mengirim respons error dengan status 500 (Internal Server Error).
      success: false, // Operasi gagal.
      message: 'Terjadi kesalahan server.', // Pesan error umum.
    });
  }
};

module.exports = { // Mengekspor objek yang berisi semua fungsi controller yang telah didefinisikan.
  getProfile, // Mengekspor fungsi getProfile.
  updateAvatar, // Mengekspor fungsi updateAvatar.
  changePassword, // Mengekspor fungsi changePassword.
  deleteAccount, // Mengekspor fungsi deleteAccount.
}; // Objek ini akan digunakan di file lain untuk memanggil fungsi-fungsi ini, misalnya dalam konfigurasi routing.