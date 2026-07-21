import 'package:dio/dio.dart';

class ApiService {
  late Dio _dio;
  static const String baseUrl = 'http://127.0.0.1:3000';

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        contentType: 'application/json',
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          return handler.next(e);
        },
      ),
    );
  }

  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  // Auth endpoints
  Future<Map<String, dynamic>> getMe() async {
    try {
      final response = await _dio.get('/auth/me');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // Entertainment endpoints
  Future<List<dynamic>> getAllEntertainment() async {
    try {
      final response = await _dio.get('/entertainment');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getEntertainmentById(String id) async {
    try {
      final response = await _dio.get('/entertainment/$id');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createEntertainment(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/entertainment', data: data);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateEntertainment(String id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.patch('/entertainment/$id', data: data);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteEntertainment(String id) async {
    try {
      await _dio.delete('/entertainment/$id');
    } catch (e) {
      rethrow;
    }
  }

  // Lists endpoints
  Future<List<dynamic>> getAllLists() async {
    try {
      final response = await _dio.get('/lists');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createList(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/lists', data: data);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // Reviews endpoints
  Future<List<dynamic>> getAllReviews() async {
    try {
      final response = await _dio.get('/reviews');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createReview(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/reviews', data: data);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // Statistics endpoints
  Future<Map<String, dynamic>> getStatistics() async {
    try {
      final response = await _dio.get('/statistics');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // Users endpoints
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final response = await _dio.get('/users/profile');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}
