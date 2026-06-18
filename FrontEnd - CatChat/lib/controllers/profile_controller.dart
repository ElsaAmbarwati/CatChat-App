// Penjelasan file dan tujuannya:
// Nama file: profile_controller.dart
// Deskripsi: File ini adalah pengatur logika (otak) di balik layar UI.
// Mengarahkan ke/Keterkaitan:
// - Mengarah ke Backend/Service: Memanggil API melalui jaringan untuk mengambil/menyimpan data.
// - Berhubungan dengan Layar: Data dari sini akan ditampilkan ke layar UI (pages).

import 'package:flutter/material.dart'; // Mengimpor package dasar Flutter untuk UI, khususnya `ChangeNotifier` yang digunakan untuk manajemen state.
import 'package:shared_preferences/shared_preferences.dart'; // Mengimpor package untuk menyimpan data sederhana secara lokal (key-value pair), digunakan untuk menyimpan preferensi pengguna seperti avatar dan username.
import '../services/auth_service.dart'; // Mengimpor layanan autentikasi dari direktori parent, digunakan untuk operasi logout dan delete account.

class ProfileController extends ChangeNotifier {
  // Mendefinisikan kelas `ProfileController` yang bertanggung jawab untuk mengelola data profil pengguna.
  // `extends ChangeNotifier` memungkinkan kelas ini memberi tahu widget yang mendengarkannya ketika ada perubahan data, sehingga UI dapat diperbarui secara otomatis.
  int _selectedAvatarIndex = 0; // Variabel privat untuk menyimpan indeks avatar yang dipilih saat ini oleh pengguna. Nilai defaultnya adalah 0.
  String _username = 'Anonim'; // Variabel privat untuk menyimpan nama pengguna saat ini. Nilai defaultnya adalah 'Anonim'.

  static const List<String> avatarAssets = [
    // Variabel statis konstan yang berisi daftar path ke aset gambar avatar.
    // `static` berarti variabel ini milik kelas itu sendiri, bukan instance objek.
    // `const` berarti daftar ini dan isinya tidak dapat diubah setelah inisialisasi.
    'assets/images/pf1.png', // Path relatif ke gambar avatar pertama.
    'assets/images/pf2.png', // Path relatif ke gambar avatar kedua.
    'assets/images/pf3.png', // Path relatif ke gambar avatar ketiga.
    'assets/images/pf4.png', // Path relatif ke gambar avatar keempat.
    'assets/images/pf5.png', // Path relatif ke gambar avatar kelima.
    'assets/images/pf6.png', // Path relatif ke gambar avatar keenam.
    'assets/images/pf7.png', // Path relatif ke gambar avatar ketujuh.
  ];

  ProfileController() {
    // Constructor (konstruktor) untuk kelas `ProfileController`.
    // Dipanggil saat sebuah instance dari `ProfileController` dibuat.
    _loadUser(); // Memanggil metode privat `_loadUser` segera setelah `ProfileController` diinisialisasi untuk memuat data pengguna yang tersimpan.
  }

  int get selectedAvatarIndex => _selectedAvatarIndex; // Getter publik untuk mengakses nilai `_selectedAvatarIndex` dari luar kelas. Mengizinkan akses baca ke indeks avatar yang dipilih.
  String get username => _username; // Getter publik untuk mengakses nilai `_username` dari luar kelas. Mengizinkan akses baca ke nama pengguna.

  void selectAvatar(int index) async {
    // Metode untuk memilih avatar baru berdasarkan indeks yang diberikan.
    // `async` menunjukkan bahwa metode ini akan melakukan operasi asinkron (misalnya, menyimpan ke `SharedPreferences`).
    _selectedAvatarIndex = index; // Memperbarui nilai `_selectedAvatarIndex` dengan indeks avatar yang baru dipilih.
    notifyListeners(); // Memberi tahu semua widget yang mendengarkan `ProfileController` bahwa data telah berubah. Ini akan memicu pembangunan ulang (rebuild) bagian UI yang relevan untuk menampilkan avatar baru.
    final prefs = await SharedPreferences.getInstance(); // Menginisialisasi instance `SharedPreferences` secara asinkron. Digunakan untuk menyimpan data preferensi pengguna.
    await prefs.setInt('selected_avatar_index', index); // Menyimpan indeks avatar yang dipilih ke `SharedPreferences` dengan kunci 'selected_avatar_index' agar tetap persisten di antara sesi aplikasi.
  }

  Future<void> _loadUser() async {
    // Metode privat asinkron untuk memuat data profil pengguna (username dan indeks avatar) dari `SharedPreferences`.
    final prefs = await SharedPreferences.getInstance(); // Mendapatkan instance `SharedPreferences`.
    _username = prefs.getString('current_username') ?? 'Anonim'; // Memuat nama pengguna dari `SharedPreferences` menggunakan kunci 'current_username'. Jika tidak ada nilai yang ditemukan, `_username` akan diatur ke 'Anonim' (operator `??` adalah null-aware operator).
    _selectedAvatarIndex = prefs.getInt('selected_avatar_index') ?? 0; // Memuat indeks avatar yang dipilih dari `SharedPreferences` menggunakan kunci 'selected_avatar_index'. Jika tidak ada nilai yang ditemukan, `_selectedAvatarIndex` akan diatur ke 0.
    notifyListeners(); // Memberi tahu listener bahwa data profil (username dan avatar) telah dimuat dan mungkin telah berubah, memicu pembaruan UI.
  }

  Future<void> logout() async {
    // Metode asinkron untuk melakukan logout pengguna.
    await AuthService.instance.logout(); // Memanggil metode `logout` dari `AuthService` untuk menangani proses logout (misalnya, menghapus token autentikasi). Mengarah ke fungsi logout di layanan autentikasi.
  }

  Future<void> deleteAccount() async {
    // Metode asinkron untuk menghapus akun pengguna.
    await AuthService.instance.deleteAccount(); // Memanggil metode `deleteAccount` dari `AuthService` untuk menangani proses penghapusan akun. Mengarah ke fungsi deleteAccount di layanan autentikasi.
  }
}