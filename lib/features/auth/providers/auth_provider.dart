import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_user.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

// Firebase Auth stream
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// AppUser Firestore stream — рөл өзгерсе автоматты жаңарады
final currentUserProvider = StreamProvider<AppUser?>((ref) {
  final authAsync = ref.watch(authStateProvider);
  final firebaseUser = authAsync.valueOrNull;

  if (firebaseUser == null) return Stream.value(null);

  return FirebaseFirestore.instance
      .collection('users')
      .doc(firebaseUser.uid)
      .snapshots()
      .map((doc) {
    if (!doc.exists || doc.data() == null) return null;
    try {
      return AppUser.fromMap(doc.data()!);
    } catch (e) {
      return null;
    }
  });
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final GoogleSignIn _google = GoogleSignIn();

  // Email / пароль кіру
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await _ensureUserDoc(cred.user!);
    } on FirebaseAuthException catch (e) {
      throw _errorText(e);
    }
  }

  // Email / пароль тіркелу
  Future<void> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await cred.user!.updateDisplayName(displayName);

      final user = AppUser(
        uid: cred.user!.uid,
        email: email.trim(),
        displayName: displayName,
        role: UserRole.student,
        createdAt: DateTime.now(),
      );
      await _db
          .collection('users')
          .doc(user.uid)
          .set(user.toMap(), SetOptions(merge: true));
    } on FirebaseAuthException catch (e) {
      throw _errorText(e);
    }
  }

  // Google кіру
  Future<void> signInWithGoogle() async {
    try {
      final gUser = await _google.signIn();
      if (gUser == null) throw Exception('Болдырылмады');

      final gAuth = await gUser.authentication;
      final cred = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );
      final result = await _auth.signInWithCredential(cred);
      await _ensureUserDoc(result.user!);
    } on FirebaseAuthException catch (e) {
      throw _errorText(e);
    }
  }

  // Пароль қалпына келтіру
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _errorText(e);
    }
  }

  // Шығу
  Future<void> signOut() async {
    await _google.signOut();
    await _auth.signOut();
  }

  // Firestore-да doc жоқ болса жасайды, бар болса қалдырады
  // Public version — home_screen fallback үшін
  Future<void> ensureUserExists(AppUser user) async {
    final docRef = _db.collection('users').doc(user.uid);
    final doc = await docRef.get();
    if (!doc.exists) await docRef.set(user.toMap());
  }

  Future<void> _ensureUserDoc(User firebaseUser) async {
    final ref = _db.collection('users').doc(firebaseUser.uid);
    final doc = await ref.get();
    if (!doc.exists) {
      final user = AppUser(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        displayName: firebaseUser.displayName ?? 'Пайдаланушы',
        photoUrl: firebaseUser.photoURL,
        role: UserRole.student,
        createdAt: DateTime.now(),
      );
      await ref.set(user.toMap());
    }
    // doc бар болса — ештеңе өзгертпейміз (рөл сақталады)
  }

  String _errorText(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':       return 'Бұл email тіркелмеген';
      case 'wrong-password':
      case 'invalid-credential':   return 'Email немесе пароль қате';
      case 'email-already-in-use': return 'Бұл email бұрыннан тіркелген';
      case 'weak-password':        return 'Пароль кем дегенде 6 таңба болуы керек';
      case 'invalid-email':        return 'Email пішімі дұрыс емес';
      case 'too-many-requests':    return 'Тым көп әрекет, кейінірек қайталаңыз';
      case 'network-request-failed': return 'Интернет байланысы жоқ';
      default: return 'Қате: ${e.message}';
    }
  }
}
