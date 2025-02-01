import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../models/product_model.dart';

class ApiService {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: AppConfig.baseUrl,
    connectTimeout: Duration(milliseconds: AppConfig.connectionTimeout),
    receiveTimeout: Duration(milliseconds: AppConfig.receiveTimeout),
  ));

  static Future<List<Product>> getProducts() async {
    try {
      final response = await _dio.get(AppConfig.getProductsEndpoint);
      if (response.statusCode == 200) {
        return (response.data as List)
            .map((item) => Product.fromJson(item))
            .toList();
      }
      throw Exception('Failed to load products');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<Map<String, dynamic>> addProduct(
      Product product, String? imagePath) async {
    try {
      FormData formData = FormData.fromMap({
        'product_name': product.productName,
        'product_type': product.productType,
        'price': product.price,
        'tax': product.tax,
      });

      if (imagePath != null) {
        formData.files.add(MapEntry(
          'files[]',
          await MultipartFile.fromFile(imagePath),
        ));
      }

      final response = await _dio.post(
        AppConfig.addProductEndpoint,
        data: formData,
      );

      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Failed to add product');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
