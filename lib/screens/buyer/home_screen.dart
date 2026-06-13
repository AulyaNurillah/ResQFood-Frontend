import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../models/product_model.dart';
import '../../services/product_service.dart';
import '../../widgets/product_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() =>
      _HomeScreenState();
}

class _HomeScreenState
    extends State<HomeScreen> {

  final ProductService
      productService =
          ProductService();

  List<Product> products = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  Future<void> loadProducts()
  async {

    try {

      products =
          await productService
              .getProducts();

    } catch (e) {

      debugPrint(
        e.toString(),
      );

    }

    if (mounted) {

      setState(() {
        isLoading = false;
      });

    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          AppColors.background,

      body: SafeArea(

        child:
            SingleChildScrollView(

          padding:
              const EdgeInsets.all(
            20,
          ),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              /// HEADER

              Row(
                children: [

                  const CircleAvatar(
                    radius: 22,
                    backgroundImage:
                        AssetImage(
                      "assets/images/profile.jpg",
                    ),
                  ),

                  const SizedBox(
                    width: 12,
                  ),

                  const Expanded(
                    child: Text(
                      "ResQFood",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight:
                            FontWeight.bold,
                        color:
                            AppColors.primary,
                      ),
                    ),
                  ),

                  IconButton(
                    onPressed: () {},

                    icon: const Icon(
                      Icons
                          .notifications_none,
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 20,
              ),

              /// SEARCH

              TextField(

                decoration:
                    InputDecoration(

                  hintText:
                      "Makan apa hari ini?",

                  prefixIcon:
                      const Icon(
                    Icons.search,
                  ),

                  filled: true,

                  fillColor:
                      Colors.white,

                  border:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                      30,
                    ),

                    borderSide:
                        BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(
                height: 25,
              ),

              /// KATEGORI

              Row(
                mainAxisAlignment:
                    MainAxisAlignment
                        .spaceBetween,

                children: [

                  const Text(
                    "Kategori",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight:
                          FontWeight.bold,
                      color:
                          AppColors.primary,
                    ),
                  ),

                  TextButton(
                    onPressed: () {},

                    child:
                        const Text(
                      "Lihat Semua",
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 15,
              ),

              Row(
                mainAxisAlignment:
                    MainAxisAlignment
                        .spaceAround,

                children: const [

                  _CategoryItem(
                    icon:
                        Icons.restaurant,
                    title:
                        "Restoran",
                  ),

                  _CategoryItem(
                    icon:
                        Icons.hotel,
                    title:
                        "Hotel",
                  ),

                  _CategoryItem(
                    icon:
                        Icons.coffee,
                    title:
                        "Cafe",
                  ),

                  _CategoryItem(
                    icon:
                        Icons.cake,
                    title:
                        "Bakery",
                  ),

                  _CategoryItem(
                    icon:
                        Icons.store,
                    title:
                        "UMKM",
                  ),
                ],
              ),

              const SizedBox(
                height: 30,
              ),

              /// PRODUK

              const Text(
                "Surplus Populer",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight:
                      FontWeight.bold,
                  color:
                      AppColors.primary,
                ),
              ),

              const SizedBox(
                height: 15,
              ),

              if (isLoading)

                const Center(
                  child:
                      CircularProgressIndicator(),
                )

              else

                Column(
                  children:
                      products.map(
                    (product) {

                      return ProductCard(
                        product:
                            product,
                      );

                    },
                  ).toList(),
                ),
            ],
          ),
        ),
      ),

      bottomNavigationBar:
          BottomNavigationBar(

        currentIndex: 0,

        selectedItemColor:
            AppColors.primary,

        unselectedItemColor:
            Colors.grey,

        type:
            BottomNavigationBarType
                .fixed,

        items: const [

          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
            ),
            label: "Home",
          ),

          BottomNavigationBarItem(
            icon: Icon(
              Icons.grid_view,
            ),
            label: "Explore",
          ),

          BottomNavigationBarItem(
            icon: Icon(
              Icons.add_circle,
            ),
            label: "Add",
          ),

          BottomNavigationBarItem(
            icon: Icon(
              Icons.chat_bubble_outline,
            ),
            label: "Chat",
          ),

          BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
            ),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}

class _CategoryItem
    extends StatelessWidget {

  final IconData icon;
  final String title;

  const _CategoryItem({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [

        CircleAvatar(
          radius: 24,
          backgroundColor:
              AppColors.secondary,

          child: Icon(
            icon,
            color:
                Colors.white,
          ),
        ),

        const SizedBox(
          height: 6,
        ),

        Text(
          title,
          style:
              const TextStyle(
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}