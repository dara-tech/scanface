import 'package:flutter/foundation.dart';
import 'dart:async';
import '../services/api_service.dart';
import '../config/api_config.dart';

enum ConnectionStatus {
  connected,
  disconnected,
  connecting,
  syncing,
}

class ConnectionProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  Timer? _healthCheckTimer;
  
  ConnectionStatus _status = ConnectionStatus.connecting;
  bool _isOnline = false;
  DateTime? _lastSyncTime;
  String? _serverUrl;
  String? _errorMessage;

  ConnectionStatus get status => _status;
  bool get isOnline => _isOnline;
  DateTime? get lastSyncTime => _lastSyncTime;
  String? get serverUrl => _serverUrl;
  String? get errorMessage => _errorMessage;

  ConnectionProvider() {
    _serverUrl = ApiConfig.baseUrl;
    _startHealthCheck();
  }

  void _startHealthCheck() {
    // Check immediately
    checkConnection();
    
    // Check every 10 seconds
    _healthCheckTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      checkConnection();
    });
  }

  Future<void> checkConnection() async {
    if (_status == ConnectionStatus.syncing) return;
    
    _status = ConnectionStatus.connecting;
    notifyListeners();

    try {
      // Try to reach health endpoint
      final response = await _apiService.healthCheck().timeout(
        const Duration(seconds: 5),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final dbStatus = data['database'] as String?;
        
        _isOnline = true;
        _status = dbStatus == 'connected' 
            ? ConnectionStatus.connected 
            : ConnectionStatus.disconnected;
        _lastSyncTime = DateTime.now();
        _errorMessage = null;
      } else {
        _isOnline = false;
        _status = ConnectionStatus.disconnected;
        _errorMessage = 'Server returned error';
      }
    } catch (e) {
      _isOnline = false;
      _status = ConnectionStatus.disconnected;
      _errorMessage = _getErrorMessage(e);
    }

    notifyListeners();
  }

  Future<void> syncNow() async {
    if (_status == ConnectionStatus.syncing) return;
    
    _status = ConnectionStatus.syncing;
    notifyListeners();

    try {
      await checkConnection();
      _lastSyncTime = DateTime.now();
    } catch (e) {
      _status = ConnectionStatus.disconnected;
      _errorMessage = _getErrorMessage(e);
    }

    notifyListeners();
  }

  String _getErrorMessage(dynamic error) {
    if (error.toString().contains('timeout')) {
      return 'Connection timeout';
    } else if (error.toString().contains('Failed host lookup')) {
      return 'Cannot reach server';
    } else if (error.toString().contains('SocketException')) {
      return 'Network error';
    } else {
      return 'Connection failed';
    }
  }

  @override
  void dispose() {
    _healthCheckTimer?.cancel();
    super.dispose();
  }
}

