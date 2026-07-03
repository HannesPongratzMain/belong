import 'package:flutter/material.dart' show Scaffold;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/belong_colors.dart';
import '../core/theme/belong_dimens.dart';
import '../core/theme/belong_typography.dart';
import '../core/widgets/belong_wordmark.dart';
import '../core/widgets/state_view.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/profile/profile_controller.dart';
import 'home_shell.dart';

/// Weiche zwischen Onboarding und App: solange kein Profil existiert,
/// gibt es nur den anonymen Einstieg.
class RootGate extends ConsumerWidget {
  const RootGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);

    return AnimatedSwitcher(
      duration: BelongMotion.medium,
      switchInCurve: BelongMotion.curve,
      child: switch (profile) {
        AsyncValue(value: _?) => const HomeShell(),
        AsyncValue(hasValue: true) => const Scaffold(
            backgroundColor: BelongColors.surface,
            body: OnboardingScreen(),
          ),
        // Start fehlgeschlagen (z. B. keine Verbindung): sichtbar machen
        // statt ewig auf dem Splash zu hängen.
        AsyncValue(hasError: true) => Scaffold(
            backgroundColor: BelongColors.surface,
            body: StateView(
              blobColor: BelongColors.berryTint,
              symbol: Text('!',
                  style: BelongText.displaySuccess.copyWith(
                      fontSize: 44, color: BelongColors.berryDeep)),
              title: 'Da hakt gerade was.',
              message: 'Wir erreichen belong nicht — vielleicht fehlt die '
                  'Internetverbindung. Kein Problem.',
              primaryLabel: 'Noch mal versuchen',
              onPrimary: () => ref.invalidate(profileProvider),
            ),
          ),
        _ => const _Splash(),
      },
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: BelongColors.cream,
      body: Center(child: BelongWordmark(fontSize: 34)),
    );
  }
}
