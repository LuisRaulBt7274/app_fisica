import 'dart:convert';
import 'package:http/http.dart' as http;
import '../app/constants.dart';

class PhysicsAIService {
  static const String _baseUrl = AppConstants.geminiBaseUrl;
  static const String _apiKey = AppConstants.geminiApiKey;

  // Analizar documento de física
  Future<Map<String, dynamic>?> analyzePhysicsDocument(String text) async {
    try {
      final prompt = '''
      Analiza este texto relacionado con física y proporciona:
      1. Conceptos principales identificados
      2. Fórmulas encontradas
      3. Tags sugeridos para categorización
      4. Tipo de problema de física (si aplica)
      5. Nivel de dificultad estimado

      Texto: $text

      Responde en formato JSON con las claves: concepts, formulas, suggestedTags, problemType, difficulty
      ''';

      final response = await _makeGeminiRequest(prompt);
      if (response != null) {
        return _parseAnalysisResponse(response);
      }
    } catch (e) {
      print('Error analizando documento: $e');
    }
    return null;
  }

  // Generar ejercicios de física
  Future<String?> generateExercises({
    required String topic,
    required String difficulty,
    int quantity = 5,
  }) async {
    try {
      final prompt = '''
      Genera $quantity ejercicios de física sobre el tema "$topic" con nivel de dificultad "$difficulty".
      
      Para cada ejercicio incluye:
      1. Enunciado del problema
      2. Datos dados
      3. Lo que se pide encontrar
      4. Solución paso a paso
      5. Respuesta final con unidades

      Asegúrate de que los ejercicios sean educativos y progresivos en dificultad.
      ''';

      return await _makeGeminiRequest(prompt);
    } catch (e) {
      print('Error generando ejercicios: $e');
      return null;
    }
  }

  // Generar explicación teórica
  Future<String?> generateTheory({
    required String topic,
    required String level,
  }) async {
    try {
      final prompt = '''
      Genera una explicación teórica completa sobre "$topic" para nivel "$level".
      
      Incluye:
      1. Introducción al concepto
      2. Principios fundamentales
      3. Fórmulas principales con explicación
      4. Ejemplos prácticos
      5. Aplicaciones en la vida real
      6. Conceptos relacionados

      La explicación debe ser clara, didáctica y apropiada para el nivel especificado.
      ''';

      return await _makeGeminiRequest(prompt);
    } catch (e) {
      print('Error generando teoría: $e');
      return null;
    }
  }

  // Resolver problema de física
  Future<String?> solvePhysicsProblem(String problem) async {
    try {
      final prompt = '''
      Resuelve este problema de física paso a paso:

      $problem

      Proporciona:
      1. Identificación de datos dados
      2. Lo que se pide encontrar
      3. Leyes y fórmulas aplicables
      4. Solución detallada paso a paso
      5. Verificación del resultado
      6. Respuesta final con unidades correctas
      ''';

      return await _makeGeminiRequest(prompt);
    } catch (e) {
      print('Error resolviendo problema: $e');
      return null;
    }
  }

  // Explicar concepto de física
  Future<String?> explainConcept(String concept) async {
    try {
      final prompt = '''
      Explica el concepto de física "$concept" de manera clara y didáctica.
      
      Incluye:
      1. Definición simple
      2. Principios fundamentales
      3. Fórmulas relevantes (si aplica)
      4. Ejemplos cotidianos
      5. Aplicaciones prácticas
      6. Relación con otros conceptos

      Usa un lenguaje accesible pero técnicamente correcto.
      ''';

      return await _makeGeminiRequest(prompt);
    } catch (e) {
      print('Error explicando concepto: $e');
      return null;
    }
  }

  // Método privado para hacer requests a Gemini
  Future<String?> _makeGeminiRequest(String prompt) async {
    try {
      final requestBody = {
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
      };

      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'];
      } else {
        print('Error en API Gemini: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error haciendo request a Gemini: $e');
      return null;
    }
  }

  // Parsear respuesta de análisis
  Map<String, dynamic>? _parseAnalysisResponse(String response) {
    try {
      // Intentar parsear como JSON
      return json.decode(response);
    } catch (e) {
      // Si no es JSON válido, crear estructura básica
      return {
        'concepts': _extractConcepts(response),
        'formulas': _extractFormulas(response),
        'suggestedTags': _generateTags(response),
        'problemType': _classifyProblem(response),
        'difficulty': 'intermedio',
      };
    }
  }

  List<String> _extractConcepts(String text) {
    // Implementación básica para extraer conceptos
    const physicsTerms = [
      'fuerza',
      'energía',
      'velocidad',
      'aceleración',
      'masa',
      'temperatura',
      'calor',
      'corriente',
      'voltaje',
      'onda',
    ];

    return physicsTerms
        .where((term) => text.toLowerCase().contains(term))
        .toList();
  }

  List<String> _extractFormulas(String text) {
    final RegExp formulaRegex = RegExp(r'[a-zA-Z]\s*=\s*[^=\n]+');
    return formulaRegex
        .allMatches(text)
        .map((match) => match.group(0)!.trim())
        .toList();
  }

  List<String> _generateTags(String text) {
    final tags = <String>[];
    final lowerText = text.toLowerCase();

    if (lowerText.contains('fuerza') || lowerText.contains('newton')) {
      tags.add('mecánica');
    }
    if (lowerText.contains('energía') || lowerText.contains('trabajo')) {
      tags.add('energía');
    }
    if (lowerText.contains('calor') || lowerText.contains('temperatura')) {
      tags.add('termodinámica');
    }
    if (lowerText.contains('corriente') || lowerText.contains('voltaje')) {
      tags.add('electricidad');
    }

    return tags;
  }

  String _classifyProblem(String text) {
    final lowerText = text.toLowerCase();

    if (lowerText.contains('fuerza')) return 'Dinámica';
    if (lowerText.contains('velocidad')) return 'Cinemática';
    if (lowerText.contains('energía')) return 'Energía';
    if (lowerText.contains('calor')) return 'Termodinámica';
    if (lowerText.contains('corriente')) return 'Electricidad';

    return 'Física General';
  }
}
