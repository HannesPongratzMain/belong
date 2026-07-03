import 'package:flutter/widgets.dart';

import '../theme/belong_colors.dart';
import '../theme/belong_dimens.dart';
import '../theme/belong_typography.dart';
import 'belong_sheet.dart';
import 'pressable.dart';

/// Auswahl-Sheet für Dropdown-Pills (Ort, Zeitraum, Tag, Uhrzeit):
/// Liste aus Pill-Rows, aktuelle Auswahl mit Koralle-Punkt markiert.
Future<T?> showOptionSheet<T>({
  required BuildContext context,
  required String title,
  required List<T> options,
  required String Function(T) labelOf,
  T? selected,
}) {
  return showBelongSheet<T>(
    context: context,
    builder: (context) => _OptionList<T>(
      title: title,
      options: options,
      labelOf: labelOf,
      selected: selected,
    ),
  );
}

class _OptionList<T> extends StatelessWidget {
  const _OptionList({
    required this.title,
    required this.options,
    required this.labelOf,
    required this.selected,
  });

  final String title;
  final List<T> options;
  final String Function(T) labelOf;
  final T? selected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: BelongSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SheetHeader(title: title),
          const SizedBox(height: BelongSpacing.sm),
          for (final option in options)
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: BelongSpacing.md, vertical: 4),
              child: _OptionRow(
                label: labelOf(option),
                selected: option == selected,
                onTap: () => Navigator.of(context).pop(option),
              ),
            ),
        ],
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      semanticLabel: label,
      child: Container(
        constraints: const BoxConstraints(minHeight: BelongSpacing.hitTarget),
        padding: const EdgeInsets.symmetric(horizontal: BelongSpacing.md),
        decoration: BoxDecoration(
          color: selected ? BelongColors.coralWash : BelongColors.card,
          borderRadius: BelongRadii.inputAll,
          border: Border.all(
            color: selected ? BelongColors.coral : BelongColors.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: BelongText.input.copyWith(
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
            _RadioDot(selected: selected),
          ],
        ),
      ),
    );
  }
}

/// Radio-Punkt wie im Onboarding: Koralle gefüllt bzw. idle Ring.
class _RadioDot extends StatelessWidget {
  const _RadioDot({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: BelongMotion.fast,
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? BelongColors.coral : BelongColors.borderIdle,
          width: 2,
        ),
      ),
      alignment: Alignment.center,
      child: selected
          ? Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: BelongColors.coral,
              ),
            )
          : null,
    );
  }
}
