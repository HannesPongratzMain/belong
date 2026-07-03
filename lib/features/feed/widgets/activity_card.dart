import 'package:flutter/widgets.dart';

import '../../../core/format/belong_dates.dart';
import '../../../core/theme/belong_colors.dart';
import '../../../core/theme/belong_dimens.dart';
import '../../../core/theme/belong_shadows.dart';
import '../../../core/theme/belong_typography.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/category_chip.dart';
import '../../../core/widgets/photo_placeholder.dart';
import '../../../core/widgets/pills.dart';
import '../../../core/widgets/pressable.dart';
import '../../../domain/models/activity.dart';
import '../../participation/widgets/join_button.dart';

/// Große Feed-Karte (featured): Foto mit Sonnenblume-Badge und gerissener
/// Kante, Kategorie-Chip, Serif-Titel, Meta, Plätze + JoinButton.
class ActivityCard extends StatelessWidget {
  const ActivityCard({super.key, required this.activity, this.onTap});

  final Activity activity;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
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
            // Foto mit gerissener Weiß-Kante unten.
            Stack(
              children: [
                ClipPath(
                  clipper: const TornEdgeClipper(amplitude: 4),
                  child: SizedBox(
                    height: 132,
                    width: double.infinity,
                    child: PhotoPlaceholder(
                      category: activity.category,
                      photoHint: activity.photoHint,
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Transform.rotate(
                    angle: 3 * 3.14159 / 180,
                    child: BelongPill(
                      label: BelongDates.badge(activity.startsAt),
                      background: BelongColors.sunflower,
                      foreground: BelongColors.forest,
                      textStyle: BelongText.badge,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      shadows: BelongShadows.sunflowerBadge,
                    ),
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
                  const SizedBox(height: 4),
                  Text(
                    '${activity.placeLabel} · '
                    '${BelongDates.dayLong(activity.startsAt)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: BelongText.body.copyWith(color: BelongColors.muted),
                  ),
                  const SizedBox(height: BelongSpacing.sm),
                  Row(
                    children: [
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
class ActivityRow extends StatelessWidget {
  const ActivityRow({super.key, required this.activity, this.onTap});

  final Activity activity;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
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
                  Text(
                    '${activity.placeLabel} · '
                    '${BelongDates.weekday(activity.startsAt)} '
                    '${BelongDates.time(activity.startsAt)}',
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
