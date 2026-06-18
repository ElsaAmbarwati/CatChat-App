// Penjelasan file dan tujuannya:
// Nama file: chat_message.dart
// Deskripsi: File ini mengatur cetakan bentuk data (struktur data).
// Mengarahkan ke/Keterkaitan:
// - Digunakan oleh Controller dan Service untuk membungkus data agar rapi.

class ChatMessage {
  // Mendefinisikan sebuah kelas bernama ChatMessage. Kelas ini akan digunakan untuk merepresentasikan satu pesan dalam obrolan.
  final String text; // Mendeklarasikan properti 'text' bertipe String. Properti ini akan menyimpan isi teks dari pesan.
  final bool isAi; // Mendeklarasikan properti 'isAi' bertipe boolean. Properti ini akan menunjukkan apakah pesan berasal dari AI (true) atau pengguna (false).
  final DateTime time; // Mendeklarasikan properti 'time' bertipe DateTime. Properti ini akan menyimpan stempel waktu (timestamp) kapan pesan dibuat atau dikirim.

  // Ini adalah konstruktor untuk kelas ChatMessage.
  // Konstruktor ini menerima tiga parameter bernama: text, isAi, dan time.
  // Kata kunci 'required' memastikan bahwa ketiga parameter ini harus disediakan saat membuat objek ChatMessage baru.
  // 'this.text', 'this.isAi', dan 'this.time' digunakan untuk menginisialisasi properti kelas dengan nilai yang diberikan ke konstruktor.
  // Tujuan konstruktor ini adalah untuk memudahkan pembuatan objek pesan obrolan dengan semua data yang diperlukan.
  ChatMessage({required this.text, required this.isAi, required this.time});
}