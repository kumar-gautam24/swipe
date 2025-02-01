class Product {
  final int? id;
  final String image;
  final double price;
  final String productName;
  final String productType;
  final double tax;
  final bool isSynced;

  Product({
    this.id,
    required this.image,
    required this.price,
    required this.productName,
    required this.productType,
    required this.tax,
    this.isSynced = true,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      image: json['image'] ?? '',
      price: double.parse(json['price'].toString()),
      productName: json['product_name'],
      productType: json['product_type'],
      tax: double.parse(json['tax'].toString()),
      isSynced: json['is_synced'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image': image,
      'price': price,
      'product_name': productName,
      'product_type': productType,
      'tax': tax,
      'is_synced': isSynced,
    };
  }

  Product copyWith({
    int? id,
    String? image,
    double? price,
    String? productName,
    String? productType,
    double? tax,
    bool? isSynced,
  }) {
    return Product(
      id: id ?? this.id,
      image: image ?? this.image,
      price: price ?? this.price,
      productName: productName ?? this.productName,
      productType: productType ?? this.productType,
      tax: tax ?? this.tax,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
