// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exam_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExamModel _$ExamModelFromJson(Map<String, dynamic> json) => ExamModel(
  id: json['id'] as String,
  title: json['title'] as String,
  subject: json['subject'] as String,
  difficulty: json['difficulty'] as String,
  questionCount: (json['question_count'] as num).toInt(),
  questions:
      (json['questions'] as List<dynamic>)
          .map((e) => ExamQuestion.fromJson(e as Map<String, dynamic>))
          .toList(),
  createdAt: DateTime.parse(json['created_at'] as String),
  userId: json['user_id'] as String,
  timeLimit: (json['time_limit'] as num?)?.toInt(),
  isCompleted: json['is_completed'] as bool? ?? false,
  score: (json['score'] as num?)?.toInt(),
  completedAt:
      json['completed_at'] == null
          ? null
          : DateTime.parse(json['completed_at'] as String),
  updatedAt:
      json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$ExamModelToJson(ExamModel instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'subject': instance.subject,
  'difficulty': instance.difficulty,
  'question_count': instance.questionCount,
  'questions': instance.questions,
  'created_at': instance.createdAt.toIso8601String(),
  'user_id': instance.userId,
  'time_limit': instance.timeLimit,
  'is_completed': instance.isCompleted,
  'score': instance.score,
  'completed_at': instance.completedAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
};

ExamQuestion _$ExamQuestionFromJson(Map<String, dynamic> json) => ExamQuestion(
  id: json['id'] as String?,
  question: json['question'] as String,
  options: (json['options'] as List<dynamic>).map((e) => e as String).toList(),
  correctAnswer: (json['correct_answer'] as num).toInt(),
  explanation: json['explanation'] as String,
  type: json['type'] as String? ?? 'multiple_choice',
  userAnswer: json['user_answer'] as String?,
  isCorrect: json['is_correct'] as bool?,
);

Map<String, dynamic> _$ExamQuestionToJson(ExamQuestion instance) =>
    <String, dynamic>{
      'id': instance.id,
      'question': instance.question,
      'options': instance.options,
      'correct_answer': instance.correctAnswer,
      'explanation': instance.explanation,
      'type': instance.type,
      'user_answer': instance.userAnswer,
      'is_correct': instance.isCorrect,
    };

ExamSettings _$ExamSettingsFromJson(Map<String, dynamic> json) => ExamSettings(
  subject: json['subject'] as String,
  difficulty: json['difficulty'] as String,
  questionCount: (json['question_count'] as num).toInt(),
  timeLimit: (json['time_limit'] as num?)?.toInt(),
  topics: (json['topics'] as List<dynamic>).map((e) => e as String).toList(),
  questionType: json['question_type'] as String,
  documentContent: json['document_content'] as String?,
);

Map<String, dynamic> _$ExamSettingsToJson(ExamSettings instance) =>
    <String, dynamic>{
      'subject': instance.subject,
      'difficulty': instance.difficulty,
      'question_count': instance.questionCount,
      'time_limit': instance.timeLimit,
      'topics': instance.topics,
      'question_type': instance.questionType,
      'document_content': instance.documentContent,
    };
