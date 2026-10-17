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
import 'peer_chat_lobby_page.dart';

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
                          SizedBox(height: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _MoodSummaryRow(),
                                SizedBox(height: 10),
                                Expanded(
                                  child: _BottomContent(controller: _controller, onReturnFromDoa: _onReturnFromDoa),
                                ),
                              ],
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
                    SizedBox(height: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _ShortcutButtonsRow(onReturnFromDoa: _onReturnFromDoa),
                          SizedBox(height: 10),
                          _MoodSummaryRow(),
                          SizedBox(height: 10),
                          Expanded(
                            child: _BottomContent(controller: _controller, onReturnFromDoa: _onReturnFromDoa),
                          ),
                        ],
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
            label: 'Statistik Mood',
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
      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.transparent,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SizedBox(width: 4),
                    Image(
                      image: AssetImage('assets/images/logo2.png'),
                      width: 60,
                      height: 36,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Catchat',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF7B6F65),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6),
                Text(
                  '${_getGreeting()} $username',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3F3734),
                  ),
                ),
                SizedBox(height: 6),
                SizedBox(
                  height: 38,
                  child: AnimatedSwitcher(
                    duration: Duration(milliseconds: 850),
                    switchInCurve: Curves.easeOutQuart,
                    switchOutCurve: Curves.easeInQuart,
                  layoutBuilder: (currentChild, previousChildren) {
                    return Stack(
                      alignment: Alignment.centerLeft,
                      children: [...previousChildren, if (currentChild != null) currentChild],
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
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.5,
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
                    fontSize: 11,
                    height: 1.4,
                    fontStyle: FontStyle.italic,
                    color: Color(0xFF6D5650),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              'assets/images/logo1.jpg',
              width: 72,
              height: 72,
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
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Color(0xFFE7D8CF)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _ShortcutButton(
                  label: 'Chat',
                  icon: Icons.chat_bubble_outline,
                  color: Color(0xFFF4B5A3),
                  onTap: () => _showChatPickerDialog(context),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _ShortcutButton(
                  label: 'Dinding Doa',
                  icon: Icons.article_outlined,
                  color: Color(0xFFB0B8BE),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DindingDoaPages(),
                      ),
                    );
                    if (onReturnFromDoa != null) onReturnFromDoa!();
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _ShortcutButton(
                  label: 'Statistik Mood',
                  icon: Icons.bar_chart,
                  color: Color(0xFFF4B5A3),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MoodTracker()),
                    );
                  },
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _ShortcutButton(
                  label: 'Jurnal',
                  icon: Icons.book_outlined,
                  color: Color(0xFFB0B8BE),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const JournalPages()),
                    );
                  },
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _ShortcutButton(
                  label: 'Profil',
                  icon: Icons.person_outline,
                  color: Color(0xFFF4B5A3),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfilePages()),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


// ==========================================
// Class _ShortcutButton
// ==========================================
class _ShortcutButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  final IconData? icon;

  const _ShortcutButton({
    required this.label,
    required this.color,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFFCCC0B7)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) Icon(icon, size: 16, color: const Color(0xFF3F3734)),
            if (icon != null) const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color(0xFF3F3734),
              ),
            ),
          ],
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
        SizedBox(width: 6),
        _MoodStatusCard(label: 'Sedih', imagePath: 'assets/images/sedih.png', color: Color(0xFFF4D9CD)),
        SizedBox(width: 6),
        _MoodStatusCard(label: 'Capek', imagePath: 'assets/images/capek.png', color: Color(0xFFD8D4E3)),
        SizedBox(width: 6),
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
        height: 74,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Color(0xFFE7D8CF)),
        ),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              height: 28,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(12),
                ),
              ),
            ),
            Positioned.fill(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(imagePath, height: 34, fit: BoxFit.contain),
                  SizedBox(height: 2),
                  Text(
                    label,
                    style: TextStyle(
                      color: Color(0xFF4A3A36),
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
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
        Expanded(child: _RightStoriesPanel(controller: controller)),
        SizedBox(height: 10),
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
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Color(0xFFE7D8CF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Cerita Terbaru di Dinding Doa',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF3F3734),
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: widget.controller.rightStories.length,
              separatorBuilder: (context, index) =>
                  SizedBox(height: 8),
              itemBuilder: (context, index) {
                  return Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 28,
                          decoration: BoxDecoration(
                            color: Color(0xFFF7F1EE),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Color(0xFFE6D9D2)),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            widget.controller.rightStories[index]['content'] ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Color(0xFF6D5650),
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFF4B5A3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          minimumSize: const Size(60, 28),
                        ),
                        onPressed: () => _toggleLike(index),
                        icon: Icon(
                          widget.controller.likedStories.contains(widget.controller.rightStories[index]['id'])
                              ? Icons.favorite
                              : Icons.favorite_border,
                          size: 14,
                          color: widget.controller.likedStories.contains(widget.controller.rightStories[index]['id'])
                              ? Colors.red
                              : Color(0xFF5D4A45),
                        ),
                        label: Text(
                          'Doa',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF5D4A45),
                          ),
                        ),
                      ),
                    ],
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
      height: 52,
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xFFE7D8CF)),
      ),
      child: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFF4B5A3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            minimumSize: const Size.fromHeight(36),
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

// ==========================================
// Fungsi _showChatPickerDialog
// Fungsi: Menampilkan dialog pilihan antara Chat AI dan Chat Anonim.
// ==========================================
void _showChatPickerDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: const Color(0xFFFAF4F0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Pilih Tipe Chat',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3F3734),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Kamu mau curhat ke siapa?',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF7B6F65),
              ),
            ),
            const SizedBox(height: 14),
            _ChatPickerOption(
              icon: Icons.smart_toy_outlined,
              iconColor: const Color(0xFF7B6F65),
              bgColor: const Color(0xFFE7D8CF),
              title: 'Chat AI',
              subtitle: 'Curhat ke teman AI yang selalu siap mendengarkan tanpa menghakimi.',
              onTap: () {
                Navigator.of(ctx).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ChatPages()),
                );
              },
            ),
            const SizedBox(height: 8),
            _ChatPickerOption(
              icon: Icons.people_outline,
              iconColor: const Color(0xFF5D4A45),
              bgColor: const Color(0xFFF4B5A3),
              title: 'Chat Anonim',
              subtitle: 'Ngobrol anonim dengan pengguna lain secara acak.',
              onTap: () {
                Navigator.of(ctx).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PeerChatLobbyPage()),
                );
              },
            ),
          ],
        ),
      ),
    ),
  );
}


// ==========================================
// Class _ChatPickerOption
// Fungsi: Opsi dalam dialog pemilih tipe chat.
// ==========================================
class _ChatPickerOption extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ChatPickerOption({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE7D8CF)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3F3734),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF7B6F65),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFFB0A89E), size: 20),
          ],
        ),
      ),
    );
  }
}
