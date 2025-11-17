import 'package:flutter/material.dart';
import '../core/theme/theme.dart';

/// Central application widget. For now it mirrors the existing MyApp
/// configuration in main.dart. We'll gradually move routing and theming
/// here to avoid churn.
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finance App',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      // Placeholder home; main.dart still owns the primary shell for now.
      home: const SizedBox.shrink(),
    );
  }
}
