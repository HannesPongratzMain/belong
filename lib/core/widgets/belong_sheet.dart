import 'package:flutter/material.dart';

import '../theme/belong_colors.dart';
import '../theme/belong_dimens.dart';
import '../theme/belong_typography.dart';
import 'belong_icons.dart';
import 'pressable.dart';

/// Öffnet ein Bottom-Sheet im Belong-Stil: moderater Radius oben, Grabber,
/// dezenter Scrim. Wird für Erstellen, Auswahl-Listen und das Schutz-Sheet
/// verwendet.
Future<T?> showBelongSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool expand = false,
}) {
  return showModalBottomSheet<T>(
    context: context,
    barrierColor: BelongColors.scrim,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => _SheetShell(expand: expand, child: builder(context)),
  );
}

class _SheetShell extends StatelessWidget {
  const _SheetShell({required this.child, required this.expand});

  final Widget child;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        color: BelongColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(BelongRadii.sheet)),
      ),
      child: Column(
        mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
        children: [
          // Grabber
          Container(
            width: 44,
            height: 5,
            margin: const EdgeInsets.only(top: 10, bottom: 4),
            decoration: BoxDecoration(
              color: BelongColors.borderIdle,
              borderRadius: BelongRadii.pillAll,
            ),
          ),
          if (expand) Expanded(child: child) else Flexible(child: child),
        ],
      ),
    );
    if (!expand) return content;
    return FractionallySizedBox(heightFactor: 0.93, child: content);
  }
}

/// Kopfzeile eines Sheets: Serif-Titel, Subline, Close-Button.
class SheetHeader extends StatelessWidget {
  const SheetHeader({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          BelongSpacing.lg, BelongSpacing.sm, BelongSpacing.md, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: BelongText.sheetTitle),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: BelongText.body.copyWith(color: BelongColors.muted),
                  ),
                ],
              ],
            ),
          ),
          Pressable(
            onTap: () => Navigator.of(context).pop(),
            semanticLabel: 'Schließen',
            child: Container(
              width: BelongSpacing.hitTarget,
              height: BelongSpacing.hitTarget,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: BelongColors.header,
                shape: BoxShape.circle,
              ),
              child: const BelongIcon(BelongIconGlyph.close,
                  size: 18, color: BelongColors.inkSoft),
            ),
          ),
        ],
      ),
    );
  }
}
