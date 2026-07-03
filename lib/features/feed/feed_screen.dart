import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/belong_colors.dart';
import '../../core/theme/belong_dimens.dart';
import '../../core/theme/belong_shadows.dart';
import '../../core/theme/belong_typography.dart';
import '../../core/widgets/app_header.dart';
import '../../core/widgets/belong_wordmark.dart';
import '../../core/widgets/category_chip.dart';
import '../../core/widgets/option_sheet.dart';
import '../../core/widgets/pills.dart';
import '../../core/widgets/pressable.dart';
import '../../data/providers.dart';
import '../../domain/models/activity.dart';
import '../../domain/models/feed_filter.dart';
import '../activity_detail/activity_detail_screen.dart';
import '../create/create_activity_sheet.dart';
import 'feed_controller.dart';
import 'widgets/activity_card.dart';
import 'widgets/feed_states.dart';

/// Aktivitäten-Feed: Entdecken → Verstehen → Beitreten, ohne Umwege.
class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(feedFilterProvider);
    final feed = ref.watch(feedProvider);

    return Column(
      children: [
        AppHeader(
          child: Row(
            children: [
              const BelongWordmark(),
              const Spacer(),
              // Long-Press = Demo-Trigger für den Fehler-Zustand (nur Mock).
              Pressable(
                onLongPress: () {
                  ref.read(feedErrorDemoProvider)();
                  ref.invalidate(feedProvider);
                },
                semanticLabel: 'Kassel',
                child: BelongPill(
                  label: 'Kassel',
                  background: BelongColors.card,
                  foreground: BelongColors.coralDeep,
                  textStyle:
                      BelongText.chip.copyWith(fontWeight: FontWeight.w700),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                  shadows: BelongShadows.e1,
                ),
              ),
            ],
          ),
        ),
        _FilterBar(filter: filter),
        Expanded(
          // Reihenfolge zählt: Fehler schlägt gehaltene Alt-Daten
          // (Riverpod behält den letzten Wert über Reloads hinweg).
          child: switch (feed) {
            AsyncValue(hasError: true) => FeedErrorState(
                onRetry: () => ref.read(feedProvider.notifier).refresh(),
                onShowCached:
                    ref.read(feedProvider.notifier).hasCachedFeed
                        ? () =>
                            ref.read(feedProvider.notifier).showCachedFeed()
                        : null,
              ),
            AsyncValue(:final value?) when !feed.isLoading || value.isNotEmpty =>
              value.isEmpty
                  ? FeedEmptyState(
                      onCreate: () => showCreateActivitySheet(context),
                      onResetFilters: () =>
                          ref.read(feedFilterProvider.notifier).reset(),
                    )
                  : _FeedList(activities: value),
            _ => const FeedLoadingState(),
          },
        ),
      ],
    );
  }
}

class _FilterBar extends ConsumerWidget {
  const _FilterBar({required this.filter});

  final FeedFilter filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(feedFilterProvider.notifier);
    final categories = [null, ...ActivityCategory.values];

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          BelongSpacing.screen, BelongSpacing.md, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dropdown-Pills: Stadtteil + Zeitraum.
          Row(
            children: [
              DropdownPill(
                label: filter.area,
                onTap: () async {
                  final area = await showOptionSheet<String>(
                    context: context,
                    title: 'Wo in Kassel?',
                    options: FeedFilter.areas,
                    labelOf: (area) => area,
                    selected: filter.area,
                  );
                  if (area != null) notifier.setArea(area);
                },
              ),
              const SizedBox(width: BelongSpacing.xs),
              DropdownPill(
                label: filter.timeRange.label,
                onTap: () async {
                  final range = await showOptionSheet<FeedTimeRange>(
                    context: context,
                    title: 'Wann?',
                    options: FeedTimeRange.values,
                    labelOf: (range) => range.label,
                    selected: filter.timeRange,
                  );
                  if (range != null) notifier.setTimeRange(range);
                },
              ),
            ],
          ),
          const SizedBox(height: BelongSpacing.sm),
          // Kategorie-Chips, horizontal scrollbar.
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(right: BelongSpacing.screen),
              itemCount: categories.length,
              separatorBuilder: (_, _) => const SizedBox(width: BelongSpacing.xs),
              itemBuilder: (context, index) {
                final category = categories[index];
                final selected = filter.category == category;
                return CategoryChip(
                  label: category?.label ?? 'Alle',
                  category: category,
                  selected: selected,
                  onTap: () => notifier.setCategory(category),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedList extends StatelessWidget {
  const _FeedList({required this.activities});

  final List<Activity> activities;

  @override
  Widget build(BuildContext context) {
    final featured = activities.first;
    final rest = activities.skip(1).toList();

    void openDetail(Activity activity) {
      Navigator.of(context).push(
        ActivityDetailScreen.route(activity.id),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(BelongSpacing.screen,
          BelongSpacing.md, BelongSpacing.screen, BelongSpacing.lg),
      children: [
        ActivityCard(activity: featured, onTap: () => openDetail(featured)),
        const SizedBox(height: BelongSpacing.sm),
        for (final activity in rest) ...[
          ActivityRow(activity: activity, onTap: () => openDetail(activity)),
          const SizedBox(height: BelongSpacing.sm),
        ],
      ],
    );
  }
}
