import '../../domain/models/friend.dart';
import '../../domain/models/friend_request.dart';

/// Freundschaftsanfragen zwischen verifizierten Mitgliedern — bewusst ohne
/// Kontaktabgleich/Telefonbuch, rein in-app (siehe BEL-04). Beide Seiten
/// müssen `VerificationLevel.phone` haben; das wird serverseitig über die
/// Database Rules erzwungen, [VerificationRequiredException] deckt die
/// eigene Seite auch datenschichtseitig ab (Defense in Depth, wie beim
/// Beitreten).
abstract interface class FriendRepository {
  /// Live-Sicht auf eingehende Anfragen (Profil-Screen).
  Stream<List<FriendRequest>> watchIncomingRequests();

  /// Live-Sicht auf angenommene Freundschaften.
  Stream<List<Friend>> watchFriends();

  /// Anfrage an [toUserId] senden — eigener Nickname wird intern aufgelöst.
  Future<void> sendRequest(String toUserId);

  /// Anfrage annehmen — Nickname wird aus der Anfrage selbst übernommen.
  Future<void> acceptRequest(String fromUserId);

  Future<void> declineRequest(String fromUserId);
}
