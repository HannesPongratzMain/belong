import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/format/belong_dates.dart';
import '../../../core/theme/belong_colors.dart';
import '../../../core/theme/belong_dimens.dart';
import '../../../core/theme/belong_shadows.dart';
import '../../../core/theme/belong_typography.dart';
import '../../../core/widgets/belong_icons.dart';
import '../../../core/widgets/category_chip.dart';
import '../../../core/widgets/photo_placeholder.dart';
import '../../../core/widgets/pills.dart';
import '../../../core/widgets/pressable.dart';
import '../../../domain/models/activity.dart';
import '../../participation/participation_controller.dart';
import '../../participation/widgets/join_button.dart';

/// Große Feed-Karte (featured): flache Bildfläche mit Zeit-Badge,
/// Kategorie-Chip, Titel, Meta, Plätze + JoinButton.
class ActivityCard extends ConsumerWidget {
  const ActivityCard({super.key, required this.activity, this.onTap});

  final Activity activity;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accessLevel = ref.watch(accessLevelProvider(activity.id));
    return Pressable(
      onTap: onTap,
      pressedScale: 0.985,
      semanticLabel: activity.title,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: BelongColors.card,
          borderRadius: BelongRadii.activityCardAll,
          boxShadow: BelongShadows.e2,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Flache Bildfläche mit Zeit-Badge.
            Stack(
              children: [
                SizedBox(
                  height: 132,
                  width: double.infinity,
                  child: PhotoPlaceholder(
                    category: activity.category,
                    photoHint: activity.photoHint,
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: BelongPill(
                    label: BelongDates.badge(activity.startsAt),
                    background: BelongColors.sunflower,
                    foreground: BelongColors.forest,
                    textStyle: BelongText.badge,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(BelongSpacing.md, 10,
                  BelongSpacing.md, BelongSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CategoryChip(
                    label: activity.category.label,
                    category: activity.category,
                  ),
                  const SizedBox(height: 10),
                  Text(activity.title, style: BelongText.cardTitle),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const BelongIcon(BelongIconGlyph.pin,
                          size: 14, color: BelongColors.muted),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          activity.placeLabelFor(accessLevel),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: BelongText.body
                              .copyWith(color: BelongColors.muted),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const BelongIcon(BelongIconGlyph.clock,
                          size: 14, color: BelongColors.muted),
                      const SizedBox(width: 4),
                      Text(
                        BelongDates.dayLong(activity.startsAt),
                        style:
                            BelongText.body.copyWith(color: BelongColors.muted),
                      ),
                    ],
                  ),
                  const SizedBox(height: BelongSpacing.sm),
                  Row(
                    children: [
                      const BelongIcon(BelongIconGlyph.users,
                          size: 15, color: BelongColors.inkSoft),
                      const SizedBox(width: 5),
                      Text('${activity.participantCount} dabei',
                          style: BelongText.rowTitle.copyWith(fontSize: 15)),
                      const Spacer(),
                      _SpotsBadge(activity: activity),
                    ],
                  ),
                  const SizedBox(height: BelongSpacing.sm),
                  JoinButton(activity: activity),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Kompakte Feed-Zeile: Foto-Thumb 56 px, Titel, Meta, Chip + Plätze.
class ActivityRow extends ConsumerWidget {
  const ActivityRow({super.key, required this.activity, this.onTap});

  final Activity activity;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accessLevel = ref.watch(accessLevelProvider(activity.id));
    return Pressable(
      onTap: onTap,
      pressedScale: 0.985,
      semanticLabel: activity.title,
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
            ClipRRect(
              borderRadius: BorderRadius.circular(BelongRadii.input),
              child: SizedBox(
                width: 56,
                height: 56,
                child: PhotoPlaceholder(
                    category: activity.category, showHint: false),
              ),
            ),
            const SizedBox(width: BelongSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(activity.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: BelongText.rowTitle),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const BelongIcon(BelongIconGlyph.pin,
                          size: 12, color: BelongColors.muted),
                      const SizedBox(width: 3),
                      Flexible(
                        child: Text(
                          '${activity.placeLabelFor(accessLevel)} · '
                          '${BelongDates.weekday(activity.startsAt)} '
                          '${BelongDates.time(activity.startsAt)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: BelongText.meta,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: BelongSpacing.xs),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                CategoryChip(
                  label: activity.category.label,
                  category: activity.category,
                ),
                const SizedBox(height: 6),
                Text(_spotsLabel(activity), style: BelongText.meta),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _spotsLabel(Activity activity) {
    final free = activity.freeSpots;
    if (free == null) return '${activity.participantCount} dabei';
    if (free == 0) return 'voll';
    return '${activity.participantCount} dabei · $free frei';
  }
}

class _SpotsBadge extends StatelessWidget {
  const _SpotsBadge({required this.activity});

  final Activity activity;

  @override
  Widget build(BuildContext context) {
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
