// Penjelasan file dan tujuannya:
// Nama file: journal_controller.dart
// Deskripsi: File ini adalah pengatur logika (otak) di balik layar UI.
// Mengarahkan ke/Keterkaitan:
// - Mengarah ke Backend/Service: Memanggil API melalui jaringan untuk mengambil/menyimpan data.
// - Berhubungan dengan Layar: Data dari sini akan ditampilkan ke layar UI (pages).

import 'dart:convert'; // Mengimpor pustaka 'dart:convert' untuk mengelola encoding dan decoding JSON.
import 'package:flutter/material.dart'; // Mengimpor pustaka 'flutter/material.dart' yang menyediakan widget-widget UI dan dasar framework Flutter, termasuk ChangeNotifier.
import '../models/journal_entry.dart'; // Mengimpor definisi model 'JournalEntry' dari jalur relatif. Model ini merepresentasikan struktur data satu entri jurnal.
import '../services/api_service.dart'; // Mengimpor 'ApiService' untuk melakukan panggilan API ke backend.

class JournalController extends ChangeNotifier { // Mendefinisikan kelas JournalController yang merupakan turunan dari ChangeNotifier. Ini memungkinkan kelas untuk memberi tahu (notify) widget-widget yang mendengarkannya (listeners) tentang perubahan data.
  List<JournalEntry> _entries = []; // Variabel privat _entries untuk menyimpan daftar semua entri jurnal. Defaultnya adalah list kosong.
  List<JournalEntry> get entries => _entries; // Getter publik untuk mengakses _entries. Mengarah ke daftar entri jurnal yang tidak difilter.

  final TextEditingController searchCtrl = TextEditingController(); // Controller untuk input teks pencarian, mengelola teks yang diketik pengguna.

  String _searchQuery = ''; // Variabel privat _searchQuery untuk menyimpan teks pencarian saat ini.
  String get searchQuery => _searchQuery; // Getter publik untuk mengakses _searchQuery.

  DateTimeRange? _filterRange; // Variabel privat _filterRange untuk menyimpan rentang tanggal yang digunakan untuk memfilter entri. Bisa bernilai null jika tidak ada filter tanggal.
  DateTimeRange? get filterRange => _filterRange; // Getter publik untuk mengakses _filterRange.

  DateTime? _customDate; // Variabel privat _customDate untuk menyimpan tanggal spesifik yang dipilih pengguna. Bisa bernilai null jika tidak ada tanggal spesifik yang dipilih.
  DateTime? get customDate => _customDate; // Getter publik untuk mengakses _customDate.

  bool _isLoading = false; // Variabel privat _isLoading untuk menunjukkan apakah data sedang dimuat dari backend (status loading).
  bool get isLoading => _isLoading; // Getter publik untuk mengakses _isLoading.

  JournalController() { // Konstruktor kelas JournalController.
    searchCtrl.addListener(() { // Menambahkan listener ke searchCtrl. Listener ini akan dipanggil setiap kali teks di searchCtrl berubah.
      _searchQuery = searchCtrl.text.trim(); // Memperbarui _searchQuery dengan teks dari searchCtrl, menghilangkan spasi di awal/akhir.
      notifyListeners(); // Memberi tahu semua widget yang mendengarkan bahwa data telah berubah, memicu rebuild UI.
    });
    fetchJournals(); // Memanggil fungsi fetchJournals() saat controller diinisialisasi untuk memuat data jurnal awal.
  }

  Future<void> fetchJournals() async { // Fungsi asinkron untuk mengambil (fetch) semua entri jurnal dari backend.
    _isLoading = true; // Mengatur status loading menjadi true.
    notifyListeners(); // Memberi tahu listener bahwa status loading telah berubah.

    try { // Memulai blok try-catch untuk menangani potensi error selama panggilan API.
      final response = await ApiService.instance.get('/journals'); // Melakukan permintaan GET ke endpoint '/journals' melalui ApiService.instance. Mengarah ke endpoint API untuk daftar jurnal.
      if (response.statusCode == 200) { // Memeriksa apakah kode status respons adalah 200 (OK).
        final data = jsonDecode(response.body); // Mengurai (decode) body respons JSON menjadi objek Dart.
        final list = data['data'] as List; // Mengambil daftar data dari kunci 'data' dalam respons.
        _entries = list.map((e) => JournalEntry.fromJson(e)).toList(); // Mengubah setiap item dalam list menjadi objek JournalEntry menggunakan konstruktor fromJson dan menyimpannya di _entries.
      }
    } catch (e) { // Menangkap error apa pun yang terjadi selama proses fetch.
      print('Fetch journals error: $e'); // Mencetak pesan error ke konsol.
    }

    _isLoading = false; // Mengatur status loading menjadi false setelah selesai (baik sukses maupun gagal).
    notifyListeners(); // Memberi tahu listener bahwa status loading telah berubah.
  }

  void setFilterRange(DateTimeRange? range) { // Fungsi untuk mengatur rentang tanggal filter.
    _filterRange = range; // Memperbarui _filterRange dengan rentang yang diberikan.
    notifyListeners(); // Memberi tahu listener untuk memperbarui UI.
  }

  void setCustomDate(DateTime date) { // Fungsi untuk mengatur tanggal kustom (spesifik).
    _customDate = date; // Memperbarui _customDate dengan tanggal yang diberikan.
    _filterRange = DateTimeRange(start: date, end: date); // Mengatur _filterRange menjadi rentang yang hanya mencakup tanggal kustom tersebut (dari awal hingga akhir hari itu).
    notifyListeners(); // Memberi tahu listener untuk memperbarui UI.
  }

  Future<void> addEntry(String title, String content, String mood) async { // Fungsi asinkron untuk menambahkan entri jurnal baru.
    try { // Memulai blok try-catch.
      final response = await ApiService.instance.post('/journals', { // Melakukan permintaan POST ke endpoint '/journals' dengan data entri baru. Mengarah ke endpoint API untuk membuat jurnal baru.
        'title': title, // Mengirim judul entri.
        'content': content, // Mengirim konten entri.
        'mood': mood, // Mengirim mood entri.
      });
      if (response.statusCode == 201) { // Memeriksa apakah kode status respons adalah 201 (Created).
        await fetchJournals(); // Jika entri berhasil ditambahkan, panggil fetchJournals() untuk memperbarui daftar entri.
      }
    } catch (e) { // Menangkap error.
      print('Add journal error: $e'); // Mencetak pesan error.
    }
  }

  Future<void> removeEntry(int id) async { // Fungsi asinkron untuk menghapus entri jurnal berdasarkan ID.
    try { // Memulai blok try-catch.
      final response = await ApiService.instance.delete('/journals/$id'); // Melakukan permintaan DELETE ke endpoint '/journals/{id}'. Mengarah ke endpoint API untuk menghapus jurnal berdasarkan ID.
      if (response.statusCode == 200) { // Memeriksa apakah kode status respons adalah 200 (OK).
        await fetchJournals(); // Jika entri berhasil dihapus, panggil fetchJournals() untuk memperbarui daftar entri.
      }
    } catch (e) { // Menangkap error.
      print('Delete journal error: $e'); // Mencetak pesan error.
    }
  }

  Future<void> updateEntry(int id, String title, String content, String mood) async { // Fungsi asinkron untuk memperbarui entri jurnal berdasarkan ID.
    try { // Memulai blok try-catch.
      final response = await ApiService.instance.put('/journals/$id', { // Melakukan permintaan PUT ke endpoint '/journals/{id}' dengan data yang diperbarui. Mengarah ke endpoint API untuk memperbarui jurnal berdasarkan ID.
        'title': title, // Mengirim judul entri yang diperbarui.
        'content': content, // Mengirim konten entri yang diperbarui.
        'mood': mood, // Mengirim mood entri yang diperbarui.
      });
      if (response.statusCode == 200) { // Memeriksa apakah kode status respons adalah 200 (OK).
        await fetchJournals(); // Jika entri berhasil diperbarui, panggil fetchJournals() untuk memperbarui daftar entri.
      }
    } catch (e) { // Menangkap error.
      print('Update journal error: $e'); // Mencetak pesan error.
    }
  }

  List<JournalEntry> get visibleEntries { // Getter yang mengembalikan daftar entri jurnal yang difilter dan dicari.
    Iterable<JournalEntry> results = _entries; // Menginisialisasi hasil dengan semua entri.
    if (_searchQuery.isNotEmpty) { // Memeriksa apakah ada query pencarian.
      final q = _searchQuery.toLowerCase(); // Mengubah query pencarian menjadi huruf kecil untuk pencarian case-insensitive.
      results = results.where( // Memfilter entri berdasarkan query pencarian.
        (e) => // Kondisi filter:
            e.title.toLowerCase().contains(q) || // Judul entri mengandung query pencarian (case-insensitive) ATAU
            e.content.toLowerCase().contains(q), // Konten entri mengandung query pencarian (case-insensitive).
      );
    }
    if (_filterRange != null) { // Memeriksa apakah ada rentang tanggal filter yang diatur.
      final start = DateTime( // Membuat objek DateTime baru untuk awal rentang filter, menghilangkan informasi waktu agar hanya membandingkan tanggal.
        _filterRange!.start.year,
        _filterRange!.start.month,
        _filterRange!.start.day,
      );
      final end = DateTime( // Membuat objek DateTime baru untuk akhir rentang filter, menghilangkan informasi waktu agar hanya membandingkan tanggal.
        _filterRange!.end.year,
        _filterRange!.end.month,
        _filterRange!.end.day,
      );
      results = results.where((e) { // Memfilter entri berdasarkan rentang tanggal.
        final d = DateTime(e.date.year, e.date.month, e.date.day); // Membuat objek DateTime baru dari tanggal entri, menghilangkan informasi waktu.
        return (d.isAtSameMomentAs(start) || d.isAfter(start)) && // Mengembalikan true jika tanggal entri sama dengan atau setelah tanggal mulai filter DAN
            (d.isAtSameMomentAs(end) || d.isBefore(end)); // Tanggal entri sama dengan atau sebelum tanggal akhir filter.
      });
    }
    return results.toList(); // Mengembalikan daftar entri yang sudah difilter dan dicari.
  }

  @override // Menandai bahwa metode ini meng-override metode dari kelas induk.
  void dispose() { // Metode ini dipanggil saat objek JournalController tidak lagi digunakan, untuk membersihkan sumber daya.
    searchCtrl.dispose(); // Membuang (dispose) TextEditingController untuk mencegah kebocoran memori.
    super.dispose(); // Memanggil metode dispose dari kelas induk (ChangeNotifier).
  }
}