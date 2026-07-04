import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Service for monitoring network connectivity status.
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();

  /// Stream of connectivity changes.
  Stream<bool> get connectionStream => _connectionController.stream;

  /// Current connectivity status.
  bool _isConnected = true;
  bool get isConnected => _isConnected;

  /// Start monitoring connectivity changes.
  void startMonitoring() {
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      final wasConnected = _isConnected;
      _isConnected =
          results.isNotEmpty && !results.contains(ConnectivityResult.none);

      if (wasConnected != _isConnected) {
        _connectionController.add(_isConnected);
      }
    });
  }

  /// Stop monitoring connectivity changes.
  void stopMonitoring() {
    _subscription?.cancel();
    _subscription = null;
  }

  /// Check current connectivity status.
  Future<bool> checkConnectivity() async {
    final results = await _connectivity.checkConnectivity();
    _isConnected =
        results.isNotEmpty && !results.contains(ConnectivityResult.none);
    return _isConnected;
  }

  /// Dispose resources.
  void dispose() {
    stopMonitoring();
    _connectionController.close();
  }
}
