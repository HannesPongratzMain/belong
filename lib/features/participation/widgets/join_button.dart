import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/belong_colors.dart';
import '../../../core/theme/belong_dimens.dart';
import '../../../core/theme/belong_typography.dart';
import '../../../core/widgets/belong_icons.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/pressable.dart';
import '../../../domain/models/access_level.dart';
import '../../../domain/models/activity.dart';
import '../../profile/widgets/verify_phone_sheet.dart';
import '../participation_controller.dart';

/// One-Click-Join-Button mit sichtbarem Zustand:
/// gesperrt (unverifiziert) → beitreten → „Du bist dabei." → voll →
/// wieder verlassen (im Detail).
class JoinButton extends ConsumerWidget {
  const JoinButton({super.key, required this.activity, this.onJoined});

  final Activity activity;

  /// Optionaler Hook nach erfolgreichem Beitritt (z. B. Hinweis zeigen).
  final VoidCallback? onJoined;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accessLevel = ref.watch(accessLevelProvider(activity.id));
    final pending = ref.watch(joinControllerProvider).contains(activity.id);
    final isMine = ref.watch(myActivitiesProvider).value
            ?.any((mine) => mine.id == activity.id) ??
        false;

    if (isMine) {
      return _StatusPill(
        label: 'Deine Aktivität',
        background: BelongColors.amberTint,
        foreground: BelongColors.amberDeep,
      );
    }
    if (accessLevel == AccessLevel.joined) {
      return _StatusPill(
        label: 'Du bist dabei',
        glyph: BelongIconGlyph.check,
        background: BelongColors.sageTint,
        foreground: BelongColors.sage,
      );
    }
    if (accessLevel == AccessLevel.locked) {
      return const _LockedJoinPill();
    }
    if (activity.isFull) {
      return _StatusPill(
        label: 'Voll — schau später rein',
        background: BelongColors.chipNeutral,
        foreground: BelongColors.muted,
      );
    }
    return PrimaryButton(
      label: 'Ich bin dabei',
      loading: pending,
      onTap: () async {
        final result =
            await ref.read(joinControllerProvider.notifier).join(activity.id);
        if (result == JoinResult.joined) onJoined?.call();
      },
    );
  }
}

/// Gedimmter Join-Button für unverifizierte Nutzer:innen — Graustufe statt
/// Koralle, Lock-Icon. Tap führt direkt in die Verifizierung, statt nur
/// einen Hinweis zu zeigen — der schnellste Weg, den Button freizuschalten.
class _LockedJoinPill extends StatelessWidget {
  const _LockedJoinPill();

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: () => showVerifyPhoneSheet(context),
      semanticLabel: 'Ich bin dabei — Verifizierung nötig',
      child: Container(
        height: 52,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: BelongColors.chipNeutral,
          borderRadius: BelongRadii.buttonAll,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const BelongIcon(BelongIconGlyph.lock,
                size: 16, color: BelongColors.muted),
            const SizedBox(width: 6),
            Text('Ich bin dabei',
                style: BelongText.button.copyWith(color: BelongColors.muted)),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.label,
    required this.background,
    required this.foreground,
    this.glyph,
  });

  final String label;
  final Color background;
  final Color foreground;
  final BelongIconGlyph? glyph;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      semanticButton: false,
      child: Container(
        height: 52,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BelongRadii.buttonAll,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (glyph != null) ...[
              BelongIcon(glyph!, size: 17, color: foreground),
              const SizedBox(width: 6),
            ],
            Text(label,
                style: BelongText.button.copyWith(color: foreground)),
          ],
        ),
      ),
    );
  }
}
