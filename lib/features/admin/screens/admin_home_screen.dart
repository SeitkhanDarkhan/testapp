import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/models/app_user.dart';
import '../../auth/providers/auth_provider.dart';
import '../../test/providers/test_provider.dart';
import '../../../core/theme/app_theme.dart';

class AdminHomeScreen extends ConsumerStatefulWidget {
  final AppUser user;
  const AdminHomeScreen({super.key, required this.user});

  @override
  ConsumerState<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends ConsumerState<AdminHomeScreen> {
  int _selectedNav = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: IndexedStack(
        index: _selectedNav,
        children: [
          _DashboardTab(user: widget.user),
          _UsersTab(),
          _TestsTab(),
          _SettingsTab(user: widget.user),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedNav,
        onDestinationSelected: (i) => setState(() => _selectedNav = i),
        backgroundColor: AppTheme.surface,
        indicatorColor: AppTheme.primary.withOpacity(0.1),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded, color: AppTheme.primary),
            label: 'Басты',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outlined),
            selectedIcon: Icon(Icons.people_rounded, color: AppTheme.primary),
            label: 'Пайдаланушылар',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon:
                Icon(Icons.assignment_rounded, color: AppTheme.primary),
            label: 'Тесттер',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon:
                Icon(Icons.settings_rounded, color: AppTheme.primary),
            label: 'Баптаулар',
          ),
        ],
      ),
    );
  }
}

// ── Дашборд ────────────────────────────────────────────────
class _DashboardTab extends ConsumerWidget {
  final AppUser user;
  const _DashboardTab({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminStatsProvider);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 160,
          pinned: true,
          backgroundColor: const Color(0xFF862E9C),
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF862E9C), Color(0xFFAE3EC9)],
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 80, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Сәлем, ${user.displayName.split(' ').first}! 🔧',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Админ панелі',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: statsAsync.when(
            data: (stats) => _buildDashboard(context, stats),
            loading: () => const Padding(
              padding: EdgeInsets.all(48),
              child: Center(
                child: CircularProgressIndicator(
                    color: Color(0xFFAE3EC9)),
              ),
            ),
            error: (e, _) => Center(child: Text('Қате: $e')),
          ),
        ),
      ],
    );
  }

  Widget _buildDashboard(BuildContext context, Map<String, int> stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Статистика grid
        Padding(
          padding: const EdgeInsets.all(16),
          child: GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _BigStatCard(
                label: 'Пайдаланушылар',
                value: '${stats['users'] ?? 0}',
                icon: Icons.people_rounded,
                color: AppTheme.primary,
              ),
              _BigStatCard(
                label: 'Барлық тесттер',
                value: '${stats['tests'] ?? 0}',
                icon: Icons.assignment_rounded,
                color: const Color(0xFF2F9E44),
              ),
              _BigStatCard(
                label: 'Белсенді тесттер',
                value: '${stats['activeTests'] ?? 0}',
                icon: Icons.play_circle_rounded,
                color: AppTheme.warning,
              ),
              _BigStatCard(
                label: 'Нәтижелер',
                value: '${stats['results'] ?? 0}',
                icon: Icons.bar_chart_rounded,
                color: const Color(0xFF862E9C),
              ),
            ],
          ),
        ),

        // Жылдам əрекеттер
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Жылдам əрекеттер',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 12),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              _AdminActionCard(
                icon: Icons.person_add_outlined,
                title: 'Мұғалім қосу',
                subtitle: 'Жаңа мұғалім тіркеу',
                color: AppTheme.primary,
                onTap: () => context.push('/admin/add-teacher'),
              ),
              const SizedBox(height: 10),
              _AdminActionCard(
                icon: Icons.category_outlined,
                title: 'Категориялар',
                subtitle: 'Тест категорияларын басқару',
                color: const Color(0xFF2F9E44),
                onTap: () {},
              ),
              const SizedBox(height: 10),
              _AdminActionCard(
                icon: Icons.download_outlined,
                title: 'Есеп жүктеу',
                subtitle: 'Excel форматта экспорт',
                color: AppTheme.warning,
                onTap: () {},
              ),
              const SizedBox(height: 10),
              _AdminActionCard(
                icon: Icons.delete_sweep_outlined,
                title: 'Деректерді тазалау',
                subtitle: 'Ескі нәтижелерді жою',
                color: AppTheme.error,
                onTap: () => _showDeleteConfirm(context),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  void _showDeleteConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Растау'),
        content: const Text(
            'Ескі нәтижелерді жойғыңыз келе ме? Бұл əрекетті кері қайтару мүмкін емес.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Болдырмау'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            child: const Text('Жою'),
          ),
        ],
      ),
    );
  }
}

// ── Пайдаланушылар ─────────────────────────────────────────
class _UsersTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(allUsersProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Пайдаланушылар'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: usersAsync.when(
        data: (snap) {
          final docs = snap.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('Пайдаланушы жоқ'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final data = docs[i].data() as Map<String, dynamic>;
              final role = data['role'] as String? ?? 'student';
              final name = data['displayName'] as String? ?? '—';
              final email = data['email'] as String? ?? '—';

              final roleColor = role == 'admin'
                  ? const Color(0xFF862E9C)
                  : role == 'teacher'
                      ? const Color(0xFF2F9E44)
                      : AppTheme.primary;
              final roleLabel = role == 'admin'
                  ? 'Админ'
                  : role == 'teacher'
                      ? 'Мұғалім'
                      : 'Оқушы';

              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: roleColor.withOpacity(0.1),
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : '?',
                        style: TextStyle(
                            color: roleColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 16),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary),
                          ),
                          Text(
                            email,
                            style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: roleColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        roleLabel,
                        style: TextStyle(
                            fontSize: 12,
                            color: roleColor,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFFAE3EC9))),
        error: (e, _) => Center(child: Text('Қате: $e')),
      ),
    );
  }
}

// ── Тесттер тізімі (Admin) ─────────────────────────────────
class _TestsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final testsAsync = ref.watch(activeTestsProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Барлық тесттер')),
      body: testsAsync.when(
        data: (tests) => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: tests.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) {
            final t = tests[i];
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(t.title,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text('Белсенді',
                            style: TextStyle(
                                fontSize: 11,
                                color: AppTheme.success,
                                fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '👨‍🏫 ${t.teacherName} • ${t.categoryName} • ${t.questionCount} сұрақ',
                    style: TextStyle(
                        fontSize: 12, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            );
          },
        ),
        loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFFAE3EC9))),
        error: (e, _) => Center(child: Text('Қате: $e')),
      ),
    );
  }
}

// ── Баптаулар ──────────────────────────────────────────────
class _SettingsTab extends ConsumerWidget {
  final AppUser user;
  const _SettingsTab({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Баптаулар')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Профиль карточкасы
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.border),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor:
                      const Color(0xFF862E9C).withOpacity(0.1),
                  child: Text(
                    user.displayName.isNotEmpty
                        ? user.displayName[0].toUpperCase()
                        : 'A',
                    style: const TextStyle(
                        color: Color(0xFF862E9C),
                        fontSize: 22,
                        fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.displayName,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: AppTheme.textPrimary)),
                    Text(user.email,
                        style: TextStyle(
                            fontSize: 13, color: AppTheme.textSecondary)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF862E9C).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('Админ',
                          style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF862E9C),
                              fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          _SettingsTile(
            icon: Icons.person_outline,
            label: 'Профильді өзгерту',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.lock_outline,
            label: 'Парольді өзгерту',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.notifications_outlined,
            label: 'Хабарландырулар',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.info_outline,
            label: 'Қосымша туралы',
            onTap: () {},
          ),
          const SizedBox(height: 10),
          _SettingsTile(
            icon: Icons.logout_rounded,
            label: 'Шығу',
            color: AppTheme.error,
            onTap: () async {
              await ref.read(authServiceProvider).signOut();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;
  const _SettingsTile(
      {required this.icon,
      required this.label,
      this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppTheme.textPrimary;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: ListTile(
        leading: Icon(icon, color: c, size: 22),
        title: Text(label,
            style: TextStyle(
                fontSize: 15,
                color: c,
                fontWeight: FontWeight.w500)),
        trailing: color == null
            ? Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: AppTheme.textSecondary)
            : null,
        onTap: onTap,
      ),
    );
  }
}

// ── Жалпы виджеттер ────────────────────────────────────────
class _BigStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _BigStatCard(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary)),
              Text(label,
                  style: TextStyle(
                      fontSize: 12, color: AppTheme.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}

class _AdminActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  const _AdminActionCard(
      {required this.icon,
      required this.title,
      required this.subtitle,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.border),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: AppTheme.textPrimary)),
                    Text(subtitle,
                        style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary)),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded,
                  size: 14, color: AppTheme.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
