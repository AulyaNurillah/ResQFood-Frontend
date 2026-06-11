import 'package:flutter/material.dart';
import 'package:resqfood_app/services/api_service.dart';
import 'package:resqfood_app/screens/buyer/order_qr_screen.dart';

class OrderListScreen extends StatefulWidget {
  @override
  _OrderListScreenState createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  List<dynamic> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.getMyOrders();
      setState(() {
        _orders = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat pesanan: $e')),
      );
    }
  }

  Future<void> _cancelOrder(String orderId) async {
    try {
      final response = await ApiService.cancelOrder(orderId); // perlu tambahkan method di ApiService
      if (response['status'] != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pesanan dibatalkan')),
        );
        _fetchOrders();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['error'] ?? 'Gagal membatalkan')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'menunggu_konfirmasi_penjual': return 'Menunggu konfirmasi';
      case 'diterima_penjual': return 'Diterima, siap diambil';
      case 'selesai': return 'Selesai';
      case 'dibatalkan': return 'Dibatalkan';
      default: return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'menunggu_konfirmasi_penjual': return Colors.orange;
      case 'diterima_penjual': return Colors.blue;
      case 'selesai': return Colors.green;
      case 'dibatalkan': return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pesanan Saya'),
        backgroundColor: Color.fromRGBO(59, 98, 85, 1),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? Center(child: Text('Belum ada pesanan'))
              : ListView.builder(
                  itemCount: _orders.length,
                  itemBuilder: (ctx, index) {
                    final order = _orders[index];
                    final status = order['status'];
                    final productName = order['product'] != null ? order['product']['name'] : 'Produk';
                    final total = order['total_price'];
                    final quantity = order['quantity'];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(productName, style: TextStyle(fontWeight: FontWeight.bold)),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(status),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _getStatusText(status),
                                    style: TextStyle(color: Colors.white, fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text('Jumlah: $quantity item'),
                            Text('Total: Rp $total'),
                            SizedBox(height: 12),
                            Row(
                              children: [
                                if (status == 'menunggu_konfirmasi_penjual')
                                  ElevatedButton(
                                    onPressed: () => _cancelOrder(order['id']),
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                    child: Text('Batalkan'),
                                  ),
                                if (status == 'diterima_penjual')
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => OrderQRScreen(orderId: order['id'])),
                                      );
                                    },
                                    child: Text('Lihat QR'),
                                  ),
                                Spacer(),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/chat-room', arguments: order['id']);
                                  },
                                  child: Text('Chat'),
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