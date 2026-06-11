import 'package:flutter/material.dart';
import 'package:resqfood_app/services/api_service.dart';
import 'package:resqfood_app/screens/buyer/order_qr_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;
  const ProductDetailScreen({required this.productId, Key? key}) : super(key: key);

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
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
    try {
      final data = await ApiService.getProductById(widget.productId);
      setState(() {
        _product = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat detail produk: $e')),
      );
    }
  }

  Future<void> _orderNow() async {
    setState(() => _isOrdering = true);
    try {
      final response = await ApiService.createOrder(widget.productId, 1);
      if (response.containsKey('id')) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => OrderQRScreen(orderId: response['id'])),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['error'] ?? 'Gagal membuat pesanan')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isOrdering = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_product == null) return Scaffold(body: Center(child: Text('Produk tidak ditemukan')));
    final p = _product!;
    final originalPrice = p['price'];
    final discountedPrice = (originalPrice * 0.5).toInt(); // contoh diskon 50%
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar header
            Container(
              height: 265,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(45)),
                image: p['image_url'] != null
                    ? DecorationImage(image: NetworkImage(p['image_url']), fit: BoxFit.cover)
                    : null,
                color: Colors.grey.shade300,
              ),
              child: p['image_url'] == null ? Icon(Icons.food_bank, size: 80) : null,
            ),
            // Harga dan diskon
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(9999),
                      color: Color.fromRGBO(35, 74, 62, 1),
                    ),
                    child: Text(
                      '${((originalPrice - discountedPrice) / originalPrice * 100).toInt()}% SAVED',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(9999),
                      color: Color.fromRGBO(35, 74, 62, 1),
                    ),
                    child: Text(
                      'Rp $discountedPrice',
                      style: TextStyle(color: Color.fromRGBO(240, 226, 186, 1), fontSize: 20),
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
                  Text(p['name'], style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  Text(p['seller']?['full_name'] ?? 'Penjual', style: TextStyle(fontSize: 16, color: Colors.grey)),
                  SizedBox(height: 16),
                  Text(p['description'] ?? '', style: TextStyle(fontSize: 15)),
                  SizedBox(height: 24),
                  Wrap(spacing: 8, children: [
                    Chip(label: Text('High Protein'), backgroundColor: Color.fromRGBO(78, 102, 93, 0.4)),
                    Chip(label: Text('Vegetarian'), backgroundColor: Color.fromRGBO(78, 102, 93, 0.4)),
                  ]),
                  SizedBox(height: 16),
                  if (p['pickup_start'] != null && p['pickup_end'] != null)
                    Chip(
                      label: Text(
                        'Pickup at ${p['pickup_start'].toString().substring(11, 16)} - ${p['pickup_end'].toString().substring(11, 16)}',
                      ),
                      backgroundColor: Color.fromRGBO(78, 102, 93, 0.4),
                    ),
                  SizedBox(height: 24),
                  Text('Pickup Location', style: TextStyle(fontSize: 24)),
                  SizedBox(height: 12),
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Color.fromRGBO(35, 74, 62, 1), width: 2),
                      image: DecorationImage(
                        image: AssetImage('assets/images/Rectangle11.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: () {},
                      child: Text('Get Directions'),
                    ),
                  ),
                  SizedBox(height: 24),
                  Row(
                    children: [
                      CircleAvatar(radius: 24, backgroundColor: Colors.grey, child: Icon(Icons.store)),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Managed by ${p['seller']?['full_name'] ?? 'Admin'}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text('Active 5 mins ago', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () {},
                        child: Text('Chat'),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 78,
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(color: Colors.black26, offset: Offset(0, -1), blurRadius: 1)],
          color: Color.fromRGBO(203, 222, 211, 1),
        ),
        child: Center(
          child: ElevatedButton(
            onPressed: _isOrdering ? null : _orderNow,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromRGBO(59, 98, 85, 1),
              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: _isOrdering
                ? CircularProgressIndicator(color: Colors.white)
                : Text('Grab Now', style: TextStyle(fontSize: 20, color: Color.fromRGBO(240, 226, 186, 1))),
          ),
        ),
      ),
    );
  }
}