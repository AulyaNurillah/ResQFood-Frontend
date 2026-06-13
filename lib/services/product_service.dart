import 'dart:convert';

import 'package:http/http.dart'
    as http;

import '../models/product_model.dart';

class ProductService {

  static const String baseUrl =
      "https://resqfood-backend.up.railway.app";

  Future<List<Product>>
      getProducts() async {

    final response =
        await http.get(
      Uri.parse(
        "$baseUrl/api/products",
      ),
    );

    if (response.statusCode ==
        200) {

      final List<dynamic> data =
          jsonDecode(
        response.body,
      );

      return data
          .map(
            (e) =>
                Product.fromJson(e),
          )
          .toList();
    }

    throw Exception(
      "Gagal mengambil produk",
    );
  }
}