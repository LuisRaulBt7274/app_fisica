// lib/exercise/exercise_model.dart
import 'package:collection/collection.dart'; // For firstWhereOrNull

class ExerciseModel {
  final String id;
  final String title;
  final String subject;
  final String difficulty;
  final int questionCount;
  final List<ExerciseQuestion> questions;
  final DateTime createdAt;
  final String userId;
  final bool isCompleted;
  final int? score;
  final DateTime? completedAt;

  ExerciseModel({
    required this.id,
    required this.title,
    required this.subject,
    required this.difficulty,
    required this.questionCount,
    required this.questions,
    required this.createdAt,
    required this.userId,
    this.isCompleted = false,
    this.score,
    this.completedAt,
  });

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      id: json['id'],
      title: json['title'],
      subject: json['subject'],
      difficulty: json['difficulty'],
      questionCount: json['question_count'],
      questions:
          (json['questions'] as List)
              .map((q) => ExerciseQuestion.fromJson(q))
              .toList(),
      createdAt: DateTime.parse(json['created_at']),
      userId: json['user_id'],
      isCompleted: json['is_completed'] ?? false,
      score: json['score'],
      completedAt:
          json['completed_at'] != null
              ? DateTime.parse(json['completed_at'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subject': subject,
      'difficulty': difficulty,
      'question_count': questionCount,
      'questions': questions.map((q) => q.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'user_id': userId,
      'is_completed': isCompleted,
      'score': score,
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  ExerciseModel copyWith({
    String? id,
    String? title,
    String? subject,
    String? difficulty,
    int? questionCount,
    List<ExerciseQuestion>? questions,
    DateTime? createdAt,
    String? userId,
    bool? isCompleted,
    int? score,
    DateTime? completedAt,
  }) {
    return ExerciseModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subject: subject ?? this.subject,
      difficulty: difficulty ?? this.difficulty,
      questionCount: questionCount ?? this.questionCount,
      questions: questions ?? this.questions,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
      isCompleted: isCompleted ?? this.isCompleted,
      score: score ?? this.score,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

class ExerciseQuestion {
  final String id;
  final String question;
  final String type; // e.g., 'multiple_choice', 'open_ended', 'true_false'
  final List<String>? options; // For multiple_choice, true_false
  final dynamic correctAnswer; // int for index, String for open_ended
  final String explanation;
  String? userAnswer;
  bool? isCorrect; // To store if the user's answer was correct

  ExerciseQuestion({
    required this.id,
    required this.question,
    required this.type,
    this.options,
    this.correctAnswer,
    required this.explanation,
    this.userAnswer,
    this.isCorrect,
  });

  factory ExerciseQuestion.fromJson(Map<String, dynamic> json) {
    return ExerciseQuestion(
      id: json['id'],
      question: json['question'],
      type: json['type'],
      options:
          json['options'] != null ? List<String>.from(json['options']) : null,
      correctAnswer: json['correct_answer'],
      explanation: json['explanation'],
      userAnswer: json['user_answer'],
      isCorrect: json['is_correct'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'type': type,
      'options': options,
      'correct_answer': correctAnswer,
      'explanation': explanation,
      'user_answer': userAnswer,
      'is_correct': isCorrect,
    };
  }

  ExerciseQuestion copyWith({
    String? id,
    String? question,
    String? type,
    List<String>? options,
    dynamic correctAnswer,
    String? explanation,
    String? userAnswer,
    bool? isCorrect,
  }) {
    return ExerciseQuestion(
      id: id ?? this.id,
      question: question ?? this.question,
      type: type ?? this.type,
      options: options ?? this.options,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      explanation: explanation ?? this.explanation,
      userAnswer: userAnswer ?? this.userAnswer,
      isCorrect: isCorrect ?? this.isCorrect,
    );
  }
}

class ExerciseSettings {
  final String subject;
  final String difficulty;
  final int questionCount;
  // Potentially add topics or other specific settings here later

  ExerciseSettings({
    required this.subject,
    required this.difficulty,
    required this.questionCount,
  });

  Map<String, dynamic> toJson() {
    return {
      'subject': subject,
      'difficulty': difficulty,
      'question_count': questionCount,
    };
  }
}
