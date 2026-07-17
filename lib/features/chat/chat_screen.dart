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
import '../../domain/models/poll.dart';
import '../friends/friends_controller.dart';
import '../participation/participation_controller.dart';
import '../profile/profile_controller.dart';
import 'chat_controller.dart';
import 'widgets/chat_bubbles.dart';
import 'widgets/create_poll_sheet.dart';
import 'widgets/meetup_sheet.dart';
import 'widgets/poll_card.dart';
import 'widgets/safety_sheet.dart';

/// Ein Eintrag der Chat-Timeline — Nachrichten und Umfragen werden nach
/// Erstellzeit gemeinsam einsortiert (Umfragen leben in einem eigenen,
/// von Nachrichten getrennten Pfad, siehe `chat_repository.dart`).
sealed class _TimelineItem {
  DateTime get time;
}

class _MessageTimelineItem extends _TimelineItem {
  _MessageTimelineItem(this.message);
  final ChatMessage message;
  @override
  DateTime get time => message.sentAt;
}

class _PollTimelineItem extends _TimelineItem {
  _PollTimelineItem(this.poll);
  final Poll poll;
  @override
  DateTime get time => poll.createdAt;
}

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
  final Map<String, GlobalKey> _messageKeys = {};
  String? _toast;
  bool _didInitialScroll = false;

  GlobalKey _keyFor(String messageId) =>
      _messageKeys.putIfAbsent(messageId, GlobalKey.new);

  void _scrollToMessage(String messageId) {
    final messageContext = _messageKeys[messageId]?.currentContext;
    if (messageContext == null) return;
    Scrollable.ensureVisible(
      messageContext,
      duration: BelongMotion.medium,
      curve: BelongMotion.curve,
      alignment: 0.5,
    );
  }

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
    final pin = await showMeetupSheet(
      context: context,
      activity: ref.read(activityStreamProvider(widget.activityId)).value,
    );
    if (pin == null) return;
    await ref.read(chatActionsProvider).sendMeetupPin(widget.activityId, pin);
    await _scrollToEnd();
  }

  void _openSafetySheet(ChatMessage message,
      {required bool isMine, required bool isHost}) {
    final pinnedId =
        ref.read(pinnedMessageIdProvider(widget.activityId)).value;
    showSafetySheet(
      context: context,
      message: message,
      isMine: isMine,
      canPin: isHost,
      isPinned: pinnedId == message.id,
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
      onAddFriend: () async {
        await ref
            .read(friendActionControllerProvider.notifier)
            .sendRequest(message.senderId);
        _showToast('Anfrage an ${message.senderNickname} gesendet.');
      },
      onPin: () async {
        await ref
            .read(chatActionsProvider)
            .pinMessage(widget.activityId, message.id);
        _showToast('Nachricht angepinnt.');
      },
      onUnpin: () async {
        await ref.read(chatActionsProvider).unpinMessage(widget.activityId);
        _showToast('Anheftung gelöst.');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final activity = ref.watch(activityStreamProvider(widget.activityId)).value;
    final messages = ref.watch(chatMessagesProvider(widget.activityId));
    final polls = ref.watch(chatPollsProvider(widget.activityId)).value ?? const [];
    final pinnedId = ref.watch(pinnedMessageIdProvider(widget.activityId)).value;
    final myId = ref.watch(profileProvider).value?.id;
    final isHost = activity?.hostId != null && activity!.hostId == myId;

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
                  AsyncValue(:final value?) => Column(
                      children: [
                        if (pinnedId != null)
                          _PinnedBanner(
                            message: _findMessage(value, pinnedId),
                            isHost: isHost,
                            onTap: () => _scrollToMessage(pinnedId),
                            onUnpin: () async {
                              await ref
                                  .read(chatActionsProvider)
                                  .unpinMessage(widget.activityId);
                              _showToast('Anheftung gelöst.');
                            },
                          ),
                        Expanded(
                          child: ListView(
                            controller: _scrollController,
                            padding: const EdgeInsets.fromLTRB(
                                BelongSpacing.md,
                                BelongSpacing.md,
                                BelongSpacing.md,
                                BelongSpacing.lg),
                            children: [
                              // Privatsphäre-Hinweis steht immer am Anfang.
                              const SystemNote(
                                  text:
                                      'Alle sehen nur Spitznamen — so wie du es eingestellt hast'),
                              const SizedBox(height: BelongSpacing.sm),
                              for (final item in _timeline(value, polls)) ...[
                                switch (item) {
                                  _MessageTimelineItem(:final message) =>
                                    KeyedSubtree(
                                      key: _keyFor(message.id),
                                      child: _MessageEntry(
                                        message: message,
                                        isHost: isHost,
                                        onLongPress: (message, {required isMine}) =>
                                            _openSafetySheet(message,
                                                isMine: isMine, isHost: isHost),
                                        onAddressCopied: () => _showToast(
                                            'Adresse kopiert — füg sie in deine Karten-App ein.'),
                                      ),
                                    ),
                                  _PollTimelineItem(:final poll) => PollCard(
                                      activityId: widget.activityId,
                                      poll: poll,
                                    ),
                                },
                                const SizedBox(height: BelongSpacing.sm),
                              ],
                            ],
                          ),
                        ),
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
            onCreatePoll: canCreatePoll(isHost: isHost)
                ? () => showCreatePollSheet(
                    context: context, activityId: widget.activityId)
                : null,
          ),
        ],
      ),
    );
  }

  /// Nachrichten + Umfragen gemeinsam nach Erstellzeit einsortiert.
  List<_TimelineItem> _timeline(List<ChatMessage> messages, List<Poll> polls) {
    return [
      for (final message in messages) _MessageTimelineItem(message),
      for (final poll in polls) _PollTimelineItem(poll),
    ]..sort((a, b) => a.time.compareTo(b.time));
  }

  ChatMessage? _findMessage(List<ChatMessage> messages, String id) {
    for (final message in messages) {
      if (message.id == id) return message;
    }
    return null;
  }
}

class _MessageEntry extends ConsumerWidget {
  const _MessageEntry({
    required this.message,
    required this.isHost,
    required this.onLongPress,
    required this.onAddressCopied,
  });

  final ChatMessage message;

  /// Der Host darf jede Nachricht anpinnen — auch eigene.
  final bool isHost;
  final void Function(ChatMessage message, {required bool isMine}) onLongPress;
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
    // Host darf jede Nachricht anpinnen, alle anderen nur fremde
    // long-pressen (Melden/Blockieren/Stummschalten/Freund-Anfrage).
    final canLongPress = isHost || !isMine;
    return ChatBubble(
      message: message,
      isMine: isMine,
      onLongPress:
          canLongPress ? () => onLongPress(message, isMine: isMine) : null,
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
                    size: 20, color: BelongColors.ink),
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
                if (subtitle.isNotEmpty)
                  Row(
                    children: [
                      const BelongIcon(BelongIconGlyph.users,
                          size: 12, color: BelongColors.muted),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: BelongText.meta),
                      ),
                    ],
                  ),
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
                size: 15, color: BelongColors.coralDeep),
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
    this.onCreatePoll,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onShareMeetup;

  /// `null` = kein Umfrage-Recht (siehe `canCreatePoll` in
  /// `chat_controller.dart`) — Button dann ausgeblendet.
  final VoidCallback? onCreatePoll;

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
          if (onCreatePoll != null) ...[
            const SizedBox(width: 6),
            Pressable(
              onTap: onCreatePoll,
              semanticLabel: 'Umfrage erstellen',
              child: Container(
                width: BelongSpacing.hitTarget,
                height: BelongSpacing.hitTarget,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                    color: BelongColors.header, shape: BoxShape.circle),
                child: const BelongIcon(BelongIconGlyph.poll,
                    size: 18, color: BelongColors.inkSoft),
              ),
            ),
          ],
          const SizedBox(width: BelongSpacing.xs),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: BelongColors.surface,
                borderRadius: BelongRadii.inputAll,
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
              decoration: const BoxDecoration(
                color: BelongColors.coral,
                shape: BoxShape.circle,
              ),
              child: const BelongIcon(BelongIconGlyph.send,
                  size: 18, color: Color(0xFFFFFFFF)),
            ),
          ),
        ],
      ),
    );
  }
}

/// Banner über der Chat-Liste, solange eine Nachricht angepinnt ist.
/// Tippen springt zur Nachricht; „Lösen" ist nur für den Host sichtbar.
class _PinnedBanner extends StatelessWidget {
  const _PinnedBanner({
    required this.message,
    required this.isHost,
    required this.onTap,
    required this.onUnpin,
  });

  /// `null`, solange die gepinnte Nachricht noch nicht geladen ist.
  final ChatMessage? message;
  final bool isHost;
  final VoidCallback onTap;
  final VoidCallback onUnpin;

  @override
  Widget build(BuildContext context) {
    final message = this.message;
    if (message == null) return const SizedBox.shrink();
    return Semantics(
      label: 'Angepinnt: ${message.senderNickname}: ${message.text}. '
          'Tippen, um zur Nachricht zu springen.',
      button: true,
      excludeSemantics: true,
      child: Pressable(
        onTap: onTap,
        semanticButton: false,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
              horizontal: BelongSpacing.md, vertical: 10),
          decoration: const BoxDecoration(
            color: BelongColors.amberTint,
            border: Border(bottom: BorderSide(color: BelongColors.hairline)),
          ),
          child: Row(
            children: [
              const BelongIcon(BelongIconGlyph.pinned,
                  size: 16, color: BelongColors.amberDeep),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Angepinnt',
                        style: BelongText.caption.copyWith(
                            color: BelongColors.amberDeep,
                            fontWeight: FontWeight.w700)),
                    Text(message.text,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: BelongText.bodySmall
                            .copyWith(color: BelongColors.inkSoft)),
                  ],
                ),
              ),
              if (isHost) ...[
                const SizedBox(width: 8),
                Pressable(
                  onTap: onUnpin,
                  semanticLabel: 'Anheftung lösen',
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: BelongSpacing.xs),
                    child: Text('Lösen',
                        style: BelongText.chip.copyWith(
                            color: BelongColors.amberDeep,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ],
          ),
        ),
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
