import '../../domain/models/participation.dart';

/// Teilnahmen der aktuellen Nutzer:in (One-Click-Join).
abstract interface class ParticipationRepository {
  Future<List<Participation>> myParticipations();

  /// Live-Sicht auf die eigenen Teilnahmen (für Feed-Buttons, Profil, Chats).
  Stream<Set<String>> watchJoinedActivityIds();

  /// Tritt bei. Wirft [ActivityFullException], wenn kein Platz mehr frei ist.
  Future<void> join(String activityId);

  Future<void> leave(String activityId);
}

class ActivityFullException implements Exception {
  const ActivityFullException();
}
