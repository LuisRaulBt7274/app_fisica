// lib/exam/exam_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'exam_service.dart';
import 'exam_model.dart';
import '../widgets/custom_button.dart';
import '../widgets/loading_indicator.dart';

class ExamController extends GetxController {
  final ExamService _examService = Get.find<ExamService>();
  
  final RxBool isLoading = false.obs;
  final RxBool isGenerating = false.obs;
  final RxList<Exam> exams = <Exam>[].obs;
  final RxList<Question> currentQuestions = <Question>[].obs;
  final RxInt currentQuestionIndex = 0.obs;
  final RxMap<int, String> answers = <int, String>{}.obs;
  final RxBool showResults = false.obs;
  final RxDouble score = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    loadExams();
  }

  Future<void> loadExams() async {
    try {
      isLoading.value = true;
      exams.value = await _examService.getUserExams();
    } catch (e) {
      Get.snackbar('Error', 'Error al cargar exámenes: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> generateExam(String subject, String difficulty, int questionCount) async {
    try {
      isGenerating.value = true;
      final exam = await _examService.generateExam(subject, difficulty, questionCount);
      currentQuestions.value = exam.questions;
      currentQuestionIndex.value = 0;
      answers.clear();
      showResults.value = false;
      Get.to(() => ExamTakingScreen());
    } catch (e) {
      Get.snackbar('Error', 'Error al generar examen: $e');
    } finally {
      isGenerating.value = false;
    }
  }

  void selectAnswer(String answer) {
    answers[currentQuestionIndex.value] = answer;
  }

  void nextQuestion() {
    if (currentQuestionIndex.value < currentQuestions.length - 1) {
      currentQuestionIndex.value++;
    }
  }

  void previousQuestion() {
    if (currentQuestionIndex.value > 0) {
      currentQuestionIndex.value--;
    }
  }

  Future<void> submitExam() async {
    try {
      isLoading.value = true;
      
      int correctAnswers = 0;
      for (int i = 0; i < currentQuestions.length; i++) {
        final question = currentQuestions[i];
        final userAnswer = answers[i];
        if (userAnswer == question.correctAnswer) {
          correctAnswers++;
        }
      }
      
      score.value = (correctAnswers / currentQuestions.length) * 100;
      showResults.value = true;
      
      // Guardar resultado en Supabase
      await _examService.saveExamResult(
        currentQuestions.first.subject,
        score.value,
        currentQuestions.length,
        correctAnswers,
      );
      
    } catch (e) {
      Get.snackbar('Error', 'Error al procesar examen: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void goToResults() {
    Get.to(() => ExamResultsScreen());
  }

  void backToHome() {
    Get.back();
    currentQuestions.clear();
    answers.clear();
    showResults.value = false;
  }
}

class ExamScreen extends StatelessWidget {
  ExamScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ExamController());
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exámenes'),
        elevation: 0,
      ),
      body: Obx(() => controller.isLoading.value
          ? const LoadingIndicator()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Crear nuevo examen
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Crear Nuevo Examen',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 16),
                          CustomButton(
                            text: 'Generar con IA',
                            onPressed: () => _showExamForm(context, controller),
                            isLoading: controller.isGenerating.value,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Historial de exámenes
                  Text(
                    'Mis Exámenes',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  controller.exams.isEmpty
                      ? Card(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.quiz_outlined,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No tienes exámenes aún',
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Crea tu primer examen con IA',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: controller.exams.length,
                          itemBuilder: (context, index) {
                            final exam = controller.exams[index];
                            return Card(
                              child: ListTile(
                                leading: CircleAvatar(
                                  child: Text(exam.subject[0].toUpperCase()),
                                ),
                                title: Text(exam.title),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${exam.questions.length} preguntas'),
                                    Text('Dificultad: ${exam.difficulty}'),
                                    if (exam.score != null)
                                      Text('Puntuación: ${exam.score!.toStringAsFixed(1)}%'),
                                  ],
                                ),
                                trailing: PopupMenuButton<String>(
                                  onSelected: (value) {
                                    if (value == 'retake') {
                                      controller.currentQuestions.value = exam.questions;
                                      controller.currentQuestionIndex.value = 0;
                                      controller.answers.clear();
                                      controller.showResults.value = false;
                                      Get.to(() => ExamTakingScreen());
                                    } else if (value == 'delete') {
                                      _confirmDelete(context, controller, exam);
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'retake',
                                      child: Text('Repetir'),
                                    ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Text('Eliminar'),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
      ),
    );
  }

  void _showExamForm(BuildContext context, ExamController controller) {
    final subjectController = TextEditingController();
    String difficulty = 'Intermedio';
    int questionCount = 10;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Generar Examen'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: subjectController,
                decoration: const InputDecoration(
                  labelText: 'Materia o Tema',
                  hintText: 'Ej: Matemáticas, Historia, Biología',
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: difficulty,
                decoration: const InputDecoration(labelText: 'Dificultad'),
                items: ['Fácil', 'Intermedio', 'Difícil']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) => setState(() => difficulty = value!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: questionCount,
                decoration: const InputDecoration(labelText: 'Número de Preguntas'),
                items: [5, 10, 15, 20, 25]
                    .map((e) => DropdownMenuItem(value: e, child: Text('$e')))
                    .toList(),
                onChanged: (value) => setState(() => questionCount = value!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (subjectController.text.isNotEmpty) {
                  Get.back();
                  controller.generateExam(
                    subjectController.text,
                    difficulty,
                    questionCount,
                  );
                }
              },
              child: const Text('Generar'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, ExamController controller, Exam exam) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar'),
        content: const Text('¿Estás seguro de que quieres eliminar este examen?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              // Implementar eliminación
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

class ExamTakingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ExamController>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Realizando Examen'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _confirmExit(context, controller),
        ),
      ),
      body: Obx(() {
        if (controller.showResults.value) {
          return _buildResults(context, controller);
        }
        
        final question = controller.currentQuestions[controller.currentQuestionIndex.value];
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress indicator
              LinearProgressIndicator(
                value: (controller.currentQuestionIndex.value + 1) / controller.currentQuestions.length,
              ),
              const SizedBox(height: 8),
              Text(
                'Pregunta ${controller.currentQuestionIndex.value + 1} de ${controller.currentQuestions.length}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              
              const SizedBox(height: 24),
              
              // Question
              Text(
                question.question,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              
              const SizedBox(height: 24),
              
              // Options
              Expanded(
                child: ListView.builder(
                  itemCount: question.options.length,
                  itemBuilder: (context, index) {
                    final option = question.options[index];
                    final isSelected = controller.answers[controller.currentQuestionIndex.value] == option;
                    
                    return Card(
                      color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
                      child: ListTile(
                        leading: Radio<String>(
                          value: option,
                          groupValue: controller.answers[controller.currentQuestionIndex.value],
                          onChanged: (value) => controller.selectAnswer(value!),
                        ),
                        title: Text(option),
                        onTap: () => controller.selectAnswer(option),
                      ),
                    );
                  },
                ),
              ),
              
              // Navigation buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: controller.currentQuestionIndex.value > 0
                        ? controller.previousQuestion
                        : null,
                    child: const Text('Anterior'),
                  ),
                  if (controller.currentQuestionIndex.value < controller.currentQuestions.length - 1)
                    ElevatedButton(
                      onPressed: controller.nextQuestion,
                      child: const Text('Siguiente'),
                    )
                  else
                    ElevatedButton(
                      onPressed: controller.submitExam,
                      child: const Text('Finalizar'),
                    ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildResults(BuildContext context, ExamController controller) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Icon(
                    controller.score.value >= 70 ? Icons.celebration : Icons.sentiment_neutral,
                    size: 64,
                    color: controller.score.value >= 70 ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Examen Completado',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Puntuación: ${controller.score.value.toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: controller.score.value >= 70 ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          CustomButton(
            text: 'Ver Respuestas Detalladas',
            onPressed: controller.goToResults,
          ),
          const SizedBox(height: 10),
          CustomButton(
            text: 'Volver al Inicio',
            onPressed: controller.backToHome,
            isSecondary: true,
          ),
        ],
      ),
    );
  }

  void _confirmExit(BuildContext context, ExamController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Salir del Examen'),
        content: const Text('¿Estás seguro? Se perderá el progreso actual.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Continuar'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.backToHome();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Salir'),
          ),
        ],
      ),
    );
  }
}

class ExamResultsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ExamController>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultados Detallados'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: controller.currentQuestions.length,
        itemBuilder: (context, index) {
          final question = controller.currentQuestions[index];
          final userAnswer = controller.answers[index];
          final isCorrect = userAnswer == question.correctAnswer;
          
          return Card(
            margin: const EdgeInsets.only(bottom: 16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        isCorrect ? Icons.check_circle : Icons.cancel,
                        color: isCorrect ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Pregunta ${index + 1}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    question.question,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 12),
                  if (userAnswer != null) ...[
                    Text(
                      'Tu respuesta: $userAnswer',
                      style: TextStyle(
                        color: isCorrect ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    'Respuesta correcta: ${question.correctAnswer}',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,