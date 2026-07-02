// Penjelasan file dan tujuannya:
// Nama file: api_service.dart
// Deskripsi: File ini mengatur komunikasi dengan pihak luar (seperti Backend Server atau memori HP lokal).
// Mengarahkan ke/Keterkaitan:
// - Mengarah ke Backend: Mengirim HTTP Request ke Node.js.
// - Berhubungan dengan Controller: Menyediakan data mentah yang akan diolah oleh file Controller.

import 'dart:convert'; // Mengimpor pustaka 'dart:convert' untuk fungsionalitas pengkodean dan dekode JSON, memungkinkan konversi antara objek Dart dan string JSON.
import 'package:http/http.dart'
    as http; // Mengimpor pustaka 'http' untuk membuat permintaan jaringan, diberi alias 'http' untuk penulisan yang lebih ringkas.
import 'package:shared_preferences/shared_preferences.dart'; // Mengimpor pustaka 'shared_preferences' untuk menyimpan data sederhana secara persisten di perangkat lokal.

class ApiService {
  // Mendefinisikan kelas ApiService untuk mengelola semua interaksi dengan API backend.
  ApiService._(); // Konstruktor privat untuk kelas ApiService. Ini adalah bagian dari pola desain Singleton untuk memastikan hanya satu instance kelas ini yang dibuat.
  static final ApiService instance =
      ApiService._(); // Membuat instance statis tunggal dari ApiService. Pola Singleton ini memungkinkan akses ke instance yang sama dari mana saja di aplikasi.

  // Komentar ini memberikan panduan tentang cara mengkonfigurasi baseUrl untuk lingkungan yang berbeda, seperti emulator Android atau perangkat fisik, karena 'localhost' dapat merujuk pada perangkat itu sendiri atau mesin host.
  // Contoh konfigurasi untuk emulator Android: 'http://10.0.2.2:3000/api'
  // Contoh konfigurasi untuk perangkat fisik di jaringan lokal: 'http://192.168.1.5:3000/api' (ganti dengan IP lokal mesin Anda)
  static const String baseUrl =
      'http://10.83.241.220:3000/api'; // Mendefinisikan URL dasar untuk semua endpoint API. Ini adalah konstanta yang digunakan sebagai prefiks untuk semua permintaan.
  static const String _tokenKey =
      'catchat_jwt_token'; // Mendefinisikan kunci string yang digunakan untuk menyimpan dan mengambil token JWT dari SharedPreferences. Ini adalah konstanta privat yang menandakan bahwa itu hanya untuk penggunaan internal kelas.

  Future<void> saveToken(String token) async {
    // Metode asinkron untuk menyimpan token otentikasi (JWT) ke penyimpanan lokal menggunakan SharedPreferences.
    final prefs =
        await SharedPreferences.getInstance(); // Mendapatkan instance dari SharedPreferences. Operasi ini asinkron karena melibatkan akses ke penyimpanan.
    await prefs.setString(
      _tokenKey,
      token,
    ); // Menyimpan token string ke SharedPreferences menggunakan kunci yang telah ditentukan (_tokenKey).
  }

  Future<String?> getToken() async {
    // Metode asinkron untuk mengambil token otentikasi (JWT) dari penyimpanan lokal. Mengembalikan String? karena token mungkin belum ada.
    final prefs =
        await SharedPreferences.getInstance(); // Mendapatkan instance dari SharedPreferences.
    return prefs.getString(
      _tokenKey,
    ); // Mengambil string yang terkait dengan kunci token. Jika tidak ada, ia akan mengembalikan null. Mengarah ke token yang disimpan oleh `saveToken`.
  }

  Future<void> clearToken() async {
    // Metode asinkron untuk menghapus token otentikasi (JWT) dari penyimpanan lokal.
    final prefs =
        await SharedPreferences.getInstance(); // Mendapatkan instance dari SharedPreferences.
    await prefs.remove(
      _tokenKey,
    ); // Menghapus entri yang terkait dengan kunci token dari SharedPreferences. Ini berguna saat logout.
  }

  Map<String, String> _buildHeaders(String? token) {
    // Metode privat untuk membuat Map header HTTP. Ini termasuk header Content-Type, Accept, dan Authorization (jika token tersedia).
    final headers = {
      // Menginisialisasi Map untuk header HTTP.
      'Content-Type':
          'application/json', // Menetapkan header 'Content-Type' untuk menunjukkan bahwa body permintaan dikirim dalam format JSON.
      'Accept':
          'application/json', // Menetapkan header 'Accept' untuk menunjukkan bahwa klien mengharapkan respons dalam format JSON.
    };
    if (token != null && token.isNotEmpty) {
      // Memeriksa apakah token yang diberikan tidak null dan tidak kosong.
      headers['Authorization'] =
          'Bearer $token'; // Jika token ada, tambahkan header 'Authorization' dengan token yang didahului oleh 'Bearer '. Ini adalah standar untuk otentikasi JWT.
    }
    return headers; // Mengembalikan Map header yang sudah lengkap.
  }

  Future<http.Response> get(String endpoint) async {
    // Metode asinkron untuk melakukan permintaan HTTP GET.
    final token =
        await getToken(); // Mengambil token otentikasi yang tersimpan dari SharedPreferences. Mengarah ke `getToken()`.
    final uri = Uri.parse(
      '$baseUrl$endpoint',
    ); // Membuat objek Uri lengkap dengan menggabungkan baseUrl dan endpoint yang diberikan.
    return await http.get(
      uri,
      headers: _buildHeaders(token),
    ); // Melakukan permintaan GET HTTP ke URI yang dibuat, meneruskan header yang dibangun (termasuk token otentikasi jika ada) yang dibuat oleh `_buildHeaders`.
  }

  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    // Metode asinkron untuk melakukan permintaan HTTP POST.
    final token =
        await getToken(); // Mengambil token otentikasi yang tersimpan.
    final uri = Uri.parse(
      '$baseUrl$endpoint',
    ); // Membuat objek Uri lengkap untuk endpoint.
    return await http.post(
      // Melakukan permintaan POST HTTP.
      uri, // URL tujuan permintaan.
      headers: _buildHeaders(token), // Header HTTP, termasuk otentikasi.
      body: jsonEncode(
        body,
      ), // Mengonversi Map body menjadi string JSON menggunakan `jsonEncode` dari `dart:convert` sebelum mengirimkannya.
    );
  }

  Future<http.Response> put(String endpoint, Map<String, dynamic> body) async {
    // Metode asinkron untuk melakukan permintaan HTTP PUT, biasanya digunakan untuk memperbarui sumber daya yang ada.
    final token =
        await getToken(); // Mengambil token otentikasi yang tersimpan.
    final uri = Uri.parse(
      '$baseUrl$endpoint',
    ); // Membuat objek Uri lengkap untuk endpoint.
    return await http.put(
      // Melakukan permintaan PUT HTTP.
      uri, // URL tujuan permintaan.
      headers: _buildHeaders(token), // Header HTTP, termasuk otentikasi.
      body: jsonEncode(
        body,
      ), // Mengonversi Map body menjadi string JSON dan mengirimkannya.
    );
  }

  Future<http.Response> delete(String endpoint) async {
    // Metode asinkron untuk melakukan permintaan HTTP DELETE, digunakan untuk menghapus sumber daya.
    final token =
        await getToken(); // Mengambil token otentikasi yang tersimpan.
    final uri = Uri.parse(
      '$baseUrl$endpoint',
    ); // Membuat objek Uri lengkap untuk endpoint.
    return await http.delete(
      uri,
      headers: _buildHeaders(token),
    ); // Melakukan permintaan DELETE HTTP ke URI yang ditentukan, dengan header yang menyertakan token otentikasi jika ada.
  }

  Future<http.Response> patch(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    // Metode asinkron untuk melakukan permintaan HTTP PATCH, digunakan untuk pembaruan parsial pada sumber daya.
    final token =
        await getToken(); // Mengambil token otentikasi yang tersimpan.
    final uri = Uri.parse(
      '$baseUrl$endpoint',
    ); // Membuat objek Uri lengkap untuk endpoint.
    return await http.patch(
      // Melakukan permintaan PATCH HTTP.
      uri, // URL tujuan permintaan.
      headers: _buildHeaders(token), // Header HTTP, termasuk otentikasi.
      body: jsonEncode(
        body,
      ), // Mengonversi Map body menjadi string JSON dan mengirimkannya untuk pembaruan parsial.
    );
  }
}
