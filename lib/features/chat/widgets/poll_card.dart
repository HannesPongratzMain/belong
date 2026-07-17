import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/belong_colors.dart';
import '../../../core/theme/belong_dimens.dart';
import '../../../core/theme/belong_typography.dart';
import '../../../core/widgets/belong_icons.dart';
import '../../../core/widgets/pressable.dart';
import '../../../domain/models/poll.dart';
import '../../profile/profile_controller.dart';
import '../chat_controller.dart';

/// Umfrage-Karte in der Chat-Timeline: Frage, antippbare Optionen, Ergebnis
/// live als Balken **und** Zahl (WCAG 2.1 AA — nie nur über Farbe).
class PollCard extends ConsumerWidget {
  const PollCard({super.key, required this.activityId, required this.poll});

  final String activityId;
  final Poll poll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myId = ref.watch(profileProvider).value?.id;
    final myVotes = myId == null ? const <int>[] : poll.votesOf(myId) ?? const <int>[];
    final tally = poll.tally;
    final totalVoters = poll.voterCount;

    Future<void> toggle(int index) async {
      if (myId == null) return;
      final List<int> next;
      if (poll.allowMultiple) {
        next = myVotes.contains(index)
            ? (myVotes.toList()..remove(index))
            : ([...myVotes, index]..sort());
      } else {
        if (myVotes.length == 1 && myVotes.first == index) return;
        next = [index];
      }
      await ref.read(chatActionsProvider).vote(
            activityId,
            poll.id,
            allowMultiple: poll.allowMultiple,
            selection: next,
          );
    }

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 320),
      padding: const EdgeInsets.all(BelongSpacing.md),
      decoration: BoxDecoration(
        color: BelongColors.card,
        borderRadius: BelongRadii.rowCardAll,
        border: Border.all(color: BelongColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: BelongIcon(BelongIconGlyph.poll,
                    size: 16, color: BelongColors.coralDeep),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(poll.question,
                    style: BelongText.rowTitle.copyWith(fontSize: 15)),
              ),
            ],
          ),
          const SizedBox(height: BelongSpacing.sm),
          for (final (index, option) in poll.options.indexed) ...[
            _PollOption(
              label: option,
              selected: myVotes.contains(index),
              allowMultiple: poll.allowMultiple,
              votes: tally[index],
              totalVoters: totalVoters,
              onTap: () => toggle(index),
            ),
            if (index != poll.options.length - 1)
              const SizedBox(height: BelongSpacing.xs),
          ],
          const SizedBox(height: 6),
          Text(
            totalVoters == 0
                ? 'Noch keine Stimmen'
                : '$totalVoters ${totalVoters == 1 ? "Person hat" : "Personen haben"} abgestimmt'
                    '${poll.allowMultiple ? " · Mehrfachauswahl" : ""}',
            style: BelongText.meta,
          ),
        ],
      ),
    );
  }
}

class _PollOption extends StatelessWidget {
  const _PollOption({
    required this.label,
    required this.selected,
    required this.allowMultiple,
    required this.votes,
    required this.totalVoters,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool allowMultiple;
  final int votes;
  final int totalVoters;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final share = totalVoters == 0 ? 0.0 : votes / totalVoters;
    final percentLabel = '${(share * 100).round()} %';
    return Semantics(
      label: '$label — $votes von $totalVoters Stimmen, $percentLabel'
          '${selected ? ", ausgewählt" : ""}',
      button: true,
      excludeSemantics: true,
      child: Pressable(
        onTap: onTap,
        pressedScale: 0.985,
        semanticButton: false,
        child: Container(
          constraints: const BoxConstraints(minHeight: BelongSpacing.hitTarget),
          padding:
              const EdgeInsets.symmetric(horizontal: BelongSpacing.sm, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? BelongColors.coralWash : BelongColors.surface,
            borderRadius: BelongRadii.inputAll,
            border: Border.all(
              color: selected ? BelongColors.coral : BelongColors.border,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _SelectionMark(selected: selected, allowMultiple: allowMultiple),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      label,
                      style: BelongText.body.copyWith(
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('$votes · $percentLabel',
                      style: BelongText.meta.copyWith(fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: SizedBox(
                  height: 6,
                  child: Stack(
                    children: [
                      Container(color: BelongColors.chipNeutral),
                      FractionallySizedBox(
                        widthFactor: share.clamp(0, 1),
                        child: Container(color: BelongColors.coral),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Radio-Ring (Single) bzw. Checkbox-Quadrat (Multi) — Auswahlzustand wird
/// nie nur über Farbe transportiert, siehe Text+Balken in [_PollOption].
class _SelectionMark extends StatelessWidget {
  const _SelectionMark({required this.selected, required this.allowMultiple});

  final bool selected;
  final bool allowMultiple;

  @override
  Widget build(BuildContext context) {
    if (allowMultiple) {
      return Container(
        width: 20,
        height: 20,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? BelongColors.coral : BelongColors.card,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: selected ? BelongColors.coral : BelongColors.borderIdle,
            width: 2,
          ),
        ),
        child: selected
            ? const BelongIcon(BelongIconGlyph.check,
                size: 13, color: Color(0xFFFFFFFF))
            : null,
      );
    }
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? BelongColors.coral : BelongColors.borderIdle,
          width: 2,
        ),
      ),
      alignment: Alignment.center,
      child: selected
          ? Container(
              width: 9,
              height: 9,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: BelongColors.coral),
            )
          : null,
    );
  }
}
