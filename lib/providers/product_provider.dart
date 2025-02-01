// import 'package:flutter/foundation.dart';

// import '../models/product_model.dart';

// import '../services/db_service.dart';
// import '../services/connectivity_service.dart';
// import '../services/product_api_service.dart';

// class ProductProvider with ChangeNotifier {
//   List<Product> _products = [];
//   bool _isLoading = false;
//   bool _isUploading = false;
//   double _uploadProgress = 0.0;
//   String _error = '';
//   String _searchQuery = '';
//   String _filterType = 'All';

//   // Getters
//   List<Product> get products => _products;
//   bool get isLoading => _isLoading;
//   bool get isUploading => _isUploading;
//   double get uploadProgress => _uploadProgress;
//   String get error => _error;
//   String get searchQuery => _searchQuery;
//   String get filterType => _filterType;

//   ProductProvider() {
//     _initializeProducts();
//     _listenToConnectivity();
//   }

//   void _listenToConnectivity() {
//     ConnectivityService.connectionStream.listen((bool hasConnection) {
//       if (hasConnection) {
//         syncUnsyncedProducts();
//       }
//     });
//   }

//   Future<void> _initializeProducts() async {
//     await fetchProducts();
//   }

//   Future<void> fetchProducts() async {
//     _isLoading = true;
//     _error = '';
//     notifyListeners();

//     try {
//       if (ConnectivityService.isConnected) {
//         final apiProducts = await ApiService.getProducts();
//         await _saveProductsLocally(apiProducts);
//       }

//       _products = await DBService.getProducts(searchQuery: _searchQuery);

//       if (_filterType != 'All') {
//         _products =
//             _products.where((p) => p.productType == _filterType).toList();
//       }
//     } catch (e) {
//       _error = e.toString();
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   Future<void> _saveProductsLocally(List<Product> products) async {
//     for (var product in products) {
//       await DBService.insertProduct(product);
//     }
//   }

//   Future<void> addProduct(Product product, String? imagePath) async {
//     _isUploading = true;
//     _uploadProgress = 0.0;
//     notifyListeners();

//     try {
//       // Save locally first
//       final localId = await DBService.insertProduct(
//         product.copyWith(isSynced: ConnectivityService.isConnected),
//       );

//       if (ConnectivityService.isConnected) {
//         final response = await ApiService.addProduct(product, imagePath);
//         if (response['success']) {
//           await DBService.markAsSynced(localId);
//         }
//       }

//       await fetchProducts();
//     } catch (e) {
//       _error = e.toString();
//     } finally {
//       _isUploading = false;
//       _uploadProgress = 0.0;
//       notifyListeners();
//     }
//   }

//   Future<void> syncUnsyncedProducts() async {
//     if (!ConnectivityService.isConnected) return;

//     final unsyncedProducts = await DBService.getUnsyncedProducts();
//     for (var product in unsyncedProducts) {
//       try {
//         final response = await ApiService.addProduct(product, product.image);
//         if (response['success']) {
//           await DBService.markAsSynced(product.id!);
//         }
//       } catch (e) {
//         print('Failed to sync product: ${product.id}');
//       }
//     }
//     await fetchProducts();
//   }

//   void setSearchQuery(String query) {
//     _searchQuery = query;
//     fetchProducts();
//   }

//   void setFilterType(String type) {
//     _filterType = type;
//     fetchProducts();
//   }

//   void updateUploadProgress(double progress) {
//     _uploadProgress = progress;
//     notifyListeners();
//   }
// }
import 'package:flutter/material.dart';

import '../models/product_model.dart';
import '../services/product_api_service.dart';


class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  bool _isLoading = false;
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String _error = '';
  String _searchQuery = '';
  String _filterType = 'All';

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  bool get isUploading => _isUploading;
  double get uploadProgress => _uploadProgress;
  String get error => _error;
  String get searchQuery => _searchQuery;
  String get filterType => _filterType;

  Future<void> fetchProducts() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _products = await ApiService.getProducts();

      // Apply search filter
      if (_searchQuery.isNotEmpty) {
        _products = _products
            .where((product) => product.productName
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()))
            .toList();
      }

      // Apply type filter
      if (_filterType != 'All') {
        _products = _products
            .where((product) => product.productType == _filterType)
            .toList();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addProduct(Product product, String? imagePath) async {
    _isUploading = true;
    _uploadProgress = 0.0;
    notifyListeners();

    try {
      await ApiService.addProduct(product, imagePath);
      await fetchProducts();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isUploading = false;
      _uploadProgress = 0.0;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    fetchProducts();
  }

  void setFilterType(String type) {
    _filterType = type;
    fetchProducts();
  }

  void updateUploadProgress(double progress) {
    _uploadProgress = progress;
    notifyListeners();
  }
}
