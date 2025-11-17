import 'package:flutter/material.dart';

// Centralized routing. We'll gradually migrate screens to named routes.
class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    // Temporary: fall back to an empty page if not handled.
    return MaterialPageRoute(
      builder: (_) => const SizedBox.shrink(),
      settings: settings,
    );
  }
}
