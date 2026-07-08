import 'package:flutter/services.dart' show TextInputAction;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/belong_colors.dart';
import '../../../core/theme/belong_dimens.dart';
import '../../../core/theme/belong_typography.dart';
import '../../../core/widgets/belong_icons.dart';
import '../../../core/widgets/belong_sheet.dart';
import '../../../core/widgets/belong_text_field.dart';
import '../../../core/widgets/buttons.dart';
import '../profile_controller.dart';

/// Simulierte Verifizierung — Uni-Prototyp, kein echter SMS-Versand:
/// die Telefonnummer verlässt dieses Sheet nie (Datensparsamkeit bleibt
/// gewahrt), nur das Ergebnis „verifiziert" wird gespeichert. Der Code auf
/// Schritt 2 wird nie geprüft — jede Eingabe schließt ab.
Future<void> showVerifyPhoneSheet(BuildContext context) {
  return showBelongSheet<void>(
    context: context,
    builder: (context) => const _VerifyPhoneSheet(),
  );
}

enum _Step { phone, code, done }

class _VerifyPhoneSheet extends ConsumerStatefulWidget {
  const _VerifyPhoneSheet();

  @override
  ConsumerState<_VerifyPhoneSheet> createState() => _VerifyPhoneSheetState();
}

class _VerifyPhoneSheetState extends ConsumerState<_VerifyPhoneSheet> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  _Step _step = _Step.phone;
  bool _submitting = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _sendCode() {
    if (_phoneController.text.trim().isEmpty) return;
    setState(() => _step = _Step.code);
  }

  Future<void> _confirmCode() async {
    if (_codeController.text.trim().isEmpty) return;
    setState(() => _submitting = true);
    await ref.read(profileProvider.notifier).verifyPhone();
    if (!mounted) return;
    setState(() {
      _submitting = false;
      _step = _Step.done;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: BelongSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          switch (_step) {
            _Step.phone => const SheetHeader(
                title: 'Nummer bestätigen',
                subtitle: 'Demo-Modus: Es wird kein SMS-Code verschickt und '
                    'deine Nummer bleibt auf diesem Gerät.',
              ),
            _Step.code => const SheetHeader(
                title: 'Code eingeben',
                subtitle: 'Trag irgendeinen Code ein — im Demo-Modus zählt '
                    'nur, dass du den Schritt siehst.',
              ),
            _Step.done => const SheetHeader(title: 'Verifiziert'),
          },
          const SizedBox(height: BelongSpacing.md),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: BelongSpacing.md),
            child: switch (_step) {
              _Step.phone => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    BelongTextField(
                      label: 'Telefonnummer',
                      controller: _phoneController,
                      placeholder: '+49 …',
                      textInputAction: TextInputAction.done,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: BelongSpacing.md),
                    PrimaryButton(
                      label: 'Code senden',
                      onTap: _phoneController.text.trim().isEmpty
                          ? null
                          : _sendCode,
                    ),
                  ],
                ),
              _Step.code => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    BelongTextField(
                      label: 'Code',
                      controller: _codeController,
                      placeholder: '000000',
                      textInputAction: TextInputAction.done,
                      autofocus: true,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: BelongSpacing.md),
                    PrimaryButton(
                      label: 'Bestätigen',
                      loading: _submitting,
                      onTap: _codeController.text.trim().isEmpty
                          ? null
                          : _confirmCode,
                    ),
                  ],
                ),
              _Step.done => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const BelongIcon(BelongIconGlyph.verified,
                            size: 20, color: BelongColors.sage),
                        const SizedBox(width: BelongSpacing.sm),
                        Expanded(
                          child: Text(
                            'Du kannst jetzt beitreten, hosten und chatten.',
                            style: BelongText.body
                                .copyWith(color: BelongColors.inkSoft),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: BelongSpacing.md),
                    PrimaryButton(
                      label: 'Fertig',
                      onTap: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
            },
          ),
        ],
      ),
    );
  }
}
