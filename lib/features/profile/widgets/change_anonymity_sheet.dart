import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/belong_colors.dart';
import '../../../core/theme/belong_dimens.dart';
import '../../../core/theme/belong_typography.dart';
import '../../../core/widgets/belong_sheet.dart';
import '../../../core/widgets/belong_text_field.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/category_chip.dart';
import '../../../core/widgets/pressable.dart';
import '../../../domain/models/anonymity_level.dart';
import '../profile_controller.dart';

/// Stufe wechseln — jederzeit, ohne Nachfragen, ohne Datenverlust-Drama.
Future<void> showChangeAnonymitySheet(BuildContext context) {
  return showBelongSheet<void>(
    context: context,
    builder: (context) => const _ChangeAnonymitySheet(),
  );
}

class _ChangeAnonymitySheet extends ConsumerStatefulWidget {
  const _ChangeAnonymitySheet();

  @override
  ConsumerState<_ChangeAnonymitySheet> createState() =>
      _ChangeAnonymitySheetState();
}

class _ChangeAnonymitySheetState extends ConsumerState<_ChangeAnonymitySheet> {
  late AnonymityLevel _level;
  late final TextEditingController _nicknameController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileProvider).value;
    _level = profile?.anonymityLevel ?? AnonymityLevel.anonymous;
    _nicknameController = TextEditingController(text: profile?.nickname ?? '');
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final nickname = _nicknameController.text.trim();
    await ref.read(profileProvider.notifier).changeAnonymity(
          _level,
          nickname: nickname.isEmpty ? null : nickname,
        );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: BelongSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SheetHeader(
            title: 'Wie sichtbar willst du sein?',
            subtitle: 'Deine Wahl gilt sofort — nichts geht verloren.',
          ),
          const SizedBox(height: BelongSpacing.md),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: BelongSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final level in AnonymityLevel.values) ...[
                  _LevelRow(
                    level: level,
                    selected: _level == level,
                    onTap: () => setState(() => _level = level),
                  ),
                  const SizedBox(height: BelongSpacing.xs),
                ],
                if (_level != AnonymityLevel.anonymous) ...[
                  const SizedBox(height: BelongSpacing.xs),
                  BelongTextField(
                    label: 'Dein Spitzname',
                    controller: _nicknameController,
                  ),
                ],
                const SizedBox(height: BelongSpacing.md),
                PrimaryButton(
                    label: 'Übernehmen', loading: _saving, onTap: _save),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelRow extends StatelessWidget {
  const _LevelRow({
    required this.level,
    required this.selected,
    required this.onTap,
  });

  final AnonymityLevel level;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      pressedScale: 0.985,
      semanticLabel: level.label,
      child: AnimatedContainer(
        duration: BelongMotion.fast,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
            horizontal: BelongSpacing.md, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? BelongColors.coralWash : BelongColors.card,
          borderRadius: BelongRadii.inputAll,
          border: Border.all(
            color: selected ? BelongColors.coral : BelongColors.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Text(
          level.label,
          style: BelongText.input.copyWith(
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

/// Interessen bearbeiten (nur Stufe „Spitzname + Interessen").
Future<List<String>?> showInterestPickerSheet({
  required BuildContext context,
  required List<String> pool,
  required Set<String> selected,
}) {
  return showBelongSheet<List<String>>(
    context: context,
    builder: (context) => _InterestPicker(pool: pool, selected: selected),
  );
}

class _InterestPicker extends StatefulWidget {
  const _InterestPicker({required this.pool, required this.selected});

  final List<String> pool;
  final Set<String> selected;

  @override
  State<_InterestPicker> createState() => _InterestPickerState();
}

class _InterestPickerState extends State<_InterestPicker> {
  late final Set<String> _selection = {...widget.selected};

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: BelongSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SheetHeader(
            title: 'Worauf hast du Lust?',
            subtitle: 'Hilft beim Finden — bleibt trotzdem ohne Foto.',
          ),
          const SizedBox(height: BelongSpacing.md),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: BelongSpacing.md),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final interest in widget.pool)
                  PickerChip(
                    label: interest,
                    selected: _selection.contains(interest),
                    onTap: () => setState(() {
                      if (!_selection.add(interest)) {
                        _selection.remove(interest);
                      }
                    }),
                  ),
              ],
            ),
          ),
          const SizedBox(height: BelongSpacing.md),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: BelongSpacing.md),
            child: PrimaryButton(
              label: 'Übernehmen',
              onTap: () => Navigator.of(context).pop(_selection.toList()),
            ),
          ),
        ],
      ),
    );
  }
}
