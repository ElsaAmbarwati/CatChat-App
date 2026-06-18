// Penjelasan file dan tujuannya:
// Nama file: mood_tracker.dart
// Deskripsi: File ini mengatur antarmuka pengguna (UI) dan apa yang dilihat pengguna di layar.
// Mengarahkan ke/Keterkaitan:
// - Mengarah ke Layar Lain: Menggunakan navigasi (Router) saat tombol ditekan.
// - Berhubungan dengan Controller: Mengambil dan mengirim data melalui file Controller yang relevan.

import 'package:fl_chart/fl_chart.dart'; // Mengimpor library fl_chart untuk membuat grafik.
import 'package:flutter/material.dart'; // Mengimpor library Flutter untuk membangun UI.
import '../controllers/mood_tracker_controller.dart'; // Mengimpor controller yang menangani logika Mood Tracker.


// ==========================================
// Class MoodTracker
// Fungsi: Mendeklarasikan halaman/komponen visual ini.
// Mengarah ke: Biasanya dipanggil oleh router atau tombol navigasi di file lain.
// ==========================================
class MoodTracker extends StatefulWidget { // Mendefinisikan widget MoodTracker yang stateful.
  const MoodTracker({super.key}); // Konstruktor untuk MoodTracker, menerima key opsional.

  @override // Menandakan bahwa metode ini meng-override metode dari superclass.
  State<MoodTracker> createState() => _MoodTrackerState(); // Membuat state untuk MoodTracker.
}

enum _ChartType { weekly, monthly } // Mendefinisikan enum untuk membedakan jenis grafik (mingguan atau bulanan).

class _MoodTrackerState extends State<MoodTracker> { // Kelas state untuk MoodTracker.
  // Mendefinisikan konstanta warna yang digunakan dalam UI untuk konsistensi visual.
  static final Color _backgroundColor = Color(0xFFFAF4F0); // Warna latar belakang utama.
  static final Color _cardColor = Colors.white; // Warna untuk kartu atau elemen utama.
  static final Color _borderColor = Color(0xFFE7D8CF); // Warna untuk border.
  static final Color _textColor = Color(0xFF3F3734); // Warna teks utama.
  static final Color _secondaryTextColor = Color(0xFF7B6F65); // Warna teks sekunder.
  static final Color _accentColor = Color(0xFFF4B5A3); // Warna aksen.
  static final Color _softColor = Color(0xFFF7F1EE); // Warna latar belakang yang lebih lembut.

  final MoodTrackerController _controller = MoodTrackerController(); // Membuat instance dari MoodTrackerController. Controller ini akan menangani data dan logika.

  @override // Menandakan bahwa metode ini meng-override metode dari superclass.
  void dispose() { // Metode dispose dipanggil saat widget dihapus dari pohon widget.
    _controller.dispose(); // Memastikan controller juga dibuang untuk membersihkan sumber daya.
    super.dispose(); // Memanggil metode dispose dari superclass.
  }

  @override // Menandakan bahwa metode ini meng-override metode dari superclass.
  
  // Fungsi build: Bertugas menggambar (me-render) elemen visual/UI ke layar HP pengguna.
  // Menghubungkan data dari Controller ke dalam bentuk Widget (teks, tombol, gambar).
  Widget build(BuildContext context) { // Metode build untuk membangun UI widget.
    return ListenableBuilder( // ListenableBuilder digunakan untuk mendengarkan perubahan pada MoodTrackerController.
      listenable: _controller, // Menentukan objek yang dapat didengarkan (controller).
      builder: (context, _) { // Fungsi builder akan dipanggil setiap kali controller berubah.
        // Mengambil data yang sudah diolah dari controller.
        final weeklyData = _controller.buildWeeklyData(); // Membangun data grafik mingguan.
        final monthlyData = _controller.buildMonthlyData(); // Membangun data grafik bulanan.
        final averageMood = _controller.averageScore; // Mendapatkan skor rata-rata mood.
        final dominantMood = _controller.dominantMood; // Mendapatkan mood yang paling dominan.

    return Scaffold( // Scaffold adalah struktur dasar untuk layar Flutter.
      backgroundColor: _backgroundColor, // Mengatur warna latar belakang layar.
      body: SafeArea( // SafeArea memastikan konten tidak tumpang tindih dengan notch atau status bar.
        child: Padding( // Padding menambahkan ruang di sekitar konten.
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 18), // Mengatur padding horizontal dan vertikal.
          child: Column( // Column menata widget secara vertikal.
            children: [ // Daftar widget anak.
              _buildHeader(), // Memanggil metode untuk membangun bagian header.
              SizedBox(height: 14), // Menambahkan ruang vertikal.
              Expanded( // Expanded membuat widget anak mengisi ruang yang tersedia.
                child: SingleChildScrollView( // SingleChildScrollView memungkinkan konten untuk di-scroll jika tidak muat di layar.
                  child: Column( // Column lain untuk menata konten di dalam scroll view.
                    crossAxisAlignment: CrossAxisAlignment.stretch, // Merentangkan anak-anak ke lebar maksimum.
                    children: [ // Daftar widget anak di dalam scroll view.
                      _buildMoodHighlights(averageMood, dominantMood), // Membangun bagian sorotan mood (dominan dan rata-rata).
                      SizedBox(height: 12), // Menambahkan ruang vertikal.
                      _buildChartCard( // Memanggil metode untuk membangun kartu grafik mingguan.
                        title: 'Mood Mingguan', // Judul kartu.
                        subtitle: 'Rata-rata mood 7 hari terakhir.', // Subjudul kartu.
                        data: weeklyData, // Data yang akan ditampilkan di grafik.
                        color: _accentColor, // Warna utama untuk grafik ini.
                        chartType: _ChartType.weekly, // Menentukan jenis grafik adalah mingguan.
                      ),
                      SizedBox(height: 12), // Menambahkan ruang vertikal.
                      _buildChartCard( // Memanggil metode untuk membangun kartu grafik bulanan.
                        title: 'Mood Bulanan (${DateTime.now().year})', // Judul kartu, menyertakan tahun saat ini.
                        subtitle: 'Rata-rata mood 6 bulan terakhir.', // Subjudul kartu.
                        data: monthlyData, // Data yang akan ditampilkan di grafik.
                        color: Color(0xFFE6D9D2), // Warna sekunder untuk grafik ini.
                        chartType: _ChartType.monthly, // Menentukan jenis grafik adalah bulanan.
                      ),
                      SizedBox(height: 12), // Menambahkan ruang vertikal.
                      Container( // Container untuk menampilkan informasi tambahan tentang skala mood.
                        padding: EdgeInsets.all(18), // Menambahkan padding di semua sisi.
                        decoration: BoxDecoration( // Mendefinisikan tampilan visual container.
                          color: _softColor, // Mengatur warna latar belakang container.
                          borderRadius: BorderRadius.circular(24), // Membuat sudut membulat.
                          border: Border.all(color: _borderColor), // Menambahkan border.
                        ),
                        child: Row( // Row untuk menata ikon dan teks secara horizontal.
                          children: [ // Daftar widget anak.
                            Icon( // Ikon informasi.
                              Icons.info_outline, // Tipe ikon.
                              color: Color(0xFF5D4A45), // Warna ikon.
                            ),
                            SizedBox(width: 12), // Menambahkan ruang horizontal.
                            Expanded( // Expanded agar teks mengisi ruang yang tersedia.
                              child: Text( // Teks penjelasan tentang skala mood.
                                'Skala mood: 1 (Sedih/Lelah) hingga 4 (Senang). Pantau tren grafik garis untuk melihat ritme suasana hatimu.',
                                style: TextStyle( // Mengatur gaya teks.
                                  fontSize: 13, // Ukuran font.
                                  height: 1.5, // Tinggi baris untuk keterbacaan.
                                  color: _secondaryTextColor, // Warna teks.
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
        );
      },
    );
  }

  Widget _buildHeader() { // Metode untuk membangun bagian header widget.
    return Container( // Container utama untuk header.
      width: double.infinity, // Mengisi lebar penuh yang tersedia.
      padding: EdgeInsets.symmetric(vertical: 18, horizontal: 18), // Padding internal.
      decoration: BoxDecoration( // Mendefinisikan tampilan visual container.
        color: _cardColor, // Warna latar belakang header.
        borderRadius: BorderRadius.circular(24), // Sudut membulat.
        border: Border.all(color: _borderColor), // Border.
      ),
      child: Column( // Column untuk menata elemen header secara vertikal.
        crossAxisAlignment: CrossAxisAlignment.stretch, // Merentangkan anak-anak.
        children: [ // Daftar widget anak.
          Row( // Row untuk menata tombol kembali dan judul secara horizontal.
            children: [ // Daftar widget anak.
              InkWell( // Widget interaktif yang memberikan efek visual saat disentuh.
                borderRadius: BorderRadius.circular(16), // Area efek visual.
                onTap: () => // Aksi yang terjadi saat InkWell diketuk.
                    Navigator.of(context).popUntil((route) => route.isFirst), // Kembali ke halaman pertama (root) dari navigator.
                child: Container( // Container untuk tombol kembali.
                  width: 30, // Lebar tombol.
                  height: 30, // Tinggi tombol.
                  decoration: BoxDecoration( // Dekorasi tombol kembali.
                    color: _softColor, // Warna latar belakang tombol.
                    borderRadius: BorderRadius.circular(14), // Sudut membulat tombol.
                  ),
                  child: Icon(Icons.arrow_back, color: Color(0xFF5D4A45)), // Ikon panah kembali.
                ),
              ),
              SizedBox(width: 12), // Ruang horizontal antara tombol kembali dan judul.
              Expanded( // Expanded agar judul mengisi ruang yang tersedia.
                child: Text( // Teks judul "Mood Tracker".
                  'Mood Tracker',
                  style: TextStyle( // Gaya teks judul.
                    fontSize: 24, // Ukuran font.
                    fontWeight: FontWeight.bold, // Ketebalan font.
                    color: _textColor, // Warna teks.
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8), // Ruang vertikal antara baris tombol dan teks deskripsi.
          Text( // Teks deskripsi tentang fitur Mood Tracker.
            'Catat mood harianmu dalam tampilan yang lembut seperti jurnal, lengkap dengan gambar mood dan grafik tren.',
            style: TextStyle( // Gaya teks deskripsi.
              fontSize: 14, // Ukuran font.
              height: 1.6, // Tinggi baris.
              color: _secondaryTextColor, // Warna teks.
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodHighlights(double averageMood, MoodType dominantMood) { // Metode untuk membangun bagian sorotan mood.
    return Container( // Container utama untuk sorotan mood.
      padding: EdgeInsets.all(18), // Padding internal.
      decoration: BoxDecoration( // Dekorasi container.
        color: _cardColor, // Warna latar belakang.
        borderRadius: BorderRadius.circular(24), // Sudut membulat.
        border: Border.all(color: _borderColor), // Border.
      ),
      child: Row( // Row untuk menata elemen sorotan mood secara horizontal.
        children: [ // Daftar widget anak.
          Container( // Container untuk ikon mood dominan.
            width: 72, // Lebar container ikon.
            height: 72, // Tinggi container ikon.
            decoration: BoxDecoration( // Dekorasi container ikon.
              color: dominantMood.tintColor.withValues(alpha: 0.35), // Warna latar belakang ikon dengan transparansi.
              borderRadius: BorderRadius.circular(22), // Sudut membulat.
            ),
            child: Padding( // Padding di dalam container ikon.
              padding: EdgeInsets.all(12), // Padding internal.
              child: Image.asset(dominantMood.imagePath, fit: BoxFit.contain), // Menampilkan gambar ikon mood dominan.
            ),
          ),
          SizedBox(width: 14), // Ruang horizontal antara ikon dan teks.
          Expanded( // Expanded agar teks mengisi ruang yang tersedia.
            child: Column( // Column untuk menata teks sorotan mood secara vertikal.
              crossAxisAlignment: CrossAxisAlignment.start, // Meratakan teks ke kiri.
              children: [ // Daftar widget anak.
                Text( // Teks label "Mood dominan".
                  'Mood dominan',
                  style: TextStyle(fontSize: 14, color: _secondaryTextColor), // Gaya teks label.
                ),
                SizedBox(height: 4), // Ruang vertikal kecil.
                Text( // Teks nama mood dominan.
                  dominantMood.label,
                  style: TextStyle( // Gaya teks nama mood.
                    fontSize: 22, // Ukuran font.
                    fontWeight: FontWeight.w800, // Ketebalan font.
                    color: _textColor, // Warna teks.
                  ),
                ),
                SizedBox(height: 6), // Ruang vertikal.
                Text( // Teks rata-rata mood.
                  'Rata-rata mood ${averageMood.toStringAsFixed(1)} / 4',
                  style: TextStyle( // Gaya teks rata-rata mood.
                    fontSize: 13, // Ukuran font.
                    color: _secondaryTextColor, // Warna teks.
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12), // Ruang horizontal antara teks dan skor.
          Container( // Container untuk menampilkan skor rata-rata.
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10), // Padding internal.
            decoration: BoxDecoration( // Dekorasi container skor.
              color: _softColor, // Warna latar belakang.
              borderRadius: BorderRadius.circular(16), // Sudut membulat.
              border: Border.all(color: _borderColor), // Border.
            ),
            child: Column( // Column untuk menata label "Skor" dan nilai skor secara vertikal.
              crossAxisAlignment: CrossAxisAlignment.end, // Meratakan ke kanan.
              children: [ // Daftar widget anak.
                Text( // Label "Skor".
                  'Skor',
                  style: TextStyle(fontSize: 12, color: _secondaryTextColor), // Gaya teks label skor.
                ),
                SizedBox(height: 2), // Ruang vertikal kecil.
                Text( // Nilai skor rata-rata.
                  averageMood.toStringAsFixed(1),
                  style: TextStyle( // Gaya teks nilai skor.
                    fontSize: 20, // Ukuran font.
                    fontWeight: FontWeight.w800, // Ketebalan font.
                    color: _textColor, // Warna teks.
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard({ // Metode untuk membangun kartu yang berisi grafik.
    required String title, // Parameter judul kartu.
    required String subtitle, // Parameter subjudul kartu.
    required List<ChartPoint> data, // Parameter data untuk grafik. ChartPoint adalah tipe data kustom yang diasumsikan memiliki properti 'value', 'label', dan 'dateStr'.
    required Color color, // Parameter warna utama untuk grafik.
    required _ChartType chartType, // Parameter untuk menentukan apakah grafik mingguan atau bulanan.
  }) {
    return Container( // Container utama untuk kartu grafik.
      padding: EdgeInsets.all(18), // Padding internal.
      decoration: BoxDecoration( // Dekorasi container.
        color: _cardColor, // Warna latar belakang kartu.
        borderRadius: BorderRadius.circular(24), // Sudut membulat.
        border: Border.all(color: _borderColor), // Border.
      ),
      child: Column( // Column untuk menata elemen kartu secara vertikal.
        crossAxisAlignment: CrossAxisAlignment.stretch, // Merentangkan anak-anak.
        children: [ // Daftar widget anak.
          Row( // Row untuk menata ikon, judul, dan skala secara horizontal.
            children: [ // Daftar widget anak.
              Container( // Container untuk ikon mood di kartu grafik.
                width: 44, // Lebar container ikon.
                height: 44, // Tinggi container ikon.
                decoration: BoxDecoration( // Dekorasi container ikon.
                  color: _softColor, // Warna latar belakang ikon.
                  borderRadius: BorderRadius.circular(14), // Sudut membulat.
                  border: Border.all(color: _borderColor), // Border.
                ),
                child: Padding( // Padding di dalam container ikon.
                  padding: EdgeInsets.all(7), // Padding internal.
                  child: Image.asset( // Menampilkan gambar ikon berdasarkan tipe grafik.
                    chartType == _ChartType.weekly
                        ? 'assets/images/senang.png' // Gambar untuk grafik mingguan.
                        : 'assets/images/biasa_aja.png', // Gambar untuk grafik bulanan.
                    fit: BoxFit.contain, // Memastikan gambar pas di dalam container tanpa terpotong.
                  ),
                ),
              ),
              SizedBox(width: 12), // Ruang horizontal antara ikon dan teks judul.
              Expanded( // Expanded agar kolom teks mengisi ruang yang tersedia.
                child: Column( // Column untuk menata judul dan subjudul secara vertikal.
                  crossAxisAlignment: CrossAxisAlignment.start, // Meratakan teks ke kiri.
                  children: [ // Daftar widget anak.
                    Text( // Teks judul grafik.
                      title,
                      style: TextStyle( // Gaya teks judul.
                        fontSize: 16, // Ukuran font.
                        fontWeight: FontWeight.w700, // Ketebalan font.
                        color: _textColor, // Warna teks.
                      ),
                    ),
                    SizedBox(height: 4), // Ruang vertikal kecil.
                    Text( // Teks subjudul grafik.
                      subtitle,
                      style: TextStyle( // Gaya teks subjudul.
                        fontSize: 13, // Ukuran font.
                        color: _secondaryTextColor, // Warna teks.
                      ),
                    ),
                  ],
                ),
              ),
              Container( // Container untuk menampilkan skala mood (1-4).
                padding: EdgeInsets.symmetric( // Padding internal.
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration( // Dekorasi container skala.
                  color: _softColor, // Warna latar belakang.
                  borderRadius: BorderRadius.circular(999), // Membuat bentuk bulat oval.
                ),
                child: Text( // Teks skala "1 - 4".
                  '1 - 4',
                  style: TextStyle( // Gaya teks skala.
                    fontSize: 12, // Ukuran font.
                    fontWeight: FontWeight.w600, // Ketebalan font.
                    color: Color(0xFF5D4A45), // Warna teks.
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 18), // Ruang vertikal antara baris judul dan grafik.
          SizedBox(height: 240, // Menetapkan tinggi tetap untuk area grafik.
            child: LineChart( // Widget grafik garis dari fl_chart.
              LineChartData( // Konfigurasi data untuk LineChart.
                minY: 0.5, // Nilai minimum sumbu Y.
                maxY: 4.5, // Nilai maksimum sumbu Y.
                gridData: FlGridData( // Konfigurasi grid (garis bantu) pada grafik.
                  show: true, // Tampilkan grid.
                  drawVerticalLine: false, // Jangan gambar garis vertikal.
                  horizontalInterval: 1, // Interval antara garis horizontal adalah 1 unit.
                  getDrawingHorizontalLine: (value) => const FlLine( // Mengatur tampilan garis horizontal.
                    color: Color(0xFFF0E5DF), // Warna garis horizontal.
                    strokeWidth: 1, // Ketebalan garis.
                    dashArray: [4, 4], // Garis putus-putus.
                  ),
                ),
                borderData: FlBorderData(show: false), // Jangan tampilkan border grafik.
                titlesData: FlTitlesData( // Konfigurasi label sumbu (titles).
                  topTitles: const AxisTitles( // Label sumbu atas.
                    sideTitles: SideTitles(showTitles: false), // Sembunyikan label.
                  ),
                  rightTitles: const AxisTitles( // Label sumbu kanan.
                    sideTitles: SideTitles(showTitles: false), // Sembunyikan label.
                  ),
                  leftTitles: AxisTitles( // Label sumbu kiri (skala mood).
                    sideTitles: SideTitles(
                      showTitles: true, // Tampilkan label.
                      reservedSize: 44, // Ruang yang disediakan untuk label.
                      interval: 1, // Interval antar label adalah 1.
                      getTitlesWidget: (value, meta) { // Fungsi untuk membuat widget label sumbu Y.
                        if (value < 1 || value > 4 || value % 1 != 0) { // Hanya tampilkan label untuk nilai bulat antara 1 dan 4.
                          return SizedBox.shrink(); // Kembalikan widget kosong jika tidak perlu ditampilkan.
                        }
                        
                        String imgPath; // Variabel untuk path gambar mood.
                        String moodName; // Variabel untuk nama mood.
                        switch (value.toInt()) { // Menentukan gambar dan nama berdasarkan nilai sumbu Y.
                          case 1:
                            imgPath = 'assets/images/sedih.png'; // Gambar untuk mood 1.
                            moodName = 'Sedih'; // Nama mood 1.
                            break;
                          case 2:
                            imgPath = 'assets/images/capek.png'; // Gambar untuk mood 2.
                            moodName = 'Capek'; // Nama mood 2.
                            break;
                          case 3:
                            imgPath = 'assets/images/biasa_aja.png'; // Gambar untuk mood 3.
                            moodName = 'Biasa'; // Nama mood 3.
                            break;
                          case 4:
                          default: // Default untuk nilai 4 atau nilai yang tidak terduga.
                            imgPath = 'assets/images/senang.png'; // Gambar untuk mood 4.
                            moodName = 'Senang'; // Nama mood 4.
                            break;
                        }

                        return Padding( // Padding untuk menata ikon dan teks mood.
                          padding: EdgeInsets.only(right: 6), // Padding ke kanan.
                          child: Column( // Column untuk menata ikon dan teks mood secara vertikal.
                            mainAxisSize: MainAxisSize.min, // Menggunakan ukuran minimum.
                            mainAxisAlignment: MainAxisAlignment.center, // Pusatkan secara vertikal.
                            children: [ // Daftar widget anak.
                              Image.asset(imgPath, width: 20, height: 20), // Tampilkan ikon mood.
                              SizedBox(height: 2), // Ruang vertikal kecil.
                              Text( // Tampilkan nama mood.
                                moodName,
                                style: TextStyle( // Gaya teks nama mood.
                                  fontSize: 9, // Ukuran font.
                                  fontWeight: FontWeight.bold, // Ketebalan font.
                                  color: _secondaryTextColor, // Warna teks.
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles( // Label sumbu bawah (tanggal/periode).
                    sideTitles: SideTitles(
                      showTitles: true, // Tampilkan label.
                      reservedSize: 30, // Ruang yang disediakan untuk label.
                      interval: 1, // Interval antar label adalah 1.
                      getTitlesWidget: (value, meta) { // Fungsi untuk membuat widget label sumbu X.
                        final index = value.toInt(); // Konversi nilai sumbu X ke indeks.
                        if (index < 0 || index >= data.length) { // Pastikan indeks valid.
                          return SizedBox.shrink(); // Kembalikan widget kosong jika indeks tidak valid.
                        }
                        return Padding( // Padding untuk label tanggal.
                          padding: EdgeInsets.only(top: 8), // Padding ke atas.
                          child: Text( // Tampilkan label tanggal dari data.
                            data[index].label,
                            style: TextStyle( // Gaya teks label tanggal.
                              fontSize: 11, // Ukuran font.
                              fontWeight: FontWeight.w600, // Ketebalan font.
                              color: _secondaryTextColor, // Warna teks.
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                lineTouchData: LineTouchData( // Konfigurasi interaksi saat menyentuh grafik.
                  enabled: true, // Aktifkan interaksi sentuh.
                  touchTooltipData: LineTouchTooltipData( // Konfigurasi tooltip yang muncul saat disentuh.
                    getTooltipColor: (_) => Color(0xFF3F3734).withValues(alpha: 0.9), // Warna latar tooltip.
                    tooltipPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8), // Padding dalam tooltip.
                    getTooltipItems: (touchedSpots) { // Fungsi untuk mendapatkan item tooltip.
                      return touchedSpots.map((spot) { // Iterasi melalui titik yang disentuh.
                        final point = data[spot.x.toInt()]; // Ambil data titik dari list data.
                        return LineTooltipItem( // Membuat item tooltip.
                          '${point.dateStr}\n${spot.y.toStringAsFixed(1)}', // Teks tooltip: tanggal dan nilai mood.
                          TextStyle( // Gaya teks tooltip.
                            color: Colors.white, // Warna teks tooltip.
                            fontWeight: FontWeight.w600, // Ketebalan font.
                            fontSize: 12, // Ukuran font.
                          ),
                        );
                      }).toList(); // Konversi hasil map ke list.
                    },
                  ),
                ),
                lineBarsData: [ // Data untuk setiap baris dalam grafik garis.
                  LineChartBarData(
                    spots: data.asMap().entries.map((entry) { // Konversi data ke format FlSpot yang dibutuhkan LineChart.
                      return FlSpot(entry.key.toDouble(), entry.value.value); // Membuat FlSpot dari indeks (x) dan nilai (y).
                    }).toList(),
                    isCurved: true, // Buat garis melengkung.
                    curveSmoothness: 0.35, // Tingkat kelengkungan kurva.
                    color: color, // Warna garis.
                    barWidth: 4, // Ketebalan garis.
                    isStrokeCapRound: true, // Ujung garis membulat.
                    dotData: FlDotData( // Konfigurasi titik data pada garis.
                      show: true, // Tampilkan titik data.
                      getDotPainter: (spot, percent, barData, index) { // Fungsi untuk menggambar titik data.
                        return FlDotCirclePainter( // Menggunakan gambar lingkaran untuk titik.
                          radius: 5, // Radius titik.
                          color: Colors.white, // Warna dalam titik.
                          strokeWidth: 3, // Ketebalan garis tepi.
                          strokeColor: color, // Warna garis tepi titik.
                        );
                      },
                    ),
                    belowBarData: BarAreaData( // Konfigurasi area di bawah garis.
                      show: true, // Tampilkan area di bawah garis.
                      gradient: LinearGradient( // Gradasi warna untuk area di bawah garis.
                        colors: [
                          color.withValues(alpha: 0.35), // Warna gradasi awal (lebih transparan).
                          color.withValues(alpha: 0.0), // Warna gradasi akhir (transparan penuh).
                        ],
                        begin: Alignment.topCenter, // Arah gradasi dari atas.
                        end: Alignment.bottomCenter, // Arah gradasi ke bawah.
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 8), // Ruang vertikal antara grafik dan teks penjelasan.
          Text( // Teks penjelasan tentang grafik.
            chartType == _ChartType.weekly
                ? 'Grafik ini membantu melihat pola mood harian selama satu minggu terakhir.' // Penjelasan untuk grafik mingguan.
                : 'Grafik ini membantu melihat kecenderungan mood dari bulan ke bulan.', // Penjelasan untuk grafik bulanan.
            style: TextStyle( // Gaya teks penjelasan.
              fontSize: 12, // Ukuran font.
              height: 1.5, // Tinggi baris.
              color: _secondaryTextColor, // Warna teks.
            ),
          ),
        ],
      ),
    );
  }

}