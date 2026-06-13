import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class AmbilPesananScreen extends StatelessWidget {
  final String orderId;
  final Map<String, dynamic>? orderData; // Tambahkan parameter opsional
  final Map<String, dynamic>? productData; // Tambahkan parameter opsional

  const AmbilPesananScreen({
    Key? key, 
    required this.orderId,
    this.orderData,
    this.productData,
  }) : super(key: key);

  String formatPrice(dynamic value) {
    return "Rp ${value.toString()}";
  }

  @override
  Widget build(BuildContext context) {
    // Gunakan orderData jika ada, atau buat data sederhana
    final displayOrder = orderData ?? {'id': orderId, 'total_price': 0};
    final displayProduct = productData ?? {'name': 'Produk', 'category': '-'};
    
    final qrData = jsonEncode({
      "order_id": orderId,
      "product_id": displayProduct['id'],
      "seller_id": displayProduct['seller_id'],
      "buyer_id": displayOrder['buyer_id'],
      "product_name": displayProduct['name'],
      "price": displayOrder['total_price'],
    });

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
          "Konfirmasi QR",
          style: TextStyle(
            color: Color(0xFF133B1F),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 10),
            const CircleAvatar(
              radius: 45,
              backgroundColor: Color(0xFF234A3E),
              child: Icon(
                Icons.check,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              "Pesanan Berhasil!",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF234A3E),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Tunjukkan QR Code ini ke karyawan di lokasi pengambilan.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF234A3E),
              ),
            ),
            const SizedBox(height: 25),
            
            // QR CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xCC3B6255),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(15),
                    color: Colors.white,
                    child: QrImageView(
                      data: qrData,
                      version: QrVersions.auto,
                      size: 230,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Kode Pesanan: $orderId",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFFF0E2BA),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // DETAIL PESANAN
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xCC3B6255),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formatPrice(displayOrder['total_price']),
                    style: const TextStyle(
                      color: Color(0xFFF0E2BA),
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    displayProduct['name'] ?? "-",
                    style: const TextStyle(
                      color: Color(0xFFF0E2BA),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Kategori: ${displayProduct['category'] ?? "-"}",
                    style: const TextStyle(
                      color: Color(0xFFF0E2BA),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: const Color(0xBF234A3E),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Instruksi Pick Up",
                          style: TextStyle(
                            color: Color(0xFFF0E2BA),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "• Datang ke lokasi penjual\n"
                          "• Tunjukkan QR Code ini\n"
                          "• Ambil pesanan Anda\n"
                          "• Pastikan membawa tas belanja",
                          style: TextStyle(
                            color: Color(0xFFF0E2BA),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF234A3E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(38),
                  ),
                ),
                onPressed: () {
                  // Navigasi ke halaman daftar pesanan
                  Navigator.pushReplacementNamed(context, '/order-list');
                },
                child: const Text(
                  "Lihat Pesanan Saya",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}