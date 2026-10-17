// Penjelasan file dan tujuannya:
// Nama file: main.dart
// Deskripsi: Mengelola logika dan tampilan layar.
// Mengarahkan ke/Keterkaitan:
// Berhubungan dengan komponen atau controller lain dalam aplikasi.

import 'package:flutter/material.dart'; // Mengimpor library dasar Flutter untuk membangun UI.
import 'package:google_fonts/google_fonts.dart'; // Mengimpor Google Fonts untuk tema global

import 'pages/app_lock_page.dart'; // Mengimpor halaman kunci aplikasi. Digunakan untuk mengunci aplikasi saat kembali dari latar belakang jika ada PIN.
import 'pages/landing_page.dart'; // Mengimpor halaman awal (landing page) aplikasi. Ini adalah halaman yang dilihat pengguna jika mereka belum login atau tidak memiliki sesi aktif.
import 'services/auth_service.dart'; // Mengimpor layanan otentikasi untuk mengelola sesi pengguna. Berisi logika untuk memeriksa status login, aktivitas sesi, dan keberadaan PIN.

void main() {
  // Fungsi utama yang dijalankan saat aplikasi dimulai.
  WidgetsFlutterBinding.ensureInitialized(); // Memastikan semua binding widget Flutter telah diinisialisasi sebelum `runApp`. Ini penting agar layanan seperti `AuthService` yang mungkin bergantung pada platform dapat diakses dengan benar.
  runApp(
    const AnonHeartApp(),
  ); // Menjalankan aplikasi utama Flutter, yaitu widget `AnonHeartApp`. `const` digunakan karena `AnonHeartApp` tidak akan berubah setelah dibuat.
}

class AnonHeartApp extends StatefulWidget {
  // `AnonHeartApp` adalah root widget aplikasi. Ini adalah `StatefulWidget` karena perlu mengelola siklus hidup aplikasi dan potensi perubahan state terkait dengan observasi lifecycle.
  const AnonHeartApp({super.key}); // Konstruktor untuk `AnonHeartApp`.

  @override
  State<AnonHeartApp> createState() => _AnonHeartAppState(); // Membuat state terkait untuk `AnonHeartApp`. `StatefulWidget` memerlukan `createState()` untuk mengaitkan state yang dapat berubah.
}

class _AnonHeartAppState extends State<AnonHeartApp>
    with WidgetsBindingObserver {
  // `_AnonHeartAppState` adalah state untuk `AnonHeartApp`.
  // `with WidgetsBindingObserver` memungkinkan kelas ini untuk mendengarkan dan merespons perubahan siklus hidup aplikasi (misalnya, aplikasi masuk ke latar belakang, kembali ke latar depan).
  final GlobalKey<NavigatorState> _navigatorKey =
      GlobalKey<
        NavigatorState
      >(); // Kunci global untuk `Navigator`. Ini memungkinkan kita untuk mengakses state `Navigator` dari mana saja di dalam aplikasi, yang berguna untuk menampilkan halaman `AppLockPage` secara terprogram, bahkan ketika aplikasi di latar belakang.
  bool _wasBackgrounded =
      false; // Variabel boolean untuk melacak apakah aplikasi pernah masuk ke latar belakang sejak terakhir kali aktif. Digunakan untuk memicu logika penguncian saat kembali dari latar belakang.

  @override
  void initState() {
    // Metode ini dipanggil sekali saat `State` dibuat.
    super.initState(); // Memanggil `initState` dari kelas induk (`State`).
    WidgetsBinding.instance.addObserver(
      this,
    ); // Mendaftarkan `_AnonHeartAppState` sebagai observer ke `WidgetsBinding`. Ini akan membuat `didChangeAppLifecycleState` dipanggil saat status siklus hidup aplikasi berubah.
  }

  @override
  void dispose() {
    // Metode ini dipanggil saat `State` dihapus secara permanen dari widget tree.
    WidgetsBinding.instance.removeObserver(
      this,
    ); // Menghapus observer ini dari `WidgetsBinding` untuk mencegah kebocoran memori. Penting untuk membersihkan observer saat tidak lagi digunakan.
    super.dispose(); // Memanggil `dispose` dari kelas induk (`State`).
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Metode ini dipanggil setiap kali status siklus hidup aplikasi berubah (misalnya, aplikasi dibuka, ditutup, masuk latar belakang, kembali ke latar depan).
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      // Jika aplikasi masuk ke mode jeda (`paused`) atau tersembunyi (`hidden`), ini berarti aplikasi sedang dikirim ke latar belakang atau ditutup.
      // App was minimized or backgrounded — mark it
      _wasBackgrounded =
          true; // Menandai bahwa aplikasi telah masuk ke latar belakang.
    } else if (state == AppLifecycleState.resumed && _wasBackgrounded) {
      // Jika aplikasi kembali ke keadaan aktif (`resumed`) DAN sebelumnya telah masuk ke latar belakang (`_wasBackgrounded` bernilai true).
      // App came back from background — lock if needed
      _wasBackgrounded =
          false; // Mereset status latar belakang karena aplikasi sekarang aktif.
      _tryShowLock(); // Mencoba menampilkan halaman kunci aplikasi (`AppLockPage`) jika kondisi terpenuhi.
    }
  }

  Future<void> _tryShowLock() async {
    // Fungsi asinkron untuk memeriksa apakah halaman kunci aplikasi perlu ditampilkan saat kembali dari latar belakang.
    final isLoggedIn = await AuthService.instance
        .isSessionActive(); // Memeriksa apakah pengguna memiliki sesi otentikasi yang masih aktif menggunakan instance singleton dari `AuthService`.
    final hasPin = await AuthService.instance
        .hasPIN(); // Memeriksa apakah pengguna telah mengatur kode PIN untuk keamanan tambahan.
    if (isLoggedIn &&
        hasPin &&
        !AppLockPage.isShowing &&
        _navigatorKey.currentState != null) {
      // Kondisi untuk menampilkan halaman kunci:
      // 1. Pengguna sedang login (`isLoggedIn`).
      // 2. Pengguna telah mengatur PIN (`hasPin`).
      // 3. Halaman `AppLockPage` belum sedang ditampilkan (`!AppLockPage.isShowing`). Ini mencegah tumpukan halaman kunci yang tidak perlu.
      // 4. `navigatorKey.currentState` tidak null, artinya navigator siap digunakan.
      _navigatorKey.currentState!.push(
        // Menggunakan `navigatorKey` untuk melakukan navigasi. `push` menambahkan `AppLockPage` ke tumpukan navigasi.
        MaterialPageRoute(
          builder: (_) => const AppLockPage(
            isFromBackground: true,
          ), // Membangun instance `AppLockPage`. `isFromBackground: true` adalah flag yang mungkin digunakan di dalam `AppLockPage` untuk menyesuaikan perilakunya saat dipanggil dari latar belakang.
          fullscreenDialog:
              true, // Menampilkan `AppLockPage` sebagai dialog layar penuh, menutupi konten sebelumnya.
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Metode `build` mendefinisikan struktur widget yang akan dirender untuk `AnonHeartApp`.
    return MaterialApp(
      title:
          'Catchat', // Judul aplikasi yang ditampilkan di task switcher perangkat dan jendela browser (jika di web).
      theme: ThemeData(
        // Mengatur tema visual default untuk seluruh aplikasi.
        textTheme:
            GoogleFonts.nunitoTextTheme(), // Menerapkan font Nunito ke seluruh aplikasi.
        useMaterial3:
            true, // Mengaktifkan penggunaan pedoman Material Design 3, yang memberikan tampilan dan nuansa yang lebih modern.
        colorScheme: ColorScheme.fromSeed(
          // Membuat skema warna berdasarkan warna "seed" yang diberikan. Ini membantu menghasilkan warna-warna harmonis untuk berbagai elemen UI.
          seedColor: Color(
            0xFFF4B5A3,
          ), // Warna dasar yang digunakan untuk menghasilkan palet warna aplikasi.
          surface: Colors
              .white, // Menentukan warna dasar untuk permukaan seperti `Card` atau `Dialog`.
        ),
        scaffoldBackgroundColor: Color(
          0xFFFAF4F0,
        ), // Warna latar belakang default untuk widget `Scaffold`. Ini adalah warna latar belakang utama halaman.
        primaryColor: Color(
          0xFF5D4A45,
        ), // Warna primer aplikasi, sering digunakan untuk `AppBar` atau elemen penting lainnya (meskipun `primarySwatch` lebih umum untuk tema).
        appBarTheme: AppBarTheme(
          // Mengkonfigurasi tema default untuk `AppBar`.
          backgroundColor: Color(
            0xFFFAF4F0,
          ), // Warna latar belakang `AppBar` agar menyatu dengan `scaffoldBackgroundColor`.
          surfaceTintColor: Color(
            0xFFFAF4F0,
          ), // Warna tint yang memengaruhi bayangan `AppBar` (biasanya tidak terlihat jika elevation 0).
          foregroundColor: Colors
              .white, // Warna untuk ikon dan teks di `AppBar` (misalnya, ikon panah kembali atau judul).
          centerTitle:
              false, // Menentukan apakah judul `AppBar` harus berada di tengah (di sini disetel ke false, umumnya rata kiri).
          elevation:
              0, // Mengatur bayangan `AppBar` menjadi nol, membuatnya terlihat rata.
        ),
        cardTheme: CardThemeData(
          // Mengkonfigurasi tema default untuk widget `Card`.
          color: Colors.white, // Warna latar belakang `Card`.
          elevation: 0, // Menghilangkan bayangan `Card` agar terlihat rata.
          shape: RoundedRectangleBorder(
            // Menentukan bentuk sudut `Card`.
            borderRadius: BorderRadius.circular(
              28,
            ), // Membuat sudut `Card` sangat membulat.
            side: BorderSide(
              color: Color(0xFFE7D8CF),
            ), // Menambahkan garis tepi tipis di sekeliling `Card` dengan warna tertentu.
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          // Mengkonfigurasi tema default untuk `InputDecoration`, yang digunakan pada `TextField` dan `TextFormField`.
          filled: true, // Mengisi latar belakang area input.
          fillColor: Color(
            0xFFFAF4F0,
          ), // Menetapkan warna latar belakang untuk area input yang terisi.
          border: OutlineInputBorder(
            // Gaya border default saat widget tidak fokus.
            borderRadius: BorderRadius.circular(18), // Sudut border membulat.
            borderSide: BorderSide(color: Color(0xFFE7D8CF)), // Warna border.
          ),
          enabledBorder: OutlineInputBorder(
            // Gaya border saat widget aktif tetapi tidak fokus.
            borderRadius: BorderRadius.circular(18), // Sudut border membulat.
            borderSide: BorderSide(color: Color(0xFFE7D8CF)), // Warna border.
          ),
          focusedBorder: OutlineInputBorder(
            // Gaya border saat widget mendapatkan fokus.
            borderRadius: BorderRadius.circular(18), // Sudut border membulat.
            borderSide: BorderSide(
              color: Color(0xFFF4B5A3),
              width: 1.5,
            ), // Warna border yang berbeda dan sedikit lebih tebal saat fokus.
          ),
          contentPadding: EdgeInsets.symmetric(
            // Padding di dalam area input field, antara border dan teks.
            horizontal: 16, // Padding horizontal.
            vertical: 16, // Padding vertikal.
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          // Mengkonfigurasi tema default untuk `ElevatedButton`.
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(
              0xFFF4B5A3,
            ), // Warna latar belakang tombol (warna utama).
            foregroundColor: Color(
              0xFF5D4A45,
            ), // Warna teks dan ikon pada tombol.
            shape: RoundedRectangleBorder(
              // Bentuk tombol.
              borderRadius: BorderRadius.circular(18), // Sudut tombol membulat.
            ),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          // Mengkonfigurasi tema default untuk `SnackBar`.
          behavior: SnackBarBehavior
              .floating, // `SnackBar` akan mengambang di atas konten, bukan menempel di bagian bawah.
          backgroundColor: Color(
            0xFF5D4A45,
          ), // Warna latar belakang `SnackBar`.
          contentTextStyle: TextStyle(
            color: Colors.white,
          ), // Gaya teks konten `SnackBar`, memastikan kontras yang baik dengan latar belakang.
        ),
      ),
      navigatorKey:
          _navigatorKey, // Menghubungkan `GlobalKey` `_navigatorKey` ke `MaterialApp`. Ini memungkinkan navigasi programatik menggunakan `_navigatorKey`.
      home:
          SplashDecider(), // Menentukan halaman awal (`home`) aplikasi. `SplashDecider` akan menentukan secara dinamis apakah akan menampilkan halaman login, halaman utama, atau halaman lain.
      debugShowCheckedModeBanner:
          false, // Menyembunyikan banner debug yang muncul di sudut kanan atas aplikasi dalam mode debug.
    );
  }
}

/// Decides which page to show first based on session state.
///
/// - No session → RegisterPage (fresh install or logged out)
/// - Active session → AppLockPage (verify PIN to enter)
class SplashDecider extends StatefulWidget {
  // `SplashDecider` adalah widget yang bertugas menentukan halaman mana yang harus ditampilkan pertama kali saat aplikasi diluncurkan. Ia melakukan ini dengan memeriksa status sesi pengguna.
  const SplashDecider({super.key}); // Konstruktor untuk `SplashDecider`.

  @override
  State<SplashDecider> createState() => _SplashDeciderState(); // Membuat state terkait untuk `SplashDecider`.
}

class _SplashDeciderState extends State<SplashDecider> {
  // `_SplashDeciderState` adalah state untuk `SplashDecider`.
  @override
  void initState() {
    // Metode ini dipanggil sekali saat `State` dibuat.
    super.initState(); // Memanggil `initState` dari kelas induk (`State`).
    _decide(); // Segera memanggil fungsi `_decide` untuk memulai proses penentuan halaman tujuan.
  }

  Future<void> _decide() async {
    // Fungsi asinkron ini berisi logika untuk memeriksa status sesi dan menentukan halaman tujuan.
    final isLoggedIn = await AuthService.instance
        .isSessionActive(); // Memeriksa apakah ada sesi pengguna yang aktif menggunakan `AuthService`.
    if (!mounted)
      return; // Pemeriksaan penting: jika widget `SplashDecider` sudah tidak ada di pohon widget (misalnya, karena pengguna keluar dari aplikasi dengan cepat), hentikan eksekusi untuk menghindari error.

    Widget
    destination; // Deklarasi variabel `destination` yang akan menyimpan widget halaman tujuan.
    if (isLoggedIn) {
      // Jika `isLoggedIn` bernilai true (ada sesi aktif).
      // User has an active session → verify PIN
      destination =
          const AppLockPage(); // Menetapkan `AppLockPage` sebagai tujuan. Ini akan meminta pengguna untuk memasukkan PIN mereka untuk melanjutkan.
    } else {
      // Jika `isLoggedIn` bernilai false (tidak ada sesi aktif).
      // No session → show landing
      destination =
          const LandingPage(); // Menetapkan `LandingPage` sebagai tujuan. Ini biasanya halaman pendaftaran atau login untuk pengguna baru atau yang keluar sesi.
    }

    Navigator.of(context).pushReplacement(
      // Mengganti halaman `SplashDecider` saat ini dengan halaman `destination`. `pushReplacement` berarti `SplashDecider` tidak akan ada lagi di tumpukan navigasi, sehingga pengguna tidak bisa kembali ke layar ini dengan tombol kembali.
      PageRouteBuilder(
        // `PageRouteBuilder` digunakan untuk membuat rute kustom dengan transisi animasi.
        pageBuilder: (context, animation, secondaryAnimation) =>
            destination, // Widget yang akan ditampilkan sebagai halaman baru.
        transitionDuration: Duration(
          milliseconds: 400,
        ), // Durasi animasi transisi.
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Fungsi ini mendefinisikan bagaimana animasi transisi akan dibangun.
          return FadeTransition(
            opacity: animation,
            child: child,
          ); // Menggunakan transisi `FadeTransition` di mana halaman baru muncul secara perlahan (memudar masuk). `animation` mengontrol opacity.
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Metode `build` untuk `SplashDecider`. Ini menampilkan layar loading sementara sambil menunggu keputusan navigasi dibuat.
    // Brief splash while deciding
    return Scaffold(
      backgroundColor: Color(
        0xFFFAF4F0,
      ), // Mengatur warna latar belakang `Scaffold` agar sesuai dengan tema aplikasi.
      body: Center(
        // Memusatkan seluruh konten `body` di tengah layar.
        child: Column(
          // Mengatur widget anak secara vertikal dalam kolom.
          mainAxisSize: MainAxisSize
              .min, // Membuat kolom mengambil ukuran vertikal minimal yang diperlukan oleh anak-anaknya, sehingga konten terpusat secara vertikal dalam ruang yang tersedia.
          children: [
            Icon(
              // Menampilkan ikon hati.
              Icons.favorite_rounded, // Ikon yang dipilih dari library `Icons`.
              size: 48, // Ukuran ikon.
              color: Color(
                0xFFF4B5A3,
              ), // Warna ikon, sesuai dengan warna seed tema.
            ),
            SizedBox(
              height: 16,
            ), // Memberikan ruang kosong vertikal sebesar 16 piksel.
            Text(
              // Menampilkan teks nama aplikasi.
              'Catchat',
              style: TextStyle(
                fontSize: 24, // Ukuran font.
                fontWeight: FontWeight.w900, // Ketebalan font (sangat tebal).
                color: Color(0xFF3F3734), // Warna teks.
              ),
            ),
            SizedBox(
              height: 8,
            ), // Memberikan ruang kosong vertikal sebesar 8 piksel.
            SizedBox(
              // Membuat widget `SizedBox` yang akan menampung `CircularProgressIndicator`.
              width: 24, // Lebar `SizedBox`.
              height: 24, // Tinggi `SizedBox`.
              child: CircularProgressIndicator(
                // Menampilkan indikator progres yang berputar.
                strokeWidth: 2.4, // Ketebalan garis indikator progres.
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color(0xFFF4B5A3),
                ), // Menetapkan warna indikator progres menggunakan animasi yang selalu berhenti pada warna yang ditentukan.
              ),
            ),
          ],
        ),
      ),
    );
  }
}
