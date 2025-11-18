// lib/core/networking/interceptors/connectivity_interceptor.dart

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';

class ConnectivityInterceptor extends Interceptor {
  final Connectivity _connectivity = Connectivity();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final result = await _connectivity.checkConnectivity();
    final bool isOffline = result == ConnectivityResult.none;

    // Just tag the request – do NOT reject
    options.extra['is_offline'] = isOffline;

    // Always proceed
    handler.next(options);
  }
}