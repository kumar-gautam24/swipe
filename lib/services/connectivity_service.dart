import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  static final Connectivity _connectivity = Connectivity();
  static final StreamController<bool> _connectionStatusController =
      StreamController<bool>.broadcast();
  static bool _hasConnection = false;

  static Future<void> initialize() async {
    List<ConnectivityResult> result = await _connectivity.checkConnectivity();
    _handleConnectionStatus(result);

    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> result) {
      _handleConnectionStatus(result);
    });
  }

  static void _handleConnectionStatus(List<ConnectivityResult> result) {
    _hasConnection = result != ConnectivityResult.none;
    _connectionStatusController.add(_hasConnection);
  }

  static Stream<bool> get connectionStream => _connectionStatusController.stream;

  static bool get isConnected => _hasConnection;

  static void dispose() {
    _connectionStatusController.close();
  }
}
