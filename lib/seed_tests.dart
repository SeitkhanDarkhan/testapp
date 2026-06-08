// ═══════════════════════════════════════════════════════════
// ҚОЛДАНУ: lib/seed_tests.dart деп сақта
// main.dart-та initState немесе бір батырмаға байла:
//   await SeedTests.uploadAll();
// Бір рет іске қос, содан кейін жой немесе комментке ал
// ═══════════════════════════════════════════════════════════

import 'package:cloud_firestore/cloud_firestore.dart';

class SeedTests {
  static final _db = FirebaseFirestore.instance;

  static Future<void> uploadAll() async {
    print('Тесттер жүктеліп жатыр...');
    for (final data in _allTests) {
      await _uploadTest(data);
    }
    print('✅ Барлық тесттер жүктелді!');
  }

  static Future<void> _uploadTest(Map<String, dynamic> data) async {
    final testRef = _db.collection('tests').doc();
    final questions = data['questions'] as List<Map<String, dynamic>>;

    await testRef.set({
      'id': testRef.id,
      'title': data['title'],
      'description': data['description'],
      'teacherId': 'admin',
      'teacherName': 'Жүйе',
      'category': data['category'],
      'status': 'active',
      'questionCount': questions.length,
      'durationMinutes': data['durationMinutes'],
      'maxScore': questions.length,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
      'allowedStudentIds': [],
    });

    final batch = _db.batch();
    for (int i = 0; i < questions.length; i++) {
      final q = questions[i];
      final qRef = testRef.collection('questions').doc();
      batch.set(qRef, {
        'id': qRef.id,
        'testId': testRef.id,
        'text': q['text'],
        'type': 'singleChoice',
        'points': 1,
        'orderIndex': i,
        'imageUrl': null,
        'options': q['options'],
        'correctAnswerIds': [q['correct']],
      });
    }
    await batch.commit();
    print('✅ ${data['title']} жүктелді');
  }

  // ═══════════════════════════════════════════════════════
  // МАТЕМАТИКА — 20 сұрақ
  // ═══════════════════════════════════════════════════════
  static final _math = {
    'title': 'Математика негіздері',
    'description': '9-сынып математика — арифметика, геометрия, алгебра',
    'category': 'math',
    'durationMinutes': 30,
    'questions': [
      {'text': '2 + 2 = ?', 'options': [{'id':'a','text':'3'},{'id':'b','text':'4'},{'id':'c','text':'5'},{'id':'d','text':'6'}], 'correct': 'b'},
      {'text': '15 × 4 = ?', 'options': [{'id':'a','text':'45'},{'id':'b','text':'55'},{'id':'c','text':'60'},{'id':'d','text':'70'}], 'correct': 'c'},
      {'text': '√144 = ?', 'options': [{'id':'a','text':'11'},{'id':'b','text':'12'},{'id':'c','text':'13'},{'id':'d','text':'14'}], 'correct': 'b'},
      {'text': '3² + 4² = ?', 'options': [{'id':'a','text':'20'},{'id':'b','text':'24'},{'id':'c','text':'25'},{'id':'d','text':'30'}], 'correct': 'c'},
      {'text': 'Үшбұрыштың бұрыштарының қосындысы:', 'options': [{'id':'a','text':'90°'},{'id':'b','text':'180°'},{'id':'c','text':'270°'},{'id':'d','text':'360°'}], 'correct': 'b'},
      {'text': '100 ÷ 4 = ?', 'options': [{'id':'a','text':'20'},{'id':'b','text':'24'},{'id':'c','text':'25'},{'id':'d','text':'30'}], 'correct': 'c'},
      {'text': 'x + 5 = 12 болса, x = ?', 'options': [{'id':'a','text':'5'},{'id':'b','text':'6'},{'id':'c','text':'7'},{'id':'d','text':'8'}], 'correct': 'c'},
      {'text': '2x = 18 болса, x = ?', 'options': [{'id':'a','text':'7'},{'id':'b','text':'8'},{'id':'c','text':'9'},{'id':'d','text':'10'}], 'correct': 'c'},
      {'text': 'Шеңбер ауданы: r = 5 болса (π≈3.14)', 'options': [{'id':'a','text':'78.5'},{'id':'b','text':'31.4'},{'id':'c','text':'25'},{'id':'d','text':'15.7'}], 'correct': 'a'},
      {'text': 'Квадраттың периметрі, қабырғасы = 6 болса:', 'options': [{'id':'a','text':'12'},{'id':'b','text':'18'},{'id':'c','text':'24'},{'id':'d','text':'36'}], 'correct': 'c'},
      {'text': '(-3) × (-4) = ?', 'options': [{'id':'a','text':'-12'},{'id':'b','text':'-7'},{'id':'c','text':'7'},{'id':'d','text':'12'}], 'correct': 'd'},
      {'text': '5! (факториал) = ?', 'options': [{'id':'a','text':'60'},{'id':'b','text':'100'},{'id':'c','text':'120'},{'id':'d','text':'125'}], 'correct': 'c'},
      {'text': 'Тік бұрышты үшбұрыштың гипотенузасы а=3, b=4 болса:', 'options': [{'id':'a','text':'4'},{'id':'b','text':'5'},{'id':'c','text':'6'},{'id':'d','text':'7'}], 'correct': 'b'},
      {'text': '0.5 × 0.5 = ?', 'options': [{'id':'a','text':'0.1'},{'id':'b','text':'0.25'},{'id':'c','text':'0.5'},{'id':'d','text':'1'}], 'correct': 'b'},
      {'text': '3/4 + 1/4 = ?', 'options': [{'id':'a','text':'4/8'},{'id':'b','text':'1/2'},{'id':'c','text':'1'},{'id':'d','text':'4/4'}], 'correct': 'c'},
      {'text': 'Тіктөртбұрыш ауданы: a=8, b=5 болса:', 'options': [{'id':'a','text':'13'},{'id':'b','text':'26'},{'id':'c','text':'40'},{'id':'d','text':'80'}], 'correct': 'c'},
      {'text': '2³ = ?', 'options': [{'id':'a','text':'6'},{'id':'b','text':'8'},{'id':'c','text':'9'},{'id':'d','text':'12'}], 'correct': 'b'},
      {'text': 'Ең кіші жай сан:', 'options': [{'id':'a','text':'0'},{'id':'b','text':'1'},{'id':'c','text':'2'},{'id':'d','text':'3'}], 'correct': 'c'},
      {'text': '15% от 200 = ?', 'options': [{'id':'a','text':'20'},{'id':'b','text':'25'},{'id':'c','text':'30'},{'id':'d','text':'40'}], 'correct': 'c'},
      {'text': 'Логарифм: log₁₀(100) = ?', 'options': [{'id':'a','text':'1'},{'id':'b','text':'2'},{'id':'c','text':'10'},{'id':'d','text':'100'}], 'correct': 'b'},
    ],
  };

  // ═══════════════════════════════════════════════════════
  // ҚАЗАҚ ТІЛІ — 20 сұрақ
  // ═══════════════════════════════════════════════════════
  static final _kazakh = {
    'title': 'Қазақ тілі грамматикасы',
    'description': 'Қазақ тілінің грамматикалық ережелері',
    'category': 'kazakh',
    'durationMinutes': 25,
    'questions': [
      {'text': 'Зат есімнің сұрағы:', 'options': [{'id':'a','text':'қалай?'},{'id':'b','text':'кім? не?'},{'id':'c','text':'қанша?'},{'id':'d','text':'қайда?'}], 'correct': 'b'},
      {'text': 'Сын есімнің сұрағы:', 'options': [{'id':'a','text':'кім?'},{'id':'b','text':'не?'},{'id':'c','text':'қандай?'},{'id':'d','text':'қайда?'}], 'correct': 'c'},
      {'text': '"Бала" сөзінің көпше түрі:', 'options': [{'id':'a','text':'балалар'},{'id':'b','text':'балалар'},{'id':'c','text':'баладар'},{'id':'d','text':'балалер'}], 'correct': 'a'},
      {'text': 'Етістіктің сұрағы:', 'options': [{'id':'a','text':'кім?'},{'id':'b','text':'не істеді?'},{'id':'c','text':'қандай?'},{'id':'d','text':'қанша?'}], 'correct': 'b'},
      {'text': 'Қазақ алфавитіндегі әріп саны:', 'options': [{'id':'a','text':'32'},{'id':'b','text':'33'},{'id':'c','text':'42'},{'id':'d','text':'43'}], 'correct': 'c'},
      {'text': '"Кітап" сөзінің тәуелді түрі (менің):', 'options': [{'id':'a','text':'кітабым'},{'id':'b','text':'кітапым'},{'id':'c','text':'кітапм'},{'id':'d','text':'кітабм'}], 'correct': 'a'},
      {'text': 'Сөйлемнің бас мүшелері:', 'options': [{'id':'a','text':'анықтауыш, толықтауыш'},{'id':'b','text':'баяндауыш, пысықтауыш'},{'id':'c','text':'бастауыш, баяндауыш'},{'id':'d','text':'анықтауыш, бастауыш'}], 'correct': 'c'},
      {'text': 'Дауысты дыбыстар саны қазақ тілінде:', 'options': [{'id':'a','text':'6'},{'id':'b','text':'9'},{'id':'c','text':'12'},{'id':'d','text':'15'}], 'correct': 'b'},
      {'text': '"Жақсы" сөзі сөйлемде қандай мүше болады?', 'options': [{'id':'a','text':'бастауыш'},{'id':'b','text':'баяндауыш'},{'id':'c','text':'анықтауыш'},{'id':'d','text':'толықтауыш'}], 'correct': 'c'},
      {'text': 'Үндестік заңы дегеніміз:', 'options': [{'id':'a','text':'сөздердің дыбыстық үйлесуі'},{'id':'b','text':'сөйлемнің мағынасы'},{'id':'c','text':'сөздердің жасалуы'},{'id':'d','text':'сөздің буынға бөлінуі'}], 'correct': 'a'},
      {'text': '"Мектеп" сөзінің буын саны:', 'options': [{'id':'a','text':'1'},{'id':'b','text':'2'},{'id':'c','text':'3'},{'id':'d','text':'4'}], 'correct': 'b'},
      {'text': 'Шылау дегеніміз:', 'options': [{'id':'a','text':'заттың атын білдіреді'},{'id':'b','text':'сөздер мен сөйлемдерді байланыстырады'},{'id':'c','text':'қимылды білдіреді'},{'id':'d','text':'сынын білдіреді'}], 'correct': 'b'},
      {'text': '"Оқу" сөзінің бұйрық райы:', 'options': [{'id':'a','text':'оқыды'},{'id':'b','text':'оқисың'},{'id':'c','text':'оқы'},{'id':'d','text':'оқыған'}], 'correct': 'c'},
      {'text': 'Қай сөз антоним болады? "Биік":', 'options': [{'id':'a','text':'үлкен'},{'id':'b','text':'аласа'},{'id':'c','text':'кіші'},{'id':'d','text':'ұзын'}], 'correct': 'b'},
      {'text': '"Сен" есімдігі қай жаққа жатады?', 'options': [{'id':'a','text':'I жақ'},{'id':'b','text':'II жақ'},{'id':'c','text':'III жақ'},{'id':'d','text':'Жақсыз'}], 'correct': 'b'},
      {'text': 'Қай сөз синоним болады? "Жылдам":', 'options': [{'id':'a','text':'баяу'},{'id':'b','text':'тез'},{'id':'c','text':'ұзақ'},{'id':'d','text':'жай'}], 'correct': 'b'},
      {'text': 'Сан есімнің сұрағы:', 'options': [{'id':'a','text':'кім?'},{'id':'b','text':'қандай?'},{'id':'c','text':'қанша? нешінші?'},{'id':'d','text':'қалай?'}], 'correct': 'c'},
      {'text': 'Үстеудің сұрағы:', 'options': [{'id':'a','text':'кім? не?'},{'id':'b','text':'қандай?'},{'id':'c','text':'қалай? қашан? қайда?'},{'id':'d','text':'қанша?'}], 'correct': 'c'},
      {'text': '"Алматы — Қазақстанның ең үлкен қаласы." Баяндауыш:', 'options': [{'id':'a','text':'Алматы'},{'id':'b','text':'Қазақстанның'},{'id':'c','text':'ең үлкен қаласы'},{'id':'d','text':'үлкен'}], 'correct': 'c'},
      {'text': 'Қосымша дегеніміз:', 'options': [{'id':'a','text':'дербес мағынасы бар сөз'},{'id':'b','text':'сөзге жалғанып мағына үстейтін бөлік'},{'id':'c','text':'сөйлемнің басты мүшесі'},{'id':'d','text':'дыбыс тіркесімі'}], 'correct': 'b'},
    ],
  };

  // ═══════════════════════════════════════════════════════
  // АҒЫЛШЫН ТІЛІ — 20 сұрақ
  // ═══════════════════════════════════════════════════════
  static final _english = {
    'title': 'English Grammar Basics',
    'description': 'Ағылшын тілі грамматикасы — бастауыш деңгей',
    'category': 'english',
    'durationMinutes': 25,
    'questions': [
      {'text': '"Мен оқушымын" ағылшынша:', 'options': [{'id':'a','text':'I am a student'},{'id':'b','text':'I is a student'},{'id':'c','text':'I are student'},{'id':'d','text':'Me am student'}], 'correct': 'a'},
      {'text': 'To be етістігі "ол" үшін (he/she):', 'options': [{'id':'a','text':'am'},{'id':'b','text':'are'},{'id':'c','text':'is'},{'id':'d','text':'be'}], 'correct': 'c'},
      {'text': '"Кітап" ағылшынша:', 'options': [{'id':'a','text':'pen'},{'id':'b','text':'book'},{'id':'c','text':'bag'},{'id':'d','text':'desk'}], 'correct': 'b'},
      {'text': 'Present Simple. "Ол мектепке барады":', 'options': [{'id':'a','text':'He go to school'},{'id':'b','text':'He goes to school'},{'id':'c','text':'He going to school'},{'id':'d','text':'He went to school'}], 'correct': 'b'},
      {'text': 'Plural of "child":', 'options': [{'id':'a','text':'childs'},{'id':'b','text':'childes'},{'id':'c','text':'children'},{'id':'d','text':'childrens'}], 'correct': 'c'},
      {'text': '"Бүгін" ағылшынша:', 'options': [{'id':'a','text':'yesterday'},{'id':'b','text':'tomorrow'},{'id':'c','text':'today'},{'id':'d','text':'now'}], 'correct': 'c'},
      {'text': 'Past Simple of "go":', 'options': [{'id':'a','text':'goed'},{'id':'b','text':'goes'},{'id':'c','text':'going'},{'id':'d','text':'went'}], 'correct': 'd'},
      {'text': 'Артикль "an" қашан қолданылады?', 'options': [{'id':'a','text':'Дауыссыз дыбыстан басталған сөз алдында'},{'id':'b','text':'Дауысты дыбыстан басталған сөз алдында'},{'id':'c','text':'Кез келген жерде'},{'id':'d','text':'Ешқашан'}], 'correct': 'b'},
      {'text': '"Үлкен" ағылшынша:', 'options': [{'id':'a','text':'small'},{'id':'b','text':'tall'},{'id':'c','text':'big'},{'id':'d','text':'long'}], 'correct': 'c'},
      {'text': 'Future Simple. "Мен барамын":', 'options': [{'id':'a','text':'I go'},{'id':'b','text':'I went'},{'id':'c','text':'I will go'},{'id':'d','text':'I am going'}], 'correct': 'c'},
      {'text': '"Have got" не білдіреді?', 'options': [{'id':'a','text':'Барды'},{'id':'b','text':'Бар (иелену)'},{'id':'c','text':'Болды'},{'id':'d','text':'Алды'}], 'correct': 'b'},
      {'text': 'Comparative of "good":', 'options': [{'id':'a','text':'gooder'},{'id':'b','text':'more good'},{'id':'c','text':'better'},{'id':'d','text':'best'}], 'correct': 'c'},
      {'text': '"Мұғалім" ағылшынша:', 'options': [{'id':'a','text':'doctor'},{'id':'b','text':'teacher'},{'id':'c','text':'driver'},{'id':'d','text':'student'}], 'correct': 'b'},
      {'text': 'Сан есім: "бірінші" ағылшынша:', 'options': [{'id':'a','text':'one'},{'id':'b','text':'first'},{'id':'c','text':'once'},{'id':'d','text':'mono'}], 'correct': 'b'},
      {'text': '"There is / There are" айырмашылығы:', 'options': [{'id':'a','text':'There is — кем дегенде 2, there are — 1'},{'id':'b','text':'There is — 1 зат, there are — көп зат'},{'id':'c','text':'Айырмашылық жоқ'},{'id':'d','text':'There is — өткен шақ'}], 'correct': 'b'},
      {'text': 'Сұраулы сөйлем: "Сен оқушысың ба?":', 'options': [{'id':'a','text':'You are a student?'},{'id':'b','text':'Are you a student?'},{'id':'c','text':'Is you a student?'},{'id':'d','text':'Do you student?'}], 'correct': 'b'},
      {'text': '"Never" қандай шақпен жиі қолданылады?', 'options': [{'id':'a','text':'Past Simple'},{'id':'b','text':'Future Simple'},{'id':'c','text':'Present Simple'},{'id':'d','text':'Present Continuous'}], 'correct': 'c'},
      {'text': 'Passive Voice: "Кітап оқылды":', 'options': [{'id':'a','text':'The book read'},{'id':'b','text':'The book was read'},{'id':'c','text':'The book is read'},{'id':'d','text':'The book reads'}], 'correct': 'b'},
      {'text': '"Қызықты" ағылшынша:', 'options': [{'id':'a','text':'boring'},{'id':'b','text':'difficult'},{'id':'c','text':'interesting'},{'id':'d','text':'easy'}], 'correct': 'c'},
      {'text': 'Modal verb "must" не білдіреді?', 'options': [{'id':'a','text':'Мүмкін'},{'id':'b','text':'Міндетті'},{'id':'c','text':'Қалау'},{'id':'d','text':'Рұқсат'}], 'correct': 'b'},
    ],
  };

  // ═══════════════════════════════════════════════════════
  // ТАРИХ — 20 сұрақ
  // ═══════════════════════════════════════════════════════
  static final _history = {
    'title': 'Қазақстан тарихы',
    'description': 'Қазақстанның тарихи оқиғалары мен тұлғалары',
    'category': 'history',
    'durationMinutes': 25,
    'questions': [
      {'text': 'Қазақстан тəуелсіздігін қашан алды?', 'options': [{'id':'a','text':'1990'},{'id':'b','text':'1991'},{'id':'c','text':'1992'},{'id':'d','text':'1993'}], 'correct': 'b'},
      {'text': 'Қазақ хандығы қашан құрылды?', 'options': [{'id':'a','text':'1465'},{'id':'b','text':'1500'},{'id':'c','text':'1550'},{'id':'d','text':'1600'}], 'correct': 'a'},
      {'text': 'Қазақ хандығының негізін қалаушылар:', 'options': [{'id':'a','text':'Абылай мен Əбілқайыр'},{'id':'b','text':'Керей мен Жəнібек'},{'id':'c','text':'Тауке мен Есім'},{'id':'d','text':'Абай мен Шоқан'}], 'correct': 'b'},
      {'text': 'Абай Құнанбаев қай жылы туған?', 'options': [{'id':'a','text':'1840'},{'id':'b','text':'1845'},{'id':'c','text':'1850'},{'id':'d','text':'1855'}], 'correct': 'b'},
      {'text': 'Астана қаласы бұрын қалай аталды?', 'options': [{'id':'a','text':'Верный'},{'id':'b','text':'Акмола → Астана → Нұр-Сұлтан → Астана'},{'id':'c','text':'Семей'},{'id':'d','text':'Тараз'}], 'correct': 'b'},
      {'text': 'Шоқан Уəлиханов кім болды?', 'options': [{'id':'a','text':'Ақын'},{'id':'b','text':'Ғалым-зерттеуші, саяхатшы'},{'id':'c','text':'Хан'},{'id':'d','text':'Батыр'}], 'correct': 'b'},
      {'text': 'Үш жүз деп нені атайды?', 'options': [{'id':'a','text':'Қазақ хандықтарын'},{'id':'b','text':'Қазақтың ру бірлестіктерін'},{'id':'c','text':'Үш қаланы'},{'id':'d','text':'Үш батырды'}], 'correct': 'b'},
      {'text': 'Əнұранымыздың сөзін кім жазды?', 'options': [{'id':'a','text':'Абай'},{'id':'b','text':'Жансүгіров'},{'id':'c','text':'Жұмекен Нəжімеденов, Мұхтар Əлімбаев'},{'id':'d','text':'Сейфуллин'}], 'correct': 'c'},
      {'text': 'Қазақстанда ядролық сынақтар қай жерде жүргізілді?', 'options': [{'id':'a','text':'Байқоңыр'},{'id':'b','text':'Семей'},{'id':'c','text':'Балқаш'},{'id':'d','text':'Арал'}], 'correct': 'b'},
      {'text': 'Бірінші Президент:', 'options': [{'id':'a','text':'Қасым-Жомарт Тоқаев'},{'id':'b','text':'Нұрсұлтан Назарбаев'},{'id':'c','text':'Дінмұхамед Қонаев'},{'id':'d','text':'Жəңгір хан'}], 'correct': 'b'},
      {'text': 'Абылай хан қай ғасырда өмір сүрді?', 'options': [{'id':'a','text':'XVI ғасыр'},{'id':'b','text':'XVII ғасыр'},{'id':'c','text':'XVIII ғасыр'},{'id':'d','text':'XIX ғасыр'}], 'correct': 'c'},
      {'text': 'Байқоңыр ғарыш айлағы қай жылы іске қосылды?', 'options': [{'id':'a','text':'1955'},{'id':'b','text':'1957'},{'id':'c','text':'1960'},{'id':'d','text':'1965'}], 'correct': 'b'},
      {'text': 'Арал теңізі мəселесінің басты себебі:', 'options': [{'id':'a','text':'Жер сілкінісі'},{'id':'b','text':'Суармалу үшін судың артық алынуы'},{'id':'c','text':'Қуаңшылық'},{'id':'d','text':'Өнеркəсіп'}], 'correct': 'b'},
      {'text': 'Қазақстан БҰҰ-ға қай жылы кірді?', 'options': [{'id':'a','text':'1991'},{'id':'b','text':'1992'},{'id':'c','text':'1993'},{'id':'d','text':'1995'}], 'correct': 'b'},
      {'text': '"Зар заман" ағымының өкілі:', 'options': [{'id':'a','text':'Абай'},{'id':'b','text':'Шоқан'},{'id':'c','text':'Дулат Бабатайұлы'},{'id':'d','text':'Ыбырай'}], 'correct': 'c'},
      {'text': 'Ыбырай Алтынсарин нені ашты?', 'options': [{'id':'a','text':'Университет'},{'id':'b','text':'Алғашқы қазақ мектебін'},{'id':'c','text':'Кітапхана'},{'id':'d','text':'Театр'}], 'correct': 'b'},
      {'text': 'ЭКСПО-2017 қай қалада өтті?', 'options': [{'id':'a','text':'Алматы'},{'id':'b','text':'Шымкент'},{'id':'c','text':'Астана'},{'id':'d','text':'Семей'}], 'correct': 'c'},
      {'text': 'Қазақстанның ең ірі қаласы:', 'options': [{'id':'a','text':'Астана'},{'id':'b','text':'Шымкент'},{'id':'c','text':'Алматы'},{'id':'d','text':'Қарағанды'}], 'correct': 'c'},
      {'text': 'Жібек жолы не болды?', 'options': [{'id':'a','text':'Теміржол'},{'id':'b','text':'Байырғы сауда жолы'},{'id':'c','text':'Əскери жол'},{'id':'d','text':'Өзен'}], 'correct': 'b'},
      {'text': 'Қазақстан Конституциясы қай жылы қабылданды?', 'options': [{'id':'a','text':'1991'},{'id':'b','text':'1993'},{'id':'c','text':'1995'},{'id':'d','text':'1998'}], 'correct': 'c'},
    ],
  };

  // ═══════════════════════════════════════════════════════
  // ОРЫС ТІЛІ — 20 сұрақ
  // ═══════════════════════════════════════════════════════
  static final _russian = {
    'title': 'Русский язык — грамматика',
    'description': 'Орыс тілі грамматикасының негіздері',
    'category': 'russian',
    'durationMinutes': 25,
    'questions': [
      {'text': 'Сколько букв в русском алфавите?', 'options': [{'id':'a','text':'30'},{'id':'b','text':'32'},{'id':'c','text':'33'},{'id':'d','text':'35'}], 'correct': 'c'},
      {'text': 'Имя существительное отвечает на вопрос:', 'options': [{'id':'a','text':'какой?'},{'id':'b','text':'кто? что?'},{'id':'c','text':'что делает?'},{'id':'d','text':'сколько?'}], 'correct': 'b'},
      {'text': 'Какой знак препинания ставится в конце вопроса?', 'options': [{'id':'a','text':'.'},{'id':'b','text':'!'},{'id':'c','text':'?'},{'id':'d','text':','}], 'correct': 'c'},
      {'text': '"Солнце" — какого рода?', 'options': [{'id':'a','text':'мужской'},{'id':'b','text':'женский'},{'id':'c','text':'средний'},{'id':'d','text':'общий'}], 'correct': 'c'},
      {'text': 'Глагол отвечает на вопрос:', 'options': [{'id':'a','text':'кто? что?'},{'id':'b','text':'какой?'},{'id':'c','text':'что делать?'},{'id':'d','text':'сколько?'}], 'correct': 'c'},
      {'text': 'Синоним слова "большой":', 'options': [{'id':'a','text':'маленький'},{'id':'b','text':'огромный'},{'id':'c','text':'тихий'},{'id':'d','text':'быстрый'}], 'correct': 'b'},
      {'text': 'Антоним слова "холодный":', 'options': [{'id':'a','text':'морозный'},{'id':'b','text':'тёплый'},{'id':'c','text':'ледяной'},{'id':'d','text':'прохладный'}], 'correct': 'b'},
      {'text': 'Какое слово пишется с заглавной буквы?', 'options': [{'id':'a','text':'город'},{'id':'b','text':'москва'},{'id':'c','text':'Москва'},{'id':'d','text':'страна'}], 'correct': 'c'},
      {'text': 'Сколько гласных букв в русском языке?', 'options': [{'id':'a','text':'6'},{'id':'b','text':'10'},{'id':'c','text':'12'},{'id':'d','text':'8'}], 'correct': 'b'},
      {'text': 'Прилагательное описывает:', 'options': [{'id':'a','text':'действие'},{'id':'b','text':'признак предмета'},{'id':'c','text':'предмет'},{'id':'d','text':'количество'}], 'correct': 'b'},
      {'text': '"Я иду в школу" — время глагола:', 'options': [{'id':'a','text':'прошедшее'},{'id':'b','text':'настоящее'},{'id':'c','text':'будущее'},{'id':'d','text':'неопределённое'}], 'correct': 'b'},
      {'text': 'Корень слова "учитель":', 'options': [{'id':'a','text':'учи'},{'id':'b','text':'уч'},{'id':'c','text':'учит'},{'id':'d','text':'тель'}], 'correct': 'b'},
      {'text': 'Какое предложение восклицательное?', 'options': [{'id':'a','text':'Идёт дождь.'},{'id':'b','text':'Идёт ли дождь?'},{'id':'c','text':'Какой сильный дождь!'},{'id':'d','text':'Дождь идёт медленно.'}], 'correct': 'c'},
      {'text': 'Наречие отвечает на вопрос:', 'options': [{'id':'a','text':'кто?'},{'id':'b','text':'какой?'},{'id':'c','text':'где? когда? как?'},{'id':'d','text':'чей?'}], 'correct': 'c'},
      {'text': 'Мягкий знак обозначает:', 'options': [{'id':'a','text':'звук'},{'id':'b','text':'мягкость предыдущей согласной'},{'id':'c','text':'твёрдость'},{'id':'d','text':'гласный звук'}], 'correct': 'b'},
      {'text': '"Бежать" — это глагол какого вида?', 'options': [{'id':'a','text':'совершенный'},{'id':'b','text':'несовершенный'},{'id':'c','text':'средний'},{'id':'d','text':'переходный'}], 'correct': 'b'},
      {'text': 'Сколько падежей в русском языке?', 'options': [{'id':'a','text':'4'},{'id':'b','text':'5'},{'id':'c','text':'6'},{'id':'d','text':'7'}], 'correct': 'c'},
      {'text': 'Какое слово является существительным?', 'options': [{'id':'a','text':'красивый'},{'id':'b','text':'бежать'},{'id':'c','text':'книга'},{'id':'d','text':'быстро'}], 'correct': 'c'},
      {'text': 'Предлог — это:', 'options': [{'id':'a','text':'часть слова'},{'id':'b','text':'служебная часть речи'},{'id':'c','text':'самостоятельная часть речи'},{'id':'d','text':'окончание'}], 'correct': 'b'},
      {'text': 'В слове "молоко" сколько слогов?', 'options': [{'id':'a','text':'2'},{'id':'b','text':'3'},{'id':'c','text':'4'},{'id':'d','text':'1'}], 'correct': 'b'},
    ],
  };

  // ═══════════════════════════════════════════════════════
  // ЖАРАТЫЛЫСТАНУ — 20 сұрақ
  // ═══════════════════════════════════════════════════════
  static final _science = {
    'title': 'Жаратылыстану негіздері',
    'description': 'Физика, химия, биология негіздері',
    'category': 'science',
    'durationMinutes': 30,
    'questions': [
      {'text': 'Судың химиялық формуласы:', 'options': [{'id':'a','text':'CO₂'},{'id':'b','text':'H₂O'},{'id':'c','text':'O₂'},{'id':'d','text':'NaCl'}], 'correct': 'b'},
      {'text': 'Жарықтың жылдамдығы (км/с):', 'options': [{'id':'a','text':'100 000'},{'id':'b','text':'200 000'},{'id':'c','text':'300 000'},{'id':'d','text':'400 000'}], 'correct': 'c'},
      {'text': 'Адам ағзасындағы ең ұзын сүйек:', 'options': [{'id':'a','text':'Омыртқа'},{'id':'b','text':'Сан сүйек'},{'id':'c','text':'Қол сүйек'},{'id':'d','text':'Қабырға'}], 'correct': 'b'},
      {'text': 'Фотосинтез процесінде не бөлінеді?', 'options': [{'id':'a','text':'Көмірқышқыл газы'},{'id':'b','text':'Азот'},{'id':'c','text':'Оттегі'},{'id':'d','text':'Сутегі'}], 'correct': 'c'},
      {'text': 'Ньютонның бірінші заңы не туралы?', 'options': [{'id':'a','text':'Тартылыс'},{'id':'b','text':'Инерция'},{'id':'c','text':'Үдеу'},{'id':'d','text':'Энергия'}], 'correct': 'b'},
      {'text': 'Периодтық жүйені кім ашты?', 'options': [{'id':'a','text':'Эйнштейн'},{'id':'b','text':'Ньютон'},{'id':'c','text':'Менделеев'},{'id':'d','text':'Дарвин'}], 'correct': 'c'},
      {'text': 'Адамның жүрегі 1 минутта нешерет соғады (норма)?', 'options': [{'id':'a','text':'40-50'},{'id':'b','text':'60-80'},{'id':'c','text':'100-120'},{'id':'d','text':'20-30'}], 'correct': 'b'},
      {'text': 'Электр тогының бірлігі:', 'options': [{'id':'a','text':'Ватт'},{'id':'b','text':'Вольт'},{'id':'c','text':'Ампер'},{'id':'d','text':'Ом'}], 'correct': 'c'},
      {'text': 'ДНК нені білдіреді?', 'options': [{'id':'a','text':'Дезоксирибонуклеин қышқылы'},{'id':'b','text':'Динамикалық нуклеин қосылысы'},{'id':'c','text':'Дезоксирибоза нуклеотид кешені'},{'id':'d','text':'Диффузды нуклеин активаторы'}], 'correct': 'a'},
      {'text': 'Жер бетіндегі ең мол элемент:', 'options': [{'id':'a','text':'Темір'},{'id':'b','text':'Оттегі'},{'id':'c','text':'Кремний'},{'id':'d','text':'Алюминий'}], 'correct': 'b'},
      {'text': 'Жасуша теориясын кім ұсынды?', 'options': [{'id':'a','text':'Дарвин'},{'id':'b','text':'Шлейден мен Шванн'},{'id':'c','text':'Пастер'},{'id':'d','text':'Мендель'}], 'correct': 'b'},
      {'text': 'Қайнау температурасы (су, °C):', 'options': [{'id':'a','text':'90'},{'id':'b','text':'95'},{'id':'c','text':'100'},{'id':'d','text':'110'}], 'correct': 'c'},
      {'text': 'Масса бірлігі СИ жүйесінде:', 'options': [{'id':'a','text':'Грамм'},{'id':'b','text':'Килограмм'},{'id':'c','text':'Тонна'},{'id':'d','text':'Фунт'}], 'correct': 'b'},
      {'text': 'Хлорофилл нені сіңіреді?', 'options': [{'id':'a','text':'Су'},{'id':'b','text':'Жарық энергиясын'},{'id':'c','text':'Минерал'},{'id':'d','text':'Ауа'}], 'correct': 'b'},
      {'text': 'Атомның ядросы неден тұрады?', 'options': [{'id':'a','text':'Электрон мен протон'},{'id':'b','text':'Протон мен нейтрон'},{'id':'c','text':'Нейтрон мен электрон'},{'id':'d','text':'Тек протоннан'}], 'correct': 'b'},
      {'text': 'Күн жүйесіндегі ең үлкен планета:', 'options': [{'id':'a','text':'Сатурн'},{'id':'b','text':'Уран'},{'id':'c','text':'Юпитер'},{'id':'d','text':'Нептун'}], 'correct': 'c'},
      {'text': 'pH = 7 дегеніміз:', 'options': [{'id':'a','text':'Қышқылдық орта'},{'id':'b','text':'Сілтілік орта'},{'id':'c','text':'Бейтарап орта'},{'id':'d','text':'Тұздық орта'}], 'correct': 'c'},
      {'text': 'Адамда қанша хромосома бар?', 'options': [{'id':'a','text':'23'},{'id':'b','text':'46'},{'id':'c','text':'48'},{'id':'d','text':'44'}], 'correct': 'b'},
      {'text': 'Гравитация күшін кім ашты?', 'options': [{'id':'a','text':'Эйнштейн'},{'id':'b','text':'Галилей'},{'id':'c','text':'Ньютон'},{'id':'d','text':'Коперник'}], 'correct': 'c'},
      {'text': 'Вирус тірі ме əлде тірі емес пе?', 'options': [{'id':'a','text':'Тірі'},{'id':'b','text':'Тірі емес'},{'id':'c','text':'Жартылай тірі'},{'id':'d','text':'Өсімдікке жатады'}], 'correct': 'c'},
    ],
  };

  static final _allTests = [_math, _kazakh, _english, _history, _russian, _science];
}