import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/belong_colors.dart';
import '../../core/theme/belong_dimens.dart';
import '../../core/theme/belong_shadows.dart';
import '../../core/theme/belong_typography.dart';
import '../../core/widgets/app_header.dart';
import '../../core/widgets/belong_icons.dart';
import '../../core/widgets/belong_sheet.dart';
import '../../core/widgets/belong_text_field.dart';
import '../../core/widgets/belong_wordmark.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/category_chip.dart';
import '../../core/widgets/pills.dart';
import '../../core/widgets/pressable.dart';
import '../../data/providers.dart';
import '../../domain/models/anonymity_level.dart';
import '../profile/profile_controller.dart';

/// Onboarding · Stufenwahl — anonymer Einstieg ohne E-Mail.
///
/// Progressive Freischaltung: erst bei „Spitzname"/„+ Interessen" erscheinen
/// weitere Eingaben direkt in der Karte; der Kernfluss bleibt ein Screen
/// mit einem Button.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  AnonymityLevel _level = AnonymityLevel.anonymous;
  final _nicknameController = TextEditingController();
  final Set<String> _interests = {};
  String? _suggestedNickname;
  String? _nicknameError;
  bool _ageConfirmed = false;
  String? _ageError;
  bool _submitting = false;

  static const _interestPool = [
    'Draußen', 'Spiele', 'Kaffee', 'Tanzen', 'Musik', 'Essen', 'Sport', 'Kreatives',
  ];

  @override
  void initState() {
    super.initState();
    // Vorschlag früh laden, damit „Ganz anonym" sofort greifbar wirkt.
    ref.read(authRepositoryProvider).suggestNickname().then((nickname) {
      if (mounted) setState(() => _suggestedNickname = nickname);
    });
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    final nickname = _level == AnonymityLevel.anonymous
        ? (_suggestedNickname ?? 'stiller-fuchs')
        : _nicknameController.text.trim();
    if (_level != AnonymityLevel.anonymous && nickname.isEmpty) {
      setState(() => _nicknameError = 'Such dir einen Spitznamen aus — reicht völlig.');
      return;
    }
    if (!_ageConfirmed) {
      setState(() =>
          _ageError = 'belong ist ab 18 — bitte bestätige kurz dein Alter.');
      return;
    }
    setState(() {
      _nicknameError = null;
      _ageError = null;
      _submitting = true;
    });
    await ref.read(profileProvider.notifier).completeOnboarding(
          level: _level,
          nickname: nickname,
          ageConfirmed: _ageConfirmed,
          interests: _interests.toList(),
        );
    // Kein setState nach Erfolg nötig — der RootGate wechselt zur App-Shell.
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: BelongColors.surface,
      child: Column(
        children: [
          const AppHeader(
            padding: EdgeInsets.fromLTRB(
                BelongSpacing.lg, 18, BelongSpacing.lg, 22),
            child: Column(
              children: [
                Center(child: BelongWordmark(fontSize: 24)),
                SizedBox(height: BelongSpacing.md),
                Text('Schön, dass du da bist.',
                    textAlign: TextAlign.center, style: BelongText.displayTitle),
                SizedBox(height: 6),
                Text(
                  'Kein Profil, kein Druck — du entscheidest,\nwie sichtbar du bist.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: BelongFonts.body,
                    fontSize: 14,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                    color: BelongColors.muted,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(BelongSpacing.screen,
                  BelongSpacing.lg, BelongSpacing.screen, BelongSpacing.lg),
              children: [
                _AnonymityCard(
                  level: AnonymityLevel.anonymous,
                  selected: _level == AnonymityLevel.anonymous,
                  onTap: () => setState(() => _level = AnonymityLevel.anonymous),
                  avatar: const _AvatarBlob(
                    background: BelongColors.cream,
                    child: BelongIcon(BelongIconGlyph.eyeOff,
                        size: 20, color: BelongColors.muted),
                  ),
                  badge: 'GUT ZUM STARTEN',
                  description:
                      'Wir schlagen dir einen Spitznamen vor — z. B. '
                      '„${_suggestedNickname ?? 'stiller-fuchs'}". '
                      'Kein Bild, keine Angaben.',
                ),
                const SizedBox(height: BelongSpacing.sm),
                _AnonymityCard(
                  level: AnonymityLevel.nickname,
                  selected: _level == AnonymityLevel.nickname,
                  onTap: () => setState(() => _level = AnonymityLevel.nickname),
                  avatar: const _AvatarBlob(
                    background: BelongColors.coralTint,
                    child: BelongIcon(BelongIconGlyph.profile,
                        size: 20, color: BelongColors.coralDeep),
                  ),
                  description: 'Du wählst selbst einen Namen — sonst nichts.',
                  expanded: _level == AnonymityLevel.nickname
                      ? _nicknameField()
                      : null,
                ),
                const SizedBox(height: BelongSpacing.sm),
                _AnonymityCard(
                  level: AnonymityLevel.nicknameInterests,
                  selected: _level == AnonymityLevel.nicknameInterests,
                  onTap: () =>
                      setState(() => _level = AnonymityLevel.nicknameInterests),
                  avatar: const _AvatarBlob(
                    background: BelongColors.amberTint,
                    child: BelongIcon(BelongIconGlyph.sparkles,
                        size: 20, color: BelongColors.amberDeep),
                  ),
                  description:
                      'Zeig, worauf du Lust hast — hilft beim Finden. '
                      'Immer noch ohne Foto.',
                  expanded: _level == AnonymityLevel.nicknameInterests
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _nicknameField(),
                            const SizedBox(height: BelongSpacing.sm),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                for (final interest in _interestPool)
                                  PickerChip(
                                    label: interest,
                                    selected: _interests.contains(interest),
                                    onTap: () => setState(() {
                                      _interests.contains(interest)
                                          ? _interests.remove(interest)
                                          : _interests.add(interest);
                                    }),
                                  ),
                              ],
                            ),
                          ],
                        )
                      : null,
                ),
                const SizedBox(height: BelongSpacing.md),
                const _TrustNote(
                    text: 'Ohne E-Mail · jederzeit änderbar · nichts wird bewertet'),
                const SizedBox(height: BelongSpacing.md),
                _AgeGateCheck(
                  confirmed: _ageConfirmed,
                  errorText: _ageError,
                  onTap: () => setState(() {
                    _ageConfirmed = !_ageConfirmed;
                    if (_ageConfirmed) _ageError = null;
                  }),
                ),
                const SizedBox(height: BelongSpacing.md),
                PrimaryButton(
                  label: "Los geht's",
                  loading: _submitting,
                  onTap: _start,
                ),
                const SizedBox(height: BelongSpacing.xs),
                Center(
                  child: GhostButton(
                    label: 'Was passiert mit meinen Daten?',
                    onTap: () => _showDataInfo(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _nicknameField() {
    return BelongTextField(
      label: 'Dein Spitzname',
      controller: _nicknameController,
      placeholder: _suggestedNickname ?? 'z. B. stiller-fuchs',
      // Die Security Rules erlauben max. 30 Zeichen.
      maxLength: 30,
      errorText: _nicknameError,
      onChanged: (_) {
        if (_nicknameError != null) setState(() => _nicknameError = null);
      },
    );
  }

  void _showDataInfo(BuildContext context) {
    showBelongSheet<void>(
      context: context,
      builder: (context) => const _DataInfoSheet(),
    );
  }
}

/// AnonymityLevelCard: weiß, ausgewählt = 2 px Coral-Rahmen.
class _AnonymityCard extends StatelessWidget {
  const _AnonymityCard({
    required this.level,
    required this.selected,
    required this.onTap,
    required this.avatar,
    required this.description,
    this.badge,
    this.expanded,
  });

  final AnonymityLevel level;
  final bool selected;
  final VoidCallback onTap;
  final Widget avatar;
  final String description;
  final String? badge;
  final Widget? expanded;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      pressedScale: 0.985,
      semanticLabel: level.label,
      child: AnimatedContainer(
        duration: BelongMotion.fast,
        curve: BelongMotion.curve,
        padding: const EdgeInsets.all(BelongSpacing.md),
        decoration: BoxDecoration(
          color: BelongColors.card,
          borderRadius: BelongRadii.choiceCardAll,
          border: Border.all(
            color: selected ? BelongColors.coral : BelongColors.border,
            width: selected ? 2 : 1,
          ),
          boxShadow: selected ? BelongShadows.e2 : BelongShadows.e1,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                avatar,
                const SizedBox(width: BelongSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(level.label,
                          style: BelongText.body.copyWith(
                              fontSize: 17, fontWeight: FontWeight.w700)),
                      if (badge != null) ...[
                        const SizedBox(height: 6),
                        BelongPill(
                          label: badge!,
                          background: BelongColors.amberTint,
                          foreground: BelongColors.amberDeep,
                          textStyle: BelongText.badge.copyWith(letterSpacing: 1),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                        ),
                      ],
                      const SizedBox(height: 6),
                      Text(description,
                          style: BelongText.body
                              .copyWith(color: BelongColors.muted)),
                    ],
                  ),
                ),
                const SizedBox(width: BelongSpacing.sm),
                _RadioDot(selected: selected),
              ],
            ),
            if (expanded != null) ...[
              const SizedBox(height: BelongSpacing.md),
              expanded!,
            ],
          ],
        ),
      ),
    );
  }
}

class _RadioDot extends StatelessWidget {
  const _RadioDot({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: BelongMotion.fast,
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? BelongColors.coral : BelongColors.borderIdle,
          width: 2,
        ),
      ),
      alignment: Alignment.center,
      child: selected
          ? Container(
              width: 11,
              height: 11,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: BelongColors.coral),
            )
          : null,
    );
  }
}

/// Runde 44-px-Avatar-Fläche.
class _AvatarBlob extends StatelessWidget {
  const _AvatarBlob({required this.background, required this.child});

  final Color background;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      child: child,
    );
  }
}

/// TrustNote: Koralle-Punkt + entlastender Hinweis.
class _TrustNote extends StatelessWidget {
  const _TrustNote({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 7,
          height: 7,
          margin: const EdgeInsets.only(top: 6, left: 4, right: 10),
          decoration: const BoxDecoration(
              shape: BoxShape.circle, color: BelongColors.coral),
        ),
        Expanded(
          child: Text(text,
              style: BelongText.bodySmall.copyWith(
                  fontWeight: FontWeight.w700, color: BelongColors.inkSoft)),
        ),
      ],
    );
  }
}

/// Altersgrenze 18+ als Selbstbestätigung — bewusst kein Geburtsdatum
/// (Datensparsamkeit): gespeichert wird nur das Ja. Ohne Haken blockiert
/// „Los geht's" mit einem freundlichen Inline-Fehler.
class _AgeGateCheck extends StatelessWidget {
  const _AgeGateCheck({
    required this.confirmed,
    required this.onTap,
    this.errorText,
  });

  final bool confirmed;
  final VoidCallback onTap;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Pressable(
          onTap: onTap,
          pressedScale: 0.985,
          semanticLabel: 'Ich bin mindestens 18 Jahre alt',
          child: AnimatedContainer(
            duration: BelongMotion.fast,
            curve: BelongMotion.curve,
            padding: const EdgeInsets.all(BelongSpacing.md),
            decoration: BoxDecoration(
              color: BelongColors.card,
              borderRadius: BelongRadii.inputAll,
              border: Border.all(
                color: hasError
                    ? BelongColors.error
                    : confirmed
                        ? BelongColors.coral
                        : BelongColors.border,
                width: hasError || confirmed ? 2 : 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedContainer(
                  duration: BelongMotion.fast,
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: confirmed ? BelongColors.coral : BelongColors.card,
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(
                      color: confirmed
                          ? BelongColors.coral
                          : BelongColors.borderIdle,
                      width: 2,
                    ),
                  ),
                  child: confirmed
                      ? const BelongIcon(BelongIconGlyph.check,
                          size: 14, color: BelongColors.card)
                      : null,
                ),
                const SizedBox(width: BelongSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Ich bin mindestens 18 Jahre alt.',
                          style: BelongText.body
                              .copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text(
                        'belong ist nur für Erwachsene. Wir speichern nur '
                        'deine Bestätigung — kein Geburtsdatum.',
                        style: BelongText.bodySmall
                            .copyWith(color: BelongColors.muted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Text(errorText!,
              style: BelongText.chip.copyWith(color: BelongColors.error)),
        ],
      ],
    );
  }
}

/// „Was passiert mit meinen Daten?" — Datensparsamkeit sichtbar gemacht.
class _DataInfoSheet extends StatelessWidget {
  const _DataInfoSheet();

  @override
  Widget build(BuildContext context) {
    const rows = [
      (
        'Kein Klarname, keine E-Mail',
        'Du bist mit einem Spitznamen unterwegs. Mehr fragen wir nicht ab.'
      ),
      (
        'Deine Stufe, deine Wahl',
        'Ganz anonym bis Interessen — du kannst das jederzeit im Profil ändern.'
      ),
      (
        'Chats nur für Teilnehmer:innen',
        'Gruppenchats siehst du erst, wenn du bei einer Aktivität dabei bist.'
      ),
      (
        'Nichts wird bewertet',
        'Keine Likes, keine Follower, kein Ranking — nur echte Verabredungen.'
      ),
      (
        'Ab 18 — ohne Geburtsdatum',
        'belong ist nur für Erwachsene. Wir merken uns nur, dass du das '
            'bestätigt hast — dein Alter fragen wir nie ab.'
      ),
    ];
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: BelongSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SheetHeader(
            title: 'Deine Daten, kurz erklärt',
            subtitle: 'So wenig wie möglich — das ist der ganze Trick.',
          ),
          const SizedBox(height: BelongSpacing.md),
          for (final (title, text) in rows)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  BelongSpacing.lg, 0, BelongSpacing.lg, BelongSpacing.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: BelongIcon(BelongIconGlyph.check,
                        size: 16, color: BelongColors.coralDeep),
                  ),
                  const SizedBox(width: BelongSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: BelongText.body.copyWith(
                                fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text(text,
                            style: BelongText.bodySmall
                                .copyWith(color: BelongColors.muted)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
