// Penjelasan file dan tujuannya:
// Nama file: peer_chat_message.dart
// Deskripsi: Model untuk pesan di fitur Ruang Curhat.

class PeerChatMessage {
  final String text;
  final bool isMe;
  final DateTime time;
  final String type; // 'text', 'system', 'consent_request', 'consent_response'

  PeerChatMessage({
    required this.text,
    required this.isMe,
    required this.time,
    this.type = 'text',
  });
}
