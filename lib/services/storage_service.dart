

import 'package:hive_flutter/hive_flutter.dart';

// import 'package:hive_flutter/adapters.dart';

import '../models/product_hive.dart';
import '../models/product_model.dart';

class StorageService {
  static const String _productsBoxName = 'products';
  static Box<ProductHive>? _productsBox;

  static Future<void> initialize() async {
    await Hive.initFlutter();
    Hive.registerAdapter(ProductHiveAdapter());
    _productsBox = await Hive.openBox<ProductHive>(_productsBoxName);
  }

  static Future<void> saveProducts(List<Product> products) async {
    await _productsBox?.clear();
    final hiveProducts =
        products.map((p) => ProductHive.fromProduct(p)).toList();
    await _productsBox?.addAll(hiveProducts);
  }

  static Future<void> saveProduct(Product product,
      {bool isSynced = true}) async {
    final hiveProduct = ProductHive.fromProduct(product);
    await _productsBox?.add(hiveProduct);
  }

  static List<Product> getProducts() {
    return _productsBox?.values.map((p) => p.toProduct()).toList() ?? [];
  }

  static List<Product> getUnsyncedProducts() {
    return _productsBox?.values
            .where((p) => !p.isSynced)
            .map((p) => p.toProduct())
            .toList() ??
        [];
  }

  static Future<void> clearAll() async {
    await _productsBox?.clear();
  }
}
