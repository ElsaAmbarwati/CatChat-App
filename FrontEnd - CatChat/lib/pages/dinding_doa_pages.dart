import '../widgets/constrained_scaffold.dart';
// Penjelasan file dan tujuannya:
// Nama file: dinding_doa_pages.dart
// Deskripsi: File ini mengatur antarmuka pengguna (UI) dan apa yang dilihat pengguna di layar.
// Mengarahkan ke/Keterkaitan:
// - Mengarah ke Layar Lain: Menggunakan navigasi (Router) saat tombol ditekan.
// - Berhubungan dengan Controller: Mengambil dan mengirim data melalui file Controller yang relevan.

import 'package:flutter/material.dart';
import '../controllers/dinding_doa_controller.dart';


// ==========================================
// Class DindingDoaPages
// Fungsi: Mendeklarasikan halaman/komponen visual ini.
// Mengarah ke: Biasanya dipanggil oleh router atau tombol navigasi di file lain.
// ==========================================
class DindingDoaPages extends StatefulWidget {
  final bool showOnlyAnon;
  final bool showMyStoriesOnly;

  const DindingDoaPages({
    super.key,
    this.showOnlyAnon = false,
    this.showMyStoriesOnly = false,
  });

  @override
  State<DindingDoaPages> createState() => _DindingDoaPagesState();
}

class _DindingDoaPagesState extends State<DindingDoaPages> {
  final TextEditingController _inputController = TextEditingController();
  final DindingDoaController _controller = DindingDoaController();

  void _addStory() {
    _controller.addStory(_inputController.text, widget.showMyStoriesOnly);
    _inputController.clear();
  }

  @override
  void dispose() {
    _inputController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  
  // Fungsi build: Bertugas menggambar (me-render) elemen visual/UI ke layar HP pengguna.
  // Menghubungkan data dari Controller ke dalam bentuk Widget (teks, tombol, gambar).
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 900;

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return ConstrainedScaffold(
      backgroundColor: Color(0xFFFAF4F0),
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              child: Column(
                children: [
                        _Header(
                          onBack: () =>
                              Navigator.of(context).popUntil((route) => route.isFirst),
                        ),
                        SizedBox(height: 14),
                        if (widget.showOnlyAnon)
                          Expanded(
                            child: _AnonymousStoriesPanel(
                              stories: _controller.anonStories,
                              likedStories: _controller.likedAnonStories,
                              onToggleLike: _controller.toggleLike,
                            ),
                          )
                        else if (widget.showMyStoriesOnly)
                          Expanded(
                            child: Column(
                              children: [
                                Expanded(child: _MyStoriesPanel(
                                  stories: _controller.myStories,
                                  onDelete: _controller.deleteStory,
                                  onEdit: _controller.editStory,
                                  onTogglePrivacy: _controller.toggleMyStoryPrivacy,
                                )),
                                SizedBox(height: 14),
                                _Composer(
                                  controller: _inputController,
                                  onSend: _addStory,
                                ),
                              ],
                            ),
                          )
                        else
                          Expanded(
                            child: Column(
                              children: [
                                Expanded(
                                  child: isWide
                                      ? Row(
                                          crossAxisAlignment: CrossAxisAlignment.stretch,
                                          children: [
                                            Expanded(
                                              flex: 2,
                                              child: _AnonymousStoriesPanel(
                                                stories: _controller.anonStories,
                                                likedStories: _controller.likedAnonStories,
                                                onToggleLike: _controller.toggleLike,
                                              ),
                                            ),
                                            SizedBox(width: 14),
                                            Expanded(
                                              flex: 1,
                                                child: _MyStoriesPanel(
                                                  stories: _controller.myStories,
                                                  onDelete: _controller.deleteStory,
                                                  onEdit: _controller.editStory,
                                                  onTogglePrivacy: _controller.toggleMyStoryPrivacy,
                                                ),
                                            ),
                                          ],
                                        )
                                      : Column(
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Color(0xFFF7F1EE),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              padding: EdgeInsets.all(6),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: GestureDetector(
                                                      onTap: () => _controller.setMobileTabIndex(0),
                                                      child: Container(
                                                        padding: EdgeInsets.symmetric(vertical: 12),
                                                        decoration: BoxDecoration(
                                                          color: _controller.selectedMobileTabIndex == 0 ? Colors.white : Colors.transparent,
                                                          borderRadius: BorderRadius.circular(16),
                                                          boxShadow: _controller.selectedMobileTabIndex == 0
                                                              ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: Offset(0, 2))]
                                                              : null,
                                                        ),
                                                        alignment: Alignment.center,
                                                        child: Text(
                                                          'Cerita Anonim',
                                                          style: TextStyle(
                                                            fontWeight: FontWeight.bold,
                                                            color: _controller.selectedMobileTabIndex == 0 ? Color(0xFF3F3734) : Color(0xFF7B6F65),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: GestureDetector(
                                                      onTap: () => _controller.setMobileTabIndex(1),
                                                      child: Container(
                                                        padding: EdgeInsets.symmetric(vertical: 12),
                                                        decoration: BoxDecoration(
                                                          color: _controller.selectedMobileTabIndex == 1 ? Colors.white : Colors.transparent,
                                                          borderRadius: BorderRadius.circular(16),
                                                          boxShadow: _controller.selectedMobileTabIndex == 1
                                                              ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: Offset(0, 2))]
                                                              : null,
                                                        ),
                                                        alignment: Alignment.center,
                                                        child: Text(
                                                          'Cerita Saya',
                                                          style: TextStyle(
                                                            fontWeight: FontWeight.bold,
                                                            color: _controller.selectedMobileTabIndex == 1 ? Color(0xFF3F3734) : Color(0xFF7B6F65),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(height: 14),
                                            Expanded(
                                              child: _controller.selectedMobileTabIndex == 0
                                                  ? _AnonymousStoriesPanel(
                                                      stories: _controller.anonStories,
                                                      likedStories: _controller.likedAnonStories,
                                                      onToggleLike: _controller.toggleLike,
                                                    )
                                                  : _MyStoriesPanel(
                                                      stories: _controller.myStories,
                                                      onDelete: _controller.deleteStory,
                                                      onEdit: _controller.editStory,
                                                      onTogglePrivacy: _controller.toggleMyStoryPrivacy,
                                                    ),
                                            ),
                                          ],
                                        ),
                                ),
                                SizedBox(height: 14),
                                _Composer(
                                  controller: _inputController,
                                  onSend: _addStory,
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        );
      },
    );
  }
}


// ==========================================
// Class _Header
// Fungsi: Mendeklarasikan halaman/komponen visual ini.
// Mengarah ke: Biasanya dipanggil oleh router atau tombol navigasi di file lain.
// ==========================================
class _Header extends StatelessWidget {
  final VoidCallback onBack;

  const _Header({required this.onBack});

  @override
  
  // Fungsi build: Bertugas menggambar (me-render) elemen visual/UI ke layar HP pengguna.
  // Menghubungkan data dari Controller ke dalam bentuk Widget (teks, tombol, gambar).
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 900;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: isWide ? 18 : 12, 
        horizontal: isWide ? 18 : 12
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Color(0xFFE7D8CF)),
      ),
      child: Row(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onBack,
            child: Container(
              width: isWide ? 30 : 24,
              height: isWide ? 30 : 24,
              decoration: BoxDecoration(
                color: Color(0xFFF7F1EE),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.arrow_back, size: isWide ? 20 : 16, color: Color(0xFF5D4A45)),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Dinding Doa',
              style: TextStyle(
                fontSize: isWide ? 24 : 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3F3734),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


// ==========================================
// Class _AnonymousStoriesPanel
// Fungsi: Mendeklarasikan halaman/komponen visual ini.
// Mengarah ke: Biasanya dipanggil oleh router atau tombol navigasi di file lain.
// ==========================================
class _AnonymousStoriesPanel extends StatelessWidget {
  final List<Map<String, dynamic>> stories;
  final Set<int> likedStories;
  final ValueChanged<int> onToggleLike;

  const _AnonymousStoriesPanel({
    required this.stories,
    required this.likedStories,
    required this.onToggleLike,
  });

  @override
  
  // Fungsi build: Bertugas menggambar (me-render) elemen visual/UI ke layar HP pengguna.
  // Menghubungkan data dari Controller ke dalam bentuk Widget (teks, tombol, gambar).
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Color(0xFFE7D8CF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Cerita Anonim',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF3F3734),
            ),
          ),
          SizedBox(height: 10),
          const Divider(color: Color(0xFFE7D8CF), thickness: 1.2),
          SizedBox(height: 8),
          Text(
            'Cerita anonim ini dibuat oleh teman-temanmu tanpa nama.',
            style: TextStyle(
              fontSize: 13,
              height: 1.6,
              color: Color(0xFF7B6F65),
            ),
          ),
          SizedBox(height: 14),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: stories.length,
              separatorBuilder: (context, index) => SizedBox(height: 12),
              itemBuilder: (context, index) {
                return Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xFFF7F1EE),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Color(0xFFE6D9D2)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Color(0xFFF4B5A3),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.person_outline,
                          color: Color(0xFF5D4A45),
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              stories[index]['content'] ?? '',
                              style: TextStyle(
                                fontSize: 15,
                                color: Color(0xFF3F3734),
                              ),
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                Text(
                                  'Anonim',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF7B6F65),
                                  ),
                                ),
                                Spacer(),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFFF4B5A3),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    minimumSize: const Size(88, 44),
                                  ),
                                  onPressed: () => onToggleLike(index),
                                  icon: Icon(
                                    likedStories.contains(stories[index]['id'])
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: likedStories.contains(stories[index]['id'])
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
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
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
// Class _MyStoriesPanel
// Fungsi: Mendeklarasikan halaman/komponen visual ini.
// Mengarah ke: Biasanya dipanggil oleh router atau tombol navigasi di file lain.
// ==========================================
class _MyStoriesPanel extends StatelessWidget {
  final List<Map<String, dynamic>> stories;
  final ValueChanged<int> onDelete;
  final void Function(int, String) onEdit;
  final ValueChanged<int> onTogglePrivacy;

  const _MyStoriesPanel({
    required this.stories,
    required this.onDelete,
    required this.onEdit,
    required this.onTogglePrivacy,
  });

  void _showEditDialog(BuildContext context, int index, String currentContent) {
    final controller = TextEditingController(text: currentContent);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Color(0xFFFAF4F0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Edit Cerita', style: TextStyle(color: Color(0xFF3F3734), fontWeight: FontWeight.bold)),
          content: TextField(
            controller: controller,
            maxLines: 3,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal', style: TextStyle(color: Color(0xFF7B6F65))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFF4B5A3),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                onEdit(index, controller.text);
                Navigator.pop(context);
              },
              child: Text('Simpan', style: TextStyle(color: Color(0xFF5D4A45))),
            ),
          ],
        );
      },
    );
  }

  @override
  
  // Fungsi build: Bertugas menggambar (me-render) elemen visual/UI ke layar HP pengguna.
  // Menghubungkan data dari Controller ke dalam bentuk Widget (teks, tombol, gambar).
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Color(0xFFE7D8CF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Cerita Saya',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF3F3734),
            ),
          ),
          SizedBox(height: 12),
          const Divider(color: Color(0xFFE7D8CF), thickness: 1.2),
          SizedBox(height: 8),
          Text(
            'Cerita yang pernah kamu tulis.',
            style: TextStyle(
              fontSize: 13,
              height: 1.6,
              color: Color(0xFF7B6F65),
            ),
          ),
          SizedBox(height: 12),
          Expanded(
            child: stories.isEmpty
                ? Center(
                    child: Text(
                      'Belum ada cerita',
                      style: TextStyle(fontSize: 14, color: Color(0xFF7B6F65)),
                    ),
                  )
                : ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: stories.length,
                    separatorBuilder: (context, index) =>
                        SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final isPrivate = (stories[index]['is_private'] == 1 || stories[index]['is_private'] == true);
                      return Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Color(0xFFF7F1EE),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Color(0xFFE6D9D2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.favorite, color: Colors.red, size: 16),
                                    SizedBox(width: 4),
                                    Text(
                                      '${stories[index]['prayer_count'] ?? 0} Doa',
                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF5D4A45)),
                                    ),
                                    SizedBox(width: 12),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isPrivate ? Color(0xFFD8D4E3) : Color(0xFFE6E1EA),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        isPrivate ? 'Privat' : 'Publik',
                                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF5D4A45)),
                                      ),
                                    ),
                                  ],
                                ),
                                PopupMenuButton<String>(
                                  onSelected: (val) {
                                    if (val == 'edit') {
                                      _showEditDialog(context, index, stories[index]['content'] ?? '');
                                    } else if (val == 'privacy') {
                                      onTogglePrivacy(index);
                                    } else if (val == 'delete') {
                                      onDelete(index);
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(value: 'edit', child: Text('Edit Cerita')),
                                    PopupMenuItem(value: 'privacy', child: Text(isPrivate ? 'Jadikan Publik' : 'Jadikan Privat')),
                                    const PopupMenuItem(value: 'delete', child: Text('Hapus Cerita', style: TextStyle(color: Colors.red))),
                                  ],
                                  icon: Icon(Icons.more_vert, size: 20, color: Color(0xFF7B6F65)),
                                  padding: EdgeInsets.zero,
                                ),
                              ],
                            ),
                            SizedBox(height: 6),
                            Text(
                              stories[index]['content'] ?? '',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF3F3734),
                              ),
                            ),
                          ],
                        ),
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
// Class _Composer
// Fungsi: Mendeklarasikan halaman/komponen visual ini.
// Mengarah ke: Biasanya dipanggil oleh router atau tombol navigasi di file lain.
// ==========================================
class _Composer extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const _Composer({required this.controller, required this.onSend});

  @override
  
  // Fungsi build: Bertugas menggambar (me-render) elemen visual/UI ke layar HP pengguna.
  // Menghubungkan data dari Controller ke dalam bentuk Widget (teks, tombol, gambar).
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Color(0xFFE7D8CF)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              minLines: 1,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Tulis ceritamu di sini...',
                filled: true,
                fillColor: Color(0xFFF7F1EE),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 15,
                ),
              ),
            ),
          ),
          SizedBox(width: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFF4B5A3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              minimumSize: const Size(120, 52),
            ),
            onPressed: onSend,
            child: Text(
              'Kirim Cerita',
              style: TextStyle(
                color: Color(0xFF5D4A45),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

