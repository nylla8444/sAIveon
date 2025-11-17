import 'package:flutter/material.dart';
import 'bank_card_widget.dart';

/// Horizontal scrolling section for bank/wallet cards
/// Based on Figma node 2069-764 (Frame Horizontal Scroll - Wallets/Banks)
class BanksHorizontalScrollSection extends StatelessWidget {
  final List<BankCardData> banks;
  final VoidCallback? onAddBank;

  const BanksHorizontalScrollSection({
    super.key,
    required this.banks,
    this.onAddBank,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 130,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: banks.length + 1, // +1 for the add button
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          // Show add bank button at the end
          if (index == banks.length) {
            return _buildAddBankButton(context);
          }

          final bank = banks[index];
          return BankCardWidget(
            bankName: bank.name,
            amount: bank.amount,
            bankIcon: bank.icon,
            onTap: bank.onTap,
            onArrowTap: bank.onArrowTap,
          );
        },
      ),
    );
  }

  Widget _buildAddBankButton(BuildContext context) {
    return GestureDetector(
      onTap:
          onAddBank ??
          () {
            // TODO: Navigate to add bank page
            print('Add bank tapped');
          },
      child: Container(
        width: 130,
        height: 130,
        decoration: BoxDecoration(
          color: const Color(0xFF101010),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF191919), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF191919),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.add, color: Color(0xFFBA9BFF), size: 28),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add Bank',
              style: TextStyle(
                fontFamily: 'Manrope',
                color: Color(0xFFD6D6D6),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Data model for bank card
class BankCardData {
  final String name;
  final String amount;
  final IconData? icon;
  final VoidCallback? onTap;
  final VoidCallback? onArrowTap;

  BankCardData({
    required this.name,
    required this.amount,
    this.icon,
    this.onTap,
    this.onArrowTap,
  });
}
