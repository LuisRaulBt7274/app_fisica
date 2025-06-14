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
            'maxOutputTokens': 4096, // Aumentado para respuestas más largas
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['candidates'] != null && data['candidates'].isNotEmpty) {
          return data['candidates'][0]['content']['parts'][0]['text'];
        } else {
          throw Exception('No se recibió contenido de la API');
        }
      } else {
        throw Exception('Error en la API de Gemini: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al conectar con Gemini: $e');
    }
  }

  // Generar examen de física - CORREGIDO
  Future<String> generatePhysicsExam({
    required String difficulty,
    required int questionCount,
    required String topics,
  }) async {
    final prompt = PromptTemplates.examPrompt(
      difficulty: difficulty,
      questionCount: questionCount,
      topics: topics,
    );

    return await generateContent(prompt);
  }

  // Resolver ejercicio de física - CORREGIDO
  Future<String> solvePhysicsExercise({required String exercise}) async {
    final prompt = PromptTemplates.exerciseSolverPrompt(exercise: exercise);

    return await generateContent(prompt);
  }

  // Generar flashcards de física - CORREGIDO
  Future<String> generatePhysicsFlashcards({
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

  // Analizar documento de física
  Future<String> analyzePhysicsDocument({
    required String documentContent,
    required String analysisType,
  }) async {
    final prompt = PromptTemplates.documentAnalysisPrompt(
      content: documentContent,
      analysisType: analysisType,
    );

    return await generateContent(prompt);
  }

  // Crear examen desde documento de física
  Future<String> createPhysicsExamFromDocument({
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

  // Crear flashcards desde documento de física
  Future<String> createPhysicsFlashcardsFromDocument({
    required String documentContent,
    required int cardCount,
  }) async {
    final prompt = PromptTemplates.flashcardsFromDocumentPrompt(
      content: documentContent,
      cardCount: cardCount,
    );

    return await generateContent(prompt);
  }

  // Explicar concepto de física - CORREGIDO
  Future<String> explainPhysicsConcept({
    required String concept,
    required String level,
  }) async {
    final prompt = PromptTemplates.conceptExplanationPrompt(
      concept: concept,
      level: level,
    );

    return await generateContent(prompt);
  }

  // NUEVO: Método para generar problemas de física
  Future<String> generatePhysicsProblems({
    required String topic,
    required String difficulty,
    required int problemCount,
  }) async {
    final prompt = '''
Genera $problemCount problemas de física sobre el tema: $topic con dificultad $difficulty.

Instrucciones:
- Problemas con datos numéricos realistas
- Incluye las soluciones paso a paso
- Usa unidades del Sistema Internacional
- Varía el tipo de problemas (cinemática, dinámica, energía, etc.)
- Incluye diagramas descritos en texto cuando sea necesario

Formato:
## PROBLEMAS DE FÍSICA: $topic

### Problema 1
[Enunciado con datos]

**Solución:**
[Procedimiento paso a paso]

### Problema 2
[Enunciado con datos]

**Solución:**
[Procedimiento paso a paso]
''';

    return await generateContent(prompt);
  }
}
