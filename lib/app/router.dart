import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../auth/login_screen.dart';
import '../auth/signup_screen.dart';
import '../home/home_screen.dart';
import '../exam/exam_screen.dart';
import '../exam/exam_form.dart';
import '../exercise/exercise_screen.dart';
import '../flashcards/flashcards_screen.dart';
import '../documents/document_upload_screen.dart';
import '../tools/simulators_screen.dart';
import '../tools/free_body_diagram_screen.dart';
import '../tools/conversion_calculator_screen.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    redirect: (context, state) {
      final session = Supabase.instance.client.auth.currentSession;
      final isLoggedIn = session != null;

      // Lista de rutas que no requieren autenticación
      final publicRoutes = ['/login', '/signup'];
      final currentPath =
          state.uri.path; // ← CAMBIO AQUÍ: usar uri.path en lugar de location
      final isPublicRoute = publicRoutes.contains(currentPath);

      // Si no está autenticado y trata de acceder a una ruta protegida
      if (!isLoggedIn && !isPublicRoute) {
        return '/login';
      }

      // Si está autenticado y trata de acceder a una ruta pública, redirigir a /home
      if (isLoggedIn && isPublicRoute) {
        return '/home';
      }

      // No redirigir
      return null;
    },
    routes: [
      // Auth Routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),

      // Main App Routes
      GoRoute(path: '/', redirect: (context, state) => '/home'),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),

      // Feature Routes
      GoRoute(
        path: '/exams',
        name: 'exams',
        builder: (context, state) => const ExamScreen(),
      ),
      GoRoute(
        path: '/exam/create',
        name: 'exam-create',
        builder: (context, state) => const ExamForm(),
      ),
      GoRoute(
        path: '/exercises',
        name: 'exercises',
        builder: (context, state) => const ExerciseScreen(),
      ),
      GoRoute(
        path: '/flashcards',
        name: 'flashcards',
        builder: (context, state) => const FlashcardsScreen(),
      ),
      GoRoute(
        path: '/documents',
        name: 'documents',
        builder: (context, state) => const DocumentUploadScreen(),
      ),
      GoRoute(
        path: '/simulators',
        name: 'simulators',
        builder: (context, state) => const SimulatorsScreen(),
      ),
      GoRoute(
        path: '/free-body-diagram',
        name: 'free-body-diagram',
        builder: (context, state) => const FreeBodyDiagramScreen(),
      ),
      GoRoute(
        path: '/conversion-calculator',
        name: 'conversion-calculator',
        builder: (context, state) => const ConversionCalculatorScreen(),
      ),
    ],
  );
}
