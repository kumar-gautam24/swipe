import 'package:hive_flutter/hive_flutter.dart';
import '../models/product_hive.dart';
import '../models/product_model.dart';

/// A service that manages storing and retrieving [Product] data using [Hive].
class StorageService {
  /// The name of the Hive box for products.
  static const String _productsBoxName = 'products';

  /// Reference to the open Hive box, which will hold [ProductHive] objects.
  static Box<ProductHive>? _productsBox;

  /// Initializes Hive, registers adapters, and opens the products box.
  ///
  /// Must be called once before any other method is used.
  static Future<void> initialize() async {
    await Hive.initFlutter();
    Hive.registerAdapter(ProductHiveAdapter());
    _productsBox = await Hive.openBox<ProductHive>(_productsBoxName);
  }

  /// Clears existing products and saves the provided [products] to the box.
  ///
  /// If the box is not yet open or an error occurs, it does nothing.
  static Future<void> saveProducts(List<Product> products) async {
    await _productsBox?.clear();
    final hiveProducts = products.map((p) => ProductHive.fromProduct(p)).toList();
    await _productsBox?.addAll(hiveProducts);
  }

  /// Saves a single [product] to the box.
  ///
  /// Pass [isSynced] to indicate whether this product is synced with a backend.
  static Future<void> saveProduct(Product product, {bool isSynced = true}) async {
    final hiveProduct = ProductHive.fromProduct(product);
    await _productsBox?.add(hiveProduct);
  }

  /// Retrieves all stored [Product] instances from the box.
  ///
  /// Returns an empty list if the box is closed or empty.
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
