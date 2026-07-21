class AppConstants {
  // Groq API — ключ хранится в Firebase Remote Config (groq_api_key)
  static const String groqApiUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const String groqModel = 'llama-3.3-70b-versatile';

  // Remote Config parameter names
  static const String rcGroqApiKey = 'groq_api_key';

  // OCR
  static const double ocrConfidenceThreshold = 0.7;

  // Supported languages
  static const Map<String, String> supportedLanguages = {
    'ru': 'Русский',
    'uk': 'Українська',
    'en': 'English',
    'de': 'Deutsch',
    'it': 'Italiano',
    'pl': 'Polski',
  };

  // Cities
  static const Map<String, String> popularCities = {
    'berlin': 'Berlin',
    'munich': 'München',
    'hamburg': 'Hamburg',
    'cologne': 'Köln',
    'vienna': 'Wien',
    'amsterdam': 'Amsterdam',
    'barcelona': 'Barcelona',
    'madrid': 'Madrid',
    'paris': 'Paris',
    'rome': 'Roma',
    'tallinn': 'Tallinn',
  };
}
