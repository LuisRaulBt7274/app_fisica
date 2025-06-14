// lib/home/home_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../auth/auth_service.dart';

class HomeController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  final RxBool isLoading = false.obs;
  final RxString userName = ''.obs;
  final RxString userEmail = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
  }

  void _loadUserData() {
    final user = _authService.currentUser.value;
    if (user != null) {
      userName.value = user.userMetadata?['full_name'] ?? 'Usuario';
      userEmail.value = user.email ?? '';
    }
  }

  // Navegación a diferentes secciones
  void navigateToExams() {
    Get.toNamed('/exam');
  }

  void navigateToExercises() {
    Get.toNamed('/exercise');
  }

  void navigateToFlashcards() {
    Get.toNamed('/flashcards');
  }

  void navigateToDocuments() {
    Get.toNamed('/documents');
  }

  void navigateToSimulators() {
    Get.toNamed('/simulators');
  }

  void navigateToFreeBodyDiagram() {
    Get.toNamed('/free-body-diagram');
  }

  void navigateToConversionCalculator() {
    Get.toNamed('/conversion-calculator');
  }

  Future<void> signOut() async {
    try {
      isLoading.value = true;
      await _authService.signOut();
      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error al cerrar sesión: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Estadísticas del usuario
  final RxInt totalExams = 0.obs;
  final RxInt totalExercises = 0.obs;
  final RxInt totalFlashcards = 0.obs;

  void updateStats() {
    // Aquí puedes implementar la lógica para obtener estadísticas del usuario
    // desde Supabase
  }
}
