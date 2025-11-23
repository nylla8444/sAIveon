import 'package:flutter/widgets.dart';
import '../di/service_locator.dart';
import '../services/currency_service.dart';

/// Mixin to provide easy currency formatting in widgets
mixin CurrencyFormatterMixin<T extends StatefulWidget> on State<T> {
  /// Get currency service from context
  CurrencyService get currencyService =>
      ServiceProvider.of(context).currencyService;

  /// Format amount with currency symbol (e.g., ₱1,234.56 or $1,234.56)
  String formatCurrency(double amount) {
    return currencyService.format(amount);
  }

  /// Format amount without decimals (e.g., ₱1,235 or $1,235)
  String formatCurrencyWhole(double amount) {
    return currencyService.formatWhole(amount);
  }

  /// Get current currency symbol (₱ or $)
  String get currencySymbol => currencyService.currencySymbol;

  /// Get current currency code (PHP or USD)
  String get currencyCode => currencyService.currencyCode;
}
