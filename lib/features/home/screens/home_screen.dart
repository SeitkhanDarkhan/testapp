import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/models/app_user.dart';
import '../../../core/theme/app_theme.dart';
import '../../student/screens/student_home_screen.dart';
import '../../teacher/screens/teacher_home_screen.dart';
import '../../admin/screens/admin_home_screen.dart';
import '../../../seed_tests.dart'; // ← қос

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
      ),
      error: (e, st) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              Text('Қате: $e', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(currentUserProvider),
                child: const Text('Қайталау'),
              ),
            ],
          ),
        ),
      ),
      data: (user) {
        if (user == null) {
          final firebaseUser = ref.read(firebaseAuthProvider).currentUser;
          if (firebaseUser == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) context.go('/login');
            });
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final tempUser = AppUser(
            uid: firebaseUser.uid,
            email: firebaseUser.email ?? '',
            displayName: firebaseUser.displayName ?? 'Пайдаланушы',
            photoUrl: firebaseUser.photoURL,
            role: UserRole.student,
            createdAt: DateTime.now(),
          );

          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(authServiceProvider).ensureUserExists(tempUser);
          });

          // Студент әлі тіркеліп жатқан кезде уақытша экран көрсету
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
          );
        }

        Widget screen;
        switch (user.role) {
          case UserRole.student:
            screen = StudentHomeScreen(user: user);
            break;
          case UserRole.teacher:
            screen = TeacherHomeScreen(user: user);
            break;
          case UserRole.admin:
            screen = AdminHomeScreen(user: user);
            break;
        }

        // БҰЛ ЖЕРДЕ RETURN ҚАЛЫП КЕТКЕН ЕДІ (ТҮЗЕТІЛДІ)
        return screen;
      }, // data функциясының жабылатын жақшасы мен үтірі (ТҮЗЕТІЛДІ)
    );
  }
}