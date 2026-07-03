import 'package:flutter/widgets.dart';

import '../theme/belong_colors.dart';
import '../theme/belong_shadows.dart';
import '../theme/belong_typography.dart';
import 'spark.dart';

/// „BELONG"-Wortmarke: Luckiest Guy, Buchstaben einzeln ±2–3° rotiert,
/// harter dunkler Schatten ohne Blur, Beeren-Funke rechts oben.
class BelongWordmark extends StatelessWidget {
  const BelongWordmark({super.key, this.fontSize = 23});

  final double fontSize;

  // Rotation/Versatz je Buchstabe aus dem Design-HTML.
  static const _letters = [
    (letter: 'B', rotation: -3.0, dy: 1.0),
    (letter: 'E', rotation: 2.0, dy: -1.0),
    (letter: 'L', rotation: -2.0, dy: 0.0),
    (letter: 'O', rotation: 3.0, dy: -1.0),
    (letter: 'N', rotation: -2.0, dy: 1.0),
    (letter: 'G', rotation: 3.0, dy: -1.0),
  ];

  @override
  Widget build(BuildContext context) {
    final scale = fontSize / 23;
    final style = TextStyle(
      fontFamily: BelongFonts.wordmark,
      fontSize: fontSize,
      height: 1.1,
      color: BelongColors.wordmark,
      shadows: BelongShadows.wordmark,
    );

    return Semantics(
      label: 'belong',
      header: true,
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          for (final l in _letters)
            Padding(
              padding: EdgeInsets.only(left: l.letter == 'B' ? 0 : 1 * scale),
              child: Transform.translate(
                offset: Offset(0, l.dy * scale),
                child: Transform.rotate(
                  angle: l.rotation * 3.14159 / 180,
                  child: Text(l.letter, style: style),
                ),
              ),
            ),
          Padding(
            padding: EdgeInsets.only(left: 5 * scale),
            child: Transform.translate(
              offset: Offset(0, -8 * scale),
              child: Spark(size: 18 * scale, rotation: 14),
            ),
          ),
        ],
      ),
    );
  }
}
