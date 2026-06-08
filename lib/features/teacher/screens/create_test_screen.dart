import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/create_test_provider.dart';
import '../../test/models/test_model.dart';
import '../../test/models/question_model.dart';
import '../../../core/theme/app_theme.dart';

class CreateTestScreen extends ConsumerWidget {
  const CreateTestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(createTestProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (state.currentStep > 0) {
          ref.read(createTestProvider.notifier).goToStep(state.currentStep - 1);
        } else {
          final leave = await _showExitDialog(context);
          if (leave && context.mounted) context.pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          title: Text(_stepTitle(state.currentStep)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded),
            onPressed: () async {
              if (state.currentStep > 0) {
                ref.read(createTestProvider.notifier).goToStep(state.currentStep - 1);
              } else {
                final leave = await _showExitDialog(context);
                if (leave && context.mounted) context.pop();
              }
            },
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4),
            child: _StepProgressBar(currentStep: state.currentStep, totalSteps: 3),
          ),
        ),
        body: IndexedStack(
          index: state.currentStep,
          children: const [
            _Step1Info(),
            _Step2Questions(),
            _Step3Review(),
          ],
        ),
      ),
    );
  }

  String _stepTitle(int step) {
    switch (step) {
      case 0: return '1/3 — Тест ақпараты';
      case 1: return '2/3 — Сұрақтар';
      case 2: return '3/3 — Шолу';
      default: return 'Тест жасау';
    }
  }

  Future<bool> _showExitDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Шығу'),
            content: const Text('Барлық енгізілген деректер жоғалады. Шығасыз ба?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Жоқ')),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: AppTheme.error),
                child: const Text('Шығу'),
              ),
            ],
          ),
        ) ?? false;
  }
}

// ── Прогресс бар ──────────────────────────────────────────
class _StepProgressBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  const _StepProgressBar({required this.currentStep, required this.totalSteps});

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      value: (currentStep + 1) / totalSteps,
      backgroundColor: AppTheme.border,
      color: AppTheme.primary,
      minHeight: 4,
    );
  }
}

// ══════════════════════════════════════════════════════════
// ҚАДАМ 1: Тест ақпараты
// ══════════════════════════════════════════════════════════
class _Step1Info extends ConsumerStatefulWidget {
  const _Step1Info();

  @override
  ConsumerState<_Step1Info> createState() => _Step1InfoState();
}

class _Step1InfoState extends ConsumerState<_Step1Info> {
  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;

  @override
  void initState() {
    super.initState();
    final s = ref.read(createTestProvider);
    _titleCtrl = TextEditingController(text: s.title);
    _descCtrl = TextEditingController(text: s.description);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createTestProvider);
    final notifier = ref.read(createTestProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),

          _label('Тест атауы *'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _titleCtrl,
            onChanged: notifier.setTitle,
            maxLength: 80,
            decoration: const InputDecoration(
              hintText: 'Мысалы: Математика — 9-сынып, 1-тоқсан',
              prefixIcon: Icon(Icons.title, size: 20),
            ),
          ),

          const SizedBox(height: 16),

          _label('Сипаттама *'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _descCtrl,
            onChanged: notifier.setDescription,
            maxLines: 3,
            maxLength: 300,
            decoration: const InputDecoration(
              hintText: 'Тест мазмұны мен мақсаты туралы қысқаша жазыңыз',
              prefixIcon: Icon(Icons.description_outlined, size: 20),
            ),
          ),

          const SizedBox(height: 16),

          _label('Пəн / Категория'),
          const SizedBox(height: 8),
          _CategoryGrid(
            selected: state.category,
            onSelect: notifier.setCategory,
          ),

          const SizedBox(height: 16),

          _label('Уақыт шегі'),
          const SizedBox(height: 8),
          _DurationPicker(
            value: state.durationMinutes,
            onChanged: notifier.setDuration,
          ),

          const SizedBox(height: 32),

          ElevatedButton(
            onPressed: state.step1Valid
                ? () => notifier.goToStep(1)
                : null,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Сұрақтарды қосу'),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded, size: 18),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  final TestCategory selected;
  final void Function(TestCategory) onSelect;
  const _CategoryGrid({required this.selected, required this.onSelect});

  static const _items = [
    (TestCategory.math, 'Математика', '🔢'),
    (TestCategory.kazakh, 'Қазақ тілі', '📚'),
    (TestCategory.russian, 'Орыс тілі', '📖'),
    (TestCategory.english, 'Ағылшын', '🌍'),
    (TestCategory.history, 'Тарих', '🏛️'),
    (TestCategory.science, 'Жаратылыстану', '🔬'),
    (TestCategory.other, 'Басқа', '📝'),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _items.map((item) {
        final (cat, label, emoji) = item;
        final isSelected = selected == cat;
        return GestureDetector(
          onTap: () => onSelect(cat),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primary : AppTheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? AppTheme.primary : AppTheme.border,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _DurationPicker extends StatelessWidget {
  final int value;
  final void Function(int) onChanged;
  const _DurationPicker({required this.value, required this.onChanged});

  static const _options = [10, 15, 20, 30, 45, 60, 90];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: _options.map((min) {
        final isSelected = value == min;
        return GestureDetector(
          onTap: () => onChanged(min),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primary : AppTheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? AppTheme.primary : AppTheme.border,
              ),
            ),
            child: Text(
              '$min мин',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : AppTheme.textSecondary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ══════════════════════════════════════════════════════════
// ҚАДАМ 2: Сұрақтар
// ══════════════════════════════════════════════════════════
class _Step2Questions extends ConsumerWidget {
  const _Step2Questions();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(createTestProvider);
    final notifier = ref.read(createTestProvider.notifier);

    return Column(
      children: [
        // Жоғарғы статистика
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: AppTheme.surface,
          child: Row(
            children: [
              _chip(Icons.help_outline, '${state.questions.length} сұрақ', AppTheme.primary),
              const SizedBox(width: 12),
              _chip(Icons.star_outline, '${state.totalScore} балл', AppTheme.warning),
              const Spacer(),
              TextButton.icon(
                onPressed: notifier.addQuestion,
                icon: const Icon(Icons.add_circle_outline, size: 18),
                label: const Text('Қосу'),
                style: TextButton.styleFrom(foregroundColor: AppTheme.primary),
              ),
            ],
          ),
        ),

        // Сұрақтар тізімі
        Expanded(
          child: state.questions.isEmpty
              ? _buildEmpty(notifier)
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                  itemCount: state.questions.length,
                  itemBuilder: (_, i) => _QuestionCard(
                    index: i,
                    draft: state.questions[i],
                    total: state.questions.length,
                    notifier: notifier,
                  ),
                ),
        ),

        // Төменгі батырмалар
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            border: Border(top: BorderSide(color: AppTheme.border)),
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => notifier.goToStep(0),
                  child: const Text('← Артқа'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: state.step2Valid ? () => notifier.goToStep(2) : null,
                  child: const Text('Шолуға өту →'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmpty(CreateTestNotifier notifier) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.help_outline, size: 64, color: AppTheme.border),
          const SizedBox(height: 16),
          const Text('Сұрақ жоқ', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          const SizedBox(height: 8),
          Text('Тестке сұрақ қосыңыз', style: TextStyle(color: AppTheme.textSecondary)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: notifier.addQuestion,
            icon: const Icon(Icons.add),
            label: const Text('Сұрақ қосу'),
          ),
        ],
      ),
    );
  }

  Widget _chip(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _QuestionCard extends ConsumerStatefulWidget {
  final int index;
  final QuestionDraft draft;
  final int total;
  final CreateTestNotifier notifier;
  const _QuestionCard({required this.index, required this.draft, required this.total, required this.notifier});

  @override
  ConsumerState<_QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends ConsumerState<_QuestionCard> {
  bool _expanded = true;
  late TextEditingController _textCtrl;

  @override
  void initState() {
    super.initState();
    _textCtrl = TextEditingController(text: widget.draft.text);
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.draft;
    final n = widget.notifier;
    final hasError = q.text.trim().isEmpty || q.correctOptionIds.isEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasError && !_expanded ? AppTheme.error.withOpacity(0.5) : AppTheme.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Сұрақ тақырыбы (жию/ашу) ─────────────────
          InkWell(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text('${widget.index + 1}',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.primary)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      q.text.isEmpty ? 'Сұрақ мəтінін енгізіңіз...' : q.text,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: q.text.isEmpty ? AppTheme.textSecondary : AppTheme.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Жылжыту батырмалары
                  if (widget.index > 0)
                    GestureDetector(
                      onTap: () => n.moveUp(widget.index),
                      child: const Icon(Icons.keyboard_arrow_up_rounded, size: 20, color: AppTheme.textSecondary),
                    ),
                  if (widget.index < widget.total - 1)
                    GestureDetector(
                      onTap: () => n.moveDown(widget.index),
                      child: const Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: AppTheme.textSecondary),
                    ),
                  GestureDetector(
                    onTap: () => _confirmDelete(context),
                    child: const Icon(Icons.delete_outline, size: 20, color: AppTheme.error),
                  ),
                  const SizedBox(width: 4),
                  Icon(_expanded ? Icons.expand_less : Icons.expand_more, color: AppTheme.textSecondary, size: 20),
                ],
              ),
            ),
          ),

          // ── Ашылған мазмұн ─────────────────────────────
          if (_expanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Сұрақ мəтіні
                  TextFormField(
                    controller: _textCtrl,
                    onChanged: (v) => n.updateQuestionText(q.tempId, v),
                    maxLines: 2,
                    decoration: const InputDecoration(
                      hintText: 'Сұрақ мəтінін жазыңыз...',
                      prefixIcon: Icon(Icons.help_outline, size: 18),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Тип + Балл қатар
                  Row(
                    children: [
                      Expanded(child: _TypeSelector(draft: q, notifier: n)),
                      const SizedBox(width: 10),
                      _PointsPicker(draft: q, notifier: n),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Жауап нұсқалары
                  const Text('Жауап нұсқалары',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                  const SizedBox(height: 4),
                  Text(
                    q.type == QuestionType.multipleChoice
                        ? '✅ Бірнеше дұрыс жауапты белгілей аласыз'
                        : '✅ Бір дұрыс жауапты белгілеңіз',
                    style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 8),

                  ...q.options.asMap().entries.map((entry) {
                    final i = entry.key;
                    final opt = entry.value;
                    return _OptionRow(
                      index: i,
                      opt: opt,
                      questionId: q.tempId,
                      isCorrect: q.correctOptionIds.contains(opt.tempId),
                      canDelete: q.options.length > 2,
                      notifier: n,
                    );
                  }),

                  // Нұсқа қосу
                  if (q.options.length < 6)
                    TextButton.icon(
                      onPressed: () => n.addOption(q.tempId),
                      icon: const Icon(Icons.add_circle_outline, size: 16),
                      label: const Text('Нұсқа қосу'),
                      style: TextButton.styleFrom(foregroundColor: AppTheme.primary, padding: EdgeInsets.zero),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Сұрақты жою'),
        content: const Text('Бұл сұрақты жойғыңыз келе ме?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Болдырмау')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.notifier.removeQuestion(widget.draft.tempId);
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            child: const Text('Жою'),
          ),
        ],
      ),
    );
  }
}

class _TypeSelector extends StatelessWidget {
  final QuestionDraft draft;
  final CreateTestNotifier notifier;
  const _TypeSelector({required this.draft, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<QuestionType>(
      value: draft.type,
      decoration: const InputDecoration(
        labelText: 'Тип',
        prefixIcon: Icon(Icons.list_alt_outlined, size: 18),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      items: const [
        DropdownMenuItem(value: QuestionType.singleChoice, child: Text('Бір жауап', style: TextStyle(fontSize: 13))),
        DropdownMenuItem(value: QuestionType.multipleChoice, child: Text('Бірнеше жауап', style: TextStyle(fontSize: 13))),
        DropdownMenuItem(value: QuestionType.trueFalse, child: Text('Дұрыс/Қате', style: TextStyle(fontSize: 13))),
      ],
      onChanged: (v) {
        if (v != null) notifier.updateQuestionType(draft.tempId, v);
      },
    );
  }
}

class _PointsPicker extends StatelessWidget {
  final QuestionDraft draft;
  final CreateTestNotifier notifier;
  const _PointsPicker({required this.draft, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: draft.points > 1 ? () => notifier.updateQuestionPoints(draft.tempId, draft.points - 1) : null,
            child: Icon(Icons.remove, size: 18, color: draft.points > 1 ? AppTheme.primary : AppTheme.border),
          ),
          const SizedBox(width: 8),
          Text('${draft.points} балл', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: draft.points < 10 ? () => notifier.updateQuestionPoints(draft.tempId, draft.points + 1) : null,
            child: Icon(Icons.add, size: 18, color: draft.points < 10 ? AppTheme.primary : AppTheme.border),
          ),
        ],
      ),
    );
  }
}

class _OptionRow extends ConsumerStatefulWidget {
  final int index;
  final OptionDraft opt;
  final String questionId;
  final bool isCorrect;
  final bool canDelete;
  final CreateTestNotifier notifier;
  const _OptionRow({
    required this.index, required this.opt, required this.questionId,
    required this.isCorrect, required this.canDelete, required this.notifier,
  });

  @override
  ConsumerState<_OptionRow> createState() => _OptionRowState();
}

class _OptionRowState extends ConsumerState<_OptionRow> {
  late TextEditingController _ctrl;
  static const _letters = ['A', 'B', 'C', 'D', 'E', 'F'];

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.opt.text);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          // Дұрыс жауап белгісі
          GestureDetector(
            onTap: () => widget.notifier.toggleCorrectAnswer(widget.questionId, widget.opt.tempId),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: widget.isCorrect ? AppTheme.success : AppTheme.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: widget.isCorrect ? AppTheme.success : AppTheme.border),
              ),
              alignment: Alignment.center,
              child: widget.isCorrect
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : Text(
                      widget.index < _letters.length ? _letters[widget.index] : '${widget.index + 1}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textSecondary),
                    ),
            ),
          ),
          const SizedBox(width: 8),

          // Жауап мəтіні
          Expanded(
            child: TextFormField(
              controller: _ctrl,
              onChanged: (v) => widget.notifier.updateOptionText(widget.questionId, widget.opt.tempId, v),
              decoration: InputDecoration(
                hintText: 'Нұсқа ${widget.index + 1}',
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppTheme.border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppTheme.border)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.primary)),
              ),
            ),
          ),

          // Жою батырмасы
          if (widget.canDelete)
            IconButton(
              icon: Icon(Icons.close, size: 18, color: AppTheme.textSecondary),
              onPressed: () => widget.notifier.removeOption(widget.questionId, widget.opt.tempId),
              padding: const EdgeInsets.only(left: 4),
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
// ҚАДАМ 3: Шолу және сақтау
// ══════════════════════════════════════════════════════════
class _Step3Review extends ConsumerWidget {
  const _Step3Review();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(createTestProvider);
    final notifier = ref.read(createTestProvider.notifier);

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Тест ақпараты шолуы
                _ReviewSection(
                  title: 'Тест ақпараты',
                  onEdit: () => notifier.goToStep(0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _reviewRow('Атауы', state.title),
                      _reviewRow('Сипаттама', state.description),
                      _reviewRow('Категория', _categoryName(state.category)),
                      _reviewRow('Уақыт', '${state.durationMinutes} минут'),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Сұрақтар шолуы
                _ReviewSection(
                  title: 'Сұрақтар (${state.questions.length})',
                  onEdit: () => notifier.goToStep(1),
                  child: Column(
                    children: [
                      // Жылдам қорытынды
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _miniStat('Сұрақтар', '${state.questions.length}'),
                            _miniStat('Жалпы балл', '${state.totalScore}'),
                            _miniStat('Уақыт', '${state.durationMinutes} мин'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Əр сұрақтың жылдам шолуы
                      ...state.questions.asMap().entries.map((e) {
                        final i = e.key;
                        final q = e.value;
                        final isValid = q.text.trim().isNotEmpty && q.correctOptionIds.isNotEmpty;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: [
                              Icon(
                                isValid ? Icons.check_circle_rounded : Icons.error_rounded,
                                size: 16,
                                color: isValid ? AppTheme.success : AppTheme.error,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${i + 1}. ${q.text.isEmpty ? "Мəтін жоқ" : q.text}',
                                  style: TextStyle(fontSize: 13, color: AppTheme.textPrimary),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text('${q.points} б', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),

                // Қате хабарламасы
                if (state.error != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.error.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.error.withOpacity(0.3)),
                    ),
                    child: Text(state.error!, style: TextStyle(color: AppTheme.error, fontSize: 13)),
                  ),
                ],

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),

        // Сақтау батырмалары
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            border: Border(top: BorderSide(color: AppTheme.border)),
          ),
          child: Column(
            children: [
              // Белсенді жариялау
              ElevatedButton.icon(
                onPressed: state.isSaving ? null : () => _save(context, ref, asDraft: false),
                icon: state.isSaving
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.publish_rounded, size: 18),
                label: const Text('Жариялау (Белсенді)'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  backgroundColor: AppTheme.success,
                ),
              ),
              const SizedBox(height: 8),
              // Жоба ретінде сақтау
              OutlinedButton.icon(
                onPressed: state.isSaving ? null : () => _save(context, ref, asDraft: true),
                icon: const Icon(Icons.save_outlined, size: 18),
                label: const Text('Жоба ретінде сақтау'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => notifier.goToStep(1),
                style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
                child: const Text('← Артқа'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _save(BuildContext context, WidgetRef ref, {required bool asDraft}) async {
    final notifier = ref.read(createTestProvider.notifier);
    final testId = await notifier.saveTest(asDraft: asDraft);
    if (testId != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(asDraft ? 'Жоба сақталды!' : 'Тест жарияланды!'),
          backgroundColor: AppTheme.success,
        ),
      );
      notifier.reset();
      context.pop();
    }
  }

  Widget _reviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(label, style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.primary)),
        Text(label, style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
      ],
    );
  }

  String _categoryName(TestCategory c) {
    switch (c) {
      case TestCategory.math: return 'Математика';
      case TestCategory.kazakh: return 'Қазақ тілі';
      case TestCategory.russian: return 'Орыс тілі';
      case TestCategory.english: return 'Ағылшын тілі';
      case TestCategory.history: return 'Тарих';
      case TestCategory.science: return 'Жаратылыстану';
      case TestCategory.other: return 'Басқа';
    }
  }
}

class _ReviewSection extends StatelessWidget {
  final String title;
  final VoidCallback onEdit;
  final Widget child;
  const _ReviewSection({required this.title, required this.onEdit, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
              const Spacer(),
              GestureDetector(
                onTap: onEdit,
                child: const Text('Өзгерту', style: TextStyle(fontSize: 13, color: AppTheme.primary, fontWeight: FontWeight.w500)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

Widget _label(String text) => Text(
  text,
  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.textPrimary),
);
