import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/question_model.dart';
import '../models/test_model.dart';
import '../providers/test_taking_provider.dart';
import '../../../core/theme/app_theme.dart';

class TestTakingScreen extends ConsumerWidget {
  final String testId;
  const TestTakingScreen({super.key, required this.testId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final testAsync = ref.watch(testDetailProvider(testId));
    final questionsAsync = ref.watch(testQuestionsProvider(testId));

    return questionsAsync.when(
      loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator(color: AppTheme.primary))),
      error: (e, _) => Scaffold(body: Center(child: Text('Қате: $e'))),
      data: (questions) {
        if (questions.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Тест')),
            body: const Center(child: Text('Сұрақтар əлі қосылмаған')),
          );
        }
        return testAsync.when(
          loading: () => const Scaffold(
              body: Center(child: CircularProgressIndicator(color: AppTheme.primary))),
          error: (e, _) => Scaffold(body: Center(child: Text('Қате: $e'))),
          data: (test) {
            if (test == null) {
              return Scaffold(
                appBar: AppBar(title: const Text('Тест')),
                body: const Center(child: Text('Тест табылмады')),
              );
            }
            return _TestBody(testId: testId, test: test, questions: questions);
          },
        );
      },
    );
  }
}

class _TestBody extends ConsumerWidget {
  final String testId;
  final TestModel test;
  final List<Question> questions;
  const _TestBody(
      {required this.testId, required this.test, required this.questions});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args = testTakingArgs(test: test, questions: questions);
    final session = ref.watch(testTakingProvider(args));
    final notifier = ref.watch(testTakingProvider(args).notifier);

    // Нəтиже бетіне өту
    if (session.isFinished) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.pushReplacement('/test/$testId/result');
        }
      });
    }

    final q = questions[session.currentIndex];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final leave = await _showExitDialog(context);
        if (leave && context.mounted) context.pop();
      },
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: SafeArea(
          child: Column(
            children: [
              // ── Жоғарғы бар ──────────────────────────────
              _TopBar(
                session: session,
                testTitle: test.title,
                onExit: () async {
                  final leave = await _showExitDialog(context);
                  if (leave && context.mounted) context.pop();
                },
              ),

              // ── Прогресс ─────────────────────────────────
              _ProgressBar(
                current: session.currentIndex + 1,
                total: questions.length,
                answeredCount: session.answers.length,
              ),

              // ── Сұрақ мазмұны ─────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Нөмір + балл
                      Row(
                        children: [
                          _chip(
                            'Сұрақ ${session.currentIndex + 1} / ${questions.length}',
                            AppTheme.primary,
                          ),
                          const Spacer(),
                          _chip('${q.points} балл', AppTheme.success),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Сұрақ мəтіні
                      Text(
                        q.text,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),

                      if (q.type == QuestionType.multipleChoice)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            '💡 Бірнеше дұрыс жауап болуы мүмкін',
                            style: TextStyle(
                                fontSize: 12, color: AppTheme.textSecondary),
                          ),
                        ),

                      const SizedBox(height: 12),

                      // Жауап нұсқалары
                      ...q.options.asMap().entries.map((entry) {
                        final i = entry.key;
                        final option = entry.value;
                        final selected =
                            session.answers[q.id]?.contains(option.id) ?? false;

                        return _AnswerOption(
                          index: i,
                          option: option,
                          isSelected: selected,
                          questionType: q.type,
                          onTap: () {
                            if (q.type == QuestionType.multipleChoice) {
                              notifier.toggleMultipleAnswer(q.id, option.id);
                            } else {
                              notifier.selectSingleAnswer(q.id, option.id);
                            }
                          },
                        );
                      }),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),

              // ── Навигация ─────────────────────────────────
              _BottomNavigation(
                session: session,
                totalQuestions: questions.length,
                onPrev: notifier.previousQuestion,
                onNext: notifier.nextQuestion,
                onSubmit: () => _showSubmitDialog(
                    context, notifier, session, questions.length),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 13, color: color, fontWeight: FontWeight.w500)),
    );
  }

  Future<bool> _showExitDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Тестен шығу'),
            content: const Text(
                'Тестен шықсаңыз барлық жауаптарыңыз жоғалады. Шығасыз ба?'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Жоқ')),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: AppTheme.error),
                child: const Text('Шығу'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showSubmitDialog(
      BuildContext context,
      TestTakingNotifier notifier,
      TestTakingState session,
      int total,
      ) {
    // session.answers.length арқылы жауап берілген сұрақтардың санын аламыз
    final answeredCount = session.answers.length;
    final unanswered = total - answeredCount;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Тестті тапсыру'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Осы жерде жоғарыда есептелген answeredCount айнымалысын қолданамыз
            Text('Жауап берілді: $answeredCount / $total'),
            if (unanswered > 0) ...[
              const SizedBox(height: 8),
              Text(
                '⚠️ $unanswered сұраққа жауап берілмеді!',
                style: TextStyle(
                  color: AppTheme.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            const SizedBox(height: 8),
            const Text('Тапсыруды растайсыз ба?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Болдырмау'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              notifier.submitTest();
            },
            child: const Text('Тапсыру'),
          ),
        ],
      ),
    );
  }
}

// ── Жоғарғы бар ───────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final TestTakingState session;
  final String testTitle;
  final VoidCallback onExit;
  const _TopBar(
      {required this.session,
      required this.testTitle,
      required this.onExit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: AppTheme.surface,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: AppTheme.textSecondary),
            onPressed: onExit,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              testTitle,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          // Таймер
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: session.isTimeWarning
                  ? AppTheme.error.withOpacity(0.1)
                  : AppTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(Icons.timer_outlined,
                    size: 16,
                    color: session.isTimeWarning
                        ? AppTheme.error
                        : AppTheme.primary),
                const SizedBox(width: 4),
                Text(
                  session.formattedTime,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: session.isTimeWarning
                        ? AppTheme.error
                        : AppTheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Прогресс бар ──────────────────────────────────────────
class _ProgressBar extends StatelessWidget {
  final int current;
  final int total;
  final int answeredCount;
  const _ProgressBar(
      {required this.current,
      required this.total,
      required this.answeredCount});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LinearProgressIndicator(
          value: current / total,
          backgroundColor: AppTheme.border,
          color: AppTheme.primary,
          minHeight: 4,
        ),
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: [
              Text('$current / $total сұрақ',
                  style: TextStyle(
                      fontSize: 12, color: AppTheme.textSecondary)),
              const Spacer(),
              Text('Жауап берілді: $answeredCount',
                  style: TextStyle(
                      fontSize: 12, color: AppTheme.textSecondary)),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Жауап нұсқасы ─────────────────────────────────────────
class _AnswerOption extends StatelessWidget {
  final int index;
  final AnswerOption option;
  final bool isSelected;
  final QuestionType questionType;
  final VoidCallback onTap;
  const _AnswerOption({
    required this.index,
    required this.option,
    required this.isSelected,
    required this.questionType,
    required this.onTap,
  });

  static const _letters = ['A', 'B', 'C', 'D', 'E', 'F'];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary.withOpacity(0.06)
              : AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primary
                    : AppTheme.background,
                borderRadius:
                    questionType == QuestionType.multipleChoice
                        ? BorderRadius.circular(8)
                        : BorderRadius.circular(18),
                border: Border.all(
                  color: isSelected ? AppTheme.primary : AppTheme.border,
                ),
              ),
              alignment: Alignment.center,
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 18)
                  : Text(
                      index < _letters.length
                          ? _letters[index]
                          : '${index + 1}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textSecondary,
                      ),
                    ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                option.text,
                style: TextStyle(
                  fontSize: 15,
                  color: isSelected
                      ? AppTheme.textPrimary
                      : AppTheme.textSecondary,
                  fontWeight: isSelected
                      ? FontWeight.w500
                      : FontWeight.w400,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Төменгі навигация ─────────────────────────────────────
class _BottomNavigation extends StatelessWidget {
  final TestTakingState session;
  final int totalQuestions;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onSubmit;
  const _BottomNavigation({
    required this.session,
    required this.totalQuestions,
    required this.onPrev,
    required this.onNext,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final isLast = session.currentIndex == totalQuestions - 1;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(top: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        children: [
          if (session.currentIndex > 0)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onPrev,
                icon: const Icon(Icons.arrow_back_ios_rounded, size: 16),
                label: const Text('Алдыңғы'),
                style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14)),
              ),
            ),
          if (session.currentIndex > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: isLast ? onSubmit : onNext,
              icon: Icon(
                  isLast
                      ? Icons.check_circle_outline
                      : Icons.arrow_forward_ios_rounded,
                  size: 16),
              label: Text(isLast ? 'Тапсыру' : 'Келесі'),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isLast ? AppTheme.success : AppTheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
