import 'package:flutter/widgets.dart';

import '../../domain/models/activity.dart';
import '../theme/belong_colors.dart';
import '../theme/belong_typography.dart';
import 'belong_icons.dart';
import 'pills.dart';

/// UI-Zuordnung der Kategorien (Chip-Farben laut Handoff, alle gleichrangig).
extension ActivityCategoryStyle on ActivityCategory {
  Color get tint => switch (this) {
        ActivityCategory.tanzen || ActivityCategory.musik => BelongColors.berryTint,
        ActivityCategory.draussen || ActivityCategory.essen => BelongColors.amberTint,
        ActivityCategory.spiele || ActivityCategory.kaffee => BelongColors.coralTint,
      };

  Color get deep => switch (this) {
        ActivityCategory.tanzen || ActivityCategory.musik => BelongColors.berryDeep,
        ActivityCategory.draussen || ActivityCategory.essen => BelongColors.amberDeep,
        ActivityCategory.spiele || ActivityCategory.kaffee => BelongColors.coralDeep,
      };

  BelongIconGlyph get glyph => switch (this) {
        ActivityCategory.draussen => BelongIconGlyph.pin,
        ActivityCategory.tanzen || ActivityCategory.musik => BelongIconGlyph.note,
        ActivityCategory.spiele => BelongIconGlyph.dice,
        ActivityCategory.essen || ActivityCategory.kaffee => BelongIconGlyph.cup,
      };
}

/// Kategorie-Chip im Feed (getönt) bzw. als Filter (aktiv = Koralle).
class CategoryChip extends StatelessWidget {
  const CategoryChip({
    super.key,
    required this.label,
    this.category,
    this.selected = false,
    this.onTap,
  });

  /// `null` = „Alle".
  final ActivityCategory? category;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color background;
    final Color foreground;
    if (selected) {
      background = BelongColors.coral;
      foreground = const Color(0xFFFFFFFF);
    } else if (category != null) {
      background = category!.tint;
      foreground = category!.deep;
    } else {
      background = BelongColors.chipNeutral;
      foreground = BelongColors.inkSoft;
    }
    return BelongPill(
      label: label,
      background: background,
      foreground: foreground,
      onTap: onTap,
      textStyle: BelongText.chip,
    );
  }
}

/// Auswahl-Chip im Erstellen-Formular: Outline, aktiv = Koralle gefüllt.
class PickerChip extends StatelessWidget {
  const PickerChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return BelongPill(
      label: label,
      background: selected ? BelongColors.coral : BelongColors.card,
      foreground: selected ? const Color(0xFFFFFFFF) : BelongColors.inkSoft,
      border: selected ? null : Border.all(color: BelongColors.borderIdle),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      onTap: onTap,
    );
  }
}
