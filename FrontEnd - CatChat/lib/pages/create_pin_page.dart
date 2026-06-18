// Penjelasan file dan tujuannya:
// Nama file: create_pin_page.dart
// Deskripsi: File ini mengatur antarmuka pengguna (UI) dan apa yang dilihat pengguna di layar.
// Mengarahkan ke/Keterkaitan:
// - Mengarah ke Layar Lain: Menggunakan navigasi (Router) saat tombol ditekan.
// - Berhubungan dengan Controller: Mengambil dan mengirim data melalui file Controller yang relevan.

import 'package:flutter/material.dart'; // Mengimpor paket Flutter Material Design untuk membangun UI.
import 'package:flutter/services.dart'; // Mengimpor paket Flutter Services untuk mengakses layanan platform seperti haptic feedback (getaran).

import 'home_pages.dart'; // Mengimpor halaman `HomePages` yang akan dituju setelah PIN berhasil dibuat/diubah.
import '../controllers/create_pin_controller.dart'; // Mengimpor controller untuk logika bisnis pembuatan/perubahan PIN.


// ==========================================
// Class CreatePinPage
// Fungsi: Mendeklarasikan halaman/komponen visual ini.
// Mengarah ke: Biasanya dipanggil oleh router atau tombol navigasi di file lain.
// ==========================================
class CreatePinPage extends StatefulWidget { // Mendefinisikan widget `CreatePinPage` sebagai StatefulWidget karena state-nya akan berubah.
  /// If true, we're changing an existing PIN (show current PIN first).
  final bool isChanging; // Variabel boolean untuk menunjukkan apakah pengguna sedang mengubah PIN yang sudah ada (true) atau membuat PIN baru (false).

  const CreatePinPage({super.key, this.isChanging = false}); // Konstruktor untuk `CreatePinPage`, `isChanging` default-nya `false`.

  @override
  State<CreatePinPage> createState() => _CreatePinPageState(); // Membuat instance dari state terkait untuk widget ini.
}

class _CreatePinPageState extends State<CreatePinPage> // Mendefinisikan state untuk `CreatePinPage`.
    with SingleTickerProviderStateMixin { // Menggunakan `SingleTickerProviderStateMixin` untuk menyediakan ticker bagi `AnimationController` yang digunakan untuk animasi.
  late final CreatePinController _controller; // Mendeklarasikan controller untuk mengelola logika pembuatan PIN. Akan diinisialisasi di `initState`.

  late final AnimationController _shakeCtrl; // Controller untuk mengelola animasi guncangan (shake) pada input PIN.
  late final Animation<double> _shakeAnim; // Objek `Animation` yang mendefinisikan nilai animasi guncangan (dari 0 ke 12).

  static const _bg = Color(0xFFFAF4F0); // Konstanta warna latar belakang utama.
  static const _card = Colors.white; // Konstanta warna untuk komponen kartu.
  static const _border = Color(0xFFE7D8CF); // Konstanta warna untuk border elemen UI.
  static const _textPrimary = Color(0xFF3F3734); // Konstanta warna teks utama.
  static const _textSecondary = Color(0xFF7B6F65); // Konstanta warna teks sekunder atau deskripsi.
  static const _accent = Color(0xFFF4B5A3); // Konstanta warna aksen.
  static const _btnText = Color(0xFF5D4A45); // Konstanta warna teks tombol.
  static const _innerCard = Color(0xFFF7F1EE); // Konstanta warna untuk bagian dalam kartu atau elemen tombol.
  static const _errorColor = Color(0xFFD64545); // Konstanta warna untuk pesan error.
  static const _dotFilled = Color(0xFF5D4A45); // Konstanta warna dot PIN yang sudah terisi.
  static const _dotEmpty = Color(0xFFE7D8CF); // Konstanta warna dot PIN yang kosong.

  @override
  
  // Fungsi initState: Dijalankan pertama kali saat halaman ini dibuka.
  // Biasanya terhubung ke backend untuk mengambil data awal sebelum layar dimunculkan.
  void initState() { // Dipanggil saat widget ini dimasukkan ke dalam pohon widget untuk pertama kali.
    super.initState(); // Memanggil implementasi superclass.
    _controller = CreatePinController(isChanging: widget.isChanging); // Menginisialisasi `_controller` dengan nilai `isChanging` dari widget.
    _controller.addListener(_onControllerUpdate); // Menambahkan listener ke controller untuk bereaksi terhadap perubahan state-nya (misalnya, error atau sukses).
    _shakeCtrl = AnimationController( // Menginisialisasi `AnimationController` untuk animasi guncangan.
      vsync: this, // Menentukan `TickerProvider` untuk animasi (diambil dari `SingleTickerProviderStateMixin`).
      duration: Duration(milliseconds: 400), // Durasi total animasi guncangan adalah 400 milidetik.
    );
    _shakeAnim = Tween<double>(begin: 0, end: 12).animate( // Membuat animasi `_shakeAnim` yang akan mengubah nilai dari 0 ke 12.
      CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticIn), // Menggunakan `CurvedAnimation` dengan kurva `elasticIn` untuk memberikan efek guncangan yang realistis.
    );
  }

  @override
  void dispose() { // Dipanggil saat widget ini dihapus dari pohon widget dan state-nya akan dibuang.
    _controller.removeListener(_onControllerUpdate); // Menghapus listener dari controller untuk mencegah kebocoran memori.
    _controller.dispose(); // Membuang controller untuk membebaskan sumber daya.
    _shakeCtrl.dispose(); // Membuang `AnimationController` untuk animasi guncangan.
    super.dispose(); // Memanggil implementasi superclass.
  }

  void _onControllerUpdate() { // Metode yang dipanggil setiap kali controller memberitahukan perubahan state.
    if (_controller.status == CreatePinStatus.error) { // Jika status controller adalah `error`.
      HapticFeedback.lightImpact(); // Memberikan umpan balik haptic (getaran ringan) untuk menandakan error.
      _shakeCtrl.forward(from: 0); // Memulai animasi guncangan dari awal (nilai 0).
      _controller.resetStatus(); // Mengatur ulang status controller kembali ke default setelah error.
    } else if (_controller.status == CreatePinStatus.success) { // Jika status controller adalah `success`.
      HapticFeedback.mediumImpact(); // Memberikan umpan balik haptic (getaran sedang) untuk menandakan sukses.
      _handleSuccess(); // Memanggil metode untuk menangani keberhasilan pembuatan/perubahan PIN.
    }
  }

  Future<void> _handleSuccess() async { // Metode asinkron untuk menangani logika setelah PIN berhasil dibuat/diubah.
    await Future.delayed(Duration(milliseconds: 600)); // Menunggu selama 600 milidetik (misalnya, untuk memberi waktu animasi sukses).
    if (!mounted) return; // Memeriksa apakah widget masih ada di pohon widget sebelum melakukan navigasi, untuk mencegah error.
    if (widget.isChanging) { // Jika pengguna sedang dalam mode "mengubah PIN".
      Navigator.of(context).pop(true); // Kembali ke halaman sebelumnya dengan hasil `true`, menandakan PIN berhasil diubah.
    } else { // Jika pengguna sedang dalam mode "membuat PIN baru".
      Navigator.of(context).pushAndRemoveUntil( // Navigasi ke `HomePages` dan menghapus semua rute sebelumnya dari stack navigasi.
        MaterialPageRoute(builder: (_) => const HomePages()), // Membuat `MaterialPageRoute` untuk halaman `HomePages`.
        (_) => false, // Predikat yang selalu `false`, memastikan semua rute sebelumnya dihapus dari stack. Ini mengarahkan ke halaman utama tanpa riwayat.
      );
    }
  }

  void _onDigit(int digit) { // Metode yang dipanggil saat tombol digit angka ditekan.
    HapticFeedback.lightImpact(); // Memberikan umpan balik haptic (getaran ringan).
    _controller.onDigit(digit); // Meneruskan digit yang ditekan ke controller untuk diproses.
  }

  void _onDelete() { // Metode yang dipanggil saat tombol hapus (backspace) ditekan.
    HapticFeedback.lightImpact(); // Memberikan umpan balik haptic (getaran ringan).
    _controller.onDelete(); // Memberitahukan controller untuk menghapus digit terakhir yang dimasukkan.
  }

  @override
  
  // Fungsi build: Bertugas menggambar (me-render) elemen visual/UI ke layar HP pengguna.
  // Menghubungkan data dari Controller ke dalam bentuk Widget (teks, tombol, gambar).
  Widget build(BuildContext context) { // Metode `build` untuk membangun UI widget ini.
    return ListenableBuilder( // Widget ini membangun ulang bagian UI-nya setiap kali `_controller` memberitahukan perubahan (seperti input PIN, status error/sukses).
      listenable: _controller, // `_controller` adalah objek yang dipantau untuk perubahan.
      builder: (context, _) { // Builder yang dipanggil saat `_controller` berubah. Parameter `_` menandakan child yang tidak digunakan.
        return Scaffold( // Menyediakan struktur tata letak dasar visual halaman.
      backgroundColor: _bg, // Mengatur warna latar belakang scaffold dengan warna `_bg`.
      body: Stack( // Widget `Stack` untuk menumpuk widget di atas satu sama lain, memungkinkan efek latar belakang.
        children: [ // Daftar children dari `Stack`.
          Positioned( // Widget `Positioned` untuk menempatkan widget `_Glow` di posisi absolut.
            top: -56, // Posisi dari atas layar.
            left: -44, // Posisi dari kiri layar.
            child: _Glow(size: 180, color: Color(0xFFFFD9C8)), // Menampilkan efek cahaya (glow) dengan ukuran 180 dan warna tertentu.
          ),
          Positioned( // Posisi kedua efek cahaya.
            top: 120, // Posisi dari atas.
            right: -60, // Posisi dari kanan.
            child: _Glow(size: 160, color: Color(0xFFFFC3A8)), // Menampilkan efek cahaya kedua.
          ),
          Positioned( // Posisi ketiga efek cahaya.
            bottom: -70, // Posisi dari bawah.
            left: -40, // Posisi dari kiri.
            child: _Glow(size: 220, color: Color(0xFFF6D2C0)), // Menampilkan efek cahaya ketiga.
          ),
          SafeArea( // Widget `SafeArea` untuk memastikan konten tidak tumpang tindih dengan bagian-bagian OS (seperti status bar, notch).
            child: LayoutBuilder( // Widget `LayoutBuilder` untuk mendapatkan batasan ukuran dari parent, memungkinkan penyesuaian tata letak.
              builder: (context, constraints) { // Builder yang menyediakan `BoxConstraints` dari parent.
                final w = // Menghitung lebar maksimal untuk konten utama.
                    constraints.maxWidth < 480.0 ? constraints.maxWidth : 480.0; // Jika lebar parent kurang dari 480px, gunakan lebar parent; jika tidak, batasi pada 480px.
                return Center( // Memusatkan konten utama secara horizontal.
                  child: ConstrainedBox( // Widget `ConstrainedBox` untuk membatasi ukuran child.
                    constraints: BoxConstraints(maxWidth: w), // Membatasi lebar maksimal child sesuai dengan nilai `w` yang dihitung.
                    child: Padding( // Menambahkan padding di sekitar konten.
                      padding: EdgeInsets.all(20), // Padding sebesar 20 unit di semua sisi.
                      child: Column( // Widget `Column` untuk menata children secara vertikal.
                        children: [ // Daftar children dari `Column`.
                          _buildBrandHeader(), // Membangun bagian header yang berisi logo dan nama aplikasi.
                          SizedBox(height: 14), // Memberikan jarak vertikal sebesar 14 unit.
                          Expanded(child: _buildPinCard()), // Membangun kartu input PIN, yang akan mengambil sisa ruang vertikal yang tersedia.
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

  Widget _buildBrandHeader() { // Metode untuk membangun widget header merek/aplikasi.
    return Row( // Widget `Row` untuk menata children secara horizontal.
      children: [ // Daftar children dari `Row`.
        Container( // Container untuk ikon merek.
          width: 48, // Lebar container ikon.
          height: 48, // Tinggi container ikon.
          decoration: BoxDecoration( // Dekorasi container.
            color: Colors.white, // Warna latar belakang putih.
            shape: BoxShape.circle, // Bentuk container adalah lingkaran.
            border: Border.all(color: _accent.withValues(alpha: 0.35)), // Border dengan warna aksen yang sedikit transparan.
            boxShadow: [ // Daftar shadow untuk container ikon.
              BoxShadow( // Shadow pertama.
                color: Color(0x1A5D4A45), // Warna shadow dengan transparansi.
                blurRadius: 18, // Tingkat blur shadow.
                offset: Offset(0, 8), // Offset shadow (geser ke bawah).
              ),
            ],
          ),
          child: Icon(Icons.favorite_rounded, color: _accent), // Ikon hati dengan warna aksen di dalam container.
        ),
        SizedBox(width: 14), // Memberikan jarak horizontal sebesar 14 unit.
        Expanded( // Widget `Expanded` agar `Column` berikut mengambil sisa ruang horizontal yang tersedia.
          child: Column( // Widget `Column` untuk menata teks secara vertikal.
            crossAxisAlignment: CrossAxisAlignment.start, // Penyelarasan children ke awal (kiri).
            children: [ // Daftar children dari `Column`.
              Text( // Teks judul aplikasi.
                'Catchat', // Konten teks.
                style: TextStyle( // Gaya teks.
                  fontSize: 18, // Ukuran font.
                  fontWeight: FontWeight.w900, // Ketebalan font (ultra-bold).
                  color: _textPrimary, // Warna teks utama.
                ),
              ),
              SizedBox(height: 2), // Memberikan jarak vertikal kecil.
              Text( // Teks deskripsi di bawah judul.
                'Pengaturan keamanan PIN', // Konten teks.
                style: TextStyle(fontSize: 13, color: _textSecondary), // Gaya teks dengan ukuran 13 dan warna sekunder.
              ),
            ],
          ),
        ),
        Container( // Container untuk label 'PIN'.
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8), // Padding horizontal 12 dan vertikal 8.
          decoration: BoxDecoration( // Dekorasi container.
            color: Color(0xFFFFF4EF), // Warna latar belakang.
            borderRadius: BorderRadius.circular(999), // Sudut membulat penuh, membuatnya tampak seperti pil.
            border: Border.all(color: Color(0xFFE8D6CB)), // Border dengan warna tertentu.
          ),
          child: Text( // Teks label 'PIN'.
            'PIN', // Konten teks.
            style: TextStyle( // Gaya teks.
              fontSize: 12, // Ukuran font.
              fontWeight: FontWeight.w700, // Ketebalan font (bold).
              color: Color(0xFF7A4028), // Warna teks.
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPinCard() { // Metode untuk membangun widget kartu input PIN.
    return Container( // Container utama kartu PIN.
      padding: EdgeInsets.symmetric(horizontal: 18, vertical: 20), // Padding internal horizontal 18 dan vertikal 20.
      decoration: BoxDecoration( // Dekorasi container.
        color: _card, // Warna latar belakang kartu.
        borderRadius: BorderRadius.circular(34), // Sudut membulat.
        border: Border.all(color: _border), // Border dengan warna `_border`.
        boxShadow: [ // Daftar shadow untuk kartu.
          BoxShadow( // Shadow pertama.
            color: Color(0x1A5D4A45), // Warna shadow dengan transparansi.
            blurRadius: 30, // Tingkat blur shadow.
            offset: Offset(0, 18), // Offset shadow (geser ke bawah).
          ),
        ],
      ),
      child: SingleChildScrollView( // Widget `SingleChildScrollView` untuk memungkinkan scrolling jika konten melebihi tinggi layar.
        child: Column( // Widget `Column` untuk menata children secara vertikal di dalam kartu.
          children: [ // Daftar children dari `Column`.
          // Icon
          Container( // Container untuk ikon kunci atau ceklis.
            width: 56, // Lebar container ikon.
            height: 56, // Tinggi container ikon.
            decoration: BoxDecoration( // Dekorasi container.
              color: _controller.success ? Color(0xFF4CAF50) : _innerCard, // Warna latar belakang berdasarkan status sukses (hijau) atau default (`_innerCard`).
              shape: BoxShape.circle, // Bentuk lingkaran.
              border: Border.all(color: _border), // Border dengan warna `_border`.
            ),
            child: Icon( // Ikon yang ditampilkan.
              _controller.success ? Icons.check_rounded : Icons.lock_outline_rounded, // Ikon ceklis jika sukses, ikon kunci jika tidak.
              color: _controller.success ? Colors.white : _btnText, // Warna ikon (putih jika sukses, `_btnText` jika tidak).
              size: 28, // Ukuran ikon.
            ),
          ),
          SizedBox(height: 14), // Memberikan jarak vertikal.

          Text( // Teks judul utama di kartu.
            _controller.success ? 'PIN Berhasil Dibuat!' : _controller.title, // Teks ini berubah berdasarkan status sukses atau nilai `title` dari controller.
            textAlign: TextAlign.center, // Penyelarasan teks ke tengah.
            style: TextStyle( // Gaya teks.
              fontSize: 22, // Ukuran font.
              fontWeight: FontWeight.w900, // Ketebalan font (ultra-bold).
              color: _textPrimary, // Warna teks utama.
            ),
          ),
          SizedBox(height: 6), // Memberikan jarak vertikal kecil.
          Text( // Teks subtitle/deskripsi di kartu.
            _controller.success // Konten teks ini berubah berdasarkan status sukses atau nilai `subtitle` dari controller.
                ? 'Selamat datang di Catchat.'
                : _controller.subtitle,
            textAlign: TextAlign.center, // Penyelarasan teks ke tengah.
            style: TextStyle( // Gaya teks.
              fontSize: 13, // Ukuran font.
              height: 1.4, // Tinggi baris teks.
              color: _textSecondary, // Warna teks sekunder.
            ),
          ),
          SizedBox(height: 20), // Memberikan jarak vertikal.

          // PIN dots
          AnimatedBuilder( // Widget ini membangun ulang dirinya setiap kali `_shakeAnim` berubah, untuk efek guncangan.
            animation: _shakeAnim, // Animasi yang dipantau.
            builder: (context, child) { // Builder yang dipanggil saat animasi berubah.
              return Transform.translate( // Menerapkan transformasi translasi (pergerakan) pada child.
                offset: Offset( // Offset pergeseran.
                  _shakeCtrl.status == AnimationStatus.dismissed // Jika animasi guncangan selesai (status `dismissed`).
                      ? 0 // Offset X adalah 0 (tidak bergerak).
                      : _shakeAnim.value * // Jika animasi sedang berjalan, gunakan nilai animasi dikalikan dengan faktor.
                            ((_shakeCtrl.value * 10).toInt().isEven ? 1 : -1), // Mengganti arah guncangan (ke kanan atau kiri) untuk efek maju-mundur.
                  0, // Offset Y tetap 0.
                ),
                child: child, // Child dari `AnimatedBuilder` (dot PIN) akan diguncang.
              );
            },
            child: Row( // Row untuk menata dot PIN secara horizontal.
              mainAxisAlignment: MainAxisAlignment.center, // Penyelarasan dot ke tengah.
              children: List.generate(CreatePinController.pinLength, (i) { // Membuat daftar dot PIN sebanyak `pinLength` yang ditentukan di controller.
                final filled = i < _controller.enteredPin.length; // Menentukan apakah dot saat ini harus diisi (berdasarkan panjang PIN yang sudah dimasukkan).
                return AnimatedContainer( // Container yang bisa dianimasikan perubahan ukuran dan warnanya.
                  duration: Duration(milliseconds: 200), // Durasi animasi perubahan dot.
                  curve: Curves.easeOutCubic, // Kurva animasi untuk transisi yang mulus.
                  margin: EdgeInsets.symmetric(horizontal: 8), // Margin horizontal antar dot.
                  width: filled ? 18 : 14, // Lebar dot (lebih besar jika terisi).
                  height: filled ? 18 : 14, // Tinggi dot (lebih besar jika terisi).
                  decoration: BoxDecoration( // Dekorasi dot.
                    color: _controller.success // Warna isi dot.
                        ? Color(0xFF4CAF50) // Hijau jika PIN berhasil dibuat.
                        : filled // Jika tidak sukses, cek apakah dot terisi.
                            ? _dotFilled // Warna dot terisi.
                            : Colors.transparent, // Transparan jika dot kosong.
                    shape: BoxShape.circle, // Bentuk lingkaran.
                    border: Border.all( // Border dot.
                      color: _controller.success // Warna border.
                          ? Color(0xFF4CAF50) // Hijau jika PIN berhasil dibuat.
                          : filled // Jika tidak sukses, cek apakah dot terisi.
                              ? _dotFilled // Warna border dot terisi.
                              : _dotEmpty, // Warna border dot kosong.
                      width: 2, // Lebar border.
                    ),
                  ),
                );
              }),
            ),
          ),

          // Error
          if (_controller.error != null) ...[ // Kondisi: Jika ada pesan error dari controller (`_controller.error` tidak null).
            SizedBox(height: 12), // Memberikan jarak vertikal.
            Text( // Teks pesan error.
              _controller.error!, // Konten pesan error (dipastikan tidak null karena kondisi `if`).
              textAlign: TextAlign.center, // Penyelarasan teks ke tengah.
              style: TextStyle( // Gaya teks.
                fontSize: 13, // Ukuran font.
                color: _errorColor, // Warna teks error.
                fontWeight: FontWeight.w600, // Ketebalan font.
              ),
            ),
          ],

          SizedBox(height: 16), // Memberikan jarak vertikal.

          // Number pad
          _buildNumPad(), // Membangun numpad (keyboard angka) untuk input PIN.

          SizedBox(height: 8), // Memberikan jarak vertikal.
          ],
        ),
      ),
    );
  }

  Widget _buildNumPad() { // Metode untuk membangun widget numpad (keyboard angka).
    return Column( // Widget `Column` untuk menata baris-baris tombol angka secara vertikal.
      children: [ // Daftar children dari `Column`.
        Row( // Baris pertama tombol angka (1, 2, 3).
          mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Distribusi ruang secara merata antar children.
          children: [_numBtn(1), _numBtn(2), _numBtn(3)], // Tiga tombol angka.
        ),
        SizedBox(height: 10), // Memberikan jarak vertikal antar baris.
        Row( // Baris kedua tombol angka (4, 5, 6).
          mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Distribusi ruang secara merata antar children.
          children: [_numBtn(4), _numBtn(5), _numBtn(6)], // Tiga tombol angka.
        ),
        SizedBox(height: 10), // Memberikan jarak vertikal antar baris.
        Row( // Baris ketiga tombol angka (7, 8, 9).
          mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Distribusi ruang secara merata antar children.
          children: [_numBtn(7), _numBtn(8), _numBtn(9)], // Tiga tombol angka.
        ),
        SizedBox(height: 10), // Memberikan jarak vertikal antar baris.
        Row( // Baris keempat tombol (placeholder kosong, 0, tombol hapus).
          mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Distribusi ruang secara merata antar children.
          children: [ // Daftar children.
            // Empty
            SizedBox(width: 72, height: 72), // Widget kosong sebagai placeholder untuk menjaga tata letak agar rata.
            _numBtn(0), // Tombol angka 0.
            // Delete
            SizedBox(width: 72, // Ukuran untuk tombol hapus.
              height: 72,
              child: Material( // Widget `Material` untuk efek sentuhan (splash, highlight) tanpa warna latar belakang yang terlihat.
                color: Colors.transparent, // Warna transparan agar `InkWell` terlihat.
                child: InkWell( // Widget `InkWell` untuk memberikan efek visual saat ditekan dan mendeteksi tap.
                  borderRadius: BorderRadius.circular(36), // Sudut membulat untuk efek sentuhan.
                  onTap: _onDelete, // Panggilan metode `_onDelete` saat tombol ditekan.
                  child: Center( // Memusatkan ikon hapus.
                    child: Icon( // Ikon hapus (backspace).
                      Icons.backspace_outlined,
                      color: _btnText, // Warna ikon.
                      size: 24, // Ukuran ikon.
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

  Widget _numBtn(int digit) { // Metode untuk membangun widget tombol angka individual.
    return SizedBox(width: 72, // Ukuran tombol.
      height: 72,
      child: Material( // Widget `Material` untuk memberikan warna latar belakang dan efek sentuhan.
        color: _innerCard, // Warna latar belakang tombol.
        borderRadius: BorderRadius.circular(36), // Sudut membulat.
        child: InkWell( // Widget `InkWell` untuk interaksi sentuhan.
          borderRadius: BorderRadius.circular(36), // Sudut membulat untuk efek sentuhan.
          onTap: () => _onDigit(digit), // Panggilan metode `_onDigit` dengan angka yang sesuai saat tombol ditekan.
          child: Center( // Memusatkan teks angka.
            child: Text( // Teks angka.
              '$digit', // Menampilkan digit sebagai teks.
              style: TextStyle( // Gaya teks.
                fontSize: 26, // Ukuran font.
                fontWeight: FontWeight.w700, // Ketebalan font (bold).
                color: _textPrimary, // Warna teks utama.
              ),
            ),
          ),
        ),
      ),
    );
  }
}


// ==========================================
// Class _Glow
// Fungsi: Mendeklarasikan halaman/komponen visual ini.
// Mengarah ke: Biasanya dipanggil oleh router atau tombol navigasi di file lain.
// ==========================================
class _Glow extends StatelessWidget { // Widget privat `_Glow` untuk efek cahaya, sebagai StatelessWidget karena tidak memiliki state internal yang berubah.
  final double size; // Ukuran efek cahaya (lebar dan tinggi).
  final Color color; // Warna efek cahaya.

  const _Glow({required this.size, required this.color}); // Konstruktor `_Glow` yang memerlukan `size` dan `color`.

  @override
  
  // Fungsi build: Bertugas menggambar (me-render) elemen visual/UI ke layar HP pengguna.
  // Menghubungkan data dari Controller ke dalam bentuk Widget (teks, tombol, gambar).
  Widget build(BuildContext context) { // Metode `build` untuk `_Glow`.
    return Container( // Container untuk efek cahaya.
      width: size, // Lebar container.
      height: size, // Tinggi container.
      decoration: BoxDecoration( // Dekorasi container.
        shape: BoxShape.circle, // Bentuk lingkaran.
        gradient: RadialGradient( // Menggunakan gradien radial untuk efek cahaya yang memudar dari tengah ke tepi.
          colors: [color.withValues(alpha: 0.8), color.withValues(alpha: 0.0)], // Gradien dari warna solid (80% alpha) di tengah ke transparan penuh di tepi.
        ),
      ),
    );
  }
}