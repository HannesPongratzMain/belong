import 'package:flutter/material.dart';

import '../theme/belong_colors.dart';
import '../theme/belong_dimens.dart';
import '../theme/belong_typography.dart';

/// Eingabefeld im Belong-Stil: weiße Fläche, Radius 16, Label darüber,
/// freundlicher Inline-Fehler (Beere, nie rotes Alarm-Design).
class BelongTextField extends StatelessWidget {
  const BelongTextField({
    super.key,
    required this.label,
    this.controller,
    this.placeholder,
    this.errorText,
    this.optionalHint,
    this.prefix,
    this.maxLines = 1,
    this.textInputAction,
    this.onChanged,
    this.autofocus = false,
  });

  final String label;
  final TextEditingController? controller;
  final String? placeholder;

  /// Fehlermeldung — aktiviert den 2-px-Beeren-Rahmen.
  final String? errorText;

  /// Zusatz hinter dem Label, z. B. „optional".
  final String? optionalHint;

  final Widget? prefix;
  final int maxLines;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Row(
            children: [
              Text(label, style: BelongText.label),
              if (optionalHint != null) ...[
                const SizedBox(width: 6),
                Text('· $optionalHint',
                    style: BelongText.meta.copyWith(color: BelongColors.muted)),
              ],
            ],
          ),
          const SizedBox(height: BelongSpacing.xs),
        ],
        AnimatedContainer(
          duration: BelongMotion.fast,
          decoration: BoxDecoration(
            color: BelongColors.card,
            borderRadius: BelongRadii.inputAll,
            border: Border.all(
              color: hasError ? BelongColors.berry : BelongColors.border,
              width: hasError ? 2 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: maxLines > 1
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: [
              if (prefix != null)
                Padding(
                  padding: const EdgeInsets.only(left: 14),
                  child: prefix,
                ),
              Expanded(
                child: TextField(
                  controller: controller,
                  maxLines: maxLines,
                  autofocus: autofocus,
                  textInputAction: textInputAction,
                  onChanged: onChanged,
                  style: BelongText.input,
                  cursorColor: BelongColors.coral,
                  decoration: InputDecoration(
                    hintText: placeholder,
                    hintStyle:
                        BelongText.input.copyWith(color: BelongColors.placeholder),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: prefix != null ? 10 : 16,
                      vertical: maxLines > 1 ? 14 : 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Text(
            errorText!,
            style: BelongText.chip.copyWith(color: BelongColors.berryDeep),
          ),
        ],
      ],
    );
  }
}
