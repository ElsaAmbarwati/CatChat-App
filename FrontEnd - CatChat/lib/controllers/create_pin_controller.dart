// Penjelasan file dan tujuannya:
// Nama file: create_pin_controller.dart
// Deskripsi: File ini adalah pengatur logika (otak) di balik layar UI.
// Mengarahkan ke/Keterkaitan:
// - Mengarah ke Backend/Service: Memanggil API melalui jaringan untuk mengambil/menyimpan data.
// - Berhubungan dengan Layar: Data dari sini akan ditampilkan ke layar UI (pages).

import 'package:flutter/material.dart'; // Mengimpor package material dari Flutter, yang menyediakan widget dan alat UI dasar.
import '../services/auth_service.dart'; // Mengimpor AuthService dari direktori services, kemungkinan untuk operasi otentikasi seperti verifikasi atau penyimpanan PIN.

enum CreatePinStatus { initial, error, success } // Mendefinisikan sebuah enum untuk merepresentasikan status UI pada proses pembuatan PIN: awal, terjadi error, atau sukses.

class CreatePinController extends ChangeNotifier { // Mendefinisikan kelas CreatePinController yang meng-extend ChangeNotifier, memungkinkan notifikasi perubahan state ke widget yang mendengarkan.
  static const int pinLength = 6; // Konstanta yang menentukan panjang PIN yang diharapkan, yaitu 6 digit.

  int _phase; // Variabel private untuk melacak fase proses pembuatan PIN: -1 (verifikasi PIN lama), 0 (masukkan PIN baru), 1 (konfirmasi PIN baru).
  String _enteredPin = ''; // Variabel private untuk menyimpan PIN yang sedang dimasukkan oleh pengguna.
  String _firstPin = ''; // Variabel private untuk menyimpan PIN pertama yang dimasukkan, digunakan untuk konfirmasi.
  String? _error; // Variabel private untuk menyimpan pesan error jika ada, bisa null jika tidak ada error.
  CreatePinStatus _status = CreatePinStatus.initial; // Variabel private untuk melacak status UI saat ini, dimulai dengan status initial.

  CreatePinController({bool isChanging = false}) : _phase = isChanging ? -1 : 0; // Konstruktor untuk CreatePinController. Jika `isChanging` true (mengganti PIN), fase dimulai dari -1 (verifikasi PIN lama); jika tidak, fase dimulai dari 0 (buat PIN baru).

  int get phase => _phase; // Getter untuk mengakses nilai fase saat ini dari luar kelas, berguna untuk UI yang adaptif.
  String get enteredPin => _enteredPin; // Getter untuk mengakses PIN yang sedang dimasukkan dari luar kelas.
  String? get error => _error; // Getter untuk mengakses pesan error dari luar kelas.
  CreatePinStatus get status => _status; // Getter untuk mengakses status UI saat ini dari luar kelas.
  bool get success => _status == CreatePinStatus.success; // Getter untuk memeriksa apakah status saat ini adalah success, berguna untuk navigasi atau menampilkan pesan sukses.

  String get title { // Getter untuk mendapatkan teks judul yang akan ditampilkan di UI berdasarkan fase saat ini.
    if (_phase == -1) return 'Masukkan PIN Lama'; // Jika fase adalah -1, judulnya adalah 'Masukkan PIN Lama', mengarah ke verifikasi PIN yang sedang aktif.
    if (_phase == 0) return 'Buat PIN Baru'; // Jika fase adalah 0, judulnya adalah 'Buat PIN Baru', mengarah ke input PIN baru.
    return 'Konfirmasi PIN'; // Jika fase bukan -1 atau 0 (berarti 1), judulnya adalah 'Konfirmasi PIN', mengarah ke input ulang PIN untuk konfirmasi.
  }

  String get subtitle { // Getter untuk mendapatkan teks subtitle yang akan ditampilkan di UI berdasarkan fase saat ini.
    if (_phase == -1) return 'Verifikasi PIN yang sedang aktif.'; // Jika fase adalah -1, subtitle menjelaskan tujuan verifikasi PIN lama.
    if (_phase == 0) return 'Masukkan 6 digit angka untuk mengunci aplikasi.'; // Jika fase adalah 0, subtitle menginstruksikan pengguna untuk membuat PIN baru.
    return 'Masukkan ulang PIN yang sama untuk konfirmasi.'; // Jika fase bukan -1 atau 0 (berarti 1), subtitle menginstruksikan pengguna untuk konfirmasi PIN.
  }

  void onDigit(int digit) { // Fungsi yang dipanggil ketika pengguna memasukkan sebuah digit.
    if (_enteredPin.length >= pinLength || _status == CreatePinStatus.success) return; // Menghentikan fungsi jika PIN sudah mencapai panjang maksimum atau jika status sudah sukses, mencegah input lebih lanjut.
    _enteredPin += digit.toString(); // Menambahkan digit yang dimasukkan ke string _enteredPin.
    _error = null; // Menghapus pesan error sebelumnya (jika ada).
    _status = CreatePinStatus.initial; // Mengatur ulang status menjadi initial.
    notifyListeners(); // Memberi tahu widget yang mendengarkan bahwa state telah berubah, memicu rebuild UI.

    if (_enteredPin.length == pinLength) { // Memeriksa apakah PIN yang dimasukkan sudah mencapai panjang yang ditentukan (6 digit).
      _onPinComplete(); // Jika PIN sudah lengkap, memanggil fungsi _onPinComplete untuk memproses PIN sesuai fase.
    }
  }

  void onDelete() { // Fungsi yang dipanggil ketika pengguna menekan tombol hapus (backspace).
    if (_enteredPin.isEmpty || _status == CreatePinStatus.success) return; // Menghentikan fungsi jika _enteredPin kosong atau status sudah sukses, tidak ada yang bisa dihapus.
    _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1); // Menghapus digit terakhir dari _enteredPin.
    _error = null; // Menghapus pesan error sebelumnya (jika ada).
    _status = CreatePinStatus.initial; // Mengatur ulang status menjadi initial.
    notifyListeners(); // Memberi tahu widget yang mendengarkan bahwa state telah berubah, memicu rebuild UI.
  }

  Future<void> _onPinComplete() async { // Fungsi private asinkron yang dipanggil ketika PIN lengkap dimasukkan, untuk memproses logika sesuai fase.
    if (_phase == -1) { // Memeriksa jika fase saat ini adalah -1 (verifikasi PIN lama).
      final ok = await AuthService.instance.verifyPIN(_enteredPin); // Memanggil AuthService untuk memverifikasi PIN yang dimasukkan dengan PIN lama. Ini adalah operasi asinkron.
      if (!ok) { // Jika verifikasi PIN lama gagal (PIN salah).
        _showError('PIN lama salah.'); // Menampilkan pesan error yang relevan.
        return; // Menghentikan eksekusi fungsi karena verifikasi gagal.
      }
      _phase = 0; // Jika PIN lama benar, mengubah fase menjadi 0 (buat PIN baru), mengarah ke input PIN baru.
      _enteredPin = ''; // Mengosongkan _enteredPin untuk input PIN baru.
      notifyListeners(); // Memberi tahu pendengar bahwa state telah berubah, memicu update UI.
      return; // Menghentikan eksekusi fungsi.
    }

    if (_phase == 0) { // Memeriksa jika fase saat ini adalah 0 (memasukkan PIN baru pertama kali).
      _firstPin = _enteredPin; // Menyimpan PIN yang dimasukkan sebagai _firstPin untuk konfirmasi.
      _phase = 1; // Mengubah fase menjadi 1 (konfirmasi PIN), mengarah ke input PIN ulang.
      _enteredPin = ''; // Mengosongkan _enteredPin untuk input PIN konfirmasi.
      notifyListeners(); // Memberi tahu pendengar bahwa state telah berubah, memicu update UI.
      return; // Menghentikan eksekusi fungsi.
    }

    if (_enteredPin != _firstPin) { // Memeriksa jika fase saat ini adalah 1 (konfirmasi PIN) dan PIN yang dimasukkan tidak cocok dengan _firstPin.
      _showError('PIN tidak cocok. Coba lagi.'); // Menampilkan pesan error karena PIN tidak cocok.
      _phase = 0; // Mengubah fase kembali ke 0 (buat PIN baru) agar pengguna bisa mengulang dari awal.
      _firstPin = ''; // Mengosongkan _firstPin.
      return; // Menghentikan eksekusi fungsi.
    }

    await AuthService.instance.savePIN(_enteredPin); // Jika PIN cocok, memanggil AuthService untuk menyimpan PIN baru secara asinkron. Ini adalah langkah terakhir dalam pembuatan/penggantian PIN.
    _status = CreatePinStatus.success; // Mengatur status menjadi sukses setelah PIN berhasil disimpan.
    notifyListeners(); // Memberi tahu pendengar bahwa state telah berubah, memicu UI (misalnya, navigasi kembali atau menampilkan pesan sukses).
  }

  void _showError(String msg) { // Fungsi private untuk menampilkan pesan error.
    _error = msg; // Mengatur pesan error yang akan ditampilkan.
    _enteredPin = ''; // Mengosongkan _enteredPin agar pengguna bisa mencoba lagi.
    _status = CreatePinStatus.error; // Mengatur status UI menjadi error.
    notifyListeners(); // Memberi tahu pendengar bahwa state telah berubah, memicu UI untuk menampilkan error.
  }

  void resetStatus() { // Fungsi untuk mengatur ulang status UI menjadi initial.
    _status = CreatePinStatus.initial; // Mengatur status menjadi initial, berguna jika ingin mengulang proses atau membersihkan tampilan error.
  }
}