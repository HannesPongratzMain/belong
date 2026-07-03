import 'package:flutter/material.dart' show Scaffold;
import 'package:flutter/widgets.dart';

import '../core/theme/belong_colors.dart';
import '../core/theme/belong_dimens.dart';
import '../core/theme/belong_typography.dart';
import '../core/widgets/belong_icons.dart';
import '../core/widgets/pressable.dart';
import '../features/chats/chats_screen.dart';
import '../features/create/create_activity_sheet.dart';
import '../features/feed/feed_screen.dart';
import '../features/profile/profile_screen.dart';

/// App-Shell mit TabBar: Entdecken · Starten · Chats · Du.
/// „Starten" ist bewusst eine Aktion (öffnet das Erstellen-Sheet),
/// kein eigener Tab — der Feed bleibt der Ankerpunkt.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BelongColors.surface,
      body: Column(
        children: [
          Expanded(
            child: IndexedStack(
              index: _index,
              children: [
                const FeedScreen(),
                ChatsScreen(onDiscover: () => setState(() => _index = 0)),
                const ProfileScreen(),
              ],
            ),
          ),
          _TabBar(
            index: _index,
            onSelect: (index) => setState(() => _index = index),
            onCreate: () => showCreateActivitySheet(context),
          ),
        ],
      ),
    );
  }
}

class _TabBar extends StatelessWidget {
  const _TabBar({
    required this.index,
    required this.onSelect,
    required this.onCreate,
  });

  final int index;
  final ValueChanged<int> onSelect;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return Container(
      padding: EdgeInsets.only(top: 6, bottom: 6 + bottomInset),
      decoration: const BoxDecoration(
        color: BelongColors.card,
        border: Border(top: BorderSide(color: BelongColors.hairline)),
      ),
      child: Row(
        children: [
          _TabItem(
            glyph: BelongIconGlyph.discover,
            label: 'Entdecken',
            active: index == 0,
            onTap: () => onSelect(0),
          ),
          _TabItem(
            glyph: BelongIconGlyph.plus,
            label: 'Starten',
            active: false,
            onTap: onCreate,
          ),
          _TabItem(
            glyph: BelongIconGlyph.chat,
            label: 'Chats',
            active: index == 1,
            onTap: () => onSelect(1),
          ),
          _TabItem(
            glyph: BelongIconGlyph.person,
            label: 'Du',
            active: index == 2,
            onTap: () => onSelect(2),
          ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.glyph,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final BelongIconGlyph glyph;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? BelongColors.coralDeep : BelongColors.muted;
    return Expanded(
      child: Pressable(
        onTap: onTap,
        semanticLabel: label,
        child: SizedBox(
          height: BelongSpacing.hitTarget + 4,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              BelongIcon(glyph, size: 22, color: color),
              const SizedBox(height: 3),
              Text(
                label,
                style: BelongText.caption.copyWith(
                  color: color,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
