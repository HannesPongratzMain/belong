import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/belong_colors.dart';
import '../../../core/theme/belong_dimens.dart';
import '../../../core/theme/belong_typography.dart';
import '../../../core/widgets/belong_icons.dart';
import '../../../core/widgets/belong_sheet.dart';
import '../../../core/widgets/belong_text_field.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/category_chip.dart';
import '../../../core/widgets/pressable.dart';
import '../chat_controller.dart';

const _minPollOptions = 2;
const _maxPollOptions = 6;

/// Öffnet „Umfrage erstellen" — nur für den Host erreichbar (siehe
/// `canCreatePoll` in `chat_controller.dart`).
Future<void> showCreatePollSheet({
  required BuildContext context,
  required String activityId,
}) {
  return showBelongSheet<void>(
    context: context,
    expand: true,
    builder: (_) => _CreatePollSheet(activityId: activityId),
  );
}

class _CreatePollSheet extends ConsumerStatefulWidget {
  const _CreatePollSheet({required this.activityId});

  final String activityId;

  @override
  ConsumerState<_CreatePollSheet> createState() => _CreatePollSheetState();
}

class _CreatePollSheetState extends ConsumerState<_CreatePollSheet> {
  final _questionController = TextEditingController();
  final List<TextEditingController> _optionControllers = [
    TextEditingController(),
    TextEditingController(),
  ];
  bool _allowMultiple = false;
  bool _submitting = false;

  @override
  void dispose() {
    _questionController.dispose();
    for (final controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  bool get _canSubmit =>
      _questionController.text.trim().isNotEmpty &&
      _optionControllers.where((c) => c.text.trim().isNotEmpty).length >=
          _minPollOptions;

  void _addOption() {
    if (_optionControllers.length >= _maxPollOptions) return;
    setState(() => _optionControllers.add(TextEditingController()));
  }

  void _removeOption(int index) {
    if (_optionControllers.length <= _minPollOptions) return;
    setState(() => _optionControllers.removeAt(index).dispose());
  }

  Future<void> _submit() async {
    final options = _optionControllers
        .map((c) => c.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();
    setState(() => _submitting = true);
    await ref.read(chatActionsProvider).createPoll(
          widget.activityId,
          question: _questionController.text.trim(),
          options: options,
          allowMultiple: _allowMultiple,
        );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SheetHeader(
          title: 'Umfrage erstellen',
          subtitle: 'Frag die Gruppe, was ansteht — 2 bis 6 Optionen.',
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(BelongSpacing.lg,
                BelongSpacing.md, BelongSpacing.lg, BelongSpacing.xl),
            children: [
              BelongTextField(
                label: 'Frage',
                controller: _questionController,
                placeholder: 'z. B. Welcher Tag passt?',
                maxLength: 200,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: BelongSpacing.md),
              Text('Optionen', style: BelongText.label),
              const SizedBox(height: BelongSpacing.xs),
              for (final (index, controller) in _optionControllers.indexed)
                Padding(
                  padding: const EdgeInsets.only(bottom: BelongSpacing.xs),
                  child: Row(
                    children: [
                      Expanded(
                        child: BelongTextField(
                          label: '',
                          controller: controller,
                          placeholder: 'Option ${index + 1}',
                          maxLength: 80,
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      if (_optionControllers.length > _minPollOptions) ...[
                        const SizedBox(width: 6),
                        Pressable(
                          onTap: () => _removeOption(index),
                          semanticLabel: 'Option ${index + 1} entfernen',
                          child: Container(
                            width: 40,
                            height: 40,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                                color: BelongColors.header, shape: BoxShape.circle),
                            child: const BelongIcon(BelongIconGlyph.minus,
                                size: 16, color: BelongColors.inkSoft),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              if (_optionControllers.length < _maxPollOptions)
                Pressable(
                  onTap: _addOption,
                  semanticLabel: 'Option hinzufügen',
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const BelongIcon(BelongIconGlyph.plus,
                            size: 16, color: BelongColors.coralDeep),
                        const SizedBox(width: 6),
                        Text('Option hinzufügen',
                            style: BelongText.buttonSmall
                                .copyWith(color: BelongColors.coralDeep)),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: BelongSpacing.md),
              Text('Antwortmodus', style: BelongText.label),
              const SizedBox(height: BelongSpacing.xs),
              Row(
                children: [
                  PickerChip(
                    label: 'Einfachauswahl',
                    selected: !_allowMultiple,
                    onTap: () => setState(() => _allowMultiple = false),
                  ),
                  const SizedBox(width: 6),
                  PickerChip(
                    label: 'Mehrfachauswahl',
                    selected: _allowMultiple,
                    onTap: () => setState(() => _allowMultiple = true),
                  ),
                ],
              ),
              const SizedBox(height: BelongSpacing.lg),
              PrimaryButton(
                label: 'Umfrage starten',
                loading: _submitting,
                onTap: _canSubmit ? _submit : null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
