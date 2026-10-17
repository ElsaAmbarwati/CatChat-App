import '../widgets/constrained_scaffold.dart';
// Penjelasan file dan tujuannya:
// Nama file: peer_chat_lobby_page.dart
// Deskripsi: Halaman utama fitur Ruang Curhat — alur chat anonim seperti bot Telegram.
// Mengarahkan ke/Keterkaitan:
// - Dipanggil oleh navigasi di home_pages.dart.
// - Menggunakan PeerChatController untuk logika backend.

import 'package:flutter/material.dart';
import 'package:catchat/controllers/peer_chat_controller.dart';
import 'package:catchat/models/peer_chat_message.dart';

class PeerChatLobbyPage extends StatefulWidget {
  const PeerChatLobbyPage({super.key});

  @override
  State<PeerChatLobbyPage> createState() => _PeerChatLobbyPageState();
}

class _PeerChatLobbyPageState extends State<PeerChatLobbyPage> {
  final PeerChatController _controller = PeerChatController();
  bool _hasAcceptedDisclaimer = false;

  @override
  void initState() {
    super.initState();
    // Tampilkan dialog disclaimer saat halaman pertama kali dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showDisclaimerDialog();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Dialog disclaimer yang wajib disetujui sebelum menggunakan Ruang Curhat
  void _showDisclaimerDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFFFAF4F0),
        title: Row(
          children: const [
            Icon(Icons.shield_outlined, color: Color(0xFFF4B5A3), size: 28),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Peringatan Privasi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3F3734),
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                'Sebelum menggunakan Ruang Curhat, harap perhatikan hal-hal berikut:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3F3734),
                  height: 1.5,
                ),
              ),
              SizedBox(height: 14),
              _DisclaimerPoint(
                icon: Icons.visibility_off,
                text: 'Kamu akan ngobrol secara anonim dengan pengguna lain yang tidak kamu kenal.',
              ),
              SizedBox(height: 10),
              _DisclaimerPoint(
                icon: Icons.warning_amber_rounded,
                text: 'Segala risiko yang timbul dari berbagi informasi pribadi (nama asli, alamat, nomor HP, foto, dll.) sepenuhnya menjadi tanggung jawabmu sendiri.',
              ),
              SizedBox(height: 10),
              _DisclaimerPoint(
                icon: Icons.gavel,
                text: 'Aplikasi CatChat tidak bertanggung jawab atas penyalahgunaan informasi yang kamu bagikan selama obrolan.',
              ),
              SizedBox(height: 10),
              _DisclaimerPoint(
                icon: Icons.security,
                text: 'Jangan membagikan data sensitif seperti password, PIN, atau informasi keuangan.',
              ),
              SizedBox(height: 10),
              _DisclaimerPoint(
                icon: Icons.report_outlined,
                text: 'Jika ada pengguna yang berperilaku tidak pantas, gunakan fitur Laporkan atau Blokir.',
              ),
              SizedBox(height: 16),
              Text(
                'Dengan melanjutkan, kamu menyatakan telah membaca dan menyetujui ketentuan di atas.',
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Color(0xFF7B6F65),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Tutup dialog
              Navigator.of(this.context).pop(); // Kembali ke halaman sebelumnya
            },
            child: const Text(
              'Tidak Setuju',
              style: TextStyle(
                color: Color(0xFF7B6F65),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Tutup dialog
              setState(() {
                _hasAcceptedDisclaimer = true;
              });
              // Tambahkan pesan sambutan setelah disclaimer disetujui
              _controller.messages.add(PeerChatMessage(
                text: 'Selamat datang di Ruang Curhat! 🎭\n\n'
                    'Di sini kamu bisa ngobrol secara anonim dengan pengguna lain.\n\n'
                    'Tekan tombol "🔍 Cari" di bawah untuk mencari teman obrolan.',
                isMe: false,
                time: DateTime.now(),
                type: 'system',
              ));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF4B5A3),
              foregroundColor: const Color(0xFF5D4A45),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text(
              'Saya Mengerti & Setuju',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showReportDialog() {
    final reportCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Laporkan Pengguna'),
        content: TextField(
          controller: reportCtrl,
          decoration: const InputDecoration(hintText: 'Alasan pelaporan...'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              _controller.reportUser(reportCtrl.text);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Laporan terkirim.')),
              );
            },
            child: const Text('Lapor', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showBlockDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Blokir Pengguna'),
        content: const Text(
            'Anda tidak akan terhubung lagi dengan pengguna ini. Lanjutkan?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              _controller.blockUser();
              _controller.endChat();
              _controller.messages.add(PeerChatMessage(
                text: 'Pengguna telah diblokir.',
                isMe: false,
                time: DateTime.now(),
                type: 'system',
              ));
              Navigator.of(context).pop();
            },
            child: const Text('Blokir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showConsentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bertukar Info'),
        content: const Text(
            'Apakah Anda ingin bertukar identitas? Username asli Anda akan terlihat jika kedua pihak menyetujui.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              _controller.requestConsent();
              Navigator.of(context).pop();
            },
            child: const Text('Kirim Permintaan',
                style: TextStyle(color: Color(0xFFF4B5A3))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return ConstrainedScaffold(
          backgroundColor: const Color(0xFFFAF4F0),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // ===== CUSTOM HEADER =====
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 18, horizontal: 18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFE7D8CF)),
                    ),
                    child: Row(
                      children: [
                        InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F1EE),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.arrow_back,
                                color: Color(0xFF5D4A45)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Ruang Curhat',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF3F3734),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _controller.matchingStatus == 'chatting'
                                    ? 'Terhubung dengan ${_controller.partnerAlias}'
                                    : _controller.matchingStatus == 'searching'
                                        ? 'Mencari teman obrolan...'
                                        : 'Obrolan anonim',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF7B6F65),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4B5A3),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Text(
                            'Anonim',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF5D4A45),
                            ),
                          ),
                        ),
                        if (_controller.matchingStatus == 'chatting')
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'report') _showReportDialog();
                              if (value == 'block') _showBlockDialog();
                              if (value == 'consent') _showConsentDialog();
                            },
                            icon: const Icon(Icons.more_vert,
                                color: Color(0xFF5D4A45)),
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                  value: 'consent',
                                  child: Text('🤝 Bertukar Info')),
                              const PopupMenuItem(
                                  value: 'report',
                                  child: Text('⚠️ Laporkan')),
                              const PopupMenuItem(
                                  value: 'block',
                                  child: Text('🚫 Blokir',
                                      style: TextStyle(color: Colors.red))),
                            ],
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ===== CHAT AREA =====
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: const Color(0xFFE7D8CF)),
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              controller: _controller.scrollController,
                              itemCount: _controller.messages.length,
                              itemBuilder: (context, index) {
                                final msg = _controller.messages[index];
                                return _buildMessage(msg);
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildBottomBar(),
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

  // ===== BUILD MESSAGE BUBBLE =====
  Widget _buildMessage(PeerChatMessage msg) {
    // System messages — centered, italic
    if (msg.type == 'system') {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFFF7F1EE),
                child: const Icon(Icons.smart_toy_outlined,
                    color: Color(0xFF5D4A45), size: 20),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F1EE),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    msg.text,
                    style: const TextStyle(
                      color: Color(0xFF3F3734),
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Consent request — card with buttons
    if (msg.type == 'consent_request' && !msg.isMe) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFFF7F1EE),
                child: const Icon(Icons.smart_toy_outlined,
                    color: Color(0xFF5D4A45), size: 20),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F1EE),
                    border: Border.all(
                        color: const Color(0xFFF4B5A3), width: 1.5),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        msg.text,
                        style: const TextStyle(
                          color: Color(0xFF5D4A45),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () =>
                                  _controller.respondConsent(false),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red),
                              ),
                              child: const Text('Tolak'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () =>
                                  _controller.respondConsent(true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF4B5A3),
                                foregroundColor: const Color(0xFF5D4A45),
                              ),
                              child: const Text('Setuju'),
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
      );
    }

    // Normal messages — same style as Chat AI
    final isMe = msg.isMe;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment:
              isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (!isMe) ...[
              CircleAvatar(
                backgroundColor: const Color(0xFFF7F1EE),
                child: const Icon(Icons.person_outline,
                    color: Color(0xFF5D4A45)),
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: isMe
                      ? const Color(0xFFB0B8BE)
                      : const Color(0xFFF7F1EE),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  msg.text,
                  style: TextStyle(
                    color: isMe ? Colors.white : const Color(0xFF3F3734),
                  ),
                ),
              ),
            ),
            if (isMe) ...[
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: const Color(0xFFD8D4E3),
                child:
                    const Icon(Icons.person, color: Color(0xFF5D4A45)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ===== BUILD BOTTOM BAR =====
  Widget _buildBottomBar() {
    final status = _controller.matchingStatus;

    // IDLE or ENDED — show search button
    if (status == 'idle' || status == 'ended') {
      return Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                _controller.joinQueue('random');
                _controller.messages.add(PeerChatMessage(
                  text: '/search',
                  isMe: true,
                  time: DateTime.now(),
                  type: 'text',
                ));
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4B5A3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.search, color: Color(0xFF5D4A45)),
                    SizedBox(width: 8),
                    Text(
                      'Cari Teman Obrolan',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5D4A45),
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    // SEARCHING — show cancel button
    if (status == 'searching') {
      return Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                _controller.leaveQueue();
                _controller.messages.add(PeerChatMessage(
                  text: 'Pencarian dibatalkan.',
                  isMe: false,
                  time: DateTime.now(),
                  type: 'system',
                ));
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFE7D8CF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF5D4A45)),
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Mencari... (Ketuk untuk batal)',
                      style: TextStyle(
                        color: Color(0xFF5D4A45),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    // CHATTING — show text input + action buttons
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller.textController,
            decoration: InputDecoration(
              hintText: 'Ketik pesan...',
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: Color(0xFFE7D8CF)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: Color(0xFFE7D8CF)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: Color(0xFFF4B5A3)),
              ),
            ),
            onSubmitted: (_) {
              _controller.sendMessage(_controller.textController.text);
              _controller.textController.clear();
            },
          ),
        ),
        const SizedBox(width: 8),
        InkWell(
          onTap: () {
            _controller.sendMessage(_controller.textController.text);
            _controller.textController.clear();
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFF4B5A3),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.send, color: Color(0xFF5D4A45)),
          ),
        ),
        const SizedBox(width: 4),
        // Stop button
        InkWell(
          onTap: () {
            _controller.endChat();
            _controller.messages.add(PeerChatMessage(
              text: 'Obrolan diakhiri. Ketuk "Cari" untuk memulai obrolan baru.',
              isMe: false,
              time: DateTime.now(),
              type: 'system',
            ));
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFE7D8CF),
              shape: BoxShape.circle,
            ),
            child:
                const Icon(Icons.stop, color: Color(0xFF5D4A45), size: 20),
          ),
        ),
      ],
    );
  }
}


// ==========================================
// Widget _DisclaimerPoint
// Fungsi: Item poin pada dialog disclaimer privasi.
// ==========================================
class _DisclaimerPoint extends StatelessWidget {
  final IconData icon;
  final String text;

  const _DisclaimerPoint({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: const Color(0xFFF4B5A3)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF5D4A45),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

