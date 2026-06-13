import 'package:flutter/material.dart';
import 'dart:async';
import '../../services/api_service.dart';
import '../../constants/app_colors.dart';

class ChatRoomScreen extends StatefulWidget {
  final String orderId;
  final String storeName;

  const ChatRoomScreen({
    Key? key,
    required this.orderId,
    required this.storeName,
  }) : super(key: key);

  @override
  _ChatRoomScreenState createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<dynamic> _messages = [];
  bool _isLoading = true;
  Timer? _timer;
  String? _myUserId;

  @override
  void initState() {
    super.initState();
    _loadMyUserId();
    _fetchMessages();
    // Setup polling every 3 seconds to keep chat updated
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) => _fetchMessages(showLoading: false));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMyUserId() async {
    try {
      final profile = await ApiService.getProfile();
      if (mounted) {
        setState(() {
          _myUserId = profile['id']?.toString();
        });
      }
    } catch (e) {
      debugPrint("Gagal mengambil profile ID: $e");
    }
  }

  Future<void> _fetchMessages({bool showLoading = true}) async {
    if (showLoading) {
      setState(() => _isLoading = true);
    }
    try {
      final messages = await ApiService.getMessages(widget.orderId);
      if (mounted) {
        setState(() {
          _messages = messages;
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      debugPrint("Error fetching messages: $e");
      if (mounted && showLoading) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    try {
      final response = await ApiService.sendMessage(widget.orderId, text);
      if (response['id'] != null) {
        // Optimistic UI update
        setState(() {
          _messages.add({
            'id': response['id'],
            'sender_id': _myUserId,
            'message': text,
            'created_at': DateTime.now().toIso8601String(),
          });
        });
        _scrollToBottom();
      }
      _fetchMessages(showLoading: false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengirim pesan: $e')),
      );
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCBDED3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFCBDED3),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF133B1F)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.storeName,
              style: const TextStyle(color: Color(0xFF133B1F), fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const Text(
              'Online',
              style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone, color: Color(0xFF133B1F)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Menghubungi penjual via telepon...')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // MESSAGES
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? const Center(
                        child: Text(
                          "Kirim pesan untuk memulai obrolan.",
                          style: TextStyle(color: Color(0xFF234A3E)),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(20),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final msg = _messages[index];
                          final isMe = msg['sender_id']?.toString() == _myUserId;

                          return Align(
                            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width * 0.75,
                              ),
                              decoration: BoxDecoration(
                                color: isMe ? const Color(0xFF234A3E) : const Color(0xFFF0E2BA),
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(20),
                                  topRight: const Radius.circular(20),
                                  bottomLeft: isMe ? const Radius.circular(20) : Radius.zero,
                                  bottomRight: isMe ? Radius.zero : const Radius.circular(20),
                                ),
                              ),
                              child: Text(
                                msg['message'] ?? '',
                                style: TextStyle(
                                  color: isMe ? Colors.white : const Color(0xFF133B1F),
                                  fontSize: 15,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),

          // INPUT BAR
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: SafeArea(
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.grey.shade200,
                    child: IconButton(
                      icon: const Icon(Icons.add, color: Color(0xFF234A3E)),
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: "Tulis pesan...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  CircleAvatar(
                    backgroundColor: const Color(0xFF234A3E),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _sendMessage,
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
}
