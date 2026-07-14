import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/belong_colors.dart';
import '../../core/widgets/belong_icons.dart';
import '../../core/widgets/state_view.dart';
import '../profile/profile_controller.dart';

/// Age-Gate für Profile aus der Zeit vor der Altersgrenze: die App-Shell
/// bleibt zu, bis die 18+-Bestätigung nachgeholt ist (neue Profile
/// bestätigen direkt im Onboarding).
///
/// Bewusst datensparsam: nur die Selbstbestätigung wird gespeichert,
/// kein Geburtsdatum. Wer noch nicht 18 ist, sieht einen freundlichen
/// Abschieds-Zustand statt einer Fehlermeldung.
class AgeGateScreen extends ConsumerStatefulWidget {
  const AgeGateScreen({super.key});

  @override
  ConsumerState<AgeGateScreen> createState() => _AgeGateScreenState();
}

class _AgeGateScreenState extends ConsumerState<AgeGateScreen> {
  bool _declined = false;
  bool _submitting = false;

  Future<void> _confirm() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    try {
      await ref.read(profileProvider.notifier).confirmAge();
      // Kein setState nach Erfolg nötig — der RootGate wechselt zur App-Shell.
    } catch (_) {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_declined) {
      return StateView(
        blobColor: BelongColors.amberTint,
        symbol: const BelongIcon(BelongIconGlyph.clock,
            size: 42, color: BelongColors.amberDeep),
        title: 'Dann bis bald.',
        message: 'belong ist für Erwachsene ab 18 gedacht. Schön, dass du '
            'reingeschaut hast — wir freuen uns, wenn du später wiederkommst.',
        ghostLabel: 'Zurück',
        onGhost: () => setState(() => _declined = false),
      );
    }
    return StateView(
      blobColor: BelongColors.coralTint,
      symbol: const BelongIcon(BelongIconGlyph.shield,
          size: 42, color: BelongColors.coralDeep),
      title: 'Kurze Frage vorab.',
      message: 'belong ist ab 18. Wir speichern nur deine Bestätigung — '
          'kein Geburtsdatum, keine weiteren Angaben.',
      primaryLabel: _submitting ? 'Einen Moment …' : 'Ich bin 18 oder älter',
      onPrimary: _confirm,
      ghostLabel: 'Ich bin noch nicht 18',
      onGhost: () => setState(() => _declined = true),
    );
  }
}
