import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'exam_model.dart';
import 'exam_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/loading_indicator.dart';
import '../app/constants.dart';

class ExamForm extends StatefulWidget {
  const ExamForm({super.key});

  @override
  State<ExamForm> createState() => _ExamFormState();
}

class _ExamFormState extends State<ExamForm> {
  final ExamService _examService = ExamService.instance;
  final _formKey = GlobalKey<FormState>();

  // Estado del formulario
  bool _isLoading = false;
  bool _hasDocument = false;
  String _documentContent = '';
  String _documentName = '';

  // Configuración del examen
  String _selectedDifficulty = AppConstants.difficultyLevels.first;
  int _questionCount = 10;
  int _timeLimit = 60;
  bool _hasTimeLimit = true;
  String _questionType = 'multiple_choice';
  List<String> _selectedTopics = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Examen de Física'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        loadingMessage: 'Generando examen con IA...',
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Configuración del Examen'),
                _buildDifficultyDropdown(),
                const SizedBox(height: 16),
                _buildQuestionCountSlider(),
                const SizedBox(height: 16),
                _buildTimeLimitToggle(),
                if (_hasTimeLimit) _buildTimeLimitSlider(),
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
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildDifficultyDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedDifficulty,
      onChanged: (newValue) {
        if (newValue != null) {
          setState(() {
            _selectedDifficulty = newValue;
          });
        }
      },
      items: AppConstants.difficultyLevels
          .map(
            (difficulty) => DropdownMenuItem(
              value: difficulty,
              child: Text(difficulty),
            ),
          )
          .toList(),
      decoration: const InputDecoration(
        labelText: 'Dificultad',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.trending_up),
      ),
    );
  }

  Widget _buildQuestionCountSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Número de Preguntas: $_questionCount',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Slider(
          value: _questionCount.toDouble(),
          min: 5,
          max: 30,
          divisions: 25,
          label: _questionCount.toString(),
          onChanged: (double value) {
            setState(() {
              _questionCount = value.round();
            });
          },
        ),
      ],
    );
  }

  Widget _buildTimeLimitToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Añadir límite de tiempo',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Switch(
          value: _hasTimeLimit,
          onChanged: (bool value) {
            setState(() {
              _hasTimeLimit = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildTimeLimitSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Límite de Tiempo (minutos): $_timeLimit',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Slider(
          value: _timeLimit.toDouble(),
          min: 15,
          max: 180,
          divisions: 33,
          label: _timeLimit.toString(),
          onChanged: (double value) {
            setState(() {
              _timeLimit = value.round();
            });
          },
        ),
      ],
    );
  }

  Widget _buildQuestionTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tipo de Pregunta',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Radio<String>(
              value: 'multiple_choice',
              groupValue: _questionType,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _questionType = value;
                  });
                }
              },
            ),
            const Text('Opción Múltiple'),
            const SizedBox(width: 20),
            Radio<String>(
              value: 'mixed',
              groupValue: _questionType,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _questionType = value;
                  });
                }
              },
            ),
            const Text('Mixto'),
          ],
        ),
      ],
    );
  }

  Widget _buildDocumentUpload() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Subir Documento de Física (Opcional)',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Sube un documento de física para generar preguntas basadas en su contenido.',
          style: TextStyle(color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),
        CustomButton(
          text: _hasDocument ? 'Cambiar Documento' : 'Seleccionar Documento',
          icon: Icons.upload_file,
          onPressed: _pickDocument,
          isOutlined: true,
        ),
        if (_hasDocument)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                border: Border.all(color: Colors.green.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green.shade600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Documento: $_documentName',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _hasDocument = false;
                        _documentContent = '';
                        _documentName = '';
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTopicsSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Temas de Física',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Selecciona los temas de física que deseas incluir en el examen.',
          style: TextStyle(color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: AppConstants.physicsTopics.map((topic) {
            final isSelected = _selectedTopics.contains(topic);
            return FilterChip(
              label: Text(topic),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedTopics.add(topic);
                  } else {
                    _selectedTopics.remove(topic);
                  }
                });
              },
              selectedColor: Colors.blue.shade100,
              checkmarkColor: Colors.blue.shade700,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCreateButton() {
    return SizedBox(
      width: double.infinity,
      child: CustomButton(
        text: 'Crear Examen de Física',
        onPressed: _createExam,
        isLoading: _isLoading,
        backgroundColor: Colors.blue[700],
      ),
    );
  }

  Future<void> _pickDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = result.files.single;
        
        if (file.size > AppConstants.maxFileSize) {
          _showError('El archivo es demasiado grande (máximo 15MB).');
          return;
        }

        setState(() {
          _hasDocument = true;
          _documentName = file.name;
          // En una implementación real, aquí extraerías el texto del documento
          _documentContent = 'Contenido del documento de física: ${file.name}';
        });

        _showSuccess('Documento cargado exitosamente');
      }
    } catch (e) {
      _showError('Error al seleccionar el documento: $e');
    }
  }

  Future<void> _createExam() async {
    if (!_validateForm()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final settings = ExamSettings(
        subject: 'Física',
        difficulty: _selectedDifficulty,
        questionCount: _questionCount,
        timeLimit: _hasTimeLimit ? _timeLimit : null,
        topics: _selectedTopics,
        questionType: _questionType,
        documentContent: _hasDocument ? _documentContent : null,
      );

      final newExam = await _examService.createExam(settings);
      
      if (mounted) {
        _showSuccess('Examen creado exitosamente');
        context.pop(newExam);
      }
    } catch (e) {
      if (mounted) {
        _showError('Error al crear el examen: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  bool _validateForm() {
    if (!_hasDocument && _selectedTopics.isEmpty) {
      _showError('Debes seleccionar al menos un tema o subir un documento.');
      return false;
    }
    
    if (_questionCount < 5 || _questionCount > 30) {
      _showError('El número de preguntas debe estar entre 5 y 30.');
      return false;
    }
    
    if (_hasTimeLimit && (_timeLimit < 15 || _timeLimit > 180)) {
      _showError('El límite de tiempo debe estar entre 15 y 180 minutos.');
      return false;
    }
    
    return true;
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}