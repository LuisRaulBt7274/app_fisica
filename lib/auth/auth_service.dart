import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../app/constants.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: AppConstants.googleClientId,
  );

  // Get current user
  User? get currentUser => _supabase.auth.currentUser;

  // Get auth state stream
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // Sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: fullName != null ? {'full_name': fullName} : null,
      );
      return response;
    } catch (e) {
      throw AuthException('Error al crear cuenta: ${e.toString()}');
    }
  }

  // Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      throw AuthException('Error al iniciar sesión: ${e.toString()}');
    }
  }

  // Sign in with Google
  Future<AuthResponse> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw AuthException('Inicio de sesión con Google cancelado');
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Sign in to Supabase with Google tokens
      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken,
      );

      return response;
    } catch (e) {
      throw AuthException(
        'Error al iniciar sesión con Google: ${e.toString()}',
      );
    }
  }

  // Send password reset email
  // En auth_service.dart - implementar la función faltante
  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw AuthException(
        'Error al enviar email de recuperación: ${e.toString()}',
      );
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _supabase.auth.signOut();
    } catch (e) {
      throw AuthException('Error al cerrar sesión: ${e.toString()}');
    }
  }

  // Update user profile
  Future<UserResponse> updateProfile({
    String? fullName,
    String? avatarUrl,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (fullName != null) updates['full_name'] = fullName;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

      final response = await _supabase.auth.updateUser(
        UserAttributes(data: updates),
      );
      return response;
    } catch (e) {
      throw AuthException('Error al actualizar perfil: ${e.toString()}');
    }
  }

  // Agregar al final de la clase AuthService:

  // Verificar si el usuario está autenticado
  bool get isAuthenticated => currentUser != null;

  // Obtener el nombre del usuario actual
  String get currentUserName {
    final user = currentUser;
    return user?.userMetadata?['full_name'] ?? 'Usuario';
  }

  // Obtener el email del usuario actual
  String get currentUserEmail {
    final user = currentUser;
    return user?.email ?? '';
  }
}
