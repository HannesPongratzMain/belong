import 'package:flutter/widgets.dart';

import '../theme/belong_colors.dart';
import '../theme/belong_dimens.dart';
import '../theme/belong_typography.dart';
import 'belong_icons.dart';
import 'pressable.dart';

/// Universelle Pill (Chips, Badges, Filter): Fläche + Text, Radius 999.
class BelongPill extends StatelessWidget {
  const BelongPill({
    super.key,
    required this.label,
    required this.background,
    required this.foreground,
    this.onTap,
    this.leading,
    this.trailing,
    this.textStyle,
    this.padding =
        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    this.border,
    this.shadows,
  });

  final String label;
  final Color background;
  final Color foreground;
  final VoidCallback? onTap;
  final Widget? leading;
  final Widget? trailing;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry padding;
  final BoxBorder? border;
  final List<BoxShadow>? shadows;

  @override
  Widget build(BuildContext context) {
    final pill = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BelongRadii.pillAll,
        border: border,
        boxShadow: shadows,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 5)],
          Text(
            label,
            style: (textStyle ?? BelongText.chip).copyWith(color: foreground),
          ),
          if (trailing != null) ...[const SizedBox(width: 5), trailing!],
        ],
      ),
    );
    if (onTap == null) return pill;
    return Pressable(onTap: onTap, semanticLabel: label, child: pill);
  }
}

/// Dropdown-Pill der FilterBar („Vorderer Westen ⌄").
class DropdownPill extends StatelessWidget {
  const DropdownPill({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return BelongPill(
      label: label,
      background: BelongColors.chipNeutral,
      foreground: BelongColors.inkSoft,
      onTap: onTap,
      trailing: const BelongIcon(
        BelongIconGlyph.chevronDown,
        size: 12,
        color: BelongColors.muted,
        strokeWidth: 3,
      ),
    );
  }
}
