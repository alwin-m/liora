import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();

  late Connectivity _connectivity;
  bool _isConnected = false;

  factory ConnectivityService() {
    return _instance;
  }

  ConnectivityService._internal() {
    _connectivity = Connectivity();
    _initialize();
  }

  void _initialize() async {
    final result = await _connectivity.checkConnectivity();
    _isConnected = !result.contains(ConnectivityResult.none);
  }

  Future<bool> isConnected() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _isConnected = !result.contains(ConnectivityResult.none);
      return _isConnected;
    } catch (e) {
      return false;
    }
  }

  bool get currentStatus => _isConnected;

  Stream<bool> get onConnectivityChanged => _connectivity.onConnectivityChanged
      .map((result) => !result.contains(ConnectivityResult.none));
}
