import 'package:flutter/services.dart' show TextInputAction;
import 'package:flutter/widgets.dart';

import '../../../core/theme/belong_dimens.dart';
import '../../../core/widgets/belong_sheet.dart';
import '../../../core/widgets/belong_text_field.dart';
import '../../../core/widgets/buttons.dart';
import '../../../domain/models/chat_message.dart';

/// Sheet „Treffpunkt teilen" hinter dem Standort-Button im Composer:
/// Ort, Adresse und Zeit-Label ergeben eine [MeetupPin]-Nachricht.
/// Gibt `null` zurück, wenn das Sheet ohne Teilen geschlossen wird.
Future<MeetupPin?> showMeetupSheet({required BuildContext context}) {
  return showBelongSheet<MeetupPin>(
    context: context,
    builder: (_) => const _MeetupSheet(),
  );
}

class _MeetupSheet extends StatefulWidget {
  const _MeetupSheet();

  @override
  State<_MeetupSheet> createState() => _MeetupSheetState();
}

class _MeetupSheetState extends State<_MeetupSheet> {
  final _placeController = TextEditingController();
  final _addressController = TextEditingController();
  final _timeController = TextEditingController();

  @override
  void dispose() {
    _placeController.dispose();
    _addressController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  bool get _complete =>
      _placeController.text.trim().isNotEmpty &&
      _addressController.text.trim().isNotEmpty &&
      _timeController.text.trim().isNotEmpty;

  void _share() {
    Navigator.of(context).pop(MeetupPin(
      placeName: _placeController.text.trim(),
      address: _addressController.text.trim(),
      timeLabel: _timeController.text.trim(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    // Tastatur schiebt das Sheet nach oben, statt die Felder zu verdecken.
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(BelongSpacing.md, 0, BelongSpacing.md,
          BelongSpacing.lg + keyboardInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SheetHeader(
            title: 'Treffpunkt teilen',
            subtitle: 'Alle im Chat sehen die Karte — so findet ihr '
                'ohne Suchen zusammen.',
          ),
          const SizedBox(height: BelongSpacing.md),
          BelongTextField(
            label: 'Ort',
            controller: _placeController,
            placeholder: 'z. B. Café Nordpol',
            autofocus: true,
            textInputAction: TextInputAction.next,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: BelongSpacing.sm),
          BelongTextField(
            label: 'Adresse',
            controller: _addressController,
            placeholder: 'z. B. Friedrich-Ebert-Str. 12',
            textInputAction: TextInputAction.next,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: BelongSpacing.sm),
          BelongTextField(
            label: 'Zeit',
            controller: _timeController,
            placeholder: 'z. B. Heute · 18:00',
            textInputAction: TextInputAction.done,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: BelongSpacing.md),
          PrimaryButton(
            label: 'Treffpunkt teilen',
            onTap: _complete ? _share : null,
          ),
          GhostButton(
            label: 'Abbrechen',
            onTap: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
