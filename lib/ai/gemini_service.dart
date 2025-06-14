import 'dart:convert';
import 'package:http/http.dart' as http;
import '../app/constants.dart';
import 'prompts.dart';

class GeminiService {
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';

  Future<String> generateContent(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl?key=${AppConstants.geminiApiKey}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt},
              ],
            },
          ],
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 2048,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'];
      } else {
        throw Exception('Error en la API de Gemini: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al conectar con Gemini: $e');
    }
  }

  // Generar examen
  Future<String> generateExam({
    required String subject,
    required String difficulty,
    required int questionCount,
    required String topics,
  }) async {
    final prompt = PromptTemplates.examPrompt(
      subject: subject,
      difficulty: difficulty,
      questionCount: questionCount,
      topics: topics,
    );

    return await generateContent(prompt);
  }

  // Resolver ejercicio
  Future<String> solveExercise({
    required String exercise,
    required String subject,
  }) async {
    final prompt = PromptTemplates.exerciseSolverPrompt(
      exercise: exercise,
      subject: subject,
    );

    return await generateContent(prompt);
  }

  // Generar flashcards
  Future<String> generateFlashcards({
    required String topic,
    required int cardCount,
    required String difficulty,
  }) async {
    final prompt = PromptTemplates.flashcardsPrompt(
      topic: topic,
      cardCount: cardCount,
      difficulty: difficulty,
    );

    return await generateContent(prompt);
  }

  // Analizar documento
  Future<String> analyzeDocument({
    required String documentContent,
    required String analysisType,
  }) async {
    final prompt = PromptTemplates.documentAnalysisPrompt(
      content: documentContent,
      analysisType: analysisType,
    );

    return await generateContent(prompt);
  }

  // Crear examen desde documento
  Future<String> createExamFromDocument({
    required String documentContent,
    required String difficulty,
    required int questionCount,
  }) async {
    final prompt = PromptTemplates.examFromDocumentPrompt(
      content: documentContent,
      difficulty: difficulty,
      questionCount: questionCount,
    );

    return await generateContent(prompt);
  }

  // Crear flashcards desde documento
  Future<String> createFlashcardsFromDocument({
    required String documentContent,
    required int cardCount,
  }) async {
    final prompt = PromptTemplates.flashcardsFromDocumentPrompt(
      content: documentContent,
      cardCount: cardCount,
    );

    return await generateContent(prompt);
  }

  // Explicar concepto
  Future<String> explainConcept({
    required String concept,
    required String subject,
    required String level,
  }) async {
    final prompt = PromptTemplates.conceptExplanationPrompt(
      concept: concept,
      subject: subject,
      level: level,
    );

    return await generateContent(prompt);
  }
}
