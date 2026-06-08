enum QuestionType {
  singleChoice,
  multipleChoice,
  trueFalse,
}

class Question {
  final String id;
  final String testId;
  final String text;
  final QuestionType type;
  final List<AnswerOption> options;
  final List<String> correctAnswerIds;
  final int points;
  final int orderIndex;
  final String? imageUrl;

  const Question({
    required this.id,
    required this.testId,
    required this.text,
    required this.type,
    required this.options,
    required this.correctAnswerIds,
    required this.points,
    required this.orderIndex,
    this.imageUrl,
  });

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id'] as String,
      testId: map['testId'] as String,
      text: map['text'] as String,
      type: QuestionType.values.firstWhere(
        (t) => t.name == map['type'],
        orElse: () => QuestionType.singleChoice,
      ),
      options: (map['options'] as List)
          .map((o) => AnswerOption.fromMap(o as Map<String, dynamic>))
          .toList(),
      correctAnswerIds: List<String>.from(map['correctAnswerIds']),
      points: map['points'] as int,
      orderIndex: map['orderIndex'] as int,
      imageUrl: map['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'testId': testId,
        'text': text,
        'type': type.name,
        'options': options.map((o) => o.toMap()).toList(),
        'correctAnswerIds': correctAnswerIds,
        'points': points,
        'orderIndex': orderIndex,
        'imageUrl': imageUrl,
      };
}

class AnswerOption {
  final String id;
  final String text;

  const AnswerOption({required this.id, required this.text});

  factory AnswerOption.fromMap(Map<String, dynamic> map) =>
      AnswerOption(id: map['id'] as String, text: map['text'] as String);

  Map<String, dynamic> toMap() => {'id': id, 'text': text};
}

class StudentAnswer {
  final String questionId;
  final List<String> selectedOptionIds;
  final bool isCorrect;
  final int earnedPoints;

  const StudentAnswer({
    required this.questionId,
    required this.selectedOptionIds,
    required this.isCorrect,
    required this.earnedPoints,
  });

  Map<String, dynamic> toMap() => {
        'questionId': questionId,
        'selectedOptionIds': selectedOptionIds,
        'isCorrect': isCorrect,
        'earnedPoints': earnedPoints,
      };
}
