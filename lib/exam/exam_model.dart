class ExamModel {
  final String id;
  final String title;
  final String subject;
  final String difficulty;
  final List<Question> questions;
  final List<Answer> answers;
  final DateTime createdAt;
  final String userId;

  ExamModel({
    required this.id,
    required this.title,
    required this.subject,
    required this.difficulty,
    required this.questions,
    required this.answers,
    required this.createdAt,
    required this.userId,
  });

  factory ExamModel.fromJson(Map<String, dynamic> json) {
    return ExamModel(
      id: json['id'],
      title: json['title'],
      subject: json['subject'],
      difficulty: json['difficulty'],
      questions:
          (json['questions'] as List).map((q) => Question.fromJson(q)).toList(),
      answers:
          (json['answers'] as List).map((a) => Answer.fromJson(a)).toList(),
      createdAt: DateTime.parse(json['created_at']),
      userId: json['user_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subject': subject,
      'difficulty': difficulty,
      'questions': questions.map((q) => q.toJson()).toList(),
      'answers': answers.map((a) => a.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'user_id': userId,
    };
  }
}

class Question {
  final int number;
  final String type; // 'multiple_choice', 'true_false', 'short_answer', 'essay'
  final String question;
  final List<String>? options; // Para preguntas de opción múltiple
  final String? correctAnswer;

  Question({
    required this.number,
    required this.type,
    required this.question,
    this.options,
    this.correctAnswer,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      number: json['number'],
      type: json['type'],
      question: json['question'],
      options:
          json['options'] != null ? List<String>.from(json['options']) : null,
      correctAnswer: json['correct_answer'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'type': type,
      'question': question,
      'options': options,
      'correct_answer': correctAnswer,
    };
  }
}

class Answer {
  final int questionNumber;
  final String answer;
  final String explanation;

  Answer({
    required this.questionNumber,
    required this.answer,
    required this.explanation,
  });

  factory Answer.fromJson(Map<String, dynamic> json) {
    return Answer(
      questionNumber: json['question_number'],
      answer: json['answer'],
      explanation: json['explanation'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question_number': questionNumber,
      'answer': answer,
      'explanation': explanation,
    };
  }
}

class ExamResult {
  final String id;
  final String examId;
  final String userId;
  final Map<int, String> userAnswers;
  final double score;
  final DateTime completedAt;

  ExamResult({
    required this.id,
    required this.examId,
    required this.userId,
    required this.userAnswers,
    required this.score,
    required this.completedAt,
  });

  factory ExamResult.fromJson(Map<String, dynamic> json) {
    return ExamResult(
      id: json['id'],
      examId: json['exam_id'],
      userId: json['user_id'],
      userAnswers: Map<int, String>.from(json['user_answers']),
      score: json['score'].toDouble(),
      completedAt: DateTime.parse(json['completed_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'exam_id': examId,
      'user_id': userId,
      'user_answers': userAnswers,
      'score': score,
      'completed_at': completedAt.toIso8601String(),
    };
  }
}
