// lib/app/routes.dart
class AppRoutes {
  // Auth Routes
  static const String login = '/login';
  static const String signup = '/signup';

  // Main Routes
  static const String home = '/home';
  static const String root = '/';

  // Feature Routes
  static const String exams = '/exams';
  static const String examCreate = '/exam/create';
  static const String exercises = '/exercises';
  static const String flashcards = '/flashcards';
  static const String documents = '/documents';

  // Tools Routes
  static const String simulators = '/simulators';
  static const String freeBodyDiagram = '/free-body-diagram';
  static const String conversionCalculator = '/conversion-calculator';

  // Error Route
  static const String error = '/error';

  // Método helper para validar rutas
  static bool isValidRoute(String route) {
    return [
      login,
      signup,
      home,
      root,
      exams,
      examCreate,
      exercises,
      flashcards,
      documents,
      simulators,
      freeBodyDiagram,
      conversionCalculator,
      error,
    ].contains(route);
  }
}
