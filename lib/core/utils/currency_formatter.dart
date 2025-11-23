import 'package:flutter/widgets.dart';
import '../di/service_locator.dart';

/// Utility class for formatting currency amounts
class CurrencyFormatter {
  /// Format amount with current currency symbol
  static String format(
    BuildContext context,
    double amount, {
    bool showSymbol = true,
  }) {
    final currencyService = ServiceProvider.of(context).currencyService;
    return currencyService.format(amount, showSymbol: showSymbol);
  }

  /// Format amount without decimals
  static String formatWhole(
    BuildContext context,
    double amount, {
    bool showSymbol = true,
  }) {
    final currencyService = ServiceProvider.of(context).currencyService;
    return currencyService.formatWhole(amount, showSymbol: showSymbol);
  }

  /// Get current currency symbol
  static String getSymbol(BuildContext context) {
    final currencyService = ServiceProvider.of(context).currencyService;
    return currencyService.currencySymbol;
  }

  /// Get current currency code
  static String getCode(BuildContext context) {
    final currencyService = ServiceProvider.of(context).currencyService;
    return currencyService.currencyCode;
  }
}
