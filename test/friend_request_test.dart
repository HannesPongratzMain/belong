import 'package:flutter_test/flutter_test.dart';

import 'package:belong/data/mock/mock_auth_repository.dart';
import 'package:belong/data/mock/mock_database.dart';
import 'package:belong/data/mock/mock_friend_repository.dart';
import 'package:belong/data/repositories/exceptions.dart';
import 'package:belong/domain/models/anonymity_level.dart';

/// Spiegelt `verification_enforcement_test.dart`: prüft, dass die
/// Verifizierungspflicht (BEL-04: nur verifizierte Mitglieder dürfen
/// Freundschaftsanfragen senden) auch datenschichtseitig gilt, nicht nur im
/// UI, sowie die Annehmen/Ablehnen-Übergänge selbst.
void main() {
  late MockDatabase db;
  late MockAuthRepository auth;
  late MockFriendRepository friends;

  setUp(() async {
    db = MockDatabase(latency: Duration.zero);
    auth = MockAuthRepository(db);
    friends = MockFriendRepository(db);
    await auth.completeOnboarding(
        level: AnonymityLevel.nickname,
        nickname: 'test-nutzer',
        ageConfirmed: true);
  });

  test('sendRequest() wirft VerificationRequiredException unverifiziert', () {
    expect(
      () => friends.sendRequest('u-jan'),
      throwsA(isA<VerificationRequiredException>()),
    );
  });

  test('sendRequest() gelingt nach Verifizierung', () async {
    await auth.verifyPhone();
    expect(friends.sendRequest('u-jan'), completes);
  });

  test('acceptRequest() verschiebt eine geseedete Anfrage zu den Freunden',
      () async {
    final before = await friends.watchIncomingRequests().first;
    expect(before.any((request) => request.fromUserId == 'u-jan'), isTrue);

    await friends.acceptRequest('u-jan');

    final after = await friends.watchIncomingRequests().first;
    expect(after.any((request) => request.fromUserId == 'u-jan'), isFalse);

    final friendsList = await friends.watchFriends().first;
    expect(
      friendsList
          .any((f) => f.userId == 'u-jan' && f.nickname == 'jan_orga'),
      isTrue,
    );
  });

  test('declineRequest() entfernt die Anfrage ohne Freundschaft anzulegen',
      () async {
    await friends.declineRequest('u-lena');

    final requests = await friends.watchIncomingRequests().first;
    expect(requests.any((request) => request.fromUserId == 'u-lena'), isFalse);
    expect(await friends.watchFriends().first, isEmpty);
  });
}
