// Penjelasan file dan tujuannya:
// Nama file: chat_pages.dart
// Deskripsi: File ini mengatur antarmuka pengguna (UI) dan apa yang dilihat pengguna di layar.
// Mengarahkan ke/Keterkaitan:
// - Mengarah ke Layar Lain: Menggunakan navigasi (Router) saat tombol ditekan.
// - Berhubungan dengan Controller: Mengambil dan mengirim data melalui file Controller yang relevan.

import 'dart:async';

import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../controllers/chat_controller.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

// ==========================================
// Class ChatPages
// Fungsi: Mendeklarasikan halaman/komponen visual ini.
// Mengarah ke: Biasanya dipanggil oleh router atau tombol navigasi di file lain.
// ==========================================
class ChatPages extends StatefulWidget {
  final List<ChatMessage>? initialMessages;
  final String? sessionId;

  const ChatPages({this.initialMessages, this.sessionId, super.key});

  @override
  State<ChatPages> createState() => _ChatPagesState();
}

class _ChatPagesState extends State<ChatPages> {
  final ChatController _chatController = ChatController();

  @override
  // Fungsi initState: Dijalankan pertama kali saat halaman ini dibuka.
  // Biasanya terhubung ke backend untuk mengambil data awal sebelum layar dimunculkan.
  void initState() {
    super.initState();
    if (widget.sessionId != null) {
      _chatController.sessionId = widget.sessionId;
    }
    if (widget.initialMessages != null && widget.initialMessages!.isNotEmpty) {
      _chatController.messages.addAll(widget.initialMessages!);
      // Scroll ke bawah setelah pesan dimuat
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _chatController.scrollToBottom();
      });
    } else {
      // Pesan sambutan pertama kali untuk sesi baru
      _chatController.messages.add(
        ChatMessage(
          text:
              "Halo! 👋 Aku Teman Curhat AI-mu. Gimana kabarmu hari ini? Ada yang mau kamu ceritain? Aku siap dengerin kok tanpa menghakimi. 😊",
          isAi: true,
          time: DateTime.now(),
        ),
      );
    }
  }

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  @override
  // Fungsi build: Bertugas menggambar (me-render) elemen visual/UI ke layar HP pengguna.
  // Menghubungkan data dari Controller ke dalam bentuk Widget (teks, tombol, gambar).
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _chatController,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: Color(0xFFFAF4F0),
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 18, horizontal: 18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Color(0xFFE7D8CF)),
                    ),
                    child: Row(
                      children: [
                        InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            _chatController.persistSession();
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            width: 36,
                            height: 36,
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Teman Curhat AI',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF3F3734),
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Teman curhat anonim yang mendengarkan dan memberi saran.',
                                style: TextStyle(
                                  fontSize: 13,
                                  height: 1.4,
                                  color: Color(0xFF7B6F65),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Color(0xFFF4B5A3),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            'AI',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF5D4A45),
                            ),
                          ),
                        ),
                        SizedBox(width: 4),
                        IconButton(
                          icon: Icon(
                            Icons.add_circle_outline,
                            color: Color(0xFF5D4A45),
                          ),
                          tooltip: 'Buat Sesi Baru',
                          onPressed: () {
                            _chatController.persistSession();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ChatPages(),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.history, color: Color(0xFF5D4A45)),
                          tooltip: 'Riwayat Chat',
                          onPressed: () {
                            _chatController.persistSession();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ChatHistoryPage(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: Color(0xFFE7D8CF)),
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              controller: _chatController.scrollController,
                              itemCount:
                                  _chatController.messages.length +
                                  (_chatController.isTyping ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == _chatController.messages.length &&
                                    _chatController.isTyping) {
                                  return Padding(
                                    padding: EdgeInsets.symmetric(vertical: 8),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: Color(0xFFF7F1EE),
                                            child: Image.asset(
                                              'assets/images/logo2.png',
                                              width: 20,
                                              height: 20,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Mengetik...',
                                            style: TextStyle(
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                                final msg = _chatController.messages[index];
                                return Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  child: Align(
                                    alignment: msg.isAi
                                        ? Alignment.centerLeft
                                        : Alignment.centerRight,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      mainAxisAlignment: msg.isAi
                                          ? MainAxisAlignment.start
                                          : MainAxisAlignment.end,
                                      children: [
                                        if (msg.isAi) ...[
                                          CircleAvatar(
                                            backgroundColor: Color(0xFFF7F1EE),
                                            child: Image.asset(
                                              'assets/images/logo2.png',
                                              width: 24,
                                              height: 24,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                        ],
                                        Flexible(
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 14,
                                              vertical: 12,
                                            ),
                                            decoration: BoxDecoration(
                                              color: msg.isAi
                                                  ? Color(0xFFF7F1EE)
                                                  : Color(0xFFB0B8BE),
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                            ),
                                            child: Text(
                                              msg.text,
                                              style: TextStyle(
                                                color: msg.isAi
                                                    ? Color(0xFF3F3734)
                                                    : Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                        if (!msg.isAi) ...[
                                          SizedBox(width: 8),
                                          CircleAvatar(
                                            backgroundColor: Color(0xFFD8D4E3),
                                            child: Icon(
                                              Icons.person,
                                              color: Color(0xFF5D4A45),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _chatController.textController,
                                  decoration: InputDecoration(
                                    hintText: 'Ketik pesan...',
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      borderSide: BorderSide(
                                        color: Color(0xFFE7D8CF),
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      borderSide: BorderSide(
                                        color: Color(0xFFE7D8CF),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      borderSide: BorderSide(
                                        color: Color(0xFFF4B5A3),
                                      ),
                                    ),
                                  ),
                                  onSubmitted: (_) =>
                                      _chatController.sendMessage(),
                                ),
                              ),
                              SizedBox(width: 8),
                              InkWell(
                                onTap: _chatController.sendMessage,
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Color(0xFFF4B5A3),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.send,
                                    color: Color(0xFF5D4A45),
                                  ),
                                ),
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
        );
      },
    );
  }
}

// ==========================================
// Class ChatHistoryPage
// Fungsi: Mendeklarasikan halaman/komponen visual ini.
// Mengarah ke: Biasanya dipanggil oleh router atau tombol navigasi di file lain.
// ==========================================
class ChatHistoryPage extends StatefulWidget {
  const ChatHistoryPage({super.key});

  @override
  State<ChatHistoryPage> createState() => _ChatHistoryPageState();
}

class _ChatHistoryPageState extends State<ChatHistoryPage> {
  List<Map<String, dynamic>> _sessions = [];

  @override
  // Fungsi initState: Dijalankan pertama kali saat halaman ini dibuka.
  // Biasanya terhubung ke backend untuk mengambil data awal sebelum layar dimunculkan.
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyKey = await AuthService.instance.getChatHistoryKey();
    final stored = prefs.getStringList(historyKey) ?? <String>[];
    setState(() {
      _sessions = stored
          .map((s) {
            try {
              return jsonDecode(s) as Map<String, dynamic>;
            } catch (_) {
              return <String, dynamic>{};
            }
          })
          .where((m) => m.isNotEmpty)
          .toList();
    });
  }

  Future<void> _deleteSession(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final historyKey = await AuthService.instance.getChatHistoryKey();
    final stored = prefs.getStringList(historyKey) ?? <String>[];
    if (index >= 0 && index < stored.length) {
      stored.removeAt(index);
      await prefs.setStringList(historyKey, stored);
      await _loadHistory();
    }
  }

  @override
  // Fungsi build: Bertugas menggambar (me-render) elemen visual/UI ke layar HP pengguna.
  // Menghubungkan data dari Controller ke dalam bentuk Widget (teks, tombol, gambar).
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFAF4F0),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF5D4A45)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Riwayat Chat', style: TextStyle(color: Color(0xFF3F3734))),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Color(0xFFE7D8CF)),
          ),
          child: _sessions.isEmpty
              ? Center(child: Text('Belum ada riwayat percakapan.'))
              : ListView.separated(
                  itemCount: _sessions.length,
                  separatorBuilder: (context, index) =>
                      const Divider(color: Color(0xFFE7D8CF)),
                  itemBuilder: (context, index) {
                    final s = _sessions[index];
                    final messages = s['messages'] as List<dynamic>? ?? [];
                    final preview = messages.isNotEmpty
                        ? (messages.last['text'] ?? '')
                        : '';
                    return ListTile(
                      title: Text('Sesi ${_sessions.length - index}'),
                      subtitle: Text(
                        preview,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Color(0xFFB0B8BE)),
                        onPressed: () => _deleteSession(index),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatHistoryDetailPage(session: s),
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
      ),
    );
  }
}

// ==========================================
// Class ChatHistoryDetailPage
// Fungsi: Mendeklarasikan halaman/komponen visual ini.
// Mengarah ke: Biasanya dipanggil oleh router atau tombol navigasi di file lain.
// ==========================================
class ChatHistoryDetailPage extends StatelessWidget {
  final Map<String, dynamic> session;

  const ChatHistoryDetailPage({required this.session, super.key});

  @override
  // Fungsi build: Bertugas menggambar (me-render) elemen visual/UI ke layar HP pengguna.
  // Menghubungkan data dari Controller ke dalam bentuk Widget (teks, tombol, gambar).
  Widget build(BuildContext context) {
    final msgs = (session['messages'] as List<dynamic>? ?? [])
        .map(
          (m) => ChatMessage(
            text: (m['text'] ?? '') as String,
            isAi: (m['isAi'] ?? false) as bool,
            time: DateTime.tryParse((m['time'] ?? '')) ?? DateTime.now(),
          ),
        )
        .toList();

    return Scaffold(
      backgroundColor: Color(0xFFFAF4F0),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF5D4A45)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Detail Riwayat',
          style: TextStyle(color: Color(0xFF3F3734)),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Color(0xFFE7D8CF)),
          ),
          child: ListView.builder(
            itemCount: msgs.length,
            itemBuilder: (context, index) {
              final msg = msgs[index];
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: msg.isAi
                      ? MainAxisAlignment.start
                      : MainAxisAlignment.end,
                  children: [
                    if (msg.isAi) ...[
                      CircleAvatar(
                        backgroundColor: Color(0xFFF7F1EE),
                        child: Image.asset(
                          'assets/images/logo2.png',
                          width: 24,
                          height: 24,
                        ),
                      ),
                      SizedBox(width: 8),
                    ],
                    Flexible(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: msg.isAi
                              ? Color(0xFFF7F1EE)
                              : Color(0xFFB0B8BE),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(msg.text),
                      ),
                    ),
                    if (!msg.isAi) ...[
                      SizedBox(width: 8),
                      CircleAvatar(
                        backgroundColor: Color(0xFFD8D4E3),
                        child: Icon(Icons.person, color: Color(0xFF5D4A45)),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Hapus semua halaman tumpukan sampai ke Home, lalu buka sesi chat ini
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => ChatPages(
                initialMessages: msgs,
                sessionId: session['id'] as String?,
              ),
            ),
            (route) =>
                route.isFirst, // Menyisakan halaman Home di tumpukan terbawah
          );
        },
        icon: Icon(Icons.forum),
        label: Text('Lanjutkan Obrolan'),
        backgroundColor: Color(0xFFF4B5A3),
        foregroundColor: Color(0xFF5D4A45),
      ),
    );
  }
}
