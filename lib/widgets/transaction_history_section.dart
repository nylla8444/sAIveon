import 'package:flutter/material.dart';

/// Transaction History section with tabs and transaction list
/// Based on Figma node 2069-819 (Transaction History Daily)
class TransactionHistorySection extends StatefulWidget {
  final List<TransactionData> transactions;
  final VoidCallback? onSeeAllTap;

  const TransactionHistorySection({
    super.key,
    required this.transactions,
    this.onSeeAllTap,
  });

  @override
  State<TransactionHistorySection> createState() =>
      _TransactionHistorySectionState();
}

class _TransactionHistorySectionState extends State<TransactionHistorySection> {
  String _selectedTab = 'All';

  @override
  Widget build(BuildContext context) {
    // Filter transactions based on selected tab
    final filteredTransactions = widget.transactions.where((transaction) {
      if (_selectedTab == 'All') return true;
      if (_selectedTab == 'Spending') return transaction.amount.startsWith('-');
      if (_selectedTab == 'Income') return transaction.amount.startsWith('+');
      return true;
    }).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF101010),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.06), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: "Transaction History" and "See All"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // "Transaction History" (Manrope 700, 12px, #D6D6D6)
              const Text(
                'Transaction History',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  color: Color(0xFFD6D6D6),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  height: 1.366,
                ),
              ),
              // "See All" (Manrope 500, 10px, #C6C6C6) - Clickable
              GestureDetector(
                onTap: widget.onSeeAllTap,
                child: const Text(
                  'See All',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    color: Color(0xFFC6C6C6),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    height: 1.366,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          // Tabs: All, Spending, Income - All clickable
          Row(
            children: [
              _buildTab('All'),
              const SizedBox(width: 55), // Space between tabs
              _buildTab('Spending'),
              const SizedBox(width: 70),
              _buildTab('Income'),
            ],
          ),
          const SizedBox(height: 10),
          // Date label (Manrope 700, 11px, #C6C6C6)
          const Text(
            '10 October 2025',
            style: TextStyle(
              fontFamily: 'Manrope',
              color: Color(0xFFC6C6C6),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              height: 1.366,
            ),
          ),
          const SizedBox(height: 8),
          // Divider line
          Container(height: 1, color: const Color(0xFFC6C6C6)),
          const SizedBox(height: 15),
          // Transaction items
          ...filteredTransactions.asMap().entries.map((entry) {
            final index = entry.key;
            final transaction = entry.value;
            return Column(
              children: [
                _buildTransactionItem(transaction),
                if (index < filteredTransactions.length - 1) ...[
                  const SizedBox(height: 10),
                  Container(height: 1, color: const Color(0xFF4F4F4F)),
                  const SizedBox(height: 15),
                ],
              ],
            );
          }),
        ],
      ),
    );
  }

  /// Build clickable tab with underline for selected state
  Widget _buildTab(String text) {
    final isSelected = _selectedTab == text;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = text;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tab text (Manrope 800, 12px)
          Text(
            text,
            style: TextStyle(
              fontFamily: 'Manrope',
              color: isSelected
                  ? const Color(0xFFA47FFA)
                  : const Color(0xFFD6D6D6),
              fontSize: 12,
              fontWeight: FontWeight.w800,
              height: 1.366,
            ),
          ),
          const SizedBox(height: 3),
          // Underline for selected tab
          if (isSelected)
            Container(
              height: 1,
              width: text.length * 7.0, // Approximate width
              color: const Color(0xFFA47FFA),
            ),
        ],
      ),
    );
  }

  /// Build individual transaction item
  Widget _buildTransactionItem(TransactionData transaction) {
    final isPositive = transaction.amount.startsWith('+');
    return Row(
      children: [
        // Icon (30x30)
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(
            transaction.icon ?? Icons.account_balance_wallet,
            color: Colors.white,
            size: 16,
          ),
        ),
        const SizedBox(width: 11),
        // Transaction details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title (Manrope 500, 12px, #E6E6E6)
              Text(
                transaction.title,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  color: Color(0xFFE6E6E6),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  height: 1.366,
                ),
              ),
              const SizedBox(height: 2),
              // Subtitle (Poppins 500, 12px, #949494)
              Text(
                transaction.subtitle,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  color: Color(0xFF949494),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        // Amount and time
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Amount (Poppins 500, 12px)
            Text(
              transaction.amount,
              style: TextStyle(
                fontFamily: 'Poppins',
                color: isPositive
                    ? const Color(0xFFA47FFA)
                    : const Color(0xFF949494),
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 2),
            // Time (Poppins 500, 10px, #9E9E9E)
            Text(
              transaction.time,
              style: const TextStyle(
                fontFamily: 'Poppins',
                color: Color(0xFF9E9E9E),
                fontSize: 10,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Data model for transaction item
class TransactionData {
  final String title;
  final String subtitle;
  final String amount;
  final String time;
  final IconData? icon;
  final VoidCallback? onTap;

  TransactionData({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.time,
    this.icon,
    this.onTap,
  });
}
