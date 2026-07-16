import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/belong_colors.dart';

/// Lucide-Icons hinter einer stabilen Glyph-API — einheitliche 2-px-Strokes,
/// konsistente Größen pro Kontext (24 px Bottom-Nav, 16 px Chips/Meta).
enum BelongIconGlyph {
  discover(LucideIcons.compass),
  plus(LucideIcons.plus),
  minus(LucideIcons.minus),
  chat(LucideIcons.messageCircle),
  person(LucideIcons.user),
  profile(LucideIcons.circleUser),
  users(LucideIcons.users),
  chevronDown(LucideIcons.chevronDown),
  chevronRight(LucideIcons.chevronRight),
  chevronLeft(LucideIcons.chevronLeft),
  close(LucideIcons.x),
  check(LucideIcons.check),
  pin(LucideIcons.mapPin),
  clock(LucideIcons.clock),
  shield(LucideIcons.shield),
  send(LucideIcons.send),
  flag(LucideIcons.flag),
  block(LucideIcons.ban),
  bell(LucideIcons.bell),
  alert(LucideIcons.circleAlert),
  eyeOff(LucideIcons.eyeOff),
  sparkles(LucideIcons.sparkles),
  wifi(LucideIcons.wifi),
  globe(LucideIcons.globe),
  lock(LucideIcons.lock),
  verified(LucideIcons.shieldCheck),
  userAdd(LucideIcons.userPlus),
  // Kategorien
  tree(LucideIcons.treePine),
  dance(LucideIcons.music2),
  dice(LucideIcons.gamepad2),
  note(LucideIcons.music),
  utensils(LucideIcons.utensilsCrossed),
  cup(LucideIcons.coffee);

  const BelongIconGlyph(this.icon);

  final IconData icon;
}

class BelongIcon extends StatelessWidget {
  const BelongIcon(
    this.glyph, {
    super.key,
    this.size = 22,
    this.color = BelongColors.muted,
  });

  final BelongIconGlyph glyph;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Icon(glyph.icon, size: size, color: color);
  }
}
