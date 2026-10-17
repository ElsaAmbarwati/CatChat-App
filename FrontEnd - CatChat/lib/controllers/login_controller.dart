// Penjelasan file dan tujuannya:
// Nama file: login_controller.dart
// Deskripsi: File ini adalah pengatur logika (otak) di balik layar UI.
// Mengarahkan ke/Keterkaitan:
// - Mengarah ke Backend/Service: Memanggil API melalui jaringan untuk mengambil/menyimpan data.
// - Berhubungan dengan Layar: Data dari sini akan ditampilkan ke layar UI (pages).

// @file login_controller.dart
// @description Controller untuk menangani logika antarmuka proses login.
// Menghimpun data input pengguna dan mengirim HTTP POST request ke backend.
// @connections
// - Backend: Berkomunikasi dengan endpoint /auth/login di auth.controller.js.
// - Storage: Menyimpan token JWT ke SharedPreferences jika autentikasi berhasil.
import 'package:flutter/material.dart'; // Mengimpor paket dasar Flutter untuk membangun UI, termasuk widget dan material design.

import '../services/auth_service.dart'; // Mengimpor AuthService yang berisi logika untuk komunikasi dengan API autentikasi, mengarah ke layanan autentikasi.
import '../pages/app_lock_page.dart'; // Mengimpor halaman AppLockPage, yang digunakan setelah login berhasil untuk memverifikasi PIN.
import '../pages/create_pin_page.dart'; // Mengimpor halaman CreatePinPage, yang digunakan setelah login berhasil jika pengguna belum memiliki PIN.

class LoginController extends ChangeNotifier {
  // Mendefinisikan kelas LoginController yang extends ChangeNotifier,
  // memungkinkan kelas ini untuk memberi tahu widget yang mendengarkannya tentang perubahan state.
  final TextEditingController emailCtrl = TextEditingController(); // Mendeklarasikan controller untuk input field email. Digunakan untuk mendapatkan atau mengatur teks di field email.
  final TextEditingController passwordCtrl = TextEditingController(); // Mendeklarasikan controller untuk input field password. Digunakan untuk mendapatkan atau mengatur teks di field password.

  bool _obscure = true; // Variabel boolean private untuk mengontrol visibilitas teks password (true = tersembunyi, false = terlihat).
  bool get obscure => _obscure; // Getter publik untuk mengakses nilai _obscure.

  bool _loading = false; // Variabel boolean private untuk menunjukkan status loading (true = sedang memuat/proses, false = tidak).
  bool get loading => _loading; // Getter publik untuk mengakses nilai _loading.

  String? _error; // Variabel String private untuk menyimpan pesan error, dapat bernilai null jika tidak ada error.
  String? get error => _error; // Getter publik untuk mengakses nilai _error.

  void toggleObscure() {
    // Metode untuk mengubah status visibilitas password.
    _obscure = !_obscure; // Mengubah nilai _obscure menjadi kebalikannya.
    notifyListeners(); // Memberi tahu semua widget yang mendengarkan bahwa state telah berubah, memicu rebuild UI yang relevan.
  }

  Future<void> submit(BuildContext context) async {
    // Metode asinkron untuk menangani proses submit form login. Membutuhkan BuildContext untuk navigasi.
    _error = null; // Mengatur ulang pesan error menjadi null di awal setiap submit.
    _loading = true; // Mengatur status loading menjadi true, menunjukkan proses sedang berjalan.
    notifyListeners(); // Memberi tahu listener untuk memperbarui UI (misalnya, menampilkan indikator loading).

    final email = emailCtrl.text.trim(); // Mengambil teks dari controller email, menghapus spasi di awal/akhir.
    final password = passwordCtrl.text; // Mengambil teks dari controller password.

    if (email.isEmpty || password.isEmpty) {
      // Memeriksa apakah field email atau password kosong.
      _error = 'Email dan password harus diisi.'; // Mengatur pesan error jika ada field yang kosong.
      _loading = false; // Mengatur status loading menjadi false karena validasi gagal di sisi klien.
      notifyListeners(); // Memberi tahu listener untuk memperbarui UI (misalnya, menampilkan pesan error).
      return; // Menghentikan eksekusi metode karena input tidak valid.
    }

    final result = await AuthService.instance.login(email, password); // Memanggil metode login dari AuthService, mengirimkan email dan password. Ini adalah komunikasi dengan backend.
    if (!context.mounted) return; // Memeriksa apakah widget masih terpasang pada tree widget. Penting untuk menghindari error setelah async gap jika widget sudah tidak ada.

    if (result != null) {
      // Jika hasil dari login tidak null, berarti ada error dari backend atau AuthService.
      _error = result; // Mengatur pesan error dengan hasil yang diterima dari AuthService.
      _loading = false; // Mengatur status loading menjadi false.
      notifyListeners(); // Memberi tahu listener untuk memperbarui UI (menampilkan pesan error).
      return; // Menghentikan eksekusi metode karena login gagal.
    }

    // Login success
    final hasPin = await AuthService.instance.hasPIN();
    final wantsToResetPin = await AuthService.instance.getWantsToResetPin();
    
    if (!context.mounted) return;

    if (hasPin && !wantsToResetPin) {
      // Jika user sudah punya PIN dan tidak meminta reset, minta mereka masukkan PIN lamanya.
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AppLockPage()),
        (_) => false,
      );
    } else {
      // Jika user belum punya PIN, ATAU jika mereka baru saja menekan tombol Lupa PIN,
      // arahkan mereka untuk membuat PIN baru.
      if (wantsToResetPin) {
        await AuthService.instance.setWantsToResetPin(false); // Bersihkan status reset
      }
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const CreatePinPage()),
        (_) => false,
      );
    }
  }

  @override
  void dispose() {
    // Metode ini dipanggil ketika LoginController tidak lagi digunakan dan harus dibersihkan.
    emailCtrl.dispose(); // Melepaskan sumber daya yang digunakan oleh TextEditingController email.
    passwordCtrl.dispose(); // Melepaskan sumber daya yang digunakan oleh TextEditingController password.
    super.dispose(); // Memanggil metode dispose dari kelas induk (ChangeNotifier) untuk memastikan pembersihan yang tepat.
  }
}