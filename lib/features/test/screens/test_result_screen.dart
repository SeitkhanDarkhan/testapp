import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/question_model.dart';
import '../models/test_model.dart';
import '../providers/test_taking_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';

// Firestore-дан соңғы нәтижені алатын провайдер
final latestResultProvider =
    FutureProvider.family<Map<String, dynamic>?, String>((ref, testId) async {
  final firestore = ref.watch(firestoreProvider);
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return null;

  final snap = await firestore
      .collection('results')
      .where('testId', isEqualTo: testId)
      .where('studentId', isEqualTo: user.uid)
      .limit(5)
      .get();

  if (snap.docs.isEmpty) return null;
  // Соңғы нәтижені клиент жағынан сортаймыз
  final sorted = snap.docs.toList()
    ..sort((a, b) =>
        (b.data()['completedAt'] as int)
            .compareTo(a.data()['completedAt'] as int));
  return sorted.first.data();
});

class TestResultScreen extends ConsumerWidget {
  final String testId;
  const TestResultScreen({super.key, required this.testId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final testAsync = ref.watch(testDetailProvider(testId));
    final questionsAsync = ref.watch(testQuestionsProvider(testId));
    final resultAsync = ref.watch(latestResultProvider(testId));

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: resultAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppTheme.primary)),
        error: (e, _) => Center(child: Text('Қате: $e')),
        data: (resultData) {
          return questionsAsync.when(
            loading: () => const Center(
                child: CircularProgressIndicator(color: AppTheme.primary)),
            error: (e, _) => Center(child: Text('Қате: $e')),
            data: (questions) {
              return testAsync.when(
                loading: () => const Center(
                    child:
                        CircularProgressIndicator(color: AppTheme.primary)),
                error: (e, _) => Center(child: Text('Қате: $e')),
                data: (test) {
                  if (test == null || questions.isEmpty || resultData == null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Нәтиже жүктелмеді'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => context.go('/home'),
                            child: const Text('Басты бетке'),
                          ),
                        ],
                      ),
                    );
                  }

                  // Нәтижені Firestore-дан аламыз
                  final int totalScore = resultData['score'] as int? ?? 0;
                  final int maxScore = resultData['maxScore'] as int? ?? 0;
                  final int correctCount =
                      resultData['correctCount'] as int? ?? 0;

                  // Жауаптарды Firestore-дан parse қыламыз
                  Map<String, List<String>> savedAnswers = {};
                  final rawAnswers = resultData['answers'];
                  if (rawAnswers is Map) {
                    rawAnswers.forEach((key, value) {
                      if (value is List) {
                        savedAnswers[key] =
                            value.map((e) => e.toString()).toList();
                      }
                    });
                  }

                  final percentage =
                      maxScore > 0 ? (totalScore / maxScore * 100) : 0.0;
                  final grade = percentage >= 90
                      ? '5'
                      : percentage >= 75
                          ? '4'
                          : percentage >= 60
                              ? '3'
                              : '2';

                  return SafeArea(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // ── Нәтиже header ──────────────────────
                          Container(
                            width: double.infinity,
                            padding:
                                const EdgeInsets.fromLTRB(20, 40, 20, 32),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: _gradeColors(grade),
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(_gradeEmoji(grade),
                                    style:
                                        const TextStyle(fontSize: 60)),
                                const SizedBox(height: 12),
                                Text(
                                  _gradeMessage(grade),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  test.title,
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 14),
                                ),
                                const SizedBox(height: 24),
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withOpacity(0.2),
                                  ),
                                  alignment: Alignment.center,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '${percentage.toStringAsFixed(0)}%',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 26,
                                            fontWeight: FontWeight.w800),
                                      ),
                                      Text('Баға: $grade',
                                          style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 12)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // ── Статистика ──────────────────────────
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                _StatBox(
                                    label: 'Балл',
                                    value: '$totalScore / $maxScore',
                                    icon: Icons.star_outline,
                                    color: AppTheme.warning),
                                const SizedBox(width: 10),
                                _StatBox(
                                    label: 'Дұрыс',
                                    value: '$correctCount',
                                    icon: Icons.check_circle_outline,
                                    color: AppTheme.success),
                                const SizedBox(width: 10),
                                _StatBox(
                                    label: 'Қате',
                                    value:
                                        '${questions.length - correctCount}',
                                    icon: Icons.cancel_outlined,
                                    color: AppTheme.error),
                              ],
                            ),
                          ),

                          // ── Жауаптар шолуы ──────────────────────
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Жауаптар шолуы',
                                    style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.textPrimary)),
                                const SizedBox(height: 12),
                                ...questions.asMap().entries.map((entry) {
                                  final i = entry.key;
                                  final q = entry.value;
                                  final selected =
                                      savedAnswers[q.id] ?? [];
                                  final correct = _isCorrect(q, selected);
                                  return _QuestionReviewCard(
                                    index: i + 1,
                                    question: q,
                                    selectedIds: selected,
                                    isCorrect: correct,
                                  );
                                }),
                                const SizedBox(height: 24),

                                ElevatedButton.icon(
                                  onPressed: () => context.go('/home'),
                                  icon: const Icon(Icons.home_rounded),
                                  label: const Text('Басты бетке'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primary,
                                    minimumSize:
                                        const Size(double.infinity, 52),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                OutlinedButton.icon(
                                  onPressed: () =>
                                      context.go('/test/$testId'),
                                  icon: const Icon(Icons.refresh_rounded),
                                  label: const Text('Қайта өту'),
                                  style: OutlinedButton.styleFrom(
                                    minimumSize:
                                        const Size(double.infinity, 52),
                                  ),
                                ),
                                const SizedBox(height: 32),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  bool _isCorrect(Question q, List<String> selected) {
    if (selected.isEmpty) return false;
    final correct = Set<String>.from(q.correctAnswerIds);
    final sel = Set<String>.from(selected);
    return correct.difference(sel).isEmpty && sel.difference(correct).isEmpty;
  }

  List<Color> _gradeColors(String grade) {
    switch (grade) {
      case '5':
        return [const Color(0xFF2F9E44), const Color(0xFF40C057)];
      case '4':
        return [const Color(0xFF2B8A3E), const Color(0xFF37B24D)];
      case '3':
        return [const Color(0xFFE67700), const Color(0xFFF59F00)];
      default:
        return [const Color(0xFFC92A2A), const Color(0xFFE03131)];
    }
  }

  String _gradeEmoji(String grade) {
    switch (grade) {
      case '5':
        return '🏆';
      case '4':
        return '🎉';
      case '3':
        return '👍';
      default:
        return '📚';
    }
  }

  String _gradeMessage(String grade) {
    switch (grade) {
      case '5':
        return 'Өте жақсы!';
      case '4':
        return 'Жақсы!';
      case '3':
        return 'Орташа';
      default:
        return 'Тырысыңыз!';
    }
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatBox(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(value,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary)),
            Text(label,
                style: TextStyle(
                    fontSize: 11, color: AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _QuestionReviewCard extends StatelessWidget {
  final int index;
  final Question question;
  final List<String> selectedIds;
  final bool isCorrect;
  const _QuestionReviewCard({
    required this.index,
    required this.question,
    required this.selectedIds,
    required this.isCorrect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCorrect
              ? AppTheme.success.withOpacity(0.4)
              : AppTheme.error.withOpacity(0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isCorrect
                  ? AppTheme.success.withOpacity(0.06)
                  : AppTheme.error.withOpacity(0.06),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(13)),
            ),
            child: Row(
              children: [
                Icon(
                  isCorrect
                      ? Icons.check_circle_rounded
                      : Icons.cancel_rounded,
                  color: isCorrect ? AppTheme.success : AppTheme.error,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '$index. ${question.text}',
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: question.options.map((opt) {
                final isSelected = selectedIds.contains(opt.id);
                final isCorrectOpt =
                    question.correctAnswerIds.contains(opt.id);
                Color? bg;
                Color borderColor = AppTheme.border;
                if (isCorrectOpt) {
                  bg = AppTheme.success.withOpacity(0.08);
                  borderColor = AppTheme.success;
                }
                if (isSelected && !isCorrectOpt) {
                  bg = AppTheme.error.withOpacity(0.08);
                  borderColor = AppTheme.error;
                }
                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: bg ?? AppTheme.background,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                          child: Text(opt.text,
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.textPrimary))),
                      if (isCorrectOpt)
                        Icon(Icons.check,
                            color: AppTheme.success, size: 16),
                      if (isSelected && !isCorrectOpt)
                        Icon(Icons.close,
                            color: AppTheme.error, size: 16),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
