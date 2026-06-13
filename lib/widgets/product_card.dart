import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../models/product_model.dart';

class ProductCard
    extends StatelessWidget {

  final Product product;

  const ProductCard({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 18,
      ),

      decoration:
          BoxDecoration(
        color: AppColors.cream,

        borderRadius:
            BorderRadius.circular(
          20,
        ),

        boxShadow: const [
          BoxShadow(
            blurRadius: 8,
            offset: Offset(0, 3),
            color:
                Colors.black12,
          )
        ],
      ),

      child: Column(
        children: [

          ClipRRect(
            borderRadius:
                const BorderRadius.only(
              topLeft:
                  Radius.circular(
                20,
              ),
              topRight:
                  Radius.circular(
                20,
              ),
            ),

            child: Image.network(
              product.imageUrl,

              height: 140,

              width:
                  double.infinity,

              fit: BoxFit.cover,

              errorBuilder:
                  (_, __, ___) {

                return Container(
                  height: 140,
                  color:
                      Colors.grey[300],

                  child:
                      const Center(
                    child: Icon(
                      Icons.image,
                      size: 50,
                    ),
                  ),
                );
              },
            ),
          ),

          Padding(
            padding:
                const EdgeInsets.all(
              14,
            ),

            child: Row(
              children: [

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,

                    children: [

                      Text(
                        product.name,

                        style:
                            const TextStyle(
                          fontSize:
                              16,
                          fontWeight:
                              FontWeight
                                  .bold,
                        ),
                      ),

                      const SizedBox(
                        height: 4,
                      ),

                      Text(
                        product
                            .sellerName,

                        style:
                            TextStyle(
                          color:
                              Colors.grey[700],
                        ),
                      ),

                      const SizedBox(
                        height: 8,
                      ),

                      Text(
                        "Rp ${product.price}",

                        style:
                            const TextStyle(
                          fontSize:
                              18,
                          fontWeight:
                              FontWeight
                                  .bold,
                          color:
                              AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),

                ElevatedButton(
                  onPressed: () {},

                  style:
                      ElevatedButton
                          .styleFrom(
                    backgroundColor:
                        AppColors.secondary,
                  ),

                  child: const Text(
                    "Grab Now",
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}