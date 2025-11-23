import 'package:flutter/material.dart';
import '../../../../core/widgets/index.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/services/currency_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 16, 15, 0),
              child: Row(
                children: [
                  const CustomBackButton(),
                  const SizedBox(width: 12),
                  const Text(
                    'Settings',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Settings Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Currency Section
                    const Text(
                      'Currency',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Select your preferred currency for displaying amounts throughout the app.',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 13,
                        color: Color(0xFF949494),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Currency Options
                    Builder(
                      builder: (context) {
                        final currencyService = ServiceProvider.of(
                          context,
                        ).currencyService;

                        return ListenableBuilder(
                          listenable: currencyService,
                          builder: (context, _) {
                            return Column(
                              children: [
                                // PHP Option
                                _CurrencyOption(
                                  currency: Currency.php,
                                  isSelected:
                                      currencyService.currentCurrency ==
                                      Currency.php,
                                  onTap: () async {
                                    await currencyService.setCurrency(
                                      Currency.php,
                                    );
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Currency changed to Philippine Peso (₱)',
                                          ),
                                          backgroundColor: Color(0xFF4CAF50),
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                    }
                                  },
                                ),
                                const SizedBox(height: 12),

                                // USD Option
                                _CurrencyOption(
                                  currency: Currency.usd,
                                  isSelected:
                                      currencyService.currentCurrency ==
                                      Currency.usd,
                                  onTap: () async {
                                    await currencyService.setCurrency(
                                      Currency.usd,
                                    );
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Currency changed to US Dollar (\$)',
                                          ),
                                          backgroundColor: Color(0xFF4CAF50),
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 30),

                    // Account Settings Section (Placeholder)
                    const Text(
                      'Account & Notifications',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF101010),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: const Text(
                        'Additional account and notification settings coming soon...',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 13,
                          color: Color(0xFF949494),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Currency option card widget
class _CurrencyOption extends StatelessWidget {
  final Currency currency;
  final bool isSelected;
  final VoidCallback onTap;

  const _CurrencyOption({
    required this.currency,
    required this.isSelected,
    required this.onTap,
  });

  String get _currencyName {
    switch (currency) {
      case Currency.php:
        return 'Philippine Peso';
      case Currency.usd:
        return 'US Dollar';
    }
  }

  String get _currencyDescription {
    switch (currency) {
      case Currency.php:
        return 'PHP (₱)';
      case Currency.usd:
        return 'USD (\$)';
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF6A4AAD).withOpacity(0.2)
              : const Color(0xFF101010),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFBA9BFF)
                : Colors.white.withOpacity(0.1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Currency Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFBA9BFF).withOpacity(0.2)
                    : const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  currency.symbol,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? const Color(0xFFBA9BFF)
                        : const Color(0xFF949494),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Currency Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _currencyName,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _currencyDescription,
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 13,
                      color: Color(0xFF949494),
                    ),
                  ),
                ],
              ),
            ),

            // Selection Indicator
            if (isSelected)
              const Icon(Icons.check_circle, color: Color(0xFFBA9BFF), size: 24)
            else
              Icon(
                Icons.radio_button_unchecked,
                color: Colors.white.withOpacity(0.3),
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
