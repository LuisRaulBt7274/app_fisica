import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import 'exam_model.dart';
import '../ai/gemini_service.dart';

class ExamService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final GeminiService _geminiService = GeminiService();

  // Crear un nuevo examen usando IA
  Future<ExamModel> createExam({
    required String subject,
    required String difficulty,
    required int questionCount,
    required String topics,
    String? title,
  }) async {
    try {
      // Generar contenido del examen con IA
      final examContent = await _geminiService.generateExam(
        subject: subject,
        difficulty: difficulty,
        questionCount: questionCount,
        topics: topics,
      );

      // Parsear la respuesta de la IA
      final examData = _parseExamContent(examContent, subject, difficulty);

      // Crear título si no se proporciona
      final examTitle = title ?? 'Examen de $subject - $difficulty';

      final exam = ExamModel(
        id: _generateId(),
        title: examTitle,
        subject: subject,
        difficulty: difficulty,
        questions: examData['questions'],
        answers: examData['answers'],
        createdAt: DateTime.now(),
        userId: _supabase.auth.currentUser!.id,
      );

      // Guardar en la base de datos
      await _supabase.from('exams').insert(exam.toJson());

      return exam;
    } catch (e) {
      throw Exception('Error al crear el examen: $e');
    }
  }

  // Crear examen desde documento
  Future<ExamModel> createExamFromDocument({
    required String documentContent,
    required String difficulty,
    required int questionCount,
    String? title,
  }) async {
    try {
      final examContent = await _geminiService.createExamFromDocument(
        documentContent: documentContent,
        difficulty: difficulty,
        questionCount: questionCount,
      );

      final examData = _parseExamContent(examContent, 'Documento', difficulty);

      final exam = ExamModel(
        id: _generateId(),
        title: title ?? 'Examen del Documento - $difficulty',
        subject: 'Documento',
        difficulty: difficulty,
        questions: examData['questions'],
        answers: examData['answers'],
        createdAt: DateTime.now(),
        userId: _supabase.auth.currentUser!.id,
      );

      await _supabase.from('exams').insert(exam.toJson());
      return exam;
    } catch (e) {
      throw Exception('Error al crear el examen desde el documento: $e');
    }
  }

  // Obtener exámenes del usuario
  Future<List<ExamModel>> getUserExams() async {
    try {
      final response = await _supabase
          .from('exams')
          .select()
          .eq('user_id', _supabase.auth.currentUser!.id)
          .order('created_at', ascending: false);

      return response.map((exam) => ExamModel.fromJson(exam)).toList();
    } catch (e) {
      throw Exception('Error al obtener los exámenes: $e');
    }
  }

  // Obtener examen por ID
  Future<ExamModel> getExamById(String examId) async {
    try {
      final response =
          await _supabase.from('exams').select().eq('id', examId).single();

      return ExamModel.fromJson(response);
    } catch (e) {
      throw Exception('Error al obtener el examen: $e');
    }
  }

  // Guardar resultado del examen
  Future<ExamResult> saveExamResult({
    required String examId,
    required Map<int, String> userAnswers,
  }) async {
    try {
      final exam = await getExamById(examId);
      final score = _calculateScore(exam, userAnswers);

      final result = ExamResult(
        id: _generateId(),
        examId: examId,
        userId: _supabase.auth.currentUser!.id,
        userAnswers: userAnswers,
        score: score,
        completedAt: DateTime.now(),
      );

      await _supabase.from('exam_results').insert(result.toJson());
      return result;
    } catch (e) {
      throw Exception('Error al guardar el resultado: $e');
    }
  }

  // Obtener resultados de exámenes del usuario
  Future<List<ExamResult>> getUserExamResults() async {
    try {
      final response = await _supabase
          .from('exam_results')
          .select()
          .eq('user_id', _supabase.auth.currentUser!.id)
          .order('completed_at', ascending: false);

      return response.map((result) => ExamResult.fromJson(result)).toList();
    } catch (e) {
      throw Exception('Error al obtener los resultados: $e');
    }
  }

  // Eliminar examen
  Future<void> deleteExam(String examId) async {
    try {
      await _supabase.from('exams').delete().eq('id', examId);
    } catch (e) {
      throw Exception('Error al eliminar el examen: $e');
    }
  }

  // Métodos privados
  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  Map<String, dynamic> _parseExamContent(
    String content,
    String subject,
    String difficulty,
  ) {
    // Parsear el contenido generado por la IA
    // Este es un parser básico que puede mejorarse
    final lines = content.split('\n');
    final questions = <Question>[];
    final answers = <Answer>[];

    Question? currentQuestion;
    int questionNumber = 0;
    List<String> currentOptions = [];

    for (String line in lines) {
      line = line.trim();
      if (line.isEmpty) continue;

      // Detectar pregunta
      if (line.startsWith('### Pregunta ') || line.contains('Pregunta ')) {
        if (currentQuestion != null) {
          questions.add(currentQuestion);
        }
        questionNumber++;

        // Determinar tipo de pregunta
        String type = 'short_answer';
        if (line.contains('Opción múltiple') || line.contains('múltiple')) {
          type = 'multiple_choice';
        } else if (line.contains('Verdadero/Falso') || line.contains('V/F')) {
          type = 'true_false';
        } else if (line.contains('desarrollo')) {
          type = 'essay';
        }

        currentQuestion = Question(
          number: questionNumber,
          type: type,
          question: '',
          options: type == 'multiple_choice' ? [] : null,
        );
        currentOptions = [];
      }
      // Detectar opciones
      else if (line.startsWith('a)') ||
          line.startsWith('b)') ||
          line.startsWith('c)') ||
          line.startsWith('d)')) {
        currentOptions.add(line.substring(2).trim());
      }
      // Detectar respuestas
      else if (line.startsWith('$questionNumber.') && line.contains('-')) {
        final parts = line.split('-');
        if (parts.length >= 2) {
          answers.add(
            Answer(
              questionNumber: questionNumber,
              answer: parts[0].replaceAll('$questionNumber.', '').trim(),
              explanation: parts[1].trim(),
            ),
          );
        }
      }
      // Contenido de la pregunta
      else if (currentQuestion != null && currentQuestion.question.isEmpty) {
        currentQuestion = Question(
          number: currentQuestion.number,
          type: currentQuestion.type,
          question: line,
          options: currentOptions.isNotEmpty ? currentOptions : null,
        );
      }
    }

    // Agregar última pregunta
    if (currentQuestion != null) {
      questions.add(currentQuestion);
    }

    // Si no se encontraron preguntas, crear algunas por defecto
    if (questions.isEmpty) {
      questions.add(
        Question(
          number: 1,
          type: 'short_answer',
          question: 'Pregunta generada sobre $subject',
        ),
      );
      answers.add(
        Answer(
          questionNumber: 1,
          answer: 'Respuesta ejemplo',
          explanation: 'Explicación de la respuesta',
        ),
      );
    }

    return {'questions': questions, 'answers': answers};
  }

  double _calculateScore(ExamModel exam, Map<int, String> userAnswers) {
    if (exam.answers.isEmpty) return 0.0;

    int correct = 0;
    for (final answer in exam.answers) {
      final userAnswer = userAnswers[answer.questionNumber];
      if (userAnswer != null &&
          userAnswer.toLowerCase().trim() ==
              answer.answer.toLowerCase().trim()) {
        correct++;
      }
    }

    return (correct / exam.answers.length) * 100;
  }
}
