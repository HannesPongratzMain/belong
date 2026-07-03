import 'package:flutter/widgets.dart';

import '../theme/belong_colors.dart';
import '../theme/belong_dimens.dart';
import '../theme/belong_shadows.dart';
import '../theme/belong_typography.dart';
import 'pressable.dart';

/// Primär-Button: Koralle, Pill, Glow. Genau **einer** pro Screen.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.onTap,
    this.expanded = true,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onTap;
  final bool expanded;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null && !loading;
    final button = Pressable(
      onTap: enabled ? onTap : null,
      semanticLabel: label,
      child: AnimatedOpacity(
        duration: BelongMotion.fast,
        opacity: enabled ? 1 : 0.55,
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: BelongSpacing.lg),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: BelongColors.coral,
            borderRadius: BelongRadii.pillAll,
            boxShadow: enabled ? BelongShadows.coralGlow : null,
          ),
          child: loading
              ? const _ButtonDots()
              : Text(
                  label,
                  style: BelongText.button.copyWith(color: const Color(0xFFFFFFFF)),
                ),
        ),
      ),
    );
    return expanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// Sekundär: neutral erhabene weiße Pill.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    this.onTap,
    this.expanded = true,
  });

  final String label;
  final VoidCallback? onTap;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final button = Pressable(
      onTap: onTap,
      semanticLabel: label,
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: BelongSpacing.lg),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: BelongColors.card,
          borderRadius: BelongRadii.pillAll,
          border: Border.all(color: BelongColors.border),
          boxShadow: BelongShadows.e1,
        ),
        child: Text(
          label,
          style: BelongText.buttonSmall.copyWith(color: BelongColors.inkSoft),
        ),
      ),
    );
    return expanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// Ghost: nur Text, für nachgeordnete Aktionen.
class GhostButton extends StatelessWidget {
  const GhostButton({super.key, required this.label, this.onTap, this.color});

  final String label;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      semanticLabel: label,
      child: Container(
        constraints: const BoxConstraints(minHeight: BelongSpacing.hitTarget),
        padding: const EdgeInsets.symmetric(
            horizontal: BelongSpacing.md, vertical: BelongSpacing.sm),
        alignment: Alignment.center,
        child: Text(
          label,
          style: BelongText.buttonSmall
              .copyWith(color: color ?? BelongColors.inkSoft),
        ),
      ),
    );
  }
}

/// Drei pulsierende Punkte als Lade-Indikator im Button (kein Spinner).
class _ButtonDots extends StatefulWidget {
  const _ButtonDots();

  @override
  State<_ButtonDots> createState() => _ButtonDotsState();
}

class _ButtonDotsState extends State<_ButtonDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        double opacityFor(int index) {
          final phase = (_controller.value - index * 0.2) % 1.0;
          final wave = phase < 0.5 ? phase * 2 : (1 - phase) * 2;
          return 0.35 + 0.65 * wave;
        }

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < 3; i++)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Opacity(
                  opacity: opacityFor(i),
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFFFFF),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
