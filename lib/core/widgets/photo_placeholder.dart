import 'package:flutter/widgets.dart';

import '../../domain/models/activity.dart';
import '../theme/belong_colors.dart';

/// Foto-Platzhalter: schlichte, flache neutrale Fläche — ohne Deko-Symbol.
/// Später durch echte Bilder ersetzbar; die API bleibt dafür bestehen.
class PhotoPlaceholder extends StatelessWidget {
  const PhotoPlaceholder({
    super.key,
    required this.category,
    this.photoHint,
    this.showHint = true,
  });

  final ActivityCategory category;
  final String? photoHint;
  final bool showHint;

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(color: BelongColors.cream);
  }
}
