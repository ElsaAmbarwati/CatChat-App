// Penjelasan file controller ini dan tujuannya.
// Nama file: ai.controller.js.
// Deskripsi: Controller ini bertanggung jawab untuk mengintegrasikan layanan Chat AI.
// Fungsi utamanya adalah memproses pesan yang diterima dari pengguna,
// menambahkan instruksi sistem (system prompt) yang telah ditentukan,
// lalu meneruskan informasi tersebut ke API Google Gemini untuk mendapatkan balasan.
// Keterkaitan (Connections):
// - Eksternal: Berkomunikasi dengan library @google/generative-ai, yang merupakan wrapper untuk REST-API Google Gemini.
// - Frontend: Setelah mendapatkan balasan dari AI, controller ini akan mengirimkan teks balasan tersebut
//   kembali ke `chat_controller.dart` di aplikasi Flutter, yang akan menampilkannya di antarmuka pengguna.
const { GoogleGenerativeAI } = require('@google/generative-ai'); // Mengimpor kelas GoogleGenerativeAI dari package `@google/generative-ai` untuk berinteraksi dengan API Gemini.

// Inisialisasi Gemini API dengan key dari .env
const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY); // Membuat instance baru dari GoogleGenerativeAI menggunakan kunci API yang diambil dari variabel lingkungan `GEMINI_API_KEY`.
                                                                  // Instance ini akan digunakan untuk mengakses layanan Gemini.

// Mendefinisikan fungsi asynchronous `generateAIResponse` yang akan menangani permintaan dan mengirimkan respons.
const generateAIResponse = async (req, res) => {
  try { // Memulai blok try-catch untuk menangani potensi error yang mungkin terjadi selama proses.
    const { message, history } = req.body; // Mengambil `message` (pesan terbaru dari pengguna) dan `history` (riwayat chat)
                                          // dari body permintaan HTTP. Variabel ini akan digunakan sebagai input untuk AI.

    if (!message) { // Memeriksa apakah `message` tidak ada atau kosong.
      return res.status(400).json({ success: false, message: 'Pesan tidak boleh kosong.' }); // Jika pesan kosong, mengirim respons error 400 (Bad Request)
                                                                                             // yang menunjukkan bahwa pesan input tidak valid.
    }

    if (!process.env.GEMINI_API_KEY) { // Memeriksa apakah variabel lingkungan `GEMINI_API_KEY` belum dikonfigurasi.
      return res.status(500).json({ success: false, message: 'GEMINI_API_KEY belum dikonfigurasi di server.' }); // Jika kunci API tidak ada, mengirim respons error 500 (Internal Server Error)
                                                                                                                  // karena server tidak dapat beroperasi tanpa kunci tersebut.
    }

    // System Prompt untuk membentuk karakter AI sebagai teman curhat psikologis
    const systemInstruction = `Kamu adalah teman curhat anonim di aplikasi CatChat (juga dikenal sebagai AnonHeart).
Tugasmu adalah mendengarkan dengan penuh empati, ramah, dan suportif.
Gunakan bahasa Indonesia yang santai, gaul, namun tetap sopan (seperti ngobrol dengan teman sebaya).
Jangan menghakimi (non-judgmental).
Jangan berlagak seperti robot atau AI, bertingkahlah seperti manusia yang peduli.
Selain mendengarkan dengan empati, kamu HARUS selalu memberikan 1 pertanyaan pancingan yang lembut dan relevan di akhir balasanmu. Tujuannya untuk menggali lebih dalam perasaan pengguna, memancing mereka agar mau bercerita lebih banyak, atau membantu mereka mencari akar permasalahannya sendiri. Jangan pasif.
Jika pengguna menyebutkan kata-kata terkait menyakiti diri sendiri (bunuh diri, self-harm, putus asa yang parah), 
berikan dukungan moral ekstra dan sarankan mereka untuk menghubungi psikolog profesional atau layanan darurat.
Jaga balasanmu tetap ringkas (maksimal 3-4 kalimat pendek) agar nyaman dibaca di layar HP.`; // Mendefinisikan `systemInstruction` (system prompt) yang panjang.
                                                                                              // Ini adalah instruksi penting yang membentuk "karakter" AI,
                                                                                              // membuatnya bertindak sebagai teman curhat yang empatik, suportif,
                                                                                              // dan memberikan pertanyaan pancingan, serta saran profesional jika diperlukan.

    // Menggunakan model Gemini 2.5 Flash Lite (Batas harian lebih besar untuk free tier)
    const model = genAI.getGenerativeModel({ // Mendapatkan instance model generatif dari objek `genAI`.
      model: "gemini-2.5-flash-lite", // Menentukan model AI yang akan digunakan adalah "gemini-2.5-flash-lite" agar tidak mudah kena limit.
      systemInstruction: systemInstruction // Menerapkan `systemInstruction` yang telah didefinisikan sebelumnya ke model.
                                          // Ini memastikan model akan mengikuti persona dan pedoman yang diberikan.
    });

    // Format riwayat chat untuk Gemini
    const formattedHistory = []; // Menginisialisasi array kosong untuk menyimpan riwayat chat yang telah diformat agar sesuai dengan format yang diharapkan oleh API Gemini.
    if (history && Array.isArray(history)) { // Memeriksa apakah `history` ada dan merupakan sebuah array.
      for (const msg of history) { // Melakukan iterasi melalui setiap pesan (`msg`) dalam array `history`.
        if (!msg.text) continue; // Jika sebuah pesan tidak memiliki properti `text`, lewati pesan tersebut dan lanjutkan ke pesan berikutnya.
        formattedHistory.push({ // Menambahkan objek baru ke `formattedHistory`.
          role: msg.isAi ? "model" : "user", // Menentukan peran (role) pesan: "model" jika pesan berasal dari AI (`isAi` true), atau "user" jika dari pengguna.
          parts: [{ text: msg.text }] // Menambahkan bagian (parts) pesan, yang berisi objek dengan properti `text` yang merupakan isi pesan.
        });
      }
    }

    // PENTING: Gemini API mewajibkan riwayat chat harus dimulai dengan role "user".
    // Karena kita baru saja menambahkan pesan sapaan awal dari AI, riwayat akan dimulai dengan "model".
    // Kita harus membuang pesan "model" di awal array jika ada.
    while (formattedHistory.length > 0 && formattedHistory[0].role === "model") { // Melakukan loop selama `formattedHistory` tidak kosong DAN pesan pertama memiliki role "model".
      formattedHistory.shift(); // Menghapus elemen pertama dari array `formattedHistory`.
                                // Ini dilakukan untuk memastikan riwayat chat yang dikirim ke Gemini selalu dimulai dengan pesan dari "user",
                                // sesuai dengan persyaratan API Gemini.
    }

    // Memulai sesi obrolan yang memiliki ingatan/memori
    const chat = model.startChat({ // Memulai sesi chat baru menggunakan `model` yang telah dikonfigurasi.
      history: formattedHistory // Meneruskan `formattedHistory` sebagai riwayat obrolan ke sesi chat,
                                // memungkinkan AI untuk "mengingat" percakapan sebelumnya.
    });

    // Kirim pesan terbaru ke sesi obrolan
    // PENTING UNTUK SIDANG:
    // Di sinilah proses pengiriman pesan ke server Google Gemini terjadi (secara asynchronous).
    const result = await chat.sendMessage(message); // Mengirim `message` (pesan terbaru dari pengguna) ke sesi chat.
                                                    // Ini adalah panggilan asynchronous ke API Gemini untuk mendapatkan balasan.
    const responseText = result.response.text(); // Mengekstrak teks balasan dari objek `result` yang diterima dari Gemini.

    res.status(200).json({ // Mengirim respons HTTP dengan status 200 (OK).
      success: true, // Menunjukkan bahwa operasi berhasil.
      data: { // Objek `data` berisi balasan dari AI.
        reply: responseText // Balasan teks dari AI yang akan dikirim kembali ke frontend.
      }
    });

  } catch (error) { // Menangkap error jika terjadi di dalam blok try.
    console.error('❌ AI Chat Error:', error); // Mencetak pesan error ke konsol server untuk debugging.
    res.status(500).json({ // Mengirim respons HTTP dengan status 500 (Internal Server Error) jika terjadi kesalahan.
      success: false, // Menunjukkan bahwa operasi gagal.
      message: 'Gagal terhubung ke AI.', // Pesan umum tentang kegagalan koneksi ke AI.
      error: error.message // Menyertakan pesan error spesifik untuk informasi lebih lanjut (tidak ditampilkan ke pengguna).
    });
  }
};

module.exports = { // Mengekspor objek yang berisi fungsi `generateAIResponse`.
  generateAIResponse // Membuat fungsi `generateAIResponse` tersedia untuk diimpor dan digunakan di bagian lain aplikasi (misalnya, di router).
};