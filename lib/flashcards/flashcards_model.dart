class Flashcard {
  final String id;
  final String question;
  final String answer;
  final String? imageUrl;
  final String? hint;
  final List<String> tags;
  final DateTime createdAt;
  DateTime? lastReviewed;
  bool isKnown;
  int reviewCount;
  int difficultyLevel; // 1-5 scale

  Flashcard({
    required this.id,
    required this.question,
    required this.answer,
    this.imageUrl,
    this.hint,
    this.tags = const [],
    required this.createdAt,
    this.lastReviewed,
    this.isKnown = false,
    this.reviewCount = 0,
    this.difficultyLevel = 3,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
      'imageUrl': imageUrl,
      'hint': hint,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'lastReviewed': lastReviewed?.toIso8601String(),
      'isKnown': isKnown,
      'reviewCount': reviewCount,
      'difficultyLevel': difficultyLevel,
    };
  }

  factory Flashcard.fromJson(Map<String, dynamic> json) {
    return Flashcard(
      id: json['id'],
      question: json['question'],
      answer: json['answer'],
      imageUrl: json['imageUrl'],
      hint: json['hint'],
      tags: List<String>.from(json['tags'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      lastReviewed:
          json['lastReviewed'] != null
              ? DateTime.parse(json['lastReviewed'])
              : null,
      isKnown: json['isKnown'] ?? false,
      reviewCount: json['reviewCount'] ?? 0,
      difficultyLevel: json['difficultyLevel'] ?? 3,
    );
  }

  Flashcard copyWith({
    String? id,
    String? question,
    String? answer,
    String? imageUrl,
    String? hint,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? lastReviewed,
    bool? isKnown,
    int? reviewCount,
    int? difficultyLevel,
  }) {
    return Flashcard(
      id: id ?? this.id,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      imageUrl: imageUrl ?? this.imageUrl,
      hint: hint ?? this.hint,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      lastReviewed: lastReviewed ?? this.lastReviewed,
      isKnown: isKnown ?? this.isKnown,
      reviewCount: reviewCount ?? this.reviewCount,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
    );
  }

  bool get needsReview {
    if (lastReviewed == null) return true;

    // Calcular intervalo basado en dificultad y si es conocida
    int intervalDays = 1;
    if (isKnown) {
      switch (difficultyLevel) {
        case 1:
          intervalDays = 14; // Fácil - 2 semanas
          break;
        case 2:
          intervalDays = 7; // Medio-fácil - 1 semana
          break;
        case 3:
          intervalDays = 3; // Medio - 3 días
          break;
        case 4:
          intervalDays = 2; // Medio-difícil - 2 días
          break;
        case 5:
          intervalDays = 1; // Difícil - 1 día
          break;
      }
    }

    return DateTime.now().difference(lastReviewed!).inDays >= intervalDays;
  }
}

class FlashcardSet {
  final String id;
  final String title;
  final String description;
  final List<Flashcard> flashcards;
  final DateTime createdAt;
  DateTime? lastStudied;
  final List<String> tags;
  final String? category;
  final bool isPublic;
  final String createdBy;

  FlashcardSet({
    required this.id,
    required this.title,
    required this.description,
    required this.flashcards,
    required this.createdAt,
    this.lastStudied,
    this.tags = const [],
    this.category,
    this.isPublic = false,
    this.createdBy = 'user',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'flashcards': flashcards.map((f) => f.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'lastStudied': lastStudied?.toIso8601String(),
      'tags': tags,
      'category': category,
      'isPublic': isPublic,
      'createdBy': createdBy,
    };
  }

  factory FlashcardSet.fromJson(Map<String, dynamic> json) {
    return FlashcardSet(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      flashcards:
          (json['flashcards'] as List)
              .map((f) => Flashcard.fromJson(f))
              .toList(),
      createdAt: DateTime.parse(json['createdAt']),
      lastStudied:
          json['lastStudied'] != null
              ? DateTime.parse(json['lastStudied'])
              : null,
      tags: List<String>.from(json['tags'] ?? []),
      category: json['category'],
      isPublic: json['isPublic'] ?? false,
      createdBy: json['createdBy'] ?? 'user',
    );
  }

  FlashcardSet copyWith({
    String? id,
    String? title,
    String? description,
    List<Flashcard>? flashcards,
    DateTime? createdAt,
    DateTime? lastStudied,
    List<String>? tags,
    String? category,
    bool? isPublic,
    String? createdBy,
  }) {
    return FlashcardSet(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      flashcards: flashcards ?? this.flashcards,
      createdAt: createdAt ?? this.createdAt,
      lastStudied: lastStudied ?? this.lastStudied,
      tags: tags ?? this.tags,
      category: category ?? this.category,
      isPublic: isPublic ?? this.isPublic,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  int get totalCards => flashcards.length;

  int get studiedCards =>
      flashcards.where((f) => f.lastReviewed != null).length;

  int get knownCards => flashcards.where((f) => f.isKnown).length;

  int get cardsNeedingReview => flashcards.where((f) => f.needsReview).length;

  double get progressPercentage {
    if (totalCards == 0) return 0.0;
    return (studiedCards / totalCards) * 100;
  }

  double get masteryPercentage {
    if (totalCards == 0) return 0.0;
    return (knownCards / totalCards) * 100;
  }

  List<Flashcard> getCardsByDifficulty(int difficulty) {
    return flashcards.where((f) => f.difficultyLevel == difficulty).toList();
  }

  List<Flashcard> getCardsNeedingReview() {
    return flashcards.where((f) => f.needsReview).toList();
  }

  List<Flashcard> getUnknownCards() {
    return flashcards.where((f) => !f.isKnown).toList();
  }

  List<Flashcard> getCardsByTag(String tag) {
    return flashcards.where((f) => f.tags.contains(tag)).toList();
  }
}

class StudySession {
  final String id;
  final String flashcardSetId;
  final DateTime startTime;
  DateTime? endTime;
  final List<StudySessionCard> cards;
  final StudyMode mode;

  StudySession({
    required this.id,
    required this.flashcardSetId,
    required this.startTime,
    this.endTime,
    required this.cards,
    required this.mode,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'flashcardSetId': flashcardSetId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'cards': cards.map((c) => c.toJson()).toList(),
      'mode': mode.toString(),
    };
  }

  factory StudySession.fromJson(Map<String, dynamic> json) {
    return StudySession(
      id: json['id'],
      flashcardSetId: json['flashcardSetId'],
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      cards:
          (json['cards'] as List)
              .map((c) => StudySessionCard.fromJson(c))
              .toList(),
      mode: StudyMode.values.firstWhere(
        (m) => m.toString() == json['mode'],
        orElse: () => StudyMode.review,
      ),
    );
  }

  int get totalCards => cards.length;

  int get correctAnswers => cards.where((c) => c.wasCorrect).length;

  int get incorrectAnswers =>
      cards.where((c) => !c.wasCorrect && c.wasAnswered).length;

  double get accuracy {
    int answered = cards.where((c) => c.wasAnswered).length;
    if (answered == 0) return 0.0;
    return (correctAnswers / answered) * 100;
  }

  Duration get duration {
    if (endTime == null) return Duration.zero;
    return endTime!.difference(startTime);
  }
}

class StudySessionCard {
  final String flashcardId;
  final DateTime reviewedAt;
  final bool wasCorrect;
  final bool wasAnswered;
  final Duration timeSpent;

  StudySessionCard({
    required this.flashcardId,
    required this.reviewedAt,
    required this.wasCorrect,
    required this.wasAnswered,
    required this.timeSpent,
  });

  Map<String, dynamic> toJson() {
    return {
      'flashcardId': flashcardId,
      'reviewedAt': reviewedAt.toIso8601String(),
      'wasCorrect': wasCorrect,
      'wasAnswered': wasAnswered,
      'timeSpent': timeSpent.inMilliseconds,
    };
  }

  factory StudySessionCard.fromJson(Map<String, dynamic> json) {
    return StudySessionCard(
      flashcardId: json['flashcardId'],
      reviewedAt: DateTime.parse(json['reviewedAt']),
      wasCorrect: json['wasCorrect'],
      wasAnswered: json['wasAnswered'],
      timeSpent: Duration(milliseconds: json['timeSpent']),
    );
  }
}

enum StudyMode { review, test, spaced_repetition, quick_review }

enum FlashcardDifficulty { very_easy, easy, medium, hard, very_hard }

extension FlashcardDifficultyExtension on FlashcardDifficulty {
  int get level {
    switch (this) {
      case FlashcardDifficulty.very_easy:
        return 1;
      case FlashcardDifficulty.easy:
        return 2;
      case FlashcardDifficulty.medium:
        return 3;
      case FlashcardDifficulty.hard:
        return 4;
      case FlashcardDifficulty.very_hard:
        return 5;
    }
  }

  String get label {
    switch (this) {
      case FlashcardDifficulty.very_easy:
        return 'Muy Fácil';
      case FlashcardDifficulty.easy:
        return 'Fácil';
      case FlashcardDifficulty.medium:
        return 'Medio';
      case FlashcardDifficulty.hard:
        return 'Difícil';
      case FlashcardDifficulty.very_hard:
        return 'Muy Difícil';
    }
  }
}
