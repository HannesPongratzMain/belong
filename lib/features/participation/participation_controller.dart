import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import '../../data/repositories/participation_repository.dart';
import '../../domain/models/access_level.dart';
import '../../domain/models/activity.dart';
import '../../domain/models/verification_level.dart';
import '../feed/feed_controller.dart';
import '../profile/profile_controller.dart';

/// Live-Menge der Aktivitäts-IDs, bei denen die Nutzer:in dabei ist.
final joinedIdsProvider = StreamProvider<Set<String>>(
  (ref) => ref.watch(participationRepositoryProvider).watchJoinedActivityIds(),
);

/// Ergebnis eines Join-Versuchs (für UI-Feedback).
enum JoinResult { joined, left, full }

/// Führt One-Click-Join/Leave aus; `state` enthält die IDs mit laufender
/// Anfrage, damit Buttons einen Pending-Zustand zeigen können.
final joinControllerProvider =
    NotifierProvider<JoinController, Set<String>>(JoinController.new);

class JoinController extends Notifier<Set<String>> {
  @override
  Set<String> build() => const {};

  bool isPending(String activityId) => state.contains(activityId);

  Future<JoinResult> join(String activityId) async {
    state = {...state, activityId};
    try {
      await ref.read(participationRepositoryProvider).join(activityId);
      return JoinResult.joined;
    } on ActivityFullException {
      return JoinResult.full;
    } finally {
      state = {...state}..remove(activityId);
      // Teilnehmerzahlen im Feed aktualisieren (alte Daten bleiben
      // während des Nachladens sichtbar, kein Skeleton-Flackern).
      ref.invalidate(feedProvider);
    }
  }

  Future<JoinResult> leave(String activityId) async {
    state = {...state, activityId};
    try {
      await ref.read(participationRepositoryProvider).leave(activityId);
      return JoinResult.left;
    } finally {
      state = {...state}..remove(activityId);
      ref.invalidate(feedProvider);
    }
  }
}

/// Aktivitäten, bei denen die Nutzer:in dabei ist („Du bist dabei").
final joinedActivitiesProvider = FutureProvider<List<Activity>>((ref) async {
  final ids = await ref.watch(joinedIdsProvider.future);
  final repository = ref.watch(activityRepositoryProvider);
  final activities =
      await Future.wait(ids.map((id) => repository.activityById(id)));
  activities.sort((a, b) => a.startsAt.compareTo(b.startsAt));
  return activities;
});

/// Selbst gestartete Aktivitäten.
final myActivitiesProvider = FutureProvider<List<Activity>>(
  (ref) => ref.watch(activityRepositoryProvider).myActivities(),
);

/// Aktivitäten mit Chat-Zugang: Teilnahmen + selbst gestartete.
final chatActivitiesProvider = FutureProvider<List<Activity>>((ref) async {
  final joined = await ref.watch(joinedActivitiesProvider.future);
  final mine = await ref.watch(myActivitiesProvider.future);
  final byId = {for (final activity in [...joined, ...mine]) activity.id: activity};
  final merged = byId.values.toList()
    ..sort((a, b) => a.startsAt.compareTo(b.startsAt));
  return merged;
});

/// Live-Sicht auf eine einzelne Aktivität (Detail, Chat-Header).
final activityStreamProvider = StreamProvider.family<Activity, String>(
  (ref, id) => ref.watch(activityRepositoryProvider).watchActivity(id),
);

/// Erlaubter Detailgrad je Aktivität — BEL-03-Sichtbarkeitsmatrix aus
/// Verifizierung + Teilnahme/Host-Status abgeleitet.
final accessLevelProvider = Provider.family<AccessLevel, String>((ref, activityId) {
  final verificationLevel = ref.watch(profileProvider).value?.verificationLevel ??
      VerificationLevel.none;
  final joined =
      ref.watch(joinedIdsProvider).value?.contains(activityId) ?? false;
  final isMine = ref.watch(myActivitiesProvider).value
          ?.any((activity) => activity.id == activityId) ??
      false;
  return AccessLevel.derive(
    verificationLevel: verificationLevel,
    hasAccess: joined || isMine,
  );
});
