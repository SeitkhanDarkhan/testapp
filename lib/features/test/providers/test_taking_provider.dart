import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/question_model.dart';
import '../models/test_model.dart';
import '../../auth/providers/auth_provider.dart'; // ✅ import қосылды

// Тест сұрақтарын жүктеу
final testQuestionsProvider =
    FutureProvider.family<List<Question>, String>((ref, testId) async {
  final firestore = ref.watch(firestoreProvider);
  final snap = await firestore
      .collection('tests')
      .doc(testId)
      .collection('questions')
      .orderBy('orderIndex') // ✅ 'order' → 'orderIndex' (сақталған өріс атымен сəйкес)
      .get();
  return snap.docs
      .map((d) => Question.fromMap({...d.data(), 'id': d.id}))
      .toList();
});

// Тест моделін жүктеу
final testDetailProvider =
    FutureProvider.family<TestModel?, String>((ref, testId) async {
  final firestore = ref.watch(firestoreProvider);
  final doc = await firestore.collection('tests').doc(testId).get();
  if (!doc.exists) return null;
  return TestModel.fromMap({...doc.data()!, 'id': doc.id});
});

// ── Тест өту күйі ──────────────────────────────────────────
class TestTakingState {
  final int currentIndex;
  final Map<String, List<String>> answers;
  final int remainingSeconds;
  final bool isFinished;
  final bool isSubmitting;
  final String? error;

  const TestTakingState({
    this.currentIndex = 0,
    this.answers = const {},
    this.remainingSeconds = 0,
    this.isFinished = false,
    this.isSubmitting = false,
    this.error,
  });

  TestTakingState copyWith({
    int? currentIndex,
    Map<String, List<String>>? answers,
    int? remainingSeconds,
    bool? isFinished,
    bool? isSubmitting,
    String? error,
  }) {
    return TestTakingState(
      currentIndex: currentIndex ?? this.currentIndex,
      answers: answers ?? this.answers,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isFinished: isFinished ?? this.isFinished,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
    );
  }

  String get formattedTime {
    final m = remainingSeconds ~/ 60;
    final s = remainingSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  bool get isTimeWarning => remainingSeconds <= 60;
}

// ── Notifier ───────────────────────────────────────────────
class TestTakingNotifier extends StateNotifier<TestTakingState> {
  final Ref _ref;
  final TestModel test;
  final List<Question> questions;
  final DateTime _startedAt;
  Timer? _timer;

  TestTakingNotifier({
    required Ref ref,
    required this.test,
    required this.questions,
  })  : _ref = ref,
        _startedAt = DateTime.now(),
        super(TestTakingState(
          remainingSeconds: test.durationMinutes * 60,
        )) {
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.remainingSeconds <= 1) {
        _timer?.cancel();
        submitTest();
      } else {
        state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
      }
    });
  }

  void selectSingleAnswer(String questionId, String optionId) {
    final newAnswers = Map<String, List<String>>.from(state.answers);
    newAnswers[questionId] = [optionId];
    state = state.copyWith(answers: newAnswers);
  }

  void toggleMultipleAnswer(String questionId, String optionId) {
    final newAnswers = Map<String, List<String>>.from(state.answers);
    final current = List<String>.from(newAnswers[questionId] ?? []);
    current.contains(optionId) ? current.remove(optionId) : current.add(optionId);
    newAnswers[questionId] = current;
    state = state.copyWith(answers: newAnswers);
  }

  void nextQuestion() {
    if (state.currentIndex < questions.length - 1) {
      state = state.copyWith(currentIndex: state.currentIndex + 1);
    }
  }

  void previousQuestion() {
    if (state.currentIndex > 0) {
      state = state.copyWith(currentIndex: state.currentIndex - 1);
    }
  }

  void goToQuestion(int index) {
    state = state.copyWith(currentIndex: index);
  }

  Future<void> submitTest() async {
    if (state.isSubmitting || state.isFinished) return;
    _timer?.cancel();
    state = state.copyWith(isSubmitting: true);

    try {
      final user = _ref.read(authStateProvider).valueOrNull;
      if (user == null) throw Exception('Пайдаланушы табылмады');

      // ✅ TestSession жоқ — балды осында есептейміз
      int earnedPoints = 0;
      int totalPoints = 0;
      int correctCount = 0;

      for (final q in questions) {
        totalPoints += q.points;
        final selected = state.answers[q.id] ?? [];
        final correctSet = Set<String>.from(q.correctAnswerIds);
        final selectedSet = Set<String>.from(selected);
        final isCorrect = selectedSet.isNotEmpty &&
            correctSet.difference(selectedSet).isEmpty &&
            selectedSet.difference(correctSet).isEmpty;
        if (isCorrect) {
          earnedPoints += q.points;
          correctCount++;
        }
      }

      final duration = DateTime.now().difference(_startedAt).inSeconds;
      final firestore = _ref.read(firestoreProvider);
      final resultRef = firestore.collection('results').doc();

      await resultRef.set({
        'id': resultRef.id,
        'testId': test.id,
        'testTitle': test.title,
        'studentId': user.uid,
        'score': earnedPoints,
        'maxScore': totalPoints,
        'durationSeconds': duration,
        'correctCount': correctCount,
        'wrongCount': questions.length - correctCount,
        'answers': state.answers,
        'completedAt': DateTime.now().millisecondsSinceEpoch,
      });

      state = state.copyWith(isFinished: true, isSubmitting: false);
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: 'Қате: ${e.toString()}');
    }
  }

  bool isAnswered(String questionId) =>
      (state.answers[questionId] ?? []).isNotEmpty;

  int get answeredCount => questions.where((q) => isAnswered(q.id)).length;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

// ── Provider factory ───────────────────────────────────────
// ── Provider factory ───────────────────────────────────────
final testTakingProvider = StateNotifierProvider.family<
    TestTakingNotifier, TestTakingState, _TestTakingArgs>(
      (ref, args) => TestTakingNotifier(
    ref: ref,
    test: args.test,
    questions: args.questions,
  ),
);

// ТҮЗЕТІЛГЕН КЛАСС (== және hashCode қосылды)
class _TestTakingArgs {
  final TestModel test;
  final List<Question> questions;

  const _TestTakingArgs({required this.test, required this.questions});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is _TestTakingArgs &&
              runtimeType == other.runtimeType &&
              test.id == other.test.id &&
              questions.length == other.questions.length;

  @override
  int get hashCode => test.id.hashCode ^ questions.length.hashCode;
}

_TestTakingArgs testTakingArgs({
  required TestModel test,
  required List<Question> questions,
}) =>
    _TestTakingArgs(test: test, questions: questions);