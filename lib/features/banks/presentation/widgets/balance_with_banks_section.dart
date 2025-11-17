import 'package:flutter/material.dart';

class BankBalanceData {
  final String bankName;
  final String amount;
  final IconData icon;
  final VoidCallback? onTap;

  const BankBalanceData({
    required this.bankName,
    required this.amount,
    required this.icon,
    this.onTap,
  });
}

class BalanceWithBanksSection extends StatelessWidget {
  final String totalBalance;
  final List<BankBalanceData> banks;

  const BalanceWithBanksSection({
    super.key,
    required this.totalBalance,
    required this.banks,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Balance header
        const Text(
          'Balance',
          style: TextStyle(
            color: Color(0xFFE6E6E6),
            fontSize: 20,
            fontWeight: FontWeight.w800,
            fontFamily: 'Manrope',
            height: 1.366,
          ),
        ),

        const SizedBox(height: 0),

        // Total balance amount
        Text(
          totalBalance,
          style: const TextStyle(
            color: Color(0xFFBA9BFF),
            fontSize: 24,
            fontWeight: FontWeight.w500,
            fontFamily: 'Manrope',
            height: 1.366,
          ),
        ),

        const SizedBox(height: 15),

        // Bank cards list
        ...banks.map(
          (bank) => Padding(
            padding: const EdgeInsets.only(bottom: 9),
            child: _buildBankCard(bank),
          ),
        ),
      ],
    );
  }

  Widget _buildBankCard(BankBalanceData bank) {
    return GestureDetector(
      onTap: bank.onTap,
      child: Container(
        height: 60,
        padding: const EdgeInsets.fromLTRB(13, 10, 13, 10),
        decoration: BoxDecoration(
          color: const Color(0xFF191919),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFD6D6D6).withValues(alpha: 0.05),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            // Bank icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFE6E6E6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(bank.icon, color: Colors.black, size: 20),
            ),

            const SizedBox(width: 8),

            // Bank name
            Text(
              bank.bankName,
              style: const TextStyle(
                color: Color(0xFFE6E6E6),
                fontSize: 12,
                fontWeight: FontWeight.w500,
                fontFamily: 'Manrope',
                height: 1.366,
              ),
            ),

            const Spacer(),

            // Amount
            Text(
              bank.amount,
              style: const TextStyle(
                color: Color(0xFFE6E6E6),
                fontSize: 12,
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins',
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
