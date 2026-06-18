// Penjelasan file dan tujuannya:
// Nama file: home_controller.dart
// Deskripsi: File ini adalah pengatur logika (otak) di balik layar UI.
// Mengarahkan ke/Keterkaitan:
// - Mengarah ke Backend/Service: Memanggil API melalui jaringan untuk mengambil/menyimpan data.
// - Berhubungan dengan Layar: Data dari sini akan ditampilkan ke layar UI (pages).

import 'dart:async'; // Mengimpor pustaka 'dart:async' untuk mendukung operasi asinkron seperti Timer.
import 'dart:convert'; // Mengimpor pustaka 'dart:convert' untuk mengonversi data JSON.
import 'dart:math'; // Mengimpor pustaka 'dart:math' untuk menghasilkan angka acak, digunakan untuk memilih kutipan.
import 'package:flutter/material.dart'; // Mengimpor pustaka 'flutter/material.dart' untuk membangun UI Flutter dan kelas ChangeNotifier.
import '../services/auth_service.dart'; // Mengimpor 'auth_service.dart' dari direktori '../services/' untuk layanan otentikasi.
import '../services/api_service.dart'; // Mengimpor 'api_service.dart' dari direktori '../services/' untuk layanan API.

// HomeController adalah sebuah ChangeNotifier, yang berarti ia dapat memberi tahu widget-widget yang mendengarkannya tentang perubahan state.
// Controller ini akan mengelola state untuk halaman utama, termasuk kutipan, nama pengguna, dan daftar cerita.
class HomeController extends ChangeNotifier {
  // Daftar kutipan statis yang akan ditampilkan secara acak.
  static const List<String> _quotes = [
    'Jangan menyerah, kesuksesan membutuhkan kerja keras.',
    'Hidup hanya sekali, jadikan setiap momen berharga.',
    'Tak perlu mengejar popularitas, yang penting jadi diri sendiri.',
    'Kebersamaan yang tulus lebih berharga dari harta materi.',
    'Berpikirlah dua kali sebelum bertindak.',
    'Hargai dirimu sendiri sebelum mengharapkan orang lain menghargaimu.',
    'Impian tanpa tindakan hanyalah ilusi.',
    'Setiap kegagalan adalah kesempatan untuk belajar.',
    'Jangan takut untuk menjadi diri sendiri, yang penting jujur.',
    'Kebahagiaan sejati datang dari dalam hati, bukan dari hal-hal material.',
    'Sederhana bukan berarti ketinggalan zaman, tapi merupakan bentuk kedewasaan.',
    'Terima kasih atas semua yang datang, bahkan kesulitan dalam hidup.',
    'Cintailah dirimu sendiri sebelum mencintai orang lain.',
    'Percayalah, semua akan baik-baik saja pada waktunya.',
    'Jangan biarkan kata-kata orang lain menggagalkan impianmu.',
    'Kepercayaan diri adalah kunci kesuksesan.',
    'Dengarkan hati nuranimu dalam setiap keputusan.',
    'Jangan biarkan masa lalu menghambat langkah menuju masa depan.',
    'Kerja keras dan doa adalah kunci keberhasilan.',
    'Tersenyumlah, itu bisa menjadi obat bagi orang lain yang sedang dalam kesulitan.',
  ];

  late String _selectedQuote; // Variabel untuk menyimpan kutipan yang saat ini dipilih dan ditampilkan. Akan diinisialisasi di constructor.
  Timer? _quoteTimer; // Objek Timer yang akan digunakan untuk mengganti kutipan secara berkala. Nullable karena timer bisa dibatalkan.
  String _username = 'Teman'; // Variabel untuk menyimpan nama pengguna, defaultnya 'Teman'. Akan diperbarui setelah sesi dimuat.

  List<Map<String, dynamic>> _rightStories = []; // List untuk menyimpan cerita/stories yang akan ditampilkan di sisi kanan UI. Data akan diambil dari API.
  final Set<int> _likedStories = {}; // Set untuk menyimpan ID cerita yang telah disukai (di-"pray"). Menggunakan Set untuk efisiensi pengecekan dan mencegah duplikasi.

  // Constructor HomeController.
  // Dipanggil saat objek HomeController dibuat, menginisialisasi state awal dan memulai proses fetch data.
  HomeController() {
    _selectedQuote = _pickQuote(); // Menginisialisasi _selectedQuote dengan kutipan acak pertama kali.
    _fetchUsername(); // Memanggil fungsi untuk mengambil nama pengguna dari penyimpanan sesi.
    _startTimer(); // Memulai timer untuk mengganti kutipan secara berkala (setiap 5 detik).
    fetchLatestStories(); // Memanggil fungsi untuk mengambil cerita terbaru dari API saat controller dibuat.
  }

  // Getter untuk mengakses kutipan yang saat ini dipilih dari luar kelas.
  // Digunakan oleh UI untuk menampilkan kutipan yang aktif.
  String get selectedQuote => _selectedQuote;
  // Getter untuk mengakses nama pengguna dari luar kelas.
  // Digunakan oleh UI untuk menampilkan nama pengguna yang disapa.
  String get username => _username;
  // Getter untuk mengakses daftar cerita (rightStories) sebagai list yang tidak dapat dimodifikasi.
  // Digunakan oleh UI untuk menampilkan daftar cerita. Menggunakan List.unmodifiable untuk mencegah perubahan langsung dari UI.
  List<Map<String, dynamic>> get rightStories => List.unmodifiable(_rightStories);
  // Getter untuk mengakses ID cerita yang disukai (likedStories) sebagai set yang tidak dapat dimodifikasi.
  // Digunakan oleh UI untuk menandai cerita yang sudah disukai. Menggunakan Set.unmodifiable.
  Set<int> get likedStories => Set.unmodifiable(_likedStories);

  // Fungsi privat untuk memilih kutipan secara acak dari daftar _quotes.
  // Opsional 'except' parameter digunakan untuk memastikan kutipan yang dipilih berbeda dari kutipan sebelumnya.
  String _pickQuote([String? except]) {
    final random = Random(); // Membuat instance Random untuk menghasilkan angka acak.
    if (_quotes.length <= 1) return _quotes.first; // Jika hanya ada satu kutipan atau kurang, kembalikan yang pertama untuk menghindari error.
    var newQuote = _quotes[random.nextInt(_quotes.length)]; // Pilih kutipan acak berdasarkan panjang list.
    while (except != null && newQuote == except) {
      // Jika kutipan baru sama dengan kutipan sebelumnya (dan 'except' tidak null), pilih lagi.
      newQuote = _quotes[random.nextInt(_quotes.length)]; // Terus pilih sampai mendapatkan kutipan yang berbeda.
    }
    return newQuote; // Mengembalikan kutipan yang dipilih.
  }

  // Fungsi privat untuk memulai timer yang akan mengganti kutipan secara berkala.
  void _startTimer() {
    // Membuat Timer yang berulang setiap 5 detik. Parameter '_' menunjukkan bahwa argumen timer tidak digunakan.
    _quoteTimer = Timer.periodic(Duration(seconds: 5), (_) {
      _selectedQuote = _pickQuote(_selectedQuote); // Mengganti _selectedQuote dengan kutipan baru, memastikan tidak sama dengan yang sebelumnya.
      notifyListeners(); // Memberi tahu widget yang mendengarkan bahwa _selectedQuote telah berubah, memicu pembaruan UI.
    });
  }

  // Fungsi asinkron privat untuk mengambil nama pengguna dari AuthService.
  // Ini adalah operasi I/O, jadi menggunakan async/await.
  Future<void> _fetchUsername() async {
    final name = await AuthService.instance.getSessionUsername(); // Memanggil metode getSessionUsername dari instance AuthService untuk mendapatkan nama pengguna yang tersimpan.
    if (name != null) {
      // Jika nama pengguna ditemukan (tidak null).
      _username = name; // Memperbarui variabel _username dengan nama yang diperoleh.
      notifyListeners(); // Memberi tahu widget yang mendengarkan bahwa _username telah berubah, memicu pembaruan UI.
    }
  }

  // Fungsi asinkron untuk mengambil cerita terbaru dari API.
  // Melakukan permintaan HTTP dan memproses responsnya.
  Future<void> fetchLatestStories() async {
    try {
      // Melakukan panggilan GET ke endpoint '/stories' melalui ApiService.
      final response = await ApiService.instance.get('/stories');
      if (response.statusCode == 200) {
        // Jika respons HTTP sukses (kode status 200 OK).
        final data = jsonDecode(response.body); // Mendekode body respons yang berupa string JSON menjadi objek Dart.
        // Mengambil daftar cerita dari kunci 'data' dalam JSON dan mengonversinya ke List<Map<String, dynamic>>.
        final list = List<Map<String, dynamic>>.from(data['data']);
        // Mengambil maksimal 4 cerita terbaru dari daftar 'list' dan menyimpannya ke _rightStories.
        // Mengarah ke UI yang menampilkan 4 cerita ini.
        _rightStories = list.take(4).toList();
        
        _likedStories.clear(); // Mengosongkan set _likedStories sebelum mengisi ulang berdasarkan cerita yang baru diambil.
        for (var story in _rightStories) {
          // Melakukan iterasi pada setiap cerita di _rightStories.
          // Memeriksa apakah cerita tersebut sudah 'prayed' (disukai) oleh pengguna, berdasarkan nilai 'has_prayed'.
          if (story['has_prayed'] == 1 || story['has_prayed'] == true) {
            _likedStories.add(story['id']); // Jika sudah disukai, tambahkan ID cerita ke _likedStories.
          }
        }
        
        notifyListeners(); // Memberi tahu widget yang mendengarkan bahwa _rightStories dan _likedStories telah berubah, memicu pembaruan UI.
      }
    } catch (e) {
      // Menangkap dan mencetak error jika terjadi masalah saat mengambil cerita dari API.
      print('Fetch latest stories error: $e');
    }
  }
  
  // Fungsi asinkron untuk mengubah status 'suka' (pray) pada sebuah cerita.
  // Menerima indeks cerita yang akan diubah statusnya.
  Future<void> toggleRightStoryLike(int index) async {
    // Memastikan indeks yang diberikan valid agar tidak terjadi error out of bounds.
    if (index < 0 || index >= _rightStories.length) return; // Keluar dari fungsi jika indeks tidak valid.

    final storyId = _rightStories[index]['id']; // Mendapatkan ID cerita dari indeks yang diberikan.
    // Mendapatkan jumlah 'prayers' saat ini untuk cerita tersebut. Menggunakan operator ?? untuk memberikan nilai default 0 jika null.
    final currentCount = (_rightStories[index]['prayers_count'] as int?) ?? 0;
    if (_likedStories.contains(storyId)) {
      // Jika cerita sudah ada di dalam set _likedStories (artinya sudah disukai).
      _likedStories.remove(storyId); // Hapus ID cerita dari set _likedStories.
      // Kurangi jumlah 'prayers' jika lebih dari 0, jika tidak biarkan 0.
      _rightStories[index]['prayers_count'] = currentCount > 0 ? currentCount - 1 : 0;
    } else {
      // Jika cerita belum ada di dalam set _likedStories (artinya belum disukai).
      _likedStories.add(storyId); // Tambahkan ID cerita ke set _likedStories.
      _rightStories[index]['prayers_count'] = currentCount + 1; // Tambah jumlah 'prayers'.
    }
    notifyListeners(); // Memberi tahu widget yang mendengarkan untuk memperbarui UI dengan perubahan lokal (optimistic update).

    try {
      // Melakukan panggilan POST ke API untuk memperbarui status 'pray' di server.
      // Endpoint dibangun menggunakan storyId: '/stories/{storyId}/pray'. Payload kosong karena tidak ada data tambahan yang perlu dikirim.
      await ApiService.instance.post('/stories/$storyId/pray', {});
    } catch (e) {
      // Jika panggilan API gagal, kembalikan state di UI (revert optimistic update) untuk menjaga konsistensi.
      print('Failed to toggle like for story $storyId: $e');
      // Mengambil jumlah 'prayers' setelah optimistic update untuk proses revert.
      final currentCountRevert = (_rightStories[index]['prayers_count'] as int?) ?? 0;
      if (_likedStories.contains(storyId)) {
        // Jika saat ini cerita terdaftar sebagai disukai (berarti optimistic update menambahkan, tapi API gagal).
        _likedStories.remove(storyId); // Hapus dari daftar disukai.
        _rightStories[index]['prayers_count'] = currentCountRevert > 0 ? currentCountRevert - 1 : 0; // Kurangi jumlah 'prayers'.
      } else {
        // Jika saat ini cerita tidak terdaftar sebagai disukai (berarti optimistic update menghapus, tapi API gagal).
        _likedStories.add(storyId); // Tambahkan kembali ke daftar disukai.
        _rightStories[index]['prayers_count'] = currentCountRevert + 1; // Tambah kembali jumlah 'prayers'.
      }
      notifyListeners(); // Memberi tahu widget yang mendengarkan untuk memperbarui UI setelah perubahan dikembalikan ke state semula.
    }
  }

  // Metode dispose dipanggil ketika objek HomeController tidak lagi digunakan (misalnya, widget yang menggunakannya dihapus dari pohon widget).
  // Penting untuk membersihkan resource yang berjalan di latar belakang seperti Timer.
  @override
  void dispose() {
    _quoteTimer?.cancel(); // Memastikan timer dibatalkan untuk mencegah kebocoran memori atau pembaruan yang tidak perlu setelah widget dihapus.
    super.dispose(); // Memanggil metode dispose dari kelas induk (ChangeNotifier) untuk membersihkan resource lainnya.
  }
}