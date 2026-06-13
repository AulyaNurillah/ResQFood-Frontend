import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'ambilpesanan_screen.dart';
import '../../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> filteredProducts = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  Future<void> loadProducts() async {
    try {
      final response = await supabase
          .from('products')
          .select()
          .eq('status', 'tersedia')
          .order('created_at', ascending: false);

      setState(() {
        products = List<Map<String, dynamic>>.from(response);
        filteredProducts = products;
        isLoading = false;
      });
    } catch (e) {
      debugPrint(e.toString());

      setState(() {
        isLoading = false;
      });
    }
  }

  

  void searchProduct(String keyword) {
    setState(() {
      filteredProducts = products.where((product) {
        return product['name']
            .toString()
            .toLowerCase()
            .contains(keyword.toLowerCase());
      }).toList();
    });
  }

  void filterCategory(String category) {
    if (category == "Semua") {
      setState(() {
        filteredProducts = products;
      });
      return;
    }

    setState(() {
      filteredProducts = products.where((product) {
        return product['category'] == category;
      }).toList();
    });
  }

  String formatPrice(dynamic price) {
    return "Rp ${price.toString()}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCBDED3),

      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 24,
                    backgroundColor: Color(0xFFF0E2BA),
                    child: Icon(
                      Icons.person,
                      color: Color(0xFF234A3E),
                    ),
                  ),
                  const SizedBox(width: 15),

                  const Text(
                    'ResQFood',
                    style: TextStyle(
                      color: Color(0xFF133B1F),
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const Spacer(),

                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.notifications_none,
                      color: Color(0xFF234A3E),
                    ),
                  ),
                ],
              ),
            ),

            // SEARCH
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0x664E665D),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: TextField(
                  onChanged: searchProduct,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Makan apa hari ini?',
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : ListView(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 25),
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Kategori',
                              style: TextStyle(
                                color: Color(0xFF234A3E),
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),

                            const Spacer(),

                            TextButton(
                              onPressed: () {
                                filterCategory("Semua");
                              },
                              child: const Text(
                                "Lihat Semua",
                              ),
                            )
                          ],
                        ),

                        const SizedBox(height: 15),

                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceAround,
                          children: [
                            _CategoryItem(
                              Icons.restaurant,
                              "Restoran",
                              onTap: () =>
                                  filterCategory("Restoran"),
                            ),
                            _CategoryItem(
                              Icons.hotel,
                              "Hotel",
                              onTap: () =>
                                  filterCategory("Hotel"),
                            ),
                            _CategoryItem(
                              Icons.local_cafe,
                              "Cafe",
                              onTap: () =>
                                  filterCategory("Cafe"),
                            ),
                            _CategoryItem(
                              Icons.bakery_dining,
                              "Bakery",
                              onTap: () =>
                                  filterCategory("Bakery"),
                            ),
                            _CategoryItem(
                              Icons.storefront,
                              "Kaki Lima",
                              onTap: () =>
                                  filterCategory("Kaki Lima"),
                            ),
                          ],
                        ),

                        const SizedBox(height: 25),

                        const Text(
                          'Surplus Populer',
                          style: TextStyle(
                            color: Color(0xFF234A3E),
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 15),

                        ...filteredProducts.map(
                          (product) => Padding(
                            padding:
                                const EdgeInsets.only(bottom: 20),
                            child: _foodCard(product),
                          ),
                        ),

                        const SizedBox(height: 100),
                      ],
                    ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(16),
        height: 70,
        decoration: BoxDecoration(
          color: const Color(0xFF3B6255),
          borderRadius: BorderRadius.circular(38),
        ),
        child: const Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceEvenly,
          children: [
            Icon(Icons.home, color: Color(0xFFF0E2BA)),
            Icon(Icons.favorite_border,
                color: Color(0xFFF0E2BA)),
            Icon(Icons.shopping_bag_outlined,
                color: Color(0xFFF0E2BA)),
            Icon(Icons.person_outline,
                color: Color(0xFFF0E2BA)),
          ],
        ),
      ),
    );
  }

  Widget _foodCard(Map<String, dynamic> product) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0E2BA),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        children: [
          Container(
            height: 150,
            width: double.infinity,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(25),
              ),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(25),
              ),
              child: product['image_url'] != null
                  ? Image.network(
                      product['image_url'],
                      fit: BoxFit.cover,
                    )
                  : const Icon(
                      Icons.fastfood,
                      size: 80,
                    ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  product['name'] ?? '-',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Text(
                  product['category'] ?? '-',
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    Text(
                      formatPrice(product['price']),
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF234A3E),
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const Spacer(),
                    // Di dalam HomeScreen, pada bagian ElevatedButton di _foodCard:
                    ElevatedButton(
                      onPressed: () async {
                      final authService = AuthService();

                      final userId =
                          await authService.getUserId();

                      if (userId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Silakan login terlebih dahulu'),
                          ),
                        );
                        return;
                      }

                        // Tampilkan loading
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => const Center(child: CircularProgressIndicator()),
                        );

                        try {
                          // Buat order
                          final response = await supabase
                              .from('orders')
                              .insert({
                                'buyer_id': userId,
                                'seller_id': product['seller_id'],
                                'product_id': product['id'],
                                'quantity': 1,
                                'total_price': product['price'],
                                'status': 'menunggu_konfirmasi_penjual',
                              })
                              .select()
                              .single();

                          // Tutup dialog loading
                          if (context.mounted) Navigator.pop(context);

                          // Navigasi ke halaman ambil pesanan (QR Code)
                          if (context.mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AmbilPesananScreen( // Ganti dari ConfirmQRPage ke AmbilPesananScreen
                                  orderId: response['id'].toString(),
                                  orderData: response,
                                  productData: product,
                                ),
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Gagal membuat pesanan: $e')),
                          );
                        }
                      },
                      child: const Text("Grab Now"),
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
class AmbilpesananScreen extends StatelessWidget {
  final Map<String, dynamic> order;
  final Map<String, dynamic> product;

  const AmbilpesananScreen({
    super.key,
    required this.order,
    required this.product,
  });

  String formatPrice(dynamic value) {
    return "Rp ${value.toString()}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Konfirmasi QR'),
        backgroundColor: const Color(0xFF3B6255),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pesanan berhasil dibuat!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text('Produk: ${product['name'] ?? '-'}'),
            Text('Total: ${product['price'] != null ? formatPrice(product['price']) : '-'}'),
            const SizedBox(height: 20),
            const Text(
              'Silakan tunjukkan halaman ini untuk konfirmasi pembayaran.',
            ),

          ],
        ),
      ),
    );
  }
}
class _CategoryItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  const _CategoryItem(
    this.icon,
    this.title, {
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor:
                const Color(0xFF9BB0A5),
            child: Icon(
              icon,
              color: const Color(0xFF234A3E),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF234A3E),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }



}