import 'package:flutter/material.dart' show Tooltip, TooltipState, TooltipTriggerMode;
import 'package:flutter/widgets.dart';

/// Hüllt eine gesperrte Aktion (Beitreten/Hosten ohne Verifizierung) ein:
/// zeigt bei Tap kurz „Verifizierung nötig" — kein Dialog, kein Modal.
///
/// Der Aufrufer bleibt für das gedimmte/Lock-Icon-Aussehen des Kindes
/// selbst zuständig; dieses Widget übernimmt nur den Hinweis-Mechanismus
/// (`Tooltip` im manuellen Modus, programmatisch über [show] ausgelöst,
/// damit das Kind seinen eigenen `onTap` behält statt mit der
/// Tooltip-eigenen Gestenerkennung zu kollidieren).
class LockedActionTooltip extends StatefulWidget {
  const LockedActionTooltip({
    super.key,
    required this.child,
    this.message = 'Verifizierung nötig',
  });

  final Widget child;
  final String message;

  @override
  State<LockedActionTooltip> createState() => LockedActionTooltipState();
}

class LockedActionTooltipState extends State<LockedActionTooltip> {
  final _tooltipKey = GlobalKey<TooltipState>();

  void show() => _tooltipKey.currentState?.ensureTooltipVisible();

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      key: _tooltipKey,
      message: widget.message,
      triggerMode: TooltipTriggerMode.manual,
      child: widget.child,
    );
  }
}
