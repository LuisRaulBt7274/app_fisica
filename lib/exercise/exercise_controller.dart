// lib/exercise/exercise_controller.dart
import 'package:get/get.dart';
import 'exercise_model.dart';
import 'exercise_service.dart';

class ExerciseController extends GetxController {
  final ExerciseService _exerciseService = ExerciseService();

  // Observable variables
  final RxList<ExerciseModel> exercises = <ExerciseModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isGenerating = false.obs;
  final Rx<ExerciseModel?> currentExercise = Rx<ExerciseModel?>(null);
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadExercises();
  }

  // Cargar ejercicios del usuario
  Future<void> loadExercises() async {
    try {
      isLoading.value = true;
      error.value = '';

      final userExercises = await _exerciseService.getUserExercises();
      exercises.value = userExercises;
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Error',
        'No se pudieron cargar los ejercicios: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Generar nuevo ejercicio
  Future<void> generateExercise(ExerciseSettings settings) async {
    try {
      isGenerating.value = true;
      error.value = '';

      final newExercise = await _exerciseService.generateExercise(settings);
      exercises.insert(0, newExercise);

      Get.snackbar(
        'Éxito',
        'Ejercicio generado correctamente',
        snackPosition: SnackPosition.BOTTOM,
      );

      // Navegar al ejercicio generado
      Get.toNamed('/exercise/solve', arguments: newExercise.id);
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Error',
        'No se pudo generar el ejercicio: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isGenerating.value = false;
    }
  }

  // Cargar ejercicio específico para resolver
  Future<void> loadExerciseForSolving(String exerciseId) async {
    try {
      isLoading.value = true;
      error.value = '';

      final exercise = await _exerciseService.getExerciseById(exerciseId);
      currentExercise.value = exercise;
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Error',
        'No se pudo cargar el ejercicio: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Actualizar respuesta de una pregunta
  void updateQuestionAnswer(String questionId, String answer) {
    if (currentExercise.value != null) {
      final questions = currentExercise.value!.questions;
      final questionIndex = questions.indexWhere((q) => q.id == questionId);

      if (questionIndex != -1) {
        questions[questionIndex] = questions[questionIndex].copyWith(
          userAnswer: answer,
        );

        // Actualizar el ejercicio
        currentExercise.value = currentExercise.value!.copyWith(
          questions: questions,
        );
      }
    }
  }

  // Enviar ejercicio completado
  Future<void> submitExercise() async {
    if (currentExercise.value == null) return;

    try {
      isLoading.value = true;
      error.value = '';

      final completedExercise = await _exerciseService.updateUserAnswers(
        currentExercise.value!,
      );

      currentExercise.value = completedExercise;

      // Actualizar en la lista de ejercicios
      final index = exercises.indexWhere((e) => e.id == completedExercise.id);
      if (index != -1) {
        exercises[index] = completedExercise;
      }

      Get.snackbar(
        'Ejercicio Completado',
        'Puntuación: ${completedExercise.score}%',
        snackPosition: SnackPosition.BOTTOM,
      );

      // Navegar a resultados
      Get.toNamed('/exercise/results', arguments: completedExercise.id);
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Error',
        'No se pudo enviar el ejercicio: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Eliminar ejercicio
  Future<void> deleteExercise(String exerciseId) async {
    try {
      await _exerciseService.deleteExercise(exerciseId);
      exercises.removeWhere((e) => e.id == exerciseId);

      Get.snackbar(
        'Éxito',
        'Ejercicio eliminado',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Error',
        'No se pudo eliminar el ejercicio: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Limpiar ejercicio actual
  void clearCurrentExercise() {
    currentExercise.value = null;
  }

  // Reiniciar ejercicio
  void resetExercise(String exerciseId) {
    final exercise = exercises.firstWhere((e) => e.id == exerciseId);
    final resetQuestions =
        exercise.questions
            .map((q) => q.copyWith(userAnswer: null, isCorrect: null))
            .toList();

    final resetExercise = exercise.copyWith(
      questions: resetQuestions,
      isCompleted: false,
      score: null,
      completedAt: null,
    );

    currentExercise.value = resetExercise;
  }

  // Obtener progreso del ejercicio actual
  double get currentProgress {
    if (currentExercise.value == null) return 0.0;

    final answeredQuestions =
        currentExercise.value!.questions
            .where((q) => q.userAnswer != null)
            .length;

    return answeredQuestions / currentExercise.value!.questions.length;
  }

  // Verificar si todas las preguntas están respondidas
  bool get allQuestionsAnswered {
    if (currentExercise.value == null) return false;

    return currentExercise.value!.questions.every(
      (q) => q.userAnswer != null && q.userAnswer!.isNotEmpty,
    );
  }
}
