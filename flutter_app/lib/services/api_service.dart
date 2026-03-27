import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static final ApiService _instance = ApiService._();
  factory ApiService() => _instance;

  late final Dio _dio;

  ApiService._() {
    const baseUrl = 'https://drift-diary-api.onrender.com';

    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('access_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          // Token expired — could navigate to login
        }
        handler.next(error);
      },
    ));
  }

  Dio get dio => _dio;

  // ─── Auth ───
  Future<String> devLogin({String testUserId = 'test_user_1'}) async {
    final resp = await _dio.post('/api/auth/dev-login', data: {
      'test_user_id': testUserId,
    });
    final token = resp.data['access_token'] as String;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', token);
    return token;
  }

  // ─── Diaries ───
  Future<Map<String, dynamic>> getDiaries({int page = 1, int pageSize = 20}) async {
    final resp = await _dio.get('/api/diaries', queryParameters: {
      'page': page,
      'page_size': pageSize,
    });
    return resp.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createDiary({
    required String content,
    required String moodTag,
    List<String>? topicTags,
    String type = 'private',
  }) async {
    final resp = await _dio.post('/api/diaries', data: {
      'content': content,
      'mood_tag': moodTag,
      'topic_tags': topicTags ?? [],
      'type': type,
    });
    return resp.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getDiary(int id) async {
    final resp = await _dio.get('/api/diaries/$id');
    return resp.data as Map<String, dynamic>;
  }

  Future<void> deleteDiary(int id) async {
    await _dio.delete('/api/diaries/$id');
  }

  // ─── AI ───
  Future<Map<String, dynamic>> analyzeEmotion(String content) async {
    final resp = await _dio.post('/api/ai/analyze', data: {
      'content': content,
    });
    return resp.data as Map<String, dynamic>;
  }

  // ─── Drift ───
  Future<Map<String, dynamic>> pickBottle() async {
    final resp = await _dio.post('/api/drift/pick');
    return resp.data as Map<String, dynamic>;
  }

  Future<void> respondBottle(int bottleId, String content) async {
    await _dio.post('/api/drift/$bottleId/respond', data: {
      'content': content,
    });
  }

  Future<List<dynamic>> getMyBottles() async {
    final resp = await _dio.get('/api/drift/mine');
    return resp.data as List<dynamic>;
  }

  Future<Map<String, dynamic>> getBottleJourney(int bottleId) async {
    final resp = await _dio.get('/api/drift/$bottleId/journey');
    return resp.data as Map<String, dynamic>;
  }
}
