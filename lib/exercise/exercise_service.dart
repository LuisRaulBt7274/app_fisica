// lib/exercise/exercise_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'exercise_model.dart';
import '../app/constants.dart';

class ExerciseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Crear un nuevo ejercicio usando Gemini API
  Future<ExerciseModel> generateExercise(ExerciseSettings settings) async {
    try {
      // Llamada a Gemini API para generar preguntas
      final questions = await _generateQuestionsWithGemini(settings);

      // Crear el ejercicio
      final exercise = ExerciseModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Ejercicio de ${settings.subject}',
        subject: settings.subject,
        difficulty: settings.difficulty,
        questionCount: settings.questionCount,
        questions: questions,
        createdAt: DateTime.now(),
        userId: _supabase.auth.currentUser?.id ?? '',
      );

      // Guardar en Supabase
      await _saveExerciseToDatabase(exercise);

      return exercise;
    } catch (e) {
      throw Exception('Error al generar ejercicio: $e');
    }
  }

  // Obtener ejercicios del usuario
  Future<List<ExerciseModel>> getUserExercises() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Usuario no autenticado');

      final response = await _supabase
          .from('exercises')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => ExerciseModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error al cargar ejercicios: $e');
    }
  }

  // Obtener un ejercicio específico
  Future<ExerciseModel> getExerciseById(String id) async {
    try {
      final response =
          await _supabase.from('exercises').select().eq('id', id).single();

      return ExerciseModel.fromJson(response);
    } catch (e) {
      throw Exception('Error al cargar ejercicio: $e');
    }
  }

  // Actualizar respuestas del usuario
  Future<ExerciseModel> updateUserAnswers(ExerciseModel exercise) async {
    try {
      // Calcular puntaje
      int correctAnswers = 0;
      for (var question in exercise.questions) {
        if (question.userAnswer != null) {
          question.isCorrect = _checkAnswer(question);
          if (question.isCorrect == true) correctAnswers++;
        }
      }

      final score =
          ((correctAnswers / exercise.questions.length) * 100).round();

      final updatedExercise = exercise.copyWith(
        isCompleted: true,
        score: score,
        completedAt: DateTime.now(),
      );

      // Actualizar en base de datos
      await _supabase
          .from('exercises')
          .update(updatedExercise.toJson())
          .eq('id', exercise.id);

      return updatedExercise;
    } catch (e) {
      throw Exception('Error al actualizar ejercicio: $e');
    }
  }

  // Eliminar ejercicio
  Future<void> deleteExercise(String id) async {
    try {
      await _supabase.from('exercises').delete().eq('id', id);
    } catch (e) {
      throw Exception('Error al eliminar ejercicio: $e');
    }
  }

  // Métodos privados
  Future<List<ExerciseQuestion>> _generateQuestionsWithGemini(
    ExerciseSettings settings,
  ) async {
    final prompt = _buildPrompt(settings);

    final response = await http.post(
      Uri.parse(
        '${AppConstants.geminiBaseUrl}?key=${AppConstants.geminiApiKey}',
      ),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt},
            ],
          },
        ],
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Error en la API de Gemini: ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    final generatedText = data['candidates'][0]['content']['parts'][0]['text'];

    return _parseQuestionsFromResponse(generatedText);
  }

  String _buildPrompt(ExerciseSettings settings) {
    return '''
Genera ${settings.questionCount} preguntas de ${settings.subject} con dificultad ${settings.difficulty}.
Para cada pregunta, proporciona:
1. La pregunta
2. Tipo de pregunta (multiple_choice, true_false, o open_ended)
3. Si es multiple_choice o true_false, proporciona las opciones
4. La respuesta correcta
5. Una explicación detallada

Formato de respuesta en JSON:
{
  "questions": [
    {
      "id": "q1",
      "question": "¿Cuál es la fórmula de la velocidad?",
      "type": "multiple_choice",
      "options": ["v = d/t", "v = d*t", "v = t/d", "v = d+t"],
      "correct_answer": 0,
      "explanation": "La velocidad se calcula dividiendo la distancia entre el tiempo."
    }
  ]
}
''';
  }

  List<ExerciseQuestion> _parseQuestionsFromResponse(String response) {
    try {
      // Extraer JSON del texto de respuesta
      final jsonStart = response.indexOf('{');
      final jsonEnd = response.lastIndexOf('}') + 1;
      final jsonString = response.substring(jsonStart, jsonEnd);

      final data = jsonDecode(jsonString);
      final questionsData = data['questions'] as List;

      return questionsData.map((q) => ExerciseQuestion.fromJson(q)).toList();
    } catch (e) {
      throw Exception('Error al parsear respuesta de Gemini: $e');
    }
  }

  Future<void> _saveExerciseToDatabase(ExerciseModel exercise) async {
    await _supabase.from('exercises').insert(exercise.toJson());
  }

  bool _checkAnswer(ExerciseQuestion question) {
    switch (question.type) {
      case 'multiple_choice':
      case 'true_false':
        return question.userAnswer == question.correctAnswer.toString();
      case 'open_ended':
        // Para preguntas abiertas, podrías implementar lógica más compleja
        return question.userAnswer?.toLowerCase().trim() ==
            question.correctAnswer.toString().toLowerCase().trim();
      default:
        return false;
    }
  }
}
