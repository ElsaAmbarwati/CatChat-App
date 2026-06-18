// Penjelasan file dan tujuannya:
// Nama file: login_page.dart
// Deskripsi: File ini mengatur antarmuka pengguna (UI) dan apa yang dilihat pengguna di layar.
// Mengarahkan ke/Keterkaitan:
// - Mengarah ke Layar Lain: Menggunakan navigasi (Router) saat tombol ditekan.
// - Berhubungan dengan Controller: Mengambil dan mengirim data melalui file Controller yang relevan.

import 'package:flutter/material.dart'; // Mengimpor paket dasar Flutter untuk membangun UI.

import '../controllers/login_controller.dart'; // Mengimpor LoginController dari direktori '../controllers/' untuk mengelola logika login.
import 'register_page.dart'; // Mengimpor RegisterPage dari direktori yang sama untuk navigasi ke halaman pendaftaran.

// Mendefinisikan widget LoginPage sebagai StatefulWidget karena akan memiliki state yang bisa berubah.

// ==========================================
// Class LoginPage
// Fungsi: Mendeklarasikan halaman/komponen visual ini.
// Mengarah ke: Biasanya dipanggil oleh router atau tombol navigasi di file lain.
// ==========================================
class LoginPage extends StatefulWidget {
  const LoginPage({super.key}); // Konstruktor untuk LoginPage, dengan key opsional.

  @override
  // Membuat instance dari state terkait untuk widget ini.
  State<LoginPage> createState() => _LoginPageState(); // Mengembalikan sebuah instance dari _LoginPageState.
}

// State class untuk LoginPage.
// 'with SingleTickerProviderStateMixin' digunakan untuk menyediakan 'vsync' yang diperlukan oleh AnimationController.
class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  // Membuat instance dari LoginController untuk mengelola logika bisnis dan state halaman login.
  final LoginController _controller = LoginController();

  // Mendeklarasikan AnimationController yang akan mengontrol durasi dan status animasi.
  late final AnimationController _fadeCtrl;
  // Mendeklarasikan Animation yang akan menentukan nilai animasi (misalnya, opasitas).
  late final Animation<double> _fadeAnim;

  // Mendefinisikan konstanta warna yang akan digunakan di seluruh halaman login untuk konsistensi UI.
  static const _bg = Color(0xFFFAF4F0); // Warna latar belakang utama.
  static const _card = Colors.white; // Warna untuk kartu atau panel.
  static const _border = Color(0xFFE7D8CF); // Warna untuk border elemen UI.
  static const _textPrimary = Color(0xFF3F3734); // Warna teks utama.
  static const _textSecondary = Color(0xFF7B6F65); // Warna teks sekunder.
  static const _accent = Color(0xFFF4B5A3); // Warna aksen untuk elemen interaktif.
  static const _btnText = Color(0xFF5D4A45); // Warna teks tombol.
  static const _errorColor = Color(0xFFD64545); // Warna untuk pesan error.

  @override
  // Dipanggil saat State object ini pertama kali dibuat.
  
  // Fungsi initState: Dijalankan pertama kali saat halaman ini dibuka.
  // Biasanya terhubung ke backend untuk mengambil data awal sebelum layar dimunculkan.
  void initState() {
    super.initState(); // Memanggil initState dari kelas induk.
    // Menginisialisasi AnimationController dengan 'vsync' (dari SingleTickerProviderStateMixin) dan durasi animasi.
    _fadeCtrl = AnimationController(
      vsync: this, // Membutuhkan TickerProvider untuk tick animasi.
      duration: Duration(milliseconds: 700), // Durasi total animasi fade.
    );
    // Membuat CurvedAnimation yang menggunakan _fadeCtrl sebagai parent dan Curves.easeOutCubic untuk efek transisi.
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOutCubic);
    _fadeCtrl.forward(); // Memulai animasi fade maju (dari 0 ke 1).
  }

  @override
  // Dipanggil saat State object ini dihapus secara permanen dari pohon widget.
  void dispose() {
    _fadeCtrl.dispose(); // Melepaskan sumber daya AnimationController untuk mencegah kebocoran memori.
    _controller.dispose(); // Melepaskan sumber daya LoginController.
    super.dispose(); // Memanggil dispose dari kelas induk.
  }


  @override
  // Metode build bertanggung jawab untuk mendeskripsikan bagian dari UI yang direpresentasikan oleh widget ini.
  
  // Fungsi build: Bertugas menggambar (me-render) elemen visual/UI ke layar HP pengguna.
  // Menghubungkan data dari Controller ke dalam bentuk Widget (teks, tombol, gambar).
  Widget build(BuildContext context) {
    // ListenableBuilder digunakan untuk membangun UI secara reaktif terhadap perubahan pada _controller.
    // Ketika _controller memanggil notifyListeners(), builder akan dipanggil ulang.
    return ListenableBuilder(
      listenable: _controller, // Mendengarkan perubahan pada LoginController.
      builder: (context, _) { // Builder function yang akan membangun kembali UI saat ada perubahan.
        return Scaffold( // Widget dasar untuk struktur visual material design.
          backgroundColor: _bg, // Mengatur warna latar belakang Scaffold menggunakan konstanta _bg.
      body: Stack( // Stack digunakan untuk menumpuk widget di atas satu sama lain.
        children: [
          // Widget Positioned menempatkan widget anak pada posisi tertentu relatif terhadap Stack.
          // Ini adalah elemen dekoratif berbentuk cahaya (glow) di pojok kiri atas.
          Positioned(
            top: -56, // Posisi atas relatif terhadap Stack.
            left: -44, // Posisi kiri relatif terhadap Stack.
            child: _Glow(size: 180, color: Color(0xFFFFD9C8)), // Menggunakan widget _Glow dengan ukuran dan warna tertentu.
          ),
          // Elemen dekoratif glow di pojok kanan atas.
          Positioned(
            top: 120, // Posisi atas.
            right: -60, // Posisi kanan.
            child: _Glow(size: 160, color: Color(0xFFFFC3A8)), // Glow dengan ukuran dan warna berbeda.
          ),
          // Elemen dekoratif glow di pojok kiri bawah.
          Positioned(
            bottom: -70, // Posisi bawah.
            left: -40, // Posisi kiri.
            child: _Glow(size: 220, color: Color(0xFFF6D2C0)), // Glow dengan ukuran dan warna berbeda.
          ),
          // SafeArea memastikan bahwa konten tidak tumpang tindih dengan bagian OS seperti status bar atau notch.
          SafeArea(
            child: LayoutBuilder( // LayoutBuilder digunakan untuk mendapatkan batasan (constraints) dari parent.
              builder: (context, constraints) { // Builder function yang menyediakan BuildContext dan BoxConstraints.
                // Menentukan lebar maksimum konten, menjadikannya responsif.
                // Jika lebar layar kurang dari 520.0, gunakan lebar layar; jika tidak, batasi hingga 520.0.
                final w =
                    constraints.maxWidth < 520.0 ? constraints.maxWidth : 520.0;
                return Center( // Memusatkan widget anak.
                  child: ConstrainedBox( // Membatasi ukuran widget anak.
                    constraints: BoxConstraints(maxWidth: w), // Mengatur lebar maksimum berdasarkan perhitungan 'w'.
                    child: FadeTransition( // Menerapkan efek fade in pada widget anak.
                      opacity: _fadeAnim, // Menggunakan _fadeAnim untuk mengontrol opasitas.
                      child: SingleChildScrollView( // Memungkinkan konten untuk di-scroll jika melebihi ukuran layar.
                        padding: EdgeInsets.all(20), // Memberi padding 20 di sekeliling konten.
                        child: Column( // Mengatur widget anak secara vertikal.
                          crossAxisAlignment: CrossAxisAlignment.stretch, // Meregangkan anak-anak secara horizontal.
                          children: [
                            _buildBrandHeader(), // Memanggil metode untuk membangun header merek.
                            SizedBox(height: 14), // Memberi jarak vertikal 14 piksel.
                            _buildFormCard(), // Memanggil metode untuk membangun kartu formulir login.
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

  // Metode untuk membangun bagian header merek (logo, nama aplikasi, pesan selamat datang, dan label "Login").
  Widget _buildBrandHeader() {
    return Row( // Mengatur widget anak secara horizontal.
      children: [
        Container( // Wadah untuk ikon aplikasi.
          width: 48, // Lebar container.
          height: 48, // Tinggi container.
          decoration: BoxDecoration( // Dekorasi untuk container.
            color: Colors.white, // Warna latar belakang putih.
            shape: BoxShape.circle, // Bentuk lingkaran.
            border: Border.all(color: _accent.withOpacity(0.35)), // Border dengan warna aksen dan opasitas 0.35.
            boxShadow: [ // Menambahkan efek bayangan.
              BoxShadow(
                color: Color(0x1A5D4A45), // Warna bayangan dengan opasitas.
                blurRadius: 18, // Tingkat blur bayangan.
                offset: Offset(0, 8), // Posisi offset bayangan.
              ),
            ],
          ),
          child: Icon(Icons.favorite_rounded, color: _accent), // Ikon hati dengan warna aksen.
        ),
        SizedBox(width: 14), // Memberi jarak horizontal 14 piksel.
        Expanded( // Mengambil sisa ruang horizontal yang tersedia.
          child: Column( // Mengatur teks secara vertikal.
            crossAxisAlignment: CrossAxisAlignment.start, // Menyusun teks ke kiri.
            children: [
              Text( // Teks nama aplikasi.
                'Catchat',
                style: TextStyle(
                  fontSize: 18, // Ukuran font.
                  fontWeight: FontWeight.w900, // Ketebalan font (ultra-bold).
                  color: _textPrimary, // Warna teks utama.
                ),
              ),
              SizedBox(height: 2), // Memberi jarak vertikal 2 piksel.
              Text( // Teks pesan selamat datang.
                'Selamat datang kembali',
                style: TextStyle(fontSize: 13, color: _textSecondary), // Ukuran font dan warna teks sekunder.
              ),
            ],
          ),
        ),
        Container( // Wadah untuk label "Login".
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8), // Padding horizontal dan vertikal.
          decoration: BoxDecoration( // Dekorasi untuk container.
            color: Color(0xFFFFF4EF), // Warna latar belakang.
            borderRadius: BorderRadius.circular(999), // Bentuk sudut sangat membulat (pill-shaped).
            border: Border.all(color: Color(0xFFE8D6CB)), // Border dengan warna tertentu.
          ),
          child: Text( // Teks "Login".
            'Login',
            style: TextStyle(
              fontSize: 12, // Ukuran font.
              fontWeight: FontWeight.w700, // Ketebalan font (bold).
              color: Color(0xFF7A4028), // Warna teks.
            ),
          ),
        ),
      ],
    );
  }

  // Metode untuk membangun kartu formulir login (input email, password, tombol login, dan link daftar).
  Widget _buildFormCard() {
    return Container( // Wadah untuk formulir.
      padding: EdgeInsets.all(18), // Padding di sekeliling konten.
      decoration: BoxDecoration( // Dekorasi untuk container (kartu).
        color: _card, // Warna latar belakang kartu (putih).
        borderRadius: BorderRadius.circular(34), // Sudut yang sangat membulat.
        border: Border.all(color: _border), // Border dengan warna tertentu.
        boxShadow: [ // Menambahkan efek bayangan.
          BoxShadow(
            color: Color(0x1A5D4A45), // Warna bayangan dengan opasitas.
            blurRadius: 30, // Tingkat blur bayangan.
            offset: Offset(0, 18), // Posisi offset bayangan.
          ),
        ],
      ),
      child: Column( // Mengatur elemen formulir secara vertikal.
        crossAxisAlignment: CrossAxisAlignment.stretch, // Meregangkan anak-anak secara horizontal.
        children: [

          // Bagian input Email
          TextField( // Widget input teks untuk email.
            controller: _controller.emailCtrl, // Mengikat controller ini ke TextEditingController di LoginController.
            keyboardType: TextInputType.emailAddress, // Mengatur keyboard untuk input email.
            textInputAction: TextInputAction.next, // Aksi tombol "Enter" di keyboard akan mengarahkan ke input berikutnya.
            decoration: const InputDecoration( // Dekorasi input field.
              labelText: 'Email', // Label untuk input field.
              prefixIcon: Icon(Icons.email_outlined), // Ikon di awal input field.
            ),
          ),
          SizedBox(height: 12), // Memberi jarak vertikal 12 piksel.

          // Bagian input Password
          TextField( // Widget input teks untuk password.
            controller: _controller.passwordCtrl, // Mengikat controller ini ke TextEditingController di LoginController.
            obscureText: _controller.obscure, // Mengatur apakah teks harus disembunyikan (untuk password), nilainya dari controller.
            textInputAction: TextInputAction.done, // Aksi tombol "Enter" di keyboard akan mengindikasikan selesai.
            onSubmitted: (_) => _controller.submit(context), // Dipanggil ketika tombol "Done" di keyboard ditekan, memanggil submit di controller.
            decoration: InputDecoration( // Dekorasi input field.
              labelText: 'Password', // Label untuk input field.
              prefixIcon: Icon(Icons.lock_outline_rounded), // Ikon kunci di awal input field.
              suffixIcon: IconButton( // Ikon di akhir input field yang bisa ditekan.
                onPressed: _controller.toggleObscure, // Memanggil metode toggleObscure di controller saat ikon ditekan.
                icon: Icon( // Ikon untuk menampilkan/menyembunyikan password.
                  _controller.obscure // Jika password disembunyikan, tampilkan ikon mata terbuka.
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined, // Jika password terlihat, tampilkan ikon mata tertutup.
                  color: _textSecondary, // Warna ikon.
                ),
              ),
            ),
          ),

          // Kondisi untuk menampilkan pesan error jika ada error.
          if (_controller.error != null) ...[ // Operator spread (...) digunakan untuk menambahkan daftar widget secara kondisional.
            SizedBox(height: 12), // Memberi jarak vertikal 12 piksel.
            Container( // Wadah untuk menampilkan pesan error.
              padding: EdgeInsets.all(12), // Padding di sekeliling teks error.
              decoration: BoxDecoration( // Dekorasi container error.
                color: _errorColor.withOpacity(0.08), // Warna latar belakang error dengan opasitas rendah.
                borderRadius: BorderRadius.circular(14), // Sudut membulat.
                border: Border.all(color: _errorColor.withOpacity(0.25)), // Border error dengan opasitas.
              ),
              child: Row( // Mengatur ikon dan teks error secara horizontal.
                children: [
                  Icon(Icons.error_outline, color: _errorColor, size: 18), // Ikon error.
                  SizedBox(width: 8), // Memberi jarak horizontal 8 piksel.
                  Expanded( // Memungkinkan teks error mengambil sisa ruang.
                    child: Text( // Teks pesan error.
                      _controller.error!, // Menampilkan pesan error dari controller (dijamin tidak null di sini).
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

          SizedBox(height: 16), // Memberi jarak vertikal 16 piksel.

          SizedBox(height: 52, // Menetapkan tinggi tombol login.
            child: ElevatedButton( // Tombol untuk aksi login.
              // Jika _controller.loading true, tombol dinonaktifkan (null), jika tidak, panggil _controller.submit.
              onPressed: _controller.loading ? null : () => _controller.submit(context), // Aksi yang terjadi saat tombol ditekan.
              style: ElevatedButton.styleFrom( // Styling untuk ElevatedButton.
                backgroundColor: _accent, // Warna latar belakang tombol (warna aksen).
                foregroundColor: _btnText, // Warna teks dan ikon di tombol.
                shape: RoundedRectangleBorder( // Bentuk tombol dengan sudut membulat.
                  borderRadius: BorderRadius.circular(18), // Radius sudut.
                ),
              ),
              child: _controller.loading // Jika sedang loading, tampilkan indikator loading.
                  ? SizedBox(width: 22, // Ukuran indikator loading.
                      height: 22,
                      child: CircularProgressIndicator( // Indikator loading berbentuk lingkaran.
                        strokeWidth: 2.4, // Ketebalan garis indikator.
                        valueColor: AlwaysStoppedAnimation<Color>(_btnText), // Warna indikator.
                      ),
                    )
                  : Text( // Jika tidak loading, tampilkan teks "Masuk".
                      'Masuk',
                      style: TextStyle(
                        fontSize: 15, // Ukuran font.
                        fontWeight: FontWeight.w700, // Ketebalan font (bold).
                      ),
                    ),
            ),
          ),
          SizedBox(height: 14), // Memberi jarak vertikal 14 piksel.

          Center( // Memusatkan widget anak.
            child: GestureDetector( // Mendeteksi gesture seperti tap.
              onTap: () { // Aksi saat widget ini di-tap.
                // Navigasi ke halaman pendaftaran (RegisterPage) dan mengganti halaman saat ini (Login Page).
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const RegisterPage()), // Mengarahkan ke RegisterPage.
                );
              },
              child: RichText( // Widget untuk menampilkan teks dengan gaya yang berbeda dalam satu baris.
                text: TextSpan( // Teks utama dengan gaya default.
                  style: TextStyle(fontSize: 13.5, color: _textSecondary), // Gaya teks default.
                  children: [
                    TextSpan(text: 'Belum punya akun? '), // Bagian teks normal.
                    TextSpan( // Bagian teks "Daftar" dengan gaya berbeda.
                      text: 'Daftar',
                      style: TextStyle(
                        fontWeight: FontWeight.w800, // Ketebalan font (extra-bold).
                        color: _btnText, // Warna teks.
                        decoration: TextDecoration.underline, // Teks bergaris bawah.
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

// Widget privat untuk membuat efek cahaya (glow) latar belakang.

// ==========================================
// Class _Glow
// Fungsi: Mendeklarasikan halaman/komponen visual ini.
// Mengarah ke: Biasanya dipanggil oleh router atau tombol navigasi di file lain.
// ==========================================
class _Glow extends StatelessWidget {
  final double size; // Ukuran (diameter) glow.
  final Color color; // Warna glow.

  const _Glow({required this.size, required this.color}); // Konstruktor dengan parameter yang wajib diisi.

  @override
  // Metode build untuk mendeskripsikan UI dari widget _Glow.
  
  // Fungsi build: Bertugas menggambar (me-render) elemen visual/UI ke layar HP pengguna.
  // Menghubungkan data dari Controller ke dalam bentuk Widget (teks, tombol, gambar).
  Widget build(BuildContext context) {
    return Container( // Wadah untuk menciptakan bentuk glow.
      width: size, // Mengatur lebar container sesuai dengan 'size'.
      height: size, // Mengatur tinggi container sesuai dengan 'size'.
      decoration: BoxDecoration( // Dekorasi untuk container.
        shape: BoxShape.circle, // Bentuk lingkaran.
        gradient: RadialGradient( // Menggunakan gradien radial untuk efek cahaya.
          colors: [color.withOpacity(0.8), color.withOpacity(0.0)], // Gradien dari warna solid ke transparan.
        ),
      ),
    );
  }
}