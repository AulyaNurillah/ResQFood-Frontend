import 'package:flutter/material.dart';
import 'package:resqfood_app/services/api_service.dart';
import 'package:resqfood_app/screens/buyer/ambilpesanan_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;
  const ProductDetailScreen({required this.productId, super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Map<String, dynamic>? _product;
  bool _isLoading = true;
  bool _isOrdering = false;

  @override
  void initState() {
    super.initState();
    _fetchProduct();
  }

  Future<void> _fetchProduct() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.getProductById(widget.productId);
      
      // Cek apakah response mengandung error atau data
      if (response.containsKey('error')) {
        throw Exception(response['error']);
      }
      
      if (mounted) {
        setState(() {
          _product = response;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal memuat detail produk: $e')),
          );
          Navigator.pop(context);
        }
      }
    }
  }

  Future<void> _orderNow() async {
    setState(() => _isOrdering = true);
    
    try {
      // Panggil API create order
      final response = await ApiService.createOrder(widget.productId, 1);
      
      // Cek apakah order berhasil dibuat
      if (response.containsKey('id') || response.containsKey('order')) {
        final orderData = response.containsKey('order') ? response['order'] : response;
        
        if (mounted) {
          // Navigasi ke halaman konfirmasi QR
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AmbilPesananScreen(
                orderId: orderData['id'] ?? orderData['orderId'],
                orderData: orderData,
                productData: _product!,
              ),
            ),
          ).then((_) {
            // Reset state setelah kembali
            if (mounted) {
              setState(() => _isOrdering = false);
            }
          });
        }
      } else {
        // Jika gagal, tampilkan error
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['error'] ?? 'Gagal membuat pesanan')),
          );
          setState(() => _isOrdering = false);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
        setState(() => _isOrdering = false);
      }
    }
  }

  String formatPrice(dynamic price) {
    return "Rp ${price.toString()}";
  }

  String _getTimeFromDateTime(String? dateTime) {
    if (dateTime == null) return '';
    try {
      if (dateTime.contains('T')) {
        // Format ISO
        final time = DateTime.parse(dateTime);
        return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      } else {
        // Format sudah waktu saja
        return dateTime.substring(0, 5);
      }
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    if (_product == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('Produk tidak ditemukan'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(59, 98, 85, 1),
                ),
                child: const Text('Kembali'),
              ),
            ],
          ),
        ),
      );
    }
    
    final p = _product!;
    final originalPrice = p['price'] ?? 0;
    
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar header dengan tombol back
            Stack(
              children: [
                Container(
                  height: 265,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(45)),
                    image: p['image_url'] != null && p['image_url'].toString().isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(p['image_url']), 
                            fit: BoxFit.cover
                          )
                        : null,
                    color: Colors.grey.shade300,
                  ),
                  child: p['image_url'] == null || p['image_url'].toString().isEmpty
                      ? const Icon(Icons.food_bank, size: 80, color: Colors.grey)
                      : null,
                ),
                // Tombol back
                Positioned(
                  top: 40,
                  left: 16,
                  child: CircleAvatar(
                    backgroundColor: const Color.fromRGBO(0, 0, 0, 0.5),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
              ],
            ),
            
            // Harga dan info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(9999),
                      color: const Color.fromRGBO(35, 74, 62, 1),
                    ),
                    child: const Text(
                      'FOOD SAVING',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(9999),
                      color: const Color.fromRGBO(35, 74, 62, 1),
                    ),
                    child: Text(
                      formatPrice(originalPrice),
                      style: const TextStyle(
                        color: Color.fromRGBO(240, 226, 186, 1), 
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Nama, deskripsi, dll
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p['name'] ?? 'Produk',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    p['seller_name'] ?? p['seller']?['full_name'] ?? 'Penjual',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    p['description'] ?? 'Tidak ada deskripsi',
                    style: const TextStyle(fontSize: 15, height: 1.4),
                  ),
                  const SizedBox(height: 24),
                  
                  // Info tags
                  Wrap(
                    spacing: 8, 
                    runSpacing: 8,
                    children: [
                      if (p['category'] != null)
                        Chip(
                          label: Text(p['category']),
                          backgroundColor: const Color.fromRGBO(78, 102, 93, 0.4),
                        ),
                      const Chip(
                        label: Text('Food Saving'),
                        backgroundColor: Color.fromRGBO(78, 102, 93, 0.4),
                      ),
                      if ((p['stock'] ?? 0) > 0)
                        Chip(
                          label: Text('${p['stock']} tersisa'),
                          backgroundColor: const Color.fromRGBO(78, 102, 93, 0.4),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Waktu pick-up
                  if (p['pickup_start'] != null && p['pickup_end'] != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(78, 102, 93, 0.4),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.access_time, size: 16, color: Color.fromRGBO(35, 74, 62, 1)),
                          const SizedBox(width: 8),
                          Text(
                            'Pickup: ${_getTimeFromDateTime(p['pickup_start'])} - ${_getTimeFromDateTime(p['pickup_end'])} WIB',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 24),
                  
                  // Lokasi Pickup
                  const Text(
                    'Pickup Location',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  
                  // Card alamat
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color.fromRGBO(35, 74, 62, 1), width: 1),
                      color: Colors.white,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, color: Color.fromRGBO(59, 98, 85, 1), size: 30),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Alamat Pengambilan',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                p['store_address'] ?? p['seller']?['address'] ?? 'Alamat tidak tersedia',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Tombol directions
                  Center(
                    child: TextButton.icon(
                      onPressed: () {
                        // Buka Google Maps
                        final address = p['store_address'] ?? p['seller']?['address'] ?? '';
                        if (address.isNotEmpty) {
                          // Encode address untuk URL
                          // Buka Google Maps (di web atau app)
                          // Untuk production, gunakan url_launcher package
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Fitur arah akan segera tersedia')),
                            );
                          }
                        } else {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Alamat tidak tersedia')),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.directions),
                      label: const Text('Get Directions'),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Info penjual
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(78, 102, 93, 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 24,
                          backgroundColor: Color.fromRGBO(59, 98, 85, 1),
                          child: Icon(Icons.store, color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p['seller_name'] ?? p['seller']?['full_name'] ?? 'Penjual',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const Text('Online', style: TextStyle(color: Colors.green, fontSize: 12)),
                            ],
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () {
                            // Navigasi ke chat
                            Navigator.pushNamed(
                              context,
                              '/chat-room',
                              arguments: {'sellerId': p['seller_id'], 'productId': widget.productId},
                            );
                          },
                          icon: const Icon(Icons.chat_bubble_outline, size: 18),
                          label: const Text('Chat'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color.fromRGBO(59, 98, 85, 1),
                            side: const BorderSide(color: Color.fromRGBO(59, 98, 85, 1)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100), // Space untuk bottom bar
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 78,
        decoration: BoxDecoration(
          boxShadow: const [BoxShadow(color: Colors.black26, offset: Offset(0, -1), blurRadius: 1)],
          color: const Color.fromRGBO(203, 222, 211, 1),
        ),
        child: Center(
          child: ElevatedButton(
            onPressed: _isOrdering ? null : _orderNow,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromRGBO(59, 98, 85, 1),
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: _isOrdering
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Text(
                    'Grab Now',
                    style: TextStyle(fontSize: 20, color: Color.fromRGBO(240, 226, 186, 1)),
                  ),
          ),
        ),
      ),
    );
  }
}