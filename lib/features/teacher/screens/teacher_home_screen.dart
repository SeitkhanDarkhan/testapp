import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../auth/models/app_user.dart';
import '../../auth/providers/auth_provider.dart';
import '../../test/providers/test_provider.dart';
import '../../test/models/test_model.dart';
import '../../../core/theme/app_theme.dart';

class TeacherHomeScreen extends ConsumerWidget {
  final AppUser user;
  const TeacherHomeScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final testsAsync = ref.watch(teacherTestsProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          // AppBar
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: const Color(0xFF2F9E44),
            actions: [
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
                    colors: [Color(0xFF2F9E44), Color(0xFF40C057)],
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 80, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Сәлем, ${user.displayName.split(' ').first}! 👩‍🏫',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Мұғалім панелі',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: testsAsync.when(
              data: (tests) => _buildContent(context, ref, tests),
              loading: () => const Padding(
                padding: EdgeInsets.all(48),
                child: Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFF40C057))),
              ),
              error: (e, _) => Center(child: Text('Қате: $e')),
            ),
          ),
        ],
      ),

      // Тест жасау FAB
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/teacher/create-test'),
        backgroundColor: const Color(0xFF2F9E44),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Тест жасау',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, WidgetRef ref, List<TestModel> tests) {
    final active = tests.where((t) => t.status == TestStatus.active).length;
    final draft = tests.where((t) => t.status == TestStatus.draft).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Статистика
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _StatCard(
                label: 'Барлық тесттер',
                value: '${tests.length}',
                icon: Icons.assignment_outlined,
                color: const Color(0xFF2F9E44),
              ),
              const SizedBox(width: 10),
              _StatCard(
                label: 'Белсенді',
                value: '$active',
                icon: Icons.play_circle_outline,
                color: AppTheme.primary,
              ),
              const SizedBox(width: 10),
              _StatCard(
                label: 'Жоба',
                value: '$draft',
                icon: Icons.edit_outlined,
                color: AppTheme.warning,
              ),
            ],
          ),
        ),

        // Жылдам əрекеттер
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _QuickAction(
                icon: Icons.add_circle_outline,
                label: 'Тест жасау',
                color: const Color(0xFF2F9E44),
                onTap: () => context.push('/teacher/create-test'),
              ),
              const SizedBox(width: 10),
              _QuickAction(
                icon: Icons.bar_chart_rounded,
                label: 'Нәтижелер',
                color: AppTheme.primary,
                onTap: () => context.push('/teacher/results'),
              ),
              const SizedBox(width: 10),
              _QuickAction(
                icon: Icons.people_outline,
                label: 'Оқушылар',
                color: AppTheme.warning,
                onTap: () {},
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Тест тізімі тақырыбы
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Text(
                'Менің тесттерім',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const Spacer(),
              if (tests.isNotEmpty)
                Text(
                  '${tests.length} тест',
                  style: TextStyle(
                      fontSize: 13, color: AppTheme.textSecondary),
                ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Тест тізімі
        if (tests.isEmpty)
          _buildEmpty()
        else
          ...tests.map((t) => _TeacherTestCard(test: t, ref: ref)),

        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildEmpty() {
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Column(
        children: [
          Icon(Icons.assignment_outlined, size: 56, color: AppTheme.border),
          const SizedBox(height: 12),
          Text(
            'Тест жасалмаған',
            style: TextStyle(
                color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 6),
          Text(
            '"Тест жасау" батырмасын басыңыз',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// ── Мұғалімнің тест карточкасы ─────────────────────────────
class _TeacherTestCard extends StatelessWidget {
  final TestModel test;
  final WidgetRef ref;
  const _TeacherTestCard({required this.test, required this.ref});

  @override
  Widget build(BuildContext context) {
    final statusColor = test.status == TestStatus.active
        ? AppTheme.success
        : test.status == TestStatus.draft
            ? AppTheme.warning
            : AppTheme.textSecondary;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => context.push('/teacher/test/${test.id}'),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        test.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    _StatusBadge(status: test.status),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _chip(Icons.help_outline, '${test.questionCount} сұрақ'),
                    const SizedBox(width: 12),
                    _chip(Icons.timer_outlined, '${test.durationMinutes} мин'),
                    const SizedBox(width: 12),
                    _chip(Icons.category_outlined, test.categoryName),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    // Белсендіру/өшіру батырмасы
                    _ActionButton(
                      label: test.status == TestStatus.active
                          ? 'Өшіру'
                          : 'Белсендіру',
                      icon: test.status == TestStatus.active
                          ? Icons.pause_circle_outline
                          : Icons.play_circle_outline,
                      color: test.status == TestStatus.active
                          ? AppTheme.error
                          : AppTheme.success,
                      onTap: () => _toggleStatus(context),
                    ),
                    const SizedBox(width: 8),
                    _ActionButton(
                      label: 'Өңдеу',
                      icon: Icons.edit_outlined,
                      color: AppTheme.primary,
                      onTap: () =>
                          context.push('/teacher/edit-test/${test.id}'),
                    ),
                    const SizedBox(width: 8),
                    _ActionButton(
                      label: 'Нәтижелер',
                      icon: Icons.bar_chart_rounded,
                      color: AppTheme.warning,
                      onTap: () =>
                          context.push('/teacher/test-results/${test.id}'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _toggleStatus(BuildContext context) async {
    final firestore = ref.read(firestoreProvider);
    final newStatus = test.status == TestStatus.active
        ? TestStatus.draft
        : TestStatus.active;
    await firestore
        .collection('tests')
        .doc(test.id)
        .update({'status': newStatus.name});
  }

  Widget _chip(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 13, color: AppTheme.textSecondary),
        const SizedBox(width: 3),
        Text(label,
            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final TestStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (status) {
      case TestStatus.active:
        color = AppTheme.success;
        label = 'Белсенді';
        break;
      case TestStatus.draft:
        color = AppTheme.warning;
        label = 'Жоба';
        break;
      case TestStatus.archived:
        color = AppTheme.textSecondary;
        label = 'Мұрағат';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
            fontSize: 12, color: color, fontWeight: FontWeight.w500),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ActionButton(
      {required this.label,
      required this.icon,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(label,
                  style: TextStyle(
                      fontSize: 12,
                      color: color,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}

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
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary),
            ),
            Text(label,
                style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickAction(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 6),
              Text(label,
                  style: TextStyle(
                      fontSize: 12,
                      color: color,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}
