import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format/belong_dates.dart';
import '../../core/theme/belong_colors.dart';
import '../../core/theme/belong_dimens.dart';
import '../../core/theme/belong_shadows.dart';
import '../../core/theme/belong_typography.dart';
import '../../core/widgets/app_header.dart';
import '../../core/widgets/belong_icons.dart';
import '../../core/widgets/belong_wordmark.dart';
import '../../core/widgets/category_chip.dart';
import '../../core/widgets/pills.dart';
import '../../core/widgets/pressable.dart';
import '../../core/widgets/skeleton.dart';
import '../../core/widgets/state_view.dart';
import '../../domain/models/activity.dart';
import '../../domain/models/chat_message.dart';
import '../chat/chat_controller.dart';
import '../chat/chat_screen.dart';
import '../participation/participation_controller.dart';

/// Chats-Tab: Gruppenchats gibt es nur zu Aktivitäten, bei denen du dabei
/// bist — Chat ist Koordination, kein eigenes Social-Feature.
class ChatsScreen extends ConsumerWidget {
  const ChatsScreen({super.key, required this.onDiscover});

  /// Wechselt zum Entdecken-Tab (aus dem Leer-Zustand).
  final VoidCallback onDiscover;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chats = ref.watch(chatActivitiesProvider);

    return Column(
      children: [
        AppHeader(
          child: Row(
            children: [
              const BelongWordmark(),
              const Spacer(),
              Text('Chats',
                  style: BelongText.label.copyWith(fontSize: 14)),
            ],
          ),
        ),
        Expanded(
          child: switch (chats) {
            AsyncValue(:final value?) => value.isEmpty
                ? StateView(
                    blobColor: BelongColors.coralTint,
                    symbol: const BelongIcon(BelongIconGlyph.chat,
                        size: 40, color: BelongColors.coralDeep, strokeWidth: 2.4),
                    title: 'Noch keine Chats.',
                    message:
                        'Tritt einer Aktivität bei — den Gruppenchat gibt es '
                        'direkt dazu, ganz ohne Smalltalk-Pflicht.',
                    primaryLabel: 'Aktivitäten entdecken',
                    onPrimary: onDiscover,
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(BelongSpacing.screen,
                        BelongSpacing.md, BelongSpacing.screen, BelongSpacing.lg),
                    children: [
                      for (final activity in value) ...[
                        _ChatRow(activity: activity),
                        const SizedBox(height: BelongSpacing.sm),
                      ],
                    ],
                  ),
            _ => const _ChatsLoading(),
          },
        ),
      ],
    );
  }
}

class _ChatRow extends ConsumerWidget {
  const _ChatRow({required this.activity});

  final Activity activity;

  /// Zeit rechts in der Row: „Abgesagt" (neutral), Sunflower-Pill als
  /// In-App-Erinnerung („in 2 h"), sonst das übliche Kurzformat.
  Widget _timeBadge() {
    if (activity.isCancelled) {
      return const BelongPill(
        label: 'Abgesagt',
        background: BelongColors.chipNeutral,
        foreground: BelongColors.muted,
        textStyle: BelongText.badge,
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      );
    }
    final startsIn = BelongDates.startsIn(activity.startsAt);
    if (startsIn != null) {
      return BelongPill(
        label: startsIn,
        background: BelongColors.sunflower,
        foreground: BelongColors.forest,
        textStyle: BelongText.badge,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        shadows: BelongShadows.sunflowerBadge,
      );
    }
    return Text(BelongDates.badge(activity.startsAt),
        style: BelongText.meta.copyWith(fontWeight: FontWeight.w700));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Vorschau: letzte „echte" Nachricht des Chats.
    final messages = ref.watch(chatMessagesProvider(activity.id)).value;
    final lastMessage = messages
        ?.where((message) => message.type != ChatMessageType.system)
        .lastOrNull;

    return Pressable(
      onTap: () => Navigator.of(context).push(ChatScreen.route(activity.id)),
      pressedScale: 0.985,
      semanticLabel: 'Chat: ${activity.title}',
      child: Container(
        padding: const EdgeInsets.all(BelongSpacing.sm),
        decoration: BoxDecoration(
          color: BelongColors.card,
          borderRadius: BelongRadii.rowCardAll,
          border: Border.all(color: BelongColors.border),
          boxShadow: BelongShadows.e1,
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: activity.category.tint,
                borderRadius: BelongRadii.blob(52),
              ),
              child: BelongIcon(activity.category.glyph,
                  size: 22, color: activity.category.deep),
            ),
            const SizedBox(width: BelongSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(activity.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: BelongText.rowTitle),
                  const SizedBox(height: 3),
                  Text(
                    lastMessage == null
                        ? 'Noch keine Nachrichten — sag doch kurz Hallo.'
                        : '${lastMessage.senderNickname}: ${lastMessage.text}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: BelongText.meta,
                  ),
                ],
              ),
            ),
            const SizedBox(width: BelongSpacing.xs),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _timeBadge(),
                const SizedBox(height: 6),
                const BelongIcon(BelongIconGlyph.chevronRight,
                    size: 14, color: BelongColors.placeholder, strokeWidth: 2.6),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatsLoading extends StatelessWidget {
  const _ChatsLoading();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(BelongSpacing.screen,
          BelongSpacing.md, BelongSpacing.screen, 0),
      children: [
        for (var i = 0; i < 3; i++) ...[
          Container(
            padding: const EdgeInsets.all(BelongSpacing.sm),
            decoration: BoxDecoration(
              color: BelongColors.card,
              borderRadius: BelongRadii.rowCardAll,
              border: Border.all(color: BelongColors.border),
            ),
            child: Row(
              children: [
                const Skeleton(width: 52, height: 52, radius: 18),
                const SizedBox(width: BelongSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Skeleton(width: 160, height: 14),
                      SizedBox(height: 8),
                      Skeleton(width: 210, height: 12),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: BelongSpacing.sm),
        ],
      ],
    );
  }
}
