import 'package:hive/hive.dart';
import 'package:swipe/models/product_model.dart';

part 'product_hive.g.dart';

@HiveType(typeId: 0)
class ProductHive extends HiveObject {
  @HiveField(0)
  final String image;

  @HiveField(1)
  final double price;

  @HiveField(2)
  final String productName;

  @HiveField(3)
  final String productType;

  @HiveField(4)
  final double tax;

  @HiveField(5)
  final bool isSynced;

  ProductHive({
    required this.image,
    required this.price,
    required this.productName,
    required this.productType,
    required this.tax,
    this.isSynced = true,
  });

  factory ProductHive.fromProduct(Product product) {
    return ProductHive(
      image: product.image,
      price: product.price,
      productName: product.productName,
      productType: product.productType,
      tax: product.tax,
    );
  }

  Product toProduct() {
    return Product(
      image: image,
      price: price,
      productName: productName,
      productType: productType,
      tax: tax,
    );
  }
}
