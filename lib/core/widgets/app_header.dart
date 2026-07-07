import 'package:flutter/widgets.dart';

import '../theme/belong_colors.dart';
import '../theme/belong_dimens.dart';

/// App-Header: ruhige neutrale Fläche mit gerader Unterkante (Hairline).
class AppHeader extends StatelessWidget {
  const AppHeader({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: BelongColors.header,
        border: Border(bottom: BorderSide(color: BelongColors.hairline)),
      ),
      padding: EdgeInsets.only(top: topInset),
      child: Padding(
        padding: padding ??
            const EdgeInsets.fromLTRB(
                BelongSpacing.screen, 14, BelongSpacing.screen, 14),
        child: child,
      ),
    );
  }
}
