import 'package:flutter/widgets.dart';

import '../theme/belong_colors.dart';
import '../theme/belong_typography.dart';

/// „BELONG"-Wortmarke: Inter Bold in Versalien mit Letter-Spacing —
/// gerade und ruhig, Wiedererkennung über Farbe und Tracking.
class BelongWordmark extends StatelessWidget {
  const BelongWordmark({super.key, this.fontSize = 20});

  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'belong',
      header: true,
      excludeSemantics: true,
      child: Text(
        'BELONG',
        style: TextStyle(
          fontFamily: BelongFonts.sans,
          fontSize: fontSize,
          height: 1.1,
          fontWeight: FontWeight.w700,
          letterSpacing: fontSize * 0.08,
          color: BelongColors.coral,
        ),
      ),
    );
  }
}
