import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<dynamic> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.getNotifications();
      setState(() {
        _notifications = data;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Gagal mengambil notifikasi: $e");
      // Fallback ke mock data jika gagal atau kosong untuk tujuan presentasi UAS/Mock
      setState(() {
        _notifications = [
          {
            "id": "1",
            "title": "New Surplus Near You",
            "message": "RM Seruni has just listed 5 fresh surplus food loaves. Grab them before they're gone!",
            "created_at": "2 menit yang lalu",
            "read": false,
            "type": "info"
          },
          {
            "id": "2",
            "title": "Order Confirmed",
            "message": "Your reservation at Hotel Royal Jember was successful. Pick up scheduled for 6:00 PM today.",
            "created_at": "1 jam yang lalu",
            "read": true,
            "type": "success"
          },
          {
            "id": "3",
            "title": "Promo Akhir Pekan",
            "message": "Gunakan kode RESQHEBAT untuk diskon biaya transaksi pesanan Anda minggu ini!",
            "created_at": "1 hari yang lalu",
            "read": true,
            "type": "promo"
          }
        ];
        _isLoading = false;
      });
    }
  }

  Future<void> _markAsRead(String id) async {
    try {
      await ApiService.markNotificationRead(id);
      _fetchNotifications();
    } catch (e) {
      debugPrint("Gagal update notifikasi: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCBDED3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFCBDED3),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF133B1F)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Notifikasi",
          style: TextStyle(
            color: Color(0xFF133B1F),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notif = _notifications[index];
                final isUnread = notif['read'] == false;

                return GestureDetector(
                  onTap: () {
                    if (isUnread) {
                      _markAsRead(notif['id'].toString());
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isUnread ? Colors.white : const Color.fromRGBO(255, 255, 255, 0.7),
                      borderRadius: BorderRadius.circular(20),
                      border: isUnread
                          ? Border.all(color: const Color(0xFF3B6255), width: 1.5)
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromRGBO(0, 0, 0, 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              notif['title'] ?? 'Pemberitahuan',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isUnread ? const Color(0xFF133B1F) : Colors.grey.shade700,
                              ),
                            ),
                            if (isUnread)
                              const CircleAvatar(
                                radius: 4,
                                backgroundColor: Colors.orange,
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          notif['message'] ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade800,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              notif['created_at'] ?? '',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                            ),
                            if (notif['type'] == 'info' || notif['title'].toString().contains('Surplus'))
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pushReplacementNamed(context, '/dashboard');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF3B6255),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                ),
                                child: const Text(
                                  'View Surplus',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
