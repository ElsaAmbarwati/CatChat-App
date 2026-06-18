// Penjelasan file controller ini dan tujuannya.
// Nama file: chat_controller.dart
// Deskripsi: Controller ini adalah otak dari fitur Chat AI di aplikasi HP pengguna.
// Gunanya adalah mengelola input ketikan pengguna, menyimpannya di HP (memori lokal),
// dan mengawasi jalannya komunikasi (loading/typing state).
// Mengarahkan ke/Keterkaitan:
// - Mengarah ke Backend (Node.js): Fungsi sendMessage() mengirim teks ke file ai.controller.js lewat internet.
// - Mengarah ke Penyimpanan (SharedPreferences): Fungsi persistSession() menyimpan chat murni di HP (Privacy-by-Design).
// - Berhubungan dengan Layar: Data dari sini digambar ke layar oleh file chat_pages.dart.
import 'dart:async'; // Mengimpor pustaka 'dart:async' untuk operasi asinkron.
import 'dart:convert'; // Mengimpor pustaka 'dart:convert' untuk encoding/decoding JSON.

import 'package:flutter/material.dart'; // Mengimpor pustaka Flutter untuk komponen UI dan ChangeNotifier.
import 'package:shared_preferences/shared_preferences.dart'; // Mengimpor pustaka SharedPreferences untuk penyimpanan data lokal.
import '../services/api_service.dart'; // Mengimpor layanan API untuk komunikasi dengan backend.
import '../services/auth_service.dart'; // Mengimpor layanan autentikasi untuk mendapatkan kunci riwayat chat.

import '../models/chat_message.dart'; // Mengimpor model ChatMessage untuk merepresentasikan struktur pesan.

class ChatController extends ChangeNotifier {
  // Mendefinisikan kelas ChatController yang mewarisi ChangeNotifier untuk manajemen state.
  final List<ChatMessage> _messages = []; // Variabel privat untuk menyimpan daftar pesan chat.
  List<ChatMessage> get messages => _messages; // Getter publik untuk mengakses daftar pesan dari luar.

  final TextEditingController textController = TextEditingController(); // Controller untuk mengelola input teks di TextField.
  final ScrollController scrollController = ScrollController(); // Controller untuk mengelola posisi scroll pada daftar chat.

  bool _isTyping = false; // Variabel privat untuk menunjukkan apakah AI sedang mengetik.
  bool get isTyping => _isTyping; // Getter publik untuk status _isTyping.

  String? sessionId; // Variabel untuk menyimpan ID sesi chat saat ini.

  Future<void> persistSession() async {
    // Fungsi asinkron untuk menyimpan riwayat sesi chat secara lokal.
    // PENTING UNTUK SIDANG:
    // Bagian ini adalah bukti penerapan Privacy-by-Design.
    // Pesan disimpan menggunakan SharedPreferences (Penyimpanan Lokal), bukan dikirim ke database MySQL.
    // Hanya simpan sesi jika user sudah mengetik minimal 1 pesan

    final hasUserMessage = _messages.any((m) => !m.isAi); // Memeriksa apakah ada setidaknya satu pesan dari pengguna.
    if (!hasUserMessage) return; // Jika tidak ada pesan dari pengguna, hentikan proses penyimpanan sesi.
    try {
      final prefs = await SharedPreferences.getInstance(); // Mendapatkan instance SharedPreferences.
      final historyKey = await AuthService.instance.getChatHistoryKey(); // Mendapatkan kunci unik untuk riwayat chat dari AuthService.
      final stored = prefs.getStringList(historyKey) ?? <String>[]; // Mengambil daftar riwayat sesi yang tersimpan, atau inisialisasi dengan daftar kosong.

      if (sessionId == null) {
        // Jika sessionId belum ada (sesi baru),
        sessionId = DateTime.now().toIso8601String(); // buat sessionId baru berdasarkan waktu saat ini.
      }

      final session = {
        // Membuat objek map yang merepresentasikan sesi chat saat ini.
        'id': sessionId, // ID sesi.
        'time': DateTime.now().toIso8601String(), // Waktu terakhir sesi diperbarui.
        'messages': _messages
            .map(
              // Mengubah daftar ChatMessage menjadi daftar map untuk penyimpanan.
              (m) => {
                'text': m.text, // Teks pesan.
                'isAi': m.isAi, // Status apakah pesan dari AI.
                'time': m.time.toIso8601String(), // Waktu pesan.
              },
            )
            .toList(), // Mengubah hasil map menjadi list.
      };

      // Hapus session lama jika ada, lalu insert yang baru di atas
      stored.removeWhere((s) {
        // Menghapus sesi lama dengan ID yang sama jika sudah ada.
        try {
          final data = jsonDecode(s); // Mendecode string JSON menjadi map.
          return data['id'] == sessionId; // Mengembalikan true jika ID sesi cocok.
        } catch (_) {
          return false; // Mengembalikan false jika terjadi error saat decode.
        }
      });

      stored.insert(0, jsonEncode(session)); // Menyisipkan sesi baru (dalam bentuk JSON string) di awal daftar.
      if (stored.length > 50) stored.removeRange(50, stored.length); // Membatasi jumlah sesi yang disimpan menjadi maksimal 50, menghapus yang terlama.
      await prefs.setStringList(historyKey, stored); // Menyimpan kembali daftar sesi yang telah diperbarui ke SharedPreferences.
    } catch (_) {} // Menangkap error yang mungkin terjadi selama proses penyimpanan (diabaikan agar aplikasi tidak crash).
  }

  Future<void> sendMessage() async {
    // Fungsi asinkron untuk mengirim pesan.
    final text = textController.text.trim(); // Mengambil teks dari input field dan menghapus spasi di awal/akhir.
    if (text.isEmpty) return; // Jika teks kosong, hentikan fungsi.

    final historyData = _messages.map((m) => {
      // Mempersiapkan data riwayat chat untuk dikirim ke backend.
      'text': m.text, // Teks pesan.
      'isAi': m.isAi // Status apakah pesan dari AI.
    }).toList(); // Mengubah hasil map menjadi list.

    _messages.add(
      // Menambahkan pesan pengguna ke daftar pesan lokal.
      ChatMessage(text: text, isAi: false, time: DateTime.now()), // Pesan pengguna, isAi: false.
    );
    textController.clear(); // Mengosongkan input teks setelah pesan dikirim.
    _isTyping = true; // Mengatur status _isTyping menjadi true (AI sedang merespons).
    notifyListeners(); // Memberi tahu widget yang mendengarkan bahwa state telah berubah (untuk memperbarui UI).

    scrollToBottom(delay: 100); // Menggulir daftar pesan ke bawah setelah pesan pengguna ditambahkan.

    try {
      // PENTING UNTUK SIDANG:
      // Di sini Frontend Flutter mengirimkan pesan lewat jaringan internet (REST-API)
      // menuju server Backend Node.js (ke rute /ai/chat).
      final response = await ApiService.instance.post('/ai/chat', {
        // Mengirim permintaan POST ke endpoint '/ai/chat' di backend.
        'message': text, // Mengirim pesan pengguna saat ini.
        'history': historyData // Mengirim riwayat chat sebelumnya sebagai konteks untuk AI.
      });
      if (response.statusCode == 200) {
        // Jika respons dari server sukses (status code 200),
        final data = jsonDecode(response.body); // Mendecode body respons menjadi objek Dart.
        final aiReply = data['data']['reply']; // Mengambil balasan dari AI dari data respons.
        _messages.add(
          // Menambahkan balasan AI ke daftar pesan.
          ChatMessage(text: aiReply, isAi: true, time: DateTime.now()), // Pesan AI, isAi: true.
        );
      } else {
        // Jika terjadi error dari server (status code bukan 200),
        _messages.add(
          // Menambahkan pesan error ke daftar pesan.
          ChatMessage(text: "Maaf, aku lagi pusing (server error). Coba lagi ya.", isAi: true, time: DateTime.now()), // Pesan error dari AI.
        );
      }
    } catch (e) {
      // Menangkap error jika terjadi masalah koneksi atau error lainnya saat mengirim permintaan.
      _messages.add(
        // Menambahkan pesan error koneksi ke daftar pesan.
        ChatMessage(text: "Maaf, koneksi terputus. Coba cek internetmu.", isAi: true, time: DateTime.now()), // Pesan error koneksi dari AI.
      );
    }

    _isTyping = false; // Mengatur status _isTyping menjadi false (AI selesai merespons).
    notifyListeners(); // Memberi tahu widget bahwa state telah berubah.
    scrollToBottom(delay: 100); // Menggulir daftar pesan ke bawah setelah balasan AI ditambahkan.
  }

  void scrollToBottom({int delay = 0}) {
    // Fungsi untuk menggulir daftar chat ke posisi paling bawah.
    Future.delayed(Duration(milliseconds: delay), () {
      // Menunda eksekusi gulir selama 'delay' milidetik.
      if (scrollController.hasClients) {
        // Memastikan scrollController terhubung ke Scrollable widget.
        scrollController.animateTo(
          // Melakukan animasi gulir.
          scrollController.position.maxScrollExtent + 120, // Tujuan gulir (paling bawah + sedikit padding).
          duration: Duration(milliseconds: 300), // Durasi animasi gulir.
          curve: Curves.easeOut, // Kurva animasi.
        );
      }
    });
  }

  @override
  void dispose() {
    // Override metode dispose untuk membersihkan sumber daya.
    textController.dispose(); // Membuang TextEditingController untuk mencegah memory leak.
    scrollController.dispose(); // Membuang ScrollController untuk mencegah memory leak.
    super.dispose(); // Memanggil metode dispose dari kelas induk.
  }
}