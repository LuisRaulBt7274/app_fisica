// lib/exam/exam_form.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'exam_model.dart';
import 'exam_service.dart';
import '../documents/document_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/loading_indicator.dart';
import '../app/constants.dart';

class ExamFormController extends GetxController {
  final ExamService _examService = ExamService();
  final DocumentService _documentService = DocumentService();

  final RxBool isLoading = false.obs;
  final RxBool hasDocument = false.obs;
  final RxString documentContent = ''.obs;
  final RxString documentName = ''.obs;

  // Form data
  // selectedSubject ahora siempre será 'Física'
  final RxString selectedSubject = AppConstants.subjects.first.obs;
  final RxString selectedDifficulty = AppConstants.difficultyLevels.first.obs;
  final RxInt questionCount = 10.obs;
  final RxInt timeLimit = 60.obs;
  final RxBool hasTimeLimit = true.obs;
  final RxString questionType = 'multiple_choice'.obs;
  final RxList<String> selectedTopics = <String>[].obs;
  final RxList<String> availableTopics = <String>[].obs;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    // Como solo hay una materia (Física), cargamos sus temas directamente
    loadPhysicsTopics();
  }

  void loadPhysicsTopics() {
    // Aquí defines los temas específicos de física.
    availableTopics.value = [
      'Mecánica Clásica',
      'Termodinámica',
      'Electromagnetismo',
      'Óptica',
      'Física Moderna',
      'Ondas',
      'Movimiento',
      'Energía',
      'Gravedad',
      'Circuitos Eléctricos',
    ];
    selectedTopics.clear();
  }

  void toggleTopic(String topic) {
    if (selectedTopics.contains(topic)) {
      selectedTopics.remove(topic);
    } else {
      selectedTopics.add(topic);
    }
  }

  Future<void> pickDocument() async {
    isLoading.value = true;
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: AppConstants.allowedFileTypes,
      );

      if (result != null && result.files.single.bytes != null) {
        final platformFile = result.files.single;
        if (platformFile.size > AppConstants.maxFileSize) {
          Get.snackbar(
            'Error',
            'El archivo es demasiado grande (máximo 10MB).',
          );
          return;
        }

        documentContent.value = await _documentService.extractTextFromFile(
          platformFile.bytes!,
          platformFile.extension!,
        );
        documentName.value = platformFile.name;
        hasDocument.value = true;
      } else {
        // User canceled the picker
        hasDocument.value = false;
        documentContent.value = '';
        documentName.value = '';
      }
    } catch (e) {
      Get.snackbar('Error', 'No se pudo seleccionar el documento: $e');
      hasDocument.value = false;
      documentContent.value = '';
      documentName.value = '';
    } finally {
      isLoading.value = false;
    }
  }

  String? _validateForm() {
    if (!hasDocument.value && selectedTopics.isEmpty) {
      return 'Debes seleccionar al menos un tema o subir un documento.';
    }
    if (questionCount.value < 1 || questionCount.value > 50) {
      return 'El número de preguntas debe estar entre 1 y 50.';
    }
    if (hasTimeLimit.value && (timeLimit.value < 1 || timeLimit.value > 180)) {
      return 'El límite de tiempo debe estar entre 1 y 180 minutos.';
    }
    return null;
  }

  Future<void> createExam() async {
    final validationError = _validateForm();
    if (validationError != null) {
      Get.snackbar(
        'Error de validación',
        validationError,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;
    try {
      final settings = ExamSettings(
        subject: selectedSubject.value, // Siempre 'Física'
        difficulty: selectedDifficulty.value,
        questionCount: questionCount.value,
        timeLimit: hasTimeLimit.value ? timeLimit.value : null,
        topics: selectedTopics.toList(),
        questionType: questionType.value,
        documentContent: hasDocument.value ? documentContent.value : null,
      );

      final newExam = await _examService.createExam(settings);
      Get.snackbar(
        'Éxito',
        'Examen creado exitosamente.',
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
      );
      Get.back(result: newExam);
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo crear el examen: $e',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}

class ExamForm extends GetView<ExamFormController> {
  const ExamForm({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ExamFormController());
    return LoadingOverlay(
      isLoading: controller.isLoading.value,
      loadingMessage: 'Generando examen con IA...',
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Crear Nuevo Examen de Física',
          ), // Título específico
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Configuración del Examen'),
                // Eliminamos el Dropdown de materia ya que solo es Física
                const SizedBox(height: 16),
                _buildDifficultyDropdown(),
                const SizedBox(height: 16),
                _buildQuestionCountSlider(),
                const SizedBox(height: 16),
                _buildTimeLimitToggle(),
                if (controller.hasTimeLimit.value) _buildTimeLimitSlider(),
                const SizedBox(height: 24),
                _buildSectionTitle('Contenido del Examen'),
                _buildQuestionTypeSelector(),
                const SizedBox(height: 16),
                _buildDocumentUpload(),
                const SizedBox(height: 24),
                _buildTopicsSelection(),
                const SizedBox(height: 24),
                _buildCreateButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Get.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // El Dropdown de Materia se elimina, ya que la materia es fija (Física)
  // Widget _buildSubjectDropdown() {
  //   return Obx(
  //     () => DropdownButtonFormField<String>(
  //       value: controller.selectedSubject.value,
  //       onChanged: (newValue) {
  //         if (newValue != null) {
  //           controller.selectedSubject.value = newValue;
  //           controller.loadTopicsForSubject(newValue);
  //         }
  //       },
  //       items: AppConstants.subjects
  //           .map((subject) => DropdownMenuItem(value: subject, child: Text(subject)))
  //           .toList(),
  //       decoration: const InputDecoration(labelText: 'Materia'),
  //     ),
  //   );
  // }

  Widget _buildDifficultyDropdown() {
    return Obx(
      () => DropdownButtonFormField<String>(
        value: controller.selectedDifficulty.value,
        onChanged: (newValue) {
          if (newValue != null) {
            controller.selectedDifficulty.value = newValue;
          }
        },
        items:
            AppConstants.difficultyLevels
                .map(
                  (difficulty) => DropdownMenuItem(
                    value: difficulty,
                    child: Text(difficulty),
                  ),
                )
                .toList(),
        decoration: const InputDecoration(labelText: 'Dificultad'),
      ),
    );
  }

  Widget _buildQuestionCountSlider() {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Número de Preguntas: ${controller.questionCount.value}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Slider(
            value: controller.questionCount.value.toDouble(),
            min: 1,
            max: 50,
            divisions: 49,
            label: controller.questionCount.value.round().toString(),
            onChanged: (double value) {
              controller.questionCount.value = value.round();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTimeLimitToggle() {
    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Añadir límite de tiempo',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Switch(
            value: controller.hasTimeLimit.value,
            onChanged: (bool value) {
              controller.hasTimeLimit.value = value;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTimeLimitSlider() {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Límite de Tiempo (minutos): ${controller.timeLimit.value}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Slider(
            value: controller.timeLimit.value.toDouble(),
            min: 1,
            max: 180,
            divisions: 179,
            label: controller.timeLimit.value.round().toString(),
            onChanged: (double value) {
              controller.timeLimit.value = value.round();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionTypeSelector() {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tipo de Pregunta',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              Radio<String>(
                value: 'multiple_choice',
                groupValue: controller.questionType.value,
                onChanged: (value) {
                  if (value != null) controller.questionType.value = value;
                },
              ),
              const Text('Opción Múltiple'),
              Radio<String>(
                value: 'open_ended',
                groupValue: controller.questionType.value,
                onChanged: (value) {
                  if (value != null) controller.questionType.value = value;
                },
              ),
              const Text('Abierta'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentUpload() {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Subir Documento (Opcional)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Sube un documento de física para generar preguntas basadas en su contenido. (Max ${AppConstants.maxFileSize ~/ (1024 * 1024)}MB, formatos: ${AppConstants.allowedFileTypes.join(', ')})',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 12),
          CustomButton(
            text:
                controller.hasDocument.value
                    ? 'Cambiar Documento'
                    : 'Seleccionar Documento',
            icon: Icons.upload_file,
            onPressed: controller.pickDocument,
            isOutlined: true,
          ),
          if (controller.hasDocument.value)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'Documento seleccionado: ${controller.documentName.value}',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[700],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTopicsSelection() {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Temas de Física', // Título específico
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Selecciona los temas de física que deseas incluir en el examen (si no subiste un documento).',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 12),
          if (controller.availableTopics.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  controller.availableTopics.map((topic) {
                    final isSelected = controller.selectedTopics.contains(
                      topic,
                    );
                    return FilterChip(
                      label: Text(topic),
                      selected: isSelected,
                      onSelected: (_) => controller.toggleTopic(topic),
                    );
                  }).toList(),
            )
          else
            Text(
              'No hay temas disponibles de física o no se han cargado.',
              style: TextStyle(color: Colors.grey[500]),
            ),
        ],
      ),
    );
  }

  Widget _buildCreateButton() {
    return SizedBox(
      width: double.infinity,
      child: CustomButton(
        text: 'Crear Examen de Física', // Texto específico
        onPressed: controller.createExam,
        isLoading: controller.isLoading.value,
      ),
    );
  }
}
