// lib/core/widgets/connectivity_monitor.dart

import 'package:flutter/material.dart';
import 'package:farm_manager_app/core/networking/network_info.dart';
import 'package:farm_manager_app/core/di/locator.dart';

/// ⚡ OPTIONAL: Wraps your app to monitor connectivity changes
/// Shows a banner when internet is lost/restored
class ConnectivityMonitor extends StatefulWidget {
  final Widget child;

  const ConnectivityMonitor({
    super.key,
    required this.child,
  });

  @override
  State<ConnectivityMonitor> createState() => _ConnectivityMonitorState();
}

class _ConnectivityMonitorState extends State<ConnectivityMonitor> {
  late final NetworkInfo _networkInfo;
  bool _isConnected = true;
  bool _hasShownDisconnectedBanner = false;

  @override
  void initState() {
    super.initState();
    _networkInfo = getIt<NetworkInfo>();
    _monitorConnectivity();
  }

  void _monitorConnectivity() {
    _networkInfo.onConnectivityChanged.listen((isConnected) {
      if (mounted) {
        setState(() {
          _isConnected = isConnected;
        });

        if (!isConnected && !_hasShownDisconnectedBanner) {
          _showNoConnectionBanner();
          _hasShownDisconnectedBanner = true;
        } else if (isConnected && _hasShownDisconnectedBanner) {
          _showConnectionRestoredBanner();
          _hasShownDisconnectedBanner = false;
        }
      }
    });
  }

  void _showNoConnectionBanner() {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.wifi_off, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'No internet connection',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.redAccent,
        duration: Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showConnectionRestoredBanner() {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.wifi, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Connection restored',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Show persistent banner at top when disconnected
        if (!_isConnected)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            color: Colors.red.shade700,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.wifi_off, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text(
                  'No Internet Connection',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        Expanded(child: widget.child),
      ],
    );
  }
}

/// ⚡ HOW TO USE IN YOUR APP.DART:
/// 
/// Wrap your MaterialApp.router with ConnectivityMonitor:
/// 
/// ```dart
/// class FarmBondApp extends StatelessWidget {
///   const FarmBondApp({super.key});
/// 
///   @override
///   Widget build(BuildContext context) {
///     final languageProvider = Provider.of<LanguageProvider>(context);
/// 
///     return ConnectivityMonitor(  // <-- ADD THIS WRAPPER
///       child: MaterialApp.router(
///         debugShowCheckedModeBanner: false,
///         title: 'Farm Bond App',
///         theme: AppTheme.light(context),
///         // ... rest of your config
///         routerConfig: router,
///       ),
///     );
///   }
/// }
/// ```