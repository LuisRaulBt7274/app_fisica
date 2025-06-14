class AppConstants {
  // Supabase Configuration
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

  // Gemini API Configuration
  static const String geminiApiKey = 'YOUR_GEMINI_API_KEY';
  static const String geminiBaseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';

  // Google OAuth Configuration
  static const String googleClientId = 'YOUR_GOOGLE_CLIENT_ID';

  // App Configuration
  static const String appName = 'StudyAI';
  static const String appVersion = '1.0.0';

  // Difficulty Levels
  static const List<String> difficultyLevels = [
    'Básico',
    'Intermedio',
    'Avanzado',
    'Experto',
  ];

  // Subject Categories
  static const List<String> subjects = [
    'Matemáticas',
    'Física',
    'Química',
    'Biología',
    'Historia',
    'Literatura',
    'Geografía',
    'Inglés',
    'Filosofía',
    'Economía',
  ];

  // File Upload Limits
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedFileTypes = [
    'pdf',
    'doc',
    'docx',
    'txt',
    'jpg',
    'jpeg',
    'png',
  ];

  // URLs for simulators
  static const Map<String, String> simulatorUrls = {
    'PhET Physics':
        'https://phet.colorado.edu/sims/html/forces-and-motion-basics/latest/forces-and-motion-basics_en.html',
    'Chemistry Lab':
        'https://phet.colorado.edu/sims/html/ph-scale/latest/ph-scale_en.html',
    'Math Graphing': 'https://www.desmos.com/calculator',
    'Biology Cell':
        'https://phet.colorado.edu/sims/html/gene-expression-essentials/latest/gene-expression-essentials_en.html',
  };
}
