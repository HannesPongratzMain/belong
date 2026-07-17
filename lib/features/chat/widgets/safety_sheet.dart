import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/format/belong_dates.dart';
import '../../../core/theme/belong_colors.dart';
import '../../../core/theme/belong_dimens.dart';
import '../../../core/theme/belong_typography.dart';
import '../../../core/widgets/belong_icons.dart';
import '../../../core/widgets/belong_sheet.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/pressable.dart';
import '../../../domain/models/chat_message.dart';
import '../../friends/friends_controller.dart';

/// SafetySheet nach Long-Press auf eine fremde Nachricht:
/// Melden / Blockieren / Stummschalten / Als Freund anfragen — freundlich,
/// aber unmissverständlich.
Future<void> showSafetySheet({
  required BuildContext context,
  required ChatMessage message,
  required bool isMine,
  required bool canPin,
  required bool isPinned,
  required VoidCallback onReport,
  required VoidCallback onBlock,
  required VoidCallback onMute,
  required VoidCallback onAddFriend,
  required VoidCallback onPin,
  required VoidCallback onUnpin,
}) {
  return showBelongSheet<void>(
    context: context,
    builder: (sheetContext) => _SafetySheet(
      message: message,
      isMine: isMine,
      canPin: canPin,
      isPinned: isPinned,
      onReport: onReport,
      onBlock: onBlock,
      onMute: onMute,
      onAddFriend: onAddFriend,
      onPin: onPin,
      onUnpin: onUnpin,
    ),
  );
}

/// Allgemeines Schutz-Sheet über den „Schutz"-Button im Chat-Header.
Future<void> showChatProtectionSheet({
  required BuildContext context,
  required VoidCallback onMute,
}) {
  return showBelongSheet<void>(
    context: context,
    builder: (sheetContext) => _ProtectionSheet(onMute: onMute),
  );
}

class _SafetySheet extends ConsumerWidget {
  const _SafetySheet({
    required this.message,
    required this.isMine,
    required this.canPin,
    required this.isPinned,
    required this.onReport,
    required this.onBlock,
    required this.onMute,
    required this.onAddFriend,
    required this.onPin,
    required this.onUnpin,
  });

  final ChatMessage message;

  /// Eigene Nachricht — Melden/Blockieren/Stummschalten/Freund-Anfragen
  /// ergeben dann keinen Sinn und werden ausgeblendet.
  final bool isMine;

  /// Nur der Host darf pinnen/lösen.
  final bool canPin;
  final bool isPinned;

  final VoidCallback onReport;
  final VoidCallback onBlock;
  final VoidCallback onMute;
  final VoidCallback onAddFriend;
  final VoidCallback onPin;
  final VoidCallback onUnpin;

  /// „heute", „gestern" oder Kurz-Wochentag — für die Kontextzeile.
  static String _dayLabel(DateTime sentAt) {
    final now = DateTime.now();
    bool sameDay(DateTime a, DateTime b) =>
        a.year == b.year && a.month == b.month && a.day == b.day;
    if (sameDay(sentAt, now)) return 'heute';
    if (sameDay(sentAt, now.subtract(const Duration(days: 1)))) {
      return 'gestern';
    }
    return BelongDates.weekday(sentAt);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void close(VoidCallback action) {
      Navigator.of(context).pop();
      action();
    }

    // Wer eine Nachricht in diesem Chat sehen kann, ist bereits Teilnehmer:in
    // oder Host — beides setzt Verifizierung voraus (BEL-03). Ein eigenes
    // "erst verifizieren"-Sheet braucht es an dieser Stelle also nicht.
    final alreadyFriends =
        ref.watch(friendIdsProvider).contains(message.senderId);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(BelongSpacing.md, BelongSpacing.xs,
          BelongSpacing.md, BelongSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Kontext: wessen Nachricht ist gemeint?
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: BelongColors.coralTint,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  message.senderNickname.substring(0, 1),
                  style: const TextStyle(
                    fontFamily: BelongFonts.sans,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: BelongColors.coralDeep,
                  ),
                ),
              ),
              const SizedBox(width: BelongSpacing.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(message.senderNickname,
                      style: BelongText.rowTitle.copyWith(fontSize: 16)),
                  const SizedBox(height: 2),
                  Text(
                    'Nachricht von ${_dayLabel(message.sentAt)}, '
                    '${BelongDates.time(message.sentAt)}',
                    style: BelongText.meta,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: BelongSpacing.md),
          if (!isMine) ...[
            SafetyRow(
              glyph: BelongIconGlyph.flag,
              color: BelongColors.error,
              title: 'Nachricht melden',
              subtitle: 'Unser Team schaut innerhalb von 24 h drauf.',
              onTap: () => close(onReport),
            ),
            const SizedBox(height: BelongSpacing.xs),
            SafetyRow(
              glyph: BelongIconGlyph.block,
              color: BelongColors.error,
              title: 'Person blockieren',
              subtitle:
                  'Ihr seht euch gegenseitig nicht mehr — ohne Ankündigung.',
              onTap: () => close(onBlock),
            ),
            const SizedBox(height: BelongSpacing.xs),
            SafetyRow(
              glyph: BelongIconGlyph.bell,
              color: BelongColors.ink,
              title: 'Nur stummschalten',
              subtitle: 'Du bleibst dabei, bekommst aber keine Pings mehr.',
              onTap: () => close(onMute),
            ),
            if (!alreadyFriends) ...[
              const SizedBox(height: BelongSpacing.xs),
              SafetyRow(
                glyph: BelongIconGlyph.userAdd,
                color: BelongColors.coralDeep,
                title: 'Als Freund anfragen',
                subtitle: 'Nur du siehst später, ob ihr euch kennt.',
                onTap: () => close(onAddFriend),
              ),
            ],
          ],
          if (canPin) ...[
            if (!isMine) const SizedBox(height: BelongSpacing.xs),
            SafetyRow(
              glyph: BelongIconGlyph.pinned,
              color: BelongColors.amberDeep,
              title: isPinned ? 'Anheftung lösen' : 'Nachricht anpinnen',
              subtitle: isPinned
                  ? 'Sie verschwindet aus dem Banner oben im Chat.'
                  : 'Erscheint oben im Chat, bis du sie löst oder eine '
                      'andere anpinnst.',
              onTap: () => close(isPinned ? onUnpin : onPin),
            ),
          ],
          const SizedBox(height: BelongSpacing.xs),
          GhostButton(
            label: 'Abbrechen',
            onTap: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

class _ProtectionSheet extends StatelessWidget {
  const _ProtectionSheet({required this.onMute});

  final VoidCallback onMute;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(BelongSpacing.md, 0,
          BelongSpacing.md, BelongSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SheetHeader(
            title: 'Dein Schutz hier',
            subtitle:
                'Halte eine Nachricht gedrückt, um sie zu melden oder die '
                'Person zu blockieren. Das sieht niemand außer dir.',
          ),
          const SizedBox(height: BelongSpacing.md),
          SafetyRow(
            glyph: BelongIconGlyph.bell,
            color: BelongColors.ink,
            title: 'Chat stummschalten',
            subtitle: 'Du bleibst dabei, bekommst aber keine Pings mehr.',
            onTap: () {
              Navigator.of(context).pop();
              onMute();
            },
          ),
          const SizedBox(height: BelongSpacing.xs),
          Center(
            child: GhostButton(
              label: 'Alles gut',
              onTap: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}

/// Aktions-Row des Schutz-Sheets (heller Grund, Icon, Titel + Subline).
class SafetyRow extends StatelessWidget {
  const SafetyRow({
    super.key,
    required this.glyph,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final BelongIconGlyph glyph;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      pressedScale: 0.985,
      semanticLabel: title,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(BelongSpacing.md),
        decoration: BoxDecoration(
          color: BelongColors.surface,
          borderRadius: BelongRadii.inputAll,
          border: Border.all(color: BelongColors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: BelongIcon(glyph, size: 20, color: color),
            ),
            const SizedBox(width: BelongSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: BelongText.rowTitle
                          .copyWith(fontSize: 16, color: color)),
                  const SizedBox(height: 3),
                  Text(subtitle,
                      style: BelongText.bodySmall
                          .copyWith(color: BelongColors.muted)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
