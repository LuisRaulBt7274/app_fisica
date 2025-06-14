// lib/exercise/exercise_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/custom_button.dart';
import 'exercise_controller.dart';
import 'exercise_model.dart';

class ExerciseScreen extends StatelessWidget {
  const ExerciseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ExerciseController controller = Get.put(ExerciseController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ejercicios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateExerciseDialog(context, controller),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.loadExercises(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingIndicator(message: 'Cargando ejercicios...');
        }

        if (controller.error.value.isNotEmpty) {
          return _buildErrorWidget(controller);
        }

        if (controller.exercises.isEmpty) {
          return _buildEmptyState(controller as BuildContext);
        }

        return _buildExercisesList(controller);
      }),
    );
  }

  Widget _buildErrorWidget(ExerciseController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error al cargar ejercicios',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            controller.error.value,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Reintentar',
            onPressed: () => controller.loadExercises(),
            icon: Icons.refresh,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ExerciseController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.quiz_outlined, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            'No tienes ejercicios aún',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Crea tu primer ejercicio para comenzar a practicar',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Crear Nuevo Ejercicio',
            onPressed: () => _showCreateExerciseDialog(context, controller),
            icon: Icons.add,
          ),
        ],
      ),
    );
  }

  Widget _buildExercisesList(ExerciseController controller) {
    return RefreshIndicator(
      onRefresh: () => controller.loadExercises(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: controller.exercises.length,
        itemBuilder: (context, index) {
          final exercise = controller.exercises[index];
          return _buildExerciseCard(exercise, controller);
        },
      ),
    );
  }

  Widget _buildExerciseCard(
    ExerciseModel exercise,
    ExerciseController controller,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _navigateToExercise(exercise),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      exercise.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (exercise.isCompleted)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${exercise.score}%',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildInfoChip(
                    icon: Icons.subject,
                    label: exercise.subject,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    icon: Icons.signal_cellular_alt,
                    label: exercise.difficulty,
                    color: _getDifficultyColor(exercise.difficulty),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.quiz, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    '${exercise.questionCount} preguntas',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const Spacer(),
                  PopupMenuButton<String>(
                    onSelected:
                        (value) =>
                            _handleMenuAction(value, exercise, controller),
                    itemBuilder:
                        (context) => [
                          const PopupMenuItem(
                            value: 'solve',
                            child: Row(
                              children: [
                                Icon(Icons.play_arrow),
                                SizedBox(width: 8),
                                Text('Resolver'),
                              ],
                            ),
                          ),
                          if (exercise.isCompleted)
                            const PopupMenuItem(
                              value: 'results',
                              child: Row(
                                children: [
                                  Icon(Icons.assessment),
                                  SizedBox(width: 8),
                                  Text('Ver Resultados'),
                                ],
                              ),
                            ),
                          const PopupMenuItem(
                            value: 'reset',
                            child: Row(
                              children: [
                                Icon(Icons.refresh),
                                SizedBox(width: 8),
                                Text('Reiniciar'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red),
                                SizedBox(width: 8),
                                Text(
                                  'Eliminar',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ],
                  ),
                ],
              ),
              if (exercise.isCompleted) ...[
                const SizedBox(height: 8),
                Text(
                  'Completado el ${_formatDate(exercise.completedAt!)}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'básico':
        return Colors.green;
      case 'intermedio':
        return Colors.orange;
      case 'avanzado':
        return Colors.red;
      case 'experto':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  void _navigateToExercise(ExerciseModel exercise) {
    if (exercise.isCompleted) {
      Get.toNamed('/exercise/results', arguments: exercise.id);
    } else {
      Get.toNamed('/exercise/solve', arguments: exercise.id);
    }
  }

  void _handleMenuAction(
    String action,
    ExerciseModel exercise,
    ExerciseController controller,
  ) {
    switch (action) {
      case 'solve':
        Get.toNamed('/exercise/solve', arguments: exercise.id);
        break;
      case 'results':
        Get.toNamed('/exercise/results', arguments: exercise.id);
        break;
      case 'reset':
        _showResetDialog(exercise, controller);
        break;
      case 'delete':
        _showDeleteDialog(exercise, controller);
        break;
    }
  }

  void _showCreateExerciseDialog(
    BuildContext context,
    ExerciseController controller,
  ) {
    Get.toNamed('/exercise/create');
  }

  void _showResetDialog(ExerciseModel exercise, ExerciseController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Reiniciar Ejercicio'),
        content: Text(
          '¿Estás seguro de que quieres reiniciar "${exercise.title}"? '
          'Se perderán todas las respuestas guardadas.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.resetExercise(exercise.id);
              Get.toNamed('/exercise/solve', arguments: exercise.id);
            },
            child: const Text('Reiniciar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(
    ExerciseModel exercise,
    ExerciseController controller,
  ) {
    Get.dialog(
      AlertDialog(
        title: const Text('Eliminar Ejercicio'),
        content: Text(
          '¿Estás seguro de que quieres eliminar "${exercise.title}"? '
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteExercise(exercise.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
