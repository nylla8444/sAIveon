import 'package:flutter/material.dart';
import 'edit_bank_page.dart';
import '../../../../core/widgets/index.dart';

class BankDetailPage extends StatelessWidget {
  final String bankName;
  final String balance;

  const BankDetailPage({
    super.key,
    required this.bankName,
    required this.balance,
  });

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
                              balance,
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
                              bankName,
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
                                bankName: bankName,
                                balance: balance,
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

                // Transaction history sections
                _buildTransactionSection('10 October 2025', [
                  _TransactionData(
                    category: 'Taxi',
                    description: 'Uber',
                    time: '06:40PM',
                    amount: '-\$15',
                    isPositive: false,
                    icon: Icons.local_taxi,
                  ),
                  _TransactionData(
                    category: 'Transfer',
                    description: 'Bank B',
                    time: '06:40PM',
                    amount: '+\$2',
                    isPositive: true,
                    icon: Icons.swap_horiz,
                  ),
                  _TransactionData(
                    category: 'Food',
                    description: 'Starbucks',
                    time: '06:40PM',
                    amount: '-\$17',
                    isPositive: false,
                    icon: Icons.restaurant,
                  ),
                ]),

                const SizedBox(height: 14),

                _buildTransactionSection('09 October 2025', [
                  _TransactionData(
                    category: 'Taxi',
                    description: 'Uber',
                    time: '06:40PM',
                    amount: '-\$15',
                    isPositive: false,
                    icon: Icons.local_taxi,
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionSection(
    String date,
    List<_TransactionData> transactions,
  ) {
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
          ...transactions.asMap().entries.map((entry) {
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
                _buildTransactionItem(transaction),
                if (index < transactions.length - 1) const SizedBox(height: 15),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(_TransactionData transaction) {
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
          child: Icon(transaction.icon, color: Colors.white, size: 20),
        ),

        const SizedBox(width: 11),

        // Category and description
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                transaction.category,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  color: Color(0xFFE6E6E6),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  height: 1.366,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                transaction.description,
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
              transaction.amount,
              style: TextStyle(
                fontFamily: 'Poppins',
                color: transaction.isPositive
                    ? const Color(0xFFA47FFA)
                    : const Color(0xFF949494),
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 3),
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

class _TransactionData {
  final String category;
  final String description;
  final String time;
  final String amount;
  final bool isPositive;
  final IconData icon;

  _TransactionData({
    required this.category,
    required this.description,
    required this.time,
    required this.amount,
    required this.isPositive,
    required this.icon,
  });
}
