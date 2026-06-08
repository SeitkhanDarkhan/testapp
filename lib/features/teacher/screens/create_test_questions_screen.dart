import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/create_test_provider.dart';
import '../../test/models/question_model.dart';
import '../../../core/theme/app_theme.dart';

class CreateTestQuestionsScreen extends ConsumerWidget {
  const CreateTestQuestionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(createTestProvider);
    final notifier = ref.read(createTestProvider.notifier);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text('Сұрақтар (${state.questions.length})'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: 2 / 3,
            backgroundColor: AppTheme.border,
            color: AppTheme.primary,
            minHeight: 4,
          ),
        ),
        actions: [
          if (state.questions.isNotEmpty)
            TextButton(
              onPressed: () => notifier.goToStep(2),
              child: const Text('Əрі қарай →',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
        ],
      ),
      body: state.questions.isEmpty
          ? _buildEmpty(context, notifier)
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
              itemCount: state.questions.length,
              itemBuilder: (_, i) => _QuestionCard(
                index: i,
                draft: state.questions[i],
                total: state.questions.length,
                notifier: notifier,
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: notifier.addQuestion,
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Сұрақ қосу',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context, CreateTestNotifier notifier) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.help_outline, size: 72, color: AppTheme.border),
          const SizedBox(height: 16),
          const Text('Сұрақтар жоқ',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary)),
          const SizedBox(height: 8),
          Text(
            'Төмендегі батырманы басып\nбірінші сұрақты қосыңыз',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 14, color: AppTheme.textSecondary, height: 1.5),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: notifier.addQuestion,
            icon: const Icon(Icons.add),
            label: const Text('Бірінші сұрақты қосу'),
          ),
        ],
      ),
    );
  }
}

// ── Сұрақ карточкасы ──────────────────────────────────────
class _QuestionCard extends ConsumerStatefulWidget {
  final int index;
  final QuestionDraft draft;
  final int total;
  final CreateTestNotifier notifier;
  const _QuestionCard(
      {required this.index,
      required this.draft,
      required this.total,
      required this.notifier});

  @override
  ConsumerState<_QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends ConsumerState<_QuestionCard> {
  late final TextEditingController _questionCtrl;
  late final List<TextEditingController> _optionCtrls;
  bool _isExpanded = true;

  @override
  void initState() {
    super.initState();
    _questionCtrl = TextEditingController(text: widget.draft.text);
    _optionCtrls = widget.draft.options
        .map((o) => TextEditingController(text: o.text))
        .toList();
  }

  @override
  void dispose() {
    _questionCtrl.dispose();
    for (final c in _optionCtrls) c.dispose();
    super.dispose();
  }

  // QuestionDraft валидациясы — жергілікті
  bool get _isValid =>
      widget.draft.text.trim().isNotEmpty &&
      widget.draft.correctOptionIds.isNotEmpty &&
      widget.draft.options.length >= 2;

  @override
  Widget build(BuildContext context) {
    final draft = widget.draft;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isValid
              ? AppTheme.border
              : AppTheme.error.withOpacity(0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Карточка header ──────────────────────────
          GestureDetector(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.vertical(
                  top: const Radius.circular(15),
                  bottom: _isExpanded
                      ? Radius.zero
                      : const Radius.circular(15),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: _isValid ? AppTheme.primary : AppTheme.border,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text('${widget.index + 1}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      draft.text.isEmpty
                          ? 'Сұрақ ${widget.index + 1}'
                          : draft.text,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: draft.text.isEmpty
                            ? AppTheme.textSecondary
                            : AppTheme.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Жылжыту
                  if (widget.index > 0)
                    GestureDetector(
                      onTap: () => widget.notifier.moveUp(widget.index),
                      child: const Icon(Icons.keyboard_arrow_up_rounded,
                          size: 20, color: AppTheme.textSecondary),
                    ),
                  if (widget.index < widget.total - 1)
                    GestureDetector(
                      onTap: () => widget.notifier.moveDown(widget.index),
                      child: const Icon(Icons.keyboard_arrow_down_rounded,
                          size: 20, color: AppTheme.textSecondary),
                    ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: AppTheme.error, size: 20),
                    onPressed: () => _confirmDelete(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: AppTheme.textSecondary,
                  ),
                ],
              ),
            ),
          ),

          if (_isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Сұрақ мəтіні
                  _label('Сұрақ мəтіні *'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _questionCtrl,
                    // ✅ tempId пайдаланамыз
                    onChanged: (v) => widget.notifier
                        .updateQuestionText(draft.tempId, v),
                    maxLines: 2,
                    decoration: const InputDecoration(
                        hintText: 'Сұрақты жазыңыз...'),
                  ),

                  const SizedBox(height: 16),

                  // Сұрақ типі
                  _label('Сұрақ типі'),
                  const SizedBox(height: 8),
                  _QuestionTypeSelector(
                    selected: draft.type,
                    // ✅ tempId пайдаланамыз
                    onChanged: (t) => widget.notifier
                        .updateQuestionType(draft.tempId, t),
                  ),

                  const SizedBox(height: 16),

                  // Жауап нұсқалары
                  Row(
                    children: [
                      _label('Жауап нұсқалары *'),
                      const SizedBox(width: 8),
                      Text(
                        draft.type == QuestionType.multipleChoice
                            ? '(бірнешеуін белгілеңіз)'
                            : '(біреуін белгілеңіз)',
                        style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  ...draft.options.asMap().entries.map((entry) {
                    final i = entry.key;
                    final opt = entry.value;
                    if (i >= _optionCtrls.length) return const SizedBox();
                    final isCorrect =
                        draft.correctOptionIds.contains(opt.tempId);

                    return _OptionRow(
                      index: i,
                      controller: _optionCtrls[i],
                      isCorrect: isCorrect,
                      isDisabled:
                          draft.type == QuestionType.trueFalse,
                      questionType: draft.type,
                      onTextChanged: (v) => widget.notifier
                          // ✅ tempId пайдаланамыз
                          .updateOptionText(draft.tempId, opt.tempId, v),
                      onToggleCorrect: () => widget.notifier
                          // ✅ tempId пайдаланамыз
                          .toggleCorrectAnswer(draft.tempId, opt.tempId),
                    );
                  }),

                  const SizedBox(height: 16),

                  // Балл
                  Row(
                    children: [
                      _label('Балл:'),
                      const SizedBox(width: 12),
                      _PointsSelector(
                        value: draft.points,
                        // ✅ updateQuestionPoints пайдаланамыз (updatePoints емес)
                        onChanged: (v) => widget.notifier
                            .updateQuestionPoints(draft.tempId, v),
                      ),
                    ],
                  ),

                  // Валидация ескертуі
                  if (!_isValid) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.error.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: AppTheme.error.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber_outlined,
                              color: AppTheme.error, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              draft.text.isEmpty
                                  ? 'Сұрақ мəтінін енгізіңіз'
                                  : draft.correctOptionIds.isEmpty
                                      ? 'Кем дегенде бір дұрыс жауапты белгілеңіз'
                                      : 'Кем дегенде 2 нұсқа толтырылуы керек',
                              style: TextStyle(
                                  fontSize: 12, color: AppTheme.error),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _label(String text) => Text(text,
      style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppTheme.textPrimary));

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Сұрақты жою'),
        content: const Text('Бұл сұрақты жойғыңыз келе ме?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Болдырмау')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // ✅ tempId пайдаланамыз
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

class _QuestionTypeSelector extends StatelessWidget {
  final QuestionType selected;
  final ValueChanged<QuestionType> onChanged;
  const _QuestionTypeSelector(
      {required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _typeChip(QuestionType.singleChoice, 'Бір жауап',
            Icons.radio_button_checked),
        const SizedBox(width: 8),
        _typeChip(QuestionType.multipleChoice, 'Бірнеше',
            Icons.check_box_outlined),
        const SizedBox(width: 8),
        _typeChip(
            QuestionType.trueFalse, 'Дұрыс/Қате', Icons.swap_horiz_rounded),
      ],
    );
  }

  Widget _typeChip(QuestionType type, String label, IconData icon) {
    final isSelected = selected == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primary.withOpacity(0.08)
                : AppTheme.background,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color:
                    isSelected ? AppTheme.primary : AppTheme.border,
                width: isSelected ? 1.5 : 1),
          ),
          child: Column(
            children: [
              Icon(icon,
                  size: 18,
                  color: isSelected
                      ? AppTheme.primary
                      : AppTheme.textSecondary),
              const SizedBox(height: 3),
              Text(label,
                  style: TextStyle(
                      fontSize: 10,
                      color: isSelected
                          ? AppTheme.primary
                          : AppTheme.textSecondary,
                      fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  final int index;
  final TextEditingController controller;
  final bool isCorrect;
  final bool isDisabled;
  final QuestionType questionType;
  final ValueChanged<String> onTextChanged;
  final VoidCallback onToggleCorrect;
  const _OptionRow({
    required this.index,
    required this.controller,
    required this.isCorrect,
    required this.isDisabled,
    required this.questionType,
    required this.onTextChanged,
    required this.onToggleCorrect,
  });

  static const _letters = ['A', 'B', 'C', 'D', 'E', 'F'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: onToggleCorrect,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isCorrect ? AppTheme.success : AppTheme.background,
                borderRadius:
                    questionType == QuestionType.multipleChoice
                        ? BorderRadius.circular(6)
                        : BorderRadius.circular(16),
                border: Border.all(
                    color: isCorrect
                        ? AppTheme.success
                        : AppTheme.border),
              ),
              alignment: Alignment.center,
              child: isCorrect
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : Text(
                      index < _letters.length
                          ? _letters[index]
                          : '${index + 1}',
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary),
                    ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextFormField(
              controller: controller,
              onChanged: onTextChanged,
              enabled: !isDisabled,
              decoration: InputDecoration(
                hintText: isDisabled
                    ? ''
                    : '${index < _letters.length ? _letters[index] : (index + 1)} нұсқасы...',
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PointsSelector extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  const _PointsSelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: value > 1 ? () => onChanged(value - 1) : null,
          icon: const Icon(Icons.remove_circle_outline),
          color: AppTheme.primary,
          iconSize: 22,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        const SizedBox(width: 12),
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text('$value',
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary)),
        ),
        const SizedBox(width: 12),
        IconButton(
          onPressed: value < 10 ? () => onChanged(value + 1) : null,
          icon: const Icon(Icons.add_circle_outline),
          color: AppTheme.primary,
          iconSize: 22,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }
}
