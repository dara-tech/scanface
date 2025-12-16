import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:async';
import '../config/api_config.dart';

class SocketService {
  IO.Socket? _socket;
  String? _token;
  String? _userId;
  String? _organizationId;

  // Stream controllers for real-time updates
  final _attendanceStreamController = StreamController<Map<String, dynamic>>.broadcast();
  final _notificationStreamController = StreamController<Map<String, dynamic>>.broadcast();
  final _connectionStreamController = StreamController<bool>.broadcast();

  // Getters for streams
  Stream<Map<String, dynamic>> get attendanceStream => _attendanceStreamController.stream;
  Stream<Map<String, dynamic>> get notificationStream => _notificationStreamController.stream;
  Stream<bool> get connectionStream => _connectionStreamController.stream;

  bool get isConnected => _socket?.connected ?? false;

  // Connect to WebSocket server
  void connect(String serverUrl, String token, String userId, {String? organizationId}) {
    _token = token;
    _userId = userId;
    _organizationId = organizationId;

    // Use ApiConfig for consistent URL
    final url = serverUrl.isEmpty ? ApiConfig.socketUrl : serverUrl;
    print('🔌 Connecting to WebSocket: $url');

    _socket = IO.io(
      url,
      IO.OptionBuilder()
        .setTransports(['websocket'])
        .setExtraHeaders({'Authorization': 'Bearer $token'})
        .enableAutoConnect()
        .build(),
    );

    _setupEventHandlers();
  }

  void _setupEventHandlers() {
    if (_socket == null) return;

    // Connection events
    _socket!.onConnect((_) {
      print('✅ WebSocket connected');
      _connectionStreamController.add(true);
    });

    _socket!.onDisconnect((_) {
      print('❌ WebSocket disconnected');
      _connectionStreamController.add(false);
    });

    _socket!.onError((error) {
      print('❌ WebSocket error: $error');
      _connectionStreamController.add(false);
    });

    // Authentication response
    _socket!.on('authenticated', (data) {
      print('✅ Authenticated: $data');
    });

    // Real-time attendance events
    _socket!.on('attendance:new', (data) {
      print('📥 New attendance: $data');
      _attendanceStreamController.add(Map<String, dynamic>.from(data));
    });

    _socket!.on('attendance:update', (data) {
      print('📥 Attendance updated: $data');
      _attendanceStreamController.add(Map<String, dynamic>.from(data));
    });

    // Check-in/Check-out responses
    _socket!.on('checkin:success', (data) {
      print('✅ Check-in success: $data');
      _attendanceStreamController.add({
        'type': 'checkin_success',
        'data': data,
      });
    });

    _socket!.on('checkin:error', (data) {
      print('❌ Check-in error: $data');
      _attendanceStreamController.add({
        'type': 'checkin_error',
        'data': data,
      });
    });

    _socket!.on('checkout:success', (data) {
      print('✅ Check-out success: $data');
      _attendanceStreamController.add({
        'type': 'checkout_success',
        'data': data,
      });
    });

    _socket!.on('checkout:error', (data) {
      print('❌ Check-out error: $data');
      _attendanceStreamController.add({
        'type': 'checkout_error',
        'data': data,
      });
    });

    // Notifications
    _socket!.on('notification', (data) {
      print('🔔 Notification: $data');
      _notificationStreamController.add(Map<String, dynamic>.from(data));
    });

    // Sync status
    _socket!.on('sync:status', (data) {
      print('🔄 Sync status: $data');
    });

    // Ping/Pong
    _socket!.on('pong', (data) {
      print('📥 Pong: $data');
    });
  }

  // Emit check-in event
  void emitCheckIn({
    double? latitude,
    double? longitude,
    String? address,
  }) {
    if (_socket == null || !_socket!.connected) {
      print('⚠️ Socket not connected');
      return;
    }

    _socket!.emit('checkin', {
      if (latitude != null && longitude != null)
        'location': {
          'latitude': latitude,
          'longitude': longitude,
          if (address != null) 'address': address,
        },
    });
  }

  // Emit check-out event
  void emitCheckOut({
    String? attendanceId,
    double? latitude,
    double? longitude,
    String? address,
  }) {
    if (_socket == null || !_socket!.connected) {
      print('⚠️ Socket not connected');
      return;
    }

    _socket!.emit('checkout', {
      if (attendanceId != null) 'attendanceId': attendanceId,
      if (latitude != null && longitude != null)
        'location': {
          'latitude': latitude,
          'longitude': longitude,
          if (address != null) 'address': address,
        },
    });
  }

  // Ping server
  void ping() {
    if (_socket == null || !_socket!.connected) return;
    _socket!.emit('ping');
  }

  // Disconnect
  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  // Cleanup
  void dispose() {
    disconnect();
    _attendanceStreamController.close();
    _notificationStreamController.close();
    _connectionStreamController.close();
  }
}

