// Penjelasan file dan tujuannya:
// Nama file: mood_tracker_controller.dart
// Deskripsi: File ini adalah pengatur logika (otak) di balik layar UI.
// Mengarahkan ke/Keterkaitan:
// - Mengarah ke Backend/Service: Memanggil API melalui jaringan untuk mengambil/menyimpan data.
// - Berhubungan dengan Layar: Data dari sini akan ditampilkan ke layar UI (pages).

// Mengimpor library 'dart:convert' untuk mengelola data JSON (misalnya, mendekode respons dari API).
import 'dart:convert';
// Mengimpor package Flutter material.dart yang berisi definisi widget, utilitas UI, dan ChangeNotifier.
import 'package:flutter/material.dart';
// Mengimpor 'api_service.dart' dari direktori '../services', yang digunakan untuk melakukan panggilan API ke backend.
import '../services/api_service.dart';

// Mendefinisikan kelas MoodType untuk merepresentasikan sebuah jenis suasana hati.
// Kelas ini berfungsi sebagai model data untuk setiap mood yang akan ditampilkan di aplikasi.
class MoodType {
  // Variabel final 'key' untuk identifikasi unik mood (misal: 'senang').
  final String key;
  // Variabel final 'label' untuk nama mood yang akan ditampilkan ke pengguna (misal: 'Senang').
  final String label;
  // Variabel final 'imagePath' untuk lokasi aset gambar terkait mood ini.
  final String imagePath;
  // Variabel final 'tintColor' untuk warna yang terkait dengan mood ini, biasanya untuk visualisasi di UI.
  final Color tintColor;

  // Constructor konstan untuk kelas MoodType.
  // Semua properti bersifat 'required' (wajib diisi) saat membuat instance MoodType.
  const MoodType({
    required this.key, // Menetapkan bahwa 'key' harus disediakan.
    required this.label, // Menetapkan bahwa 'label' harus disediakan.
    required this.imagePath, // Menetapkan bahwa 'imagePath' harus disediakan.
    required this.tintColor, // Menetapkan bahwa 'tintColor' harus disediakan.
  });
}

// Mendefinisikan kelas ChartPoint untuk merepresentasikan satu titik data dalam grafik.
// Kelas ini berfungsi sebagai model data untuk data yang akan digambarkan pada chart.
class ChartPoint {
  // Variabel final 'label' untuk label sumbu X atau kategori titik data (misal: 'Sen', 'Jan').
  final String label;
  // Variabel final 'dateStr' untuk representasi string tanggal dari titik data.
  final String dateStr;
  // Variabel final 'value' untuk nilai numerik titik data yang akan digambarkan di sumbu Y grafik.
  final double value;

  // Constructor konstan untuk kelas ChartPoint.
  // Semua properti bersifat 'required' (wajib diisi) saat membuat instance ChartPoint.
  const ChartPoint({
    required this.label, // Menetapkan bahwa 'label' harus disediakan.
    required this.dateStr, // Menetapkan bahwa 'dateStr' harus disediakan.
    required this.value, // Menetapkan bahwa 'value' harus disediakan.
  });
}

// Mendefinisikan kelas MoodTrackerController yang mengelola logika bisnis dan state untuk fitur mood tracker.
// Kelas ini mewarisi ChangeNotifier, yang memungkinkan widget untuk 'mendengarkan' perubahan pada properti di controller ini.
class MoodTrackerController extends ChangeNotifier {
  // Variabel statis konstan 'moodTypes' yang berisi daftar pre-defined dari semua jenis mood yang didukung aplikasi.
  // Ini adalah data master yang digunakan di seluruh aplikasi untuk referensi mood.
  static const List<MoodType> moodTypes = [
    // Definisi objek MoodType untuk mood 'Senang' beserta propertinya.
    MoodType(
      key: 'senang', // Kunci unik untuk mood 'Senang'.
      label: 'Senang', // Label yang ditampilkan.
      imagePath: 'assets/images/senang.png', // Path gambar terkait.
      tintColor: Color(0xFFF4B5A3), // Warna visual terkait.
    ),
    // Definisi objek MoodType untuk mood 'Sedih'.
    MoodType(
      key: 'sedih',
      label: 'Sedih',
      imagePath: 'assets/images/sedih.png',
      tintColor: Color(0xFF9EC5FF),
    ),
    // Definisi objek MoodType untuk mood 'Capek'.
    MoodType(
      key: 'capek',
      label: 'Capek',
      imagePath: 'assets/images/capek.png',
      tintColor: Color(0xFFE6D9D2),
    ),
    // Definisi objek MoodType untuk mood 'Biasa'.
    MoodType(
      key: 'biasa',
      label: 'Biasa',
      imagePath: 'assets/images/biasa_aja.png',
      tintColor: Color(0xFFF7F1EE),
    ),
  ];

  // Variabel privat '_isLoading' untuk melacak status apakah data sedang dalam proses pengambilan dari backend.
  bool _isLoading = false;
  // Getter publik 'isLoading' yang mengizinkan akses read-only ke status loading dari luar kelas.
  bool get isLoading => _isLoading;

  // Variabel privat '_averageScore' untuk menyimpan rata-rata skor mood yang diambil dari backend.
  double _averageScore = 0.0;
  // Variabel privat '_dominantMoodKey' untuk menyimpan kunci (key) mood yang paling dominan dalam periode tertentu.
  String _dominantMoodKey = 'biasa';

  // List privat '_weeklyData' untuk menyimpan data grafik mingguan, berisi objek ChartPoint.
  List<ChartPoint> _weeklyData = [];
  // List privat '_monthlyData' untuk menyimpan data grafik bulanan, berisi objek ChartPoint.
  List<ChartPoint> _monthlyData = [];

  // Constructor MoodTrackerController.
  // Saat instance controller ini dibuat, method 'fetchSummary()' akan langsung dipanggil.
  MoodTrackerController() {
    fetchSummary(); // Memulai proses pengambilan data ringkasan mood segera setelah controller diinisialisasi.
  }

  // Getter publik 'averageScore' yang mengizinkan akses read-only ke rata-rata skor mood.
  double get averageScore => _averageScore;

  // Getter publik 'dominantMood' yang mengembalikan objek MoodType yang dominan.
  // Ini mencari MoodType dari daftar 'moodTypes' berdasarkan '_dominantMoodKey'.
  MoodType get dominantMood {
    return moodTypes.firstWhere(
      (m) => m.key == _dominantMoodKey, // Mencari MoodType yang kuncinya cocok dengan '_dominantMoodKey'.
      orElse: () => moodTypes.last, // Jika tidak ditemukan, kembalikan objek MoodType terakhir (yang biasanya 'Biasa').
    );
  }

  // Method asinkron 'fetchSummary' untuk mengambil data ringkasan mood dari backend.
  // Method ini akan memanggil API dan memperbarui state controller.
  Future<void> fetchSummary() async {
    _isLoading = true; // Set status loading menjadi true.
    notifyListeners(); // Beri tahu semua widget yang mendengarkan bahwa status loading telah berubah, memicu rebuild UI.

    try {
      // Melakukan permintaan HTTP GET ke endpoint '/journals/mood-summary' menggunakan ApiService.
      final response = await ApiService.instance.get('/journals/mood-summary');
      // Memeriksa apakah respons dari server memiliki status code 200 (OK).
      if (response.statusCode == 200) {
        // Mendekode body respons JSON dan mengambil bagian 'data'.
        final data = jsonDecode(response.body)['data'];
        // Memperbarui '_averageScore' dengan nilai dari 'average_score' di respons, jika null akan menggunakan 0.0.
        _averageScore = (data['average_score'] ?? 0.0).toDouble();
        // Memperbarui '_dominantMoodKey' dengan nilai dari 'dominant_mood' di respons, jika null akan menggunakan 'biasa'.
        _dominantMoodKey = data['dominant_mood'] ?? 'biasa';

        // Mengambil data mingguan ('weekly_data') dari respons sebagai List.
        final weeklyList = data['weekly_data'] as List;
        // Mengkonversi setiap item di 'weeklyList' menjadi objek ChartPoint dan menyimpannya di '_weeklyData'.
        _weeklyData = weeklyList.map((e) => ChartPoint(
          label: e['label'], // Mengambil label dari data JSON.
          dateStr: e['date'], // Mengambil string tanggal dari data JSON.
          value: (e['value'] ?? 0.0).toDouble(), // Mengambil nilai, jika null default ke 0.0.
        )).toList(); // Mengkonversi hasil map menjadi List.

        // Mengambil data bulanan ('monthly_data') dari respons sebagai List.
        final monthlyList = data['monthly_data'] as List;
        // Mengkonversi setiap item di 'monthlyList' menjadi objek ChartPoint dan menyimpannya di '_monthlyData'.
        _monthlyData = monthlyList.map((e) => ChartPoint(
          label: e['label'],
          dateStr: e['date'],
          value: (e['value'] ?? 0.0).toDouble(),
        )).toList();
      }
    } catch (e) {
      // Menangkap dan mencetak error jika terjadi kesalahan selama proses pengambilan data API.
      print('Fetch mood summary error: $e');
    }

    _isLoading = false; // Set status loading menjadi false setelah proses selesai (baik berhasil atau gagal).
    notifyListeners(); // Beri tahu semua widget yang mendengarkan bahwa status loading telah berubah kembali.
  }

  // Method 'buildWeeklyData' untuk menyediakan data grafik mingguan yang siap ditampilkan di UI.
  List<ChartPoint> buildWeeklyData() {
    // Memeriksa apakah '_weeklyData' yang di-fetch dari backend kosong.
    if (_weeklyData.isEmpty) {
      // Jika kosong, membuat struktur data fallback (data dummy) untuk 7 hari terakhir.
      final today = DateUtils.dateOnly(DateTime.now()); // Mendapatkan tanggal hari ini saja (tanpa waktu).
      return List.generate(7, (index) { // Membuat list berisi 7 ChartPoint.
        final date = today.subtract(Duration(days: 6 - index)); // Menghitung tanggal untuk setiap hari (dari 6 hari lalu hingga hari ini).
        return ChartPoint(
          label: _weekdayLabel(date.weekday), // Menggunakan helper method untuk mendapatkan label hari singkat.
          dateStr: '', // String tanggal dikosongkan karena ini data fallback.
          value: 0, // Nilai default 0 untuk data fallback.
        );
      });
    }
    // Jika '_weeklyData' tidak kosong (sudah ada data dari backend), kembalikan data tersebut.
    return _weeklyData;
  }

  // Method 'buildMonthlyData' untuk menyediakan data grafik bulanan yang siap ditampilkan di UI.
  List<ChartPoint> buildMonthlyData() {
    // Memeriksa apakah '_monthlyData' yang di-fetch dari backend kosong.
    if (_monthlyData.isEmpty) {
      final today = DateTime.now(); // Mendapatkan tanggal dan waktu saat ini.
      // Jika kosong, membuat struktur data fallback (data dummy) untuk 6 bulan terakhir.
      return List.generate(6, (index) { // Membuat list berisi 6 ChartPoint.
        // Menghitung tanggal untuk bulan-bulan sebelumnya (dari 5 bulan lalu hingga bulan ini).
        final monthDate = DateTime(today.year, today.month - 5 + index, 1);
        return ChartPoint(
          label: _monthLabel(monthDate.month), // Menggunakan helper method untuk mendapatkan label bulan singkat.
          dateStr: '', // String tanggal dikosongkan karena ini data fallback.
          value: 0, // Nilai default 0 untuk data fallback.
        );
      });
    }
    // Jika '_monthlyData' tidak kosong (sudah ada data dari backend), kembalikan data tersebut.
    return _monthlyData;
  }

  // Helper method privat '_weekdayLabel' untuk mengkonversi nilai integer hari dalam seminggu (dari DateTime) menjadi label string singkat (misal: 1 -> 'Sen').
  String _weekdayLabel(int weekday) {
    switch (weekday) { // Menggunakan pernyataan switch untuk memetakan nilai hari.
      case DateTime.monday: return 'Sen'; // Jika hari Senin, kembalikan 'Sen'.
      case DateTime.tuesday: return 'Sel'; // Jika hari Selasa, kembalikan 'Sel'.
      case DateTime.wednesday: return 'Rab'; // Dan seterusnya...
      case DateTime.thursday: return 'Kam';
      case DateTime.friday: return 'Jum';
      case DateTime.saturday: return 'Sab';
      case DateTime.sunday: return 'Min';
      default: return ''; // Jika tidak ada yang cocok, kembalikan string kosong.
    }
  }

  // Helper method privat '_monthLabel' untuk mengkonversi nilai integer bulan (dari DateTime) menjadi label string singkat (misal: 1 -> 'Jan').
  String _monthLabel(int month) {
    switch (month) { // Menggunakan pernyataan switch untuk memetakan nilai bulan.
      case 1: return 'Jan'; // Jika bulan 1 (Januari), kembalikan 'Jan'.
      case 2: return 'Feb';
      case 3: return 'Mar';
      case 4: return 'Apr';
      case 5: return 'Mei';
      case 6: return 'Jun';
      case 7: return 'Jul';
      case 8: return 'Agu';
      case 9: return 'Sep';
      case 10: return 'Okt';
      case 11: return 'Nov';
      case 12: return 'Des';
      default: return ''; // Jika tidak ada yang cocok, kembalikan string kosong.
    }
  }
}