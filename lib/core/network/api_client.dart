import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import '../constants/app_constants.dart';

class ApiClient {
  late final Dio _dio;
  String? _cachedUserId;

  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.backendFunctionUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(minutes: 3),
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => print('[API] $obj'),
    ));
  }

  /// Get unique device-specific user ID
  Future<String> getUserId() async {
    if (_cachedUserId != null) return _cachedUserId!;

    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        _cachedUserId = 'android_${androidInfo.id}';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        _cachedUserId = 'ios_${iosInfo.identifierForVendor}';
      } else {
        _cachedUserId = 'web_${DateTime.now().millisecondsSinceEpoch}';
      }
    } catch (e) {
      _cachedUserId = 'unknown_${DateTime.now().millisecondsSinceEpoch}';
    }

    return _cachedUserId!;
  }

  /// Send listing text for analysis
  Future<AnalysisResponse> analyzeListing({
    required String text,
    String? userId,
    required String lang,
  }) async {
    final uid = userId ?? await getUserId();
    final response = await _dio.post('/botProxy', data: {
      'text': text,
      'user_id': uid,
      'lang': lang,
    });
    return AnalysisResponse.fromJson(response.data);
  }

  /// Send photo (Base64) for analysis
  Future<AnalysisResponse> analyzePhoto({
    required String imageBase64,
    String? userId,
    required String lang,
  }) async {
    final uid = userId ?? await getUserId();
    final response = await _dio.post('/analyzePhoto', data: {
      'image': imageBase64,
      'user_id': uid,
      'lang': lang,
    });
    return AnalysisResponse.fromJson(response.data);
  }

  /// Link Google account to user ID
  Future<void> linkGoogleAccount({
    required String googleUserId,
    required String email,
  }) async {
    await _dio.post('/linkAccount', data: {
      'google_user_id': googleUserId,
      'email': email,
    });
  }
}

class AnalysisResponse {
  final String id;
  final String text;
  final String analysis;
  final String? city;
  final double? price;
  final int? score;
  final DateTime createdAt;

  AnalysisResponse({
    required this.id,
    required this.text,
    required this.analysis,
    this.city,
    this.price,
    this.score,
    required this.createdAt,
  });

  factory AnalysisResponse.fromJson(Map<String, dynamic> json) {
    return AnalysisResponse(
      id: json['id'] ?? '',
      text: json['text'] ?? '',
      analysis: json['analysis'] ?? '',
      city: json['city'],
      price: json['price']?.toDouble(),
      score: json['score'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'analysis': analysis,
    'city': city,
    'price': price,
    'score': score,
    'created_at': createdAt.toIso8601String(),
  };
}
