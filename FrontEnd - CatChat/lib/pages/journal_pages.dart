import '../widgets/constrained_scaffold.dart';
// Penjelasan file dan tujuannya:
// Nama file: journal_pages.dart
// Deskripsi: File ini mengatur antarmuka pengguna (UI) dan apa yang dilihat pengguna di layar.
// Mengarahkan ke/Keterkaitan:
// - Mengarah ke Layar Lain: Menggunakan navigasi (Router) saat tombol ditekan.
// - Berhubungan dengan Controller: Mengambil dan mengirim data melalui file Controller yang relevan.

import 'dart:ui';
import 'package:flutter/material.dart';

import '../models/journal_entry.dart';
import '../controllers/journal_controller.dart';


// ==========================================
// Class JournalPages
// Fungsi: Mendeklarasikan halaman/komponen visual ini.
// Mengarah ke: Biasanya dipanggil oleh router atau tombol navigasi di file lain.
// ==========================================
class JournalPages extends StatefulWidget {
  const JournalPages({super.key});

  @override
  State<JournalPages> createState() => _JournalPagesState();
}

class _JournalPagesState extends State<JournalPages> {
  final JournalController _controller = JournalController();

  final List<String> _moodOptions = ['senang', 'sedih', 'capek', 'biasa'];
  final List<String> _moodLabels = ['Senang', 'Sedih', 'Capek', 'Biasa'];
  final Map<String, String> _moodImages = {
    'senang': 'assets/images/senang.png',
    'sedih': 'assets/images/sedih.png',
    'capek': 'assets/images/capek.png',
    'biasa': 'assets/images/biasa_aja.png',
  };
  final Map<String, Color> _moodColors = {
    'senang': Color(0xFFF4B5A3),
    'sedih': Color(0xFF9EC5FF),
    'capek': Color(0xFFE6D9D2),
    'biasa': Color(0xFFF7F1EE),
  };

  void _showAddEditDialog([JournalEntry? existingEntry]) {
    final titleCtrl = TextEditingController(text: existingEntry?.title ?? '');
    final contentCtrl = TextEditingController(text: existingEntry?.content ?? '');

    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Tutup',
      barrierColor: Colors.black54,
      transitionDuration: Duration(milliseconds: 220),
      pageBuilder: (context, animation, secondaryAnimation) {
        final entryDate = existingEntry?.date ?? DateTime.now();
        String selectedMood = existingEntry?.mood ?? _moodOptions[0];

        return StatefulBuilder(
          builder: (context, setLocalState) {
            return ConstrainedScaffold(
              backgroundColor: Colors.white,
              resizeToAvoidBottomInset: false,
              body: SingleChildScrollView(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: SafeArea(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: 20,
                        right: 20,
                        top: 12,
                        bottom: 20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Color(0xFFF7F1EE),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                Icons.arrow_back,
                                color: Color(0xFF5D4A45),
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              existingEntry == null ? 'Ceritakan Harimu' : 'Edit Jurnal',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF3F3734),
                              ),
                            ),
                          ),
                          Text(
                            '${entryDate.day} ${_monthShort(entryDate.month)} ${entryDate.year}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF9B8E86),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      TextField(
                        controller: titleCtrl,
                        decoration: InputDecoration(
                          hintText: 'Judul (opsional)',
                          filled: true,
                          fillColor: Color(0xFFF7F1EE),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      Expanded(
                        child: TextField(
                          controller: contentCtrl,
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          expands: true,
                          textAlignVertical: TextAlignVertical.top,
                          decoration: InputDecoration(
                            hintText:
                                'Tulis apa yang kamu rasakan, pikiran, atau kejadian hari ini...',
                            alignLabelWithHint: true,
                            filled: true,
                            fillColor: Color(0xFFF7F1EE),
                            contentPadding: EdgeInsets.fromLTRB(
                              12,
                              16,
                              12,
                              16,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Text(
                            'Mood:',
                            style: TextStyle(color: Color(0xFF6D5650)),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Wrap(
                              spacing: 8,
                              children: _moodOptions.asMap().entries.map((e) {
                                final idx = e.key;
                                final key = e.value;
                                final label = _moodLabels.length > idx
                                    ? _moodLabels[idx]
                                    : '';
                                final isSelected = key == selectedMood;
                                final imagePath =
                                    _moodImages[key] ??
                                    'assets/images/biasa_aja.png';
                                final bg =
                                    _moodColors[key] ?? Color(0xFFFDF7F6);

                                return GestureDetector(
                                  onTap: () =>
                                      setLocalState(() => selectedMood = key),
                                  child: AnimatedContainer(
                                    duration: Duration(milliseconds: 180),
                                    padding: EdgeInsets.symmetric(
                                      vertical: 8,
                                      horizontal: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? bg.withValues(alpha: 0.95)
                                          : bg,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: isSelected
                                            ? Color(0xFFF4B5A3)
                                            : Color(0xFFE6D9D2),
                                        width: isSelected ? 1.6 : 1.0,
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(width: 50,
                                          height: 50,
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            alignment: Alignment.center,
                                            child: Image.asset(
                                              imagePath,
                                              filterQuality: FilterQuality.high,
                                              isAntiAlias: true,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          label,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: isSelected
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                            color: isSelected
                                                ? Color(0xFF5D4A45)
                                                : Color(0xFF9B8E86),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${contentCtrl.text.length} chars',
                          style: TextStyle(color: Color(0xFF9B8E86)),
                        ),
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                titleCtrl.clear();
                                contentCtrl.clear();
                                Navigator.of(context).pop();
                              },
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: Color(0xFFE6D9D2),
                                ),
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Batal',
                                style: TextStyle(color: Color(0xFF6D5650)),
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                final title = titleCtrl.text.trim();
                                final content = contentCtrl.text.trim();
                                if (title.isEmpty && content.isEmpty) return;
                                
                                if (existingEntry == null) {
                                  _controller.addEntry(title, content, selectedMood);
                                } else {
                                  _controller.updateEntry(existingEntry.id, title, content, selectedMood);
                                }
                                Navigator.of(context).pop();
                                if (existingEntry != null) {
                                  // Close the view dialog too if editing
                                  Navigator.of(context).pop();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFFF4B5A3),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Simpan',
                                style: TextStyle(color: Color(0xFF5D4A45)),
                              ),
                            ),
                          ),
                        ],
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
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset(0, 0.03),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  void _showEntry(JournalEntry entry) {
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Tutup',
      barrierColor: Colors.black54,
      transitionDuration: Duration(milliseconds: 260),
      pageBuilder: (context, animation, secondaryAnimation) {
        final moodColor = _moodColors[entry.mood] ?? Color(0xFFF7F1EE);
        final moodImagePath = _moodImages[entry.mood] ?? 'assets/images/biasa_aja.png';
        final moodIdx = _moodOptions.indexOf(entry.mood);
        final moodLabel = moodIdx != -1 && moodIdx < _moodLabels.length ? _moodLabels[moodIdx] : 'Biasa';

        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: moodColor.withOpacity(0.6),
                    blurRadius: 24,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
            child: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    decoration: BoxDecoration(
                      color: moodColor,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                moodLabel.toUpperCase(),
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12,
                                  letterSpacing: 1.2,
                                  color: Color(0xFF3F3734),
                                ),
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () => _showAddEditDialog(entry),
                                  icon: Icon(Icons.edit, color: Color(0xFF3F3734), size: 22),
                                  tooltip: 'Edit',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                                SizedBox(width: 16),
                                IconButton(
                                  onPressed: () {
                                    _controller.removeEntry(entry.id);
                                    Navigator.of(context).pop();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Jurnal dihapus')),
                                    );
                                  },
                                  icon: Icon(Icons.delete, color: Color(0xFF3F3734), size: 22),
                                  tooltip: 'Hapus',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                                SizedBox(width: 16),
                                IconButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  icon: Icon(Icons.close, color: Color(0xFF3F3734), size: 26),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Image.asset(moodImagePath, width: 80, height: 80),
                        SizedBox(height: 16),
                        Text(
                          entry.title.isEmpty ? '(Tanpa Judul)' : entry.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF3F3734),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '${entry.date.day} ${_monthShort(entry.date.month)} ${entry.date.year} • ${entry.date.hour.toString().padLeft(2, '0')}:${entry.date.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF3F3734).withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: Container(
                      padding: EdgeInsets.all(24),
                      child: SingleChildScrollView(
                        child: Text(
                          entry.content.isEmpty ? '(Konten kosong)' : entry.content,
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.8,
                            color: Color(0xFF5D4A45),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        );
        return ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(curved),
          child: FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
            child: child,
          ),
        );
      },
    );
  }

  Future<void> _pickCustomDate() async {
    final now = DateTime.now();
    final initialDate = _controller.customDate ?? _controller.filterRange?.start ?? now;
    final firstDate = DateTime(now.year - 5);
    final lastDate = DateTime(now.year + 1);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: 'Lihat tanggal berapa',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFF4B5A3),
              onPrimary: Color(0xFF5D4A45),
              surface: Colors.white,
              onSurface: Color(0xFF3F3734),
            ),
          ),
          child: child ?? SizedBox.shrink(),
        );
      },
    );

    if (picked == null) return;

    _controller.setCustomDate(picked);
  }

  @override
  
  // Fungsi build: Bertugas menggambar (me-render) elemen visual/UI ke layar HP pengguna.
  // Menghubungkan data dari Controller ke dalam bentuk Widget (teks, tombol, gambar).
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 800;
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return ConstrainedScaffold(
      backgroundColor: Color(0xFFFAF4F0),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Color(0xFFE7D8CF)),
            ),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    vertical: isWide ? 18 : 12,
                    horizontal: isWide ? 18 : 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Color(0xFFE7D8CF)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => Navigator.of(
                              context,
                            ).popUntil((route) => route.isFirst),
                            child: Container(
                              width: isWide ? 30 : 24,
                              height: isWide ? 30 : 24,
                              decoration: BoxDecoration(
                                color: Color(0xFFF7F1EE),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                Icons.arrow_back,
                                size: isWide ? 20 : 16,
                                color: Color(0xFF5D4A45),
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Jurnal',
                              style: TextStyle(
                                fontSize: isWide ? 24 : 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF3F3734),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Catat harianmu, pikiran, atau perasaan yang ingin diingat.',
                        style: TextStyle(
                          fontSize: isWide ? 14 : 11,
                          height: 1.6,
                          color: Color(0xFF6D5650),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: _controller.searchCtrl,
                  decoration: InputDecoration(
                    hintText: 'Cari judul atau isi...',
                    prefixIcon: Icon(
                      Icons.search,
                      color: Color(0xFF6D5650),
                    ),
                    filled: true,
                    fillColor: Color(0xFFF7F1EE),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 0,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 12),
                // Preset filters: Semua / Hari ini / 7 hari / 30 hari + Custom
                Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(right: 8.0),
                              child: ChoiceChip(
                                label: Text('Semua'),
                                selected: _controller.filterRange == null,
                                onSelected: (_) =>
                                    _controller.setFilterRange(null),
                                selectedColor: Color(0xFFF4B5A3),
                                backgroundColor: Color(0xFFF7F1EE),
                                labelStyle: TextStyle(
                                  color: _controller.filterRange == null
                                      ? Color(0xFF5D4A45)
                                      : Color(0xFF6D5650),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(right: 8.0),
                              child: ChoiceChip(
                                label: Text('Hari ini'),
                                selected:
                                    _controller.filterRange != null &&
                                    _controller.filterRange!.start.year ==
                                        DateTime.now().year &&
                                    _controller.filterRange!.start.month ==
                                        DateTime.now().month &&
                                    _controller.filterRange!.start.day ==
                                        DateTime.now().day &&
                                    _controller.filterRange!.end.year ==
                                        DateTime.now().year &&
                                    _controller.filterRange!.end.month ==
                                        DateTime.now().month &&
                                    _controller.filterRange!.end.day == DateTime.now().day,
                                onSelected: (_) {
                                  final now = DateTime.now();
                                  final today = DateTime(
                                    now.year,
                                    now.month,
                                    now.day,
                                  );
                                  _controller.setFilterRange(
                                    DateTimeRange(
                                      start: today,
                                      end: today,
                                    ),
                                  );
                                },
                                selectedColor: Color(0xFFF4B5A3),
                                backgroundColor: Color(0xFFF7F1EE),
                                labelStyle: TextStyle(
                                  color:
                                      _controller.filterRange != null &&
                                          _controller.filterRange!.start ==
                                              DateTime(
                                                DateTime.now().year,
                                                DateTime.now().month,
                                                DateTime.now().day,
                                              )
                                      ? Color(0xFF5D4A45)
                                      : Color(0xFF6D5650),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(right: 8.0),
                              child: ChoiceChip(
                                label: Text('7 hari'),
                                selected:
                                    _controller.filterRange != null &&
                                    _controller.filterRange!.end
                                            .difference(_controller.filterRange!.start)
                                            .inDays ==
                                        6 &&
                                    _controller.filterRange!.end.day == DateTime.now().day,
                                onSelected: (_) {
                                  final now = DateTime.now();
                                  final end = DateTime(
                                    now.year,
                                    now.month,
                                    now.day,
                                  );
                                  final start = end.subtract(
                                    Duration(days: 6),
                                  );
                                  _controller.setFilterRange(
                                    DateTimeRange(
                                      start: start,
                                      end: end,
                                    ),
                                  );
                                },
                                selectedColor: Color(0xFFF4B5A3),
                                backgroundColor: Color(0xFFF7F1EE),
                                labelStyle: TextStyle(
                                  color: Color(0xFF6D5650),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(right: 8.0),
                              child: ChoiceChip(
                                label: Text('30 hari'),
                                selected:
                                    _controller.filterRange != null &&
                                    _controller.filterRange!.end
                                            .difference(_controller.filterRange!.start)
                                            .inDays ==
                                        29 &&
                                    _controller.filterRange!.end.day == DateTime.now().day,
                                onSelected: (_) {
                                  final now = DateTime.now();
                                  final end = DateTime(
                                    now.year,
                                    now.month,
                                    now.day,
                                  );
                                  final start = end.subtract(
                                    Duration(days: 29),
                                  );
                                  _controller.setFilterRange(
                                    DateTimeRange(
                                      start: start,
                                      end: end,
                                    ),
                                  );
                                },
                                selectedColor: Color(0xFFF4B5A3),
                                backgroundColor: Color(0xFFF7F1EE),
                                labelStyle: TextStyle(
                                  color: Color(0xFF6D5650),
                                ),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: _pickCustomDate,
                              icon: Icon(
                                Icons.calendar_today,
                                size: 18,
                                color: Color(0xFF6D5650),
                              ),
                              label: Text('Kustom'),
                              style: TextButton.styleFrom(
                                backgroundColor: Color(0xFFF7F1EE),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    IconButton(
                      onPressed: _controller.filterRange == null
                          ? null
                          : () => _controller.setFilterRange(null),
                      icon: Icon(
                        Icons.clear,
                        color: _controller.filterRange != null
                            ? Color(0xFFF4B5A3)
                            : Color(0xFF9B8E86),
                      ),
                      tooltip: 'Hapus filter tanggal',
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Expanded(
                  child: _controller.visibleEntries.isEmpty
                      ? Center(
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.book_outlined, size: 64, color: Colors.grey),
                              SizedBox(height: 8),
                              Text(
                                'Belum ada entri jurnal',
                                style: TextStyle(color: Colors.grey),
                              ),
                              SizedBox(height: 12),
                              Text(
                                'Tekan tombol + untuk menambah jurnal',
                                style: TextStyle(color: Color(0xFF9B8E86)),
                              ),
                            ],
                          ),
                          ),
                        )
                      : ListView.separated(
                          padding: EdgeInsets.symmetric(vertical: 8),
                    itemCount: _controller.visibleEntries.length,
                    separatorBuilder: (context, index) =>
                        SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final entry = _controller.visibleEntries[index];
                      return Dismissible(
                        key: ValueKey(
                          entry.date.toIso8601String() + index.toString(),
                        ),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) {
                          _controller.removeEntry(entry.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Entri dihapus')),
                          );
                        },
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Icon(Icons.delete, color: Colors.white),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Color(0xFFE6D9D2)),
                            boxShadow: [
                              BoxShadow(
                                color: (_moodColors[entry.mood] ?? Color(0xFFE6D9D2)).withOpacity(0.15),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => _showEntry(entry),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                        child: Padding(
                                          padding: EdgeInsets.all(16),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              _buildDateAvatar(entry.date),
                                              SizedBox(width: 16),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      entry.title.isEmpty ? '(Tanpa Judul)' : entry.title,
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        color: Color(0xFF6D5650),
                                                        fontWeight: FontWeight.w700,
                                                      ),
                                                    ),
                                                    SizedBox(height: 6),
                                                    Text(
                                                      entry.content.isEmpty ? '(kosong)' : entry.content,
                                                      maxLines: 2,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        height: 1.4,
                                                        color: Color(0xFF7B6F65),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(width: 12),
                                              Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Image.asset(
                                                    _moodImages[entry.mood] ?? 'assets/images/biasa_aja.png',
                                                    width: 32,
                                                    height: 32,
                                                  ),
                                                  SizedBox(height: 4),
                                                  Text(
                                                    _moodOptions.contains(entry.mood) && _moodOptions.indexOf(entry.mood) < _moodLabels.length
                                                      ? _moodLabels[_moodOptions.indexOf(entry.mood)]
                                                      : 'Biasa',
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      color: Color(0xFF9B8E86),
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(width: 8),
                                              PopupMenuButton<String>(
                                                icon: Icon(Icons.more_vert, color: Color(0xFF9B8E86), size: 20),
                                                padding: EdgeInsets.zero,
                                                onSelected: (value) {
                                                  if (value == 'edit') {
                                                    _showAddEditDialog(entry);
                                                  } else if (value == 'delete') {
                                                    _controller.removeEntry(entry.id);
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      const SnackBar(content: Text('Jurnal dihapus')),
                                                    );
                                                  }
                                                },
                                                itemBuilder: (context) => [
                                                  const PopupMenuItem(
                                                    value: 'edit',
                                                    child: Text('Edit'),
                                                  ),
                                                  const PopupMenuItem(
                                                    value: 'delete',
                                                    child: Text('Hapus', style: TextStyle(color: Colors.red)),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
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
                  ),
                ),
                SizedBox(height: 12),
                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton.icon(
                    onPressed: () => _showAddEditDialog(),
                    icon: Icon(Icons.add, color: Color(0xFF5D4A45)),
                    label: Text(
                      'Tambah Jurnal',
                      style: TextStyle(color: Color(0xFF5D4A45), fontSize: 12),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFF4B5A3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      minimumSize: const Size(140, 42),
                      elevation: 6,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildDateAvatar(DateTime date) {
    final day = date.day.toString();
    final month = _monthShort(date.month).toUpperCase();
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: Color(0xFFF7F1EE),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            day,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Color(0xFF5D4A45),
            ),
          ),
          Text(
            month,
            style: TextStyle(fontSize: 9, color: Color(0xFF6D5650)),
          ),
        ],
      ),
    );
  }

  String _monthShort(int m) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    final idx = ((m - 1).clamp(0, 11)).toInt();
    return months[idx];
  }
}

