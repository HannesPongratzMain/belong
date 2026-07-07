import 'package:flutter/widgets.dart';

import '../theme/belong_colors.dart';
import '../theme/belong_dimens.dart';
import '../theme/belong_typography.dart';
import 'buttons.dart';

/// Zustand (Leer/Fehler/Erfolg): ruhige Symbol-Fläche, Titel,
/// entlastender Text und genau ein CTA.
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
  final TextStyle? titleStyle;

  @override
  State<StateView> createState() => _StateViewState();
}

class _StateViewState extends State<StateView>
    with SingleTickerProviderStateMixin {
  // Sanftes Einblenden der Symbol-Fläche (kein Overshoot).
  late final AnimationController _appear = AnimationController(
    vsync: this,
    duration: BelongMotion.medium,
  )..forward();

  @override
  void dispose() {
    _appear.dispose();
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
              FadeTransition(
                opacity:
                    CurvedAnimation(parent: _appear, curve: BelongMotion.curve),
                child: Container(
                  width: 120,
                  height: 120,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: widget.blobColor,
                    shape: BoxShape.circle,
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
              const SizedBox(height: BelongSpacing.sm),
              Text(
                widget.message,
                textAlign: TextAlign.center,
                style: BelongText.body.copyWith(color: BelongColors.muted),
              ),
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
