import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../auth/providers/auth_provider.dart';
import '../../test/models/test_model.dart';
import '../../test/models/question_model.dart';

class CreateTestState {
  final String title;
  final String description;
  final TestCategory category;
  final int durationMinutes;
  final List<QuestionDraft> questions;
  final int currentStep;
  final bool isSaving;
  final String? error;

  const CreateTestState({
    this.title = '',
    this.description = '',
    this.category = TestCategory.other,
    this.durationMinutes = 30,
    this.questions = const [],
    this.currentStep = 0,
    this.isSaving = false,
    this.error,
  });

  int get totalScore => questions.fold(0, (sum, q) => sum + q.points);
  bool get step1Valid => title.trim().isNotEmpty && description.trim().isNotEmpty;
  bool get step2Valid =>
      questions.isNotEmpty &&
      questions.every((q) =>
          q.text.trim().isNotEmpty &&
          q.options.length >= 2 &&
          q.correctOptionIds.isNotEmpty);

  CreateTestState copyWith({
    String? title, String? description, TestCategory? category,
    int? durationMinutes, List<QuestionDraft>? questions,
    int? currentStep, bool? isSaving, String? error,
  }) => CreateTestState(
    title: title ?? this.title, description: description ?? this.description,
    category: category ?? this.category, durationMinutes: durationMinutes ?? this.durationMinutes,
    questions: questions ?? this.questions, currentStep: currentStep ?? this.currentStep,
    isSaving: isSaving ?? this.isSaving, error: error ?? this.error,
  );
}

class QuestionDraft {
  final String tempId;
  final String text;
  final QuestionType type;
  final List<OptionDraft> options;
  final List<String> correctOptionIds;
  final int points;

  const QuestionDraft({
    required this.tempId, this.text = '',
    this.type = QuestionType.singleChoice,
    this.options = const [], this.correctOptionIds = const [], this.points = 1,
  });

  QuestionDraft copyWith({
    String? text, QuestionType? type,
    List<OptionDraft>? options, List<String>? correctOptionIds, int? points,
  }) => QuestionDraft(
    tempId: tempId, text: text ?? this.text, type: type ?? this.type,
    options: options ?? this.options,
    correctOptionIds: correctOptionIds ?? this.correctOptionIds,
    points: points ?? this.points,
  );
}

class OptionDraft {
  final String tempId;
  final String text;
  const OptionDraft({required this.tempId, this.text = ''});
  OptionDraft copyWith({String? text}) => OptionDraft(tempId: tempId, text: text ?? this.text);
}

class CreateTestNotifier extends StateNotifier<CreateTestState> {
  final Ref _ref;
  CreateTestNotifier(this._ref) : super(const CreateTestState());

  void setTitle(String v) => state = state.copyWith(title: v);
  void setDescription(String v) => state = state.copyWith(description: v);
  void setCategory(TestCategory v) => state = state.copyWith(category: v);
  void setDuration(int v) => state = state.copyWith(durationMinutes: v);
  void goToStep(int step) => state = state.copyWith(currentStep: step);

  void addQuestion() {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    state = state.copyWith(questions: [
      ...state.questions,
      QuestionDraft(
        tempId: id,
        options: [
          OptionDraft(tempId: '${id}_a'),
          OptionDraft(tempId: '${id}_b'),
          OptionDraft(tempId: '${id}_c'),
          OptionDraft(tempId: '${id}_d'),
        ],
      ),
    ]);
  }

  void removeQuestion(String tempId) => state = state.copyWith(
    questions: state.questions.where((q) => q.tempId != tempId).toList(),
  );

  void updateQuestionText(String tempId, String text) => state = state.copyWith(
    questions: state.questions.map((q) => q.tempId == tempId ? q.copyWith(text: text) : q).toList(),
  );

  void updateQuestionType(String tempId, QuestionType type) => state = state.copyWith(
    questions: state.questions.map((q) => q.tempId == tempId ? q.copyWith(type: type, correctOptionIds: []) : q).toList(),
  );

  void updateQuestionPoints(String tempId, int points) => state = state.copyWith(
    questions: state.questions.map((q) => q.tempId == tempId ? q.copyWith(points: points) : q).toList(),
  );

  void updateOptionText(String questionId, String optionId, String text) => state = state.copyWith(
    questions: state.questions.map((q) {
      if (q.tempId != questionId) return q;
      return q.copyWith(options: q.options.map((o) => o.tempId == optionId ? o.copyWith(text: text) : o).toList());
    }).toList(),
  );

  void addOption(String questionId) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    state = state.copyWith(
      questions: state.questions.map((q) {
        if (q.tempId != questionId) return q;
        return q.copyWith(options: [...q.options, OptionDraft(tempId: id)]);
      }).toList(),
    );
  }

  void removeOption(String questionId, String optionId) => state = state.copyWith(
    questions: state.questions.map((q) {
      if (q.tempId != questionId) return q;
      return q.copyWith(
        options: q.options.where((o) => o.tempId != optionId).toList(),
        correctOptionIds: q.correctOptionIds.where((id) => id != optionId).toList(),
      );
    }).toList(),
  );

  void toggleCorrectAnswer(String questionId, String optionId) => state = state.copyWith(
    questions: state.questions.map((q) {
      if (q.tempId != questionId) return q;
      List<String> correct;
      if (q.type == QuestionType.multipleChoice) {
        correct = List.from(q.correctOptionIds);
        correct.contains(optionId) ? correct.remove(optionId) : correct.add(optionId);
      } else {
        correct = [optionId];
      }
      return q.copyWith(correctOptionIds: correct);
    }).toList(),
  );

  void moveUp(int i) {
    if (i <= 0) return;
    final list = List<QuestionDraft>.from(state.questions);
    final tmp = list[i]; list[i] = list[i - 1]; list[i - 1] = tmp;
    state = state.copyWith(questions: list);
  }

  void moveDown(int i) {
    if (i >= state.questions.length - 1) return;
    final list = List<QuestionDraft>.from(state.questions);
    final tmp = list[i]; list[i] = list[i + 1]; list[i + 1] = tmp;
    state = state.copyWith(questions: list);
  }

  Future<String?> saveTest({bool asDraft = false}) async {
    state = state.copyWith(isSaving: true, error: null);
    try {
      final firestore = _ref.read(firestoreProvider);
      final user = _ref.read(authStateProvider).valueOrNull;
      if (user == null) throw Exception('Пайдаланушы табылмады');

      final testRef = firestore.collection('tests').doc();
      await testRef.set({
        'id': testRef.id,
        'title': state.title.trim(),
        'description': state.description.trim(),
        'teacherId': user.uid,
        'teacherName': user.displayName ?? 'Мұғалім',
        'category': state.category.name,
        'status': asDraft ? 'draft' : 'active',
        'questionCount': state.questions.length,
        'durationMinutes': state.durationMinutes,
        'maxScore': state.totalScore,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'allowedStudentIds': [],
      });

      final batch = firestore.batch();
      for (int i = 0; i < state.questions.length; i++) {
        final q = state.questions[i];
        final qRef = testRef.collection('questions').doc();
        batch.set(qRef, {
          'id': qRef.id, 'testId': testRef.id,
          'text': q.text.trim(), 'type': q.type.name,
          'options': q.options.map((o) => {'id': o.tempId, 'text': o.text.trim()}).toList(),
          'correctAnswerIds': q.correctOptionIds,
          'points': q.points, 'orderIndex': i, 'imageUrl': null,
        });
      }
      await batch.commit();
      state = state.copyWith(isSaving: false);
      return testRef.id;
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      return null;
    }
  }

  void reset() => state = const CreateTestState();
}

final createTestProvider = StateNotifierProvider.autoDispose<CreateTestNotifier, CreateTestState>(
  (ref) => CreateTestNotifier(ref),
);
