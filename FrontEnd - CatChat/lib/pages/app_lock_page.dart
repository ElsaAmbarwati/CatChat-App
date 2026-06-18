// Penjelasan file dan tujuannya:
// Nama file: app_lock_page.dart
// Deskripsi: File ini mengatur antarmuka pengguna (UI) dan apa yang dilihat pengguna di layar.
// Mengarahkan ke/Keterkaitan:
// - Mengarah ke Layar Lain: Menggunakan navigasi (Router) saat tombol ditekan.
// - Berhubungan dengan Controller: Mengambil dan mengirim data melalui file Controller yang relevan.

import 'package:flutter/material.dart'; // Mengimpor pustaka Flutter untuk membangun UI.

import '../controllers/app_lock_controller.dart'; // Mengimpor controller yang menangani logika penguncian aplikasi.

// Mendefinisikan widget halaman AppLockPage yang merupakan StatefulWidget.

// ==========================================
// Class AppLockPage
// Fungsi: Mendeklarasikan halaman/komponen visual ini.
// Mengarah ke: Biasanya dipanggil oleh router atau tombol navigasi di file lain.
// ==========================================
class AppLockPage extends StatefulWidget {
  // Properti untuk menandakan apakah halaman ini dibuka dari latar belakang.
  final bool isFromBackground;
  // Variabel statis untuk melacak apakah AppLockPage sedang ditampilkan.
  static bool isShowing = false;

  // Konstruktor untuk AppLockPage.
  const AppLockPage({super.key, this.isFromBackground = false});

  // Membuat state untuk widget AppLockPage.
  @override
  State<AppLockPage> createState() => _AppLockPageState();
}

// Kelas state untuk AppLockPage.
class _AppLockPageState extends State<AppLockPage>
    with SingleTickerProviderStateMixin { // Menggunakan SingleTickerProviderStateMixin untuk animasi.
  // Instansiasi AppLockController.
  final AppLockController _controller = AppLockController();

  // Definisi konstanta warna yang digunakan dalam UI.
  static const _bg = Color(0xFFFAF4F0); // Warna latar belakang.
  static const _card = Colors.white; // Warna kartu.
  static const _border = Color(0xFFE7D8CF); // Warna garis batas.
  static const _textPrimary = Color(0xFF3F3734); // Warna teks utama.
  static const _textSecondary = Color(0xFF7B6F65); // Warna teks sekunder.
  static const _accent = Color(0xFFF4B5A3); // Warna aksen.
  static const _btnText = Color(0xFF5D4A45); // Warna teks tombol.
  static const _innerCard = Color(0xFFF7F1EE); // Warna kartu bagian dalam.
  static const _errorColor = Color(0xFFD64545); // Warna untuk pesan error.
  static const _dotFilled = Color(0xFF5D4A45); // Warna untuk titik PIN yang terisi.
  static const _dotEmpty = Color(0xFFE7D8CF); // Warna untuk titik PIN yang kosong.

  // Deklarasi AnimationController untuk animasi getaran (shake).
  late final AnimationController _shakeCtrl;
  // Deklarasi Animation untuk nilai getaran.
  late final Animation<double> _shakeAnim;

  // Metode initState dipanggil saat widget pertama kali dibuat.
  @override
  
  // Fungsi initState: Dijalankan pertama kali saat halaman ini dibuka.
  // Biasanya terhubung ke backend untuk mengambil data awal sebelum layar dimunculkan.
  void initState() {
    super.initState();
    AppLockPage.isShowing = true; // Mengatur status tampilan menjadi true.
    // Menginisialisasi AnimationController untuk animasi getaran.
    _shakeCtrl = AnimationController(
      vsync: this, // Menyediakan ticker untuk sinkronisasi animasi.
      duration: Duration(milliseconds: 400), // Durasi animasi getaran.
    );
    // Mengatur animasi getaran menggunakan Tween dan CurvedAnimation.
    _shakeAnim = Tween<double>(begin: 0, end: 12).animate(
      CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticIn), // Kurva animasi yang memantul.
    );
  }

  // Metode dispose dipanggil saat widget dihapus dari pohon widget.
  @override
  void dispose() {
    AppLockPage.isShowing = false; // Mengatur status tampilan menjadi false.
    _shakeCtrl.dispose(); // Membuang AnimationController.
    _controller.dispose(); // Membuang AppLockController.
    super.dispose(); // Memanggil dispose dari superclass.
  }


  // Metode build untuk membangun UI widget.
  @override
  
  // Fungsi build: Bertugas menggambar (me-render) elemen visual/UI ke layar HP pengguna.
  // Menghubungkan data dari Controller ke dalam bentuk Widget (teks, tombol, gambar).
  Widget build(BuildContext context) {
    // Menggunakan ListenableBuilder untuk membangun ulang widget saat controller berubah.
    return ListenableBuilder(
      listenable: _controller, // Mendengarkan perubahan pada _controller.
      builder: (context, _) { // Fungsi builder yang dipanggil saat ada perubahan.
        // Mengembalikan widget Scaffold sebagai struktur halaman utama.
        return Scaffold(
      backgroundColor: _bg, // Mengatur warna latar belakang halaman.
      body: Stack( // Menggunakan Stack untuk menempatkan widget secara bertumpuk.
        children: [
          // Menempatkan elemen latar belakang gradien di berbagai posisi.
          Positioned(
            top: -56,
            left: -44,
            child: _BackgroundGlow(size: 180, color: Color(0xFFFFD9C8)), // Elemen glow latar belakang pertama.
          ),
          Positioned(
            top: 120,
            right: -60,
            child: _BackgroundGlow(size: 160, color: Color(0xFFFFC3A8)), // Elemen glow latar belakang kedua.
          ),
          Positioned(
            bottom: -70,
            left: -40,
            child: _BackgroundGlow(size: 220, color: Color(0xFFF6D2C0)), // Elemen glow latar belakang ketiga.
          ),
          SafeArea( // Memastikan konten tidak tertutup oleh notch atau status bar.
            child: LayoutBuilder( // Membangun widget berdasarkan ukuran yang tersedia.
              builder: (context, constraints) {
                // Menentukan lebar konten, membatasi maksimal 480 piksel.
                final contentWidth = constraints.maxWidth < 480.0
                    ? constraints.maxWidth
                    : 480.0;
                return Center( // Memusatkan konten di tengah layar.
                  child: ConstrainedBox( // Membatasi lebar konten.
                    constraints: BoxConstraints(maxWidth: contentWidth),
                    child: Padding( // Menambahkan padding di sekitar konten.
                      padding: EdgeInsets.all(20),
                      child: Column( // Mengatur widget secara vertikal.
                        children: [
                          _buildBrandHeader(), // Membangun bagian header merek.
                          SizedBox(height: 14), // Menambahkan jarak vertikal.
                          Expanded(child: _buildPinCard()), // Membangun bagian kartu PIN, mengambil ruang yang tersedia.
                        ],
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

  // Widget untuk membangun bagian header merek.
  Widget _buildBrandHeader() {
    return Row( // Mengatur widget secara horizontal.
      children: [
        Container( // Wadah untuk ikon merek.
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white, // Warna latar belakang ikon.
            shape: BoxShape.circle, // Membuat ikon berbentuk lingkaran.
            border: Border.all(color: _accent.withValues(alpha: 0.35)), // Garis batas dengan transparansi.
            boxShadow: [ // Menambahkan bayangan.
              BoxShadow(
                color: Color(0x1A5D4A45), // Warna bayangan.
                blurRadius: 18, // Radius blur bayangan.
                offset: Offset(0, 8), // Pergeseran bayangan.
              ),
            ],
          ),
          child: Icon(Icons.favorite_rounded, color: _accent), // Ikon favorit dengan warna aksen.
        ),
        SizedBox(width: 14), // Menambahkan jarak horizontal.
        Expanded( // Mengambil ruang yang tersedia.
          child: Column( // Mengatur teks secara vertikal.
            crossAxisAlignment: CrossAxisAlignment.start, // Rata kiri.
            children: [
              Text(
                'Catchat', // Teks nama aplikasi.
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: _textPrimary,
                ),
              ),
              SizedBox(height: 2), // Menambahkan jarak vertikal.
              Text(
                'Ruang privat, lembut, dan aman', // Teks deskripsi aplikasi.
                style: TextStyle(fontSize: 13, color: _textSecondary),
              ),
            ],
          ),
        ),
        Container( // Wadah untuk label "Private".
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8), // Padding horizontal dan vertikal.
          decoration: BoxDecoration(
            color: Color(0xFFFFF4EF), // Warna latar belakang label.
            borderRadius: BorderRadius.circular(999), // Membuat sudut sangat bulat.
            border: Border.all(color: Color(0xFFE8D6CB)), // Garis batas label.
          ),
          child: Text(
            'Private', // Teks label.
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF7A4028),
            ),
          ),
        ),
      ],
    );
  }

  // Widget untuk membangun bagian kartu PIN.
  Widget _buildPinCard() {
    return Container( // Wadah utama kartu PIN.
      padding: EdgeInsets.symmetric(horizontal: 18, vertical: 20), // Padding di dalam kartu.
      decoration: BoxDecoration(
        color: _card, // Warna latar belakang kartu.
        borderRadius: BorderRadius.circular(34), // Sudut kartu yang membulat.
        border: Border.all(color: _border), // Garis batas kartu.
        boxShadow: [ // Bayangan kartu.
          BoxShadow(
            color: Color(0x1A5D4A45),
            blurRadius: 30,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: LayoutBuilder( // Membangun widget berdasarkan ukuran yang tersedia.
        builder: (context, constraints) {
          return SingleChildScrollView( // Memungkinkan pengguliran jika konten melebihi layar.
            child: ConstrainedBox( // Memastikan tinggi minimum untuk konten.
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight( // Memastikan tinggi elemen di dalamnya sama.
                child: Column( // Mengatur widget secara vertikal.
        children: [
          SizedBox(height: 4), // Jarak vertikal kecil.

          // Hero intro
          Container( // Wadah untuk bagian pengantar.
            padding: EdgeInsets.all(14), // Padding di dalam wadah pengantar.
            decoration: BoxDecoration(
              color: _innerCard, // Warna latar belakang wadah pengantar.
              borderRadius: BorderRadius.circular(22), // Sudut membulat.
              border: Border.all(color: _border), // Garis batas.
            ),
            child: Row( // Mengatur ikon dan teks secara horizontal.
              children: [
                Container( // Wadah untuk ikon.
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white, // Warna latar belakang ikon.
                    shape: BoxShape.circle, // Bentuk lingkaran.
                    border: Border.all(color: _border), // Garis batas.
                  ),
                  child: Icon(Icons.pets_rounded, color: _btnText), // Ikon hewan peliharaan.
                ),
                SizedBox(width: 12), // Jarak horizontal.
                Expanded( // Mengambil ruang yang tersedia untuk teks.
                  child: Text(
                    'Halo! Masukkan PIN 6 digit untuk membuka ruang pribadimu.', // Teks pengantar.
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.45,
                      color: _textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16), // Jarak vertikal.

          // Lock icon
          Container( // Wadah untuk ikon gembok.
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _controller.success ? Color(0xFF4CAF50) : _innerCard, // Warna berubah jika sukses.
              shape: BoxShape.circle, // Bentuk lingkaran.
              border: Border.all(color: _border), // Garis batas.
            ),
            child: Icon( // Ikon gembok.
              _controller.success ? Icons.lock_open_rounded : Icons.lock_rounded, // Ikon gembok terbuka atau tertutup.
              color: _controller.success ? Colors.white : _btnText, // Warna ikon berubah jika sukses.
              size: 28,
            ),
          ),
          SizedBox(height: 12), // Jarak vertikal.

          Text(
            _controller.success ? 'Berhasil!' : 'Masukkan PIN', // Teks status.
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: _textPrimary,
            ),
          ),
          SizedBox(height: 4), // Jarak vertikal kecil.
          Text(
            'Verifikasi identitasmu dengan PIN 6 digit.', // Teks deskripsi status.
            style: TextStyle(
              fontSize: 13,
              color: _textSecondary,
            ),
          ),
          SizedBox(height: 16), // Jarak vertikal.

          // Status row
          Row( // Mengatur chip status secara horizontal.
            children: [
              Expanded( // Mengambil ruang yang tersedia untuk setiap chip.
                child: _StatusChip(icon: Icons.security_rounded, label: 'Lokal'), // Chip status "Lokal".
              ),
              SizedBox(width: 10), // Jarak horizontal.
              Expanded(
                child: _StatusChip(
                  icon: Icons.visibility_off_rounded,
                  label: 'Privat', // Chip status "Privat".
                ),
              ),
              SizedBox(width: 10), // Jarak horizontal.
              Expanded(
                child: _StatusChip(
                  icon: Icons.favorite_rounded,
                  label: 'Hangat', // Chip status "Hangat".
                ),
              ),
            ],
          ),
          SizedBox(height: 16), // Jarak vertikal.

          // PIN dots
          AnimatedBuilder( // Membangun ulang widget saat animasi berjalan.
            animation: _shakeAnim, // Menggunakan animasi getaran.
            builder: (context, child) {
              return Transform.translate( // Menerapkan pergeseran untuk efek getaran.
                offset: Offset(
                  _shakeCtrl.status == AnimationStatus.dismissed
                      ? 0
                      : _shakeAnim.value *
                            ((_shakeCtrl.value * 10).toInt().isEven ? 1 : -1),
                  0,
                ),
                child: child, // Widget anak yang akan digetarkan.
              );
            },
            child: Row( // Mengatur titik-titik PIN secara horizontal.
              mainAxisAlignment: MainAxisAlignment.center, // Pusatkan titik-titik.
              children: List.generate(AppLockController.pinLength, (i) { // Membuat titik sebanyak panjang PIN.
                final filled = i < _controller.enteredPin.length; // Menentukan apakah titik terisi atau tidak.
                return AnimatedContainer( // Animasi untuk perubahan ukuran dan warna titik.
                  duration: Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  margin: EdgeInsets.symmetric(horizontal: 8), // Jarak antar titik.
                  width: filled ? 18 : 14, // Lebar titik berdasarkan status terisi.
                  height: filled ? 18 : 14, // Tinggi titik berdasarkan status terisi.
                  decoration: BoxDecoration(
                    color: _controller.success
                        ? Color(0xFF4CAF50) // Warna hijau jika sukses.
                        : filled
                            ? _dotFilled // Warna titik terisi.
                            : Colors.transparent, // Transparan jika kosong.
                    shape: BoxShape.circle, // Bentuk lingkaran.
                    border: Border.all(
                      color: _controller.success
                          ? Color(0xFF4CAF50) // Warna batas hijau jika sukses.
                          : filled
                              ? _dotFilled // Warna batas titik terisi.
                              : _dotEmpty, // Warna batas titik kosong.
                      width: 2, // Lebar garis batas.
                    ),
                  ),
                );
              }),
            ),
          ),

          // Menampilkan pesan error jika ada.
          if (_controller.error != null) ...[
            SizedBox(height: 10), // Jarak vertikal.
            Text(
              _controller.error!, // Tampilkan pesan error dari controller.
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: _errorColor, // Warna merah untuk error.
                fontWeight: FontWeight.w600,
              ),
            ),
          ],

          SizedBox(height: 16), // Jarak vertikal.

          // Number pad
          _buildNumPad(), // Membangun bagian keypad angka.

                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}

  // Widget untuk membangun keypad angka.
  Widget _buildNumPad() {
    return Column( // Mengatur tombol angka secara vertikal.
      children: [
        Row( // Baris tombol angka pertama.
          mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Jarak yang merata antar tombol.
          children: [_numBtn(1), _numBtn(2), _numBtn(3)], // Tombol 1, 2, 3.
        ),
        SizedBox(height: 10), // Jarak vertikal.
        Row( // Baris tombol angka kedua.
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [_numBtn(4), _numBtn(5), _numBtn(6)], // Tombol 4, 5, 6.
        ),
        SizedBox(height: 10), // Jarak vertikal.
        Row( // Baris tombol angka ketiga.
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [_numBtn(7), _numBtn(8), _numBtn(9)], // Tombol 7, 8, 9.
        ),
        SizedBox(height: 10), // Jarak vertikal.
        Row( // Baris tombol angka terakhir (0 dan backspace).
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(width: 64, height: 64), // Spacer untuk menyeimbangkan tata letak.
            _numBtn(0), // Tombol 0.
            SizedBox(width: 64,
              height: 64,
              child: Material( // Widget Material untuk efek ripple inkwell.
                color: Colors.transparent,
                child: InkWell( // Widget untuk menangani sentuhan.
                  borderRadius: BorderRadius.circular(36), // Sudut membulat untuk efek ripple.
                  onTap: _controller.onDelete, // Memanggil fungsi delete pada controller.
                  child: Center(
                    child: Icon(
                      Icons.backspace_outlined, // Ikon backspace.
                      color: _btnText, // Warna ikon.
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Widget untuk membangun tombol angka individual.
  Widget _numBtn(int digit) {
    return SizedBox(width: 64, // Ukuran tombol.
      height: 64,
      child: Material( // Widget Material untuk efek ripple inkwell.
        color: _innerCard, // Warna latar belakang tombol.
        borderRadius: BorderRadius.circular(36), // Sudut membulat.
        child: InkWell( // Widget untuk menangani sentuhan.
          borderRadius: BorderRadius.circular(36), // Sudut membulat untuk efek ripple.
          onTap: () => _controller.onDigit(digit, () { // Memanggil fungsi onDigit pada controller saat ditekan.
            _controller.verifyPin( // Memanggil fungsi verifikasi PIN setelah digit dimasukkan.
              context: context, // Konteks saat ini.
              isFromBackground: widget.isFromBackground, // Meneruskan status dari background.
              onShake: () => _shakeCtrl.forward(from: 0), // Memicu animasi getaran jika verifikasi gagal.
            );
          }),
          child: Center( // Memusatkan teks angka di dalam tombol.
            child: Text(
              '$digit', // Menampilkan angka digit.
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: _textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Widget _StatusChip untuk menampilkan ikon dan label status.

// ==========================================
// Class _StatusChip
// Fungsi: Mendeklarasikan halaman/komponen visual ini.
// Mengarah ke: Biasanya dipanggil oleh router atau tombol navigasi di file lain.
// ==========================================
class _StatusChip extends StatelessWidget {
  final IconData icon; // Properti untuk ikon.
  final String label; // Properti untuk label teks.

  // Konstruktor untuk _StatusChip.
  const _StatusChip({required this.icon, required this.label});

  // Metode build untuk membangun UI widget.
  @override
  
  // Fungsi build: Bertugas menggambar (me-render) elemen visual/UI ke layar HP pengguna.
  // Menghubungkan data dari Controller ke dalam bentuk Widget (teks, tombol, gambar).
  Widget build(BuildContext context) {
    return Container( // Wadah untuk chip status.
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10), // Padding di dalam chip.
      decoration: BoxDecoration(
        color: Colors.white, // Warna latar belakang chip.
        borderRadius: BorderRadius.circular(18), // Sudut membulat.
        border: Border.all(color: Color(0xFFE7D8CF)), // Garis batas chip.
      ),
      child: Column( // Mengatur ikon dan teks secara vertikal.
        children: [
          Icon(icon, size: 18, color: Color(0xFF7B6F65)), // Menampilkan ikon.
          SizedBox(height: 6), // Jarak vertikal.
          Text(
            label, // Menampilkan label teks.
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF7B6F65),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget _BackgroundGlow untuk membuat efek cahaya latar belakang.

// ==========================================
// Class _BackgroundGlow
// Fungsi: Mendeklarasikan halaman/komponen visual ini.
// Mengarah ke: Biasanya dipanggil oleh router atau tombol navigasi di file lain.
// ==========================================
class _BackgroundGlow extends StatelessWidget {
  final double size; // Properti untuk ukuran glow.
  final Color color; // Properti untuk warna glow.

  // Konstruktor untuk _BackgroundGlow.
  const _BackgroundGlow({required this.size, required this.color});

  // Metode build untuk membangun UI widget.
  @override
  
  // Fungsi build: Bertugas menggambar (me-render) elemen visual/UI ke layar HP pengguna.
  // Menghubungkan data dari Controller ke dalam bentuk Widget (teks, tombol, gambar).
  Widget build(BuildContext context) {
    return Container( // Wadah untuk efek glow.
      width: size, // Mengatur lebar wadah.
      height: size, // Mengatur tinggi wadah.
      decoration: BoxDecoration(
        shape: BoxShape.circle, // Membuat wadah berbentuk lingkaran.
        gradient: RadialGradient( // Menggunakan gradien radial untuk efek glow.
          colors: [color.withValues(alpha: 0.8), color.withValues(alpha: 0.0)], // Gradien dari warna opak ke transparan.
        ),
      ),
    );
  }
}