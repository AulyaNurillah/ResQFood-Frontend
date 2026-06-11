class Product {
  final String id;
  final String name;
  final String description;
  final int price;
  final int stock;
  final String? imageUrl;
  final String sellerId;
  final String sellerName;
  final String? category;
  final DateTime? pickupStart;
  final DateTime? pickupEnd;
  final DateTime? expiredDate;
  final String status;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    this.imageUrl,
    required this.sellerId,
    required this.sellerName,
    this.category,
    this.pickupStart,
    this.pickupEnd,
    this.expiredDate,
    required this.status,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      price: json['price'],
      stock: json['stock'],
      imageUrl: json['image_url'],
      sellerId: json['seller_id'],
      sellerName: json['seller']?['full_name'] ?? '',
      category: json['category'],
      pickupStart: json['pickup_start'] != null ? DateTime.parse(json['pickup_start']) : null,
      pickupEnd: json['pickup_end'] != null ? DateTime.parse(json['pickup_end']) : null,
      expiredDate: json['expired_date'] != null ? DateTime.parse(json['expired_date']) : null,
      status: json['status'],
    );
  }
}