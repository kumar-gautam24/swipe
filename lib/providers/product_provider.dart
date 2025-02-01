import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/product_api_service.dart';
import '../services/storage_service.dart';
import '../services/connectivity_service.dart';

/// Provider class that manages [Product] data. It handles:
/// - Fetching products from the API if online, or local storage if offline.
/// - Adding and syncing products with local storage.
/// - Filtering and searching the product list.
class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  bool _isLoading = false;
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String _error = '';
  String _searchQuery = '';
  String _filterType = 'All';

  /// Initializes the provider by fetching products and
  /// setting up a listener for connectivity changes.
  ProductProvider() {
    _initializeProducts();
    _listenToConnectivity();
  }

  /// A list of products that the UI can display.
  List<Product> get products => _products;

  /// Indicates whether a fetch operation is in progress.
  bool get isLoading => _isLoading;

  /// Indicates whether an upload operation is in progress.
  bool get isUploading => _isUploading;

  /// Represents the current upload progress, useful for UI progress indicators.
  double get uploadProgress => _uploadProgress;

  /// Holds an error message if any operation fails.
  String get error => _error;

  /// Used to filter products by name.
  String get searchQuery => _searchQuery;

  /// Used to filter products by type (e.g., 'All', 'Product', or 'Service').
  String get filterType => _filterType;

  /// Sets a listener on the connectivity stream to automatically sync products
  /// if a connection becomes available.
  void _listenToConnectivity() {
    ConnectivityService.connectionStream.listen((bool hasConnection) {
      if (hasConnection) {
        syncProducts();
      }
    });
  }

  /// Initializes the list of products by fetching them and applying filters.
  Future<void> _initializeProducts() async {
    await fetchProducts();
  }

  /// Fetches products from the API if connected; otherwise, loads from local storage.
  /// After fetching, applies the current search and filter criteria.
  Future<void> fetchProducts() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      if (ConnectivityService.isConnected) {
        // Fetch remote products
        _products = await ApiService.getProducts();
        // Save them locally
        await StorageService.saveProducts(_products);
      } else {
        // Load from local storage
        _products = StorageService.getProducts();
      }
      _applyFilters();
    } catch (e) {
      // On error, save the error message and load local data
      _error = e.toString();
      _products = StorageService.getProducts();
      _applyFilters();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Adds a new product to both the API (if online) and local storage.
  /// Refreshes the product list afterward.
  Future<void> addProduct(Product product, dynamic imageData) async {
    _isUploading = true;
    _uploadProgress = 0.0;
    notifyListeners();

    try {
      if (ConnectivityService.isConnected) {
        // Upload to remote
        await ApiService.addProduct(product, imageData);
        // Mark as synced in local storage
        await StorageService.saveProduct(product, isSynced: true);
      } else {
        // Only save locally if offline
        await StorageService.saveProduct(product, isSynced: false);
      }
      // Refresh products
      await fetchProducts();
    } catch (e) {
      _error = e.toString();
      // Fallback: save locally, mark unsynced
      await StorageService.saveProduct(product, isSynced: false);
      rethrow; // Rethrow so UI can handle error
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  /// Syncs all unsynced products with the remote API, then fetches updated data.
  Future<void> syncProducts() async {
    if (!ConnectivityService.isConnected) return;

    final unsyncedProducts = StorageService.getUnsyncedProducts();
    for (var product in unsyncedProducts) {
      try {
        await ApiService.addProduct(product, product.image);
      } catch (e) {
        // Log or handle sync errors if needed
      }
    }
    await fetchProducts();
  }

  /// Applies a search query and refreshes the product list with updated filters.
  void setSearchQuery(String query) {
    _searchQuery = query;
    fetchProducts();
  }

  /// Changes the filter type (e.g., 'All', 'Product', or 'Service') 
  /// and refreshes the product list with updated filters.
  void setFilterType(String type) {
    _filterType = type;
    fetchProducts();
  }

  /// Updates the upload progress, useful for UI indicators.
  void updateUploadProgress(double progress) {
    _uploadProgress = progress;
    notifyListeners();
  }

  /// Applies the current search query and filter type to the products list.
  void _applyFilters() {
    // Start with the full list from local storage
    var tempList = StorageService.getProducts();

    if (_searchQuery.isNotEmpty) {
      tempList = tempList
          .where((product) =>
              product.productName.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    if (_filterType != 'All') {
      tempList = tempList
          .where((product) => product.productType == _filterType)
          .toList();
    }

    _products = tempList;
  }
}
