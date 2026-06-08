import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/teacher/screens/create_test_screen.dart';
import '../../features/test/screens/test_detail_screen.dart';
import '../../features/test/screens/test_result_screen.dart';
import '../../features/test/screens/test_taking_screen.dart';

// Auth өзгерісін GoRouter-ге хабарлайтын listenable
// GoRouter тек осы арқылы refresh жасайды — жаңа router ЖАСАЛМАЙДЫ
class _AuthChangeNotifier extends ChangeNotifier {
  late final StreamSubscription<User?> _sub;

  _AuthChangeNotifier() {
    _sub = FirebaseAuth.instance.authStateChanges().listen((_) {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

// Router бір рет жасалады, ешқашан қайта жасалмайды
final routerProvider = Provider<GoRouter>((ref) {
  final notifier = _AuthChangeNotifier();
  ref.onDispose(notifier.dispose);

  final router = GoRouter(
    initialLocation: '/login',
    refreshListenable: notifier,
    redirect: (context, state) {
      final user = FirebaseAuth.instance.currentUser;
      final loggedIn = user != null;
      final path = state.matchedLocation;

      final onAuthPage = path == '/login' ||
          path == '/register' ||
          path == '/forgot-password';

      if (!loggedIn && !onAuthPage) return '/login';
      if (loggedIn && onAuthPage) return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (_, __) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (_, __) => const HomeScreen(),
      ),
      GoRoute(
        path: '/test/:id',
        builder: (_, s) => TestDetailScreen(testId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/test/:id/take',
        builder: (_, s) => TestTakingScreen(testId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/test/:id/result',
        builder: (_, s) => TestResultScreen(testId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/teacher/create-test',
        builder: (_, __) => const CreateTestScreen(),
      ),
      GoRoute(
        path: '/teacher/edit-test/:id',
        builder: (_, s) => Scaffold(
          appBar: AppBar(title: const Text('Тестті өңдеу')),
          body: const Center(child: Text('Жақында')),
        ),
      ),
      GoRoute(
        path: '/teacher/test-results/:id',
        builder: (_, s) => Scaffold(
          appBar: AppBar(title: const Text('Нәтижелер')),
          body: const Center(child: Text('Жақында')),
        ),
      ),
      GoRoute(
        path: '/teacher/results',
        builder: (_, __) => Scaffold(
          appBar: AppBar(title: const Text('Барлық нәтижелер')),
          body: const Center(child: Text('Жақында')),
        ),
      ),
      GoRoute(
        path: '/admin/add-teacher',
        builder: (_, __) => Scaffold(
          appBar: AppBar(title: const Text('Мұғалім қосу')),
          body: const Center(child: Text('Жақында')),
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Бет табылмады: ${state.error}')),
    ),
  );

  return router;
});
