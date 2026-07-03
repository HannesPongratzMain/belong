import 'package:flutter/cupertino.dart' show CupertinoPageRoute;
import 'package:flutter/material.dart' show Scaffold;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format/belong_dates.dart';
import '../../core/theme/belong_colors.dart';
import '../../core/theme/belong_dimens.dart';
import '../../core/theme/belong_shadows.dart';
import '../../core/theme/belong_typography.dart';
import '../../core/widgets/app_header.dart';
import '../../core/widgets/belong_icons.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/category_chip.dart';
import '../../core/widgets/photo_placeholder.dart';
import '../../core/widgets/pills.dart';
import '../../core/widgets/pressable.dart';
import '../../domain/models/activity.dart';
import '../chat/chat_screen.dart';
import '../participation/participation_controller.dart';
import '../participation/widgets/join_button.dart';

/// Detailansicht: alles, was für „Bin ich dabei?" zählt — und nach dem
/// Join der Weg in den Gruppenchat.
class ActivityDetailScreen extends ConsumerWidget {
  const ActivityDetailScreen({super.key, required this.activityId});

  final String activityId;

  static Route<void> route(String activityId) => CupertinoPageRoute(
        builder: (_) => ActivityDetailScreen(activityId: activityId),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activity = ref.watch(activityStreamProvider(activityId)).value;
    final joined =
        ref.watch(joinedIdsProvider).value?.contains(activityId) ?? false;
    final isMine = ref.watch(myActivitiesProvider).value
            ?.any((mine) => mine.id == activityId) ??
        false;

    return Scaffold(
      backgroundColor: BelongColors.surface,
      body: activity == null
          ? const SizedBox.expand()
          : Column(
              children: [
                _PhotoHeader(activity: activity),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(BelongSpacing.screen,
                        BelongSpacing.md, BelongSpacing.screen, BelongSpacing.lg),
                    children: [
                      CategoryChip(
                        label: activity.category.label,
                        category: activity.category,
                      ),
                      const SizedBox(height: 10),
                      Text(activity.title, style: BelongText.displayTitle),
                      const SizedBox(height: BelongSpacing.sm),
                      _MetaRow(
                        glyph: activity.isOnline
                            ? BelongIconGlyph.globe
                            : BelongIconGlyph.pin,
                        text: activity.isOnline
                            ? 'Online — Link kommt im Gruppenchat'
                            : '${activity.locationName}'
                                '${activity.area != null ? ' · ${activity.area}' : ''}',
                      ),
                      const SizedBox(height: 6),
                      _MetaRow(
                        glyph: BelongIconGlyph.discover,
                        text:
                            '${BelongDates.dayLong(activity.startsAt)} · ${BelongDates.time(activity.startsAt)} Uhr',
                      ),
                      if (activity.description != null) ...[
                        const SizedBox(height: BelongSpacing.md),
                        Text(activity.description!,
                            style: BelongText.body
                                .copyWith(color: BelongColors.inkSoft)),
                      ],
                      const SizedBox(height: BelongSpacing.md),
                      Row(
                        children: [
                          Text('${activity.participantCount} dabei',
                              style:
                                  BelongText.rowTitle.copyWith(fontSize: 15)),
                          const Spacer(),
                          _spotsBadge(activity),
                        ],
                      ),
                      const SizedBox(height: BelongSpacing.md),
                      JoinButton(activity: activity),
                      if (joined && !isMine) ...[
                        const SizedBox(height: BelongSpacing.xs),
                        Center(
                          child: Text(
                            'Wir sagen dir kurz vorher Bescheid.',
                            style: BelongText.bodySmall
                                .copyWith(color: BelongColors.muted),
                          ),
                        ),
                      ],
                      if (joined || isMine) ...[
                        const SizedBox(height: BelongSpacing.sm),
                        SecondaryButton(
                          label: 'Zum Gruppenchat',
                          onTap: () => Navigator.of(context)
                              .push(ChatScreen.route(activity.id)),
                        ),
                      ],
                      if (joined && !isMine) ...[
                        const SizedBox(height: BelongSpacing.xs),
                        Center(
                          child: GhostButton(
                            label: 'Ich kann doch nicht',
                            onTap: () => ref
                                .read(joinControllerProvider.notifier)
                                .leave(activity.id),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _spotsBadge(Activity activity) {
    final free = activity.freeSpots;
    final (label, background, foreground) = switch (free) {
      null => ('offen für alle', BelongColors.amberTint, BelongColors.amberDeep),
      0 => ('voll', BelongColors.chipNeutral, BelongColors.muted),
      _ => ('$free frei', BelongColors.sageTint, BelongColors.sage),
    };
    return BelongPill(
      label: label,
      background: background,
      foreground: foreground,
      textStyle: BelongText.badge,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    );
  }
}

/// Foto-Kopf mit gerissener Kante, Zurück-Button und Zeit-Badge.
class _PhotoHeader extends StatelessWidget {
  const _PhotoHeader({required this.activity});

  final Activity activity;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    return Stack(
      children: [
        ClipPath(
          clipper: const TornEdgeClipper(amplitude: 5),
          child: SizedBox(
            height: 200 + topInset,
            width: double.infinity,
            child: PhotoPlaceholder(
              category: activity.category,
              photoHint: activity.photoHint,
            ),
          ),
        ),
        Positioned(
          top: topInset + 10,
          left: BelongSpacing.md,
          child: Pressable(
            onTap: () => Navigator.of(context).pop(),
            semanticLabel: 'Zurück',
            child: Container(
              width: BelongSpacing.hitTarget,
              height: BelongSpacing.hitTarget,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: BelongColors.card,
                shape: BoxShape.circle,
                boxShadow: BelongShadows.e1,
              ),
              child: const BelongIcon(BelongIconGlyph.chevronLeft,
                  size: 20, color: BelongColors.inkSoft, strokeWidth: 2.6),
            ),
          ),
        ),
        Positioned(
          top: topInset + 14,
          right: BelongSpacing.md,
          child: Transform.rotate(
            angle: 3 * 3.14159 / 180,
            child: BelongPill(
              label: BelongDates.badge(activity.startsAt),
              background: BelongColors.sunflower,
              foreground: BelongColors.forest,
              textStyle: BelongText.badge,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              shadows: BelongShadows.sunflowerBadge,
            ),
          ),
        ),
      ],
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.glyph, required this.text});

  final BelongIconGlyph glyph;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        BelongIcon(glyph, size: 17, color: BelongColors.coralDeep),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text,
              style: BelongText.body.copyWith(color: BelongColors.muted)),
        ),
      ],
    );
  }
}
