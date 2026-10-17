# APLIKASI BERBASIS WEB UNTUK DEEPTALK ANONIM DALAM MEMPEROLEH SOLUSI BAGI GENERASI MUDA
ELSA AMBARWATI

## ABSTRAK
Tingginya tingkat perundungan siber (cyberbullying), sentimen negatif, dan fenomena fear of missing out (FOMO) di media sosial konvensional telah memicu lonjakan krisis kesehatan mental di kalangan Generasi Z. Jika ruang interaksi digital yang aman tidak segera diciptakan, keengganan generasi muda dalam mengekspresikan emosi akibat takut akan stigma sosial akan semakin memperburuk tingkat stres dan kecemasan mereka. Untuk menyelesaikan permasalahan tersebut, penelitian ini merancang dan membangun aplikasi e-mental health bernama Deeptalk Anonim (CatChat) sebagai ekosistem sosial tertutup (safe space). Langkah penyelesaian dilakukan dengan mengembangkan aplikasi cross-platform menggunakan framework Flutter dan backend Node.js, di mana kolom komentar bebas pada fitur publik ditiadakan secara desain untuk memotong rantai toksisitas. Metode yang digunakan juga meliputi implementasi expressive writing melalui Jurnal Harian yang terintegrasi dengan Mood Tracker, serta penggabungan Application Programming Interface (API) Google Gemini untuk menghadirkan fitur “Teman Curhat AI” yang mampu merespons secara seketika (real-time) berbekal analitik Natural Language Processing (NLP). Berdasarkan hasil pengujian perangkat lunak (Black Box Testing), aplikasi terbukti berhasil memfasilitasi interaksi anonim yang aman, beroperasi secara tanggap dengan manajemen memori yang efisien, serta sukses menjadi media alternatif yang empatik untuk memitigasi risiko gangguan kecemasan akibat lingkungan digital bagi generasi muda.
Kata Kunci: Kesehatan Mental, Anonimitas, Cyberbullying, Kecerdasan Buatan, Natural Language Processing.

## 1. PENDAHULUAN
Kesehatan mental telah menjadi salah satu isu krusial dalam krisis kesehatan masyarakat global, khususnya yang berdampak pada kelompok usia remaja dan dewasa muda atau yang sering disebut sebagai Generasi Z. Di era digitalisasi yang sangat masif ini, generasi muda dihadapkan pada dinamika kehidupan yang serba cepat. Tekanan akademik, tuntutan sosial, gaya hidup yang kompetitif, serta tingginya ekspektasi lingkungan seringkali menjadi pemicu utama timbulnya stres, kecemasan (anxiety), hingga depresi. 

Seiring dengan kemajuan teknologi, pemanfaatan platform digital atau e-mental health mulai diakui sebagai salah satu medium alternatif untuk memfasilitasi komunikasi dan penyaluran emosi. Namun, implementasi fitur obrolan anonim konvensional yang menghubungkan antar sesama pengguna manusia (peer-to-peer) membawa risiko perundungan siber (cyberbullying) dan pelecehan verbal jika tanpa sistem moderasi yang ketat. 

Untuk mengatasi permasalahan tersebut dan menciptakan ruang aman (safe space) yang sesungguhnya, diperlukan sebuah inovasi teknologi yang mampu menggantikan peran manusia sebagai pendengar dalam obrolan anonim, yaitu integrasi Artificial Intelligence (AI). AI dapat diprogram untuk bertindak sebagai pendengar yang sepenuhnya objektif, tidak menghakimi (non-judgmental), dan merespons dengan pendekatan empatik.

Penelitian ini mengusulkan perancangan dan pengembangan aplikasi berbasis web untuk deeptalk anonim. Aplikasi ini dirancang tidak hanya sekadar menyediakan fitur pesan instan (Chat) bersama agen cerdas (AI), tetapi juga dilengkapi dengan Mood Tracker, Jurnal Harian, serta Dinding Doa sebagai wadah ekspresi anonim tanpa kolom komentar berisiko toksik. Tujuannya adalah menciptakan ruang aman yang terkontrol bagi generasi muda dalam mengekspresikan diri dan mencari solusi atas permasalahan psikologis mereka.

## 2. METODOLOGI PENELITIAN
Penelitian diawali dengan mengidentifikasi kebutuhan generasi muda akan ruang curhat digital yang aman, kemudian dilanjutkan dengan pengumpulan data, perancangan sistem, implementasi, dan pengujian.
Pengumpulan data dilakukan melalui studi pustaka dan pengujian sistem secara langsung (Black Box Testing).
Sistem ini menggunakan arsitektur aplikasi berbasis klien-server. Frontend dibangun menggunakan framework Flutter (berjalan di sisi klien/web browser) dan memanfaatkan SharedPreferences untuk penyimpanan lokal data sesi dan riwayat percakapan. Backend dibangun menggunakan Node.js dan Express.js, bertindak sebagai perantara yang menangani logika bisnis dan komunikasi dengan basis data MySQL serta layanan pihak ketiga (API Google Gemini AI).

Metode perancangan konseptual divisualisasikan menggunakan Flowchart, Use Case Diagram, Activity Diagram, dan Sequence Diagram untuk memetakan alur kerja pengguna (seperti register/login, pengelolaan dinding doa, chat AI, pencatatan jurnal, dan mood tracker). Perancangan fisik melibatkan pembuatan skema database relasional (tabel users, stories, prayers, journals) serta desain antarmuka responsif.

## 3. HASIL DAN PEMBAHASAN
Aplikasi Deeptalk Anonim (CatChat) berhasil dikembangkan sesuai dengan perancangan. 
1. Implementasi Database: Menggunakan MySQL dengan struktur tabel yang telah dirancang untuk menyimpan kredensial pengguna, cerita Dinding Doa, doa (prayers), dan entri Jurnal Harian.
2. Implementasi Antarmuka (User Interface): Halaman utama, register, login, App Lock (PIN), Dinding Doa, Chat AI, Jurnal Harian, Mood Tracker, dan Profil berhasil diimplementasikan menggunakan Flutter web. Antarmuka terhubung dengan backend Node.js untuk pemrosesan data.
3. Fitur Chat AI: Telah terintegrasi dengan Google Gemini API. Pengguna dapat melakukan percakapan privat dengan agen cerdas, di mana setiap pesan masukan (prompt) diproses untuk menghasilkan balasan empatik secara real-time.
4. Pengujian: Hasil pengujian perangkat lunak menggunakan Black Box Testing menunjukkan bahwa semua fitur (Autentikasi, Dinding Doa, Chat AI, Jurnal, Mood Tracker) berfungsi sesuai skenario yang direncanakan.
Aplikasi ini berhasil mengatasi celah keamanan psikologis yang ada pada platform anonim konvensional (seperti Telegram atau Twitter) dengan meniadakan fitur komentar publik dan mengganti interaksi manusia dengan agen cerdas, sehingga mengeliminasi risiko cyberbullying.

## 4. KESIMPULAN
Aplikasi Deeptalk Anonim berhasil dibangun menggunakan framework Flutter dan backend Node.js sebagai ruang curhat yang aman (safe space) bagi generasi muda. Aplikasi meniadakan kolom komentar bebas pada fitur Dinding Doa, mengintegrasikan Jurnal Harian dengan Mood Tracker, serta memfasilitasi interaksi curhat melalui AI (Google Gemini API). Penggunaan arsitektur berbasis REST-API dan penyimpanan lokal membatasi riwayat percakapan secara efisien, sehingga aplikasi berjalan tanggap dan aman untuk memitigasi risiko cyberbullying di lingkungan digital.

## 5. DAFTAR PUSTAKA
[1] Adnandi, Muhammad Arba, dkk. 2025. “ANALISIS MINDNEST: INOVASI APLIKASI KESEHATAN MENTAL DIGITAL BERBASIS MOBILE...”.
[2] Aurellia, Zerlina, dkk. 2024. “Pengalaman Pengguna X Sebagai Platform Curhat (Studi Fenomenologi)”.
[3] Fahrezi, Fahmi, dkk. 2025. “Pemanfaatan Fitur @AnonymousChat Telegram Sebagai Media Kuratif...”.
[4] Hartono, B. 2023. Sistem Informasi Manajemen Dan Pemodelan UML. Penerbit Andi.
[5] Lee, Yi Ping, dkk. 2025. “Delving into the World of WebCHAT – an e-Mental Health Support Service for Distressed Youths in Singapore”.
[6] Rahmanto, Anugrah Nur, dkk. “PENERAPAN DESIGN THINKING DENGAN USABILITY TESTING...”.
[7] Thorn, Pinar, dkk. 2023. “Motivations and Perceived Harms and Benefits of Online Communication about Self-Harm”.
[8] Zein, A. 2023. Rekayasa Perangkat Lunak Dan Pemodelan Sistem Cerdas. Penerbit Informatika.
