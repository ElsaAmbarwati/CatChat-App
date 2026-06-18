// Penjelasan file dan tujuannya:
// Nama file: landing_page.dart
// Deskripsi: File ini mengatur antarmuka pengguna (UI) dan apa yang dilihat pengguna di layar.
// Mengarahkan ke/Keterkaitan:
// - Mengarah ke Layar Lain: Menggunakan navigasi (Router) saat tombol ditekan.
// - Berhubungan dengan Controller: Mengambil dan mengirim data melalui file Controller yang relevan.

import 'package:flutter/material.dart';
import 'register_page.dart';

// Mendefinisikan widget halaman utama (landing page) yang bersifat stateful.
// Stateful widget digunakan karena halaman ini memiliki animasi dan interaksi yang dinamis.

// ==========================================
// Class LandingPage
// Fungsi: Mendeklarasikan halaman/komponen visual ini.
// Mengarah ke: Biasanya dipanggil oleh router atau tombol navigasi di file lain.
// ==========================================
class LandingPage extends StatefulWidget {
  // Konstruktor untuk LandingPage. 'super.key' digunakan untuk meneruskan kunci ke superclass.
  const LandingPage({super.key});

  // Membuat state untuk widget LandingPage. State ini akan mengelola data dan logika widget.
  @override
  State<LandingPage> createState() => _LandingPageState();
}

// Kelas state untuk LandingPage.
class _LandingPageState extends State<LandingPage>
    with TickerProviderStateMixin { // 'with TickerProviderStateMixin' diperlukan untuk menggunakan AnimationController di dalam widget.

  // Mendeklarasikan AnimationController untuk animasi fade in/out.
  late AnimationController _fadeController;
  // Mendeklarasikan animasi untuk mengontrol tingkat transparansi (fade).
  late Animation<double> _fadeAnimation;
  // Mendeklarasikan animasi untuk pergerakan dari atas/bawah ke posisi semula (slide).
  late Animation<Offset> _slideAnimation;
  // Mendeklarasikan animasi untuk tombol agar muncul dengan fade.
  late Animation<double> _buttonFadeAnimation;
  
  // Mendeklarasikan AnimationController untuk animasi bounce (memantul).
  late AnimationController _bounceController;
  // Mendeklarasikan animasi untuk pergerakan bounce (offset).
  late Animation<Offset> _bounceAnimation;

  // Mendeklarasikan AnimationController untuk animasi latar belakang.
  late AnimationController _bgController;
  // Mendeklarasikan animasi untuk skala latar belakang (zoom in/out).
  late Animation<double> _bgScaleAnimation;

  // Mendeklarasikan ScrollController untuk mengontrol dan mendengarkan event scroll pada SingleChildScrollView.
  final ScrollController _scrollController = ScrollController();
  // Variabel boolean untuk menandakan apakah aplikasi sedang dalam proses kembali ke atas setelah scroll ke bawah.
  bool _isReturningToTop = false;

  // Metode initState dipanggil saat widget pertama kali dibuat.
  @override
  
  // Fungsi initState: Dijalankan pertama kali saat halaman ini dibuka.
  // Biasanya terhubung ke backend untuk mengambil data awal sebelum layar dimunculkan.
  void initState() {
    super.initState();
    
    // 1. Memantau seberapa jauh user nge-scroll layar
    // Menambahkan listener ke ScrollController. Fungsi _onScroll akan dipanggil setiap kali terjadi event scroll.
    _scrollController.addListener(_onScroll);
    
    // 2. Animasi Masuk (Intro): Mengatur elemen muncul pelan-pelan saat aplikasi dibuka
    // Menginisialisasi AnimationController untuk animasi fade. 'vsync: this' menghubungkannya dengan TickerProviderStateMixin.
    // 'duration' menentukan total waktu animasi.
    _fadeController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2500),
    );

    // Mengatur animasi fade in untuk elemen utama. Mulai dari 0.0 (transparan) ke 1.0 (opak).
    // 'CurvedAnimation' digunakan untuk memberikan kurva animasi yang lebih halus dan ekspresif.
    // 'Interval' menentukan kapan animasi ini aktif dalam durasi total _fadeController.
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOut), // Animasi mulai setelah 20% durasi, berakhir di 80%, dengan kurva easeOut.
      ),
    );

    // Mengatur animasi slide in untuk elemen utama. Mulai dari posisi sedikit ke bawah (0.4 dari tinggi layar) ke posisi semula (nol).
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.4), // Mulai sedikit ke bawah
      end: Offset.zero, // Berakhir di posisi asli
    ).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutExpo), // Animasi mulai dari awal, berakhir di 80% durasi, dengan kurva easeOutExpo yang lebih dinamis.
      ),
    );

    // Mengatur animasi fade in untuk tombol.
    _buttonFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeIn), // Animasi mulai di 60% durasi, berakhir di 100%, dengan kurva easeIn.
      ),
    );

    // Memulai animasi fade setelah semuanya diatur.
    _fadeController.forward();

    // 3. Animasi Panah Bawah: Bikin panahnya gerak-gerak ke bawah seakan menyuruh scroll
    // Menginisialisasi AnimationController untuk animasi bounce.
    _bounceController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    )..repeat(reverse: true); // Mengatur agar animasi berulang bolak-balik.

    // Mengatur animasi bounce: bergerak dari posisi semula ke bawah (0.3 dari tinggi layar) dan kembali lagi.
    _bounceAnimation = Tween<Offset>(
      begin: Offset.zero, // Mulai dari posisi asli
      end: Offset(0, 0.3), // Bergerak ke bawah
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.easeInOut, // Menggunakan kurva easeInOut untuk gerakan yang mulus.
    ));

    // 4. Animasi Latar Belakang (Breathing): Bikin gambar background nge-zoom pelan-pelan biar terasa hidup (efek nafas)
    // Menginisialisasi AnimationController untuk animasi latar belakang. Durasi 20 detik untuk efek yang sangat lambat.
    _bgController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 20),
    )..repeat(reverse: true); // Mengulang animasi bolak-balik untuk efek nafas.

    // Mengatur animasi skala: dari skala 1.0 ke 1.08 (sedikit membesar) dan kembali lagi.
    _bgScaleAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _bgController, curve: Curves.easeInOutSine), // Kurva easeInOutSine untuk gerakan yang halus dan sedikit bergelombang.
    );
  }

  // Metode _onScroll dipanggil setiap kali pengguna melakukan scroll.
  void _onScroll() {
    // Memeriksa apakah ScrollController memiliki klien yang aktif.
    if (!_scrollController.hasClients) return;
    
    // Mengecek apakah pengguna telah scroll melewati bagian paling bawah dari konten sebesar 50 piksel.
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent + 50) {
      // Jika pengguna telah scroll ke bawah dan belum dalam proses kembali ke atas.
      if (!_isReturningToTop) {
        // Menandai bahwa aplikasi sedang dalam proses kembali ke atas.
        _isReturningToTop = true;
        // Memanggil fungsi untuk scroll kembali ke indeks 0 (bagian paling atas).
        _scrollToIndex(0);
        
        // Setelah animasi scroll selesai (diperkirakan 1000ms), reset flag _isReturningToTop.
        Future.delayed(Duration(milliseconds: 1000), () {
          // Memastikan widget masih terpasang (mounted) sebelum mengubah state.
          if (mounted) {
            _isReturningToTop = false; // Reset flag setelah animasi selesai.
          }
        });
      }
    }
  }

  // Metode dispose dipanggil saat widget dihapus dari pohon widget.
  // Penting untuk membuang (dispose) controller animasi dan scroll controller untuk mencegah memory leaks.
  @override
  void dispose() {
    _fadeController.dispose(); // Membebaskan sumber daya _fadeController.
    _bounceController.dispose(); // Membebaskan sumber daya _bounceController.
    _bgController.dispose(); // Membebaskan sumber daya _bgController.
    _scrollController.dispose(); // Membebaskan sumber daya _scrollController.
    super.dispose(); // Memanggil dispose dari superclass.
  }

  // Fungsi untuk scroll ke indeks bagian tertentu.
  void _scrollToIndex(int index) {
    // Mendapatkan tinggi layar saat ini.
    final h = MediaQuery.of(context).size.height;
    // Menggunakan animateTo untuk scroll ke posisi yang diinginkan.
    _scrollController.animateTo(
      index * h, // Menghitung posisi scroll berdasarkan indeks dan tinggi layar. Setiap bagian memiliki tinggi layar penuh.
      duration: Duration(milliseconds: 1000), // Durasi animasi scroll.
      curve: Curves.easeOutCubic, // Kurva animasi scroll.
    );
  }

  // Metode build mendeskripsikan struktur UI dari widget ini.
  @override
  
  // Fungsi build: Bertugas menggambar (me-render) elemen visual/UI ke layar HP pengguna.
  // Menghubungkan data dari Controller ke dalam bentuk Widget (teks, tombol, gambar).
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0F0B13), // Mengatur warna latar belakang Scaffold.
      // Stack ini ibarat kue lapis. Yang ditulis pertama letaknya paling bawah (background), yang terakhir letaknya paling atas.
      body: Stack(
        fit: StackFit.expand, // Memastikan Stack mengisi seluruh area yang tersedia.
        children: [
          // Lapis 1: Gambar Background dengan efek zoom
          // Widget ScaleTransition menerapkan animasi skala (_bgScaleAnimation) pada Image.asset.
          ScaleTransition(
            scale: _bgScaleAnimation, // Menggunakan animasi skala yang dikontrol oleh _bgScaleAnimation.
            child: Image.asset(
              'assets/images/bg.jpeg', // Path ke gambar background.
              fit: BoxFit.cover, // Memastikan gambar menutupi seluruh area tanpa terpotong (mungkin ada bagian yang terpotong jika rasio berbeda).
            ),
          ),
          
          // Lapis 2: Warna gelap (Gradient) yang menutupi gambar background biar tulisannya kebaca
          // Container dengan dekorasi gradient untuk memberikan efek overlay gelap pada gambar background.
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter, // Arah awal gradient.
                end: Alignment.bottomCenter, // Arah akhir gradient.
                colors: [
                  Color(0xFF0F0B13).withOpacity(0.5), // Warna gelap di bagian atas dengan sedikit transparansi.
                  Color(0xFF0F0B13).withOpacity(0.85), // Warna lebih gelap di tengah.
                  Color(0xFF0F0B13).withOpacity(0.98), // Warna paling gelap di bagian bawah.
                ],
                stops: [0.0, 0.5, 1.0], // Posisi warna dalam gradient.
              ),
            ),
          ),

          // Lapis 3: Tiga Halaman yang bisa di-scroll ke bawah (Section 1, 2, dan 3)
          // SingleChildScrollView memungkinkan konten di dalamnya untuk di-scroll jika ukurannya melebihi layar.
          SingleChildScrollView(
            controller: _scrollController, // Menghubungkan ScrollController untuk mengontrol scroll.
            // Physics untuk scroll yang memantul (bouncing) dan selalu bisa di-scroll.
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            // Column digunakan untuk menata widget anak secara vertikal.
            child: Column(
              children: [
                // Widget _ScrollAnimatedSection digunakan untuk setiap bagian halaman yang memiliki efek animasi parallax saat di-scroll.
                _ScrollAnimatedSection(
                  scrollController: _scrollController, // Meneruskan scroll controller.
                  index: 0, // Indeks bagian ini (bagian pertama).
                  child: _buildSection1(), // Widget yang akan ditampilkan di bagian ini.
                ),
                _ScrollAnimatedSection(
                  scrollController: _scrollController, // Meneruskan scroll controller.
                  index: 1, // Indeks bagian ini (bagian kedua).
                  child: _buildSection2(), // Widget yang akan ditampilkan di bagian ini.
                ),
                _ScrollAnimatedSection(
                  scrollController: _scrollController, // Meneruskan scroll controller.
                  index: 2, // Indeks bagian ini (bagian ketiga).
                  child: _buildSection3(), // Widget yang akan ditampilkan di bagian ini.
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }

  // Metode untuk membangun bagian pertama (Section 1) dari landing page.
  Widget _buildSection1() {
    // SafeArea memastikan konten tidak tumpang tindih dengan status bar atau notch.
    return SafeArea(
      // Padding memberikan ruang di sekitar konten.
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        // Column digunakan untuk menata widget anak secara vertikal.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Pusatkan konten secara vertikal di dalam Column.
          children: [
            Spacer(), // Widget Spacer mendorong elemen lain ke atas dan bawah untuk memusatkan konten.
            
            // Animated Logo & Text
            // SlideTransition menerapkan animasi posisi (_slideAnimation) pada FadeTransition.
            SlideTransition(
              position: _slideAnimation, // Menggunakan animasi slide.
              child: FadeTransition(
                opacity: _fadeAnimation, // Menggunakan animasi fade.
                child: Column( // Column untuk mengelompokkan logo dan teks.
                  children: [
                    Image.asset(
                      'assets/images/logo2.png', // Path ke gambar logo.
                      width: 140,
                      height: 140,
                      fit: BoxFit.contain, // Memastikan logo ditampilkan sepenuhnya tanpa terpotong.
                    ),
                    SizedBox(height: 24), // Memberikan jarak vertikal.
                    Text(
                      'CATCHAT', // Teks judul aplikasi.
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900, // Ketebalan font ekstra tebal.
                        letterSpacing: 10.0, // Jarak antar huruf.
                        color: Colors.white, // Warna teks putih.
                      ),
                    ),
                    SizedBox(height: 16), // Memberikan jarak vertikal.
                    Text(
                      'Ruang aman untuk bercerita tanpa identitas.', // Teks deskripsi singkat.
                      textAlign: TextAlign.center, // Pusatkan teks.
                      style: TextStyle(
                        fontSize: 18,
                        height: 1.5, // Jarak antar baris teks.
                        color: Colors.white.withOpacity(0.8), // Warna putih dengan sedikit transparansi.
                        fontWeight: FontWeight.w400, // Ketebalan font normal.
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            Spacer(), // Spacer lainnya untuk mendorong tombol ke bawah.

            // Action Button
            // FadeTransition menerapkan animasi fade (_buttonFadeAnimation) pada Column yang berisi tombol dan indikator scroll.
            FadeTransition(
              opacity: _buttonFadeAnimation, // Menggunakan animasi fade untuk tombol.
              child: Column(
                children: [
                  ElevatedButton(
                    // Mengatur gaya tombol.
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFF4B5A3), // Warna latar tombol.
                      foregroundColor: Color(0xFF5D4A45), // Warna teks tombol.
                      minimumSize: const Size(double.infinity, 56), // Ukuran minimum tombol agar lebar penuh dan tinggi 56.
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16), // Bentuk tombol dengan sudut membulat.
                      ),
                      elevation: 8, // Bayangan tombol.
                    ),
                    // Aksi yang terjadi saat tombol ditekan.
                    onPressed: () {
                      // Ini adalah KODE NAVIGASI.
                      // Saat tombol ditekan, dia akan menghapus Landing Page (pushReplacement)
                      // dan memindahkan (mengarahkan) user ke halaman RegisterPage.
                      Navigator.pushReplacement(
                        context,
                        // PageRouteBuilder digunakan untuk membuat transisi halaman kustom.
                        PageRouteBuilder(
                          transitionDuration: Duration(milliseconds: 600), // Durasi transisi halaman.
                          // pageBuilder mendefinisikan halaman tujuan.
                          pageBuilder: (context, animation, secondaryAnimation) =>
                              const RegisterPage(), // Menuju ke RegisterPage.
                          // transitionsBuilder mendefinisikan animasi transisi.
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            // Efek pindah halamannya dibuat memudar (Fade) perlahan
                            return FadeTransition(
                              opacity: animation, // Menggunakan animasi fade dari PageRouteBuilder.
                              child: child, // Widget halaman tujuan.
                            );
                          },
                        ),
                      );
                    },
                    // Teks di dalam tombol.
                    child: Text(
                      'Mulai Perjalananmu',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold, // Ketebalan font tebal.
                        letterSpacing: 1.2, // Jarak antar huruf.
                      ),
                    ),
                  ),
                  SizedBox(height: 32), // Memberikan jarak vertikal.
                  
                  // Bouncing Scroll Indicator
                  // GestureDetector memungkinkan interaksi tap pada ikon.
                  GestureDetector(
                    onTap: () => _scrollToIndex(1), // Saat ikon ditekan, scroll ke bagian 1.
                    child: SlideTransition(
                      position: _bounceAnimation, // Menggunakan animasi bounce untuk ikon.
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded, // Ikon panah ke bawah.
                        color: Colors.white70, // Warna ikon semi-transparan putih.
                        size: 32, // Ukuran ikon.
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Metode untuk membangun bagian kedua (Section 2) dari landing page.
  Widget _buildSection2() {
    // Container untuk mengatur padding dan alignment konten.
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 40), // Padding horizontal.
      alignment: Alignment.centerLeft, // Pusatkan konten ke kiri.
      // Column untuk menata widget anak secara vertikal.
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Pusatkan konten secara vertikal.
        crossAxisAlignment: CrossAxisAlignment.start, // Pusatkan konten ke kiri secara horizontal.
        children: [
          // ShaderMask digunakan untuk menerapkan gradient pada teks.
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient( // Callback untuk membuat shader gradient.
              colors: [Color(0xFFFF8A8A), Color(0xFFF4B5A3)], // Warna gradient dari merah muda ke oranye muda.
              begin: Alignment.topLeft, // Arah awal gradient.
              end: Alignment.bottomRight, // Arah akhir gradient.
            ).createShader(bounds), // Membuat shader dari bounds widget.
            // Teks judul bagian kedua.
            child: Text(
              'Ruang Aman,\nTanpa Jejak.',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900, // Ketebalan font ekstra tebal.
                color: Colors.white, // Warna teks putih (akan ditimpa oleh shader).
                height: 1.1, // Jarak antar baris.
                letterSpacing: -1.0, // Sedikit tumpang tindih antar huruf.
                shadows: [ // Menambahkan bayangan pada teks untuk efek lebih dramatis.
                  Shadow(
                    color: Color(0xFFF4B5A3).withOpacity(0.6), // Warna bayangan.
                    blurRadius: 30, // Tingkat blur bayangan.
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 32), // Memberikan jarak vertikal.
          // Teks deskripsi untuk bagian kedua.
          Text(
            'Terkadang, hidup terasa terlalu berat untuk ditanggung sendiri. Namun, mencari tempat untuk bercerita tanpa dihakimi sangatlah sulit. Catchat hadir sebagai ruang pelarian yang aman, di mana kamu bisa membagikan keluh kesah, rahasia, dan kebahagiaanmu dengan jujur, karena di sini—identitasmu adalah misteri yang terlindungi secara mutlak.',
            style: TextStyle(
              fontSize: 20,
              color: Color(0xFFF4B5A3), // Warna teks oranye muda.
              fontWeight: FontWeight.w500, // Ketebalan font medium.
              height: 1.6, // Jarak antar baris.
            ),
          ),
          SizedBox(height: 32), // Memberikan jarak vertikal.
          // Indikator scroll ke bagian berikutnya.
          GestureDetector(
            onTap: () => _scrollToIndex(2), // Saat ikon ditekan, scroll ke bagian 2.
            child: SlideTransition(
              position: _bounceAnimation, // Menggunakan animasi bounce.
              child: Center( // Pusatkan ikon di tengah secara horizontal.
                child: Icon(
                  Icons.keyboard_arrow_down_rounded, // Ikon panah ke bawah.
                  color: Colors.white70, // Warna ikon.
                  size: 32, // Ukuran ikon.
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Metode untuk membangun bagian ketiga (Section 3) dari landing page.
  Widget _buildSection3() {
    // Container untuk mengatur padding dan alignment konten.
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 32), // Padding horizontal.
      alignment: Alignment.center, // Pusatkan konten di tengah.
      // Column untuk menata widget anak secara vertikal.
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Pusatkan konten secara vertikal.
        children: [
          // Logo aplikasi.
          Image.asset(
            'assets/images/logo2.png',
            width: 120,
            height: 120,
          ),
          SizedBox(height: 16), // Jarak vertikal.
          // Teks judul aplikasi.
          Text(
            'CATCHAT',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: 8.0,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 24), // Jarak vertikal.
          
          // Teks label "DIBUAT OLEH".
          Text(
            'DIBUAT OLEH',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: 4.0,
              color: Color(0xFFF4B5A3), // Warna oranye muda.
            ),
          ),
          SizedBox(height: 8), // Jarak vertikal.
          // Nama pembuat dengan efek gradient dan bayangan.
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFFFF8A8A), Color(0xFFFFD494)], // Warna gradient dari merah muda ke kuning muda.
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ).createShader(bounds),
            child: Text(
              'ELSA AMBARWATI',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                height: 1.1,
                letterSpacing: 2.0,
                shadows: [
                  Shadow(
                    color: Color(0xFFFFD494).withOpacity(0.6), // Warna bayangan kuning muda.
                    blurRadius: 40, // Tingkat blur bayangan.
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 32), // Jarak vertikal.
          
          // Ikon platform yang tersedia.
          Row(
            mainAxisAlignment: MainAxisAlignment.center, // Pusatkan ikon secara horizontal.
            children: [
              Icon(Icons.apple_rounded, color: Colors.white.withOpacity(0.8), size: 32), // Ikon Apple.
              SizedBox(width: 24), // Jarak antar ikon.
              Icon(Icons.android_rounded, color: Colors.white.withOpacity(0.8), size: 32), // Ikon Android.
              SizedBox(width: 24), // Jarak antar ikon.
              Icon(Icons.language_rounded, color: Colors.white.withOpacity(0.8), size: 32), // Ikon Web.
            ],
          ),
          SizedBox(height: 16), // Jarak vertikal.
          // Teks keterangan platform.
          Text(
            'Tersedia di iOS, Android, & Web',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.6), // Warna putih semi-transparan.
              fontWeight: FontWeight.w500,
              letterSpacing: 1.5, // Jarak antar huruf.
            ),
          ),
          SizedBox(height: 32), // Jarak vertikal.
          
          // Bouncing UP Arrow
          // Ikon panah ke atas untuk kembali ke bagian pertama.
          GestureDetector(
            onTap: () => _scrollToIndex(0), // Saat ikon ditekan, scroll ke bagian 0.
            child: SlideTransition(
              // Menggunakan animasi bounce yang terbalik (dari bawah ke atas) khusus untuk ikon ini.
              position: Tween<Offset>(
                begin: Offset.zero,
                end: Offset(0, -0.3), // Bergerak ke atas.
              ).animate(CurvedAnimation(
                parent: _bounceController,
                curve: Curves.easeInOut,
              )),
              child: Center( // Pusatkan ikon di tengah.
                child: Icon(
                  Icons.keyboard_arrow_up_rounded, // Ikon panah ke atas.
                  color: Colors.white70, // Warna ikon.
                  size: 32, // Ukuran ikon.
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget _ScrollAnimatedSection adalah widget kustom yang membungkus setiap bagian halaman.
// Widget ini menerapkan efek animasi parallax berdasarkan posisi scroll.

// ==========================================
// Class _ScrollAnimatedSection
// Fungsi: Mendeklarasikan halaman/komponen visual ini.
// Mengarah ke: Biasanya dipanggil oleh router atau tombol navigasi di file lain.
// ==========================================
class _ScrollAnimatedSection extends StatelessWidget {
  // ScrollController yang digunakan untuk memantau scroll.
  final ScrollController scrollController;
  // Indeks dari bagian ini dalam daftar konten yang bisa di-scroll.
  final int index;
  // Widget anak yang akan ditampilkan di dalam bagian ini.
  final Widget child;

  // Konstruktor untuk _ScrollAnimatedSection.
  const _ScrollAnimatedSection({
    required this.scrollController,
    required this.index,
    required this.child,
  });

  // Metode build mendeskripsikan struktur UI dari widget ini.
  @override
  
  // Fungsi build: Bertugas menggambar (me-render) elemen visual/UI ke layar HP pengguna.
  // Menghubungkan data dari Controller ke dalam bentuk Widget (teks, tombol, gambar).
  Widget build(BuildContext context) {
    // Mendapatkan tinggi layar.
    final h = MediaQuery.of(context).size.height;
    
    // SizedBox digunakan untuk memberikan tinggi yang tetap pada setiap bagian (tinggi layar penuh).
    return SizedBox(
      height: h,
      // AnimatedBuilder akan membangun ulang widget setiap kali animasi (dalam hal ini, scroll controller) berubah.
      child: AnimatedBuilder(
        animation: scrollController, // Mendengarkan perubahan pada scrollController.
        builder: (context, _) { // Builder function yang dijalankan saat animasi berubah.
          double offset = 0; // Variabel untuk menyimpan posisi scroll saat ini.
          // Memeriksa apakah scrollController memiliki klien yang aktif.
          if (scrollController.hasClients) {
            offset = scrollController.offset; // Mendapatkan posisi scroll saat ini.
          }

          // Menghitung seberapa jauh bagian ini dari pusat viewport.
          final centerOffset = index * h; // Posisi tengah bagian ini di layar.
          final diff = offset - centerOffset; // Perbedaan antara posisi scroll saat ini dan posisi tengah bagian ini.
          // Menghitung progress animasi: nilai antara -1.0 dan 1.0, di mana 0.0 berarti bagian ini di tengah layar.
          final progress = (diff / h).clamp(-1.0, 1.0);
          
          // Menerapkan kurva animasi (cinematic easing) pada progress untuk efek yang lebih halus.
          final curveProgress = Curves.easeOutCubic.transform(progress.abs());

          // Menghitung opacity: semakin jauh bagian ini dari tengah, semakin transparan.
          final opacity = (1.0 - curveProgress * 1.5).clamp(0.0, 1.0);

          // Menghitung translasi vertikal untuk efek parallax yang lebih dalam.
          final translateY = progress * 250.0;
          
          // Menghitung skala: bagian ini sedikit mengecil saat menjauh dari tengah.
          final scale = 1.0 - (curveProgress * 0.15);

          // Mengembalikan widget yang telah diubah dengan animasi.
          return Opacity(
            opacity: opacity, // Menerapkan transparansi.
            child: Transform.translate(
              offset: Offset(0, translateY), // Menerapkan pergerakan vertikal.
              child: Transform.scale(
                scale: scale, // Menerapkan skala.
                child: child, // Menampilkan widget anak asli.
              ),
            ),
          );
        },
      ),
    );
  }
}