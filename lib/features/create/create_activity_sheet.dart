import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format/belong_dates.dart';
import '../../core/theme/belong_colors.dart';
import '../../core/theme/belong_dimens.dart';
import '../../core/theme/belong_typography.dart';
import '../../core/widgets/belong_icons.dart';
import '../../core/widgets/belong_sheet.dart';
import '../../core/widgets/belong_text_field.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/category_chip.dart';
import '../../core/widgets/doodles.dart';
import '../../core/widgets/option_sheet.dart';
import '../../core/widgets/pressable.dart';
import '../../core/widgets/spark.dart';
import '../../core/widgets/state_view.dart';
import '../../data/providers.dart';
import '../../domain/models/activity.dart';
import '../activity_detail/activity_detail_screen.dart';
import '../feed/feed_controller.dart';
import '../participation/participation_controller.dart';

/// Öffnet „Starte was Kleines" als Bottom-Sheet — oder mit [edit] das
/// gleiche Formular vorbefüllt als „Aktivität bearbeiten" (Host-Werkzeug).
Future<void> showCreateActivitySheet(BuildContext context, {Activity? edit}) {
  return showBelongSheet<void>(
    context: context,
    expand: true,
    builder: (context) => CreateActivitySheet(edit: edit),
  );
}

/// Aktivität erstellen: sechs Felder, freundliche Validierung,
/// Erfolgs-Moment mit Funke. Mit [edit] wird dieselbe Maske zum
/// Bearbeiten — Speichern statt Erfolgs-Moment.
class CreateActivitySheet extends ConsumerStatefulWidget {
  const CreateActivitySheet({super.key, this.edit});

  final Activity? edit;

  @override
  ConsumerState<CreateActivitySheet> createState() =>
      _CreateActivitySheetState();
}

class _CreateActivitySheetState extends ConsumerState<CreateActivitySheet> {
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _listController = ScrollController();

  ActivityCategory _category = ActivityCategory.draussen;
  bool _isOnline = false;
  late DateTime _day;
  int _hour = 18;
  int _minute = 30;
  int _capacity = 8;
  bool _noLimit = false;

  bool _showBanner = false;
  String? _titleError;
  String? _locationError;
  bool _submitting = false;
  Activity? _created;

  bool get _isEdit => widget.edit != null;

  @override
  void initState() {
    super.initState();
    final edit = widget.edit;
    if (edit == null) {
      final now = DateTime.now();
      _day = DateTime(now.year, now.month, now.day);
      return;
    }
    _titleController.text = edit.title;
    _locationController.text = edit.locationName ?? '';
    _descriptionController.text = edit.description ?? '';
    _category = edit.category;
    _isOnline = edit.isOnline;
    _day = DateTime(edit.startsAt.year, edit.startsAt.month, edit.startsAt.day);
    _hour = edit.startsAt.hour;
    _minute = edit.startsAt.minute;
    _noLimit = edit.capacity == null;
    _capacity = edit.capacity ?? 8;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _listController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final titleMissing = _titleController.text.trim().isEmpty;
    final locationMissing = !_isOnline && _locationController.text.trim().isEmpty;
    setState(() {
      _titleError =
          titleMissing ? 'Gib deiner Aktivität einen kurzen Titel.' : null;
      _locationError = locationMissing
          ? 'Sag kurz, wo ihr euch trefft — oder stell auf Online um.'
          : null;
      _showBanner = titleMissing || locationMissing;
    });
    if (_showBanner) {
      // Banner und Fehler-Feld ins Bild holen.
      _listController.animateTo(0,
          duration: BelongMotion.medium, curve: BelongMotion.curve);
      return;
    }

    setState(() => _submitting = true);
    final draft = ActivityDraft(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      category: _category,
      locationName: _isOnline ? null : _locationController.text.trim(),
      isOnline: _isOnline,
      startsAt:
          DateTime(_day.year, _day.month, _day.day, _hour, _minute),
      capacity: _noLimit ? null : _capacity,
    );
    final edit = widget.edit;
    if (edit != null) {
      await ref.read(activityRepositoryProvider).updateActivity(edit.id, draft);
      ref.invalidate(feedProvider);
      ref.invalidate(myActivitiesProvider);
      // Kein Erfolgs-Moment — der Detail-Screen zeigt die Änderung live.
      if (mounted) Navigator.of(context).pop();
      return;
    }

    final created =
        await ref.read(activityRepositoryProvider).createActivity(draft);
    ref.invalidate(feedProvider);
    ref.invalidate(myActivitiesProvider);
    if (!mounted) return;
    setState(() {
      _submitting = false;
      _created = created;
    });
  }

  @override
  Widget build(BuildContext context) {
    final created = _created;
    if (created != null) return _SuccessView(activity: created);

    return Column(
      children: [
        _isEdit
            ? const SheetHeader(
                title: 'Aktivität bearbeiten',
                subtitle: 'Alle, die dabei sind, sehen die Änderung im Chat.')
            : const SheetHeader(
                title: 'Starte was Kleines',
                subtitle: 'Ein Kaffee reicht schon.'),
        Expanded(
          child: ListView(
            controller: _listController,
            padding: const EdgeInsets.fromLTRB(BelongSpacing.lg,
                BelongSpacing.md, BelongSpacing.lg, BelongSpacing.xl),
            children: [
              if (_showBanner) ...[
                const _ValidationBanner(),
                const SizedBox(height: BelongSpacing.md),
              ],
              BelongTextField(
                label: 'Titel',
                controller: _titleController,
                placeholder: 'Wie heißt deine Aktivität?',
                // Die Security Rules erlauben max. 80 Zeichen.
                maxLength: 80,
                errorText: _titleError,
                onChanged: (_) {
                  if (_titleError != null) setState(() => _titleError = null);
                },
              ),
              const SizedBox(height: BelongSpacing.md),
              Text('Kategorie', style: BelongText.label),
              const SizedBox(height: BelongSpacing.xs),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final category in ActivityCategory.values)
                    PickerChip(
                      label: category.label,
                      selected: _category == category,
                      onTap: () => setState(() => _category = category),
                    ),
                ],
              ),
              const SizedBox(height: BelongSpacing.md),
              Row(
                children: [
                  Text('Ort', style: BelongText.label),
                  const Spacer(),
                  PickerChip(
                    label: 'Vor Ort',
                    selected: !_isOnline,
                    onTap: () => setState(() => _isOnline = false),
                  ),
                  const SizedBox(width: 6),
                  PickerChip(
                    label: 'Online',
                    selected: _isOnline,
                    onTap: () => setState(() {
                      _isOnline = true;
                      _locationError = null;
                    }),
                  ),
                ],
              ),
              const SizedBox(height: BelongSpacing.xs),
              if (_isOnline)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: BelongSpacing.md, vertical: 14),
                  decoration: BoxDecoration(
                    color: BelongColors.coralWash,
                    borderRadius: BelongRadii.inputAll,
                  ),
                  child: Row(
                    children: [
                      const BelongIcon(BelongIconGlyph.globe,
                          size: 18, color: BelongColors.coralDeep),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Ihr trefft euch online — den Link teilst du im Gruppenchat.',
                          style: BelongText.bodySmall
                              .copyWith(color: BelongColors.coralDeep),
                        ),
                      ),
                    ],
                  ),
                )
              else
                BelongTextField(
                  label: '',
                  controller: _locationController,
                  placeholder: 'Wo trefft ihr euch?',
                  errorText: _locationError,
                  prefix: const BelongIcon(BelongIconGlyph.pin,
                      size: 18, color: BelongColors.coralDeep),
                  onChanged: (_) {
                    if (_locationError != null) {
                      setState(() => _locationError = null);
                    }
                  },
                ),
              const SizedBox(height: BelongSpacing.md),
              // Tag/Uhrzeit-Grid.
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: _PickerField(
                      label: 'Tag',
                      value: BelongDates.dayLong(_day),
                      onTap: _pickDay,
                    ),
                  ),
                  const SizedBox(width: BelongSpacing.sm),
                  Expanded(
                    flex: 2,
                    child: _PickerField(
                      label: 'Uhrzeit',
                      value:
                          '${_hour.toString().padLeft(2, '0')}:${_minute.toString().padLeft(2, '0')}',
                      onTap: _pickTime,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: BelongSpacing.md),
              BelongTextField(
                label: 'Kurzbeschreibung',
                optionalHint: 'optional',
                controller: _descriptionController,
                placeholder: 'Was sollte man wissen?',
                maxLines: 3,
                // Die Security Rules erlauben max. 500 Zeichen.
                maxLength: 500,
              ),
              const SizedBox(height: BelongSpacing.md),
              // CapacityStepper.
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Max. Teilnehmer:innen', style: BelongText.label),
                        const SizedBox(height: BelongSpacing.xs),
                        PickerChip(
                          label: 'ohne Limit',
                          selected: _noLimit,
                          onTap: () => setState(() => _noLimit = !_noLimit),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: BelongSpacing.sm),
                  _CapacityStepper(
                    value: _capacity,
                    enabled: !_noLimit,
                    onChanged: (value) => setState(() => _capacity = value),
                  ),
                ],
              ),
              const SizedBox(height: BelongSpacing.lg),
              PrimaryButton(
                label: _isEdit ? 'Änderungen speichern' : 'Aktivität teilen',
                loading: _submitting,
                onTap: _submit,
              ),
              const SizedBox(height: BelongSpacing.sm),
              Center(
                child: Text(
                  _isEdit
                      ? 'Die Änderung erscheint als kurze Notiz im Gruppenchat.'
                      : 'Sichtbar für alle in Kassel · du bleibst so anonym wie eingestellt',
                  textAlign: TextAlign.center,
                  style: BelongText.bodySmall.copyWith(color: BelongColors.muted),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _pickDay() async {
    final now = DateTime.now();
    final days = [
      for (var i = 0; i < 14; i++)
        DateTime(now.year, now.month, now.day + i),
    ];
    final day = await showOptionSheet<DateTime>(
      context: context,
      title: 'An welchem Tag?',
      options: days,
      labelOf: (day) => BelongDates.dayLong(day),
      selected: _day,
    );
    if (day != null) setState(() => _day = day);
  }

  Future<void> _pickTime() async {
    final times = [
      for (var hour = 7; hour <= 22; hour++)
        for (final minute in const [0, 30]) (hour: hour, minute: minute),
    ];
    final time = await showOptionSheet<({int hour, int minute})>(
      context: context,
      title: 'Um wie viel Uhr?',
      options: times,
      labelOf: (time) =>
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
      selected: (hour: _hour, minute: _minute),
    );
    if (time != null) {
      setState(() {
        _hour = time.hour;
        _minute = time.minute;
      });
    }
  }
}

/// Banner „Fast geschafft — ein Feld fehlt noch." (freundlich, kein Alarm).
class _ValidationBanner extends StatelessWidget {
  const _ValidationBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: BelongSpacing.md, vertical: 14),
      decoration: BoxDecoration(
        color: BelongColors.berryTint,
        borderRadius: BelongRadii.inputAll,
      ),
      child: Row(
        children: [
          Text('!',
              style: BelongText.rowTitle
                  .copyWith(fontSize: 18, color: BelongColors.berryDeep)),
          const SizedBox(width: BelongSpacing.sm),
          Expanded(
            child: Text(
              'Fast geschafft — ein Feld fehlt noch.',
              style: BelongText.rowTitle
                  .copyWith(color: BelongColors.berryDeep, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}

/// Feld, das ein Auswahl-Sheet öffnet (Tag, Uhrzeit).
class _PickerField extends StatelessWidget {
  const _PickerField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: BelongText.label),
        const SizedBox(height: BelongSpacing.xs),
        Pressable(
          onTap: onTap,
          semanticLabel: '$label: $value',
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: BelongSpacing.md, vertical: 14),
            decoration: BoxDecoration(
              color: BelongColors.card,
              borderRadius: BelongRadii.inputAll,
              border: Border.all(color: BelongColors.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: BelongText.input),
                ),
                const BelongIcon(BelongIconGlyph.chevronDown,
                    size: 14, color: BelongColors.muted, strokeWidth: 3),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// ±-Stepper für das Teilnehmerlimit.
class _CapacityStepper extends StatelessWidget {
  const _CapacityStepper({
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final int value;
  final bool enabled;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget round(BelongIconGlyph glyph, VoidCallback? onTap) => Pressable(
          onTap: onTap,
          semanticLabel: glyph == BelongIconGlyph.plus ? 'Mehr' : 'Weniger',
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
                color: BelongColors.header, shape: BoxShape.circle),
            child: BelongIcon(glyph,
                size: 16,
                color: onTap == null
                    ? BelongColors.placeholder
                    : BelongColors.inkSoft,
                strokeWidth: 2.6),
          ),
        );

    return AnimatedOpacity(
      duration: BelongMotion.fast,
      opacity: enabled ? 1 : 0.45,
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: BelongColors.card,
          borderRadius: BelongRadii.pillAll,
          border: Border.all(color: BelongColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            round(BelongIconGlyph.minus,
                enabled && value > 2 ? () => onChanged(value - 1) : null),
            SizedBox(
              width: 44,
              child: Center(
                child: Text('$value',
                    style: BelongText.rowTitle.copyWith(fontSize: 17)),
              ),
            ),
            round(BelongIconGlyph.plus,
                enabled && value < 30 ? () => onChanged(value + 1) : null),
          ],
        ),
      ),
    );
  }
}

/// Erstellen · Erfolg: „Steht!" mit Squiggle und Funke-Blob.
class _SuccessView extends StatelessWidget {
  const _SuccessView({required this.activity});

  final Activity activity;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Hintergrund-Blobs in den Ecken.
        Positioned(
          top: -40,
          left: -50,
          child: _CornerBlob(color: BelongColors.coralTint, size: 170),
        ),
        Positioned(
          bottom: -50,
          right: -40,
          child: _CornerBlob(color: BelongColors.berryTint, size: 190),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: BelongSpacing.xl),
          child: StateView(
            blobColor: BelongColors.sunflower,
            symbol: const Spark(
                size: 46, color: BelongColors.forest, strokeWidth: 2.6, rotation: 16),
            title: 'Steht!',
            titleStyle: BelongText.displaySuccess,
            message: '„${activity.title}" ist jetzt für alle in Kassel '
                'sichtbar. Wir sagen dir, sobald jemand dabei ist.',
            underTitle: const SquiggleUnderline(),
            primaryLabel: 'Zur Aktivität',
            onPrimary: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(ActivityDetailScreen.route(activity.id));
            },
            ghostLabel: 'Zurück zum Feed',
            onGhost: () => Navigator.of(context).pop(),
          ),
        ),
      ],
    );
  }
}

class _CornerBlob extends StatelessWidget {
  const _CornerBlob({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, borderRadius: BelongRadii.blob(size)),
    );
  }
}
