import 'package:flutter/widgets.dart';

import '../../domain/models/activity.dart';
import '../theme/belong_colors.dart';
import '../theme/belong_typography.dart';
import 'belong_icons.dart';
import 'pills.dart';

/// UI-Zuordnung der Kategorien: zwei Ton-Familien (Koralle/Amber) statt
/// drei — weniger Farbrauschen. Jede Kategorie hat ihr eigenes Lucide-Icon.
extension ActivityCategoryStyle on ActivityCategory {
  Color get tint => switch (this) {
        ActivityCategory.draussen || ActivityCategory.essen => BelongColors.amberTint,
        ActivityCategory.tanzen ||
        ActivityCategory.musik ||
        ActivityCategory.spiele ||
        ActivityCategory.kaffee =>
          BelongColors.coralTint,
      };

  Color get deep => switch (this) {
        ActivityCategory.draussen || ActivityCategory.essen => BelongColors.amberDeep,
        ActivityCategory.tanzen ||
        ActivityCategory.musik ||
        ActivityCategory.spiele ||
        ActivityCategory.kaffee =>
          BelongColors.coralDeep,
      };

  BelongIconGlyph get glyph => switch (this) {
        ActivityCategory.draussen => BelongIconGlyph.tree,
        ActivityCategory.tanzen => BelongIconGlyph.dance,
        ActivityCategory.spiele => BelongIconGlyph.dice,
        ActivityCategory.musik => BelongIconGlyph.note,
        ActivityCategory.essen => BelongIconGlyph.utensils,
        ActivityCategory.kaffee => BelongIconGlyph.cup,
      };
}

/// Kategorie-Chip im Feed (getönt, mit Icon) bzw. als Filter (aktiv = Koralle).
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
      leading: category != null
          ? BelongIcon(category!.glyph, size: 15, color: foreground)
          : null,
      textStyle: BelongText.chip,
    );
  }
}

/// Auswahl-Chip im Erstellen-Formular: Outline, aktiv = Koralle gefüllt.
/// Mit [glyph] bekommt der Chip ein führendes Icon (z. B. Vor Ort/Online).
class PickerChip extends StatelessWidget {
  const PickerChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.glyph,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final BelongIconGlyph? glyph;

  @override
  Widget build(BuildContext context) {
    final foreground =
        selected ? const Color(0xFFFFFFFF) : BelongColors.inkSoft;
    return BelongPill(
      label: label,
      background: selected ? BelongColors.coral : BelongColors.card,
      foreground: foreground,
      border: selected ? null : Border.all(color: BelongColors.borderIdle),
      leading: glyph != null
          ? BelongIcon(glyph!, size: 15, color: foreground)
          : null,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      onTap: onTap,
    );
  }
}
