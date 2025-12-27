import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
  Stream<bool> get onConnectivityChanged;
}

class NetworkInfoImpl implements NetworkInfo {
  final Connectivity _connectivity = Connectivity();
  final InternetConnectionChecker _checker = InternetConnectionChecker.instance;

  NetworkInfoImpl() {
    // ⚡ Configure connection checker for faster response
    _checker.checkInterval = const Duration(seconds: 3);
  }

  @override
  Future<bool> get isConnected async {
    try {
      // Step 1: Quick check - Do we have network connectivity?
      final connectivityResults = await _connectivity.checkConnectivity();
      
      // Handle multiple connection types (WiFi + Mobile Data)
      if (connectivityResults.contains(ConnectivityResult.none)) {
        return false;
      }
      
      // Step 2: Verify actual internet access (ping Google/Cloudflare DNS)
      final hasConnection = await _checker.hasConnection;
      return hasConnection;
      
    } catch (e) {
      // If check fails, assume no connection
      return false;
    }
  }

  @override
  Stream<bool> get onConnectivityChanged {
    // Monitor connectivity changes in real-time
    return _connectivity.onConnectivityChanged.asyncMap((results) async {
      if (results.contains(ConnectivityResult.none)) {
        return false;
      }
      try {
        return await _checker.hasConnection;
      } catch (e) {
        return false;
      }
    });
  }
}

/// ⚡ Faster Network Info (for UI checks only - less accurate)
class QuickNetworkInfo implements NetworkInfo {
  final Connectivity _connectivity = Connectivity();

  @override
  Future<bool> get isConnected async {
    try {
      final results = await _connectivity.checkConnectivity();
      return !results.contains(ConnectivityResult.none);
    } catch (e) {
      return false;
    }
  }

  @override
  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map((results) {
      return !results.contains(ConnectivityResult.none);
    });
  }
}