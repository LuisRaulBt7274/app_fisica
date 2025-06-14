import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';
import 'exam_model.dart';

class ExamService extends GetxService {
  static const String _tableName = 'exams';
  final SupabaseClient _supabase = Supabase.instance.client;

  // Singleton pattern para mejor performance
  static ExamService? _instance;
  static ExamService get instance => _instance ??= ExamService();

  /// Crea un nuevo examen usando IA
  Future<ExamModel> createExam(ExamSettings settings) async {
    try {
      final userId = _getCurrentUserId();

      // Generar preguntas usando IA (simulado)
      final questions = await _generateQuestionsWithAI(settings);

      final examData = {
        'title': _generateExamTitle(settings),
        'subject': settings.subject,
        'difficulty': settings.difficulty,
        'question_count': settings.questionCount,
        'questions': questions.map((q) => q.toJson()).toList(),
        'user_id': userId,
        'time_limit': settings.timeLimit,
        'is_completed': false,
        'created_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from(_tableName)
          .insert(examData)
          .select()
          .single()
          .timeout(const Duration(seconds: 30));

      return ExamModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw AppException('Error de base de datos: ${e.message}');
    } on TimeoutException {
      throw AppException('Tiempo de espera agotado. Intenta nuevamente.');
    } catch (e) {
      throw AppException('Error al crear el examen: ${e.toString()}');
    }
  }

  /// Obtiene todos los exámenes del usuario actual
  Future<List<ExamModel>> getUserExams() async {
    try {
      final userId = _getCurrentUserId();

      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .timeout(const Duration(seconds: 15));

      return response
          .map<ExamModel>((json) => ExamModel.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw AppException('Error al cargar exámenes: ${e.message}');
    } catch (e) {
      throw AppException('Error de conexión: ${e.toString()}');
    }
  }

  /// Obtiene un examen específico por ID
  Future<ExamModel?> getExamById(String examId) async {
    try {
      final userId = _getCurrentUserId();

      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('id', examId)
          .eq('user_id', userId)
          .maybeSingle()
          .timeout(const Duration(seconds: 10));

      return response != null ? ExamModel.fromJson(response) : null;
    } catch (e) {
      throw AppException('Error al obtener el examen: ${e.toString()}');
    }
  }

  /// Actualiza las respuestas del usuario en un examen
  Future<ExamModel> updateExamAnswers(
    String examId,
    List<ExamQuestion> questions,
  ) async {
    try {
      final userId = _getCurrentUserId();

      final updateData = {
        'questions': questions.map((q) => q.toJson()).toList(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from(_tableName)
          .update(updateData)
          .eq('id', examId)
          .eq('user_id', userId)
          .select()
          .single()
          .timeout(const Duration(seconds: 15));

      return ExamModel.fromJson(response);
    } catch (e) {
      throw AppException('Error al guardar respuestas: ${e.toString()}');
    }
  }

  /// Completa un examen y calcula la puntuación
  Future<ExamModel> completeExam(
    String examId,
    List<ExamQuestion> questions,
  ) async {
    try {
      final userId = _getCurrentUserId();
      final score = _calculateScore(questions);

      final updateData = {
        'questions': questions.map((q) => q.toJson()).toList(),
        'is_completed': true,
        'score': score,
        'completed_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from(_tableName)
          .update(updateData)
          .eq('id', examId)
          .eq('user_id', userId)
          .select()
          .single()
          .timeout(const Duration(seconds: 15));

      return ExamModel.fromJson(response);
    } catch (e) {
      throw AppException('Error al completar el examen: ${e.toString()}');
    }
  }

  /// Elimina un examen
  Future<void> deleteExam(String examId) async {
    try {
      final userId = _getCurrentUserId();

      await _supabase
          .from(_tableName)
          .delete()
          .eq('id', examId)
          .eq('user_id', userId)
          .timeout(const Duration(seconds: 10));
    } catch (e) {
      throw AppException('Error al eliminar el examen: ${e.toString()}');
    }
  }

  /// Reinicia un examen completado
  Future<ExamModel> resetExam(String examId) async {
    try {
      final exam = await getExamById(examId);
      if (exam == null) throw AppException('Examen no encontrado');

      // Limpiar respuestas de las preguntas
      final resetQuestions =
          exam.questions
              .map((q) => q.copyWith(userAnswer: null, isCorrect: null))
              .toList();

      final updateData = {
        'questions': resetQuestions.map((q) => q.toJson()).toList(),
        'is_completed': false,
        'score': null,
        'completed_at': null,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response =
          await _supabase
              .from(_tableName)
              .update(updateData)
              .eq('id', examId)
              .eq('user_id', _getCurrentUserId())
              .select()
              .single();

      return ExamModel.fromJson(response);
    } catch (e) {
      throw AppException('Error al reiniciar el examen: ${e.toString()}');
    }
  }

  // Métodos privados de utilidad

  String _getCurrentUserId() {
    final user = _supabase.auth.currentUser;
    if (user == null) throw AppException('Usuario no autenticado');
    return user.id;
  }

  String _generateExamTitle(ExamSettings settings) {
    final topicsPart =
        settings.topics.isNotEmpty
            ? ' - ${settings.topics.take(2).join(', ')}'
            : '';
    return 'Examen de ${settings.subject} (${settings.difficulty})$topicsPart';
  }

  int _calculateScore(List<ExamQuestion> questions) {
    if (questions.isEmpty) return 0;

    final correctAnswers = questions.where((q) => q.isCorrect == true).length;
    return ((correctAnswers / questions.length) * 100).round();
  }

  /// Simula la generación de preguntas con IA
  Future<List<ExamQuestion>> _generateQuestionsWithAI(
    ExamSettings settings,
  ) async {
    // Simulación de delay de IA
    await Future.delayed(const Duration(seconds: 2));

    final questions = <ExamQuestion>[];

    for (int i = 0; i < settings.questionCount; i++) {
      questions.add(_generateSampleQuestion(i + 1, settings));
    }

    return questions;
  }

  ExamQuestion _generateSampleQuestion(int number, ExamSettings settings) {
    // Banco de preguntas de ejemplo para física
    final sampleQuestions = _getPhysicsQuestions(settings.difficulty);
    final questionData = sampleQuestions[number % sampleQuestions.length];

    return ExamQuestion(
      question: questionData['question'],
      options: List<String>.from(questionData['options']),
      correctAnswer: questionData['correctAnswer'],
      explanation: questionData['explanation'],
      type: settings.questionType,
    );
  }

  List<Map<String, dynamic>> _getPhysicsQuestions(String difficulty) {
    // Banco de preguntas basado en la dificultad
    switch (difficulty.toLowerCase()) {
      case 'básico':
        return _basicPhysicsQuestions;
      case 'intermedio':
        return _intermediatePhysicsQuestions;
      case 'avanzado':
        return _advancedPhysicsQuestions;
      default:
        return _basicPhysicsQuestions;
    }
  }

  // Bancos de preguntas de ejemplo
  final List<Map<String, dynamic>> _basicPhysicsQuestions = [
    {
      'question':
          '¿Cuál es la unidad básica de longitud en el Sistema Internacional?',
      'options': ['Metro', 'Kilómetro', 'Centímetro', 'Milímetro'],
      'correctAnswer': 0,
      'explanation': 'El metro es la unidad base de longitud en el SI.',
    },
    {
      'question': '¿Qué tipo de energía posee un objeto en movimiento?',
      'options': ['Potencial', 'Cinética', 'Térmica', 'Química'],
      'correctAnswer': 1,
      'explanation':
          'La energía cinética es la energía asociada al movimiento.',
    },
    // ... más preguntas básicas
  ];

  final List<Map<String, dynamic>> _intermediatePhysicsQuestions = [
    {
      'question':
          'En el movimiento uniformemente acelerado, ¿cómo varía la velocidad?',
      'options': [
        'Constante',
        'Linealmente',
        'Exponencialmente',
        'Parabólicamente',
      ],
      'correctAnswer': 1,
      'explanation': 'En MUA, la velocidad cambia linealmente con el tiempo.',
    },
    // ... más preguntas intermedias
  ];

  final List<Map<String, dynamic>> _advancedPhysicsQuestions = [
    {
      'question': '¿Cuál es la relación de De Broglie?',
      'options': ['λ = h/p', 'E = mc²', 'F = ma', 'PV = nRT'],
      'correctAnswer': 0,
      'explanation':
          'La longitud de onda de De Broglie relaciona la longitud de onda con el momento.',
    },
    // ... más preguntas avanzadas
  ];
}

// Clase de excepción personalizada
class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;
}
