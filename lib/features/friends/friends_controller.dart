import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import '../../domain/models/friend.dart';
import '../../domain/models/friend_request.dart';

/// Live-Sicht auf eingehende Freundschaftsanfragen (Profil-Screen).
final incomingFriendRequestsProvider = StreamProvider<List<FriendRequest>>(
  (ref) => ref.watch(friendRepositoryProvider).watchIncomingRequests(),
);

/// Live-Sicht auf angenommene Freundschaften.
final friendsProvider = StreamProvider<List<Friend>>(
  (ref) => ref.watch(friendRepositoryProvider).watchFriends(),
);

/// Nur die IDs, für schnelle "ist diese Person schon Freund:in"-Prüfungen
/// (z. B. im Chat-Sheet, ohne die ganze Liste durchsuchen zu müssen).
final friendIdsProvider = Provider<Set<String>>((ref) {
  final friends = ref.watch(friendsProvider).value ?? const [];
  return {for (final friend in friends) friend.userId};
});

/// Sendet/beantwortet Freundschaftsanfragen; `state` enthält die IDs mit
/// laufender Anfrage (analog zu `JoinController`).
final friendActionControllerProvider =
    NotifierProvider<FriendActionController, Set<String>>(
        FriendActionController.new);

class FriendActionController extends Notifier<Set<String>> {
  @override
  Set<String> build() => const {};

  Future<void> sendRequest(String toUserId) async {
    state = {...state, toUserId};
    try {
      await ref.read(friendRepositoryProvider).sendRequest(toUserId);
    } finally {
      state = {...state}..remove(toUserId);
    }
  }

  Future<void> accept(String fromUserId) async {
    state = {...state, fromUserId};
    try {
      await ref.read(friendRepositoryProvider).acceptRequest(fromUserId);
    } finally {
      state = {...state}..remove(fromUserId);
    }
  }

  Future<void> decline(String fromUserId) async {
    state = {...state, fromUserId};
    try {
      await ref.read(friendRepositoryProvider).declineRequest(fromUserId);
    } finally {
      state = {...state}..remove(fromUserId);
    }
  }
}
