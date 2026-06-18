// Penjelasan file dan tujuannya:
// Nama file: journal.controller.js
// Deskripsi: File ini adalah pengatur logika utama (otak) untuk fitur tertentu di sisi server.
// Mengarahkan ke/Keterkaitan:
// - Mengarah ke Frontend: Menerima data (Request) dari HP pengguna dan mengirimkan balasan (Response).
// - Berhubungan dengan Database: Membaca atau menyimpan data ke MySQL.
// - Berhubungan dengan Routes: Dipanggil oleh rute yang sesuai.

const { pool } = require('../config/database'); // Mengimpor objek 'pool' dari konfigurasi database. Objek ini digunakan untuk membuat koneksi ke database dan menjalankan query SQL.

// Konstanta skor mood
const MOOD_SCORES = { // Mendefinisikan skor numerik untuk setiap jenis mood. Ini akan digunakan untuk perhitungan analitik mood.
  senang: 4.0, // Mood 'senang' diberi skor 4.0.
  biasa: 3.0, // Mood 'biasa' diberi skor 3.0.
  capek: 2.0, // Mood 'capek' diberi skor 2.0.
  sedih: 1.0, // Mood 'sedih' diberi skor 1.0.
};

// Konstanta warna mood untuk UI
const MOOD_COLORS = { // Mendefinisikan warna heksadesimal untuk setiap jenis mood. Warna ini digunakan di antarmuka pengguna (UI) untuk merepresentasikan mood.
  senang: '0xFFF4B5A3', // Warna untuk mood 'senang'.
  sedih: '0xFF9EC5FF', // Warna untuk mood 'sedih'.
  capek: '0xFFE6D9D2', // Warna untuk mood 'capek'.
  biasa: '0xFFF7F1EE', // Warna untuk mood 'biasa'.
};

/**
 * GET /api/journals
 * Get all journals for current user
 */
const getJournals = async (req, res) => { // Handler untuk route GET /api/journals. Bertanggung jawab mengambil semua entri jurnal milik pengguna yang terotentikasi.
  try {
    const userId = req.user.id; // Mengambil ID pengguna dari objek 'req.user' yang diisi oleh middleware otentikasi. Ini mengidentifikasi pengguna yang membuat permintaan.

    // Mengambil semua jurnal dari database yang terkait dengan user_id ini, diurutkan berdasarkan tanggal pembuatan terbaru.
    const [journals] = await pool.query( // Menjalankan query SQL menggunakan objek 'pool'.
      'SELECT * FROM journals WHERE user_id = ? ORDER BY created_at DESC', // Query SQL ini memilih semua kolom (*) dari tabel 'journals' di mana 'user_id' cocok dengan parameter yang diberikan, dan mengurutkannya berdasarkan 'created_at' secara menurun (terbaru di atas).
      [userId] // Array berisi parameter yang akan disubstitusikan ke dalam placeholder (?) dalam query SQL. Di sini, hanya 'userId'.
    );

    res.status(200).json({ // Mengirimkan respons HTTP dengan status 200 (OK) dan data JSON.
      success: true, // Properti boolean yang menandakan bahwa operasi berhasil.
      data: journals, // Properti yang berisi array jurnal yang diambil dari database.
    });
  } catch (error) { // Blok 'catch' untuk menangani setiap kesalahan yang terjadi di dalam blok 'try'.
    console.error('GetJournals error:', error); // Mencatat pesan error ke konsol server untuk debugging.
    res.status(500).json({ // Mengirimkan respons HTTP dengan status 500 (Internal Server Error) jika terjadi kesalahan tak terduga.
      success: false, // Properti boolean yang menandakan bahwa operasi gagal.
      message: 'Terjadi kesalahan server saat mengambil data jurnal.', // Pesan error yang akan dikirimkan ke klien.
    });
  }
};

/**
 * POST /api/journals
 * Create a new journal entry
 */
const createJournal = async (req, res) => { // Handler untuk route POST /api/journals. Bertanggung jawab membuat entri jurnal baru.
  try {
    const { title, content, mood } = req.body; // Destructuring untuk mendapatkan properti 'title', 'content', dan 'mood' dari body permintaan HTTP.
    const userId = req.user.id; // Mengambil ID pengguna dari objek 'req.user' yang diisi oleh middleware otentikasi.

    if (!content || !mood) { // Validasi input: Memeriksa apakah 'content' dan 'mood' disediakan dalam body permintaan.
      return res.status(400).json({ // Jika salah satu atau keduanya hilang, kirim respons HTTP 400 (Bad Request).
        success: false, // Menandakan kegagalan operasi.
        message: 'Konten dan Mood wajib diisi.', // Pesan error untuk pengguna.
      });
    }

    if (!Object.keys(MOOD_SCORES).includes(mood)) { // Validasi input: Memeriksa apakah nilai 'mood' yang diberikan ada di dalam kunci objek 'MOOD_SCORES'.
      return res.status(400).json({ // Jika mood tidak valid, kirim respons HTTP 400 (Bad Request).
        success: false, // Menandakan kegagalan operasi.
        message: 'Mood tidak valid. Gunakan: senang, sedih, capek, atau biasa.', // Pesan error yang menjelaskan mood yang valid.
      });
    }

    // Memasukkan entri jurnal baru ke database.
    const [result] = await pool.query( // Menjalankan query INSERT menggunakan 'pool'.
      'INSERT INTO journals (user_id, title, content, mood) VALUES (?, ?, ?, ?)', // Query SQL untuk menyisipkan data baru ke dalam tabel 'journals'. Placeholder (?) akan diganti oleh nilai dari array parameter.
      [userId, title || null, content, mood] // Array parameter: user_id, title (jika tidak disediakan, gunakan null), content, dan mood.
    );

    res.status(201).json({ // Mengirimkan respons HTTP 201 (Created) karena sumber daya baru berhasil dibuat.
      success: true, // Menandakan keberhasilan operasi.
      message: 'Jurnal berhasil disimpan.', // Pesan sukses untuk pengguna.
      data: { // Objek yang berisi detail dari entri jurnal yang baru dibuat.
        id: result.insertId, // 'insertId' adalah ID unik dari baris yang baru saja disisipkan, yang disediakan oleh driver database.
        title: title || '', // Mengembalikan judul yang dimasukkan atau string kosong jika tidak ada.
        content, // Mengembalikan konten yang dimasukkan.
        mood, // Mengembalikan mood yang dimasukkan.
        created_at: new Date().toISOString(), // Menambahkan timestamp saat ini dalam format ISO string sebagai waktu pembuatan.
      },
    });
  } catch (error) { // Blok 'catch' untuk menangani kesalahan.
    console.error('CreateJournal error:', error); // Mencatat error ke konsol.
    res.status(500).json({ // Mengirimkan respons error server.
      success: false, // Menandakan kegagalan.
      message: 'Terjadi kesalahan server saat menyimpan jurnal.', // Pesan error.
    });
  }
};

/**
 * PUT /api/journals/:id
 * Update an existing journal entry
 */
const updateJournal = async (req, res) => { // Handler untuk route PUT /api/journals/:id. Bertanggung jawab memperbarui entri jurnal yang ada.
  try {
    const { id } = req.params; // Mendapatkan ID jurnal dari parameter URL (misalnya, '/api/journals/123' akan memberikan id=123).
    const { title, content, mood } = req.body; // Mendapatkan data yang diperbarui dari body permintaan.
    const userId = req.user.id; // Mendapatkan ID pengguna dari token otentikasi.

    if (!content || !mood) { // Validasi input: Memastikan konten dan mood disediakan.
      return res.status(400).json({ // Mengirim respons Bad Request jika validasi gagal.
        success: false,
        message: 'Konten dan Mood wajib diisi.',
      });
    }

    if (!Object.keys(MOOD_SCORES).includes(mood)) { // Validasi input: Memastikan mood yang diberikan valid.
      return res.status(400).json({ // Mengirim respons Bad Request jika mood tidak valid.
        success: false,
        message: 'Mood tidak valid.',
      });
    }

    // Cek kepemilikan: Memastikan bahwa jurnal yang akan diupdate dimiliki oleh pengguna yang sedang login.
    const [journals] = await pool.query( // Menjalankan query untuk memeriksa apakah jurnal dengan ID yang diberikan dimiliki oleh pengguna yang terotentikasi.
      'SELECT id FROM journals WHERE id = ? AND user_id = ?', // Memilih 'id' dari tabel 'journals' yang cocok dengan ID entri DAN ID pengguna.
      [id, userId] // Parameter untuk query: ID jurnal dan ID pengguna.
    );

    if (journals.length === 0) { // Memeriksa hasil query. Jika array kosong, berarti jurnal tidak ditemukan atau bukan milik pengguna.
      return res.status(404).json({ // Mengirim respons Not Found (404).
        success: false,
        message: 'Jurnal tidak ditemukan atau Anda tidak berhak mengubahnya.',
      });
    }

    // Memperbarui entri jurnal di database.
    await pool.query( // Menjalankan query UPDATE.
      'UPDATE journals SET title = ?, content = ?, mood = ? WHERE id = ?', // Query SQL untuk memperbarui kolom 'title', 'content', dan 'mood' untuk baris dengan 'id' yang cocok.
      [title || null, content, mood, id] // Parameter untuk query: nilai baru untuk title, content, mood, dan ID jurnal yang akan diperbarui.
    );

    res.status(200).json({ // Mengirimkan respons OK (200).
      success: true,
      message: 'Jurnal berhasil diperbarui.',
    });
  } catch (error) { // Menangani kesalahan.
    console.error('UpdateJournal error:', error); // Mencatat error.
    res.status(500).json({ // Mengirim respons error server.
      success: false,
      message: 'Terjadi kesalahan server.',
    });
  }
};

/**
 * DELETE /api/journals/:id
 * Delete a journal entry
 */
const deleteJournal = async (req, res) => { // Handler untuk route DELETE /api/journals/:id. Bertanggung jawab menghapus entri jurnal.
  try {
    const { id } = req.params; // Mendapatkan ID jurnal dari parameter URL.
    const userId = req.user.id; // Mendapatkan ID pengguna dari token otentikasi.

    // Cek kepemilikan: Memastikan bahwa jurnal yang akan dihapus dimiliki oleh pengguna yang sedang login.
    const [journals] = await pool.query( // Menjalankan query untuk memeriksa kepemilikan jurnal.
      'SELECT id FROM journals WHERE id = ? AND user_id = ?', // Memilih 'id' dari tabel 'journals' yang cocok dengan ID entri DAN ID pengguna.
      [id, userId] // Parameter: ID jurnal dan ID pengguna.
    );

    if (journals.length === 0) { // Memeriksa apakah jurnal ditemukan dan dimiliki oleh pengguna.
      return res.status(404).json({ // Mengirim respons Not Found (404) jika tidak ditemukan atau bukan milik pengguna.
        success: false,
        message: 'Jurnal tidak ditemukan.',
      });
    }

    // Menghapus entri jurnal dari database.
    await pool.query('DELETE FROM journals WHERE id = ?', [id]); // Menjalankan query DELETE untuk menghapus baris dari tabel 'journals' berdasarkan ID.

    res.status(200).json({ // Mengirimkan respons OK (200).
      success: true,
      message: 'Jurnal berhasil dihapus.',
    });
  } catch (error) { // Menangani kesalahan.
    console.error('DeleteJournal error:', error); // Mencatat error.
    res.status(500).json({ // Mengirim respons error server.
      success: false,
      message: 'Terjadi kesalahan server.',
    });
  }
};

/**
 * GET /api/moods/summary
 * Get mood analytics based on journal entries
 */
const getMoodSummary = async (req, res) => { // Handler untuk route GET /api/moods/summary. Bertanggung jawab menghitung dan mengembalikan ringkasan analitik mood pengguna.
  try {
    const userId = req.user.id; // Mendapatkan ID pengguna dari token otentikasi.

    // Ambil semua entri jurnal beserta mood-nya, diurutkan dari yang paling lama.
    const [entries] = await pool.query( // Mengambil data jurnal yang relevan untuk perhitungan analitik.
      'SELECT mood, created_at FROM journals WHERE user_id = ? ORDER BY created_at ASC', // Query memilih hanya kolom 'mood' dan 'created_at' untuk user tertentu, diurutkan menaik berdasarkan tanggal.
      [userId] // Parameter ID pengguna.
    );

    if (entries.length === 0) { // Memeriksa jika tidak ada entri jurnal.
      return res.status(200).json({ // Mengirim respons OK dengan data default jika tidak ada entri.
        success: true,
        data: {
          dominant_mood: null, // Tidak ada mood dominan.
          average_score: 0, // Skor rata-rata adalah 0.
          weekly_data: [], // Data mingguan kosong.
          monthly_data: [], // Data bulanan kosong.
        },
      });
    }

    const now = new Date(); // Mendapatkan tanggal dan waktu saat ini.
    const thirtyDaysAgo = new Date(); // Membuat objek Date baru untuk batas 30 hari.
    thirtyDaysAgo.setDate(now.getDate() - 30); // Mengatur tanggal menjadi 30 hari sebelum tanggal saat ini.

    // 1. Hitung Dominant Mood dan Average Score (Berdasarkan 30 HARI TERAKHIR saja)
    let totalScore30Days = 0; // Variabel untuk mengakumulasi total skor mood dalam 30 hari terakhir.
    let count30Days = 0; // Variabel untuk menghitung jumlah entri dalam 30 hari terakhir.
    const moodCounts = { senang: 0, biasa: 0, capek: 0, sedih: 0 }; // Objek untuk menyimpan frekuensi setiap jenis mood dalam 30 hari terakhir.

    entries.forEach(entry => { // Iterasi melalui setiap entri jurnal yang diambil.
      const entryDate = new Date(entry.created_at); // Mengonversi string tanggal entri menjadi objek Date.
      if (entryDate >= thirtyDaysAgo) { // Memeriksa apakah tanggal entri berada dalam rentang 30 hari terakhir.
        totalScore30Days += MOOD_SCORES[entry.mood]; // Menambahkan skor mood dari entri saat ini ke total.
        count30Days++; // Menambah hitungan entri yang valid.
        moodCounts[entry.mood]++; // Menambah hitungan untuk jenis mood spesifik.
      }
    });

    const averageScore = count30Days > 0 ? (totalScore30Days / count30Days) : 0; // Menghitung skor rata-rata. Jika count30Days adalah 0, maka averageScore adalah 0 untuk menghindari pembagian dengan nol.
    
    // Cari dominant mood di 30 hari terakhir
    let dominantMood = 'biasa'; // Inisialisasi mood dominan dengan nilai default.
    let maxCount = -1; // Inisialisasi hitungan maksimum untuk pencarian mood dominan.
    for (const [mood, count] of Object.entries(moodCounts)) { // Iterasi melalui objek moodCounts.
      if (count > maxCount) { // Jika hitungan mood saat ini lebih besar dari hitungan maksimum yang ditemukan sejauh ini.
        maxCount = count; // Perbarui hitungan maksimum.
        dominantMood = mood; // Perbarui mood dominan.
      }
    }
    
    // Jika tidak ada data 30 hari terakhir, ambil dari keseluruhan data yang ada
    if (count30Days === 0) { // Kondisi ini dijalankan jika tidak ada entri dalam 30 hari terakhir.
        const allMoodCounts = { senang: 0, biasa: 0, capek: 0, sedih: 0 }; // Objek untuk menghitung frekuensi mood dari semua entri (jika tidak ada data 30 hari terakhir).
        let allScore = 0; // Variabel untuk total skor dari semua entri.
        entries.forEach(entry => { // Iterasi melalui SEMUA entri jurnal.
            allScore += MOOD_SCORES[entry.mood]; // Menambahkan skor mood ke total.
            allMoodCounts[entry.mood]++; // Menambah hitungan untuk jenis mood spesifik dari semua entri.
        });
        
        let allMax = -1; // Inisialisasi hitungan maksimum untuk pencarian mood dominan dari semua entri.
        for (const [mood, count] of Object.entries(allMoodCounts)) { // Iterasi melalui objek allMoodCounts.
            if (count > allMax) { // Jika hitungan mood saat ini lebih besar dari hitungan maksimum dari semua entri.
                allMax = count; // Perbarui hitungan maksimum.
                dominantMood = mood; // Perbarui mood dominan berdasarkan data keseluruhan.
            }
        }
    }

    // 2. Data Grafik Mingguan (7 Hari Terakhir)
    const weeklyData = []; // Array untuk menyimpan data mingguan yang akan digunakan untuk grafik.
    for (let i = 6; i >= 0; i--) { // Loop berjalan dari 6 hari yang lalu hingga hari ini (untuk mendapatkan data 7 hari terakhir).
      const date = new Date(); // Mendapatkan tanggal saat ini untuk setiap iterasi.
      date.setDate(now.getDate() - i); // Mengatur tanggal menjadi 'i' hari yang lalu dari tanggal saat ini.
      const dateStr = date.toISOString().split('T')[0]; // Mengonversi tanggal ke format string 'YYYY-MM-DD'.
      
      const dayEntries = entries.filter(e => { // Memfilter entri jurnal yang dibuat pada tanggal yang sedang diproses dalam loop.
        const ed = new Date(e.created_at); // Mengonversi tanggal entri ke objek Date.
        return ed.toISOString().split('T')[0] === dateStr; // Membandingkan tanggal entri dengan tanggal target.
      });

      let dayScore = 0; // Variabel untuk skor rata-rata mood pada hari tertentu.
      if (dayEntries.length > 0) { // Jika ada entri untuk hari tersebut.
        const sum = dayEntries.reduce((acc, curr) => acc + MOOD_SCORES[curr.mood], 0); // Menjumlahkan skor mood dari semua entri pada hari itu.
        dayScore = sum / dayEntries.length; // Menghitung skor rata-rata untuk hari itu.
      }

      // Format label hari (Sen, Sel, dll)
      const dayNames = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab']; // Array nama-nama hari dalam bahasa Indonesia.
      const dayLabel = dayNames[date.getDay()]; // Mendapatkan label nama hari berdasarkan indeks hari (0=Minggu, 1=Senin, dst.).

      weeklyData.push({ // Menambahkan objek data ke array 'weeklyData'.
        label: dayLabel, // Label nama hari (e.g., "Sen").
        date: `${String(date.getDate()).padStart(2, '0')}-${String(date.getMonth() + 1).padStart(2, '0')}-${date.getFullYear()}`, // Format tanggal menjadi DD-MM-YYYY.
        value: parseFloat(dayScore.toFixed(1)) // Skor rata-rata harian, dibulatkan hingga satu angka desimal.
      });
    }

    // 3. Data Grafik Bulanan (6 Bulan Terakhir)
    const monthlyData = []; // Array untuk menyimpan data bulanan yang akan digunakan untuk grafik.
    for (let i = 5; i >= 0; i--) { // Loop berjalan dari 5 bulan yang lalu hingga bulan ini (untuk mendapatkan data 6 bulan terakhir).
      const monthDate = new Date(now.getFullYear(), now.getMonth() - i, 1); // Membuat objek Date untuk hari pertama dari setiap bulan dalam rentang 6 bulan.
      
      const monthEntries = entries.filter(e => { // Memfilter entri jurnal yang dibuat dalam bulan yang sedang diproses dalam loop.
        const ed = new Date(e.created_at); // Mengonversi tanggal entri ke objek Date.
        return ed.getFullYear() === monthDate.getFullYear() && ed.getMonth() === monthDate.getMonth(); // Membandingkan tahun dan bulan entri dengan tahun dan bulan target.
      });

      let monthScore = 0; // Variabel untuk skor rata-rata mood pada bulan tertentu.
      if (monthEntries.length > 0) { // Jika ada entri untuk bulan tersebut.
        const sum = monthEntries.reduce((acc, curr) => acc + MOOD_SCORES[curr.mood], 0); // Menjumlahkan skor mood dari semua entri pada bulan itu.
        monthScore = sum / monthEntries.length; // Menghitung skor rata-rata untuk bulan itu.
      }

      const monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des']; // Array nama-nama bulan dalam bahasa Indonesia.
      const monthLabel = monthNames[monthDate.getMonth()]; // Mendapatkan label nama bulan berdasarkan indeks bulan (0=Januari, 1=Februari, dst.).

      monthlyData.push({ // Menambahkan objek data ke array 'monthlyData'.
        label: monthLabel, // Label nama bulan (e.g., "Jan").
        date: `${monthLabel} ${monthDate.getFullYear()}`, // Format tanggal menjadi "Jan 2023".
        value: parseFloat(monthScore.toFixed(1)) // Skor rata-rata bulanan, dibulatkan hingga satu angka desimal.
      });
    }

    res.status(200).json({ // Mengirimkan respons OK (200) dengan data analitik.
      success: true,
      data: {
        dominant_mood: dominantMood, // Mood yang paling sering muncul dalam 30 hari terakhir (atau keseluruhan jika data 30 hari tidak ada).
        average_score: parseFloat(averageScore.toFixed(1)), // Skor rata-rata mood dalam 30 hari terakhir (atau keseluruhan).
        weekly_data: weeklyData, // Array data mingguan untuk grafik.
        monthly_data: monthlyData, // Array data bulanan untuk grafik.
        // Kirimkan info warna dan detail dominant mood sekalian untuk mempermudah UI Frontend
        dominant_mood_detail: { // Objek tambahan berisi detail tentang mood dominan untuk memudahkan rendering di frontend.
            label: dominantMood.charAt(0).toUpperCase() + dominantMood.slice(1), // Label mood dominan dengan huruf pertama kapital (e.g., "Senang").
            imagePath: `assets/images/${dominantMood == 'biasa' ? 'biasa_aja' : dominantMood}.png`, // Path ke gambar yang sesuai dengan mood dominan. Jika mood-nya 'biasa', gunakan 'biasa_aja.png', jika tidak, gunakan nama mood itu sendiri.
            color: MOOD_COLORS[dominantMood] // Kode warna heksadesimal yang sesuai dengan mood dominan, diambil dari konstanta MOOD_COLORS.
        }
      },
    });
  } catch (error) { // Menangani kesalahan.
    console.error('GetMoodSummary error:', error); // Mencatat error.
    res.status(500).json({ // Mengirim respons error server.
      success: false,
      message: 'Terjadi kesalahan server saat menganalisis mood.',
    });
  }
};

module.exports = { // Mengekspor objek yang berisi semua fungsi controller yang telah didefinisikan. Ini memungkinkan fungsi-fungsi ini diimpor dan digunakan di file lain (misalnya, file router).
  getJournals, // Mengekspor fungsi getJournals.
  createJournal, // Mengekspor fungsi createJournal.
  updateJournal, // Mengekspor fungsi updateJournal.
  deleteJournal, // Mengekspor fungsi deleteJournal.
  getMoodSummary, // Mengekspor fungsi getMoodSummary.
};