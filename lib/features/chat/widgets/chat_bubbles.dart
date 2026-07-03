import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:flutter/widgets.dart';

import '../../../core/platform/maps_opener_io.dart'
    if (dart.library.js_interop) '../../../core/platform/maps_opener_web.dart';

import '../../../core/theme/belong_colors.dart';
import '../../../core/theme/belong_dimens.dart';
import '../../../core/theme/belong_shadows.dart';
import '../../../core/theme/belong_typography.dart';
import '../../../core/widgets/belong_icons.dart';
import '../../../core/widgets/pills.dart';
import '../../../core/widgets/pressable.dart';
import '../../../domain/models/chat_message.dart';

/// Zentrierte System-Pille („leise-lerche ist jetzt dabei").
class SystemNote extends StatelessWidget {
  const SystemNote({super.key, required this.text, this.highlight = false});

  final String text;

  /// Beitritts-Notizen sind amber hervorgehoben, Info-Notizen neutral.
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        constraints: const BoxConstraints(maxWidth: 320),
        decoration: BoxDecoration(
          color: highlight ? BelongColors.amberTint : BelongColors.chipNeutral,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: BelongText.meta.copyWith(
            fontWeight: FontWeight.w700,
            color: highlight ? BelongColors.amberDeep : BelongColors.inkSoft,
          ),
        ),
      ),
    );
  }
}

/// Farbige Absender-Kennung: stabil aus dem Spitznamen abgeleitet.
Color senderColor(ChatMessage message) {
  if (message.isOrganizer) return BelongColors.amberDeep;
  const palette = [
    BelongColors.berryDeep,
    BelongColors.coralDeep,
    BelongColors.sage,
  ];
  return palette[message.senderNickname.hashCode.abs() % palette.length];
}

/// Chat-Bubble: fremd = weiß mit Border (18/18/18/6), eigen = Koralle
/// (18/18/6/18). Long-Press auf fremde öffnet das Schutz-Sheet.
class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.message,
    required this.isMine,
    this.onLongPress,
  });

  final ChatMessage message;
  final bool isMine;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final bubble = Container(
      constraints: const BoxConstraints(maxWidth: 300),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
      decoration: BoxDecoration(
        color: isMine ? BelongColors.coral : BelongColors.card,
        borderRadius: isMine ? BelongRadii.bubbleMine : BelongRadii.bubbleOther,
        border: isMine ? null : Border.all(color: BelongColors.border),
        boxShadow: BelongShadows.e1,
      ),
      child: Text(
        message.text,
        style: BelongText.body.copyWith(
          color: isMine ? const Color(0xFFFFFFFF) : BelongColors.ink,
        ),
      ),
    );

    return Column(
      crossAxisAlignment:
          isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        if (!isMine) ...[
          Padding(
            padding: const EdgeInsets.only(left: 6, bottom: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message.senderNickname,
                  style: BelongText.meta.copyWith(
                    fontWeight: FontWeight.w700,
                    color: senderColor(message),
                  ),
                ),
                if (message.isOrganizer) ...[
                  const SizedBox(width: 6),
                  BelongPill(
                    label: 'ORGA',
                    background: BelongColors.amberTint,
                    foreground: BelongColors.amberDeep,
                    textStyle: BelongText.caption.copyWith(letterSpacing: 0.8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  ),
                ],
              ],
            ),
          ),
        ],
        Pressable(
          onLongPress: onLongPress,
          semanticButton: false,
          pressedScale: 0.98,
          child: bubble,
        ),
      ],
    );
  }
}

/// MeetupPinCard: Treffpunkt mit Karten-Platzhalter und „Route"-Pill.
/// „Route" öffnet im Browser die Karten-Suche (pluginfrei); sonst wandert
/// die Adresse in die Zwischenablage — [onAddressCopied] zeigt danach das
/// Feedback, z. B. einen Toast.
class MeetupPinCard extends StatelessWidget {
  const MeetupPinCard({super.key, required this.pin, this.onAddressCopied});

  final MeetupPin pin;
  final VoidCallback? onAddressCopied;

  Future<void> _openRoute() async {
    final query = '${pin.placeName}, ${pin.address}';
    if (openMapsSearch(query)) return;
    await Clipboard.setData(ClipboardData(text: query));
    onAddressCopied?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 300),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: BelongColors.card,
        borderRadius: BorderRadius.circular(BelongRadii.bubble),
        border: Border.all(color: BelongColors.border),
        boxShadow: BelongShadows.e1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Karten-Platzhalter mit diagonalen Streifen und Pin.
          SizedBox(
            height: 86,
            width: double.infinity,
            child: CustomPaint(
              painter: const _MapStripesPainter(),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const BelongIcon(BelongIconGlyph.pin,
                        size: 24, color: BelongColors.coral, strokeWidth: 2.6),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: BelongColors.card,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('Kartenausschnitt',
                          style: BelongText.caption
                              .copyWith(color: BelongColors.muted)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(BelongSpacing.sm),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(pin.placeName, style: BelongText.rowTitle),
                      const SizedBox(height: 2),
                      Text('${pin.address} · ${pin.timeLabel}',
                          style: BelongText.meta),
                    ],
                  ),
                ),
                BelongPill(
                  label: 'Route',
                  background: BelongColors.chipNeutral,
                  foreground: BelongColors.inkSoft,
                  onTap: _openRoute,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Diagonale Amber-Streifen als Karten-Platzhalter.
class _MapStripesPainter extends CustomPainter {
  const _MapStripesPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, Paint()..color = BelongColors.cream);
    final stripe = Paint()
      ..color = BelongColors.chipNeutral
      ..strokeWidth = 14;
    for (var x = -size.height; x < size.width + size.height; x += 34) {
      canvas.drawLine(
          Offset(x, size.height + 8), Offset(x + size.height + 16, -8), stripe);
    }
  }

  @override
  bool shouldRepaint(_MapStripesPainter oldDelegate) => false;
}
