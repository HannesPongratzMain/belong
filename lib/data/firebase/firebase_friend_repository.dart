import '../../domain/models/friend.dart';
import '../../domain/models/friend_request.dart';
import '../repositories/friend_repository.dart';
import 'firebase_auth_client.dart';
import 'rtdb_client.dart';

/// `friendRequests/{toUid}/{fromUid}` (Anfrage) + `friendships/{uid}/{friendUid}`
/// (angenommen) — Nicknames werden zum Schreibzeitpunkt denormalisiert, weil
/// `users/{uid}` laut Rules nur von der jeweiligen Person selbst lesbar ist.
/// Verifizierung beider Seiten wird serverseitig über die Rules erzwungen.
class FirebaseFriendRepository implements FriendRepository {
  FirebaseFriendRepository(this._auth, this._db);

  final FirebaseAuthClient _auth;
  final RtdbClient _db;

  @override
  Stream<List<FriendRequest>> watchIncomingRequests() async* {
    await _auth.ensureSignedIn();
    yield* _db.watch('friendRequests/${_auth.uid}').map((json) {
      if (json == null) return const <FriendRequest>[];
      return [
        for (final entry in (json as Map<String, dynamic>).entries)
          FriendRequest.fromJson({
            'fromUserId': entry.key,
            ...(entry.value as Map).cast<String, dynamic>(),
          }),
      ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    });
  }

  @override
  Stream<List<Friend>> watchFriends() async* {
    await _auth.ensureSignedIn();
    yield* _db.watch('friendships/${_auth.uid}').map((json) {
      if (json == null) return const <Friend>[];
      return [
        for (final entry in (json as Map<String, dynamic>).entries)
          Friend.fromJson({
            'userId': entry.key,
            ...(entry.value as Map).cast<String, dynamic>(),
          }),
      ]..sort((a, b) => a.nickname.compareTo(b.nickname));
    });
  }

  @override
  Future<void> sendRequest(String toUserId) async {
    await _auth.ensureSignedIn();
    final nickname = await _ownNickname();
    await _db.patch('', {
      'friendRequests/$toUserId/${_auth.uid}': {
        'fromNickname': nickname,
        'createdAt': DateTime.now().toIso8601String(),
      },
    });
  }

  @override
  Future<void> acceptRequest(String fromUserId) async {
    await _auth.ensureSignedIn();
    final uid = _auth.uid;

    final requestJson = await _db.get('friendRequests/$uid/$fromUserId');
    final fromNickname =
        (requestJson as Map?)?['fromNickname'] as String? ?? 'jemand';
    final ownNickname = await _ownNickname();
    final since = DateTime.now().toIso8601String();

    await _db.patch('', {
      'friendships/$uid/$fromUserId': {'nickname': fromNickname, 'since': since},
      'friendships/$fromUserId/$uid': {'nickname': ownNickname, 'since': since},
      'friendRequests/$uid/$fromUserId': null,
    });
  }

  @override
  Future<void> declineRequest(String fromUserId) async {
    await _auth.ensureSignedIn();
    await _db.patch('', {'friendRequests/${_auth.uid}/$fromUserId': null});
  }

  Future<String> _ownNickname() async =>
      await _db.get('users/${_auth.uid}/nickname') as String? ?? 'jemand';
}
