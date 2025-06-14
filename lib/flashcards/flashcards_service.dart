import 'dart:convert';
import 'dart:math';
import 'flashcard_model.dart';

class FlashcardsService {
  // Simulación de base de datos local
  static List<FlashcardSet> _flashcardSets = [];
  static List<StudySession> _studySessions = [];
  
  // Inicializar con datos de ejemplo
  static bool _initialized = false;
  
  void _initializeSampleData() {
    if (_initialized) return;
    
    // Set de ejemplo: Física
    final physicsSet = FlashcardSet(
      id: '1',
      title: 'Fundamentos de Física',
      description: 'Conceptos básicos de mecánica clásica',
      category: 'Física',
      tags: ['física', 'mecánica', 'fundamentos'],
      createdAt: DateTime.now().subtract(Duration(days: 30)),
      flashcards: [
        Flashcard(
          id: '1-1',
          question: '¿Cuál es la segunda ley de Newton?',
          answer: 'F = ma (La fuerza es igual a la masa por la aceleración)',
          tags: ['newton', 'fuerza', 'aceleración'],
          createdAt: DateTime.now().subtract(Duration(days: 30)),
          difficultyLevel: 2,
        ),
        Flashcard(
          id: '1-2',
          question: '¿Qué es la velocidad?',
          answer: 'La velocidad es el cambio de posición con respecto al tiempo. v = Δx/Δt',
          tags: ['cinemática', 'velocidad'],
          createdAt: DateTime.now().subtract(Duration(days: 29)),
          difficultyLevel: 1,
        ),
        Flashcard(
          id: '1-3',
          question: '¿Cuál es la ecuación de la energía cinética?',
          answer: 'Ec = ½mv² (donde m es masa y v es velocidad)',
          tags: ['energía', 'cinética'],
          createdAt: DateTime.now().subtract(Duration(days: 28)),
          difficultyLevel: 3,
        ),
        Flashcard(
          id: '1-4',
          question: '¿Qué establece la ley de conservación de la energía?',
          answer: 'La energía no se crea ni se destruye, solo se transforma de una forma a otra',
          tags: ['conservación', 'energía'],
          createdAt: DateTime.now().subtract(Duration(days: 27)),
          difficultyLevel: 3,
        ),
        Flashcard(
          id: '1-5',
          question: '¿Qué es la aceleración?',
          answer: 'La aceleración es el cambio de velocidad con respecto al tiempo. a = Δv/Δt',
          tags: ['cinemática', 'aceleración'],
          createdAt: DateTime.now().subtract(Duration(days: 26)),
          difficultyLevel: 2,
        ),
      ],
    );
    
    // Set de ejemplo: Matemáticas
    final mathSet = FlashcardSet(
      id: '2',
      title: 'Álgebra Básica',
      description: 'Conceptos fundamentales de álgebra',
      category: 'Matemáticas',
      tags: ['matemáticas', 'álgebra', 'ecuaciones'],
      createdAt: DateTime.now().subtract(Duration(days: 25)),
      flashcards: [
        Flashcard(
          id: '2-1',
          question: '¿Cuál es la fórmula cuadrática?',
          answer: 'x = (-b ± √(b²-4ac)) / 2a',
          tags: ['ecuaciones', 'cuadrática'],
          createdAt: DateTime.now().subtract(Duration(days: 25)),
          difficultyLevel: 4,
        ),
        Flashcard(
          id: '2-2',
          question: '¿Qué es una función lineal?',
          answer: 'Una función de la forma f(x) = mx + b, donde m es la pendiente y b es la ordenada al origen',
          tags: ['funciones', 'lineal'],
          createdAt: DateTime.now().subtract(Duration(days: 24)),
          difficultyLevel: 2,
        ),
        Flashcard(
          id: '2-3',
          question: '¿Cómo se calcula la pendiente de una recta?',
          answer: 'm = (y₂ - y₁) / (x₂ - x₁)',
          tags: ['pendiente', 'recta'],
          createdAt: DateTime.now().subtract(Duration(days: 23)),
          difficultyLevel: 3,
        ),
      ],
    );
    
    // Set de ejemplo: Química
    final chemistrySet = FlashcardSet(
      id: '3',
      title: 'Química General',
      description: 'Conceptos básicos de química',
      category: 'Química',
      tags: ['química', 'átomos', 'elementos'],
      createdAt: DateTime.now().subtract(Duration(days: 20)),
      flashcards: [
        Flashcard(
          id: '3-1',
          question: '¿Cuál es la ley de Avogadro?',
          answer: 'Volúmenes iguales de gases a la misma temperatura y presión contienen el mismo número de moléculas',
          tags: ['avogadro', 'gases'],
          createdAt: DateTime.now().subtract(Duration(days: 20)),
          difficultyLevel: 3,
        ),
        Flashcard(
          id: '3-2',
          question: '¿Qué es un mol?',
          answer: 'Un mol es la cantidad de sustancia que contiene 6.022 × 10²³ entidades elementales',
          tags: ['mol', 'avogadro'],
          createdAt: DateTime.now().subtract(Duration(days: 19)),
          difficultyLevel: 2,
        ),
        Flashcard(
          id: '3-3',
          question: '¿Cuál es la fórmula de la ley de los gases ideales?',
          answer: 'PV = nRT (donde P=presión, V=volumen, n=moles, R=constante, T=temperatura)',
          tags: ['gases', 'ideales', 'presión'],
          createdAt: DateTime.now().subtract(Duration(days: 18)),
          difficultyLevel: 4,
        ),
      ],
    );
    
    _flashcardSets = [physicsSet, mathSet, chemistrySet];
    _initialized = true;
  }
  
  Future<List<FlashcardSet>> getFlashcardSets() async {
    _initializeSampleData();
    
    // Simular delay de red
    await Future.delayed(Duration(milliseconds: 500));
    
    return List.from(_flashcardSets);
  }
  
  Future<FlashcardSet?> getFlashcardSet(String id) async {
    _initializeSampleData();
    
    // Simular delay de red
    await Future.delayed(Duration(milliseconds: 300));
    
    try {
      return _flashcardSets.firstWhere((set) => set.id == id);
    } catch (e) {
      return null;
    }
  }
  
  Future<FlashcardSet> createFlashcardSet(FlashcardSet set) async {
    // Simular delay de red
    await Future.delayed(Duration(milliseconds: 500));
    
    _flashcardSets.add(set);
    return set;
  }
  
  Future<FlashcardSet> updateFlashcardSet(FlashcardSet set) async {
    // Simular delay de red
    await Future.delayed(Duration(milliseconds: 500));
    
    final index = _flashcardSets.indexWhere((s) => s.id == set.id);
    if (index != -1) {
      _flashcardSets[index] = set;
      return set;
    }
    throw Exception('FlashcardSet not found');
  }
  
  Future<void> deleteFlashcardSet(String id) async {
    // Simular delay de red
    await Future.delayed(Duration(milliseconds: 500));
    
    _flashcardSets.removeWhere((set) => set.id == id);
  }
  
  Future<Flashcard> addFlashcard(String setId, Flashcard flashcard) async {
    // Simular delay de red
    await Future.delayed(Duration(milliseconds: 300));
    
    final setIndex = _flashcardSets.indexWhere((set) => set.id == setId);
    if (setIndex != -1) {
      _flashcardSets[setIndex].flashcards.add(flashcard);
      return flashcard;
    }
    throw Exception('FlashcardSet not found');
  }
  
  Future<Flashcard> updateFlashcard(String setId, Flashcard flashcard) async {
    // Simular delay de red
    await Future.delayed(Duration(milliseconds: 300));
    
    final setIndex = _flashcardSets.indexWhere((set) => set.id == setId);
    if (setIndex != -1) {
      final cardIndex = _flashcardSets[setIndex].flashcards
          .indexWhere((card) => card.id == flashcard.id);
      if (cardIndex != -1) {
        _flashcardSets[setIndex].flashcards[cardIndex] = flashcard;
        return flashcard;
      }
    }
    throw Exception('Flashcard not found');
  }
  
  Future<void> deleteFlashcard(String setId, String cardId) async {
    // Simular delay de red
    await Future.delayed(Duration(milliseconds: 300));
    
    final setIndex = _flashcardSets.indexWhere((set) => set.id == setId);
    if (setIndex != -1) {
      _flashcardSets[setIndex].flashcards
          .removeWhere((card) => card.id == cardId);
    }
  }
  
  Future<StudySession> createStudySession(StudySession session) async {
    // Simular delay de red
    await Future.delayed(Duration(milliseconds: 300));
    
    _studySessions.add(session);
    return session;
  }
  
  Future<StudySession> updateStudySession(StudySession session) async {
    // Simular delay de red
    await Future.delayed(Duration(milliseconds: 300));
    
    final index = _studySessions.indexWhere((s) => s.id == session.id);
    if (index != -1) {
      _studySessions[index] = session;
      return session;