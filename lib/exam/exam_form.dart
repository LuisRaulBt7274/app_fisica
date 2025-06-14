import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'exam_service.dart';
import '../app/constants.dart';
import '../widgets/custom_button.dart';
import '../widgets/loading_indicator.dart';

class ExamForm extends StatefulWidget {
  const ExamForm({super.key});

  @override
  State<ExamForm> createState() => _ExamFormState();
}

class _ExamFormState extends State<ExamForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _topicsController = TextEditingController();
  final _examService = ExamService();

  String _selectedSubject = AppConstants.subjects.first;
  String _selectedDifficulty = AppConstants.difficultyLevels.first;
  int _questionCount = 5;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _topicsController.dispose();
    super.dispose();
  }

  Future<void> _createExam() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _examService.createExam(
        subject: _selectedSubject,
        difficulty: _selectedDifficulty,
        questionCount: _questionCount,
        topics: _topicsController.text.trim(),
        title:
            _titleController.text.trim().isEmpty
                ? null
                : _titleController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Examen creado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Examen'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        loadingMessage: 'Generando examen con IA...',
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Título del examen (opcional)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Información del Examen',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: 'Título del examen (opcional)',
                            hintText: 'Ej: Examen de Matemáticas - Álgebra',
                            prefixIcon: Icon(Icons.title),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Configuración del examen
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Configuración',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),

                        // Selector de materia
                        DropdownButtonFormField<String>(
                          value: _selectedSubject,
                          decoration: const InputDecoration(
                            labelText: 'Materia',
                            prefixIcon: Icon(Icons.subject),
                          ),
                          items:
                              AppConstants.subjects.map((subject) {
                                return DropdownMenuItem(
                                  value: subject,
                                  child: Text(subject),
                                );
                              }).toList(),
                          onChanged: (value) {
                            setState(() => _selectedSubject = value!);
                          },
                        ),

                        const SizedBox(height: 16),

                        // Selector de dificultad
                        DropdownButtonFormField<String>(
                          value: _selectedDifficulty,
                          decoration: const InputDecoration(
                            labelText: 'Dificultad',
                            prefixIcon: Icon(Icons.trending_up),
                          ),
                          items:
                              AppConstants.difficultyLevels.map((level) {
                                return DropdownMenuItem(
                                  value: level,
                                  child: Text(level),
                                );
                              }).toList(),
                          onChanged: (value) {
                            setState(() => _selectedDifficulty = value!);
                          },
                        ),

                        const SizedBox(height: 16),

                        // Cantidad de preguntas
                        Text(
                          'Cantidad de preguntas: $_questionCount',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        Slider(
                          value: _questionCount.toDouble(),
                          min: 3,
                          max: 20,
                          divisions: 17,
                          label: _questionCount.toString(),
                          onChanged: (value) {
                            setState(() => _questionCount = value.round());
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Temas específicos
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Temas Específicos',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _topicsController,
                          decoration: const InputDecoration(
                            labelText: 'Temas a incluir',
                            hintText:
                                'Ej: ecuaciones lineales, sistemas de ecuaciones, gráficas',
                            prefixIcon: Icon(Icons.list),
                          ),
                          maxLines: 3,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Por favor especifica los temas del examen';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Describe los temas específicos que quieres incluir en el examen. Sé específico para obtener mejores resultados.',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Resumen
                Card(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryContainer,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Resumen del Examen',
                              style: Theme.of(
                                context,
                              ).textTheme.titleSmall?.copyWith(
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Se creará un examen de $_selectedSubject con dificultad $_selectedDifficulty, '
                          'que incluirá $_questionCount preguntas sobre los temas especificados. '
                          'El examen incluirá diferentes tipos de preguntas y respuestas con explicaciones.',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Botón crear
                CustomButton(
                  text: 'Generar Examen con IA',
                  onPressed: _createExam,
                  isLoading: _isLoading,
                  icon: Icons.auto_awesome,
                ),

                const SizedBox(height: 16),

                // Botón cancelar
                CustomButton(
                  text: 'Cancelar',
                  onPressed: () => context.pop(),
                  isOutlined: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
