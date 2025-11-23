import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Supported currencies in the app
enum Currency {
  php('PHP', '₱'),
  usd('USD', '\$');

  const Currency(this.code, this.symbol);
  final String code;
  final String symbol;
}

/// Service to manage currency preferences throughout the app
class CurrencyService extends ChangeNotifier {
  static const String _currencyKey = 'selected_currency';
  Currency _currentCurrency = Currency.php; // Default to PHP
  SharedPreferences? _prefs;

  Currency get currentCurrency => _currentCurrency;
  String get currencySymbol => _currentCurrency.symbol;
  String get currencyCode => _currentCurrency.code;

  /// Initialize the service and load saved preference
  Future<void> initialize() async {
    print('💱 [CurrencyService] Initializing...');
    _prefs = await SharedPreferences.getInstance();
    await _loadCurrency();
    print(
      '✅ [CurrencyService] Initialized with currency: ${_currentCurrency.code}',
    );
  }

  /// Load saved currency preference
  Future<void> _loadCurrency() async {
    final savedCode = _prefs?.getString(_currencyKey);
    if (savedCode != null) {
      try {
        _currentCurrency = Currency.values.firstWhere(
          (c) => c.code == savedCode,
          orElse: () => Currency.php,
        );
        print(
          '💱 [CurrencyService] Loaded saved currency: ${_currentCurrency.code}',
        );
      } catch (e) {
        print('❌ [CurrencyService] Error loading currency: $e');
        _currentCurrency = Currency.php;
      }
    }
  }

  /// Change the current currency and save preference
  Future<void> setCurrency(Currency currency) async {
    if (_currentCurrency == currency) return;

    print(
      '💱 [CurrencyService] Changing currency from ${_currentCurrency.code} to ${currency.code}',
    );
    _currentCurrency = currency;
    await _prefs?.setString(_currencyKey, currency.code);
    notifyListeners();
    print('✅ [CurrencyService] Currency changed and saved');
  }

  /// Format amount with current currency
  String format(double amount, {bool showSymbol = true}) {
    final absAmount = amount.abs();
    final formatted = absAmount.toStringAsFixed(2);

    // Add thousand separators
    final parts = formatted.split('.');
    final whole = parts[0];
    final decimal = parts.length > 1 ? parts[1] : '00';

    final buffer = StringBuffer();
    for (int i = 0; i < whole.length; i++) {
      if (i > 0 && (whole.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(whole[i]);
    }

    final result = showSymbol
        ? '${_currentCurrency.symbol}$buffer.$decimal'
        : '$buffer.$decimal';

    return amount < 0 ? '-$result' : result;
  }

  /// Format amount without decimals
  String formatWhole(double amount, {bool showSymbol = true}) {
    final absAmount = amount.abs();
    final whole = absAmount.toStringAsFixed(0);

    // Add thousand separators
    final buffer = StringBuffer();
    for (int i = 0; i < whole.length; i++) {
      if (i > 0 && (whole.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(whole[i]);
    }

    final result = showSymbol
        ? '${_currentCurrency.symbol}$buffer'
        : buffer.toString();

    return amount < 0 ? '-$result' : result;
  }
}
