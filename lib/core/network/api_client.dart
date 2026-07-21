import 'dart:io';
import 'dart:convert';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import '../constants/app_constants.dart';

class ApiClient {
  late final Dio _dio;
  String? _cachedUserId;
  String? _cachedApiKey;

  ApiClient() {
    _dio = Dio(BaseOptions(
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

  /// Get Groq API key from Firebase Remote Config
  Future<String> _getApiKey() async {
    if (_cachedApiKey != null && _cachedApiKey!.isNotEmpty) {
      return _cachedApiKey!;
    }

    try {
      final remoteConfig = FirebaseRemoteConfig.instance;
      await remoteConfig.fetchAndActivate();
      _cachedApiKey = remoteConfig.getString(AppConstants.rcGroqApiKey);
    } catch (e) {
      print('[API] Failed to fetch Remote Config: $e');
    }

    if (_cachedApiKey == null || _cachedApiKey!.isEmpty) {
      throw Exception('Groq API key not configured. Add groq_api_key to Firebase Remote Config.');
    }

    return _cachedApiKey!;
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

  /// Get system prompt for rental analysis
  String _getSystemPrompt(String lang) {
    const prompts = {
      'ru': 'Ты — эксперт по аренде жилья в Европе. Проанализируй объявление об аренде и дай:\n'
          '1. Оценка риска (1-10, где 10 — идеально)\n'
          '2. Реальную цену со всеми комиссиями\n'
          '3. Скрытые платежи и риски\n'
          '4. Рекомендации по документам\n'
          '5. Краткий итог (3-5 предложений)\n'
          'Отвечай на русском языке. Будь конкретным и практичен.',
      'en': 'You are a European rental housing expert. Analyze this rental listing and provide:\n'
          '1. Risk score (1-10, where 10 is perfect)\n'
          '2. Real price with all fees\n'
          '3. Hidden payments and risks\n'
          '4. Document recommendations\n'
          '5. Brief summary (3-5 sentences)\n'
          'Answer in English. Be specific and practical.',
      'de': 'Du bist ein Experte für Mietwohnungen in Europa. Analysiere diese Anzeige und gib:\n'
          '1. Risikobewertung (1-10, wobei 10 perfekt ist)\n'
          '2. Realen Preis mit allen Gebühren\n'
          '3. Versteckte Zahlungen und Risiken\n'
          '4. Dokumentenempfehlungen\n'
          '5. Kurze Zusammenfassung (3-5 Sätze)\n'
          'Antworte auf Deutsch. Sei konkret und praktisch.',
    };
    return prompts[lang] ?? prompts['ru']!;
  }

  /// Call Groq API directly
  Future<String> _callGroq(String prompt) async {
    final apiKey = await _getApiKey();

    final response = await _dio.post(
      AppConstants.groqApiUrl,
      options: Options(headers: {
        'Authorization': 'Bearer $apiKey',
      }),
      data: {
        'model': AppConstants.groqModel,
        'messages': [{'role': 'user', 'content': prompt}],
      },
    );

    final data = response.data;
    return data['choices']?[0]?['message']?['content'] ?? 'No analysis generated.';
  }

  /// Analyze a rental listing text
  Future<AnalysisResponse> analyzeListing({
    required String text,
    String? userId,
    required String lang,
  }) async {
    final uid = userId ?? await getUserId();
    final systemPrompt = _getSystemPrompt(lang);
    final fullPrompt = '$systemPrompt\n\nListing text:\n$text';

    final analysis = await _callGroq(fullPrompt);

    return AnalysisResponse(
      id: 'analysis_${DateTime.now().millisecondsSinceEpoch}',
      text: text,
      analysis: analysis,
      city: _extractCity(analysis),
      price: _extractPrice(analysis),
      score: _extractScore(analysis),
      createdAt: DateTime.now(),
    );
  }

  /// Analyze a photo (Base64)
  Future<AnalysisResponse> analyzePhoto({
    required String imageBase64,
    String? userId,
    required String lang,
  }) async {
    final uid = userId ?? await getUserId();
    final apiKey = await _getApiKey();
    final systemPrompt = _getSystemPrompt(lang);

    final response = await _dio.post(
      AppConstants.groqApiUrl,
      options: Options(headers: {
        'Authorization': 'Bearer $apiKey',
      }),
      data: {
        'model': AppConstants.groqModel,
        'messages': [
          {'role': 'system', 'content': systemPrompt},
          {
            'role': 'user',
            'content': [
              {'type': 'text', 'text': 'Analyze this rental listing photo:'},
              {'type': 'image_url', 'image_url': {'url': 'data:image/jpeg;base64,$imageBase64'}},
            ],
          },
        ],
      },
    );

    final data = response.data;
    final analysis = data['choices']?[0]?['message']?['content'] ?? 'No analysis generated.';

    return AnalysisResponse(
      id: 'photo_${DateTime.now().millisecondsSinceEpoch}',
      text: '(photo)',
      analysis: analysis,
      city: _extractCity(analysis),
      price: _extractPrice(analysis),
      score: _extractScore(analysis),
      createdAt: DateTime.now(),
    );
  }

  String? _extractCity(String text) {
    final match = RegExp(r'🏙.*?([A-ZА-Яа-яёЁ][a-zа-яёЁ]+)').firstMatch(text);
    return match?.group(1);
  }

  double? _extractPrice(String text) {
    final match = RegExp(r'(\d[\d\s]*)\s*EUR').firstMatch(text);
    if (match != null) {
      return double.tryParse(match.group(1)!.replaceAll(' ', ''));
    }
    return null;
  }

  int? _extractScore(String text) {
    final match = RegExp(r'(?:Риск|Score|Оценка|Risk)[^\d]*(\d+)').firstMatch(text);
    return match != null ? int.tryParse(match.group(1)!) : null;
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
