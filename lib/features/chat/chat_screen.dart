import 'package:flutter/cupertino.dart' show CupertinoPageRoute;
import 'package:flutter/material.dart' show InputBorder, InputDecoration, Scaffold, TextField;
import 'package:flutter/services.dart' show LengthLimitingTextInputFormatter;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format/belong_dates.dart';
import '../../core/theme/belong_colors.dart';
import '../../core/theme/belong_dimens.dart';
import '../../core/theme/belong_shadows.dart';
import '../../core/theme/belong_typography.dart';
import '../../core/widgets/belong_icons.dart';
import '../../core/widgets/pills.dart';
import '../../core/widgets/pressable.dart';
import '../../domain/models/chat_message.dart';
import '../participation/participation_controller.dart';
import '../profile/profile_controller.dart';
import 'chat_controller.dart';
import 'widgets/chat_bubbles.dart';
import 'widgets/meetup_sheet.dart';
import 'widgets/safety_sheet.dart';

/// Gruppenchat · Koordination — sichtbar erst nach dem Beitreten.
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, required this.activityId});

  final String activityId;

  static Route<void> route(String activityId) => CupertinoPageRoute(
        builder: (_) => ChatScreen(activityId: activityId),
      );

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _composerController = TextEditingController();
  final _scrollController = ScrollController();
  String? _toast;
  bool _didInitialScroll = false;

  @override
  void dispose() {
    _composerController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _showToast(String message) {
    setState(() => _toast = message);
    Future<void>.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _toast = null);
    });
  }

  /// Ans Ende scrollen, sobald die eigene Nachricht im Stream ist.
  Future<void> _scrollToEnd() async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: BelongMotion.medium,
        curve: BelongMotion.curve,
      );
    }
  }

  Future<void> _send() async {
    final text = _composerController.text;
    _composerController.clear();
    await ref.read(chatActionsProvider).send(widget.activityId, text);
    await _scrollToEnd();
  }

  Future<void> _shareMeetup() async {
    final pin = await showMeetupSheet(context: context);
    if (pin == null) return;
    await ref.read(chatActionsProvider).sendMeetupPin(widget.activityId, pin);
    await _scrollToEnd();
  }

  void _openSafetySheet(ChatMessage message) {
    showSafetySheet(
      context: context,
      message: message,
      onReport: () async {
        await ref.read(chatActionsProvider).report(message);
        _showToast('Danke — unser Team schaut innerhalb von 24 h drauf.');
      },
      onBlock: () async {
        await ref.read(chatActionsProvider).block(message);
        _showToast('${message.senderNickname} ist blockiert.');
      },
      onMute: () async {
        await ref.read(chatActionsProvider).mute(widget.activityId);
        _showToast('Chat stummgeschaltet — du bleibst dabei.');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final activity = ref.watch(activityStreamProvider(widget.activityId)).value;
    final messages = ref.watch(chatMessagesProvider(widget.activityId));

    // Beim ersten Laden ans Ende springen — die neueste Nachricht zählt.
    ref.listen(chatMessagesProvider(widget.activityId), (_, next) {
      if (_didInitialScroll || next.value == null) return;
      _didInitialScroll = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    });

    return Scaffold(
      backgroundColor: BelongColors.surface,
      body: Column(
        children: [
          _ChatHeader(
            title: activity?.title ?? '…',
            subtitle: activity == null
                ? ''
                : '${activity.participantCount} dabei · '
                    '${BelongDates.weekday(activity.startsAt)} '
                    '${BelongDates.time(activity.startsAt)}',
            onSafety: () => showChatProtectionSheet(
              context: context,
              onMute: () async {
                await ref.read(chatActionsProvider).mute(widget.activityId);
                _showToast('Chat stummgeschaltet — du bleibst dabei.');
              },
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                switch (messages) {
                  AsyncValue(:final value?) => ListView(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(BelongSpacing.md,
                          BelongSpacing.md, BelongSpacing.md, BelongSpacing.lg),
                      children: [
                        // Privatsphäre-Hinweis steht immer am Anfang.
                        const SystemNote(
                            text:
                                'Alle sehen nur Spitznamen — so wie du es eingestellt hast'),
                        const SizedBox(height: BelongSpacing.sm),
                        for (final message in value) ...[
                          _MessageEntry(
                            message: message,
                            onLongPressForeign: () => _openSafetySheet(message),
                            onAddressCopied: () => _showToast(
                                'Adresse kopiert — füg sie in deine Karten-App ein.'),
                          ),
                          const SizedBox(height: BelongSpacing.sm),
                        ],
                      ],
                    ),
                  AsyncValue(hasError: true) => const _AccessDeniedView(),
                  _ => const SizedBox.expand(),
                },
                if (_toast != null)
                  Positioned(
                    left: BelongSpacing.lg,
                    right: BelongSpacing.lg,
                    bottom: BelongSpacing.md,
                    child: _Toast(text: _toast!),
                  ),
              ],
            ),
          ),
          _Composer(
            controller: _composerController,
            onSend: _send,
            onShareMeetup: _shareMeetup,
          ),
        ],
      ),
    );
  }
}

class _MessageEntry extends ConsumerWidget {
  const _MessageEntry({
    required this.message,
    required this.onLongPressForeign,
    required this.onAddressCopied,
  });

  final ChatMessage message;
  final VoidCallback onLongPressForeign;
  final VoidCallback onAddressCopied;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (message.type == ChatMessageType.system) {
      return SystemNote(text: message.text, highlight: true);
    }
    // Eigene Nachrichten an der Profil-ID erkennen — funktioniert für
    // beide Backends (Firebase-uid bzw. Mock-Konstante).
    final myId = ref.watch(profileProvider).value?.id;
    final isMine = message.senderId == myId;
    if (message.type == ChatMessageType.meetupPin && message.pin != null) {
      return MeetupPinCard(pin: message.pin!, onAddressCopied: onAddressCopied);
    }
    return ChatBubble(
      message: message,
      isMine: isMine,
      onLongPress: isMine ? null : onLongPressForeign,
    );
  }
}

/// Weißer Chat-Header mit Zurück, Titel/Meta und Schutz-Button.
class _ChatHeader extends StatelessWidget {
  const _ChatHeader({
    required this.title,
    required this.subtitle,
    required this.onSafety,
  });

  final String title;
  final String subtitle;
  final VoidCallback onSafety;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    return Container(
      padding: EdgeInsets.fromLTRB(6, topInset + 6, BelongSpacing.md, 10),
      decoration: const BoxDecoration(
        color: BelongColors.card,
        border:
            Border(bottom: BorderSide(color: BelongColors.hairline)),
      ),
      child: Row(
        children: [
          Pressable(
            onTap: () => Navigator.of(context).pop(),
            semanticLabel: 'Zurück',
            child: const SizedBox(
              width: BelongSpacing.hitTarget,
              height: BelongSpacing.hitTarget,
              child: Center(
                child: BelongIcon(BelongIconGlyph.chevronLeft,
                    size: 20, color: BelongColors.ink, strokeWidth: 2.6),
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: BelongText.rowTitle.copyWith(fontSize: 16)),
                const SizedBox(height: 2),
                Text(subtitle, style: BelongText.meta),
              ],
            ),
          ),
          const SizedBox(width: BelongSpacing.xs),
          // Schutz ist sichtbar, nicht versteckt — psychologische Sicherheit.
          BelongPill(
            label: 'Schutz',
            background: BelongColors.coralTint,
            foreground: BelongColors.coralDeep,
            onTap: onSafety,
            leading: const BelongIcon(BelongIconGlyph.shield,
                size: 15, color: BelongColors.coralDeep, strokeWidth: 2.4),
            textStyle: BelongText.chip.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

/// Composer: Treffpunkt-Button, Eingabe-Pill, Coral-Senden-FAB (44 px).
class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.onSend,
    required this.onShareMeetup,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onShareMeetup;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(BelongSpacing.sm, 10, BelongSpacing.sm,
          10 + bottomInset),
      decoration: const BoxDecoration(
        color: BelongColors.card,
        border: Border(top: BorderSide(color: BelongColors.hairline)),
      ),
      child: Row(
        children: [
          Pressable(
            onTap: onShareMeetup,
            semanticLabel: 'Treffpunkt teilen',
            child: Container(
              width: BelongSpacing.hitTarget,
              height: BelongSpacing.hitTarget,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                  color: BelongColors.header, shape: BoxShape.circle),
              child: const BelongIcon(BelongIconGlyph.pin,
                  size: 19, color: BelongColors.inkSoft),
            ),
          ),
          const SizedBox(width: BelongSpacing.xs),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: BelongColors.surface,
                borderRadius: BelongRadii.pillAll,
                border: Border.all(color: BelongColors.border),
              ),
              child: TextField(
                controller: controller,
                onSubmitted: (_) => onSend(),
                // Die Security Rules erlauben max. 500 Zeichen pro Nachricht.
                inputFormatters: [LengthLimitingTextInputFormatter(500)],
                style: BelongText.input,
                cursorColor: BelongColors.coral,
                decoration: InputDecoration(
                  hintText: 'Schreib was Kurzes …',
                  hintStyle: BelongText.input
                      .copyWith(color: BelongColors.placeholder),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: BelongSpacing.xs),
          Pressable(
            onTap: onSend,
            semanticLabel: 'Senden',
            child: Container(
              width: BelongSpacing.hitTarget,
              height: BelongSpacing.hitTarget,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: BelongColors.coral,
                shape: BoxShape.circle,
                boxShadow: BelongShadows.coralGlow,
              ),
              child: const BelongIcon(BelongIconGlyph.send,
                  size: 18, color: Color(0xFFFFFFFF), strokeWidth: 2.4),
            ),
          ),
        ],
      ),
    );
  }
}

/// Fallback, falls der Chat ohne Teilnahme geöffnet wird.
class _AccessDeniedView extends StatelessWidget {
  const _AccessDeniedView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(BelongSpacing.xl),
        child: Text(
          'Dieser Chat ist nur für Teilnehmer:innen sichtbar.\n'
          'Tritt der Aktivität bei, dann bist du dabei.',
          textAlign: TextAlign.center,
          style: BelongText.body.copyWith(color: BelongColors.muted),
        ),
      ),
    );
  }
}

/// Kurzes, schwebendes Feedback nach Schutz-Aktionen.
class _Toast extends StatelessWidget {
  const _Toast({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: BelongSpacing.md, vertical: 12),
      decoration: BoxDecoration(
        color: BelongColors.ink,
        borderRadius: BelongRadii.inputAll,
        boxShadow: BelongShadows.e3,
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: BelongText.bodySmall.copyWith(
            color: const Color(0xFFFFFFFF), fontWeight: FontWeight.w600),
      ),
    );
  }
}
