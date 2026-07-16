import 'dart:async';

import '../../domain/models/friend.dart';
import '../../domain/models/friend_request.dart';
import '../../domain/models/verification_level.dart';
import '../repositories/exceptions.dart';
import '../repositories/friend_repository.dart';
import 'mock_database.dart';

class MockFriendRepository implements FriendRepository {
  MockFriendRepository(this._db);

  final MockDatabase _db;

  @override
  Stream<List<FriendRequest>> watchIncomingRequests() async* {
    yield _db.incomingFriendRequests.values.toList();
    yield* _db.friendRequestChanges.stream
        .map((requests) => requests.values.toList());
  }

  @override
  Stream<List<Friend>> watchFriends() async* {
    yield _db.friends.values.toList();
    yield* _db.friendChanges.stream.map((friends) => friends.values.toList());
  }

  @override
  Future<void> sendRequest(String toUserId) {
    return _db(() {
      if (_db.profile?.verificationLevel != VerificationLevel.phone) {
        throw const VerificationRequiredException();
      }
      // Bekannte Mock-Grenze: Der Mock kennt nur „mich" vollständig, es gibt
      // also niemanden auf der anderen Seite, der die Anfrage je annimmt —
      // im echten Firebase-Backend landet sie normal bei der Empfänger:in.
    });
  }

  @override
  Future<void> acceptRequest(String fromUserId) {
    return _db(() {
      final request = _db.incomingFriendRequests.remove(fromUserId);
      if (request == null) return;
      _db.friends[fromUserId] = Friend(
        userId: fromUserId,
        nickname: request.fromNickname,
        since: DateTime.now(),
      );
      _db.friendRequestChanges.add(_db.incomingFriendRequests);
      _db.friendChanges.add(_db.friends);
    });
  }

  @override
  Future<void> declineRequest(String fromUserId) {
    return _db(() {
      if (_db.incomingFriendRequests.remove(fromUserId) == null) return;
      _db.friendRequestChanges.add(_db.incomingFriendRequests);
    });
  }
}
