enum TestCategory {
  math,
  kazakh,
  russian,
  english,
  history,
  science,
  other,
}

enum TestStatus { active, draft, archived }

class TestModel {
  final String id;
  final String title;
  final String description;
  final String teacherId;
  final String teacherName;
  final TestCategory category;
  final TestStatus status;
  final int questionCount;
  final int durationMinutes;
  final int maxScore;
  final DateTime createdAt;
  final List<String> allowedStudentIds; // бос болса — барлығына ашық

  const TestModel({
    required this.id,
    required this.title,
    required this.description,
    required this.teacherId,
    required this.teacherName,
    required this.category,
    required this.status,
    required this.questionCount,
    required this.durationMinutes,
    required this.maxScore,
    required this.createdAt,
    this.allowedStudentIds = const [],
  });

  factory TestModel.fromMap(Map<String, dynamic> map) {
    return TestModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      teacherId: map['teacherId'] as String,
      teacherName: map['teacherName'] as String,
      category: TestCategory.values.firstWhere(
        (c) => c.name == map['category'],
        orElse: () => TestCategory.other,
      ),
      status: TestStatus.values.firstWhere(
        (s) => s.name == map['status'],
        orElse: () => TestStatus.draft,
      ),
      questionCount: map['questionCount'] as int,
      durationMinutes: map['durationMinutes'] as int,
      maxScore: map['maxScore'] as int,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      allowedStudentIds: List<String>.from(map['allowedStudentIds'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'teacherId': teacherId,
      'teacherName': teacherName,
      'category': category.name,
      'status': status.name,
      'questionCount': questionCount,
      'durationMinutes': durationMinutes,
      'maxScore': maxScore,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'allowedStudentIds': allowedStudentIds,
    };
  }

  String get categoryName {
    switch (category) {
      case TestCategory.math: return 'Математика';
      case TestCategory.kazakh: return 'Қазақ тілі';
      case TestCategory.russian: return 'Орыс тілі';
      case TestCategory.english: return 'Ағылшын тілі';
      case TestCategory.history: return 'Тарих';
      case TestCategory.science: return 'Жаратылыстану';
      case TestCategory.other: return 'Басқа';
    }
  }

  String get statusName {
    switch (status) {
      case TestStatus.active: return 'Белсенді';
      case TestStatus.draft: return 'Жоба';
      case TestStatus.archived: return 'Мұрағат';
    }
  }
}

// Тест нәтижесі
class TestResult {
  final String id;
  final String testId;
  final String testTitle;
  final String studentId;
  final int score;
  final int maxScore;
  final int durationSeconds;
  final DateTime completedAt;

  const TestResult({
    required this.id,
    required this.testId,
    required this.testTitle,
    required this.studentId,
    required this.score,
    required this.maxScore,
    required this.durationSeconds,
    required this.completedAt,
  });

  double get percentage => maxScore > 0 ? (score / maxScore * 100) : 0;

  String get grade {
    if (percentage >= 90) return '5';
    if (percentage >= 75) return '4';
    if (percentage >= 60) return '3';
    return '2';
  }

  factory TestResult.fromMap(Map<String, dynamic> map) {
    return TestResult(
      id: map['id'] as String,
      testId: map['testId'] as String,
      testTitle: map['testTitle'] as String,
      studentId: map['studentId'] as String,
      score: map['score'] as int,
      maxScore: map['maxScore'] as int,
      durationSeconds: map['durationSeconds'] as int,
      completedAt: DateTime.fromMillisecondsSinceEpoch(map['completedAt'] as int),
    );
  }
}
