// Erzeugt die Quell-PNGs für flutter_launcher_icons:
//
//   assets/icon/icon.png             1024×1024, Funke auf Creme (Web + Legacy)
//   assets/icon/icon_foreground.png  1024×1024, Funke auf Transparent
//                                    (Adaptive-Icon-Vordergrund, Safe Zone)
//
// Ausführen (braucht die Flutter-Engine für dart:ui, daher als Test):
//
//   flutter test tool/generate_icons.dart
//   dart run flutter_launcher_icons
//
// Der Funke lebt nur noch hier als App-Icon-Motiv (viewBox 24×24,
// vier Kubik-Striche, 14° gedreht) — im UI selbst kommt er nicht mehr vor.
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:belong/core/theme/belong_colors.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

const _canvas = 1024.0;

void _drawSpark(Canvas canvas, {required double extent}) {
  final s = extent / 24;
  canvas.save();
  canvas.translate(_canvas / 2, _canvas / 2);
  canvas.rotate(14 * math.pi / 180);
  canvas.translate(-12 * s, -12 * s);

  final paint = Paint()
    ..color = BelongColors.coral
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.6 * s
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
  canvas.restore();
}

Future<void> _renderPng(String path,
    {required double sparkExtent, Color? background}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  if (background != null) {
    canvas.drawRect(
        const Rect.fromLTWH(0, 0, _canvas, _canvas), Paint()..color = background);
  }
  _drawSpark(canvas, extent: sparkExtent);

  final image =
      await recorder.endRecording().toImage(_canvas.toInt(), _canvas.toInt());
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  final file = File(path)..createSync(recursive: true);
  file.writeAsBytesSync(bytes!.buffer.asUint8List());
}

void main() {
  test('rendert die Icon-Quell-PNGs nach assets/icon/', () async {
    // Volle Fläche mit großzügigem Padding (Funke ~55 % der Kante).
    await _renderPng('assets/icon/icon.png',
        sparkExtent: _canvas * 0.55, background: BelongColors.cream);
    // Adaptive-Vordergrund: Safe Zone sind die inneren 66/108 ≈ 61 % —
    // der Funke bleibt mit 42 % der Kante sicher innerhalb.
    await _renderPng('assets/icon/icon_foreground.png',
        sparkExtent: _canvas * 0.42);

    expect(File('assets/icon/icon.png').existsSync(), isTrue);
    expect(File('assets/icon/icon_foreground.png').existsSync(), isTrue);
  });
}
