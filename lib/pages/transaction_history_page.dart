import 'package:flutter/material.dart';

class TransactionHistoryPage extends StatefulWidget {
  const TransactionHistoryPage({super.key});

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  String _selectedFilter = 'All'; // All, Spending, Income
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // All transactions data
  final List<Map<String, dynamic>> _allTransactions = [
    // 11 October 2025
    {
      'date': '11 October 2025',
      'isSpecial': true,
      'transactions': [
        {
          'category': 'Bank Transfer',
          'description': 'Bank A',
          'time': '06:40PM',
          'amount': '+\$2',
          'type': 'income',
          'icon': Icons.account_balance,
        },
        {
          'category': 'Transportation',
          'description': 'Bank A',
          'time': '06:40PM',
          'amount': '-\$2',
          'type': 'spending',
          'icon': Icons.directions_car,
        },
      ],
    },
    // 10 October 2025
    {
      'date': '10 October 2025',
      'isSpecial': false,
      'transactions': [
        {
          'category': 'Taxi',
          'description': 'Uber',
          'time': '06:40PM',
          'amount': '-\$15',
          'type': 'spending',
          'icon': Icons.local_taxi,
        },
        {
          'category': 'Transfer',
          'description': 'Bank B',
          'time': '06:40PM',
          'amount': '+\$2',
          'type': 'income',
          'icon': Icons.swap_horiz,
        },
        {
          'category': 'Food',
          'description': 'Starbucks',
          'time': '06:40PM',
          'amount': '-\$17',
          'type': 'spending',
          'icon': Icons.restaurant,
        },
      ],
    },
    // 09 October 2025
    {
      'date': '09 October 2025',
      'isSpecial': false,
      'transactions': [
        {
          'category': 'Taxi',
          'description': 'Uber',
          'time': '06:40PM',
          'amount': '-\$15',
          'type': 'spending',
          'icon': Icons.local_taxi,
        },
      ],
    },
    // 08 October 2025
    {
      'date': '08 October 2025',
      'isSpecial': false,
      'transactions': [
        {
          'category': 'Taxi',
          'description': 'Uber',
          'time': '06:40PM',
          'amount': '-\$15',
          'type': 'spending',
          'icon': Icons.local_taxi,
        },
        {
          'category': 'Transfer',
          'description': 'Bank B',
          'time': '06:40PM',
          'amount': '+\$2',
          'type': 'income',
          'icon': Icons.swap_horiz,
        },
        {
          'category': 'Food',
          'description': 'Starbucks',
          'time': '06:40PM',
          'amount': '-\$17',
          'type': 'spending',
          'icon': Icons.restaurant,
        },
      ],
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getFilteredTransactions() {
    // First filter by type (All/Spending/Income)
    List<Map<String, dynamic>> filtered = _allTransactions
        .map((dateGroup) {
          List<dynamic> transactions = List.from(dateGroup['transactions']);

          // Filter by type
          if (_selectedFilter == 'Spending') {
            transactions = transactions
                .where((t) => t['type'] == 'spending')
                .toList();
          } else if (_selectedFilter == 'Income') {
            transactions = transactions
                .where((t) => t['type'] == 'income')
                .toList();
          }

          // Filter by search query
          if (_searchQuery.isNotEmpty) {
            transactions = transactions.where((t) {
              final category = t['category'].toString().toLowerCase();
              final description = t['description'].toString().toLowerCase();
              final query = _searchQuery.toLowerCase();
              return category.contains(query) || description.contains(query);
            }).toList();
          }

          return {
            'date': dateGroup['date'],
            'isSpecial': dateGroup['isSpecial'],
            'transactions': transactions,
          };
        })
        .where((dateGroup) => dateGroup['transactions'].isNotEmpty)
        .toList();

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Row(
                  children: const [
                    Icon(
                      Icons.arrow_back_ios,
                      color: Color(0xFFD6D6D6),
                      size: 12,
                    ),
                    Text(
                      ' Transaction History',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        color: Color(0xFFD6D6D6),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        height: 1.366,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Search bar
              Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  color: const Color(0xFF191919),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.search,
                      color: Color(0xFF949494),
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          color: Color(0xFFD6D6D6),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          height: 1.5,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Super AI Search',
                          hintStyle: TextStyle(
                            fontFamily: 'Poppins',
                            color: Color(0xFF949494),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            height: 1.5,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Filter tabs
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildFilterTab('All', 29),
                  const SizedBox(width: 31),
                  _buildFilterTab('Spending', 74),
                  const SizedBox(width: 31),
                  _buildFilterTab('Income', 59),
                ],
              ),

              const SizedBox(height: 19),

              // Transaction list
              Expanded(child: _buildFilteredTransactionList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterTab(String label, double underlineWidth) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: Column(
        children: [
          Text(
            label,
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
          Container(
            width: underlineWidth,
            height: 1,
            color: isSelected ? const Color(0xFFA47FFA) : Colors.transparent,
          ),
        ],
      ),
    );
  }

  Widget _buildFilteredTransactionList() {
    final filteredTransactions = _getFilteredTransactions();

    if (filteredTransactions.isEmpty) {
      return const Center(
        child: Text(
          'No transactions found',
          style: TextStyle(
            fontFamily: 'Poppins',
            color: Color(0xFF949494),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredTransactions.length,
      itemBuilder: (context, index) {
        final dateGroup = filteredTransactions[index];
        final date = dateGroup['date'] as String;
        final transactions = (dateGroup['transactions'] as List)
            .cast<Map<String, dynamic>>();

        // Convert to _TransactionData objects
        final transactionData = transactions
            .map(
              (t) => _TransactionData(
                category: t['category'] as String,
                description: t['description'] as String,
                time: t['time'] as String,
                amount: t['amount'] as String,
                isPositive: (t['amount'] as String).startsWith('+'),
                icon: t['icon'] as IconData,
              ),
            )
            .toList();

        return Column(
          children: [
            if (index == 0)
              // First item - special rounded card
              _buildSpecialTransactionCard(date, transactionData)
            else
              // Regular transaction section
              _buildTransactionSection(date, transactionData),
            if (index < filteredTransactions.length - 1)
              const SizedBox(height: 14),
          ],
        );
      },
    );
  }

  Widget _buildSpecialTransactionCard(
    String date,
    List<_TransactionData> transactions,
  ) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF101010),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.06), width: 2),
      ),
      child: Column(
        children: [
          // Date header
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
              const SizedBox(width: 7),
              Expanded(
                child: Container(height: 1, color: const Color(0xFFC6C6C6)),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Transactions with dividers
          ...transactions.asMap().entries.map((entry) {
            final index = entry.key;
            final transaction = entry.value;
            return Column(
              children: [
                if (index > 0) ...[
                  const SizedBox(height: 10),
                  Container(height: 1, color: const Color(0xFF4F4F4F)),
                  const SizedBox(height: 10),
                ],
                _buildCompactTransaction(
                  transaction.category,
                  transaction.description,
                  transaction.time,
                  transaction.amount,
                  transaction.isPositive,
                  transaction.icon,
                ),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildCompactTransaction(
    String category,
    String description,
    String time,
    String amount,
    bool isPositive,
    IconData icon,
  ) {
    return Row(
      children: [
        // Icon
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: const Color(0xFF191919),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, color: Colors.white, size: 16),
        ),

        const SizedBox(width: 11),

        // Category and description
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                category,
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

        // Amount and time
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              amount,
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
              time,
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
