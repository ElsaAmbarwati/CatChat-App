// Penjelasan file dan tujuannya:
// Nama file: register_page.dart
// Deskripsi: File ini mengatur antarmuka pengguna (UI) dan apa yang dilihat pengguna di layar.
// Mengarahkan ke/Keterkaitan:
// - Mengarah ke Layar Lain: Menggunakan navigasi (Router) saat tombol ditekan.
// - Berhubungan dengan Controller: Mengambil dan mengirim data melalui file Controller yang relevan.

import 'package:flutter/material.dart'; // Mengimpor pustaka material design dari Flutter untuk membangun UI.

import '../controllers/register_controller.dart'; // Mengimpor RegisterController yang berisi logika bisnis untuk halaman register.
import 'login_page.dart'; // Mengimpor LoginPage, halaman tujuan setelah pendaftaran atau jika pengguna sudah memiliki akun.

// Kelas RegisterPage adalah StatefulWidget karena tampilannya dapat berubah seiring waktu (misalnya, loading state, error messages).

// ==========================================
// Class RegisterPage
// Fungsi: Mendeklarasikan halaman/komponen visual ini.
// Mengarah ke: Biasanya dipanggil oleh router atau tombol navigasi di file lain.
// ==========================================
class RegisterPage extends StatefulWidget {
  // Konstruktor untuk RegisterPage, membutuhkan `key` untuk identifikasi widget.
  const RegisterPage({super.key});

  @override
  // Membuat dan mengembalikan instance dari State untuk RegisterPage.
  State<RegisterPage> createState() => _RegisterPageState();
}

// State untuk RegisterPage, mengelola data dan lifecycle dari widget.
class _RegisterPageState extends State<RegisterPage>
    // `with SingleTickerProviderStateMixin` digunakan untuk menyediakan `Ticker` bagi animasi, seperti `AnimationController`.
    with SingleTickerProviderStateMixin {
  // Membuat instance dari RegisterController untuk mengelola logika pendaftaran dan state form.
  final RegisterController _controller = RegisterController();

  // Deklarasi AnimationController yang akan mengontrol durasi dan status animasi.
  late final AnimationController _fadeCtrl;
  // Deklarasi Animation yang akan menghitung nilai untuk efek fade berdasarkan controller.
  late final Animation<double> _fadeAnim;

  // ── Design tokens ──
  // Mendefinisikan konstanta warna untuk konsistensi desain UI.
  static const _bg = Color(0xFFFAF4F0); // Warna latar belakang utama.
  static const _card = Colors.white; // Warna untuk latar belakang kartu/form.
  static const _border = Color(0xFFE7D8CF); // Warna untuk border elemen UI.
  static const _textPrimary = Color(0xFF3F3734); // Warna teks utama.
  static const _textSecondary = Color(0xFF7B6F65); // Warna teks sekunder.
  static const _accent = Color(0xFFF4B5A3); // Warna aksen/highlight.
  static const _btnText = Color(0xFF5D4A45); // Warna teks pada tombol.
  static const _errorColor = Color(0xFFD64545); // Warna untuk pesan error.

  @override
  // Dipanggil saat State objek pertama kali dibuat. Digunakan untuk inisialisasi resources.
  
  // Fungsi initState: Dijalankan pertama kali saat halaman ini dibuka.
  // Biasanya terhubung ke backend untuk mengambil data awal sebelum layar dimunculkan.
  void initState() {
    super.initState();
    // Menginisialisasi AnimationController dengan `vsync` untuk sinkronisasi dengan frame layar
    // dan `duration` untuk menentukan lama animasi.
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 700),
    );
    // Menginisialisasi CurvedAnimation untuk memberikan kurva easing pada animasi fade,
    // membuatnya terlihat lebih natural.
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOutCubic);
    // Memulai animasi fade ke depan (opacity dari 0 ke 1).
    _fadeCtrl.forward();
  }

  @override
  // Dipanggil saat State objek dihapus secara permanen. Digunakan untuk membersihkan resources.
  void dispose() {
    // Membuang AnimationController untuk mencegah memory leak.
    _fadeCtrl.dispose();
    // Membuang RegisterController untuk membersihkan TextEditControllers dan Notifier.
    _controller.dispose();
    super.dispose();
  }

  @override
  // Metode `build` bertanggung jawab untuk membangun UI dari widget ini.
  
  // Fungsi build: Bertugas menggambar (me-render) elemen visual/UI ke layar HP pengguna.
  // Menghubungkan data dari Controller ke dalam bentuk Widget (teks, tombol, gambar).
  Widget build(BuildContext context) {
    // ListenableBuilder mendengarkan perubahan pada _controller (yang merupakan ChangeNotifier).
    // Setiap kali _controller memberitahu pendengar bahwa ada perubahan, builder akan dipanggil ulang untuk memperbarui UI.
    return ListenableBuilder(
      listenable: _controller, // Controller yang akan didengar perubahannya.
      builder: (context, _) {
        // Mengembalikan widget Scaffold yang menyediakan struktur dasar visual material design.
        return Scaffold(
      backgroundColor: _bg, // Mengatur warna latar belakang Scaffold.
      body: Stack( // Stack digunakan untuk menumpuk widget di atas satu sama lain.
        children: [
          // Background glows
          // Widget Positioned menempatkan child-nya secara eksplisit dalam Stack.
          Positioned(
            top: -56, // Posisi dari atas.
            left: -44, // Posisi dari kiri.
            child: _Glow(size: 180, color: Color(0xFFFFD9C8)), // Menampilkan efek glow di latar belakang.
          ),
          Positioned(
            top: 120, // Posisi dari atas.
            right: -60, // Posisi dari kanan.
            child: _Glow(size: 160, color: Color(0xFFFFC3A8)), // Menampilkan efek glow kedua.
          ),
          Positioned(
            bottom: -70, // Posisi dari bawah.
            left: -40, // Posisi dari kiri.
            child: _Glow(size: 220, color: Color(0xFFF6D2C0)), // Menampilkan efek glow ketiga.
          ),
          // SafeArea memastikan konten UI tidak tertutup oleh notch, status bar, atau navigasi sistem.
          SafeArea(
            child: LayoutBuilder( // LayoutBuilder memungkinkan kita untuk membangun widget berdasarkan ukuran dari parent.
              builder: (context, constraints) {
                // Menghitung lebar konten utama. Jika lebar layar < 520, gunakan lebar layar, jika tidak gunakan 520.0 (untuk responsif).
                final w =
                    constraints.maxWidth < 520.0 ? constraints.maxWidth : 520.0;
                return Center( // Menempatkan child-nya di tengah layar.
                  child: ConstrainedBox( // ConstrainedBox memberikan batasan pada ukuran child-nya.
                    constraints: BoxConstraints(maxWidth: w), // Batasan lebar maksimum.
                    child: FadeTransition( // FadeTransition menerapkan animasi fade (memudar masuk/keluar) pada child-nya.
                      opacity: _fadeAnim, // Menggunakan _fadeAnim untuk mengontrol opacity.
                      child: SingleChildScrollView( // Memungkinkan konten di dalamnya dapat discroll jika melebihi tinggi layar.
                        padding: EdgeInsets.all(20), // Padding di sekitar konten yang dapat discroll.
                        child: Column( // Column menyusun widget secara vertikal.
                          crossAxisAlignment: CrossAxisAlignment.stretch, // Mengisi lebar yang tersedia.
                          children: [
                            _buildBrandHeader(), // Membangun bagian header merek/logo aplikasi.
                            SizedBox(height: 14), // Memberikan spasi vertikal.
                            _buildFormCard(), // Membangun bagian kartu form pendaftaran.
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
      },
    );
  }

  // Widget privat untuk membangun header merek aplikasi.
  Widget _buildBrandHeader() {
    return Row( // Row menyusun widget secara horizontal.
      children: [
        Container( // Container untuk ikon aplikasi.
          width: 48, // Lebar container.
          height: 48, // Tinggi container.
          decoration: BoxDecoration( // Dekorasi untuk container (warna, bentuk, border, shadow).
            color: Colors.white, // Warna latar belakang ikon.
            shape: BoxShape.circle, // Bentuk lingkaran.
            border: Border.all(color: _accent.withValues(alpha: 0.35)), // Border dengan warna aksen semi-transparan.
            boxShadow: [ // Efek shadow di bawah ikon.
              BoxShadow(
                color: Color(0x1A5D4A45), // Warna shadow.
                blurRadius: 18, // Tingkat blur shadow.
                offset: Offset(0, 8), // Offset shadow (x, y).
              ),
            ],
          ),
          child: Icon(Icons.favorite_rounded, color: _accent), // Ikon di dalam container.
        ),
        SizedBox(width: 14), // Spasi horizontal.
        Expanded( // Expanded mengambil semua ruang horizontal yang tersisa di dalam Row.
          child: Column( // Column untuk menyusun teks merek dan slogan secara vertikal.
            crossAxisAlignment: CrossAxisAlignment.start, // Menyusun teks ke kiri.
            children: [
              Text( // Teks nama aplikasi.
                'Catchat',
                style: TextStyle(
                  fontSize: 18, // Ukuran font.
                  fontWeight: FontWeight.w900, // Ketebalan font (ultra bold).
                  color: _textPrimary, // Warna teks.
                ),
              ),
              SizedBox(height: 2), // Spasi vertikal.
              Text( // Teks slogan aplikasi.
                'Buat akun baru, mulai perjalananmu',
                style: TextStyle(fontSize: 13, color: _textSecondary), // Ukuran dan warna teks.
              ),
            ],
          ),
        ),
        Container( // Container untuk badge "Register".
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8), // Padding horizontal dan vertikal.
          decoration: BoxDecoration( // Dekorasi untuk badge.
            color: Color(0xFFFFF4EF), // Warna latar belakang badge.
            borderRadius: BorderRadius.circular(999), // Border radius sangat besar untuk bentuk pill.
            border: Border.all(color: Color(0xFFE8D6CB)), // Border badge.
          ),
          child: Text( // Teks "Register" di dalam badge.
            'Register',
            style: TextStyle(
              fontSize: 12, // Ukuran font.
              fontWeight: FontWeight.w700, // Ketebalan font.
              color: Color(0xFF7A4028), // Warna teks.
            ),
          ),
        ),
      ],
    );
  }

  // Widget privat untuk membangun kartu form pendaftaran.
  Widget _buildFormCard() {
    return Container( // Container utama untuk kartu form.
      padding: EdgeInsets.all(18), // Padding di dalam container.
      decoration: BoxDecoration( // Dekorasi container (warna, border radius, border, shadow).
        color: _card, // Warna latar belakang kartu.
        borderRadius: BorderRadius.circular(34), // Border radius untuk sudut membulat.
        border: Border.all(color: _border), // Border kartu.
        boxShadow: [ // Efek shadow di bawah kartu.
          BoxShadow(
            color: Color(0x1A5D4A45), // Warna shadow.
            blurRadius: 30, // Tingkat blur shadow.
            offset: Offset(0, 18), // Offset shadow.
          ),
        ],
      ),
      child: Column( // Column menyusun semua field form secara vertikal.
        crossAxisAlignment: CrossAxisAlignment.stretch, // Mengisi lebar yang tersedia.
        children: [

          // TextField untuk input email.
          TextField(
            controller: _controller.emailCtrl, // Menggunakan controller dari RegisterController untuk mengelola teks.
            keyboardType: TextInputType.emailAddress, // Menyetel keyboard untuk input email.
            textInputAction: TextInputAction.next, // Aksi 'next' pada keyboard, akan fokus ke field selanjutnya.
            decoration: const InputDecoration( // Dekorasi input field.
              labelText: 'Email', // Label untuk field.
              prefixIcon: Icon(Icons.email_outlined), // Ikon di awal field.
            ),
          ),
          SizedBox(height: 12), // Spasi vertikal.

          // TextField untuk input username.
          TextField(
            controller: _controller.usernameCtrl, // Controller untuk username.
            textInputAction: TextInputAction.next, // Aksi 'next' pada keyboard.
            decoration: InputDecoration( // Dekorasi input field.
              labelText: 'Username (Nama Samaran)', // Label field.
              prefixIcon: Icon(Icons.person_outline_rounded), // Ikon di awal field.
              suffixIcon: IconButton( // Ikon tombol di akhir field.
                tooltip: 'Buat nama acak', // Tooltip saat hover/long press.
                icon: Icon(Icons.casino_outlined, color: _accent), // Ikon dadu dengan warna aksen.
                onPressed: _controller.generateAnonName, // Memanggil metode untuk menghasilkan nama acak.
              ),
            ),
          ),
          SizedBox(height: 12), // Spasi vertikal.

          // TextField untuk input password.
          TextField(
            controller: _controller.passwordCtrl, // Controller untuk password.
            obscureText: _controller.obscure, // Mengaburkan teks jika `_controller.obscure` true.
            textInputAction: TextInputAction.next, // Aksi 'next' pada keyboard.
            decoration: InputDecoration( // Dekorasi input field.
              labelText: 'Password', // Label field.
              prefixIcon: Icon(Icons.lock_outline_rounded), // Ikon gembok.
              suffixIcon: IconButton( // Tombol untuk toggle visibilitas password.
                onPressed: _controller.toggleObscure, // Memanggil metode untuk mengubah status obscure.
                icon: Icon(
                  // Menampilkan ikon mata terbuka atau tertutup berdasarkan status obscure.
                  _controller.obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: _textSecondary, // Warna ikon.
                ),
              ),
            ),
          ),
          SizedBox(height: 12), // Spasi vertikal.

          // TextField untuk konfirmasi password.
          TextField(
            controller: _controller.confirmCtrl, // Controller untuk konfirmasi password.
            obscureText: _controller.obscureConfirm, // Mengaburkan teks jika `_controller.obscureConfirm` true.
            textInputAction: TextInputAction.done, // Aksi 'done' pada keyboard, menandakan akhir input.
            onSubmitted: (_) => _controller.submit(context), // Memanggil metode submit saat keyboard "done" ditekan.
            decoration: InputDecoration( // Dekorasi input field.
              labelText: 'Konfirmasi Password', // Label field.
              prefixIcon: Icon(Icons.verified_outlined), // Ikon verifikasi.
              suffixIcon: IconButton( // Tombol untuk toggle visibilitas konfirmasi password.
                onPressed: _controller.toggleObscureConfirm, // Memanggil metode untuk mengubah status obscure konfirmasi.
                icon: Icon(
                  // Menampilkan ikon mata terbuka atau tertutup.
                  _controller.obscureConfirm
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: _textSecondary, // Warna ikon.
                ),
              ),
            ),
          ),

          // Kondisional: Menampilkan pesan error jika ada error (_controller.error tidak null).
          if (_controller.error != null) ...[
            SizedBox(height: 12), // Spasi vertikal sebelum pesan error.
            Container( // Container untuk tampilan pesan error.
              padding: EdgeInsets.all(12), // Padding di dalam container.
              decoration: BoxDecoration( // Dekorasi container error.
                color: _errorColor.withValues(alpha: 0.08), // Latar belakang error semi-transparan.
                borderRadius: BorderRadius.circular(14), // Sudut membulat.
                border: Border.all(color: _errorColor.withValues(alpha: 0.25)), // Border error semi-transparan.
              ),
              child: Row( // Row untuk menyusun ikon dan teks error secara horizontal.
                children: [
                  Icon(Icons.error_outline, color: _errorColor, size: 18), // Ikon error.
                  SizedBox(width: 8), // Spasi horizontal.
                  Expanded( // Mengambil sisa ruang horizontal untuk teks.
                    child: Text( // Teks pesan error.
                      _controller.error!, // Menampilkan pesan error dari controller.
                      style: TextStyle(
                        fontSize: 13, // Ukuran font.
                        color: _errorColor, // Warna teks error.
                        fontWeight: FontWeight.w600, // Ketebalan font.
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          SizedBox(height: 16), // Spasi vertikal.

          // Tombol submit untuk mendaftar.
          SizedBox(height: 52, // Tinggi tombol.
            child: ElevatedButton( // Tombol dengan gaya yang ditinggikan.
              // Tombol dinonaktifkan jika _controller.loading true (sedang memproses pendaftaran).
              onPressed: _controller.loading ? null : () => _controller.submit(context), // Memanggil metode submit saat tombol ditekan.
              style: ElevatedButton.styleFrom( // Gaya kustom untuk ElevatedButton.
                backgroundColor: _accent, // Warna latar belakang tombol.
                foregroundColor: _btnText, // Warna teks dan ikon pada tombol.
                shape: RoundedRectangleBorder( // Bentuk tombol dengan sudut membulat.
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: _controller.loading // Konten tombol: CircularProgressIndicator jika loading, atau teks "Daftar Sekarang".
                  ? SizedBox(width: 22, // Lebar indicator.
                      height: 22, // Tinggi indicator.
                      child: CircularProgressIndicator( // Indikator loading berbentuk lingkaran.
                        strokeWidth: 2.4, // Ketebalan garis.
                        valueColor: AlwaysStoppedAnimation<Color>(_btnText), // Warna indikator.
                      ),
                    )
                  : Text( // Teks tombol jika tidak loading.
                      'Daftar Sekarang',
                      style: TextStyle(
                        fontSize: 15, // Ukuran font.
                        fontWeight: FontWeight.w700, // Ketebalan font.
                      ),
                    ),
            ),
          ),
          SizedBox(height: 14), // Spasi vertikal.

          // Link untuk navigasi ke halaman login.
          Center( // Menempatkan child di tengah secara horizontal.
            child: GestureDetector( // Mendeteksi gesture tap pada child.
              onTap: () {
                // Navigasi ke LoginPage saat teks "Login" ditekan.
                // `pushReplacement` digunakan agar halaman register tidak bisa di-back lagi setelah login.
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginPage()), // Rute menuju LoginPage.
                );
              },
              child: RichText( // Menampilkan teks dengan gaya yang berbeda dalam satu baris.
                text: TextSpan( // Span teks utama.
                  style: TextStyle(fontSize: 13.5, color: _textSecondary), // Gaya teks default.
                  children: [
                    TextSpan(text: 'Sudah punya akun? '), // Bagian teks pertama.
                    TextSpan( // Bagian teks "Login" dengan gaya berbeda.
                      text: 'Login',
                      style: TextStyle(
                        fontWeight: FontWeight.w800, // Lebih tebal.
                        color: _btnText, // Warna teks tombol.
                        decoration: TextDecoration.underline, // Garis bawah.
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),


        ],
      ),
    );
  }
}

// Widget privat `_Glow` untuk menciptakan efek glow lingkaran di latar belakang.

// ==========================================
// Class _Glow
// Fungsi: Mendeklarasikan halaman/komponen visual ini.
// Mengarah ke: Biasanya dipanggil oleh router atau tombol navigasi di file lain.
// ==========================================
class _Glow extends StatelessWidget {
  final double size; // Ukuran (lebar dan tinggi) glow.
  final Color color; // Warna dasar glow.

  // Konstruktor untuk _Glow, membutuhkan size dan color.
  const _Glow({required this.size, required this.color});

  @override
  
  // Fungsi build: Bertugas menggambar (me-render) elemen visual/UI ke layar HP pengguna.
  // Menghubungkan data dari Controller ke dalam bentuk Widget (teks, tombol, gambar).
  Widget build(BuildContext context) {
    return Container( // Container sebagai dasar untuk efek glow.
      width: size, // Mengatur lebar container.
      height: size, // Mengatur tinggi container.
      decoration: BoxDecoration( // Dekorasi container.
        shape: BoxShape.circle, // Bentuk lingkaran.
        gradient: RadialGradient( // Gradient radial untuk efek memudar dari tengah ke tepi.
          colors: [color.withValues(alpha: 0.8), color.withValues(alpha: 0.0)], // Warna glow (dari pekat ke transparan).
        ),
      ),
    );
  }
}