import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/test_model.dart';
import '../../auth/providers/auth_provider.dart';

// Барлық белсенді тесттер (оқушыға)
final activeTestsProvider = StreamProvider<List<TestModel>>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return firestore
      .collection('tests')
      .where('status', isEqualTo: 'active')
  // orderBy жойылды — индекс керек емес
      .snapshots()
      .map((snap) {
    final docs = snap.docs
        .map((d) => TestModel.fromMap({...d.data(), 'id': d.id}))
        .toList();
    // Клиент жағынан сорттаймыз
    docs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return docs;
  });
});

// Мұғалімнің тесттері
final teacherTestsProvider = StreamProvider<List<TestModel>>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return const Stream.empty();

  return firestore
      .collection('tests')
      .where('teacherId', isEqualTo: user.uid)
  // orderBy жойылды — индекс керек емес
      .snapshots()
      .map((snap) {
    final docs = snap.docs
        .map((d) => TestModel.fromMap({...d.data(), 'id': d.id}))
        .toList();
    docs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return docs;
  });
});

// Оқушының нәтижелері
final studentResultsProvider = StreamProvider<List<TestResult>>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return const Stream.empty();

  return firestore
      .collection('results')
      .where('studentId', isEqualTo: user.uid)
  // orderBy жойылды — индекс керек емес
      .snapshots()
      .map((snap) {
    final docs = snap.docs
        .map((d) => TestResult.fromMap({...d.data(), 'id': d.id}))
        .toList();
    // Клиент жағынан сорттап, 10-мен шектейміз
    docs.sort((a, b) => b.completedAt.compareTo(a.completedAt));
    return docs.take(10).toList();
  });
});

// Жалпы статистика (Админге)
final adminStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  final firestore = ref.watch(firestoreProvider);
  final results = await Future.wait([
    firestore.collection('users').count().get(),
    firestore.collection('tests').count().get(),
    firestore.collection('results').count().get(),
    firestore
        .collection('tests')
        .where('status', isEqualTo: 'active')
        .count()
        .get(),
  ]);
  return {
    'users': results[0].count ?? 0,
    'tests': results[1].count ?? 0,
    'results': results[2].count ?? 0,
    'activeTests': results[3].count ?? 0,
  };
});

// Барлық пайдаланушылар (Админге)
final allUsersProvider = StreamProvider((ref) {
  final firestore = ref.watch(firestoreProvider);
  return firestore
      .collection('users')
  // orderBy жойылды — индекс керек емес
      .snapshots();
});