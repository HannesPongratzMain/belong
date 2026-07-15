import 'package:flutter/widgets.dart';

import '../theme/belong_colors.dart';

/// Der „gekritzelte" Logo-Funke: vier leicht schiefe, gebogene Striche.
/// Pfade 1:1 aus dem Design-HTML (viewBox 24×24) übernommen.
class Spark extends StatelessWidget {
  const Spark({
    super.key,
    this.size = 18,
    this.color = BelongColors.berry,
    this.strokeWidth = 2.6,
    this.rotation = 0,
  });

  final double size;
  final Color color;
  final double strokeWidth;

  /// Rotation in Grad (Logo: 14°, Zustands-Blobs: 16°).
  final double rotation;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation * 3.14159 / 180,
      child: CustomPaint(
        size: Size.square(size),
        painter: _SparkPainter(color: color, strokeWidth: strokeWidth),
      ),
    );
  }
}

class _SparkPainter extends CustomPainter {
  const _SparkPainter({required this.color, required this.strokeWidth});

  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * s
      ..strokeCap = StrokeCap.round;

    Path stroke(double x1, double y1, double c1x, double c1y, double c2x,
        double c2y, double x2, double y2) {
      return Path()
        ..moveTo(x1 * s, y1 * s)
        ..cubicTo(c1x * s, c1y * s, c2x * s, c2y * s, x2 * s, y2 * s);
    }

    canvas.drawPath(stroke(11.2, 3.8, 11.9, 5.3, 12.6, 6.6, 12.3, 8.7), paint);
    canvas.drawPath(stroke(13.1, 15.4, 12.3, 16.7, 12.7, 18.5, 11.5, 20.2), paint);
    canvas.drawPath(stroke(3.9, 13.2, 5.7, 12.4, 7.3, 12.8, 9, 12.1), paint);
    canvas.drawPath(stroke(15.2, 11.5, 16.7, 11.8, 18.3, 10.9, 20, 11.3), paint);
  }

  @override
  bool shouldRepaint(_SparkPainter oldDelegate) =>
      color != oldDelegate.color || strokeWidth != oldDelegate.strokeWidth;
}
