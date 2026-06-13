import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/product_model.dart';
import '../../services/product_service.dart';
import '../../widgets/product_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ProductService productService = ProductService();

  List<Product> products = [];
  List<Product> filteredProducts = [];
  bool isLoading = true;
  String selectedCategory = "Semua";

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  Future<void> loadProducts() async {
    try {
      final fetchedProducts = await productService.getProducts();
      if (mounted) {
        setState(() {
          products = fetchedProducts;
          filteredProducts = fetchedProducts;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint(e.toString());
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void searchProduct(String keyword) {
    setState(() {
      filteredProducts = products.where((product) {
        return product.name
            .toLowerCase()
            .contains(keyword.toLowerCase());
      }).toList();
    });
  }

  void filterCategory(String category) {
    setState(() {
      selectedCategory = category;
      if (category == "Semua") {
        filteredProducts = products;
      } else {
        filteredProducts = products.where((product) {
          return product.category?.toLowerCase() == category.toLowerCase();
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// HEADER
              Row(
                children: [
                  const CircleAvatar(
                    radius: 22,
                    backgroundImage: AssetImage(
                      "assets/images/profile.jpg",
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      "ResQFood",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.notifications_none,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              /// SEARCH
              TextField(
                onChanged: searchProduct,
                decoration: InputDecoration(
                  hintText: "Makan apa hari ini?",
                  prefixIcon: const Icon(
                    Icons.search,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 25),

              /// KATEGORI
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Kategori",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  TextButton(
                    onPressed: () => filterCategory("Semua"),
                    child: const Text("Lihat Semua"),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _CategoryItem(
                    icon: Icons.restaurant,
                    title: "Restoran",
                    isSelected: selectedCategory == "Restoran",
                    onTap: () => filterCategory("Restoran"),
                  ),
                  _CategoryItem(
                    icon: Icons.hotel,
                    title: "Hotel",
                    isSelected: selectedCategory == "Hotel",
                    onTap: () => filterCategory("Hotel"),
                  ),
                  _CategoryItem(
                    icon: Icons.coffee,
                    title: "Cafe",
                    isSelected: selectedCategory == "Cafe",
                    onTap: () => filterCategory("Cafe"),
                  ),
                  _CategoryItem(
                    icon: Icons.cake,
                    title: "Bakery",
                    isSelected: selectedCategory == "Bakery",
                    onTap: () => filterCategory("Bakery"),
                  ),
                  _CategoryItem(
                    icon: Icons.store,
                    title: "UMKM",
                    isSelected: selectedCategory == "UMKM",
                    onTap: () => filterCategory("UMKM"),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              /// PRODUK
              const Text(
                "Surplus Populer",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 15),

              if (isLoading)
                const Center(
                  child: CircularProgressIndicator(),
                )
              else if (filteredProducts.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Text(
                      "Tidak ada produk tersedia",
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ),
                )
              else
                Column(
                  children: filteredProducts.map((product) {
                    return ProductCard(
                      product: product,
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view),
            label: "Explore",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: "Add",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: "Chat",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryItem({
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: isSelected ? AppColors.primary : const Color(0xFF9BB0A5),
            child: Icon(
              icon,
              color: isSelected ? Colors.white : const Color(0xFF234A3E),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: TextStyle(
              color: isSelected ? AppColors.primary : const Color(0xFF234A3E),
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}