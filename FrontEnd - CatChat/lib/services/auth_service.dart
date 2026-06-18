// Penjelasan file dan tujuannya:
// Nama file: auth_service.dart
// Deskripsi: File ini mengatur komunikasi dengan pihak luar (seperti Backend Server atau memori HP lokal).
// Mengarahkan ke/Keterkaitan:
// - Mengarah ke Backend: Mengirim HTTP Request ke Node.js.
// - Berhubungan dengan Controller: Menyediakan data mentah yang akan diolah oleh file Controller.

import 'dart:convert'; // Mengimpor pustaka 'dart:convert' untuk encoding/decoding JSON dan operasi UTF-8.
import 'dart:math'; // Mengimpor pustaka 'dart:math' untuk menghasilkan angka acak.

import 'package:crypto/crypto.dart'; // Mengimpor pustaka 'crypto' untuk fungsi hashing kriptografis seperti SHA256.
import 'package:shared_preferences/shared_preferences.dart'; // Mengimpor pustaka 'shared_preferences' untuk menyimpan data preferensi pengguna secara lokal dan persisten.
import 'api_service.dart'; // Mengimpor file 'api_service.dart', yang kemungkinan berisi definisi kelas untuk berinteraksi dengan API backend aplikasi.

class AuthService {
  // Mendefinisikan kelas 'AuthService' yang bertanggung jawab untuk semua logika yang berkaitan dengan otentikasi pengguna, manajemen sesi, dan PIN.
  AuthService._(); // Konstruktor privat untuk menerapkan pola desain Singleton, memastikan hanya ada satu instance dari kelas ini.
  static final AuthService instance = AuthService._(); // Membuat instance tunggal (singleton) dari 'AuthService' yang dapat diakses secara global.

  static const String _sessionActiveKey = 'catchat_session_active'; // Kunci konstanta untuk Shared Preferences yang menyimpan status aktifnya sesi pengguna.
  static const String _sessionUsernameKey = 'catchat_session_username'; // Kunci konstanta untuk Shared Preferences yang menyimpan nama pengguna (username) dari sesi yang aktif.
  static const String _pinKey = 'catchat_user_pin'; // Kunci konstanta untuk Shared Preferences yang menyimpan PIN pengguna setelah di-hash.

  // ── Auth ──────────────────────────────────────────────────────────

  /// True if a local session exists (can be used to check offline state)
  // Metode ini memeriksa apakah ada sesi pengguna yang terdaftar secara lokal, yang dapat digunakan untuk menentukan status offline.
  Future<bool> hasRegisteredUsers() async {
    final prefs = await SharedPreferences.getInstance(); // Mendapatkan instance dari SharedPreferences untuk mengakses penyimpanan lokal.
    return prefs.getBool(_sessionActiveKey) ?? false; // Mengembalikan nilai boolean dari kunci '_sessionActiveKey'. Jika kunci tidak ada, maka mengembalikan false (mengindikasikan belum ada pengguna terdaftar/sesi aktif). Berhubungan ke pengecekan status login.
  }

  /// Generate a unique anonymous username using API
  // Metode ini bertujuan untuk menghasilkan nama pengguna (username) anonim yang unik, dengan prioritas menggunakan API backend terlebih dahulu.
  Future<String> generateAnonUsername() async {
    try {
      // Mencoba untuk mendapatkan username anonim dari API backend.
      final response = await ApiService.instance.get('/auth/generate-username'); // Melakukan permintaan HTTP GET ke endpoint '/auth/generate-username' pada API.
      if (response.statusCode == 200) {
        // Jika respons dari API berhasil (status code 200 OK).
        final data = jsonDecode(response.body); // Mendekode body respons JSON menjadi objek Dart.
        return data['data']['username']; // Mengembalikan nilai username yang didapat dari struktur data JSON respons. Berhubungan ke UI untuk menampilkan username anonim.
      }
    } catch (_) {
      // Jika terjadi kesalahan saat memanggil API (misalnya, tidak ada koneksi internet), blok ini akan dieksekusi.
      // Kesalahan diabaikan untuk melanjutkan ke logika fallback di bawah.
    }

    // Fallback logic jika API gagal atau tidak tersedia.
    final random = Random(); // Membuat instance dari generator angka acak.
    const daftarNama = ['Sophelia', 'Teodor', 'Zandra', 'Akira', 'SaeRi']; // Daftar nama predefinisi untuk digunakan jika API gagal.
    final nama = daftarNama[random.nextInt(daftarNama.length)]; // Memilih satu nama secara acak dari 'daftarNama'.
    final num = random.nextInt(900) + 100; // Menghasilkan angka acak antara 100 dan 999 (inklusif).
    return '$nama$num'; // Menggabungkan nama acak dan angka acak untuk membentuk username anonim fallback. Berhubungan ke UI untuk menampilkan username anonim.
  }

  /// Register a new account via API
  // Metode ini menangani proses registrasi akun pengguna baru dengan mengirimkan detail ke API backend.
  Future<String?> register(String email, String username, String password) async {
    try {
      // Mencoba mengirim data registrasi ke API backend.
      final response = await ApiService.instance.post('/auth/register', {
        'email': email.trim(), // Mengirim email pengguna, setelah menghapus spasi di awal dan akhir.
        'username': username.trim(), // Mengirim username pengguna, setelah menghapus spasi di awal dan akhir.
        'password': password, // Mengirim kata sandi pengguna.
      });

      final data = jsonDecode(response.body); // Mendekode respons JSON dari API.

      if (response.statusCode == 201) {
        // Jika registrasi berhasil (status code 201 Created).
        final token = data['data']['token']; // Mengambil token otentikasi dari respons.
        final user = data['data']['user']; // Mengambil data pengguna dari respons.
        await ApiService.instance.saveToken(token); // Menyimpan token otentikasi menggunakan ApiService (kemungkinan ke Shared Preferences atau Keystore).
        await _setSession(user['username']); // Memanggil metode privat untuk mengatur sesi lokal pengguna. Berhubungan ke status login.
        return null; // Mengembalikan null untuk menandakan bahwa proses registrasi berhasil tanpa pesan error.
      } else {
        // Jika registrasi gagal (status code bukan 201).
        return data['message'] ?? 'Gagal mendaftar.'; // Mengembalikan pesan error dari respons API, atau pesan default jika tidak ada pesan error. Berhubungan ke UI untuk menampilkan pesan error registrasi.
      }
    } catch (e) {
      // Menangkap dan menangani kesalahan jaringan atau server saat mencoba mendaftar.
      return 'Tidak dapat terhubung ke server. Pastikan internet Anda aktif.'; // Mengembalikan pesan error koneksi. Berhubungan ke UI untuk menampilkan pesan error koneksi.
    }
  }

  /// Login with existing credentials via API
  // Metode ini menangani proses login pengguna dengan kredensial yang ada melalui API backend.
  Future<String?> login(String email, String password) async {
    try {
      // Mencoba mengirim detail login ke API backend.
      final response = await ApiService.instance.post('/auth/login', {
        'email': email.trim(), // Mengirim email pengguna, setelah menghapus spasi di awal dan akhir.
        'password': password, // Mengirim kata sandi pengguna.
      });

      final data = jsonDecode(response.body); // Mendekode respons JSON dari API.

      if (response.statusCode == 200) {
        // Jika login berhasil (status code 200 OK).
        final token = data['data']['token']; // Mengambil token otentikasi dari respons.
        final user = data['data']['user']; // Mengambil data pengguna dari respons.
        
        await ApiService.instance.saveToken(token); // Menyimpan token otentikasi.
        await _setSession(user['username'] ?? 'User'); // Memanggil metode privat untuk mengatur sesi lokal pengguna dengan username. Jika username null, gunakan 'User'. Berhubungan ke status login.
        
        // Pin flag
        if (user['has_pin'] == true) {
           // Logika ini menangani kasus di mana pengguna memiliki PIN yang telah disetel di backend.
           // Catatan: Kode ini menjelaskan bahwa PIN tidak diunduh, tetapi diverifikasi oleh backend.
           // Namun, untuk menjaga logika kunci PIN lokal agar berfungsi saat offline,
           // ada pertimbangan untuk menyimpan PIN dummy atau mengandalkan verifikasi backend.
           // Kode yang ada memilih untuk menandai PIN dikontrol backend secara lokal.
           final prefs = await SharedPreferences.getInstance(); // Mendapatkan instance SharedPreferences.
           await prefs.setString(_pinKey, 'backend_controlled'); // Menyimpan nilai khusus '_pinKey' untuk menandakan PIN dikelola oleh backend. Berhubungan ke proses verifikasi PIN.
        }

        return null; // Mengembalikan null untuk menandakan bahwa proses login berhasil tanpa pesan error. Berhubungan ke halaman utama aplikasi.
      } else {
        // Jika login gagal (status code bukan 200).
        return data['message'] ?? 'Email atau password salah.'; // Mengembalikan pesan error dari respons API, atau pesan default jika tidak ada pesan error. Berhubungan ke UI untuk menampilkan pesan error login.
      }
    } catch (e) {
      // Menangkap dan menangani kesalahan jaringan atau server saat mencoba login.
      return 'Tidak dapat terhubung ke server. Pastikan internet Anda aktif.'; // Mengembalikan pesan error koneksi. Berhubungan ke UI untuk menampilkan pesan error koneksi.
    }
  }

  // ── Session ───────────────────────────────────────────────────────

  // Metode privat untuk mengatur data sesi pengguna di SharedPreferences.
  Future<void> _setSession(String username) async {
    final prefs = await SharedPreferences.getInstance(); // Mendapatkan instance SharedPreferences.
    await prefs.setBool(_sessionActiveKey, true); // Menyetel kunci '_sessionActiveKey' menjadi true, menandakan sesi aktif.
    await prefs.setString(_sessionUsernameKey, username); // Menyimpan nama pengguna sesi ke kunci '_sessionUsernameKey'.
  }

  // Metode ini memeriksa apakah sesi pengguna saat ini aktif dan apakah token otentikasi tersedia.
  Future<bool> isSessionActive() async {
    final prefs = await SharedPreferences.getInstance(); // Mendapatkan instance SharedPreferences.
    final isActive = prefs.getBool(_sessionActiveKey) ?? false; // Mendapatkan status aktif sesi dari SharedPreferences.
    final token = await ApiService.instance.getToken(); // Mendapatkan token otentikasi yang tersimpan dari ApiService.
    return isActive && token != null; // Mengembalikan true jika sesi aktif DAN token otentikasi ada. Berhubungan ke logika navigasi (misal: menampilkan halaman utama atau halaman login).
  }

  // Metode ini mengambil dan mengembalikan nama pengguna (username) sesi yang tersimpan secara lokal.
  Future<String?> getSessionUsername() async {
    final prefs = await SharedPreferences.getInstance(); // Mendapatkan instance SharedPreferences.
    return prefs.getString(_sessionUsernameKey); // Mengembalikan username yang tersimpan dari SharedPreferences. Berhubungan ke UI yang menampilkan informasi pengguna.
  }

  /// Logout: clears session & PIN
  // Metode ini melakukan proses logout pengguna, menghapus data sesi lokal, token otentikasi, dan PIN.
  Future<void> logout() async {
    try {
      // Mencoba memanggil endpoint logout di API backend.
      await ApiService.instance.post('/auth/logout', {}); // Mengirim permintaan POST ke endpoint '/auth/logout'.
    } catch (_) {
      // Jika terjadi kesalahan saat memanggil API logout (misal: offline), kesalahan ini diabaikan.
      // Proses logout lokal akan tetap dilanjutkan.
    }
    
    final prefs = await SharedPreferences.getInstance(); // Mendapatkan instance SharedPreferences.
    await prefs.remove(_sessionActiveKey); // Menghapus kunci '_sessionActiveKey' dari SharedPreferences.
    await prefs.remove(_sessionUsernameKey); // Menghapus kunci '_sessionUsernameKey' dari SharedPreferences.
    await ApiService.instance.clearToken(); // Memanggil metode 'clearToken' di ApiService untuk menghapus token otentikasi.
    await clearPIN(); // Memanggil metode 'clearPIN' untuk menghapus PIN yang tersimpan secara lokal. Berhubungan ke halaman login/register.
  }

  // Metode ini menghasilkan kunci unik untuk penyimpanan riwayat obrolan berdasarkan nama pengguna sesi.
  Future<String> getChatHistoryKey() async {
    final username = await getSessionUsername(); // Mendapatkan username sesi saat ini.
    if (username != null && username.isNotEmpty) {
      // Jika username tersedia dan tidak kosong, buat kunci dengan format 'chat_history_[username]'.
      return 'chat_history_$username'; // Berhubungan ke mekanisme penyimpanan atau pengambilan riwayat obrolan.
    }
    // Jika username tidak tersedia, gunakan kunci default.
    return 'chat_history'; // Berhubungan ke mekanisme penyimpanan atau pengambilan riwayat obrolan.
  }

  /// Delete account: wipe everything.
  // Metode ini menangani penghapusan akun pengguna, baik dari sisi backend maupun dari data lokal di perangkat.
  Future<void> deleteAccount() async {
    try {
      // Mencoba memanggil endpoint penghapusan akun di API backend.
      await ApiService.instance.delete('/profile/account'); // Mengirim permintaan DELETE ke endpoint '/profile/account'.
    } catch (_) {
      // Jika terjadi kesalahan saat memanggil API penghapusan akun (misal: offline), kesalahan ini diabaikan.
      // Proses penghapusan data lokal akan tetap dilanjutkan.
    }

    final prefs = await SharedPreferences.getInstance(); // Mendapatkan instance SharedPreferences.
    await prefs.remove(_sessionActiveKey); // Menghapus kunci status sesi aktif.
    await prefs.remove(_sessionUsernameKey); // Menghapus kunci username sesi.
    await prefs.remove(await getChatHistoryKey()); // Menghapus riwayat obrolan menggunakan kunci yang relevan dengan pengguna.
    await ApiService.instance.clearToken(); // Menghapus token otentikasi.
    await clearPIN(); // Menghapus PIN yang tersimpan secara lokal. Berhubungan ke halaman login/register setelah akun berhasil dihapus.
  }

  // ── PIN ───────────────────────────────────────────────────────────

  // Metode privat untuk menghasilkan hash SHA256 dari sebuah string input.
  String _hash(String input) {
    final bytes = utf8.encode(input); // Mengonversi string input menjadi urutan byte UTF-8.
    final digest = sha256.convert(bytes); // Melakukan operasi hashing SHA256 pada byte-byte tersebut.
    return digest.toString(); // Mengembalikan hasil hash dalam bentuk string heksadesimal.
  }

  // Metode ini memeriksa apakah PIN pengguna telah disetel secara lokal (sudah disimpan).
  Future<bool> hasPIN() async {
    final prefs = await SharedPreferences.getInstance(); // Mendapatkan instance SharedPreferences.
    final pin = prefs.getString(_pinKey); // Mengambil nilai PIN yang tersimpan dari SharedPreferences.
    return pin != null && pin.isNotEmpty; // Mengembalikan true jika nilai PIN tidak null dan tidak kosong. Berhubungan ke logika pengecekan status PIN.
  }

  // Metode ini menyimpan PIN pengguna. PIN tersebut akan di-hash sebelum disimpan secara lokal, dan juga dikirim ke backend.
  Future<void> savePIN(String pin) async {
    final prefs = await SharedPreferences.getInstance(); // Mendapatkan instance SharedPreferences.
    final hashedPin = _hash(pin); // Meng-hash PIN yang diberikan menggunakan metode _hash.
    await prefs.setString(_pinKey, hashedPin); // Menyimpan PIN yang sudah di-hash ke SharedPreferences menggunakan kunci '_pinKey'.

    // Save to backend
    try {
      // Mencoba mengirim PIN mentah ke backend untuk disimpan.
      await ApiService.instance.put('/auth/pin', {'pin': pin}); // Mengirim permintaan HTTP PUT ke endpoint '/auth/pin' dengan data PIN mentah.
    } catch (_) {
      // Jika terjadi kesalahan saat mengirim PIN ke backend (misal: offline), kesalahan ini diabaikan.
      // PIN akan tetap tersimpan secara lokal.
    } // Berhubungan ke status PIN yang berhasil disimpan.
  }

  // Metode ini memverifikasi PIN yang diberikan oleh pengguna. Akan mencoba verifikasi melalui API backend terlebih dahulu.
  Future<bool> verifyPIN(String pin) async {
    // Try backend verification first
    try {
      // Mencoba memverifikasi PIN langsung dengan API backend.
      final response = await ApiService.instance.post('/auth/verify-pin', {'pin': pin}); // Mengirim permintaan HTTP POST ke endpoint '/auth/verify-pin' dengan PIN.
      if (response.statusCode == 200) {
        // Jika verifikasi backend berhasil (status code 200 OK).
        final data = jsonDecode(response.body); // Mendekode respons JSON dari API.
        return data['data']['valid'] == true; // Mengembalikan nilai dari field 'valid' dalam respons JSON. Berhubungan ke proses pengecekan PIN (sukses/gagal).
      }
    } catch (_) {
      // Jika terjadi kesalahan saat verifikasi backend (misal: offline), kesalahan ini diabaikan.
      // Proses akan dilanjutkan ke verifikasi lokal sebagai fallback.
    }

    // Fallback to local
    final prefs = await SharedPreferences.getInstance(); // Mendapatkan instance SharedPreferences.
    final stored = prefs.getString(_pinKey); // Mengambil PIN yang tersimpan dari SharedPreferences.
    if (stored == 'backend_controlled') {
       // Kasus khusus: Jika PIN lokal ditandai sebagai 'backend_controlled'.
       // Ini berarti PIN asli hanya ada di backend. Jika verifikasi backend gagal atau offline,
       // kita tidak bisa memverifikasi secara lokal tanpa PIN mentah (yang tidak disimpan).
       // Oleh karena itu, dalam kondisi ini, kita mengembalikan false jika verifikasi backend gagal.
       return false; // Mengindikasikan PIN tidak valid atau tidak dapat diverifikasi.
    }
    // Membandingkan PIN yang di-hash dari input pengguna dengan PIN yang tersimpan secara lokal.
    return stored == _hash(pin); // Mengembalikan true jika kedua hash cocok, menandakan PIN valid. Berhubungan ke proses pengecekan PIN (sukses/gagal).
  }

  // Metode ini menghapus PIN pengguna yang tersimpan secara lokal dari SharedPreferences.
  Future<void> clearPIN() async {
    final prefs = await SharedPreferences.getInstance(); // Mendapatkan instance SharedPreferences.
    await prefs.remove(_pinKey); // Menghapus kunci '_pinKey' beserta nilainya dari SharedPreferences. Berhubungan ke status PIN yang tidak tersimpan.
  }
}