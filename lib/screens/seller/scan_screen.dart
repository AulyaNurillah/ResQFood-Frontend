import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../services/api_service.dart';
import '../../constants/app_colors.dart';
import 'dart:convert';

class SellerScanScreen extends StatefulWidget {
  const SellerScanScreen({Key? key}) : super(key: key);

  @override
  _SellerScanScreenState createState() => _SellerScanScreenState();
}

class _SellerScanScreenState extends State<SellerScanScreen> {
  final MobileScannerController _scannerController = MobileScannerController();
  final TextEditingController _manualCodeController = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _scannerController.dispose();
    _manualCodeController.dispose();
    super.dispose();
  }

  Future<void> _processQr(String qrToken) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    _scannerController.stop();

    try {
      // Panggil API Scan QR
      final response = await ApiService.scanQr(qrToken);

      if (response['id'] != null || response['status'] == 'selesai') {
        _showResultDialog(
          success: true,
          message: "Transaksi Berhasil!\n\nProduk: ${response['product']?['name'] ?? 'Makanan Surplus'}\nTotal: Rp ${response['total_price'] ?? 0}\nStatus: Jual Beli Selesai.",
        );
      } else {
        _showResultDialog(
          success: false,
          message: response['error'] ?? "Transaksi gagal atau QR Code sudah tidak berlaku.",
        );
      }
    } catch (e) {
      // Fallback/Simulate untuk testing offline/UAS jika API belum merespon
      try {
        final decoded = jsonDecode(qrToken);
        if (decoded.containsKey('order_id')) {
          // Coba panggil acceptOrder jika scanQr error
          final acceptRes = await ApiService.acceptOrder(decoded['order_id'].toString());
          if (acceptRes.containsKey('id') || acceptRes.containsKey('status')) {
            _showResultDialog(
              success: true,
              message: "Transaksi Berhasil!\n\nOrder ID: ${decoded['order_id']}\nProduk: ${decoded['product_name'] ?? 'Makanan Surplus'}\nTotal: Rp ${decoded['price'] ?? 0}",
            );
            setState(() => _isProcessing = false);
            return;
          }
        }
      } catch (_) {}

      _showResultDialog(
        success: false,
        message: "Error memvalidasi transaksi: $e",
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _showResultDialog({required bool success, required String message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              success ? Icons.check_circle : Icons.error,
              color: success ? Colors.green : Colors.red,
              size: 28,
            ),
            const SizedBox(width: 10),
            Text(success ? "Berhasil" : "Gagal"),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _scannerController.start();
            },
            child: const Text("Scan Lagi", style: TextStyle(color: Color(0xFF234A3E), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCBDED3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFCBDED3),
        elevation: 0,
        title: const Text('Scan QR Code Pembeli', style: TextStyle(color: Color(0xFF133B1F), fontWeight: FontWeight.bold, fontSize: 20)),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Text(
                "Arahkan kamera ke QR Code pembeli untuk memvalidasi dan menyelesaikan pesanan.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF234A3E), fontSize: 14),
              ),
              const SizedBox(height: 24),

              // CAMERA SCANNER BOX
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  height: 300,
                  width: double.infinity,
                  color: Colors.black,
                  child: MobileScanner(
                    controller: _scannerController,
                    onDetect: (capture) {
                      final List<Barcode> barcodes = capture.barcodes;
                      for (final barcode in barcodes) {
                        if (barcode.rawValue != null) {
                          _processQr(barcode.rawValue!);
                          break;
                        }
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // MANUAL CODE OPTION (FOR EMULATOR TESTING)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const Text(
                      "Menggunakan Emulator? Masukkan Kode Order Secara Manual",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF234A3E)),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _manualCodeController,
                      decoration: InputDecoration(
                        hintText: "Contoh: 12 (Order ID)",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF234A3E),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          final code = _manualCodeController.text.trim();
                          if (code.isNotEmpty) {
                            // Coba proses format json palsu
                            final mockJson = jsonEncode({
                              "order_id": code,
                              "product_name": "Makanan Surplus",
                              "price": 15000,
                            });
                            _processQr(mockJson);
                          }
                        },
                        child: const Text("Kirim Kode Manual"),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
