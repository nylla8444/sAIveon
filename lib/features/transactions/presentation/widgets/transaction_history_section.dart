import 'package:flutter/material.dart';
import '../../../../core/di/service_locator.dart';

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

  String _formatDate(DateTime dt) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${dt.day.toString().padLeft(2, '0')} ${months[dt.month - 1]} ${dt.year}';
  }

  Widget build(BuildContext context) {
    // Sort all transactions by date descending first
    final sorted = List<TransactionData>.from(widget.transactions)
      ..sort((a, b) => b.date.compareTo(a.date));

    // Filter based on selected tab using type rather than amount sign
    List<TransactionData> filtered = sorted.where((tx) {
      switch (_selectedTab) {
        case 'Income':
          return tx.type == 'receive';
        case 'Spending':
          return tx.type == 'send';
        case 'Transfer':
          return tx.type == 'transfer';
        default:
          return true;
      }
    }).toList();

    // Limit to max 5 items for preview
    if (filtered.length > 5) {
      filtered = filtered.sublist(0, 5);
    }

    // Group transactions by date
    final Map<String, List<TransactionData>> groupedByDate = {};
    for (var transaction in filtered) {
      final dateKey = _formatDate(transaction.date);
      groupedByDate.putIfAbsent(dateKey, () => []).add(transaction);
    }

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
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
          Row(
            children: [
              _buildTab('All'),
              const SizedBox(width: 55),
              _buildTab('Income'),
              const SizedBox(width: 55),
              _buildTab('Spending'),
              const SizedBox(width: 55),
              _buildTab('Transfer'),
            ],
          ),
          const SizedBox(height: 10),
          ...groupedByDate.entries.expand((entry) {
            final dateHeader = entry.key;
            final transactions = entry.value;
            final isFirstGroup = groupedByDate.keys.first == dateHeader;

            return [
              if (!isFirstGroup) const SizedBox(height: 15),
              Text(
                dateHeader,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  color: Color(0xFFC6C6C6),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  height: 1.366,
                ),
              ),
              const SizedBox(height: 8),
              Container(height: 1, color: const Color(0xFFC6C6C6)),
              const SizedBox(height: 15),
              ...transactions.asMap().entries.map((txEntry) {
                final index = txEntry.key;
                final transaction = txEntry.value;
                return Column(
                  children: [
                    _buildTransactionItem(transaction),
                    if (index < transactions.length - 1) ...[
                      const SizedBox(height: 10),
                      Container(height: 1, color: const Color(0xFF4F4F4F)),
                      const SizedBox(height: 15),
                    ],
                  ],
                );
              }),
            ];
          }),
        ],
      ),
    );
  }

  Widget _buildTab(String text) {
    final isSelected = _selectedTab == text;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = text),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
          if (isSelected)
            Container(
              height: 1,
              width: text.length * 7.0,
              color: const Color(0xFFA47FFA),
            ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(TransactionData transaction) {
    final isPositive = transaction.amount.startsWith('+');
    return GestureDetector(
      onLongPress: () => _showActions(transaction),
      child: Row(
        children: [
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
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
      ),
    );
  }

  void _showActions(TransactionData tx) {
    final locator = ServiceProvider.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF101010),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: Color(0xFFD6D6D6)),
              title: const Text(
                'Update Transaction',
                style: TextStyle(color: Color(0xFFD6D6D6)),
              ),
              onTap: () async {
                Navigator.pop(context);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Edit coming soon')),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.redAccent),
              title: const Text(
                'Delete Transaction',
                style: TextStyle(color: Colors.redAccent),
              ),
              onTap: () async {
                Navigator.pop(context);
                try {
                  await locator.transactionRepository.deleteTransaction(tx.id);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Transaction deleted')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Delete failed: $e')),
                    );
                  }
                }
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class TransactionData {
  final int id;
  final String title;
  final String subtitle;
  final String amount;
  final String time;
  final DateTime date;
  final String type;
  final double rawAmount;
  final int? bankId;
  final IconData? icon;
  final VoidCallback? onTap;

  TransactionData({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.time,
    required this.date,
    required this.type,
    required this.rawAmount,
    required this.bankId,
    this.icon,
    this.onTap,
  });
}
