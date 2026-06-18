// Penjelasan file dan tujuannya:
// Nama file: register_controller.dart
// Deskripsi: File ini adalah pengatur logika (otak) di balik layar UI.
// Mengarahkan ke/Keterkaitan:
// - Mengarah ke Backend/Service: Memanggil API melalui jaringan untuk mengambil/menyimpan data.
// - Berhubungan dengan Layar: Data dari sini akan ditampilkan ke layar UI (pages).

import 'package:flutter/material.dart'; // Mengimpor package material dari Flutter untuk membangun UI.

import '../services/auth_service.dart'; // Mengimpor AuthService untuk otentikasi pengguna, menuju ke file auth_service.dart di folder services.
import '../pages/create_pin_page.dart'; // Mengimpor CreatePinPage, halaman untuk membuat PIN, menuju ke file create_pin_page.dart di folder pages.

// Mendefinisikan kelas RegisterController yang merupakan sebuah ChangeNotifier.
// ChangeNotifier digunakan untuk memberi tahu widget yang mendengarkan jika ada perubahan data, sehingga UI bisa di-update.
class RegisterController extends ChangeNotifier {
  // Mendefinisikan TextEditingController untuk mengelola input teks email.
  final TextEditingController emailCtrl = TextEditingController();
  // Mendefinisikan TextEditingController untuk mengelola input teks username.
  final TextEditingController usernameCtrl = TextEditingController();
  // Mendefinisikan TextEditingController untuk mengelola input teks password.
  final TextEditingController passwordCtrl = TextEditingController();
  // Mendefinisikan TextEditingController untuk mengelola input teks konfirmasi password.
  final TextEditingController confirmCtrl = TextEditingController();

  // Variabel privat untuk mengontrol visibilitas password (true = sembunyikan, false = tampilkan).
  bool _obscure = true;
  // Getter publik untuk mengakses nilai _obscure.
  bool get obscure => _obscure;

  // Variabel privat untuk mengontrol visibilitas konfirmasi password.
  bool _obscureConfirm = true;
  // Getter publik untuk mengakses nilai _obscureConfirm.
  bool get obscureConfirm => _obscureConfirm;

  // Variabel privat untuk menunjukkan status loading (true = sedang loading, false = tidak loading).
  bool _loading = false;
  // Getter publik untuk mengakses nilai _loading.
  bool get loading => _loading;

  // Variabel privat untuk menyimpan pesan error jika terjadi.
  String? _error;
  // Getter publik untuk mengakses pesan error.
  String? get error => _error;

  // Fungsi untuk mengubah status visibilitas password.
  void toggleObscure() {
    _obscure = !_obscure; // Mengubah nilai _obscure menjadi kebalikannya.
    notifyListeners(); // Memberi tahu semua listener bahwa ada perubahan, yang akan memicu rebuild UI.
  }

  // Fungsi untuk mengubah status visibilitas konfirmasi password.
  void toggleObscureConfirm() {
    _obscureConfirm = !_obscureConfirm; // Mengubah nilai _obscureConfirm menjadi kebalikannya.
    notifyListeners(); // Memberi tahu semua listener bahwa ada perubahan, yang akan memicu rebuild UI.
  }

  // Fungsi asinkron untuk menghasilkan nama pengguna anonim.
  Future<void> generateAnonName() async {
    // Memanggil metode generateAnonUsername dari AuthService untuk mendapatkan nama anonim.
    final anonName = await AuthService.instance.generateAnonUsername();
    // Mengatur teks pada usernameCtrl dengan nama anonim yang dihasilkan.
    usernameCtrl.text = anonName;
    notifyListeners(); // Memberi tahu semua listener bahwa ada perubahan, yang akan memicu rebuild UI.
  }

  // Fungsi asinkron untuk submit proses pendaftaran.
  // Menerima BuildContext untuk navigasi.
  Future<void> submit(BuildContext context) async {
    _error = null; // Menghapus pesan error sebelumnya.
    _loading = true; // Mengatur status loading menjadi true.
    notifyListeners(); // Memberi tahu listener untuk memperbarui UI (menampilkan indikator loading).

    // Mengambil nilai teks dari controller dan membersihkan spasi di awal/akhir untuk email dan username.
    final email = emailCtrl.text.trim();
    final username = usernameCtrl.text.trim();
    final password = passwordCtrl.text; // Password tidak di-trim karena spasi bisa menjadi bagian dari password.
    final confirm = confirmCtrl.text; // Konfirmasi password tidak di-trim.

    // Kondisi untuk memeriksa apakah ada field yang kosong.
    if (email.isEmpty || username.isEmpty || password.isEmpty || confirm.isEmpty) {
      _error = 'Semua field harus diisi.'; // Mengatur pesan error.
      _loading = false; // Mengatur status loading menjadi false.
      notifyListeners(); // Memberi tahu listener untuk memperbarui UI (menampilkan error dan menyembunyikan loading).
      return; // Menghentikan eksekusi fungsi.
    }
    // Kondisi untuk memeriksa apakah password dan konfirmasi password cocok.
    if (password != confirm) {
      _error = 'Konfirmasi password tidak cocok.'; // Mengatur pesan error.
      _loading = false; // Mengatur status loading menjadi false.
      notifyListeners(); // Memberi tahu listener untuk memperbarui UI (menampilkan error dan menyembunyikan loading).
      return; // Menghentikan eksekusi fungsi.
    }

    // Memanggil metode register dari AuthService untuk mendaftarkan pengguna.
    final result = await AuthService.instance.register(email, username, password);
    // Memeriksa apakah widget masih terpasang (mounted) di pohon widget. Penting untuk menghindari error setelah dispose.
    if (!context.mounted) return; // Jika tidak mounted, hentikan eksekusi.

    // Kondisi jika hasil pendaftaran tidak null, berarti ada error.
    if (result != null) {
      _error = result; // Mengatur pesan error dengan hasil dari AuthService.
      _loading = false; // Mengatur status loading menjadi false.
      notifyListeners(); // Memberi tahu listener untuk memperbarui UI (menampilkan error dan menyembunyikan loading).
      return; // Menghentikan eksekusi fungsi.
    }

    // Jika pendaftaran berhasil (result adalah null) → Lanjutkan ke halaman pembuatan PIN.
    Navigator.of(context).pushAndRemoveUntil(
      // Mendorong rute baru (MaterialPageRoute) ke CreatePinPage.
      MaterialPageRoute(builder: (_) => const CreatePinPage()),
      // Menghapus semua rute sebelumnya dari stack, sehingga pengguna tidak bisa kembali ke halaman register.
      (_) => false,
    );
  }

  // Metode dispose dipanggil saat objek RegisterController tidak lagi digunakan.
  // Penting untuk membuang resource yang tidak terpakai, seperti TextEditingController.
  @override
  void dispose() {
    emailCtrl.dispose(); // Membuang TextEditingController untuk email.
    usernameCtrl.dispose(); // Membuang TextEditingController untuk username.
    passwordCtrl.dispose(); // Membuang TextEditingController untuk password.
    confirmCtrl.dispose(); // Membuang TextEditingController untuk konfirmasi password.
    super.dispose(); // Memanggil metode dispose dari kelas induk (ChangeNotifier).
  }
}