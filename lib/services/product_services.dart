import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product_model.dart';

class ProductService {
  final supabase = Supabase.instance.client;

  Future<List<ProductModel>> getProducts() async {
    final response = await supabase
        .from('products')
        .select()
        .eq('status', 'tersedia');

    return (response as List)
        .map((e) => ProductModel.fromJson(e))
        .toList();
  }
}