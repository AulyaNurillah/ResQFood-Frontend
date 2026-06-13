class ProductModel {
  final String id;
  final String name;
  final String? description;
  final int price;
  final int stock;
  final String? imageUrl;
  final String? category;

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    this.description,
    this.imageUrl,
    this.category,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'] ?? 0,
      stock: json['stock'] ?? 0,
      imageUrl: json['image_url'],
      category: json['category'],
    );
  }
}