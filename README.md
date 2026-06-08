# TestApp — Авторизация модулі

## Файл құрылымы

```
lib/
├── main.dart                          # Қосымшаның кіру нүктесі
├── core/
│   ├── theme/
│   │   └── app_theme.dart             # Түстер, стильдер, тақырып
│   └── routes/
│       └── app_router.dart            # GoRouter навигациясы
└── features/
    └── auth/
        ├── models/
        │   └── app_user.dart          # Пайдаланушы модельі + рөлдер
        ├── providers/
        │   └── auth_provider.dart     # Firebase Auth + Riverpod
        └── screens/
            ├── login_screen.dart      # Кіру экраны
            ├── register_screen.dart   # Тіркелу экраны
            └── forgot_password_screen.dart  # Пароль қалпына келтіру
```

## Баптау қадамдары

### 1. Firebase жобасын жасау
1. [Firebase Console](https://console.firebase.google.com/) ашыңыз
2. "Add project" → жобаның атын енгізіңіз (мысалы: `testapp-kz`)
3. Authentication → Sign-in method → **Email/Password** қосыңыз
4. Authentication → Sign-in method → **Google** қосыңыз
5. Cloud Firestore → Create database (production mode)

### 2. Flutter қосымшасын Firebase-ке байлау
```bash
# FlutterFire CLI орнату
dart pub global activate flutterfire_cli

# Firebase конфигурациясын жасау
flutterfire configure
```
Бұл `lib/firebase_options.dart` файлын автоматты жасайды.

### 3. main.dart-қа firebase_options қосу
```dart
import 'firebase_options.dart';

await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

### 4. Пакеттерді орнату
```bash
flutter pub get
```

### 5. Іске қосу
```bash
flutter run
```

## Firestore деректер құрылымы

```
users/
  {uid}/
    uid: string
    email: string
    displayName: string
    photoUrl: string | null
    role: "student" | "teacher" | "admin"
    createdAt: timestamp
```

## Firestore қауіпсіздік ережелері

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      // Тек өз деректерін оқи және жаза алады
      allow read, write: if request.auth != null 
                         && request.auth.uid == userId;
      // Админ барлығын оқи алады
      allow read: if request.auth != null 
                  && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
  }
}
```

## Авторизация мүмкіндіктері

| Мүмкіндік | Сипаттама |
|-----------|-----------|
| Email/Пароль кіру | Валидация + қате хабарламалары қазақшада |
| Google Sign-In | Бір басу арқылы кіру |
| Тіркелу | Аты-жөні, email, пароль, рөл таңдау |
| Пароль қалпына келтіру | Email арқылы сілтеме жіберу |
| Автоматты навигация | Auth күйіне байланысты redirect |
| Анимация | Fade + slide кіру анимациясы |

## Келесі қадам

Авторизациядан кейін **Басты бет (Home)** жасауға кірісеміз:
- Оқушы: тест тізімі
- Мұғалім: тест жасаушы панель
- Админ: басқару панелі
