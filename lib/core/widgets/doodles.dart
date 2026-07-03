import 'package:flutter/widgets.dart';

import '../theme/belong_colors.dart';

/// Handgezeichneter Squiggle unter dem Erfolgs-Titel („Steht!").
class SquiggleUnderline extends StatelessWidget {
  const SquiggleUnderline({
    super.key,
    this.width = 120,
    this.color = BelongColors.wordmark,
  });

  final double width;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, 10),
      painter: _SquigglePainter(color),
    );
  }
}

class _SquigglePainter extends CustomPainter {
  const _SquigglePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    final w = size.width;
    final mid = size.height / 2;
    final path = Path()
      ..moveTo(2, mid + 2)
      ..cubicTo(w * 0.18, mid - 4, w * 0.32, mid + 5, w * 0.5, mid)
      ..cubicTo(w * 0.68, mid - 5, w * 0.82, mid + 4, w - 2, mid - 2);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_SquigglePainter oldDelegate) => color != oldDelegate.color;
}

/// Gekritzelter Doodle-Pfeil (Leer-Zustand → zeigt auf den CTA).
class DoodleArrow extends StatelessWidget {
  const DoodleArrow({super.key, this.color = BelongColors.berryDeep});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 58 * 3.14159 / 180,
      child: CustomPaint(
        size: const Size(44, 30),
        painter: _DoodleArrowPainter(color),
      ),
    );
  }
}

class _DoodleArrowPainter extends CustomPainter {
  const _DoodleArrowPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    // Pfade aus dem Design-HTML (viewBox 60×40).
    final sx = size.width / 60;
    final sy = size.height / 40;
    final curve = Path()
      ..moveTo(6 * sx, 8 * sy)
      ..cubicTo(22 * sx, 26 * sy, 34 * sx, 30 * sy, 50 * sx, 26 * sy);
    canvas.drawPath(curve, paint);
    final head = Path()
      ..moveTo(42 * sx, 20 * sy)
      ..lineTo(51 * sx, 26 * sy)
      ..lineTo(43 * sx, 32 * sy);
    canvas.drawPath(head, paint);
  }

  @override
  bool shouldRepaint(_DoodleArrowPainter oldDelegate) =>
      color != oldDelegate.color;
}
