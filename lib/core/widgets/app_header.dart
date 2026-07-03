import 'package:flutter/widgets.dart';

import '../theme/belong_colors.dart';
import '../theme/belong_dimens.dart';

/// App-Header: Creme-Fläche mit Deko-Blob oben rechts und „gerissener"
/// Unterkante (flache Wellen-Kurve).
class AppHeader extends StatelessWidget {
  const AppHeader({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    return ClipPath(
      clipper: const TornEdgeClipper(),
      child: Container(
        width: double.infinity,
        color: BelongColors.header,
        // 10 px Reserve für die gerissene Kante unten.
        padding: EdgeInsets.only(top: topInset, bottom: 10),
        child: Stack(
          children: [
            // Deko-Blob, ragt oben rechts aus dem Header (Opacity 0.8).
            Positioned(
              top: -34,
              right: -26,
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: BelongColors.headerBlob.withValues(alpha: 0.8),
                  borderRadius: BelongRadii.blob(110),
                ),
              ),
            ),
            Padding(
              padding: padding ??
                  const EdgeInsets.fromLTRB(
                      BelongSpacing.screen, 14, BelongSpacing.screen, 14),
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}

/// Flache Wellen-Unterkante des Headers.
class TornEdgeClipper extends CustomClipper<Path> {
  const TornEdgeClipper({this.amplitude = 5});

  final double amplitude;

  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    final base = h - amplitude;
    return Path()
      ..lineTo(0, base)
      // Vier weiche, unregelmäßige Wellen wie im Mock.
      ..cubicTo(w * 0.08, base + amplitude, w * 0.16, base - amplitude,
          w * 0.26, base)
      ..cubicTo(w * 0.36, base + amplitude, w * 0.44, base - amplitude * 0.6,
          w * 0.55, base + amplitude * 0.4)
      ..cubicTo(w * 0.64, base + amplitude, w * 0.72, base - amplitude,
          w * 0.82, base)
      ..cubicTo(w * 0.90, base + amplitude * 0.8, w * 0.96, base - amplitude * 0.4,
          w, base + amplitude * 0.3)
      ..lineTo(w, 0)
      ..close();
  }

  @override
  bool shouldReclip(TornEdgeClipper oldClipper) =>
      amplitude != oldClipper.amplitude;
}
