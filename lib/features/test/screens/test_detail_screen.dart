import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/test_taking_provider.dart';
import '../../../core/theme/app_theme.dart';

class TestDetailScreen extends ConsumerWidget {
  final String testId;
  const TestDetailScreen({super.key, required this.testId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final testAsync = ref.watch(testDetailProvider(testId));
    final questionsAsync = ref.watch(testQuestionsProvider(testId));

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: testAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primary)),
        error: (e, _) => Center(child: Text('Қате: $e')),
        data: (test) {
          if (test == null) return const Center(child: Text('Тест табылмады'));
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                backgroundColor: AppTheme.primary,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
                  onPressed: () => context.pop(),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF3B5BDB), Color(0xFF4C6EF5)],
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 90, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(test.categoryName,
                              style: const TextStyle(color: Colors.white, fontSize: 12)),
                        ),
                        const SizedBox(height: 8),
                        Text(test.title,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text('👨‍🏫 ${test.teacherName}',
                            style: const TextStyle(color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _InfoCard(icon: Icons.help_outline, label: 'Сұрақтар',
                              value: '${test.questionCount}', color: AppTheme.primary),
                          const SizedBox(width: 10),
                          _InfoCard(icon: Icons.timer_outlined, label: 'Уақыт',
                              value: '${test.durationMinutes} мин', color: AppTheme.warning),
                          const SizedBox(width: 10),
                          _InfoCard(icon: Icons.star_outline, label: 'Максималды',
                              value: '${test.maxScore} балл', color: AppTheme.success),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text('Тест туралы',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary)),
                      const SizedBox(height: 8),
                      Text(test.description,
                          style: TextStyle(fontSize: 15, color: AppTheme.textSecondary, height: 1.5)),
                      const SizedBox(height: 20),
                      const Text('Ережелер',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary)),
                      const SizedBox(height: 10),
                      const _RuleItem(icon: Icons.timer_outlined,
                          text: 'Əр сұрақтың дұрыс жауабын таңдаңыз'),
                      const _RuleItem(icon: Icons.swap_horiz_rounded,
                          text: 'Сұрақтар арасында еркін жүре аласыз'),
                      const _RuleItem(icon: Icons.warning_amber_outlined,
                          text: 'Уақыт бітсе тест автоматты тапсырылады'),
                      const _RuleItem(icon: Icons.bar_chart_rounded,
                          text: 'Нəтиже бірден көрсетіледі'),
                      const SizedBox(height: 32),
                      questionsAsync.when(
                        data: (questions) => ElevatedButton(
                          onPressed: questions.isEmpty
                              ? null
                              : () => context.push('/test/$testId/take'),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.play_arrow_rounded, size: 22),
                              SizedBox(width: 8),
                              Text('Тестті бастау', style: TextStyle(fontSize: 16)),
                            ],
                          ),
                        ),
                        loading: () => ElevatedButton(
                          onPressed: null,
                          child: const SizedBox(height: 20, width: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                        ),
                        error: (_, __) => const Text('Сұрақтар жүктелмеді'),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _InfoCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.border)),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary)),
            Text(label, style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _RuleItem extends StatelessWidget {
  final IconData icon;
  final String text;
  const _RuleItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppTheme.primary),
          const SizedBox(width: 10),
          Expanded(child: Text(text,
              style: TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.4))),
        ],
      ),
    );
  }
}
