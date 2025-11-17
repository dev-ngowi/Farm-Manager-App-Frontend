// lib/core/networking/network_info.dart
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  final Connectivity _connectivity = Connectivity();
  final InternetConnectionChecker _checker = InternetConnectionChecker.instance;

  @override
  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    if (result == ConnectivityResult.none) return false;
    return await _checker.hasConnection;
  }
}