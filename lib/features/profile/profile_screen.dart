import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format/belong_dates.dart';
import '../../core/theme/belong_colors.dart';
import '../../core/theme/belong_dimens.dart';
import '../../core/theme/belong_shadows.dart';
import '../../core/theme/belong_typography.dart';
import '../../core/widgets/belong_icons.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/category_chip.dart';
import '../../core/widgets/pills.dart';
import '../../core/widgets/pressable.dart';
import '../../domain/models/access_level.dart';
import '../../domain/models/activity.dart';
import '../../domain/models/anonymity_level.dart';
import '../../domain/models/friend.dart';
import '../../domain/models/friend_request.dart';
import '../../domain/models/user_profile.dart';
import '../../domain/models/verification_level.dart';
import '../activity_detail/activity_detail_screen.dart';
import '../friends/friends_controller.dart';
import '../participation/participation_controller.dart';
import 'profile_controller.dart';
import 'widgets/change_anonymity_sheet.dart';
import 'widgets/verify_phone_sheet.dart';

/// Profil · minimal & anonym — die Anti-These zu Social Media:
/// kein Foto-Zwang, keine Follower, nichts zu polieren.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider).value;
    final joined = ref.watch(joinedActivitiesProvider).value ?? const [];
    final mine = ref.watch(myActivitiesProvider).value ?? const [];

    if (profile == null) return const SizedBox.expand();

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _IdentityHeader(profile: profile),
        Padding(
          padding: const EdgeInsets.fromLTRB(BelongSpacing.screen,
              BelongSpacing.md, BelongSpacing.screen, BelongSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _AntiSocialNote(),
              if (profile.anonymityLevel == AnonymityLevel.nicknameInterests) ...[
                const SizedBox(height: BelongSpacing.lg),
                Text('DEINE INTERESSEN', style: BelongText.sectionLabel),
                const SizedBox(height: BelongSpacing.sm),
                _InterestChips(profile: profile),
              ],
              const SizedBox(height: BelongSpacing.lg),
              Text('FREUNDE', style: BelongText.sectionLabel),
              const SizedBox(height: BelongSpacing.sm),
              const _FriendsSection(),
              const SizedBox(height: BelongSpacing.lg),
              Text('DU BIST DABEI', style: BelongText.sectionLabel),
              const SizedBox(height: BelongSpacing.sm),
              if (joined.isEmpty)
                Text(
                  'Noch nichts geplant — schau in den Feed, irgendwas ist immer.',
                  style: BelongText.bodySmall.copyWith(color: BelongColors.muted),
                )
              else
                for (final activity in joined) ...[
                  _JoinedActivityRow(activity: activity),
                  const SizedBox(height: BelongSpacing.xs),
                ],
              if (mine.isNotEmpty) ...[
                const SizedBox(height: BelongSpacing.lg),
                Text('VON DIR GESTARTET', style: BelongText.sectionLabel),
                const SizedBox(height: BelongSpacing.sm),
                for (final activity in mine) ...[
                  _JoinedActivityRow(activity: activity),
                  const SizedBox(height: BelongSpacing.xs),
                ],
              ],
              const SizedBox(height: BelongSpacing.lg),
              _VerificationRow(verificationLevel: profile.verificationLevel),
              const SizedBox(height: BelongSpacing.sm),
              _VisibilityRow(
                  onTap: () => showChangeAnonymitySheet(context)),
            ],
          ),
        ),
      ],
    );
  }
}

/// Identity-Header auf ruhigem Neutralton — Gelb bleibt Badges vorbehalten.
class _IdentityHeader extends StatelessWidget {
  const _IdentityHeader({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    return Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: BelongColors.header,
          border: Border(bottom: BorderSide(color: BelongColors.hairline)),
        ),
        padding: EdgeInsets.fromLTRB(
            BelongSpacing.lg, topInset + 26, BelongSpacing.lg, 30),
        child: Column(
          children: [
            Container(
              width: 76,
              height: 76,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: BelongColors.card,
                shape: BoxShape.circle,
                boxShadow: BelongShadows.e1,
              ),
              child: profile.anonymityLevel == AnonymityLevel.anonymous
                  ? const BelongIcon(BelongIconGlyph.person,
                      size: 32, color: BelongColors.muted)
                  : Text(profile.nickname.substring(0, 1),
                      style: BelongText.displayTitle
                          .copyWith(fontSize: 30, color: BelongColors.coralDeep)),
            ),
            const SizedBox(height: BelongSpacing.sm),
            Text(profile.nickname, style: BelongText.displayTitle),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                BelongPill(
                  label: profile.anonymityLevel.label,
                  background: BelongColors.card,
                  foreground: BelongColors.coralDeep,
                  textStyle:
                      BelongText.chip.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(width: BelongSpacing.xs),
                BelongPill(
                  label: 'ändern',
                  background: BelongColors.ink.withValues(alpha: 0.1),
                  foreground: BelongColors.inkSoft,
                  onTap: () => showChangeAnonymitySheet(context),
                  textStyle:
                      BelongText.chip.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ],
        ),
    );
  }
}

class _AntiSocialNote extends StatelessWidget {
  const _AntiSocialNote();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 7,
          height: 7,
          margin: const EdgeInsets.only(top: 6, left: 4, right: 10),
          decoration: const BoxDecoration(
              shape: BoxShape.circle, color: BelongColors.coral),
        ),
        Expanded(
          child: Text(
            'Kein Foto nötig · keine Follower · nichts zu polieren',
            style: BelongText.bodySmall.copyWith(
                fontWeight: FontWeight.w700, color: BelongColors.inkSoft),
          ),
        ),
      ],
    );
  }
}

class _InterestChips extends ConsumerWidget {
  const _InterestChips({required this.profile});

  final UserProfile profile;

  static const _pool = [
    'Draußen', 'Spiele', 'Kaffee', 'Tanzen', 'Musik', 'Essen', 'Sport', 'Kreatives',
  ];

  /// Chip-Farben rotieren durch die verbleibenden Tonfamilien.
  static const _tints = [
    (BelongColors.amberTint, BelongColors.amberDeep),
    (BelongColors.coralTint, BelongColors.coralDeep),
    (BelongColors.chipNeutral, BelongColors.inkSoft),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final (index, interest) in profile.interests.indexed)
          BelongPill(
            label: interest,
            background: _tints[index % _tints.length].$1,
            foreground: _tints[index % _tints.length].$2,
          ),
        BelongPill(
          label: '+ bearbeiten',
          background: BelongColors.card,
          foreground: BelongColors.inkSoft,
          border: Border.all(color: BelongColors.borderIdle),
          onTap: () => _editInterests(context, ref),
        ),
      ],
    );
  }

  Future<void> _editInterests(BuildContext context, WidgetRef ref) async {
    final selection = await showInterestPickerSheet(
      context: context,
      pool: _pool,
      selected: profile.interests.toSet(),
    );
    if (selection != null) {
      await ref.read(profileProvider.notifier).updateInterests(selection);
    }
  }
}

/// Row unter „Du bist dabei": Kategorie-Blob, Titel, Zeit · Ort, Chevron.
class _JoinedActivityRow extends StatelessWidget {
  const _JoinedActivityRow({required this.activity});

  final Activity activity;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: () =>
          Navigator.of(context).push(ActivityDetailScreen.route(activity.id)),
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
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: activity.category.tint,
                shape: BoxShape.circle,
              ),
              child: BelongIcon(activity.category.glyph,
                  size: 20, color: activity.category.deep),
            ),
            const SizedBox(width: BelongSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(activity.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: BelongText.rowTitle.copyWith(fontSize: 15)),
                  const SizedBox(height: 3),
                  Text(
                    '${BelongDates.weekday(activity.startsAt)} '
                    '${BelongDates.time(activity.startsAt)} · '
                    '${activity.placeLabelFor(AccessLevel.joined)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: BelongText.meta,
                  ),
                ],
              ),
            ),
            const BelongIcon(BelongIconGlyph.chevronRight,
                size: 16, color: BelongColors.placeholder),
          ],
        ),
      ),
    );
  }
}

/// VerificationRow: Status + Einstieg in die (simulierte) Verifizierung —
/// schaltet Beitreten/Hosten/Chatten frei (BEL-03).
class _VerificationRow extends StatelessWidget {
  const _VerificationRow({required this.verificationLevel});

  final VerificationLevel verificationLevel;

  @override
  Widget build(BuildContext context) {
    final verified = verificationLevel == VerificationLevel.phone;
    return Pressable(
      onTap: verified ? null : () => showVerifyPhoneSheet(context),
      pressedScale: verified ? 1 : 0.985,
      semanticLabel: verified ? 'Verifiziert' : 'Jetzt verifizieren',
      child: Container(
        padding: const EdgeInsets.all(BelongSpacing.md),
        decoration: BoxDecoration(
          color: verified ? BelongColors.sageTint : BelongColors.chipNeutral,
          borderRadius: BelongRadii.rowCardAll,
        ),
        child: Row(
          children: [
            BelongIcon(
              verified ? BelongIconGlyph.verified : BelongIconGlyph.lock,
              size: 22,
              color: verified ? BelongColors.sage : BelongColors.muted,
            ),
            const SizedBox(width: BelongSpacing.sm),
            Expanded(
              child: Text(
                verified
                    ? 'Verifiziert — du kannst beitreten, hosten und chatten.'
                    : 'Noch nicht verifiziert — nötig zum Beitreten und Hosten.',
                style: BelongText.bodySmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: verified ? BelongColors.sage : BelongColors.inkSoft,
                ),
              ),
            ),
            if (!verified)
              const BelongIcon(BelongIconGlyph.chevronRight,
                  size: 16, color: BelongColors.inkSoft),
          ],
        ),
      ),
    );
  }
}

/// VisibilityRow: Schild auf Coral-Tint — Kontrolle sichtbar machen.
class _VisibilityRow extends StatelessWidget {
  const _VisibilityRow({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      pressedScale: 0.985,
      semanticLabel: 'Sichtbarkeit ändern',
      child: Container(
        padding: const EdgeInsets.all(BelongSpacing.md),
        decoration: BoxDecoration(
          color: BelongColors.coralTint,
          borderRadius: BelongRadii.rowCardAll,
        ),
        child: Row(
          children: [
            const BelongIcon(BelongIconGlyph.shield,
                size: 22, color: BelongColors.coralDeep),
            const SizedBox(width: BelongSpacing.sm),
            Expanded(
              child: Text(
                'Du entscheidest, was sichtbar ist — Stufe jederzeit wechselbar.',
                style: BelongText.bodySmall.copyWith(
                    fontWeight: FontWeight.w700, color: BelongColors.coralDeep),
              ),
            ),
            const BelongIcon(BelongIconGlyph.chevronRight,
                size: 16, color: BelongColors.coralDeep),
          ],
        ),
      ),
    );
  }
}

/// Eingehende Anfragen (annehmen/ablehnen) + angenommene Freundschaften —
/// Einstieg zum Anfragen selbst liegt im Chat (Long-Press auf eine
/// Nachricht), hier nur Verwaltung.
class _FriendsSection extends ConsumerWidget {
  const _FriendsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requests = ref.watch(incomingFriendRequestsProvider).value ?? const [];
    final friends = ref.watch(friendsProvider).value ?? const [];
    final pending = ref.watch(friendActionControllerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final request in requests) ...[
          _FriendRequestRow(
              request: request, pending: pending.contains(request.fromUserId)),
          const SizedBox(height: BelongSpacing.xs),
        ],
        if (friends.isEmpty)
          Text(
            'Noch keine Freunde — frag im Chat einer Aktivität jemanden an.',
            style: BelongText.bodySmall.copyWith(color: BelongColors.muted),
          )
        else
          for (final friend in friends) ...[
            _FriendRow(friend: friend),
            const SizedBox(height: BelongSpacing.xs),
          ],
      ],
    );
  }
}

class _FriendRequestRow extends ConsumerWidget {
  const _FriendRequestRow({required this.request, required this.pending});

  final FriendRequest request;
  final bool pending;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(BelongSpacing.sm),
      decoration: BoxDecoration(
        color: BelongColors.card,
        borderRadius: BelongRadii.rowCardAll,
        border: Border.all(color: BelongColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(request.fromNickname,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: BelongText.rowTitle.copyWith(fontSize: 15)),
          ),
          Opacity(
            opacity: pending ? 0.5 : 1,
            child: BelongPill(
              label: 'Annehmen',
              background: BelongColors.coral,
              foreground: const Color(0xFFFFFFFF),
              textStyle: BelongText.chip.copyWith(fontWeight: FontWeight.w700),
              onTap: pending
                  ? null
                  : () => ref
                      .read(friendActionControllerProvider.notifier)
                      .accept(request.fromUserId),
            ),
          ),
          const SizedBox(width: BelongSpacing.xs),
          GhostButton(
            label: 'Ablehnen',
            onTap: pending
                ? null
                : () => ref
                    .read(friendActionControllerProvider.notifier)
                    .decline(request.fromUserId),
          ),
        ],
      ),
    );
  }
}

class _FriendRow extends StatelessWidget {
  const _FriendRow({required this.friend});

  final Friend friend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(BelongSpacing.sm),
      decoration: BoxDecoration(
        color: BelongColors.card,
        borderRadius: BelongRadii.rowCardAll,
        border: Border.all(color: BelongColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
                color: BelongColors.coralTint, shape: BoxShape.circle),
            child: Text(
              friend.nickname.substring(0, 1),
              style: const TextStyle(
                fontFamily: BelongFonts.sans,
                fontWeight: FontWeight.w600,
                color: BelongColors.coralDeep,
              ),
            ),
          ),
          const SizedBox(width: BelongSpacing.sm),
          Expanded(
            child: Text(friend.nickname,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: BelongText.rowTitle.copyWith(fontSize: 15)),
          ),
        ],
      ),
    );
  }
}
