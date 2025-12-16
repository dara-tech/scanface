# Flutter ↔ Backend Integration Guide

## 🔄 Architecture Overview

```
┌─────────────────────┐
│   Flutter App       │
│                     │
│  ┌───────────────┐  │
│  │  REST API     │  │───HTTP───┐
│  │  (Dio)        │  │          │
│  └───────────────┘  │          │
│                     │          │
│  ┌───────────────┐  │          │
│  │  WebSocket    │  │───WS───┐ │
│  │  (Socket.io)  │  │        │ │
│  └───────────────┘  │        │ │
└─────────────────────┘        │ │
                                │ │
                    ┌───────────┴─┴──────────┐
                    │   Express.js Backend   │
                    │                        │
                    │  ┌──────────────────┐ │
                    │  │  REST Endpoints  │ │
                    │  └──────────────────┘ │
                    │  ┌──────────────────┐ │
                    │  │  Socket.io       │ │
                    │  └──────────────────┘ │
                    └───────────┬────────────┘
                                │
                    ┌───────────▼────────────┐
                    │      MongoDB           │
                    └────────────────────────┘
```

---

## 📦 Flutter Dependencies

Already added to `pubspec.yaml`:
```yaml
dependencies:
  dio: ^5.4.0                    # HTTP client
  socket_io_client: ^2.0.3+1    # WebSocket
  connectivity_plus: ^5.0.0      # Network status
```

Run:
```bash
flutter pub get
```

---

## 🔧 Configuration

### Environment Configuration
Create `lib/config/api_config.dart`:

```dart
class ApiConfig {
  // Backend URL - change for production
  static const String baseUrl = 'http://localhost:3000/api';
  static const String socketUrl = 'http://localhost:3000';
  
  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Headers
  static Map<String, String> getHeaders(String? token) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}
```

---

## 🌐 REST API Service

### Create `lib/services/api_service.dart`

```dart
import 'package:dio/dio.dart';
import '../config/api_config.dart';

class ApiService {
  late Dio _dio;
  String? _token;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      headers: ApiConfig.getHeaders(null),
    ));

    // Add interceptors
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
  }

  // Set authentication token
  void setToken(String token) {
    _token = token;
    _dio.options.headers = ApiConfig.getHeaders(token);
  }

  void clearToken() {
    _token = null;
    _dio.options.headers = ApiConfig.getHeaders(null);
  }

  // Authentication
  Future<Response> login(String email, String password) async {
    return await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
  }

  Future<Response> register(Map<String, dynamic> userData) async {
    return await _dio.post('/auth/register', data: userData);
  }

  // Users
  Future<Response> getUsers() async {
    return await _dio.get('/users');
  }

  Future<Response> createUser(Map<String, dynamic> userData) async {
    return await _dio.post('/users', data: userData);
  }

  // Attendance
  Future<Response> checkIn({
    required String userId,
    double? latitude,
    double? longitude,
  }) async {
    return await _dio.post('/attendance/checkin', data: {
      'userId': userId,
      if (latitude != null && longitude != null)
        'location': {
          'latitude': latitude,
          'longitude': longitude,
        },
    });
  }

  Future<Response> checkOut({
    required String attendanceId,
    double? latitude,
    double? longitude,
  }) async {
    return await _dio.put('/attendance/$attendanceId/checkout', data: {
      if (latitude != null && longitude != null)
        'location': {
          'latitude': latitude,
          'longitude': longitude,
        },
    });
  }

  Future<Response> getAttendanceHistory({
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final queryParams = <String, dynamic>{};
    if (userId != null) queryParams['userId'] = userId;
    if (startDate != null) queryParams['startDate'] = startDate.toIso8601String();
    if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();

    return await _dio.get('/attendance', queryParameters: queryParams);
  }

  // Reports
  Future<Response> getDailyReport(DateTime date) async {
    return await _dio.get('/reports/daily', queryParameters: {
      'date': date.toIso8601String(),
    });
  }

  Future<Response> exportReport({
    required String format, // 'csv' or 'pdf'
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await _dio.get('/reports/export/$format', queryParameters: {
      if (startDate != null) 'startDate': startDate.toIso8601String(),
      if (endDate != null) 'endDate': endDate.toIso8601String(),
    });
  }
}
```

---

## 🔌 WebSocket Service

### Create `lib/services/socket_service.dart`

```dart
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:async';

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
  void connect(String serverUrl, String token, String userId, String organizationId) {
    _token = token;
    _userId = userId;
    _organizationId = organizationId;

    _socket = IO.io(
      serverUrl,
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
      
      // Authenticate
      authenticate();
    });

    _socket!.onDisconnect((_) {
      print('❌ WebSocket disconnected');
      _connectionStreamController.add(false);
    });

    _socket!.onError((error) {
      print('❌ WebSocket error: $error');
    });

    // Authentication
    _socket!.on('authenticated', (data) {
      print('✅ Authenticated: $data');
    });

    // Real-time attendance events
    _socket!.on('attendance:new', (data) {
      print('📥 New attendance: $data');
      _attendanceStreamController.add(data);
    });

    _socket!.on('attendance:update', (data) {
      print('📥 Attendance updated: $data');
      _attendanceStreamController.add(data);
    });

    // Notifications
    _socket!.on('notification', (data) {
      print('🔔 Notification: $data');
      _notificationStreamController.add(data);
    });

    // Sync status
    _socket!.on('sync:status', (data) {
      print('🔄 Sync status: $data');
    });
  }

  // Authenticate with server
  void authenticate() {
    if (_socket == null || _token == null) return;
    
    _socket!.emit('authenticate', {
      'token': _token,
      'userId': _userId,
      'organizationId': _organizationId,
    });
  }

  // Emit check-in event
  void emitCheckIn({
    required String userId,
    double? latitude,
    double? longitude,
  }) {
    if (_socket == null) return;

    _socket!.emit('checkin', {
      'userId': userId,
      'organizationId': _organizationId,
      'location': latitude != null && longitude != null
          ? {'latitude': latitude, 'longitude': longitude}
          : null,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // Emit check-out event
  void emitCheckOut({
    required String attendanceId,
    double? latitude,
    double? longitude,
  }) {
    if (_socket == null) return;

    _socket!.emit('checkout', {
      'attendanceId': attendanceId,
      'location': latitude != null && longitude != null
          ? {'latitude': latitude, 'longitude': longitude}
          : null,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // Subscribe to organization updates
  void subscribe(String type) {
    if (_socket == null) return;
    
    _socket!.emit('subscribe', {
      'type': type, // 'attendance', 'users', 'reports'
      'organizationId': _organizationId,
    });
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
```

---

## 🔄 Sync Service

### Create `lib/services/sync_service.dart`

```dart
import 'dart:async';
import '../services/api_service.dart';
import '../services/socket_service.dart';
import '../services/database_service.dart';

class SyncService {
  final ApiService _apiService = ApiService();
  final SocketService _socketService = SocketService();
  final DatabaseService _dbService = DatabaseService.instance;
  
  bool _isSyncing = false;
  Timer? _syncTimer;

  // Start automatic sync (every 5 minutes)
  void startAutoSync() {
    _syncTimer = Timer.periodic(Duration(minutes: 5), (_) {
      sync();
    });
  }

  void stopAutoSync() {
    _syncTimer?.cancel();
  }

  // Sync local data with server
  Future<void> sync() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      // 1. Push local changes
      await _pushLocalChanges();

      // 2. Pull server changes
      await _pullServerChanges();

      print('✅ Sync completed');
    } catch (e) {
      print('❌ Sync error: $e');
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _pushLocalChanges() async {
    // Get pending sync items from local DB
    // Send to server
    // Mark as synced
  }

  Future<void> _pullServerChanges() async {
    // Get latest data from server
    // Update local database
    // Notify UI
  }
}
```

---

## 📱 Usage in Flutter App

### Update Auth Provider

```dart
// lib/providers/auth_provider.dart
import '../services/api_service.dart';
import '../services/socket_service.dart';
import '../config/api_config.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final SocketService _socketService = SocketService();
  
  User? _currentUser;
  String? _token;

  Future<void> login(String email, String password) async {
    try {
      final response = await _apiService.login(email, password);
      _token = response.data['token'];
      _currentUser = User.fromJson(response.data['user']);
      
      // Set token for API calls
      _apiService.setToken(_token!);
      
      // Connect WebSocket
      _socketService.connect(
        ApiConfig.socketUrl,
        _token!,
        _currentUser!.id,
        _currentUser!.organizationId,
      );
      
      notifyListeners();
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  void logout() {
    _socketService.disconnect();
    _apiService.clearToken();
    _token = null;
    _currentUser = null;
    notifyListeners();
  }
}
```

### Update Check-in Screen

```dart
// lib/screens/user/check_in_screen.dart
class _CheckInScreenState extends State<CheckInScreen> {
  final SocketService _socketService = SocketService();
  final ApiService _apiService = ApiService();
  
  @override
  void initState() {
    super.initState();
    _setupSocketListeners();
  }

  void _setupSocketListeners() {
    // Listen for real-time updates
    _socketService.attendanceStream.listen((data) {
      // Update UI with real-time data
      setState(() {
        // Handle attendance updates
      });
    });
  }

  Future<void> _checkIn() async {
    try {
      // 1. Call REST API
      final response = await _apiService.checkIn(
        userId: currentUser.id,
        latitude: currentLocation?.latitude,
        longitude: currentLocation?.longitude,
      );

      // 2. Emit WebSocket event (optional, for real-time)
      _socketService.emitCheckIn(
        userId: currentUser.id,
        latitude: currentLocation?.latitude,
        longitude: currentLocation?.longitude,
      );

      // 3. Show success
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Checked in successfully')),
      );
    } catch (e) {
      // Handle error
    }
  }
}
```

---

## 🧪 Testing

### Test REST API
```dart
void testApiConnection() async {
  final apiService = ApiService();
  try {
    final response = await apiService.login('test@example.com', 'password');
    print('✅ Login successful: ${response.data}');
  } catch (e) {
    print('❌ Error: $e');
  }
}
```

### Test WebSocket
```dart
void testWebSocket() {
  final socketService = SocketService();
  socketService.connect('http://localhost:3000', 'token', 'userId', 'orgId');
  
  socketService.attendanceStream.listen((data) {
    print('Received: $data');
  });
}
```

---

## 🔒 Security Considerations

1. **Store tokens securely**
   ```dart
   import 'package:flutter_secure_storage/flutter_secure_storage.dart';
   
   final storage = FlutterSecureStorage();
   await storage.write(key: 'auth_token', value: token);
   ```

2. **Validate SSL certificates in production**
   ```dart
   _dio.httpClientAdapter = IOHttpClientAdapter(
     createHttpClient: () {
       final client = HttpClient();
       client.badCertificateCallback = (cert, host, port) => false; // Only in dev
       return client;
     },
   );
   ```

3. **Handle network errors gracefully**
   ```dart
   try {
     await apiService.checkIn(...);
   } on DioException catch (e) {
     if (e.type == DioExceptionType.connectionTimeout) {
       // Handle timeout
     } else if (e.response?.statusCode == 401) {
       // Handle unauthorized
     }
   }
   ```

---

## ✅ Integration Checklist

- [ ] Backend server running
- [ ] MongoDB connected
- [ ] Socket.io server active
- [ ] Flutter dependencies installed
- [ ] API service created
- [ ] Socket service created
- [ ] Authentication working
- [ ] Real-time updates working
- [ ] Error handling implemented
- [ ] Offline support (optional)

---

**Next**: Start implementing the backend endpoints and test the integration!

