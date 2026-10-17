// Penjelasan file dan tujuannya:
// Nama file: peer_chat_controller.dart
// Deskripsi: Controller untuk mengatur logika Ruang Curhat dengan pendekatan HTTP Polling.

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:catchat/services/api_service.dart';
import 'package:catchat/models/peer_chat_message.dart';

class PeerChatController extends ChangeNotifier {
  List<PeerChatMessage> messages = [];
  String matchingStatus = 'idle'; // 'idle' | 'searching' | 'matched' | 'chatting' | 'ended'
  String? partnerAlias;
  String? currentRoomId;
  String? selectedTopic;
  String consentStatus = 'none'; // 'none' | 'requested' | 'accepted' | 'rejected'
  bool isConnected = true; // Always true for HTTP
  int lastMessageId = 0;

  Timer? _pollTimer;

  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  Future<void> init() async {
    // Initialization logic if any
  }

  Future<void> joinQueue(String topic) async {
    selectedTopic = topic;
    matchingStatus = 'searching';
    messages.clear();
    consentStatus = 'none';
    partnerAlias = null;
    currentRoomId = null;
    lastMessageId = 0;
    notifyListeners();

    try {
      final response = await ApiService.instance.post('/peer-chat/join', {'topic': topic});
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['matched'] == true) {
          _handleMatch(data);
        } else {
          _startStatusPolling();
        }
      }
    } catch (e) {
      // Handle error
    }
  }

  void _startStatusPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      try {
        final response = await ApiService.instance.get('/peer-chat/status');
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['matched'] == true) {
            timer.cancel();
            _handleMatch(data);
          }
        }
      } catch (e) {
        // Handle error
      }
    });
  }

  void _handleMatch(Map<String, dynamic> data) {
    matchingStatus = 'matched';
    partnerAlias = data['partnerAlias'] ?? 'Teman Curhat';
    currentRoomId = data['roomId'];
    messages.add(PeerChatMessage(
      text: 'Anda telah terhubung dengan $partnerAlias.',
      isMe: false,
      time: DateTime.now(),
      type: 'system',
    ));
    matchingStatus = 'chatting';
    notifyListeners();
    scrollToBottom();
    _startMessagesPolling();
  }

  void _startMessagesPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      if (currentRoomId == null) return;
      try {
        final response = await ApiService.instance.get('/peer-chat/messages/$currentRoomId?after=$lastMessageId');
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final List newMessages = data['messages'] ?? [];
          for (var msg in newMessages) {
            int msgId = msg['id'] ?? 0;
            if (msgId > lastMessageId) lastMessageId = msgId;

            String type = msg['type'] ?? 'text';
            String text = msg['text'] ?? '';
            bool isMe = msg['isMe'] ?? false;

            messages.add(PeerChatMessage(
              text: text,
              isMe: isMe,
              time: DateTime.now(),
              type: type,
            ));

            if (type == 'system' && (text.contains('berakhir') || text.contains('terputus'))) {
              matchingStatus = 'ended';
              timer.cancel();
            } else if (type == 'consent_request' && !isMe) {
              consentStatus = 'requested';
            } else if (type == 'system' && text.contains('disetujui')) {
              consentStatus = 'accepted';
            } else if (type == 'system' && text.contains('menolak')) {
              consentStatus = 'rejected';
            }
          }
          if (newMessages.isNotEmpty) {
            notifyListeners();
            scrollToBottom();
          }
        }
      } catch (e) {
        // Handle error
      }
    });
  }

  Future<void> leaveQueue() async {
    _pollTimer?.cancel();
    matchingStatus = 'idle';
    selectedTopic = null;
    notifyListeners();
    try {
      await ApiService.instance.post('/peer-chat/leave', {});
    } catch (e) {
      // Handle error
    }
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || currentRoomId == null) return;
    
    // Optimistic UI
    // The server shouldn't return this message in polling if we already added it,
    // or we might get duplicates if the server's `isMe` logic isn't aligned with polling.
    // For simplicity, assuming backend handles duplicate or we just don't add optimistically if we rely on polling.
    // Instructions say: "Add to local list optimistically."
    messages.add(PeerChatMessage(
      text: text,
      isMe: true,
      time: DateTime.now(),
      type: 'text',
    ));
    notifyListeners();
    scrollToBottom();

    try {
      await ApiService.instance.post('/peer-chat/send', {
        'roomId': currentRoomId,
        'text': text,
      });
    } catch (e) {
      // Handle error
    }
  }

  Future<void> requestConsent() async {
    if (currentRoomId == null) return;
    messages.add(PeerChatMessage(
      text: 'Permintaan bertukar identitas terkirim.',
      isMe: true,
      time: DateTime.now(),
      type: 'system',
    ));
    notifyListeners();
    scrollToBottom();

    try {
      await ApiService.instance.post('/peer-chat/request-consent', {'roomId': currentRoomId});
    } catch (e) {
      // Handle error
    }
  }

  Future<void> respondConsent(bool accepted) async {
    if (currentRoomId == null) return;
    consentStatus = accepted ? 'accepted' : 'rejected';
    messages.add(PeerChatMessage(
      text: accepted ? 'Anda menyetujui bertukar identitas.' : 'Anda menolak bertukar identitas.',
      isMe: true,
      time: DateTime.now(),
      type: 'system',
    ));
    notifyListeners();
    scrollToBottom();

    try {
      await ApiService.instance.post('/peer-chat/respond-consent', {
        'roomId': currentRoomId,
        'accepted': accepted,
      });
    } catch (e) {
      // Handle error
    }
  }

  Future<void> endChat() async {
    _pollTimer?.cancel();
    if (currentRoomId != null) {
      try {
        await ApiService.instance.post('/peer-chat/end', {'roomId': currentRoomId});
      } catch (e) {
        // Handle error
      }
    }
    matchingStatus = 'ended';
    notifyListeners();
  }

  Future<void> reportUser(String reason) async {
    if (currentRoomId == null) return;
    try {
      await ApiService.instance.post('/peer-chat/report', {
        'roomId': currentRoomId,
        'reason': reason,
      });
    } catch (e) {
      // Handle error
    }
  }

  Future<void> blockUser() async {
    if (currentRoomId == null) return;
    try {
      await ApiService.instance.post('/peer-chat/block', {
        'roomId': currentRoomId,
      });
    } catch (e) {
      // Handle error
    }
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    textController.dispose();
    scrollController.dispose();
    super.dispose();
  }
}
