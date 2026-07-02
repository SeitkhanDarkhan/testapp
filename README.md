# TestApp — Онлайн тестілеу платформасы / Платформа онлайн-тестирования

> 🇰🇿 Қазақша төменде | 🇷🇺 Русская версия ниже

---

## 🇰🇿 Қазақша

### 📋 Сипаттамасы

**TestApp** — оқушылар мен мұғалімдерге арналған, Flutter және Firebase негізінде жасалған онлайн тестілеу қосымшасы. Үш рөлмен жұмыс істейді: **оқушы**, **мұғалім**, **админ**.
## 🖼️ Скриншоттар / Screenshots

<p align="center">
  <img src="https://github.com/user-attachments/assets/fa72b571-e802-4848-b28d-6d5799869bca" width="200" />
  <img src="https://github.com/user-attachments/assets/eb210788-98c6-49ed-b6ef-b199d92d2d20" width="200" />
  <img src="https://github.com/user-attachments/assets/49315f14-ab3e-4de8-af90-16a8e9f6c851" width="200" />
  <img src="https://github.com/user-attachments/assets/4d6d0c8e-1226-46cd-9587-d700c9cf7a7a" width="200" />
  <img src="https://github.com/user-attachments/assets/9a50b994-8759-473a-86a3-1f5f9be6302f" width="200" />
</p>

<p align="center">
  <sub>Кіру · Басты бет · Тест туралы · Тест өту · Нәтиже</sub>
</p>

### ✨ Негізгі мүмкіндіктер

| Рөл | Мүмкіндіктер |
|---|---|
| 👤 **Оқушы** | Тест тізімін көру, тест тапсыру, нәтижелерін көру, статистика |
| 👩‍🏫 **Мұғалім** | Тест жасау, сұрақтар қосу, тесттерді басқару, нәтижелерді бақылау |
| 🛠️ **Админ** | Жүйені басқару, мұғалімдер қосу |

### 🔐 Авторизация
- Email/Пароль арқылы кіру (валидация + қазақша қате хабарламалары)
- Google Sign-In
- Тіркелу (аты-жөні, email, пароль, рөл таңдау)
- Пароль қалпына келтіру
- Auth күйіне байланысты автоматты бағыттау (redirect)

### 🧩 Тест жүйесі
- Сұрақ түрлері: бір жауапты таңдау, көп жауапты таңдау, ия/жоқ (true/false)
- Санат бойынша бөлу: математика, қазақ тілі, орыс тілі, ағылшын тілі, тарих, жаратылыстану, басқа
- Тест статусы: белсенді / жоба / мұрағат
- Уақыт шектеуі, ұпай жүйесі, баға есептеу (5/4/3/2)
- Нәтиже бойынша рейтинг

### 🛠️ Технологиялар

- **Flutter** (Dart) — кросс-платформалық frontend
- **Firebase**:
  - `firebase_auth` — авторизация
  - `cloud_firestore` — деректер базасы
- **flutter_riverpod** — state management
- **go_router** — навигация, auth-қа байланысты автоматты redirect
- **google_sign_in** — Google арқылы кіру
- **gson** аналогы ретінде Dart `Map`/`fromMap`/`toMap` арқылы сериализация

### 📂 Жоба құрылымы

```
lib/
├── main.dart                          # Кіру нүктесі
├── firebase_options.dart              # Firebase конфигурациясы
├── seed_tests.dart                    # Тест деректерін алдын ала толтыру
├── core/
│   ├── theme/app_theme.dart           # Түстер, стильдер
│   └── routes/app_router.dart         # GoRouter маршруттары
└── features/
    ├── auth/
    │   ├── models/app_user.dart       # Пайдаланушы моделі + рөлдер
    │   ├── providers/auth_provider.dart
    │   └── screens/                   # login, register, forgot-password
    ├── home/screens/home_screen.dart  # Рөл бойынша бағыттаушы экран
    ├── student/screens/student_home_screen.dart
    ├── teacher/
    │   ├── providers/create_test_provider.dart
    │   └── screens/                   # teacher_home, create_test, create_test_questions
    ├── admin/screens/admin_home_screen.dart
    └── test/
        ├── models/                    # test_model, question_model
        ├── providers/                 # test, test_session, test_taking
        └── screens/                   # test_detail, test_taking, test_result
```

### 🚀 Орнату және іске қосу

#### 1. Firebase жобасын құру
1. [Firebase Console](https://console.firebase.google.com/) ашыңыз
2. Жаңа жоба жасаңыз
3. Authentication → Sign-in method → **Email/Password** және **Google** қосыңыз
4. Cloud Firestore → деректер базасын жасаңыз

#### 2. Flutter қосымшасын Firebase-ке байлау
```bash
dart pub global activate flutterfire_cli
flutterfire configure
```
Бұл `lib/firebase_options.dart` файлын автоматты жасайды.

#### 3. Пакеттерді орнату және іске қосу
```bash
flutter pub get
flutter run
```

### 🗂️ Firestore деректер құрылымы

```
users/{uid}
  uid, email, displayName, photoUrl, role ("student"|"teacher"|"admin"), createdAt

tests/{testId}
  title, description, teacherId, teacherName, category, status,
  questionCount, durationMinutes, maxScore, createdAt, allowedStudentIds

questions/{questionId}
  testId, text, type, options[], correctAnswerIds[], points, orderIndex

results/{resultId}
  testId, testTitle, studentId, score, maxScore, durationSeconds, completedAt
```

### ⚠️ Белгілі шектеулер
- Кейбір мұғалім/админ функциялары әлі дайын емес: тестті өңдеу, толық нәтиже статистикасы, мұғалім қосу — бұл маршруттар "Жақында" деп белгіленген
- README автоматты түрде жаңартылмайды — код өзгерген сайын қолмен қадағалау қажет

---

## 🇷🇺 Русская версия

### 📋 Описание

**TestApp** — приложение для онлайн-тестирования учеников и учителей, построенное на Flutter и Firebase. Поддерживает три роли: **ученик**, **учитель**, **админ**.

### ✨ Основные возможности

| Роль | Возможности |
|---|---|
| 👤 **Ученик** | Просмотр списка тестов, прохождение теста, просмотр результатов, статистика |
| 👩‍🏫 **Учитель** | Создание тестов, добавление вопросов, управление тестами, отслеживание результатов |
| 🛠️ **Админ** | Управление системой, добавление учителей |

### 🔐 Авторизация
- Вход по Email/Паролю (валидация + сообщения об ошибках на казахском)
- Google Sign-In
- Регистрация (имя, email, пароль, выбор роли)
- Восстановление пароля
- Автоматический redirect в зависимости от состояния авторизации

### 🧩 Система тестирования
- Типы вопросов: одиночный выбор, множественный выбор, да/нет (true/false)
- Категории: математика, казахский язык, русский язык, английский язык, история, естествознание, другое
- Статус теста: активный / черновик / архив
- Ограничение по времени, система баллов, расчёт оценки (5/4/3/2)
- Рейтинг по результатам

### 🛠️ Технологии

- **Flutter** (Dart) — кроссплатформенный frontend
- **Firebase**:
  - `firebase_auth` — авторизация
  - `cloud_firestore` — база данных
- **flutter_riverpod** — управление состоянием
- **go_router** — навигация с авто-редиректом по состоянию авторизации
- **google_sign_in** — вход через Google
- Сериализация моделей через `fromMap`/`toMap` на чистом Dart

### 📂 Структура проекта

```
lib/
├── main.dart                          # Точка входа
├── firebase_options.dart              # Конфигурация Firebase
├── seed_tests.dart                    # Предзаполнение тестовых данных
├── core/
│   ├── theme/app_theme.dart           # Цвета, стили
│   └── routes/app_router.dart         # Маршруты GoRouter
└── features/
    ├── auth/                          # Авторизация (login, register, forgot-password)
    ├── home/screens/home_screen.dart  # Экран-роутер по ролям
    ├── student/screens/student_home_screen.dart
    ├── teacher/                       # teacher_home, create_test, create_test_questions
    ├── admin/screens/admin_home_screen.dart
    └── test/                          # Модели, провайдеры и экраны тестирования
```

### 🚀 Установка и запуск

#### 1. Создание Firebase-проекта
1. Откройте [Firebase Console](https://console.firebase.google.com/)
2. Создайте новый проект
3. Authentication → Sign-in method → включите **Email/Password** и **Google**
4. Cloud Firestore → создайте базу данных

#### 2. Подключение Flutter-приложения к Firebase
```bash
dart pub global activate flutterfire_cli
flutterfire configure
```
Это автоматически создаст файл `lib/firebase_options.dart`.

#### 3. Установка пакетов и запуск
```bash
flutter pub get
flutter run
```

### 🗂️ Структура данных в Firestore

```
users/{uid}
  uid, email, displayName, photoUrl, role ("student"|"teacher"|"admin"), createdAt

tests/{testId}
  title, description, teacherId, teacherName, category, status,
  questionCount, durationMinutes, maxScore, createdAt, allowedStudentIds

questions/{questionId}
  testId, text, type, options[], correctAnswerIds[], points, orderIndex

results/{resultId}
  testId, testTitle, studentId, score, maxScore, durationSeconds, completedAt
```

### ⚠️ Известные ограничения
- Часть функций учителя/админа ещё не реализована: редактирование теста, полная статистика результатов, добавление учителя — эти маршруты помечены как "Скоро" (`Жақында`)
