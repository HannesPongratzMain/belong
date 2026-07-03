import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/root_gate.dart';
import 'core/theme/belong_theme.dart';

void main() {
  // Der ProviderScope ist der eine Ort, an dem die Mock-Datenschicht später
  // per `overrides` gegen ein echtes Backend getauscht wird (siehe
  // lib/data/providers.dart).
  runApp(const ProviderScope(child: BelongApp()));
}

class BelongApp extends StatelessWidget {
  const BelongApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'belong',
      debugShowCheckedModeBanner: false,
      theme: BelongTheme.light(),
      scrollBehavior: const BelongScrollBehavior(),
      home: const RootGate(),
    );
  }
}
