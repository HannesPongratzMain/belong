import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import '../../domain/models/anonymity_level.dart';
import '../../domain/models/user_profile.dart';

/// Profil der aktuellen Nutzer:in. `null` = Onboarding steht noch aus —
/// daran hängt die Weiche Onboarding ↔ App-Shell.
final profileProvider =
    AsyncNotifierProvider<ProfileController, UserProfile?>(ProfileController.new);

class ProfileController extends AsyncNotifier<UserProfile?> {
  @override
  Future<UserProfile?> build() =>
      ref.watch(authRepositoryProvider).currentProfile();

  Future<void> completeOnboarding({
    required AnonymityLevel level,
    required String nickname,
    List<String> interests = const [],
  }) async {
    final profile = await ref.read(authRepositoryProvider).completeOnboarding(
          level: level,
          nickname: nickname,
          interests: interests,
        );
    state = AsyncData(profile);
  }

  Future<void> changeAnonymity(AnonymityLevel level, {String? nickname}) async {
    final current = state.value;
    if (current == null) return;
    final updated = await ref.read(authRepositoryProvider).updateProfile(
          current.copyWith(anonymityLevel: level, nickname: nickname),
        );
    state = AsyncData(updated);
  }

  Future<void> updateInterests(List<String> interests) async {
    final current = state.value;
    if (current == null) return;
    final updated = await ref
        .read(authRepositoryProvider)
        .updateProfile(current.copyWith(interests: interests));
    state = AsyncData(updated);
  }
}
