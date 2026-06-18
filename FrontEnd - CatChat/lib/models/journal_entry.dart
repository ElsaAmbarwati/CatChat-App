// Penjelasan file dan tujuannya:
// Nama file: journal_entry.dart
// Deskripsi: File ini mengatur cetakan bentuk data (struktur data).
// Mengarahkan ke/Keterkaitan:
// - Digunakan oleh Controller dan Service untuk membungkus data agar rapi.

class JournalEntry { // Mendefinisikan sebuah kelas bernama JournalEntry, yang merepresentasikan satu entri jurnal.
  final int id; // Variabel final untuk menyimpan ID unik dari entri jurnal. `final` berarti nilainya hanya bisa diset sekali.
  final String title; // Variabel final untuk menyimpan judul entri jurnal.
  final String content; // Variabel final untuk menyimpan konten atau isi dari entri jurnal.
  final String mood; // Variabel final untuk menyimpan suasana hati (mood) yang terkait dengan entri jurnal.
  final DateTime date; // Variabel final untuk menyimpan tanggal dan waktu entri jurnal dibuat atau diperbarui.

  JournalEntry({ // Constructor (konstruktor) untuk membuat objek JournalEntry baru.
    required this.id, // Mengharuskan ID disediakan saat membuat objek.
    required this.title, // Mengharuskan judul disediakan.
    required this.content, // Mengharuskan konten disediakan.
    required this.mood, // Mengharuskan suasana hati disediakan.
    required this.date, // Mengharuskan tanggal disediakan.
  }); // Constructor ini menginisialisasi properti-properti kelas dengan nilai yang diberikan.

  factory JournalEntry.fromJson(Map<String, dynamic> json) { // Ini adalah factory constructor yang digunakan untuk membuat objek JournalEntry dari data JSON (biasanya dari API atau database).
    return JournalEntry( // Mengembalikan instance (objek) JournalEntry yang baru dibuat.
      id: json['id'], // Mengambil nilai 'id' dari map JSON dan menetapkannya ke properti id. Ini akan memetakan kolom 'id' dari data JSON ke properti `id` pada objek Dart.
      title: json['title'] ?? '', // Mengambil nilai 'title' dari JSON; jika null, menggunakan string kosong. Ini memastikan `title` selalu ada, meskipun nilai aslinya kosong di JSON.
      content: json['content'] ?? '', // Mengambil nilai 'content' dari JSON; jika null, menggunakan string kosong. Ini memastikan `content` selalu ada.
      mood: json['mood'] ?? 'biasa', // Mengambil nilai 'mood' dari JSON; jika null, menggunakan string 'biasa' sebagai default. Ini memberikan nilai default jika 'mood' tidak ada dalam data JSON.
      date: json['updated_at'] != null // Memeriksa apakah kunci 'updated_at' ada di dalam map JSON. Ini adalah langkah validasi sebelum mencoba mem-parsing tanggal.
          ? DateTime.parse(json['updated_at']) // Jika 'updated_at' ada (tidak null), parsing string tanggal tersebut menjadi objek DateTime Dart. Ini digunakan untuk tanggal pembaruan.
          : DateTime.parse(json['created_at']), // Jika 'updated_at' tidak ada (null), maka gunakan 'created_at' dan parsing string tanggal tersebut menjadi objek DateTime. Ini digunakan sebagai fallback untuk tanggal pembuatan jika tanggal pembaruan tidak tersedia.
    ); // Constructor ini mengonversi struktur data JSON menjadi objek Dart yang terstruktur, menangani potensi nilai null dan mem-parsing string tanggal.
  }
}