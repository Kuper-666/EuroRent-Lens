class AppConstants {
  // Telegram Bot API — ТОКЕН ХРАНИТСЯ ТОЛЬКО НА СЕРВЕРЕ (Firebase Cloud Function)
  // В приложении ТОЛЬКО URL backend-функции
  static const String backendFunctionUrl =
      'https://europe-west1-eurorent-lens.cloudfunctions.net/botProxy';

  // Supabase (для связи Google ID ↔ Telegram user ID)
  static const String supabaseUrl = 'https://bfpvanfudhtgqdhxpkyr.supabase.co';
  // anon key хранится в firebase_remote_config или .env, НЕ в коде

  // Groq API — ТОКЕН НЕ В КОДЕ, через backend
  static const String groqModel = 'llama-3.3-70b-versatile';

  // OCR
  static const double ocrConfidenceThreshold = 0.7;

  // Polling interval for bot responses
  static const Duration pollingInterval = Duration(seconds: 5);
  static const Duration maxWaitForResponse = Duration(minutes: 2);

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
