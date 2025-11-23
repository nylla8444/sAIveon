import 'package:flutter/material.dart';
import 'edit_bank_page.dart';
import '../../../../core/widgets/index.dart';
import '../../../../core/di/service_locator.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';

class BankDetailPage extends StatefulWidget {
  final int? bankId;
  final String bankName;
  final String balance;

  const BankDetailPage({
    super.key,
    this.bankId,
    required this.bankName,
    required this.balance,
  });

  @override
  State<BankDetailPage> createState() => _BankDetailPageState();
}

class _BankDetailPageState extends State<BankDetailPage> {
  int _displayLimit = 10;
  static const int _loadMoreIncrement = 5;

  IconData _iconForType(String type) {
    switch (type) {
      case 'send':
        return Icons.arrow_upward;
      case 'receive':
        return Icons.arrow_downward;
      case 'transfer':
        return Icons.swap_horiz;
      default:
        return Icons.payment;
    }
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '${hour.toString().padLeft(2, '0')}:$minute$ampm';
  }

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

  void _loadMore() {
    setState(() {
      _displayLimit += _loadMoreIncrement;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button
                Row(
                  children: [
                    CustomBackButton(
                      size: 40,
                      backgroundColor: const Color(0xFF2A2A2A),
                      iconColor: const Color(0xFFFFFFFF),
                    ),
                    const SizedBox(width: 15),
                    const Text(
                      'Balance',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Color(0xFFFFFFFF),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Bank name and balance card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF191919),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFD6D6D6).withOpacity(0.05),
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
                          color: const Color(0xFF101010),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.account_balance,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),

                      const SizedBox(width: 11),

                      // Bank name and balance
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.balance,
                              style: const TextStyle(
                                fontFamily: 'Manrope',
                                color: Color(0xFFD6D6D6),
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                height: 1.366,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.bankName,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                color: Color(0xFFADACAC),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Edit icon
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditBankPage(
                                bankId: widget.bankId,
                                bankName: widget.bankName,
                                balance: widget.balance,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: const Icon(
                            Icons.edit_outlined,
                            color: Color(0xFFD6D6D6),
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Transaction history sections - Load from database
                if (widget.bankId != null)
                  StreamBuilder<List<TransactionEntity>>(
                    stream: ServiceProvider.of(
                      context,
                    ).transactionRepository.watchAllTransactions(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(
                              color: Color(0xFFBA9BFF),
                            ),
                          ),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(40),
                          decoration: BoxDecoration(
                            color: const Color(0xFF191919),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFD6D6D6).withOpacity(0.05),
                              width: 2,
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              'No transactions found',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                color: Color(0xFF949494),
                                fontSize: 14,
                              ),
                            ),
                          ),
                        );
                      }

                      // Filter transactions for this bank
                      final bankTransactions = snapshot.data!.where((t) {
                        // Include if this bank is the source OR destination
                        return t.bankId == widget.bankId ||
                            t.toBankId == widget.bankId;
                      }).toList();

                      if (bankTransactions.isEmpty) {
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(40),
                          decoration: BoxDecoration(
                            color: const Color(0xFF191919),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFD6D6D6).withOpacity(0.05),
                              width: 2,
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              'No transactions for this bank',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                color: Color(0xFF949494),
                                fontSize: 14,
                              ),
                            ),
                          ),
                        );
                      }

                      // Sort all transactions by date (newest first)
                      bankTransactions.sort((a, b) => b.date.compareTo(a.date));

                      // Apply pagination limit
                      final totalTransactions = bankTransactions.length;
                      final displayedTransactions = bankTransactions
                          .take(_displayLimit)
                          .toList();
                      final hasMore = totalTransactions > _displayLimit;

                      // Group displayed transactions by date
                      final Map<String, List<TransactionEntity>> groupedByDate =
                          {};
                      for (var transaction in displayedTransactions) {
                        final dateKey = _formatDate(transaction.date);
                        if (!groupedByDate.containsKey(dateKey)) {
                          groupedByDate[dateKey] = [];
                        }
                        groupedByDate[dateKey]!.add(transaction);
                      }

                      // Sort dates in descending order
                      final sortedDates = groupedByDate.keys.toList()
                        ..sort((a, b) {
                          final dateA = groupedByDate[a]!.first.date;
                          final dateB = groupedByDate[b]!.first.date;
                          return dateB.compareTo(dateA);
                        });

                      return Column(
                        children: [
                          ...sortedDates.asMap().entries.map((entry) {
                            final index = entry.key;
                            final dateKey = entry.value;
                            final transactions = groupedByDate[dateKey]!;

                            return Column(
                              children: [
                                _buildTransactionSection(
                                  dateKey,
                                  transactions,
                                  context,
                                ),
                                if (index < sortedDates.length - 1)
                                  const SizedBox(height: 14),
                              ],
                            );
                          }).toList(),

                          // See More button
                          if (hasMore) ...[
                            const SizedBox(height: 14),
                            GestureDetector(
                              onTap: _loadMore,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 18,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF191919),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(
                                      0xFFBA9BFF,
                                    ).withOpacity(0.3),
                                    width: 1.5,
                                  ),
                                ),
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'See More',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          color: Color(0xFFBA9BFF),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '(${totalTransactions - _displayLimit} more)',
                                        style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          color: Color(0xFF949494),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      );
                    },
                  )
                else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: const Color(0xFF191919),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFD6D6D6).withOpacity(0.05),
                        width: 2,
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'Invalid bank ID',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Color(0xFF949494),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionSection(
    String date,
    List<TransactionEntity> transactions,
    BuildContext context,
  ) {
    // Get bank names from service provider for transfers
    final bankRepo = ServiceProvider.of(context).bankRepository;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF191919),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFD6D6D6).withOpacity(0.05),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date header with line
          Row(
            children: [
              Text(
                date,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  color: Color(0xFFC6C6C6),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  height: 1.366,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Container(height: 1, color: const Color(0xFFC6C6C6)),
              ),
            ],
          ),

          const SizedBox(height: 22),

          // Transactions
          StreamBuilder(
            stream: bankRepo.watchAllBanks(),
            builder: (context, bankSnapshot) {
              final banks = bankSnapshot.data ?? [];
              final bankNames = {for (var b in banks) b.id!: b.name};

              return Column(
                children: transactions.asMap().entries.map((entry) {
                  final index = entry.key;
                  final transaction = entry.value;
                  return Column(
                    children: [
                      if (index > 0)
                        Container(
                          height: 0.5,
                          margin: const EdgeInsets.only(bottom: 15),
                          color: const Color(0xFFB5B5B5).withOpacity(0.5),
                        ),
                      _buildTransactionItem(transaction, bankNames),
                      if (index < transactions.length - 1)
                        const SizedBox(height: 15),
                    ],
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(
    TransactionEntity transaction,
    Map<int, String> bankNames,
  ) {
    // Determine if this is positive or negative for this bank
    bool isPositive;
    String description;

    if (transaction.type == 'receive') {
      isPositive = true;
      description = transaction.bankId != null
          ? (bankNames[transaction.bankId!] ?? 'Unknown')
          : 'Income';
    } else if (transaction.type == 'send') {
      isPositive = false;
      description = transaction.name;
    } else if (transaction.type == 'transfer') {
      // For transfers, check if this bank is receiving or sending
      if (transaction.toBankId == widget.bankId) {
        isPositive = true;
        description = 'From ${bankNames[transaction.bankId!] ?? 'Unknown'}';
      } else {
        isPositive = false;
        description = 'To ${bankNames[transaction.toBankId!] ?? 'Unknown'}';
      }
    } else {
      isPositive = false;
      description = transaction.name;
    }

    final currencyService = ServiceProvider.of(context).currencyService;
    final amountStr = currencyService.format(transaction.amount);
    final sign = isPositive ? '+' : '-';

    return Row(
      children: [
        // Icon
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF101010),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _iconForType(transaction.type),
            color: Colors.white,
            size: 20,
          ),
        ),

        const SizedBox(width: 11),

        // Category and description
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (transaction.scheduledPaymentId != null) ...[
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF82FFB4),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Expanded(
                    child: Text(
                      transaction.name,
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        color: Color(0xFFE6E6E6),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        height: 1.366,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                description,
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

        // Time and amount
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '$sign$amountStr',
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
            const SizedBox(height: 3),
            Text(
              _formatTime(transaction.date),
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
