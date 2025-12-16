import 'package:dio/dio.dart';
import '../config/api_config.dart';

class ApiService {
  late Dio _dio;
  String? _token;

  ApiService() {
    _initDio();
  }
  
  void _initDio() {
    final baseUrl = ApiConfig.baseUrl;
    print('🌐 API Service initializing with baseUrl: $baseUrl');
    
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      headers: ApiConfig.getHeaders(null),
    ));

    // Add interceptors for logging (only in debug)
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
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
  Future<Response> register({
    required String name,
    required String email,
    required String password,
    String? phoneNumber,
    String role = 'employee',
  }) async {
    return await _dio.post('/auth/register', data: {
      'name': name,
      'email': email,
      'password': password,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      'role': role,
    });
  }

  Future<Response> login(String email, String password) async {
    return await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
  }

  Future<Response> getCurrentUser() async {
    return await _dio.get('/auth/me');
  }

  Future<Response> logout() async {
    return await _dio.post('/auth/logout');
  }

  // Attendance
  Future<Response> checkIn({
    String? userId,
    double? latitude,
    double? longitude,
    String? address,
  }) async {
    return await _dio.post('/attendance/checkin', data: {
      if (userId != null) 'userId': userId,
      if (latitude != null && longitude != null)
        'location': {
          'latitude': latitude,
          'longitude': longitude,
          if (address != null) 'address': address,
        },
    });
  }

  Future<Response> checkOut({
    String? attendanceId,
    String? userId,
    double? latitude,
    double? longitude,
    String? address,
  }) async {
    if (attendanceId != null) {
      return await _dio.put('/attendance/$attendanceId/checkout', data: {
        if (latitude != null && longitude != null)
          'location': {
            'latitude': latitude,
            'longitude': longitude,
            if (address != null) 'address': address,
          },
      });
    } else {
      return await _dio.post('/attendance/checkout', data: {
        if (userId != null) 'userId': userId,
        if (latitude != null && longitude != null)
          'location': {
            'latitude': latitude,
            'longitude': longitude,
            if (address != null) 'address': address,
          },
      });
    }
  }

  Future<Response> getAttendanceHistory({
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int limit = 50,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    
    if (userId != null) queryParams['userId'] = userId;
    if (startDate != null) queryParams['startDate'] = startDate.toIso8601String();
    if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();

    return await _dio.get('/attendance', queryParameters: queryParams);
  }

  Future<Response> getTodayAttendance({String? userId}) async {
    final queryParams = <String, dynamic>{};
    if (userId != null) queryParams['userId'] = userId;
    return await _dio.get('/attendance/today', queryParameters: queryParams);
  }

  Future<Response> getAttendanceStats({
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final queryParams = <String, dynamic>{};
    if (userId != null) queryParams['userId'] = userId;
    if (startDate != null) queryParams['startDate'] = startDate.toIso8601String();
    if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();
    
    return await _dio.get('/attendance/stats', queryParameters: queryParams);
  }

  // Error handling helper
  String getErrorMessage(DioException error) {
    if (error.response != null) {
      return error.response?.data['error'] ?? 
             error.response?.data['message'] ?? 
             'An error occurred';
    } else if (error.type == DioExceptionType.connectionTimeout) {
      return 'Connection timeout. Please check your internet connection.';
    } else if (error.type == DioExceptionType.receiveTimeout) {
      return 'Request timeout. Please try again.';
    } else {
      return error.message ?? 'An unexpected error occurred';
    }
  }
}

