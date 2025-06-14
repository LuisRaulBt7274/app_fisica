import 'auth_service.dart';

class AuthController {
  final AuthService _authService = AuthService();

  // Sign up
  Future<void> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    await _authService.signUp(
      email: email,
      password: password,
      fullName: fullName,
    );
  }

  // Sign in
  Future<void> signIn({required String email, required String password}) async {
    await _authService.signIn(email: email, password: password);
  }

  // Sign in with Google
  Future<void> signInWithGoogle() async {
    await _authService.signInWithGoogle();
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    await _authService.resetPassword(email);
  }

  // Sign out
  Future<void> signOut() async {
    await _authService.signOut();
  }

  // Update profile
  Future<void> updateProfile({String? fullName, String? avatarUrl}) async {
    await _authService.updateProfile(fullName: fullName, avatarUrl: avatarUrl);
  }
}
