import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get apiBaseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000';
  static String get apiKey => dotenv.env['API_KEY'] ?? '';
  static String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  static Future<void> load() async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (e) {
      print('Warning: Could not load .env file: $e');
      // Continue with defaults
    }
  }
}
