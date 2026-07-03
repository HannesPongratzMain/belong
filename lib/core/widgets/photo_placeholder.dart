import 'package:flutter/widgets.dart';

import '../../domain/models/activity.dart';
import '../theme/belong_colors.dart';
import 'category_chip.dart';

/// Foto-Platzhalter im Stil des Handoffs: warme Fläche mit Kategorie-Ton
/// und dezentem Hinweis, was das echte Foto zeigen würde (Aktivität statt
/// Gesichter). Später durch echte Bilder mit warmem Overlay ersetzbar.
class PhotoPlaceholder extends StatelessWidget {
  const PhotoPlaceholder({
    super.key,
    required this.category,
    this.photoHint,
    this.showHint = true,
  });

  final ActivityCategory category;
  final String? photoHint;
  final bool showHint;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            category.tint,
            Color.lerp(category.tint, BelongColors.cream, 0.55)!,
          ],
        ),
      ),
      child: showHint
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Opacity(
                      opacity: 0.7,
                      child: _FrameGlyph(color: category.deep),
                    ),
                    if (photoHint != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Foto: $photoHint',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Hanken Grotesk',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: category.deep.withValues(alpha: 0.75),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            )
          : null,
    );
  }
}

/// Kleines Bilderrahmen-Symbol (Berg + Sonne) für Platzhalter.
class _FrameGlyph extends StatelessWidget {
  const _FrameGlyph({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: const Size(30, 24), painter: _FramePainter(color));
  }
}

class _FramePainter extends CustomPainter {
  const _FramePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(6)),
      paint,
    );
    final mountain = Path()
      ..moveTo(size.width * 0.18, size.height * 0.78)
      ..lineTo(size.width * 0.42, size.height * 0.42)
      ..lineTo(size.width * 0.62, size.height * 0.66)
      ..lineTo(size.width * 0.74, size.height * 0.52)
      ..lineTo(size.width * 0.88, size.height * 0.78);
    canvas.drawPath(mountain, paint);
    canvas.drawCircle(
        Offset(size.width * 0.68, size.height * 0.28), 2.2, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_FramePainter oldDelegate) => color != oldDelegate.color;
}
