import 'package:flutter/widgets.dart';

import '../theme/belong_colors.dart';

/// Handgezeichnete Stroke-Icons im Stil des Handoffs
/// (2.2–2.6 px Strichstärke, runde Kappen, viewBox 24×24).
enum BelongIconGlyph {
  discover,
  plus,
  chat,
  person,
  chevronDown,
  chevronRight,
  chevronLeft,
  close,
  pin,
  shield,
  send,
  flag,
  block,
  bell,
  dice,
  note,
  cup,
  minus,
  globe,
}

class BelongIcon extends StatelessWidget {
  const BelongIcon(
    this.glyph, {
    super.key,
    this.size = 22,
    this.color = BelongColors.muted,
    this.strokeWidth = 2.2,
  });

  final BelongIconGlyph glyph;
  final double size;
  final Color color;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _IconPainter(glyph: glyph, color: color, strokeWidth: strokeWidth),
    );
  }
}

class _IconPainter extends CustomPainter {
  const _IconPainter({
    required this.glyph,
    required this.color,
    required this.strokeWidth,
  });

  final BelongIconGlyph glyph;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24;
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * s
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fill = Paint()..color = color;

    Offset p(double x, double y) => Offset(x * s, y * s);

    Path line(List<Offset> points) {
      final path = Path()..moveTo(points.first.dx, points.first.dy);
      for (final point in points.skip(1)) {
        path.lineTo(point.dx, point.dy);
      }
      return path;
    }

    switch (glyph) {
      case BelongIconGlyph.discover:
        canvas.drawCircle(p(12, 12), 8.5 * s, stroke);
        canvas.drawCircle(p(12, 12), 2 * s, fill);
      case BelongIconGlyph.plus:
        canvas.drawLine(p(12, 5), p(12, 19), stroke);
        canvas.drawLine(p(5, 12), p(19, 12), stroke);
      case BelongIconGlyph.minus:
        canvas.drawLine(p(5, 12), p(19, 12), stroke);
      case BelongIconGlyph.chat:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(4 * s, 5 * s, 16 * s, 12 * s), Radius.circular(5 * s)),
          stroke,
        );
        canvas.drawPath(line([p(9, 17), p(9, 20), p(13, 17)]), stroke);
      case BelongIconGlyph.person:
        canvas.drawCircle(p(12, 8), 3.6 * s, stroke);
        final path = Path()
          ..moveTo(5.5 * s, 19 * s)
          ..cubicTo(7 * s, 15.5 * s, 9 * s, 14.5 * s, 12 * s, 14.5 * s)
          ..cubicTo(15 * s, 14.5 * s, 17 * s, 15.5 * s, 18.5 * s, 19 * s);
        canvas.drawPath(path, stroke);
      case BelongIconGlyph.chevronDown:
        canvas.drawPath(line([p(6, 9), p(12, 15), p(18, 9)]), stroke);
      case BelongIconGlyph.chevronRight:
        canvas.drawPath(line([p(9, 6), p(15, 12), p(9, 18)]), stroke);
      case BelongIconGlyph.chevronLeft:
        canvas.drawPath(line([p(15, 6), p(9, 12), p(15, 18)]), stroke);
      case BelongIconGlyph.close:
        canvas.drawLine(p(6.5, 6.5), p(17.5, 17.5), stroke);
        canvas.drawLine(p(17.5, 6.5), p(6.5, 17.5), stroke);
      case BelongIconGlyph.pin:
        final path = Path()
          ..moveTo(12 * s, 21 * s)
          ..cubicTo(8.5 * s, 17.5 * s, 5 * s, 14 * s, 5 * s, 10 * s)
          ..arcToPoint(p(19, 10), radius: Radius.circular(7 * s))
          ..cubicTo(19 * s, 14 * s, 15.5 * s, 17.5 * s, 12 * s, 21 * s)
          ..close();
        canvas.drawPath(path, stroke);
        canvas.drawCircle(p(12, 10), 2.4 * s, stroke);
      case BelongIconGlyph.shield:
        final path = Path()
          ..moveTo(12 * s, 3.5 * s)
          ..lineTo(18.5 * s, 6 * s)
          ..lineTo(18.5 * s, 11 * s)
          ..cubicTo(18.5 * s, 15.5 * s, 15.5 * s, 19 * s, 12 * s, 20.5 * s)
          ..cubicTo(8.5 * s, 19 * s, 5.5 * s, 15.5 * s, 5.5 * s, 11 * s)
          ..lineTo(5.5 * s, 6 * s)
          ..close();
        canvas.drawPath(path, stroke);
      case BelongIconGlyph.send:
        canvas.drawLine(p(5, 12), p(18, 12), stroke);
        canvas.drawPath(line([p(12.5, 6.5), p(18, 12), p(12.5, 17.5)]), stroke);
      case BelongIconGlyph.flag:
        canvas.drawLine(p(6.5, 4), p(6.5, 20), stroke);
        canvas.drawPath(
          line([p(6.5, 5), p(17, 5), p(14.5, 8.5), p(17, 12), p(6.5, 12)]),
          stroke,
        );
      case BelongIconGlyph.block:
        canvas.drawCircle(p(12, 12), 8 * s, stroke);
        canvas.drawLine(p(6.7, 6.7), p(17.3, 17.3), stroke);
      case BelongIconGlyph.bell:
        final path = Path()
          ..moveTo(5.5 * s, 16 * s)
          ..lineTo(18.5 * s, 16 * s)
          ..cubicTo(17.5 * s, 14.5 * s, 17 * s, 13 * s, 17 * s, 10 * s)
          ..cubicTo(17 * s, 6.7 * s, 15 * s, 4.5 * s, 12 * s, 4.5 * s)
          ..cubicTo(9 * s, 4.5 * s, 7 * s, 6.7 * s, 7 * s, 10 * s)
          ..cubicTo(7 * s, 13 * s, 6.5 * s, 14.5 * s, 5.5 * s, 16 * s)
          ..close();
        canvas.drawPath(path, stroke);
        canvas.drawPath(
          Path()
            ..moveTo(10.2 * s, 18.6 * s)
            ..cubicTo(10.7 * s, 19.6 * s, 13.3 * s, 19.6 * s, 13.8 * s, 18.6 * s),
          stroke,
        );
      case BelongIconGlyph.dice:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(4.5 * s, 4.5 * s, 15 * s, 15 * s),
              Radius.circular(4 * s)),
          stroke,
        );
        canvas.drawCircle(p(9.2, 9.2), 1.2 * s, fill);
        canvas.drawCircle(p(14.8, 9.2), 1.2 * s, fill);
        canvas.drawCircle(p(9.2, 14.8), 1.2 * s, fill);
        canvas.drawCircle(p(14.8, 14.8), 1.2 * s, fill);
      case BelongIconGlyph.note:
        canvas.drawPath(line([p(9.5, 17.5), p(9.5, 6), p(19, 4.5), p(19, 15.5)]), stroke);
        canvas.drawCircle(p(7.2, 17.5), 2.3 * s, fill);
        canvas.drawCircle(p(16.7, 15.5), 2.3 * s, fill);
      case BelongIconGlyph.cup:
        final body = Path()
          ..moveTo(5 * s, 8 * s)
          ..lineTo(16 * s, 8 * s)
          ..lineTo(16 * s, 14 * s)
          ..cubicTo(16 * s, 17 * s, 14 * s, 19 * s, 10.5 * s, 19 * s)
          ..cubicTo(7 * s, 19 * s, 5 * s, 17 * s, 5 * s, 14 * s)
          ..close();
        canvas.drawPath(body, stroke);
        final handle = Path()
          ..moveTo(16 * s, 9.5 * s)
          ..cubicTo(19.5 * s, 9.5 * s, 19.5 * s, 14.5 * s, 16 * s, 14.5 * s);
        canvas.drawPath(handle, stroke);
      case BelongIconGlyph.globe:
        canvas.drawCircle(p(12, 12), 8 * s, stroke);
        canvas.drawLine(p(4, 12), p(20, 12), stroke);
        final meridian = Path()
          ..moveTo(12 * s, 4 * s)
          ..cubicTo(8.5 * s, 8 * s, 8.5 * s, 16 * s, 12 * s, 20 * s)
          ..moveTo(12 * s, 4 * s)
          ..cubicTo(15.5 * s, 8 * s, 15.5 * s, 16 * s, 12 * s, 20 * s);
        canvas.drawPath(meridian, stroke);
    }
  }

  @override
  bool shouldRepaint(_IconPainter oldDelegate) =>
      glyph != oldDelegate.glyph ||
      color != oldDelegate.color ||
      strokeWidth != oldDelegate.strokeWidth;
}
