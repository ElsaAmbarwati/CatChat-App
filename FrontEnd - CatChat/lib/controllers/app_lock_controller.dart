// Penjelasan file dan tujuannya:
// Nama file: app_lock_controller.dart
// Deskripsi: File ini adalah pengatur logika (otak) di balik layar UI.
// Mengarahkan ke/Keterkaitan:
// - Mengarah ke Backend/Service: Memanggil API melalui jaringan untuk mengambil/menyimpan data.
// - Berhubungan dengan Layar: Data dari sini akan ditampilkan ke layar UI (pages).

import 'package:flutter/material.dart'; // Mengimpor pustaka Flutter Material Design untuk membangun antarmuka pengguna (UI) yang mengikuti panduan desain Material.
import 'package:flutter/services.dart'; // Mengimpor pustaka Flutter Services yang menyediakan akses ke fungsionalitas sistem tingkat rendah, seperti umpan balik haptic.

import '../services/auth_service.dart'; // Mengimpor modul AuthService dari direktori '../services' yang berisi logika terkait otentikasi pengguna, seperti memverifikasi PIN dan melakukan logout.
import '../pages/home_pages.dart'; // Mengimpor modul HomePages dari direktori '../pages' yang merupakan halaman utama aplikasi yang akan ditampilkan setelah pengguna berhasil melakukan otentikasi.
import '../pages/landing_page.dart'; // Mengimpor modul LandingPage dari direktori '../pages' yang merupakan halaman awal atau sambutan aplikasi, yang biasanya ditampilkan sebelum pengguna login atau setelah logout.

// Mendefinisikan sebuah kelas bernama AppLockController yang mewarisi dari ChangeNotifier.
// Kelas ini berfungsi sebagai controller untuk mengelola logika terkait penguncian aplikasi dan otentikasi PIN.
// ChangeNotifier memungkinkan widget di Flutter untuk mendengarkan perubahan pada instance kelas ini dan memperbarui UI mereka secara otomatis.
class AppLockController extends ChangeNotifier {
  // Mendefinisikan konstanta statis untuk menentukan panjang PIN yang valid.
  // 'pinLength' akan bernilai 6, yang berarti PIN harus terdiri dari 6 digit.
  static const int pinLength = 6;

  // Variabel private untuk menyimpan PIN yang sedang dimasukkan oleh pengguna.
  // Nilai awal adalah string kosong.
  String _enteredPin = '';
  // Getter publik untuk mengakses nilai dari _enteredPin.
  // Ini memungkinkan widget lain untuk membaca PIN yang sedang dimasukkan tanpa dapat mengubahnya secara langsung.
  String get enteredPin => _enteredPin;

  // Variabel private yang akan menyimpan pesan error jika terjadi kesalahan saat verifikasi PIN.
  // Tipe data nullable String ('String?') berarti bisa bernilai string atau null (tidak ada error).
  String? _error;
  // Getter publik untuk mengakses nilai dari _error.
  // Memungkinkan widget untuk menampilkan pesan error kepada pengguna.
  String? get error => _error;

  // Variabel private yang menandakan apakah proses verifikasi PIN telah berhasil.
  // Bernilai boolean (true jika berhasil, false jika belum atau gagal).
  bool _success = false;
  // Getter publik untuk mengakses status keberhasilan verifikasi.
  // Digunakan untuk mengontrol tampilan UI berdasarkan status otentikasi.
  bool get success => _success;

  // Variabel private untuk menghitung jumlah percobaan yang gagal dalam memasukkan PIN.
  // Diinisialisasi dengan nilai 0.
  int _attempts = 0;

  // Metode publik yang dipanggil ketika pengguna menekan sebuah digit pada keypad.
  // 'digit' adalah angka yang ditekan (0-9).
  // 'onComplete' adalah sebuah callback (fungsi) yang akan dijalankan jika PIN sudah lengkap.
  void onDigit(int digit, VoidCallback onComplete) {
    // Memeriksa apakah panjang PIN yang dimasukkan sudah mencapai batas maksimum (pinLength)
    // atau jika proses verifikasi sudah berhasil (_success bernilai true).
    // Jika salah satu kondisi terpenuhi, fungsi akan berhenti dan tidak melakukan apa-apa.
    if (_enteredPin.length >= pinLength || _success) return;
    // Memberikan umpan balik haptic ringan (getaran) untuk memberikan sensasi sentuhan saat digit ditekan.
    HapticFeedback.lightImpact();
    // Menambahkan digit yang dimasukkan (setelah dikonversi menjadi string) ke akhir string _enteredPin.
    _enteredPin += digit.toString();
    // Menghapus pesan error yang mungkin ada sebelumnya, karena pengguna sedang mencoba lagi.
    _error = null;
    // Memanggil notifyListeners() untuk memberi tahu semua widget yang mendengarkan controller ini bahwa terjadi perubahan.
    // Ini akan memicu pembaruan UI di widget yang bergantung pada _enteredPin atau _error.
    notifyListeners();

    // Memeriksa apakah panjang PIN yang dimasukkan sekarang sama dengan panjang PIN yang dibutuhkan (pinLength).
    if (_enteredPin.length == pinLength) {
      // Jika PIN sudah lengkap, panggil fungsi callback onComplete yang telah diberikan.
      // Biasanya, ini akan memicu proses verifikasi PIN.
      onComplete();
    }
  }

  // Metode publik yang dipanggil ketika pengguna menekan tombol hapus (backspace) pada keypad.
  void onDelete() {
    // Memeriksa apakah string _enteredPin kosong atau jika proses verifikasi sudah berhasil.
    // Jika salah satu kondisi terpenuhi, fungsi akan berhenti.
    if (_enteredPin.isEmpty || _success) return;
    // Memberikan umpan balik haptic ringan (getaran) saat tombol hapus ditekan.
    HapticFeedback.lightImpact();
    // Menghapus karakter terakhir dari string _enteredPin menggunakan substring.
    // Ini secara efektif menghapus digit terakhir yang dimasukkan.
    _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
    // Menghapus pesan error yang mungkin ada sebelumnya.
    _error = null;
    // Memberi tahu listener bahwa terjadi perubahan, memicu pembaruan UI.
    notifyListeners();
  }

  // Metode asynchronous untuk melakukan verifikasi PIN yang telah dimasukkan pengguna.
  // 'context' adalah BuildContext yang diperlukan untuk navigasi antar halaman.
  // 'isFromBackground' adalah boolean yang menandakan apakah panggilan ini terjadi saat aplikasi kembali dari background.
  // 'onShake' adalah callback yang akan dipanggil jika verifikasi PIN gagal, biasanya untuk memicu animasi shake pada UI.
  Future<void> verifyPin({
    required BuildContext context,
    required bool isFromBackground,
    required VoidCallback onShake,
  }) async {
    // Memanggil metode verifyPIN dari instance AuthService untuk memeriksa apakah _enteredPin valid.
    // Hasilnya (boolean true/false) disimpan dalam variabel 'ok'.
    final ok = await AuthService.instance.verifyPIN(_enteredPin);
    // Memeriksa apakah widget yang terkait dengan 'context' masih terpasang (mounted) di pohon widget.
    // Jika tidak, berarti halaman ini sudah ditutup, jadi hentikan eksekusi lebih lanjut untuk mencegah error.
    if (!context.mounted) return;

    // Memeriksa apakah verifikasi PIN berhasil ('ok' bernilai true).
    if (ok) {
      // Mengatur status keberhasilan menjadi true.
      _success = true;
      // Memberi tahu listener bahwa terjadi perubahan, sehingga UI dapat diperbarui (misalnya, untuk menampilkan indikator sukses).
      notifyListeners();
      // Memberikan umpan balik haptic sedang.
      HapticFeedback.mediumImpact();
      // Menunda eksekusi selama 500 milidetik (0.5 detik) untuk memberikan efek visual sebelum navigasi.
      await Future.delayed(Duration(milliseconds: 500));
      // Memeriksa kembali apakah context masih terpasang setelah penundaan.
      if (!context.mounted) return;

      // Memeriksa apakah verifikasi PIN dipicu saat aplikasi kembali dari background.
      if (isFromBackground) {
        // Jika ya, tutup dialog atau layar pengunci saat ini (pop dari navigator).
        Navigator.of(context).pop();
      } else {
        // Jika tidak (verifikasi dilakukan dalam alur normal), navigasi ke HomePages.
        // pushAndRemoveUntil digunakan untuk mengganti semua halaman sebelumnya dengan HomePages,
        // sehingga pengguna tidak bisa kembali ke layar penguncian PIN setelah masuk ke HomePages.
        Navigator.of(context).pushAndRemoveUntil(
          // Membuat rute baru menuju HomePages.
          MaterialPageRoute(builder: (_) => const HomePages()),
          // Predikat ini selalu mengembalikan false, yang berarti semua rute di bawah rute baru (HomePages) akan dihapus.
          (_) => false,
        );
      }
    } else { // Jika verifikasi PIN gagal ('ok' bernilai false).
      // Menambah jumlah percobaan yang gagal.
      _attempts++;
      // Menetapkan pesan error. Pesan akan menampilkan jumlah percobaan jika sudah mencapai 3 kali atau lebih.
      _error = 'PIN salah. Coba lagi.${_attempts >= 3 ? '\n($_attempts kali percobaan)' : ''}';
      // Mengosongkan kembali _enteredPin agar pengguna bisa memasukkan PIN baru dari awal.
      _enteredPin = '';
      // Memberi tahu listener bahwa terjadi perubahan (error baru, PIN kosong), memicu pembaruan UI.
      notifyListeners();
      // Memanggil callback onShake untuk memberikan umpan balik visual pada UI (misalnya, animasi goyang).
      onShake();
      // Memberikan umpan balik haptic berat untuk menunjukkan kegagalan.
      HapticFeedback.heavyImpact();
    }
  }

  // Metode asynchronous untuk melakukan proses logout pengguna.
  // Menerima BuildContext untuk keperluan navigasi.
  Future<void> performLogout(BuildContext context) async {
    // Memanggil metode logout dari instance AuthService untuk melakukan proses logout di sisi backend atau penyimpanan lokal.
    await AuthService.instance.logout();
    // Memeriksa apakah context masih terpasang setelah proses logout selesai.
    if (!context.mounted) return;
    // Melakukan navigasi ke LandingPage dan menghapus semua rute sebelumnya dari stack.
    // Ini memastikan bahwa setelah logout, pengguna tidak dapat kembali ke halaman sebelumnya menggunakan tombol kembali.
    Navigator.of(context).pushAndRemoveUntil(
      // Membuat rute baru menuju LandingPage.
      MaterialPageRoute(builder: (_) => const LandingPage()),
      // Predikat ini selalu mengembalikan false, menghapus semua rute di bawah LandingPage.
      (_) => false,
    );
  }
}