import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { student, teacher, admin }

class AppUser {
  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl;
  final UserRole role;
  final DateTime createdAt;

  const AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
    required this.role,
    required this.createdAt,
  });

  factory AppUser.fromMap(Map<String, dynamic> map) {
    // createdAt: int, Timestamp, немесе null — барлық жағдай
    final rawDate = map['createdAt'];
    final DateTime date;
    if (rawDate is int) {
      date = DateTime.fromMillisecondsSinceEpoch(rawDate);
    } else if (rawDate is Timestamp) {
      date = rawDate.toDate();
    } else {
      date = DateTime.now();
    }

    // role: кез келген жағдайда student болып қалады
    final rawRole = map['role'];
    final role = UserRole.values.firstWhere(
      (r) => r.name == rawRole,
      orElse: () => UserRole.student,
    );

    return AppUser(
      uid: (map['uid'] as String?) ?? '',
      email: (map['email'] as String?) ?? '',
      displayName: (map['displayName'] as String?) ?? 'Пайдаланушы',
      photoUrl: map['photoUrl'] as String?,
      role: role,
      createdAt: date,
    );
  }

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'email': email,
        'displayName': displayName,
        'photoUrl': photoUrl,
        'role': role.name,
        'createdAt': createdAt.millisecondsSinceEpoch,
      };

  AppUser copyWith({String? displayName, String? photoUrl, UserRole? role}) =>
      AppUser(
        uid: uid,
        email: email,
        displayName: displayName ?? this.displayName,
        photoUrl: photoUrl ?? this.photoUrl,
        role: role ?? this.role,
        createdAt: createdAt,
      );

  String get roleDisplayName {
    switch (role) {
      case UserRole.student: return 'Оқушы';
      case UserRole.teacher: return 'Мұғалім';
      case UserRole.admin:   return 'Админ';
    }
  }

  bool get isStudent => role == UserRole.student;
  bool get isTeacher => role == UserRole.teacher;
  bool get isAdmin   => role == UserRole.admin;
}
