import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/custom_button.dart';
import '../widgets/loading_indicator.dart';
import 'exam_service.dart';
import 'exam_model.dart';

class ExamController extends GetxController {
  final ExamService _examService = ExamService();

  var isLoading = false.obs;
  var currentExam = Rxn<Exam>();
  var currentQuestionIndex = 0.obs;
  var selectedAnswers = <int, int>{}.obs;
  var timeRemaining = 0.obs;
  var isSubmitted = false.obs;
  var score = 0.obs;

  void startExam(String examId) async {
    isLoading.value = true;
    try {
      currentExam.value = await _examService.getExam(examId);
      timeRemaining.value = currentExam.value?.duration ?? 0;
      currentQuestionIndex.value = 0;
      selectedAnswers.clear();
      isSubmitted.value = false;
      score.value = 0;
      _startTimer();
    } catch (e) {
      Get.snackbar('Error', 'No se pudo cargar el examen');
    } finally {
      isLoading.value = false;
    }
  }

  void _startTimer() {
    if (timeRemaining.value > 0) {
      Future.delayed(Duration(seconds: 1), () {
        if (timeRemaining.value > 0 && !isSubmitted.value) {
          timeRemaining.value--;
          _startTimer();
        } else if (timeRemaining.value == 0) {
          submitExam();
        }
      });
    }
  }

  void selectAnswer(int questionIndex, int answerIndex) {
    selectedAnswers[questionIndex] = answerIndex;
  }

  void nextQuestion() {
    if (currentQuestionIndex.value <
        (currentExam.value?.questions.length ?? 0) - 1) {
      currentQuestionIndex.value++;
    }
  }

  void previousQuestion() {
    if (currentQuestionIndex.value > 0) {
      currentQuestionIndex.value--;
    }
  }

  void submitExam() async {
    isLoading.value = true;
    try {
      score.value = _calculateScore();
      isSubmitted.value = true;

      // Guardar resultado
      await _examService.saveExamResult(
        currentExam.value!.id,
        selectedAnswers,
        score.value,
      );

      Get.dialog(
        AlertDialog(
          title: Text('Examen Completado'),
          content: Text(
            'Tu puntuación: ${score.value}/${currentExam.value?.questions.length}',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
                Get.back();
              },
              child: Text('Aceptar'),
            ),
          ],
        ),
      );
    } catch (e) {
      Get.snackbar('Error', 'No se pudo enviar el examen');
    } finally {
      isLoading.value = false;
    }
  }

  int _calculateScore() {
    int correct = 0;
    for (int i = 0; i < (currentExam.value?.questions.length ?? 0); i++) {
      if (selectedAnswers[i] == currentExam.value!.questions[i].correctAnswer) {
        correct++;
      }
    }
    return correct;
  }

  String get formattedTime {
    int minutes = timeRemaining.value ~/ 60;
    int seconds = timeRemaining.value % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

class ExamScreen extends StatelessWidget {
  final ExamController controller = Get.put(ExamController());
  final String examId = Get.arguments as String;

  ExamScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Iniciar examen cuando se carga la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.startExam(examId);
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Examen'),
        backgroundColor: Colors.blue,
        elevation: 0,
        actions: [
          Obx(
            () => Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  controller.formattedTime,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color:
                        controller.timeRemaining.value < 300
                            ? Colors.red
                            : Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: LoadingIndicator());
        }

        if (controller.currentExam.value == null) {
          return Center(child: Text('No se pudo cargar el examen'));
        }

        if (controller.isSubmitted.value) {
          return _buildResultsView();
        }

        return _buildExamView();
      }),
    );
  }

  Widget _buildExamView() {
    final exam = controller.currentExam.value!;
    final currentQuestion =
        exam.questions[controller.currentQuestionIndex.value];

    return Column(
      children: [
        // Barra de progreso
        Container(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pregunta ${controller.currentQuestionIndex.value + 1} de ${exam.questions.length}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    '${controller.selectedAnswers.length}/${exam.questions.length} respondidas',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
              SizedBox(height: 8),
              LinearProgressIndicator(
                value:
                    (controller.currentQuestionIndex.value + 1) /
                    exam.questions.length,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            ],
          ),
        ),

        // Pregunta actual
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentQuestion.question,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (currentQuestion.imageUrl != null) ...[
                          SizedBox(height: 16),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              currentQuestion.imageUrl!,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 200,
                                  color: Colors.grey[300],
                                  child: Center(
                                    child: Icon(Icons.image_not_supported),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 16),

                // Opciones de respuesta
                ...currentQuestion.options.asMap().entries.map((entry) {
                  int index = entry.key;
                  String option = entry.value;
                  bool isSelected =
                      controller.selectedAnswers[controller
                          .currentQuestionIndex
                          .value] ==
                      index;

                  return Obx(
                    () => Container(
                      margin: EdgeInsets.only(bottom: 8),
                      child: InkWell(
                        onTap:
                            () => controller.selectAnswer(
                              controller.currentQuestionIndex.value,
                              index,
                            ),
                        child: Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color:
                                  isSelected ? Colors.blue : Colors.grey[300]!,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            color:
                                isSelected
                                    ? Colors.blue.withOpacity(0.1)
                                    : Colors.white,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color:
                                        isSelected
                                            ? Colors.blue
                                            : Colors.grey[400]!,
                                    width: 2,
                                  ),
                                  color:
                                      isSelected
                                          ? Colors.blue
                                          : Colors.transparent,
                                ),
                                child:
                                    isSelected
                                        ? Center(
                                          child: Icon(
                                            Icons.check,
                                            size: 16,
                                            color: Colors.white,
                                          ),
                                        )
                                        : null,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  option,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color:
                                        isSelected
                                            ? Colors.blue[700]
                                            : Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),

        // Botones de navegación
        Container(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              if (controller.currentQuestionIndex.value > 0)
                Expanded(
                  child: CustomButton(
                    text: 'Anterior',
                    onPressed: controller.previousQuestion,
                    backgroundColor: Colors.grey[300]!,
                    textColor: Colors.black87,
                  ),
                ),
              if (controller.currentQuestionIndex.value > 0)
                SizedBox(width: 16),
              Expanded(
                child: CustomButton(
                  text:
                      controller.currentQuestionIndex.value <
                              exam.questions.length - 1
                          ? 'Siguiente'
                          : 'Finalizar Examen',
                  onPressed: () {
                    if (controller.currentQuestionIndex.value <
                        exam.questions.length - 1) {
                      controller.nextQuestion();
                    } else {
                      _showSubmitDialog();
                    }
                  },
                  backgroundColor: Colors.blue,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResultsView() {
    final exam = controller.currentExam.value!;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(Icons.check_circle, size: 64, color: Colors.green),
                  SizedBox(height: 16),
                  Text(
                    'Examen Completado',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tu puntuación: ${controller.score.value}/${exam.questions.length}',
                    style: TextStyle(fontSize: 20, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Porcentaje: ${((controller.score.value / exam.questions.length) * 100).toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 24),

          CustomButton(
            text: 'Volver al Inicio',
            onPressed: () => Get.back(),
            backgroundColor: Colors.blue,
          ),
        ],
      ),
    );
  }

  void _showSubmitDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('Finalizar Examen'),
        content: Text(
          '¿Estás seguro de que quieres finalizar el examen?\n\n'
          'Preguntas respondidas: ${controller.selectedAnswers.length}/${controller.currentExam.value?.questions.length}\n'
          'Tiempo restante: ${controller.formattedTime}',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.submitExam();
            },
            child: Text('Finalizar'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          ),
        ],
      ),
    );
  }
}
