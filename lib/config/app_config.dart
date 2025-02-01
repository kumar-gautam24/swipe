class AppConfig {
  static const String baseUrl = 'https://app.getswipe.in/api/public';
  static const String getProductsEndpoint = '/get';
  static const String addProductEndpoint = '/add';

  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;

  static const String dbName = 'product_database.db';
  static const int dbVersion = 1;
}
