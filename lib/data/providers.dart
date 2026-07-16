import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase/firebase_activity_repository.dart';
import 'firebase/firebase_auth_client.dart';
import 'firebase/firebase_auth_repository.dart';
import 'firebase/firebase_chat_repository.dart';
import 'firebase/firebase_config.dart';
import 'firebase/firebase_friend_repository.dart';
import 'firebase/firebase_participation_repository.dart';
import 'firebase/rtdb_client.dart';
import 'mock/mock_activity_repository.dart';
import 'mock/mock_auth_repository.dart';
import 'mock/mock_chat_repository.dart';
import 'mock/mock_database.dart';
import 'mock/mock_friend_repository.dart';
import 'mock/mock_participation_repository.dart';
import 'repositories/activity_repository.dart';
import 'repositories/auth_repository.dart';
import 'repositories/chat_repository.dart';
import 'repositories/friend_repository.dart';
import 'repositories/participation_repository.dart';

/// Verfügbare Datenquellen der App.
enum DataBackend { mock, firebase }

/// **Der eine Austauschpunkt** für die Datenschicht.
///
/// Standard ist Firebase (Realtime Database + Anonymous Auth via REST).
/// Plan B: Ist kein API-Key hinterlegt — oder wird dieser Provider (z. B.
/// in Tests) mit [DataBackend.mock] überschrieben — läuft die App
/// vollständig auf den lokalen Mockdaten weiter. UI und Controller merken
/// davon nichts.
final dataBackendProvider = Provider<DataBackend>(
  (ref) => BelongFirebaseConfig.isConfigured
      ? DataBackend.firebase
      : DataBackend.mock,
);

// ---------------------------------------------------------------------------
// Firebase-Infrastruktur (REST-Clients, geteilt von allen Repositories)
// ---------------------------------------------------------------------------

final firebaseAuthClientProvider =
    Provider<FirebaseAuthClient>((ref) => FirebaseAuthClient());

final rtdbClientProvider = Provider<RtdbClient>(
  (ref) => RtdbClient(ref.watch(firebaseAuthClientProvider)),
);

// ---------------------------------------------------------------------------
// Mock-Infrastruktur (Plan B)
// ---------------------------------------------------------------------------

final mockDatabaseProvider = Provider<MockDatabase>((ref) => MockDatabase());

// ---------------------------------------------------------------------------
// Repositories — die UI kennt nur diese vier Interfaces.
// ---------------------------------------------------------------------------

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return switch (ref.watch(dataBackendProvider)) {
    DataBackend.firebase => FirebaseAuthRepository(
        ref.watch(firebaseAuthClientProvider), ref.watch(rtdbClientProvider)),
    DataBackend.mock => MockAuthRepository(ref.watch(mockDatabaseProvider)),
  };
});

final activityRepositoryProvider = Provider<ActivityRepository>((ref) {
  return switch (ref.watch(dataBackendProvider)) {
    DataBackend.firebase => FirebaseActivityRepository(
        ref.watch(firebaseAuthClientProvider), ref.watch(rtdbClientProvider)),
    DataBackend.mock =>
      MockActivityRepository(ref.watch(mockDatabaseProvider)),
  };
});

final participationRepositoryProvider =
    Provider<ParticipationRepository>((ref) {
  return switch (ref.watch(dataBackendProvider)) {
    DataBackend.firebase => FirebaseParticipationRepository(
        ref.watch(firebaseAuthClientProvider), ref.watch(rtdbClientProvider)),
    DataBackend.mock =>
      MockParticipationRepository(ref.watch(mockDatabaseProvider)),
  };
});

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return switch (ref.watch(dataBackendProvider)) {
    DataBackend.firebase => FirebaseChatRepository(
        ref.watch(firebaseAuthClientProvider), ref.watch(rtdbClientProvider)),
    DataBackend.mock => MockChatRepository(ref.watch(mockDatabaseProvider)),
  };
});

final friendRepositoryProvider = Provider<FriendRepository>((ref) {
  return switch (ref.watch(dataBackendProvider)) {
    DataBackend.firebase => FirebaseFriendRepository(
        ref.watch(firebaseAuthClientProvider), ref.watch(rtdbClientProvider)),
    DataBackend.mock => MockFriendRepository(ref.watch(mockDatabaseProvider)),
  };
});

/// Demo-Werkzeug für die Abgabe: macht den Fehler-Zustand des Feeds
/// vorführbar (Long-Press auf die „Kassel"-Pill) — in beiden Backends.
final feedErrorDemoProvider = Provider<void Function()>((ref) {
  switch (ref.watch(dataBackendProvider)) {
    case DataBackend.firebase:
      final repository = ref.watch(activityRepositoryProvider);
      return () =>
          (repository as FirebaseActivityRepository).failNextFeedFetch = true;
    case DataBackend.mock:
      final db = ref.watch(mockDatabaseProvider);
      return () => db.failNextFeedFetch = true;
  }
});
