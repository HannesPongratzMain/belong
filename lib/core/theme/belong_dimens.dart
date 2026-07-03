import 'package:flutter/widgets.dart';

/// Spacing-Tokens: 4er-Basis aus dem Handoff.
abstract final class BelongSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 40;
  static const double section = 64;

  /// Horizontales Screen-Padding (Handoff: 16–18).
  static const double screen = 18;

  /// Mindestgröße für Hit-Targets.
  static const double hitTarget = 44;
}

/// Radius-Tokens aus dem Handoff.
abstract final class BelongRadii {
  static const double input = 16;
  static const double bubble = 18;
  static const double rowCard = 20;
  static const double choiceCard = 22;
  static const double activityCard = 24;
  static const double screenInset = 32;
  static const double sheet = 34;
  static const double pill = 999;

  static BorderRadius get inputAll => BorderRadius.circular(input);
  static BorderRadius get rowCardAll => BorderRadius.circular(rowCard);
  static BorderRadius get choiceCardAll => BorderRadius.circular(choiceCard);
  static BorderRadius get activityCardAll => BorderRadius.circular(activityCard);
  static BorderRadius get pillAll => BorderRadius.circular(pill);
  static BorderRadius get sheetTop =>
      const BorderRadius.vertical(top: Radius.circular(sheet));

  /// Fremde Chat-Bubble: 18/18/18/6.
  static BorderRadius get bubbleOther => const BorderRadius.only(
        topLeft: Radius.circular(bubble),
        topRight: Radius.circular(bubble),
        bottomRight: Radius.circular(bubble),
        bottomLeft: Radius.circular(6),
      );

  /// Eigene Chat-Bubble: 18/18/6/18.
  static BorderRadius get bubbleMine => const BorderRadius.only(
        topLeft: Radius.circular(bubble),
        topRight: Radius.circular(bubble),
        bottomRight: Radius.circular(6),
        bottomLeft: Radius.circular(bubble),
      );

  /// Organischer Blob, CSS `border-radius: 46% 54% 60% 40% / 52% 44% 56% 48%`.
  static BorderRadius blob(double size) => BorderRadius.only(
        topLeft: Radius.elliptical(size * 0.46, size * 0.52),
        topRight: Radius.elliptical(size * 0.54, size * 0.44),
        bottomRight: Radius.elliptical(size * 0.60, size * 0.56),
        bottomLeft: Radius.elliptical(size * 0.40, size * 0.48),
      );
}

/// Bewegungs-Tokens: Übergänge weich (200–300 ms, easeOut).
abstract final class BelongMotion {
  static const fast = Duration(milliseconds: 200);
  static const medium = Duration(milliseconds: 300);
  static const pop = Duration(milliseconds: 350); // Erfolgs-Funke
  static const curve = Curves.easeOut;
}
