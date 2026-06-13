import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../constants/app_colors.dart';
import 'chat_room_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<dynamic> _orders = [];
  bool _isLoading = true;
  String _activeTab = "Semua";

  @override
  void initState() {
    super.initState();
    _fetchChats();
  }

  Future<void> _fetchChats() async {
    setState(() => _isLoading = true);
    try {
      final orders = await ApiService.getMyOrders();
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Gagal mengambil chat/pesanan: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter chats based on tab (simulated)
    final displayOrders = _orders;

    return Scaffold(
      backgroundColor: const Color(0xFFCBDED3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFCBDED3),
        elevation: 0,
        title: const Text('Chat', style: TextStyle(color: Color(0xFF133B1F), fontWeight: FontWeight.bold, fontSize: 24)),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Color(0xFF133B1F)),
            onPressed: () => Navigator.pushNamed(context, '/notifications'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            // SEARCH BAR
            TextField(
              decoration: InputDecoration(
                hintText: "Cari kontak atau restoran...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 15),

            // TABS
            Row(
              children: [
                _buildTabButton("Semua"),
                const SizedBox(width: 10),
                _buildTabButton("Belum dibaca"),
              ],
            ),
            const SizedBox(height: 20),

            // CHAT LIST
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : displayOrders.isEmpty
                      ? const Center(
                          child: Text(
                            "Belum ada percakapan chat aktif.",
                            style: TextStyle(color: Color(0xFF234A3E)),
                          ),
                        )
                      : ListView.builder(
                          itemCount: displayOrders.length,
                          itemBuilder: (context, index) {
                            final order = displayOrders[index];
                            final product = order['product'] ?? {};
                            final storeName = order['seller']?['store_name'] ?? order['seller']?['full_name'] ?? 'Penjual ResQFood';
                            final lastMessage = "Klik untuk membuka ruang chat";
                            final orderId = order['id'];

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF3B6255),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                leading: const CircleAvatar(
                                  radius: 24,
                                  backgroundColor: Color(0xFF234A3E),
                                  child: Icon(Icons.store, color: Colors.white),
                                ),
                                title: Text(
                                  storeName,
                                  style: const TextStyle(color: Color(0xFFF0E2BA), fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  "Pesanan: ${product['name'] ?? 'Produk'}\n$lastMessage",
                                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                                ),
                                trailing: const Icon(Icons.chevron_right, color: Color(0xFFF0E2BA)),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatRoomScreen(
                                        orderId: orderId.toString(),
                                        storeName: storeName,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String label) {
    final isSelected = _activeTab == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeTab = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF234A3E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF234A3E),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
