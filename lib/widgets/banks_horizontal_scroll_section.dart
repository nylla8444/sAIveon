import 'package:flutter/material.dart';
import 'bank_card_widget.dart';

/// Horizontal scrolling section for bank/wallet cards
/// Based on Figma node 2069-764 (Frame Horizontal Scroll - Wallets/Banks)
class BanksHorizontalScrollSection extends StatelessWidget {
  final List<BankCardData> banks;

  const BanksHorizontalScrollSection({super.key, required this.banks});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 130,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: banks.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
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
