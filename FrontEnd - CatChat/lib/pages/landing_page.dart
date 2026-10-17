import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts
import 'register_page.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
      ),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _fadeController,
            curve: const Interval(0.0, 0.8, curve: Curves.easeOutExpo),
          ),
        );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFFAF4F0);
    final isWide = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          // HERO SECTION
          SliverToBoxAdapter(
            child: _buildHeroSection(context, backgroundColor),
          ),

          // KONTEN BAWAH
          SliverToBoxAdapter(
            child: Container(
              color: backgroundColor,
              child: Column(
                children: [
                  _buildAnonymousHighlight(context),
                  _buildImageFeaturesSection(),
                  const SizedBox(height: 100),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      '© 2026 CATCHAT. RAHASIAMU AMAN BERSAMA KAMI.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunito(
                        color: const Color(0xFF7B6F65),
                        fontSize: isWide ? 12 : 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: isWide ? 2.0 : 1.0,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, Color bgColor) {
    final bool isWide = MediaQuery.of(context).size.width > 800;

    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/bg.jpeg',
            fit: BoxFit.cover,
            alignment: Alignment.center,
            errorBuilder: (context, error, stackTrace) =>
                Container(color: const Color(0xFF0F0B13)),
          ),

          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.7),
                  Colors.black.withOpacity(0.3),
                  bgColor,
                  bgColor,
                ],
                stops: const [0.0, 0.4, 0.8, 1.0],
              ),
            ),
          ),

          Positioned(
            bottom: -5,
            left: -5,
            right: -5,
            child: Container(height: 10, color: bgColor),
          ),

          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? 32 : 16,
              vertical: 48,
            ),
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/images/logo2.png',
                            width: isWide ? 140 : 100,
                            height: isWide ? 140 : 100,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.pets,
                              size: isWide ? 100 : 70,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'CATCHAT',
                            style: GoogleFonts.nunito(
                              fontSize: isWide ? 48 : 32,
                              fontWeight: FontWeight.w900,
                              letterSpacing: isWide ? 12.0 : 8.0,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: isWide ? 16 : 8),
                          Text(
                            'Ruang aman untuk bercerita tanpa identitas.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.nunito(
                              fontSize: isWide ? 18 : 14,
                              height: 1.5,
                              color: Colors.white.withOpacity(0.8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        Container(
                          constraints: const BoxConstraints(maxWidth: 400),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF4B5A3),
                              foregroundColor: const Color(0xFF3F3734),
                              minimumSize: Size(
                                double.infinity,
                                isWide ? 60 : 50,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  transitionDuration: const Duration(
                                    milliseconds: 600,
                                  ),
                                  pageBuilder:
                                      (
                                        context,
                                        animation,
                                        secondaryAnimation,
                                      ) => const RegisterPage(),
                                  transitionsBuilder:
                                      (
                                        context,
                                        animation,
                                        secondaryAnimation,
                                        child,
                                      ) {
                                        return FadeTransition(
                                          opacity: animation,
                                          child: child,
                                        );
                                      },
                                ),
                              );
                            },
                            child: Text(
                              'MULAI PERJALANANMU',
                              style: GoogleFonts.nunito(
                                fontSize: isWide ? 16 : 14,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2.0,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: isWide ? 40 : 24),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: const Color(0xFF7B6F65),
                          size: isWide ? 40 : 30,
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
    );
  }

  Widget _buildAnonymousHighlight(BuildContext context) {
    final bool isWide = MediaQuery.of(context).size.width > 800;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: isWide ? 20 : 10,
        bottom: isWide ? 40 : 20,
        left: 24,
        right: 24,
      ),
      child: Column(
        children: [
          Text(
            '100% ANONIM. RAHASIAMU AMAN.',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: isWide ? 32 : 22,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF3F3734),
              letterSpacing: isWide ? 2.0 : 1.0,
            ),
          ),
          SizedBox(height: isWide ? 24 : 16),
          Container(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Text(
              'Di CatChat, identitas aslimu dihapus. Bebaskan dirimu, ceritakan segalanya, dan jadilah dirimu yang sebenarnya tanpa takut label atau penilaian dari siapapun.',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: isWide ? 18 : 14,
                color: const Color(0xFF7B6F65),
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageFeaturesSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              bool isWide = constraints.maxWidth > 800;
              return Column(
                children: [
                  _buildCinematicImageBlock(
                    imagePath: 'assets/images/feature_ai.jpg',
                    title: 'CHAT AI',
                    desc:
                        'Berbicara dengan teman virtual yang dirancang khusus untuk selalu mendengarkan keluh kesahmu, kapan saja, 24 jam sehari, tanpa menghakimi jalan pikiranmu.',
                    isReverse: false,
                    isWide: isWide,
                  ),
                  const SizedBox(height: 100),
                  _buildCinematicImageBlock(
                    imagePath: 'assets/images/feature_peer.jpg',
                    title: 'RUANG CURHAT',
                    desc:
                        'Terhubung dengan pengguna lain secara anonim. Temukan seseorang yang mengerti perasaanmu, berbagi cerita, dan sadari bahwa kamu tidak pernah benar-benar sendirian.',
                    isReverse: true,
                    isWide: isWide,
                  ),
                  const SizedBox(height: 100),
                  _buildCinematicImageBlock(
                    imagePath: 'assets/images/feature_journal.jpg',
                    title: 'JURNAL',
                    desc:
                        'Sebuah buku harian digital yang aman. Tulis setiap kenangan, luapkan rasa marah, atau simpan kebahagiaan kecilmu di tempat rahasia yang hanya bisa diakses olehmu.',
                    isReverse: false,
                    isWide: isWide,
                  ),
                  const SizedBox(height: 100),
                  _buildCinematicImageBlock(
                    imagePath: 'assets/images/feature_mood.jpg',
                    title: 'MOOD TRACKER',
                    desc:
                        'Sadari perubahan emosimu. Dengan grafik interaktif, kamu dapat memantau bagaimana perasaanmu naik turun setiap harinya untuk membangun kontrol mental yang lebih baik.',
                    isReverse: true,
                    isWide: isWide,
                  ),
                  const SizedBox(height: 100),
                  _buildCinematicImageBlock(
                    imagePath: 'assets/images/feature_prayer.jpg',
                    title: 'DINDING DOA',
                    desc:
                        'Tuliskan harapanmu ke dinding besar CatChat. Baca permohonan orang lain, dan mari kita saling menguatkan dengan memberikan semangat secara virtual.',
                    isReverse: false,
                    isWide: isWide,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCinematicImageBlock({
    required String imagePath,
    required String title,
    required String desc,
    required bool isReverse,
    required bool isWide,
  }) {
    // Ukuran responsif berdasarkan layar (Lebar vs Sempit/HP)
    final double imageHeight = isWide ? 400 : 180;
    final double titleSize = isWide ? 40 : 20;
    final double descSize = isWide ? 18 : 12;
    final double textPadding = isWide ? 48 : 16;
    final double radius = isWide ? 24 : 16;

    Widget imageWidget = Expanded(
      flex: isWide ? 5 : 1, // Pada HP, bagi ruang 50:50 atau 1:1
      child: Container(
        height: imageHeight,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF4B5A3).withOpacity(0.3),
              blurRadius: isWide ? 40 : 20,
              offset: Offset(0, isWide ? 20 : 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: Image.asset(
            imagePath,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: Colors.white,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image,
                      size: isWide ? 60 : 30,
                      color: const Color(0xFFF4B5A3),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Menunggu...',
                      style: TextStyle(
                        color: const Color(0xFF7B6F65),
                        fontSize: descSize,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    Widget textWidget = Expanded(
      flex: isWide ? 4 : 1, // Pada HP, bagi ruang 50:50
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: textPadding),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start, // Selalu rata kiri agar rapi bersisian
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              textAlign: TextAlign.left,
              style: GoogleFonts.nunito(
                fontSize: titleSize,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF3F3734),
                letterSpacing: 1.5,
              ),
            ),
            SizedBox(height: isWide ? 16 : 8),
            Text(
              desc,
              textAlign: TextAlign.left,
              style: GoogleFonts.nunito(
                fontSize: descSize,
                color: const Color(0xFF7B6F65),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );

    // Selalu gunakan Row (menyamping) sesuai permintaan, baik di HP maupun Desktop
    return Container(
      constraints: const BoxConstraints(maxWidth: 1200),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: isReverse
            ? [textWidget, imageWidget]
            : [imageWidget, textWidget],
      ),
    );
  }
}
