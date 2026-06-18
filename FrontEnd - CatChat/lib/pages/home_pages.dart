// Penjelasan file dan tujuannya:
// Nama file: home_pages.dart
// Deskripsi: File ini mengatur antarmuka pengguna (UI) dan apa yang dilihat pengguna di layar.
// Mengarahkan ke/Keterkaitan:
// - Mengarah ke Layar Lain: Menggunakan navigasi (Router) saat tombol ditekan.
// - Berhubungan dengan Controller: Mengambil dan mengirim data melalui file Controller yang relevan.



import 'package:flutter/material.dart';
import '../controllers/home_controller.dart';
import 'chat_pages.dart';
import 'dinding_doa_pages.dart';
import 'journal_pages.dart';
import 'mood_tracker.dart';
import 'profile_pages.dart';


// ==========================================
// Class HomePages
// Fungsi: Mendeklarasikan halaman/komponen visual ini.
// Mengarah ke: Biasanya dipanggil oleh router atau tombol navigasi di file lain.
// ==========================================
class HomePages extends StatefulWidget {
  const HomePages({super.key});

  @override
  State<HomePages> createState() => _HomePagesState();
}

class _HomePagesState extends State<HomePages> {
  final HomeController _controller = HomeController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onReturnFromDoa() {
    _controller.fetchLatestStories();
  }

  @override
  
  // Fungsi build: Bertugas menggambar (me-render) elemen visual/UI ke layar HP pengguna.
  // Menghubungkan data dari Controller ke dalam bentuk Widget (teks, tombol, gambar).
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 900;

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: Color(0xFFFAF4F0),
      appBar: isWide
          ? null
          : AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: const IconThemeData(color: Color(0xFF3F3734)),
            ),
      drawer: isWide
          ? null
          : Drawer(
              backgroundColor: Color(0xFFFAF4F0),
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: _NavigationSidebar(),
                ),
              ),
            ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(24, isWide ? 24 : 0, 24, 24),
          child: isWide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(width: 180,
                      child: _NavigationSidebar(onReturnFromDoa: _onReturnFromDoa),
                    ),
                    SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _HomeHeader(quote: _controller.selectedQuote, username: _controller.username),
                          SizedBox(height: 14),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _ShortcutButtonsRow(onReturnFromDoa: _onReturnFromDoa),
                                  SizedBox(height: 14),
                                  _MoodSummaryRow(),
                                  SizedBox(height: 14),
                                  _BottomContent(controller: _controller, onReturnFromDoa: _onReturnFromDoa),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    _HomeHeader(quote: _controller.selectedQuote, username: _controller.username),
                    SizedBox(height: 14),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _ShortcutButtonsRow(onReturnFromDoa: _onReturnFromDoa),
                            SizedBox(height: 14),
                            _MoodSummaryRow(),
                            SizedBox(height: 14),
                            _BottomContent(controller: _controller, onReturnFromDoa: _onReturnFromDoa),
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
}


// ==========================================
// Class _NavigationSidebar
// Fungsi: Mendeklarasikan halaman/komponen visual ini.
// Mengarah ke: Biasanya dipanggil oleh router atau tombol navigasi di file lain.
// ==========================================
class _NavigationSidebar extends StatelessWidget {
  final VoidCallback? onReturnFromDoa;
  const _NavigationSidebar({this.onReturnFromDoa});

  @override
  
  // Fungsi build: Bertugas menggambar (me-render) elemen visual/UI ke layar HP pengguna.
  // Menghubungkan data dari Controller ke dalam bentuk Widget (teks, tombol, gambar).
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 24, horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Color(0xFFE7D8CF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Catchat',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF3F3734),
            ),
          ),
          SizedBox(height: 16),
          const Divider(color: Color(0xFFE7D8CF), thickness: 1),
          SizedBox(height: 16),
          _SidebarItem(label: 'Home', selected: true),
          _SidebarItem(
            label: 'Chat',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChatPages()),
              );
            },
          ),
          _SidebarItem(
            label: 'Dinding Doa',
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DindingDoaPages()),
              );
              if (onReturnFromDoa != null) onReturnFromDoa!();
            },
          ),
          _SidebarItem(
            label: 'Mood Tracker',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MoodTracker()),
              );
            },
          ),
          _SidebarItem(
            label: 'Jurnal',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const JournalPages()),
              );
            },
          ),
          _SidebarItem(
            label: 'Profil',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePages()),
              );
            },
          ),
        ],
      ),
    );
  }
}


// ==========================================
// Class _SidebarItem
// Fungsi: Mendeklarasikan halaman/komponen visual ini.
// Mengarah ke: Biasanya dipanggil oleh router atau tombol navigasi di file lain.
// ==========================================
class _SidebarItem extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const _SidebarItem({required this.label, this.selected = false, this.onTap});

  @override
  
  // Fungsi build: Bertugas menggambar (me-render) elemen visual/UI ke layar HP pengguna.
  // Menghubungkan data dari Controller ke dalam bentuk Widget (teks, tombol, gambar).
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: selected ? Color(0xFFF4B5A3) : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected
                  ? Color(0xFF5D4A45)
                  : Color(0xFF7B6F65),
              fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}


// ==========================================
// Class _HomeHeader
// Fungsi: Mendeklarasikan halaman/komponen visual ini.
// Mengarah ke: Biasanya dipanggil oleh router atau tombol navigasi di file lain.
// ==========================================
class _HomeHeader extends StatelessWidget {
  final String quote;
  final String username;

  const _HomeHeader({required this.quote, required this.username});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 3 && hour < 11) {
      return 'Selamat Pagi,';
    } else if (hour >= 11 && hour < 15) {
      return 'Selamat Siang,';
    } else if (hour >= 15 && hour < 18) {
      return 'Selamat Sore,';
    } else {
      return 'Selamat Malam,';
    }
  }

  String _getSubGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 3 && hour < 11) {
      return '- Yuk mulai hari dengan senyuman ceria -';
    } else if (hour >= 11 && hour < 15) {
      return '- Tetap semangat menjalani hari ini -';
    } else if (hour >= 15 && hour < 18) {
      return '- Waktunya bersantai dan rehat sejenak -';
    } else {
      return '- Kamu sudah berjuang keras hari ini -';
    }
  }

  @override
  
  // Fungsi build: Bertugas menggambar (me-render) elemen visual/UI ke layar HP pengguna.
  // Menghubungkan data dari Controller ke dalam bentuk Widget (teks, tombol, gambar).
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Color(0xFFE7D8CF)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SizedBox(width: 6),
                    Image(
                      image: AssetImage('assets/images/logo2.png'),
                      width: 75,
                      height: 45,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Catchat',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF7B6F65),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  '${_getGreeting()} $username',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3F3734),
                  ),
                ),
                SizedBox(height: 8),
                SizedBox(
                  height: 72,
                  child: AnimatedSwitcher(
                    duration: Duration(milliseconds: 850),
                    switchInCurve: Curves.easeOutQuart,
                    switchOutCurve: Curves.easeInQuart,
                  layoutBuilder: (currentChild, previousChildren) {
                    return Stack(
                      alignment: Alignment.centerLeft,
                      children: [...previousChildren, ?currentChild],
                    );
                  },
                  transitionBuilder: (child, animation) {
                    final curved = CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeInOut,
                    );
                    return FadeTransition(
                      opacity: curved,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: Offset(0, 0.1),
                          end: Offset.zero,
                        ).animate(curved),
                        child: child,
                      ),
                    );
                  },
                  child: SizedBox(
                    key: ValueKey(quote),
                    width: double.infinity,
                    child: Text(
                      quote,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.6,
                        color: Color(0xFF6D5650),
                      ),
                    ),
                    ),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  _getSubGreeting(),
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    fontStyle: FontStyle.italic,
                    color: Color(0xFF6D5650),
                  ),
                ),
              ],
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Image.asset(
              'assets/images/logo1.jpg',
              width: 96,
              height: 96,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}


// ==========================================
// Class _ShortcutButtonsRow
// Fungsi: Mendeklarasikan halaman/komponen visual ini.
// Mengarah ke: Biasanya dipanggil oleh router atau tombol navigasi di file lain.
// ==========================================
class _ShortcutButtonsRow extends StatelessWidget {
  final VoidCallback? onReturnFromDoa;
  const _ShortcutButtonsRow({this.onReturnFromDoa});

  @override
  
  // Fungsi build: Bertugas menggambar (me-render) elemen visual/UI ke layar HP pengguna.
  // Menghubungkan data dari Controller ke dalam bentuk Widget (teks, tombol, gambar).
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Color(0xFFE7D8CF)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ShortcutButton(
              label: 'Mulai Curhat',
              color: Color(0xFFB0B8BE),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ChatPages()),
                );
              },
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: _ShortcutButton(
              label: 'Lihat Cerita Anonim',
              color: Color(0xFFF4B5A3),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DindingDoaPages(showOnlyAnon: true),
                  ),
                );
                if (onReturnFromDoa != null) onReturnFromDoa!();
              },
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: _ShortcutButton(
              label: 'Cek Statistik Mood',
              color: Color(0xFFB0B8BE),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MoodTracker()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


// ==========================================
// Class _ShortcutButton
// Fungsi: Mendeklarasikan halaman/komponen visual ini.
// Mengarah ke: Biasanya dipanggil oleh router atau tombol navigasi di file lain.
// ==========================================
class _ShortcutButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ShortcutButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  
  // Fungsi build: Bertugas menggambar (me-render) elemen visual/UI ke layar HP pengguna.
  // Menghubungkan data dari Controller ke dalam bentuk Widget (teks, tombol, gambar).
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xFFCCC0B7)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF3F3734),
            ),
          ),
        ),
      ),
    );
  }
}


// ==========================================
// Class _MoodSummaryRow
// Fungsi: Mendeklarasikan halaman/komponen visual ini.
// Mengarah ke: Biasanya dipanggil oleh router atau tombol navigasi di file lain.
// ==========================================
class _MoodSummaryRow extends StatelessWidget {
  const _MoodSummaryRow();

  @override
  
  // Fungsi build: Bertugas menggambar (me-render) elemen visual/UI ke layar HP pengguna.
  // Menghubungkan data dari Controller ke dalam bentuk Widget (teks, tombol, gambar).
  Widget build(BuildContext context) {
    return Row(
      children: [
        _MoodStatusCard(label: 'Senang', imagePath: 'assets/images/senang.png', color: Color(0xFFF1C5B3)),
        SizedBox(width: 16),
        _MoodStatusCard(label: 'Sedih', imagePath: 'assets/images/sedih.png', color: Color(0xFFF4D9CD)),
        SizedBox(width: 16),
        _MoodStatusCard(label: 'Capek', imagePath: 'assets/images/capek.png', color: Color(0xFFD8D4E3)),
        SizedBox(width: 16),
        _MoodStatusCard(label: 'Biasa Aja', imagePath: 'assets/images/biasa_aja.png', color: Color(0xFFE6E1EA)),
      ],
    );
  }
}


// ==========================================
// Class _MoodStatusCard
// Fungsi: Mendeklarasikan halaman/komponen visual ini.
// Mengarah ke: Biasanya dipanggil oleh router atau tombol navigasi di file lain.
// ==========================================
class _MoodStatusCard extends StatelessWidget {
  final String label;
  final String imagePath;
  final Color color;

  const _MoodStatusCard({required this.label, required this.imagePath, required this.color});

  @override
  
  // Fungsi build: Bertugas menggambar (me-render) elemen visual/UI ke layar HP pengguna.
  // Menghubungkan data dari Controller ke dalam bentuk Widget (teks, tombol, gambar).
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Color(0xFFE7D8CF)),
        ),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              height: 48,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
              ),
            ),
            Positioned.fill(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(imagePath, height: 48, fit: BoxFit.contain),
                  SizedBox(height: 4),
                  Text(
                    label,
                    style: TextStyle(
                      color: Color(0xFF4A3A36),
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// ==========================================
// Class _BottomContent
// Fungsi: Mendeklarasikan halaman/komponen visual ini.
// Mengarah ke: Biasanya dipanggil oleh router atau tombol navigasi di file lain.
// ==========================================
class _BottomContent extends StatelessWidget {
  final HomeController controller;
  final VoidCallback? onReturnFromDoa;
  const _BottomContent({required this.controller, this.onReturnFromDoa});

  @override
  
  // Fungsi build: Bertugas menggambar (me-render) elemen visual/UI ke layar HP pengguna.
  // Menghubungkan data dari Controller ke dalam bentuk Widget (teks, tombol, gambar).
  Widget build(BuildContext context) {
    return _RightSidePanels(controller: controller, onReturnFromDoa: onReturnFromDoa);
  }
}




// ==========================================
// Class _RightSidePanels
// Fungsi: Mendeklarasikan halaman/komponen visual ini.
// Mengarah ke: Biasanya dipanggil oleh router atau tombol navigasi di file lain.
// ==========================================
class _RightSidePanels extends StatelessWidget {
  final HomeController controller;
  final VoidCallback? onReturnFromDoa;
  const _RightSidePanels({required this.controller, this.onReturnFromDoa});

  @override
  
  // Fungsi build: Bertugas menggambar (me-render) elemen visual/UI ke layar HP pengguna.
  // Menghubungkan data dari Controller ke dalam bentuk Widget (teks, tombol, gambar).
  Widget build(BuildContext context) {
    return Column(
      children: [
        _RightStoriesPanel(controller: controller),
        SizedBox(height: 20),
        _WriteStoryPanel(onReturnFromDoa: onReturnFromDoa),
      ],
    );
  }
}


// ==========================================
// Class _RightStoriesPanel
// Fungsi: Mendeklarasikan halaman/komponen visual ini.
// Mengarah ke: Biasanya dipanggil oleh router atau tombol navigasi di file lain.
// ==========================================
class _RightStoriesPanel extends StatefulWidget {
  final HomeController controller;
  const _RightStoriesPanel({required this.controller});

  @override
  State<_RightStoriesPanel> createState() => _RightStoriesPanelState();
}

class _RightStoriesPanelState extends State<_RightStoriesPanel> {
  final ScrollController _scrollController = ScrollController();

  void _toggleLike(int index) {
    widget.controller.toggleRightStoryLike(index);
    setState(() {});
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  
  // Fungsi build: Bertugas menggambar (me-render) elemen visual/UI ke layar HP pengguna.
  // Menghubungkan data dari Controller ke dalam bentuk Widget (teks, tombol, gambar).
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Color(0xFFE7D8CF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Cerita Terbaru di Dinding Doa',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF3F3734),
            ),
          ),
          SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: widget.controller.rightStories.length,
                separatorBuilder: (context, index) =>
                    SizedBox(height: 14),
                itemBuilder: (context, index) {
                  return Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 38,
                          decoration: BoxDecoration(
                            color: Color(0xFFF7F1EE),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Color(0xFFE6D9D2)),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 14),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            widget.controller.rightStories[index]['content'] ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Color(0xFF6D5650),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFF4B5A3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          minimumSize: const Size(88, 44),
                        ),
                        onPressed: () => _toggleLike(index),
                        icon: Icon(
                          widget.controller.likedStories.contains(widget.controller.rightStories[index]['id'])
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: widget.controller.likedStories.contains(widget.controller.rightStories[index]['id'])
                              ? Colors.red
                              : Color(0xFF5D4A45),
                        ),
                        label: Text(
                          'Doa',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF5D4A45),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
        ],
      ),
    );
  }
}


// ==========================================
// Class _WriteStoryPanel
// Fungsi: Mendeklarasikan halaman/komponen visual ini.
// Mengarah ke: Biasanya dipanggil oleh router atau tombol navigasi di file lain.
// ==========================================
class _WriteStoryPanel extends StatelessWidget {
  final VoidCallback? onReturnFromDoa;
  const _WriteStoryPanel({this.onReturnFromDoa});

  @override
  
  // Fungsi build: Bertugas menggambar (me-render) elemen visual/UI ke layar HP pengguna.
  // Menghubungkan data dari Controller ke dalam bentuk Widget (teks, tombol, gambar).
  Widget build(BuildContext context) {
    return Container(
      height: 86,
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Color(0xFFE7D8CF)),
      ),
      child: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFF4B5A3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            minimumSize: const Size.fromHeight(50),
          ),
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const DindingDoaPages(showMyStoriesOnly: true),
              ),
            );
            if (onReturnFromDoa != null) onReturnFromDoa!();
          },
          child: Text(
            '+ Tuliskan Ceritamu',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF5D4A45),
            ),
          ),
        ),
      ),
    );
  }
}
