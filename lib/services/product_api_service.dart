// lib/services/product_api_service.dart
import 'package:dio/dio.dart';
import '../models/product_model.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiService {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://app.getswipe.in/api/public',
    connectTimeout: Duration(milliseconds: 30000),
    receiveTimeout: Duration(milliseconds: 30000),
  ));

  static Future<List<Product>> getProducts() async {
    try {
      final response = await _dio.get('/get');
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
      Product product, dynamic imageData) async {
    try {
      FormData formData = FormData.fromMap({
        'product_name': product.productName,
        'product_type': product.productType,
        'price': product.price.toString(),
        'tax': product.tax.toString(),
      });

      if (imageData != null) {
        if (kIsWeb) {
          // Handle web image
          formData.files.add(MapEntry(
            'files[]',
            MultipartFile.fromBytes(
              imageData,
              filename: 'image.jpg',
            ),
          ));
        } else {
          // Handle mobile image
          formData.files.add(MapEntry(
            'files[]',
            await MultipartFile.fromFile(imageData),
          ));
        }
      }

      final response = await _dio.post(
        '/add',
        data: formData,
        onSendProgress: (int sent, int total) {
          print('Upload progress: ${(sent / total * 100).toStringAsFixed(2)}%');
        },
      );

      print('API Response: ${response.data}'); 

      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Failed to add product');
    } catch (e) {
      print('Error adding product: $e'); 
      throw Exception('Network error: $e');
    }
  }
}
