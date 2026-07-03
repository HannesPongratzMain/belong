import 'package:flutter/widgets.dart';

import '../../../core/theme/belong_colors.dart';
import '../../../core/theme/belong_dimens.dart';
import '../../../core/theme/belong_shadows.dart';
import '../../../core/theme/belong_typography.dart';
import '../../../core/widgets/doodles.dart';
import '../../../core/widgets/skeleton.dart';
import '../../../core/widgets/spark.dart';
import '../../../core/widgets/state_view.dart';

/// Feed · Laden: Skeletons statt Spinner + freundliche Lade-Notiz.
class FeedLoadingState extends StatelessWidget {
  const FeedLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    Widget rowSkeleton() => Container(
          padding: const EdgeInsets.all(BelongSpacing.sm),
          decoration: BoxDecoration(
            color: BelongColors.card,
            borderRadius: BelongRadii.rowCardAll,
            border: Border.all(color: BelongColors.border),
          ),
          child: Row(
            children: [
              const Skeleton(width: 56, height: 56, radius: 16),
              const SizedBox(width: BelongSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Skeleton(width: 190, height: 15),
                    SizedBox(height: 8),
                    Skeleton(width: 130, height: 12),
                  ],
                ),
              ),
            ],
          ),
        );

    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(BelongSpacing.screen,
          BelongSpacing.md, BelongSpacing.screen, BelongSpacing.lg),
      children: [
        // Featured-Karte als Skeleton.
        Container(
          padding: const EdgeInsets.all(BelongSpacing.md),
          decoration: BoxDecoration(
            color: BelongColors.card,
            borderRadius: BelongRadii.activityCardAll,
            boxShadow: BelongShadows.e1,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Skeleton(width: double.infinity, height: 132, radius: 18),
              SizedBox(height: 14),
              Skeleton(width: 220, height: 16),
              SizedBox(height: 10),
              Skeleton(width: 140, height: 13),
            ],
          ),
        ),
        const SizedBox(height: BelongSpacing.sm),
        rowSkeleton(),
        const SizedBox(height: BelongSpacing.sm),
        rowSkeleton(),
        const SizedBox(height: BelongSpacing.lg),
        const _LoadingNote(),
      ],
    );
  }
}

/// „Wir schauen, was heute geht …" mit den drei Farbpunkten.
class _LoadingNote extends StatelessWidget {
  const _LoadingNote();

  @override
  Widget build(BuildContext context) {
    Widget dot(Color color) => Container(
          width: 9,
          height: 9,
          margin: const EdgeInsets.only(right: 5),
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        );
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        dot(BelongColors.wordmark),
        dot(BelongColors.berry),
        dot(BelongColors.sunflower),
        const SizedBox(width: 8),
        Text('Wir schauen, was heute geht …',
            style: BelongText.body.copyWith(
                fontWeight: FontWeight.w600, color: BelongColors.muted)),
      ],
    );
  }
}

/// Feed · Leer: Amber-Blob mit Funke, Doodle-Pfeil auf den CTA.
class FeedEmptyState extends StatelessWidget {
  const FeedEmptyState({
    super.key,
    required this.onCreate,
    required this.onResetFilters,
  });

  final VoidCallback onCreate;
  final VoidCallback onResetFilters;

  @override
  Widget build(BuildContext context) {
    return StateView(
      blobColor: BelongColors.amberTint,
      symbol: const Spark(size: 42, color: BelongColors.amberDeep, strokeWidth: 2.4, rotation: 16),
      title: 'Gerade noch ruhig hier.',
      message: 'Für diese Filter ist noch nichts geplant. '
          'Starte selbst was Kleines — ein Kaffee reicht schon.',
      beforePrimary: const Padding(
        padding: EdgeInsets.only(top: BelongSpacing.sm),
        child: DoodleArrow(),
      ),
      primaryLabel: 'Aktivität starten',
      onPrimary: onCreate,
      ghostLabel: 'Filter zurücksetzen',
      onGhost: onResetFilters,
    );
  }
}

/// Feed · Fehler: Beeren-Blob mit „!", Retry als einziger CTA.
class FeedErrorState extends StatelessWidget {
  const FeedErrorState({
    super.key,
    required this.onRetry,
    this.onShowCached,
  });

  final VoidCallback onRetry;

  /// Nur gesetzt, wenn ein zuletzt geladener Stand existiert.
  final VoidCallback? onShowCached;

  @override
  Widget build(BuildContext context) {
    return StateView(
      blobColor: BelongColors.berryTint,
      symbol: Text('!',
          style: BelongText.displaySuccess
              .copyWith(fontSize: 44, color: BelongColors.berryDeep)),
      title: 'Hat gerade nicht geklappt.',
      message: 'Wir konnten den Feed nicht laden — '
          'vielleicht hakt die Verbindung. Kein Problem.',
      primaryLabel: 'Noch mal versuchen',
      onPrimary: onRetry,
      ghostLabel: onShowCached != null ? 'Zuletzt geladene anzeigen' : null,
      onGhost: onShowCached,
    );
  }
}
