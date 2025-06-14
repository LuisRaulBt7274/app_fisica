import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'exam_model.dart';
import '../app/constants.dart';

class ExamService {
  static const String _tableName = 'exams';
  final SupabaseClient _supabase = Supabase.instance.client;

  // Singleton pattern para mejor performance
  static ExamService? _instance;
  static ExamService get instance => _instance ??= ExamService();

  /// Crea un nuevo examen usando IA
  Future<ExamModel> createExam(ExamSettings settings) async {
    try {
      final userId = _getCurrentUserId();

      // Generar preguntas usando Gemini AI
      final questions = await _generateQuestionsWithGemini(settings);

      final examData = {
        'title': _generateExamTitle(settings),
        'subject': 'Física', // Siempre física
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
      final resetQuestions = exam.questions
          .map((q) => q.copyWith(userAnswer: null, isCorrect: null))
          .toList();

      final updateData = {
        'questions': resetQuestions.map((q) => q.toJson()).toList(),
        'is_completed': false,
        'score': null,
        'completed_at': null,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
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
    final topicsPart = settings.topics.isNotEmpty
        ? ' - ${settings.topics.take(2).join(', ')}'
        : '';
    return 'Examen de Física (${settings.difficulty})$topicsPart';
  }

  int _calculateScore(List<ExamQuestion> questions) {
    if (questions.isEmpty) return 0;

    final correctAnswers = questions.where((q) => q.isCorrect == true).length;
    return ((correctAnswers / questions.length) * 100).round();
  }

  /// Genera preguntas usando Gemini AI
  Future<List<ExamQuestion>> _generateQuestionsWithGemini(
    ExamSettings settings,
  ) async {
    try {
      final prompt = _buildPhysicsPrompt(settings);

      final response = await http.post(
        Uri.parse('${AppConstants.geminiBaseUrl}?key=${AppConstants.geminiApiKey}'),
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
            'maxOutputTokens': 4096,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final generatedText = data['candidates'][0]['content']['parts'][0]['text'];
        return _parseQuestionsFromGeminiResponse(generatedText);
      } else {
        throw Exception('Error en la API de Gemini: ${response.statusCode}');
      }
    } catch (e) {
      // Fallback a preguntas predefinidas si falla la IA
      return _getFallbackQuestions(settings);
    }
  }

  String _buildPhysicsPrompt(ExamSettings settings) {
    final topicsText = settings.topics.isNotEmpty 
        ? settings.topics.join(', ') 
        : 'temas generales de física';
    
    final documentText = settings.hasDocumentContent 
        ? '\n\nBasándote también en este contenido:\n${settings.documentContent}'
        : '';

    return '''
Genera ${settings.questionCount} preguntas de FÍSICA sobre: $topicsText
Nivel de dificultad: ${settings.difficulty}
Tipo de pregunta: ${settings.questionType}$documentText

IMPORTANTE: Solo temas de FÍSICA (mecánica, termodinámica, electromagnetismo, óptica, física moderna, etc.)

Para cada pregunta proporciona:
1. La pregunta (clara y específica de física)
2. 4 opciones de respuesta (solo para opción múltiple)
3. El índice de la respuesta correcta (0-3)
4. Explicación detallada con fórmulas físicas

Formato JSON:
{
  "questions": [
    {
      "question": "¿Cuál es la segunda ley de Newton?",
      "options": ["F = ma", "F = mv", "F = m/a", "F = a/m"],
      "correct_answer": 0,
      "explanation": "La segunda ley de Newton establece que F = ma, donde F es fuerza, m es masa y a es aceleración."
    }
  ]
}

Asegúrate de incluir:
- Fórmulas físicas relevantes
- Unidades del Sistema Internacional
- Conceptos fundamentales de física
- Problemas numéricos cuando sea apropiado
''';
  }

  List<ExamQuestion> _parseQuestionsFromGeminiResponse(String response) {
    try {
      // Buscar el JSON en la respuesta
      final jsonStart = response.indexOf('{');
      final jsonEnd = response.lastIndexOf('}') + 1;
      
      if (jsonStart == -1 || jsonEnd <= jsonStart) {
        throw Exception('No se encontró JSON válido en la respuesta');
      }

      final jsonString = response.substring(jsonStart, jsonEnd);
      final data = jsonDecode(jsonString);
      
      if (data['questions'] == null) {
        throw Exception('No se encontraron preguntas en la respuesta');
      }

      final questionsData = data['questions'] as List;
      return questionsData.asMap().entries.map((entry) {
        final index = entry.key;
        final q = entry.value;
        
        return ExamQuestion(
          id: 'q_${DateTime.now().millisecondsSinceEpoch}_$index',
          question: q['question'] ?? 'Pregunta de física',
          options: List<String>.from(q['options'] ?? [
            'Opción A',
            'Opción B', 
            'Opción C',
            'Opción D'
          ]),
          correctAnswer: q['correct_answer'] ?? 0,
          explanation: q['explanation'] ?? 'Explicación de física',
          type: 'multiple_choice',
        );
      }).toList();
    } catch (e) {
      throw Exception('Error al parsear respuesta de Gemini: $e');
    }
  }

  List<ExamQuestion> _getFallbackQuestions(ExamSettings settings) {
    // Preguntas de respaldo organizadas por dificultad
    final questions = _getPhysicsQuestionsByDifficulty(settings.difficulty);
    
    // Seleccionar aleatoriamente el número solicitado
    questions.shuffle();
    return questions.take(settings.questionCount).toList();
  }

  List<ExamQuestion> _getPhysicsQuestionsByDifficulty(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'básico':
        return _basicPhysicsQuestions;
      case 'intermedio':
        return _intermediatePhysicsQuestions;
      case 'avanzado':
        return _advancedPhysicsQuestions;
      case 'universitario':
        return _universityPhysicsQuestions;
      default:
        return _basicPhysicsQuestions;
    }
  }

  // Bancos de preguntas de física por dificultad
  final List<ExamQuestion> _basicPhysicsQuestions = [
    ExamQuestion(
      id: 'basic_1',
      question: '¿Cuál es la unidad básica de longitud en el Sistema Internacional?',
      options: ['Metro', 'Kilómetro', 'Centímetro', 'Milímetro'],
      correctAnswer: 0,
      explanation: 'El metro (m) es la unidad base de longitud en el Sistema Internacional de Unidades (SI).',
    ),
    ExamQuestion(
      id: 'basic_2',
      question: '¿Qué tipo de energía posee un objeto en movimiento?',
      options: ['Potencial', 'Cinética', 'Térmica', 'Química'],
      correctAnswer: 1,
      explanation: 'La energía cinética es la energía que posee un objeto debido a su movimiento. Se calcula como Ec = ½mv².',
    ),
    ExamQuestion(
      id: 'basic_3',
      question: '¿Cuál es la velocidad de la luz en el vacío?',
      options: ['300,000 km/s', '150,000 km/s', '450,000 km/s', '600,000 km/s'],
      correctAnswer: 0,
      explanation: 'La velocidad de la luz en el vacío es aproximadamente 300,000 km/s o 3×10⁸ m/s.',
    ),
    ExamQuestion(
      id: 'basic_4',
      question: '¿Qué fuerza mantiene a los planetas en órbita alrededor del Sol?',
      options: ['Electromagnética', 'Nuclear fuerte', 'Gravitacional', 'Nuclear débil'],
      correctAnswer: 2,
      explanation: 'La fuerza gravitacional, descrita por la ley de gravitación universal de Newton, mantiene a los planetas en órbita.',
    ),
    ExamQuestion(
      id: 'basic_5',
      question: '¿Cuál es la fórmula de la velocidad?',
      options: ['v = d/t', 'v = d×t', 'v = t/d', 'v = d+t'],
      correctAnswer: 0,
      explanation: 'La velocidad se calcula como la distancia dividida entre el tiempo: v = d/t.',
    ),
  ];

  final List<ExamQuestion> _intermediatePhysicsQuestions = [
    ExamQuestion(
      id: 'inter_1',
      question: '¿Cuál es la segunda ley de Newton?',
      options: ['F = ma', 'F = mv', 'F = m/a', 'F = a/m'],
      correctAnswer: 0,
      explanation: 'La segunda ley de Newton establece que F = ma, donde F es fuerza, m es masa y a es aceleración.',
    ),
    ExamQuestion(
      id: 'inter_2',
      question: 'En el movimiento uniformemente acelerado, ¿cómo varía la velocidad?',
      options: ['Constante', 'Linealmente', 'Exponencialmente', 'Parabólicamente'],
      correctAnswer: 1,
      explanation: 'En el movimiento uniformemente acelerado, la velocidad cambia linealmente con el tiempo: v = v₀ + at.',
    ),
    ExamQuestion(
      id: 'inter_3',
      question: '¿Cuál es la ecuación de la energía cinética?',
      options: ['Ec = mv²', 'Ec = ½mv²', 'Ec = 2mv²', 'Ec = m²v'],
      correctAnswer: 1,
      explanation: 'La energía cinética se calcula como Ec = ½mv², donde m es la masa y v es la velocidad.',
    ),
    ExamQuestion(
      id: 'inter_4',
      question: '¿Qué establece la ley de conservación de la energía?',
      options: [
        'La energía se crea constantemente',
        'La energía se destruye constantemente', 
        'La energía no se crea ni se destruye, solo se transforma',
        'La energía solo existe en forma cinética'
      ],
      correctAnswer: 2,
      explanation: 'La ley de conservación de la energía establece que la energía no se crea ni se destruye, solo se transforma de una forma a otra.',
    ),
    ExamQuestion(
      id: 'inter_5',
      question: '¿Cuál es la unidad de potencia en el SI?',
      options: ['Joule', 'Watt', 'Newton', 'Pascal'],
      correctAnswer: 1,
      explanation: 'El Watt (W) es la unidad de potencia en el SI. Se define como 1 Watt = 1 Joule/segundo.',
    ),
  ];

  final List<ExamQuestion> _advancedPhysicsQuestions = [
    ExamQuestion(
      id: 'adv_1',
      question: '¿Cuál es la relación de De Broglie?',
      options: ['λ = h/p', 'E = mc²', 'F = ma', 'PV = nRT'],
      correctAnswer: 0,
      explanation: 'La longitud de onda de De Broglie relaciona la longitud de onda λ con el momento p: λ = h/p, donde h es la constante de Planck.',
    ),
    ExamQuestion(
      id: 'adv_2',
      question: '¿Qué describe la ecuación de Schrödinger?',
      options: [
        'El movimiento de partículas clásicas',
        'La evolución temporal de sistemas cuánticos',
        'La relatividad especial',
        'Las ondas electromagnéticas'
      ],
      correctAnswer: 1,
      explanation: 'La ecuación de Schrödinger describe la evolución temporal de los sistemas cuánticos y es fundamental en la mecánica cuántica.',
    ),
    ExamQuestion(
      id: 'adv_3',
      question: '¿Cuál es el principio de incertidumbre de Heisenberg?',
      options: [
        'ΔxΔp ≥ ℏ/2',
        'E = mc²',
        'F = ma',
        'v = λf'
      ],
      correctAnswer: 0,
      explanation: 'El principio de incertidumbre establece que ΔxΔp ≥ ℏ/2, donde Δx es la incertidumbre en posición y Δp en momento.',
    ),
    ExamQuestion(
      id: 'adv_4',
      question: '¿Qué fenómeno explica el efecto fotoeléctrico?',
      options: [
        'Naturaleza ondulatoria de la luz',
        'Naturaleza corpuscular de la luz',
        'Interferencia de ondas',
        'Difracción de la luz'
      ],
      correctAnswer: 1,
      explanation: 'El efecto fotoeléctrico se explica por la naturaleza corpuscular de la luz, donde los fotones transfieren energía cuantizada a los electrones.',
    ),
    ExamQuestion(
      id: 'adv_5',
      question: '¿Cuál es la ecuación de Einstein para la energía relativista?',
      options: ['E = mc²', 'E = ½mv²', 'E = hf', 'E = kT'],
      correctAnswer: 0,
      explanation: 'La ecuación E = mc² de Einstein relaciona la masa con la energía en la relatividad especial.',
    ),
  ];

  final List<ExamQuestion> _universityPhysicsQuestions = [
    ExamQuestion(
      id: 'univ_1',
      question: '¿Cuál es la ecuación de campo de Einstein en relatividad general?',
      options: [
        'Gμν = 8πTμν',
        'E = mc²',
        '∇²φ = 4πGρ',
        'F = ma'
      ],
      correctAnswer: 0,
      explanation: 'La ecuación de campo de Einstein Gμν = 8πTμν relaciona la curvatura del espacio-tiempo con la densidad de energía-momento.',
    ),
    ExamQuestion(
      id: 'univ_2',
      question: '¿Qué describe el lagrangiano en mecánica clásica?',
      options: [
        'La energía total del sistema',
        'La diferencia entre energía cinética y potencial',
        'Solo la energía cinética',
        'Solo la energía potencial'
      ],
      correctAnswer: 1,
      explanation: 'El lagrangiano L = T - V es la diferencia entre la energía cinética T y la energía potencial V del sistema.',
    ),
    ExamQuestion(
      id: 'univ_3',
      question: '¿Cuál es la ecuación de Dirac para partículas relativistas con espín?',
      options: [
        '(iγμ∂μ - m)ψ = 0',
        'E = mc²',
        'Hψ = Eψ',
        '∇²ψ = 0'
      ],
      correctAnswer: 0,
      explanation: 'La ecuación de Dirac (iγμ∂μ - m)ψ = 0 describe partículas relativistas con espín 1/2, como electrones.',
    ),
    ExamQuestion(
      id: 'univ_4',
      question: '¿Qué es el bosón de Higgs?',
      options: [
        'Una partícula que da masa a otras partículas',
        'Un tipo de quark',
        'Un leptón cargado',
        'Un fotón masivo'
      ],
      correctAnswer: 0,
      explanation: 'El bosón de Higgs es la partícula asociada al campo de Higgs, que da masa a otras partículas fundamentales a través del mecanismo de Higgs.',
    ),
    ExamQuestion(
      id: 'univ_5',
      question: '¿Cuál es la constante de estructura fina?',
      options: [
        'α ≈ 1/137',
        'c = 3×10⁸ m/s',
        'h = 6.626×10⁻³⁴ J·s',
        'G = 6.674×10⁻¹¹ m³/kg·s²'
      ],
      correctAnswer: 0,
      explanation: 'La constante de estructura fina α ≈ 1/137 es una constante fundamental que caracteriza la fuerza electromagnética.',
    ),
  ];
}

// Clase de excepción personalizada
class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;
}