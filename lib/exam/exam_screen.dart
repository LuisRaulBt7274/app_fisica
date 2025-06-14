import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'exam_model.dart';
import 'exam_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/loading_indicator.dart';

class ExamScreen extends StatefulWidget {
  const ExamScreen({super.key});

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  final ExamService _examService = ExamService.instance;
  
  List<ExamModel> _exams = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadExams();
  }

  Future<void> _loadExams() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final exams = await _examService.getUserExams();
      setState(() {
        _exams = exams;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exámenes de Física'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadExams,
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToCreateExam(),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Examen'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingIndicator(message: 'Cargando exámenes...');
    }

    if (_error != null) {
      return _buildErrorWidget();
    }

    if (_exams.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadExams,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _exams.length,
        itemBuilder: (context, index) {
          final exam = _exams[index];
          return _buildExamCard(exam);
        },
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
          const SizedBox(height: 16),
          Text(
            'Error al cargar exámenes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Reintentar',
            onPressed: _loadExams,
            icon: Icons.refresh,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.quiz_outlined, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            'No tienes exámenes aún',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Crea tu primer examen de física para comenzar a estudiar',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Crear Primer Examen',
            onPressed: () => _navigateToCreateExam(),
            icon: Icons.add,
            backgroundColor: Colors.blue[700],
          ),
        ],
      ),
    );
  }

  Widget _buildExamCard(ExamModel exam) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: InkWell(
        onTap: () => _navigateToTakeExam(exam),
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
                      exam.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: exam.statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: exam.statusColor),
                    ),
                    child: Text(
                      exam.statusText,
                      style: TextStyle(
                        color: exam.statusColor,
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
                    icon: Icons.science,
                    label: exam.subject,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    icon: Icons.signal_cellular_alt,
                    label: exam.difficulty,
                    color: _getDifficultyColor(exam.difficulty),
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    icon: Icons.quiz,
                    label: '${exam.questionCount} preguntas',
                    color: Colors.green,
                  ),
                ],
              ),
              if (exam.hasTimeLimit) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.timer, size: 16, color: Colors.orange.shade600),
                    const SizedBox(width: 4),
                    Text(
                      '${exam.timeLimit} minutos',
                      style: TextStyle(color: Colors.orange.shade600),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    'Creado: ${_formatDate(exam.createdAt)}',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleMenuAction(value, exam),
                    itemBuilder: (context) => [
                      if (!exam.isCompleted)
                        const PopupMenuItem(
                          value: 'take',
                          child: Row(
                            children: [
                              Icon(Icons.play_arrow),
                              SizedBox(width: 8),
                              Text('Realizar Examen'),
                            ],
                          ),
                        ),
                      if (exam.isCompleted)
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
      case 'universitario':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  void _navigateToCreateExam() async {
    final result = await context.push('/exam/create');
    if (result != null) {
      _loadExams(); // Recargar la lista si se creó un examen
    }
  }

  void _navigateToTakeExam(ExamModel exam) {
    // Aquí navegarías a la pantalla de realizar examen
    // context.push('/exam/take/${exam.id}');
    _showComingSoon('Realizar Examen');
  }

  void _handleMenuAction(String action, ExamModel exam) {
    switch (action) {
      case 'take':
        _navigateToTakeExam(exam);
        break;
      case 'results':
        _showComingSoon('Ver Resultados');
        break;
      case 'reset':
        _showResetDialog(exam);
        break;
      case 'delete':
        _showDeleteDialog(exam);
        break;
    }
  }

  void _showResetDialog(ExamModel exam) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reiniciar Examen'),
        content: Text(
          '¿Estás seguro de que quieres reiniciar "${exam.title}"? '
          'Se perderán todas las respuestas guardadas.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _examService.resetExam(exam.id);
                _loadExams();
                _showSuccess('Examen reiniciado');
              } catch (e) {
                _showError('Error al reiniciar: $e');
              }
            },
            child: const Text('Reiniciar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(ExamModel exam) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Examen'),
        content: Text(
          '¿Estás seguro de que quieres eliminar "${exam.title}"? '
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _examService.deleteExam(exam.id);
                _loadExams();
                _showSuccess('Examen eliminado');
              } catch (e) {
                _showError('Error al eliminar: $e');
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature - Próximamente disponible'),
        backgroundColor: Colors.blue,
      ),
    );
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}