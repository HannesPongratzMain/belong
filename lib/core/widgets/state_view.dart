import 'package:flutter/widgets.dart';

import '../theme/belong_colors.dart';
import '../theme/belong_dimens.dart';
import '../theme/belong_typography.dart';
import 'buttons.dart';

/// Illustrierter Zustand (Leer/Fehler/Erfolg): organischer Blob mit Symbol,
/// Serif-Titel, entlastender Text und genau ein CTA.
class StateView extends StatefulWidget {
  const StateView({
    super.key,
    required this.blobColor,
    required this.symbol,
    required this.title,
    required this.message,
    this.primaryLabel,
    this.onPrimary,
    this.ghostLabel,
    this.onGhost,
    this.beforePrimary,
    this.underTitle,
    this.titleStyle,
  });

  final Color blobColor;
  final Widget symbol;
  final String title;
  final String message;
  final String? primaryLabel;
  final VoidCallback? onPrimary;
  final String? ghostLabel;
  final VoidCallback? onGhost;

  /// Optionales Element zwischen Text und CTA (z. B. Doodle-Pfeil).
  final Widget? beforePrimary;

  /// Optionales Element direkt unter dem Titel (z. B. Squiggle).
  final Widget? underTitle;

  final TextStyle? titleStyle;

  @override
  State<StateView> createState() => _StateViewState();
}

class _StateViewState extends State<StateView>
    with SingleTickerProviderStateMixin {
  // Der Blob „poppt" kurz beim Erscheinen (Scale 0.8 → 1, overshoot).
  late final AnimationController _pop = AnimationController(
    vsync: this,
    duration: BelongMotion.pop,
  )..forward();

  @override
  void dispose() {
    _pop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
            horizontal: BelongSpacing.xl, vertical: BelongSpacing.lg),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 340),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScaleTransition(
                scale: CurvedAnimation(parent: _pop, curve: Curves.elasticOut)
                    .drive(Tween(begin: 0.8, end: 1.0)),
                child: Container(
                  width: 132,
                  height: 132,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: widget.blobColor,
                    borderRadius: BelongRadii.blob(132),
                  ),
                  child: widget.symbol,
                ),
              ),
              const SizedBox(height: BelongSpacing.lg),
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: widget.titleStyle ?? BelongText.displayTitle,
              ),
              if (widget.underTitle != null) ...[
                const SizedBox(height: 6),
                widget.underTitle!,
              ],
              const SizedBox(height: BelongSpacing.sm),
              Text(
                widget.message,
                textAlign: TextAlign.center,
                style: BelongText.body.copyWith(color: BelongColors.muted),
              ),
              if (widget.beforePrimary != null) widget.beforePrimary!,
              if (widget.primaryLabel != null) ...[
                const SizedBox(height: BelongSpacing.lg),
                PrimaryButton(
                  label: widget.primaryLabel!,
                  onTap: widget.onPrimary,
                  expanded: false,
                ),
              ],
              if (widget.ghostLabel != null) ...[
                const SizedBox(height: BelongSpacing.xs),
                GhostButton(label: widget.ghostLabel!, onTap: widget.onGhost),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
