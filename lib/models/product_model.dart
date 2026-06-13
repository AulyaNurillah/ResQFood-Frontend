class Product {
  final String id;
  final String sellerId;
  final String name;
  final String? description;
  final int price;
  final int stock;
  final String imageUrl;
  final String status;
  final String sellerName;
  final String? category;
  final String? pickupStart;
  final String? pickupEnd;
  final String? expiredDate;

  Product({
    required this.id,
    required this.sellerId,
    required this.name,
    this.description,
    required this.price,
    required this.stock,
    required this.imageUrl,
    required this.status,
    required this.sellerName,
    this.category,
    this.pickupStart,
    this.pickupEnd,
    this.expiredDate,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json["id"] ?? json["_id"] ?? "",
      sellerId: json["seller_id"] ?? json["sellerId"] ?? "",
      name: json["name"] ?? "",
      description: json["description"] ?? "",
      price: json["price"] ?? 0,
      stock: json["stock"] ?? 0,
      imageUrl: json["image_url"] ?? json["imageUrl"] ?? "",
      status: json["status"] ?? "",
      sellerName: json["seller"]?["full_name"] ?? json["seller_name"] ?? "Unknown Seller",
      category: json["category"],
      pickupStart: json["pickup_start"] ?? json["pickupStart"],
      pickupEnd: json["pickup_end"] ?? json["pickupEnd"],
      expiredDate: json["expired_date"] ?? json["expiredDate"],
    );
  }
}

typedef ProductModel = Product;