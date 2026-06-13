class Product {

  final String id;
  final String sellerId;
  final String name;
  final String description;
  final int price;
  final int stock;
  final String imageUrl;
  final String status;
  final String sellerName;

  Product({
    required this.id,
    required this.sellerId,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.imageUrl,
    required this.status,
    required this.sellerName,
  });

  factory Product.fromJson(
    Map<String, dynamic> json,
  ) {

    return Product(
      id: json["id"],
      sellerId: json["seller_id"],
      name: json["name"],
      description:
          json["description"] ?? "",
      price: json["price"] ?? 0,
      stock: json["stock"] ?? 0,
      imageUrl:
          json["image_url"] ?? "",
      status:
          json["status"] ?? "",
      sellerName:
          json["seller"]?["full_name"] ??
              "Unknown Seller",
    );
  }
}