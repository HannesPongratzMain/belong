import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';

import 'belong_colors.dart';
import 'belong_typography.dart';

/// Zentrales App-Theme.
///
/// Material dient nur als technisches Gerüst (Scaffold, Navigator, Inputs) —
/// die sichtbare Gestaltung kommt vollständig aus den Belong-Tokens.
/// Für den iOS-Feel auf allen Plattformen: Cupertino-Pagetransitions und
/// Bouncing-Scroll, kein Material-Splash.
abstract final class BelongTheme {
  static ThemeData light() {
    const cupertinoTransitions = PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
        TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
      },
    );

    final base = ThemeData(
      useMaterial3: true,
      fontFamily: BelongFonts.sans,
      scaffoldBackgroundColor: BelongColors.surface,
      colorScheme: const ColorScheme.light(
        primary: BelongColors.coral,
        onPrimary: Colors.white,
        secondary: BelongColors.sunflower,
        onSecondary: BelongColors.forest,
        surface: BelongColors.surface,
        onSurface: BelongColors.ink,
        error: BelongColors.error,
        onError: Colors.white,
        outline: BelongColors.border,
      ),
    );

    return base.copyWith(
      pageTransitionsTheme: cupertinoTransitions,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      hoverColor: BelongColors.coralWash,
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: BelongColors.coral,
        selectionColor: BelongColors.coralTint,
        selectionHandleColor: BelongColors.coral,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: BelongColors.ink,
        displayColor: BelongColors.ink,
      ),
      dividerColor: BelongColors.hairline,
      // Sheets bauen wir selbst (Radius 34, Grabber) — hier nur Grundfarben.
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: Colors.transparent,
      ),
    );
  }
}

/// Bouncing-Scroll überall — Teil des iOS-Looks auf allen Plattformen.
class BelongScrollBehavior extends MaterialScrollBehavior {
  const BelongScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());
}
