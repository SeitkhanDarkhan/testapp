import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/models/app_user.dart';
import '../../auth/providers/auth_provider.dart';
import '../../test/providers/test_provider.dart';
import '../../test/models/test_model.dart';
import '../../../core/theme/app_theme.dart';

class StudentHomeScreen extends ConsumerStatefulWidget {
  final AppUser user;
  const StudentHomeScreen({super.key, required this.user});

  @override
  ConsumerState<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends ConsumerState<StudentHomeScreen> {
  int _selectedTab = 0; // 0: Тесттер, 1: Нәтижелер
  TestCategory? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final testsAsync = ref.watch(activeTestsProvider);
    final resultsAsync = ref.watch(studentResultsProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          // AppBar
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: AppTheme.primary,
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.logout_rounded, color: Colors.white),
                onPressed: () async {
                  await ref.read(authServiceProvider).signOut();
                  if (context.mounted) context.go('/login');
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF3B5BDB), Color(0xFF4C6EF5)],
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 80, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Сәлем, ${widget.user.displayName.split(' ').first}! 👋',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Бүгін қандай тест өтесің?',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              children: [
                // Статистика карточкалары
                resultsAsync.when(
                  data: (results) => _buildStatsRow(results),
                  loading: () => const SizedBox(height: 80),
                  error: (_, __) => const SizedBox(),
                ),

                // Tab bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _tabButton('Тесттер', 0),
                      const SizedBox(width: 8),
                      _tabButton('Нәтижелерім', 1),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                if (_selectedTab == 0) ...[
                  // Категория фильтрі
                  _buildCategoryFilter(),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          ),

          // Контент
          if (_selectedTab == 0)
            testsAsync.when(
              data: (tests) {
                final filtered = _selectedCategory == null
                    ? tests
                    : tests.where((t) => t.category == _selectedCategory).toList();
                if (filtered.isEmpty) {
                  return SliverToBoxAdapter(child: _buildEmpty('Тест табылмады'));
                }
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => _TestCard(test: filtered[i]),
                      childCount: filtered.length,
                    ),
                  ),
                );
              },
              loading: () => const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
              ),
              error: (e, _) => SliverToBoxAdapter(
                child: Center(child: Text('Қате: $e')),
              ),
            )
          else
            resultsAsync.when(
              data: (results) {
                if (results.isEmpty) {
                  return SliverToBoxAdapter(
                    child: _buildEmpty('Әлі тест өтпегенсің'),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => _ResultCard(result: results[i]),
                      childCount: results.length,
                    ),
                  ),
                );
              },
              loading: () => const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
              ),
              error: (e, _) =>
                  SliverToBoxAdapter(child: Center(child: Text('Қате: $e'))),
            ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(List<TestResult> results) {
    final avg = results.isEmpty
        ? 0.0
        : results.map((r) => r.percentage).reduce((a, b) => a + b) /
            results.length;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _StatCard(
            label: 'Өткен тесттер',
            value: '${results.length}',
            icon: Icons.check_circle_outline,
            color: AppTheme.success,
          ),
          const SizedBox(width: 10),
          _StatCard(
            label: 'Орташа балл',
            value: '${avg.toStringAsFixed(0)}%',
            icon: Icons.bar_chart_rounded,
            color: AppTheme.primary,
          ),
          const SizedBox(width: 10),
          _StatCard(
            label: 'Жетістік',
            value: results.isEmpty
                ? '-'
                : results.first.grade == '5'
                    ? '🏆'
                    : '📚',
            icon: Icons.emoji_events_outlined,
            color: AppTheme.warning,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final categories = [null, ...TestCategory.values];
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final cat = categories[i];
          final isSelected = _selectedCategory == cat;
          final label = cat == null ? 'Барлығы' : _categoryName(cat);
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primary : AppTheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppTheme.primary : AppTheme.border,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : AppTheme.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _tabButton(String label, int index) {
    final isActive = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? AppTheme.primary : AppTheme.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isActive ? AppTheme.primary : AppTheme.border,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.white : AppTheme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty(String msg) {
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, size: 56, color: AppTheme.border),
          const SizedBox(height: 12),
          Text(msg, style: TextStyle(color: AppTheme.textSecondary)),
        ],
      ),
    );
  }

  String _categoryName(TestCategory c) {
    switch (c) {
      case TestCategory.math: return 'Математика';
      case TestCategory.kazakh: return 'Қазақ тілі';
      case TestCategory.russian: return 'Орыс тілі';
      case TestCategory.english: return 'Ағылшын';
      case TestCategory.history: return 'Тарих';
      case TestCategory.science: return 'Жаратылыстану';
      case TestCategory.other: return 'Басқа';
    }
  }
}

// ── Тест карточкасы ──────────────────────────────────────
class _TestCard extends StatelessWidget {
  final TestModel test;
  const _TestCard({required this.test});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => context.push('/test/${test.id}'),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        test.categoryName,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.arrow_forward_ios_rounded,
                        size: 14, color: AppTheme.textSecondary),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  test.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  test.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _infoChip(Icons.help_outline, '${test.questionCount} сұрақ'),
                    const SizedBox(width: 12),
                    _infoChip(Icons.timer_outlined, '${test.durationMinutes} мин'),
                    const SizedBox(width: 12),
                    _infoChip(Icons.star_outline, '${test.maxScore} балл'),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  '👨‍🏫 ${test.teacherName}',
                  style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppTheme.textSecondary),
        const SizedBox(width: 4),
        Text(label,
            style:
                TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
      ],
    );
  }
}

// ── Нәтиже карточкасы ─────────────────────────────────────
class _ResultCard extends StatelessWidget {
  final TestResult result;
  const _ResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final color = result.percentage >= 75
        ? AppTheme.success
        : result.percentage >= 60
            ? AppTheme.warning
            : AppTheme.error;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              '${result.percentage.toStringAsFixed(0)}%',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: color),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.testTitle,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${result.score}/${result.maxScore} балл • Баға: ${result.grade}',
                  style: TextStyle(
                      fontSize: 13, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  result.grade,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: color),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Стат карточкасы ───────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatCard(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
