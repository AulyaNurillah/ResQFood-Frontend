import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:resqfood_app/services/api_service.dart';

class OrderQRScreen extends StatefulWidget {
  final String orderId;
  const OrderQRScreen({required this.orderId, Key? key}) : super(key: key);

  @override
  _OrderQRScreenState createState() => _OrderQRScreenState();
}

class _OrderQRScreenState extends State<OrderQRScreen> {
  Map<String, dynamic>? _order;
  bool _isLoading = true;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _fetchOrder();
    _startPolling();
  }

  Future<void> _fetchOrder() async {
    try {
      final data = await ApiService.getOrderById(widget.orderId);
      setState(() {
        _order = data;
        _isLoading = false;
      });
      if (_order != null && (_order!['status'] == 'selesai' || _order!['status'] == 'dibatalkan')) {
        _pollingTimer?.cancel();
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (_order != null && (_order!['status'] == 'selesai' || _order!['status'] == 'dibatalkan')) {
        timer.cancel();
      } else {
        _fetchOrder();
      }
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(203, 222, 211, 1),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color.fromRGBO(203, 222, 211, 1),
        title: Text('Konfirmasi QR', style: TextStyle(color: Color.fromRGBO(19, 59, 31, 1), fontSize: 24)),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _order == null
              ? Center(child: Text('Pesanan tidak ditemukan'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Column(
                    children: [
                      // Icon sukses
                      Container(
                        width: 82,
                        height: 82,
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(35, 74, 62, 1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.check, color: Colors.white, size: 50),
                      ),
                      SizedBox(height: 24),
                      Text(
                        'Pesanan Berhasil!',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color.fromRGBO(35, 74, 62, 1)),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Tunjukkan kode QR ini ke karyawan di lokasi pengambilan ya.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 15, color: Color.fromRGBO(35, 74, 62, 1)),
                      ),
                      SizedBox(height: 24),
                      if (_order!['status'] == 'menunggu_konfirmasi_penjual')
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.orange.shade100,
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.access_time, color: Colors.orange, size: 48),
                              SizedBox(height: 8),
                              Text('Menunggu konfirmasi penjual...', style: TextStyle(fontSize: 16)),
                            ],
                          ),
                        ),
                      if (_order!['status'] == 'diterima_penjual' && _order!['qr_token'] != null)
                        Column(
                          children: [
                            Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: QrImageView(
                                data: _order!['qr_token'],
                                version: QrVersions.auto,
                                size: 200,
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              _order!['qr_token'],
                              style: TextStyle(fontSize: 14, letterSpacing: 2, color: Color.fromRGBO(35, 74, 62, 1)),
                            ),
                          ],
                        ),
                      if (_order!['status'] == 'selesai')
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.green.shade100,
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.check_circle, color: Colors.green, size: 48),
                              SizedBox(height: 8),
                              Text('Pesanan selesai', style: TextStyle(fontSize: 16)),
                            ],
                          ),
                        ),
                      SizedBox(height: 32),
                      // Detail pesanan (bagian atas)
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                          color: Color.fromRGBO(59, 98, 85, 0.8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Rp ${_order!['total_price']}', style: TextStyle(fontSize: 30, color: Color.fromRGBO(240, 226, 186, 1))),
                            SizedBox(height: 8),
                            Text(
                              _order!['product'] != null ? _order!['product']['name'] : 'Produk',
                              style: TextStyle(fontSize: 15, color: Color.fromRGBO(240, 226, 186, 1)),
                            ),
                            Text(
                              '${_order!['seller'] != null ? _order!['seller']['full_name'] : 'Penjual'} • ${_order!['quantity']} items',
                              style: TextStyle(fontSize: 15, color: Color.fromRGBO(240, 226, 186, 1)),
                            ),
                            SizedBox(height: 16),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Color.fromRGBO(35, 74, 62, 0.75),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Lokasi Pengambilan', style: TextStyle(color: Color.fromRGBO(240, 226, 186, 1), fontWeight: FontWeight.bold)),
                                  SizedBox(height: 4),
                                  Text(
                                    _order!['seller'] != null && _order!['seller']['address'] != null
                                        ? _order!['seller']['address']
                                        : 'Jl. Kalimantan No.37, Jember',
                                    style: TextStyle(color: Color.fromRGBO(240, 226, 186, 1)),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 16),
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.white.withOpacity(0.1),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Instruksi Pick-Up:', style: TextStyle(color: Color.fromRGBO(240, 226, 186, 1), fontWeight: FontWeight.bold)),
                                  SizedBox(height: 4),
                                  Text('• Pick-Up sebelum pukul 19.00 WIB\n• Pastikan membawa tas belanja yaa',
                                      style: TextStyle(color: Color.fromRGBO(240, 226, 186, 1))),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Bagian bawah (opsional)
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
                          color: Color.fromRGBO(59, 98, 85, 0.8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.location_on, color: Colors.white),
                            SizedBox(width: 8),
                            Expanded(child: Text('Alamat penjual', style: TextStyle(color: Colors.white))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}