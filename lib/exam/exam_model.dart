import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

// No, no se puede quitar si usas json_serializable.
// La línea `part 'exam_model.g.dart';` es necesaria para que el código generado por json_serializable funcione correctamente.
// Si la quitas, obtendrás errores como "Target of URI hasn't been generated" o que no encuentra los métodos _$ExamModelFromJson, etc.
part 'exam_model.g.dart';

@JsonSerializable()
class ExamModel extends Equatable {
  final String id;
  final String title;
  final String subject;
  final String difficulty;
  @JsonKey(name: 'question_count')
  final int questionCount;
  final List<ExamQuestion> questions;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'user_id')
  final String userId;
  @JsonKey(name: 'time_limit')
  final int? timeLimit;
  @JsonKey(name: 'is_completed')
  final bool isCompleted;
  final int? score;
  @JsonKey(name: 'completed_at')
  final DateTime? completedAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  const ExamModel({
    required this.id,
    required this.title,
    required this.subject,
    required this.difficulty,
    required this.questionCount,
    required this.questions,
    required this.createdAt,
    required this.userId,
    this.timeLimit,
    this.isCompleted = false,
    this.score,
    this.completedAt,
    this.updatedAt,
  });

  factory ExamModel.fromJson(Map<String, dynamic> json) =>
      _$ExamModelFromJson(json);
  Map<String, dynamic> toJson() => _$ExamModelToJson(this);

  ExamModel copyWith({
    String? id,
    String? title,
    String? subject,
    String? difficulty,
    int? questionCount,
    List<ExamQuestion>? questions,
    DateTime? createdAt,
    String? userId,
    int? timeLimit,
    bool? isCompleted,
    int? score,
    DateTime? completedAt,
    DateTime? updatedAt,
  }) {
    return ExamModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subject: subject ?? this.subject,
      difficulty: difficulty ?? this.difficulty,
      questionCount: questionCount ?? this.questionCount,
      questions: questions ?? this.questions,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
      timeLimit: timeLimit ?? this.timeLimit,
      isCompleted: isCompleted ?? this.isCompleted,
      score: score ?? this.score,
      completedAt: completedAt ?? this.completedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Métodos de utilidad
  bool get hasTimeLimit => timeLimit != null && timeLimit! > 0;

  double get scorePercentage => score != null ? score! / 100.0 : 0.0;

  String get formattedScore => score != null ? '$score%' : 'N/A';

  Duration? get timeLimitDuration =>
      timeLimit != null ? Duration(minutes: timeLimit!) : null;

  int get answeredQuestions => questions.where((q) => q.hasUserAnswer).length;

  int get correctAnswers => questions.where((q) => q.isCorrect == true).length;

  bool get isFullyAnswered => answeredQuestions == questionCount;

  String get difficultyLevel {
    switch (difficulty.toLowerCase()) {
      case 'básico':
        return '⭐';
      case 'intermedio':
        return '⭐⭐';
      case 'avanzado':
        return '⭐⭐⭐';
      case 'experto':
        return '⭐⭐⭐⭐';
      default:
        return '⭐';
    }
  }

  @override
  List<Object?> get props => [
    id,
    title,
    subject,
    difficulty,
    questionCount,
    questions,
    createdAt,
    userId,
    timeLimit,
    isCompleted,
    score,
    completedAt,
    updatedAt,
  ];
}

@JsonSerializable()
class ExamQuestion extends Equatable {
  final String id;
  final String question;
  final List<String> options;
  @JsonKey(name: 'correct_answer')
  final int correctAnswer;
  final String explanation;
  final String type;
  @JsonKey(name: 'user_answer')
  final String? userAnswer;
  @JsonKey(name: 'is_correct')
  final bool? isCorrect;

  const ExamQuestion({
    String? id,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    this.type = 'multiple_choice',
    this.userAnswer,
    this.isCorrect,
  }) : id = id ?? '';

  factory ExamQuestion.fromJson(Map<String, dynamic> json) =>
      _$ExamQuestionFromJson(json);
  Map<String, dynamic> toJson() => _$ExamQuestionToJson(this);

  ExamQuestion copyWith({
    String? id,
    String? question,
    List<String>? options,
    int? correctAnswer,
    String? explanation,
    String? type,
    String? userAnswer,
    bool? isCorrect,
  }) {
    return ExamQuestion(
      id: id ?? this.id,
      question: question ?? this.question,
      options: options ?? this.options,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      explanation: explanation ?? this.explanation,
      type: type ?? this.type,
      userAnswer: userAnswer ?? this.userAnswer,
      isCorrect: isCorrect ?? this.isCorrect,
    );
  }

  // Métodos de utilidad
  bool get hasUserAnswer => userAnswer != null && userAnswer!.isNotEmpty;

  String get correctOptionText =>
      correctAnswer >= 0 && correctAnswer < options.length
          ? options[correctAnswer]
          : '';

  String get userAnswerText {
    if (userAnswer == null) return '';

    if (type == 'multiple_choice') {
      final index = int.tryParse(userAnswer!);
      return index != null && index >= 0 && index < options.length
          ? options[index]
          : userAnswer!;
    }

    return userAnswer!;
  }

  bool get isMultipleChoice => type == 'multiple_choice';
  bool get isOpenEnded => type == 'open_ended';
  bool get isTrueFalse => type == 'true_false';

  ExamQuestion withAnswer(String answer) {
    bool? correct;

    if (isMultipleChoice) {
      final answerIndex = int.tryParse(answer);
      correct = answerIndex == correctAnswer;
    } else {
      // Para preguntas abiertas, aquí se podría implementar lógica más compleja
      correct = answer.toLowerCase().trim() == explanation.toLowerCase().trim();
    }

    return copyWith(userAnswer: answer, isCorrect: correct);
  }

  @override
  List<Object?> get props => [
    id,
    question,
    options,
    correctAnswer,
    explanation,
    type,
    userAnswer,
    isCorrect,
  ];
}

@JsonSerializable()
class ExamSettings extends Equatable {
  final String subject;
  final String difficulty;
  @JsonKey(name: 'question_count')
  final int questionCount;
  @JsonKey(name: 'time_limit')
  final int? timeLimit;
  final List<String> topics;
  @JsonKey(name: 'question_type')
  final String questionType;
  @JsonKey(name: 'document_content')
  final String? documentContent;

  const ExamSettings({
    required this.subject,
    required this.difficulty,
    required this.questionCount,
    this.timeLimit,
    required this.topics,
    required this.questionType,
    this.documentContent,
  });

  factory ExamSettings.fromJson(Map<String, dynamic> json) =>
      _$ExamSettingsFromJson(json);
  Map<String, dynamic> toJson() => _$ExamSettingsToJson(this);

  // Validaciones
  bool get isValid {
    return questionCount > 0 &&
        questionCount <= 50 &&
        (timeLimit == null || (timeLimit! > 0 && timeLimit! <= 180)) &&
        (topics.isNotEmpty || hasDocumentContent);
  }

  bool get hasDocumentContent =>
      documentContent != null && documentContent!.isNotEmpty;

  String get validationError {
    if (questionCount <= 0 || questionCount > 50) {
      return 'El número de preguntas debe estar entre 1 y 50';
    }
    if (timeLimit != null && (timeLimit! <= 0 || timeLimit! > 180)) {
      return 'El límite de tiempo debe estar entre 1 y 180 minutos';
    }
    if (topics.isEmpty && !hasDocumentContent) {
      return 'Debe seleccionar al menos un tema o subir un documento';
    }
    return '';
  }

  @override
  List<Object?> get props => [
    subject,
    difficulty,
    questionCount,
    timeLimit,
    topics,
    questionType,
    documentContent,
  ];
}

// Enums para mayor type safety
enum ExamDifficulty {
  basico('Básico'),
  intermedio('Intermedio'),
  avanzado('Avanzado'),
  experto('Experto');

  const ExamDifficulty(this.displayName);
  final String displayName;
}

enum QuestionType {
  multipleChoice('multiple_choice', 'Opción Múltiple'),
  openEnded('open_ended', 'Pregunta Abierta'),
  trueFalse('true_false', 'Verdadero/Falso');

  const QuestionType(this.value, this.displayName);
  final String value;
  final String displayName;
}

// Extensiones útiles
extension ExamModelExtensions on ExamModel {
  String get statusText {
    if (isCompleted) {
      return 'Completado - $formattedScore';
    } else if (answeredQuestions > 0) {
      return 'En progreso ($answeredQuestions/$questionCount)';
    }
    return 'No iniciado';
  }

  Color get statusColor {
    if (isCompleted) {
      if (score != null && score! >= 70) return Colors.green;
      if (score != null && score! >= 50) return Colors.orange;
      return Colors.red;
    }
    return Colors.blue;
  }
}
