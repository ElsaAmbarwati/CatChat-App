// Penjelasan file dan tujuannya:
// Nama file: dinding_doa_controller.dart
// Deskripsi: File ini adalah pengatur logika (otak) di balik layar UI.
// Mengarahkan ke/Keterkaitan:
// - Mengarah ke Backend/Service: Memanggil API melalui jaringan untuk mengambil/menyimpan data.
// - Berhubungan dengan Layar: Data dari sini akan ditampilkan ke layar UI (pages).

import 'dart:convert'; // Mengimpor pustaka untuk encoding/decoding JSON, digunakan untuk memproses respons API.
import 'package:flutter/foundation.dart'; // Mengimpor pustaka fundamental Flutter, seperti untuk debugPrint.
import 'package:flutter/material.dart'; // Mengimpor pustaka Material Design Flutter, diperlukan karena ChangeNotifier adalah bagian dari framework.
import '../services/api_service.dart'; // Mengimpor ApiService untuk melakukan panggilan HTTP ke backend.

class DindingDoaController extends ChangeNotifier { // Mendefinisikan kelas DindingDoaController yang mewarisi ChangeNotifier.
  // ChangeNotifier memungkinkan kelas ini untuk memberi tahu widget-widget yang mendengarkannya jika ada perubahan data, sehingga UI bisa diperbarui.
  int _selectedMobileTabIndex = 0; // Variabel private untuk menyimpan indeks tab yang sedang dipilih di tampilan mobile. Defaultnya 0.

  List<Map<String, dynamic>> _anonStories = []; // List private untuk menyimpan cerita-cerita anonim dari backend.
  final Set<int> _likedAnonStories = {}; // Set private untuk menyimpan ID cerita anonim yang sudah diberi "doa" (liked) oleh pengguna. Set digunakan untuk efisiensi pengecekan keberadaan ID.
  List<Map<String, dynamic>> _myStories = []; // List private untuk menyimpan cerita-cerita yang dibuat oleh pengguna saat ini.
  bool _isLoading = false; // Variabel private untuk menunjukkan apakah sedang ada proses loading data dari backend.

  int get selectedMobileTabIndex => _selectedMobileTabIndex; // Getter publik untuk mendapatkan nilai _selectedMobileTabIndex. Digunakan oleh UI untuk menampilkan tab yang benar.
  List<Map<String, dynamic>> get anonStories => List.unmodifiable(_anonStories); // Getter publik untuk mendapatkan cerita anonim. Mengembalikan list yang tidak bisa diubah dari luar, mencegah modifikasi langsung.
  Set<int> get likedAnonStories => Set.unmodifiable(_likedAnonStories); // Getter publik untuk mendapatkan ID cerita yang sudah di-"doa". Mengembalikan set yang tidak bisa diubah.
  List<Map<String, dynamic>> get myStories => List.unmodifiable(_myStories); // Getter publik untuk mendapatkan cerita pengguna. Mengembalikan list yang tidak bisa diubah.
  bool get isLoading => _isLoading; // Getter publik untuk mendapatkan status loading. Digunakan oleh UI untuk menampilkan indikator loading.

  DindingDoaController() { // Constructor dari kelas DindingDoaController.
    fetchStories(); // Saat controller diinisialisasi, langsung panggil fetchStories untuk mengambil data awal.
  }

  void setMobileTabIndex(int index) { // Metode untuk mengubah indeks tab mobile yang dipilih.
    if (_selectedMobileTabIndex != index) { // Memeriksa apakah indeks baru berbeda dari yang saat ini.
      _selectedMobileTabIndex = index; // Jika berbeda, perbarui indeks tab.
      notifyListeners(); // Memberi tahu semua listener (widget) bahwa data telah berubah, memicu pembaruan UI.
    }
  }

  Future<void> fetchStories() async { // Metode asinkron untuk mengambil semua cerita (anonim dan milik pengguna) dari backend.
    _isLoading = true; // Set status loading menjadi true.
    notifyListeners(); // Beri tahu listener untuk menampilkan indikator loading.

    try {
      final response = await ApiService.instance.get('/stories'); // Melakukan panggilan GET ke endpoint '/stories' untuk mendapatkan cerita anonim.
      if (response.statusCode == 200) { // Memeriksa apakah respons dari server sukses (kode 200 OK).
        final data = jsonDecode(response.body); // Mendekode respons JSON menjadi Map/List Dart.
        _anonStories = List<Map<String, dynamic>>.from(data['data']); // Mengisi _anonStories dengan data cerita anonim.
        
        _likedAnonStories.clear(); // Mengosongkan set _likedAnonStories sebelum mengisi ulang.
        for (var story in _anonStories) { // Iterasi melalui setiap cerita anonim.
          if (story['has_prayed'] == 1 || story['has_prayed'] == true) { // Memeriksa apakah pengguna sudah memberi "doa" (pray) pada cerita ini (ditandai oleh 'has_prayed').
            _likedAnonStories.add(story['id']); // Jika sudah, tambahkan ID cerita ke _likedAnonStories.
          }
        }
      }

      final myResponse = await ApiService.instance.get('/stories/mine'); // Melakukan panggilan GET ke endpoint '/stories/mine' untuk mendapatkan cerita milik pengguna.
      if (myResponse.statusCode == 200) { // Memeriksa apakah respons sukses.
        final data = jsonDecode(myResponse.body); // Mendekode respons JSON.
        _myStories = List<Map<String, dynamic>>.from(data['data']); // Mengisi _myStories dengan data cerita milik pengguna.
      }
    } catch (e) { // Menangkap error yang mungkin terjadi selama proses fetching data.
      debugPrint('Fetch stories error: $e'); // Mencetak pesan error ke konsol debug.
    }

    _isLoading = false; // Setelah selesai (berhasil atau gagal), set status loading menjadi false.
    notifyListeners(); // Beri tahu listener untuk menyembunyikan indikator loading dan memperbarui UI dengan data baru.
  }

  Future<void> addStory(String text, bool showMyStoriesOnly) async { // Metode asinkron untuk menambahkan cerita baru. Parameter showMyStoriesOnly tidak digunakan di sini.
    final trimmed = text.trim(); // Menghapus spasi di awal dan akhir teks.
    if (trimmed.isEmpty) return; // Jika teks kosong setelah di-trim, batalkan operasi.

    try {
      final response = await ApiService.instance.post('/stories', {'content': trimmed}); // Melakukan panggilan POST ke endpoint '/stories' dengan konten cerita.
      if (response.statusCode == 201) { // Memeriksa apakah respons sukses (kode 201 Created).
        await fetchStories(); // Jika cerita berhasil ditambahkan, panggil fetchStories untuk me-refresh data dari server, agar cerita baru muncul di UI.
      }
    } catch (e) { // Menangkap error.
      debugPrint('Add story error: $e'); // Mencetak pesan error.
    }
  }

  Future<void> toggleLike(int index) async { // Metode asinkron untuk mengubah status "doa" (like) pada cerita anonim.
    if (index < 0 || index >= _anonStories.length) return; // Memastikan indeks cerita valid.
    
    final storyId = _anonStories[index]['id']; // Mendapatkan ID cerita dari daftar anonStories berdasarkan indeks.

    // Optimistic UI update: Perbarui UI terlebih dahulu sebelum menunggu respons API. Ini membuat aplikasi terasa lebih responsif.
    final currentCount = (_anonStories[index]['prayers_count'] as int?) ?? 0; // Mendapatkan jumlah doa saat ini.
    if (_likedAnonStories.contains(storyId)) { // Jika cerita sudah di-like.
      _likedAnonStories.remove(storyId); // Hapus ID cerita dari set _likedAnonStories.
      _anonStories[index]['prayers_count'] = currentCount > 0 ? currentCount - 1 : 0; // Kurangi jumlah doa.
    } else { // Jika cerita belum di-like.
      _likedAnonStories.add(storyId); // Tambahkan ID cerita ke set _likedAnonStories.
      _anonStories[index]['prayers_count'] = currentCount + 1; // Tambahkan jumlah doa.
    }
    notifyListeners(); // Beri tahu listener untuk segera memperbarui UI dengan perubahan ini.

    // Call API: Setelah UI diperbarui secara optimis, baru panggil API untuk perubahan sebenarnya di backend.
    try {
      await ApiService.instance.post('/stories/$storyId/pray', {}); // Melakukan panggilan POST ke endpoint untuk "mendoakan" cerita.
    } catch (e) { // Menangkap error jika panggilan API gagal.
      debugPrint('Toggle like error: $e'); // Mencetak pesan error.
      // Revert if failed: Jika API gagal, kembalikan perubahan UI yang optimis tadi agar UI tetap konsisten dengan data backend.
      final currentCountRevert = (_anonStories[index]['prayers_count'] as int?) ?? 0; // Mendapatkan jumlah doa (yang sudah diubah secara optimis).
      if (_likedAnonStories.contains(storyId)) { // Logika kebalikan dari optimistic update.
        _likedAnonStories.remove(storyId); // Jika sudah ada di set (berarti tadi ditambah), sekarang dihapus.
        _anonStories[index]['prayers_count'] = currentCountRevert > 0 ? currentCountRevert - 1 : 0; // Kurangi jumlah doa (yang sebelumnya ditambah).
      } else { // Jika tidak ada di set (berarti tadi dihapus).
        _likedAnonStories.add(storyId); // Sekarang ditambahkan kembali.
        _anonStories[index]['prayers_count'] = currentCountRevert + 1; // Tambahkan jumlah doa (yang sebelumnya dikurangi).
      }
      notifyListeners(); // Beri tahu listener untuk memperbarui UI kembali ke kondisi sebelum optimistic update.
    }
  }

  Future<void> editStory(int index, String newContent) async { // Metode asinkron untuk mengedit cerita milik pengguna.
    if (index < 0 || index >= _myStories.length) return; // Memastikan indeks valid.
    final storyId = _myStories[index]['id']; // Mendapatkan ID cerita yang akan diedit.
    final trimmed = newContent.trim(); // Menghapus spasi dari konten baru.
    if (trimmed.isEmpty) return; // Jika konten kosong, batalkan.

    try {
      final response = await ApiService.instance.put('/stories/$storyId', {'content': trimmed}); // Melakukan panggilan PUT ke endpoint untuk memperbarui cerita.
      if (response.statusCode == 200) { // Memeriksa apakah respons sukses.
        _myStories[index]['content'] = trimmed; // Memperbarui konten cerita di daftar lokal.
        notifyListeners(); // Beri tahu listener untuk memperbarui UI.
      }
    } catch (e) { // Menangkap error.
      debugPrint('Edit story error: $e'); // Mencetak pesan error.
    }
  }

  Future<void> deleteStory(int index) async { // Metode asinkron untuk menghapus cerita milik pengguna.
    if (index < 0 || index >= _myStories.length) return; // Memastikan indeks valid.
    final storyId = _myStories[index]['id']; // Mendapatkan ID cerita yang akan dihapus.

    try {
      final response = await ApiService.instance.delete('/stories/$storyId'); // Melakukan panggilan DELETE ke endpoint untuk menghapus cerita.
      if (response.statusCode == 200) { // Memeriksa apakah respons sukses.
        _myStories.removeAt(index); // Menghapus cerita dari daftar lokal berdasarkan indeks.
        notifyListeners(); // Beri tahu listener untuk memperbarui UI.
      }
    } catch (e) { // Menangkap error.
      debugPrint('Delete story error: $e'); // Mencetak pesan error.
    }
  }

  Future<void> toggleMyStoryPrivacy(int index) async { // Metode asinkron untuk mengubah status privasi cerita milik pengguna (publik/privat).
    if (index < 0 || index >= _myStories.length) return; // Memastikan indeks valid.
    final storyId = _myStories[index]['id']; // Mendapatkan ID cerita yang akan diubah privasinya.

    try {
      final response = await ApiService.instance.patch('/stories/$storyId/privacy', {}); // Melakukan panggilan PATCH ke endpoint untuk mengubah privasi cerita.
      if (response.statusCode == 200) { // Memeriksa apakah respons sukses.
        final data = jsonDecode(response.body); // Mendekode respons JSON.
        _myStories[index]['is_private'] = data['data']['is_private'] ? 1 : 0; // Memperbarui status privasi di daftar lokal berdasarkan respons API. 'is_private' bisa berupa boolean atau integer (1/0).
        notifyListeners(); // Beri tahu listener untuk memperbarui UI.
      }
    } catch (e) { // Menangkap error.
      debugPrint('Toggle privacy error: $e'); // Mencetak pesan error.
    }
  }
}