import 'package:flutter/material.dart';

class ExpenseDetailPage extends StatelessWidget {
  final String category;
  final String amount;
  final String percentage;
  final bool isIncrease;
  final IconData icon;

  const ExpenseDetailPage({
    super.key,
    required this.category,
    required this.amount,
    required this.percentage,
    required this.isIncrease,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Text(
                  '< $category Expenses',
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    color: Color(0xFFD6D6D6),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    height: 1.366,
                  ),
                ),
              ),

              const SizedBox(height: 19),

              // Search bar
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF191919),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: TextField(
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    color: Color(0xFFD6D6D6),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Super AI Search',
                    hintStyle: const TextStyle(
                      fontFamily: 'Poppins',
                      color: Color(0xFF949494),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.5,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xFF949494),
                      size: 16,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 19),

              // Spending chart card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(17),
                decoration: BoxDecoration(
                  color: const Color(0xFF101010),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.06),
                    width: 2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          color: Color(0xFFD6D6D6),
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          height: 1.366,
                        ),
                        children: [
                          const TextSpan(text: 'You spent '),
                          TextSpan(text: amount),
                          const TextSpan(text: ' on '),
                          TextSpan(
                            text: category,
                            style: const TextStyle(color: Color(0xFFBA9BFF)),
                          ),
                          const TextSpan(text: ' in six months'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Chart area
                    SizedBox(
                      height: 152,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Y-axis labels
                          SizedBox(
                            width: 50,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                _buildYAxisLabel('\$2,500'),
                                _buildYAxisLabel('\$2,000'),
                                _buildYAxisLabel('\$1,500'),
                                _buildYAxisLabel('\$1,000'),
                                _buildYAxisLabel('\$500'),
                                _buildYAxisLabel('\$0'),
                              ],
                            ),
                          ),
                          const SizedBox(width: 9),
                          // Chart
                          Expanded(
                            child: CustomPaint(
                              painter: _ExpenseChartPainter(),
                              child: Container(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // X-axis labels
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(width: 50),
                        const SizedBox(width: 9),
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return SizedBox(
                                height: 15,
                                child: Stack(
                                  children: [
                                    _buildCenteredXAxisLabel(
                                      'Jan',
                                      constraints.maxWidth,
                                      0,
                                      7,
                                    ),
                                    _buildCenteredXAxisLabel(
                                      'Feb',
                                      constraints.maxWidth,
                                      1,
                                      7,
                                    ),
                                    _buildCenteredXAxisLabel(
                                      'Mar',
                                      constraints.maxWidth,
                                      2,
                                      7,
                                    ),
                                    _buildCenteredXAxisLabel(
                                      'Apr',
                                      constraints.maxWidth,
                                      3,
                                      7,
                                    ),
                                    _buildCenteredXAxisLabel(
                                      'May',
                                      constraints.maxWidth,
                                      4,
                                      7,
                                    ),
                                    _buildCenteredXAxisLabel(
                                      'Jun',
                                      constraints.maxWidth,
                                      5,
                                      7,
                                    ),
                                    _buildCenteredXAxisLabel(
                                      'July',
                                      constraints.maxWidth,
                                      6,
                                      7,
                                      isHighlighted: true,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 19),

              // Transaction history sections
              _buildTransactionSection('11 October 2025', [
                _TransactionData(
                  category: category,
                  description: 'Shop X',
                  time: '06:40PM',
                  amount: '-\$2',
                  icon: icon,
                ),
                _TransactionData(
                  category: category,
                  description: 'Shop X',
                  time: '06:40PM',
                  amount: '-\$2',
                  icon: icon,
                ),
              ]),

              const SizedBox(height: 14),

              _buildTransactionSection('10 October 2025', [
                _TransactionData(
                  category: category,
                  description: 'Shop X',
                  time: '06:40PM',
                  amount: '-\$15',
                  icon: icon,
                ),
                _TransactionData(
                  category: category,
                  description: 'Shop X',
                  time: '06:40PM',
                  amount: '-\$2',
                  icon: icon,
                ),
                _TransactionData(
                  category: category,
                  description: 'Shop X',
                  time: '06:40PM',
                  amount: '-\$17',
                  icon: icon,
                ),
              ]),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildYAxisLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Poppins',
        color: Color(0xFF949494),
        fontSize: 10,
        fontWeight: FontWeight.w500,
        height: 1.5,
      ),
    );
  }

  Widget _buildCenteredXAxisLabel(
    String text,
    double width,
    int index,
    int total, {
    bool isHighlighted = false,
  }) {
    final spacing = width / (total + 1);
    final centerX = spacing * (index + 1);

    return Positioned(
      left: centerX,
      child: Transform.translate(
        offset: const Offset(-15, 0),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Poppins',
            color: isHighlighted
                ? const Color(0xFFBA9BFF)
                : const Color(0xFF949494),
            fontSize: 10,
            fontWeight: FontWeight.w500,
            height: 1.5,
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
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF101010),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.06), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          const SizedBox(height: 16),
          // Transactions
          ...transactions.asMap().entries.map((entry) {
            final index = entry.key;
            final transaction = entry.value;
            return Column(
              children: [
                if (index > 0) ...[
                  Container(
                    height: 1,
                    color: const Color(0xFF4F4F4F),
                    margin: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ],
                _buildTransactionItem(transaction),
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
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: const Color(0xFF101010),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(transaction.icon, color: Colors.white, size: 18),
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
              const SizedBox(height: 2),
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
        // Amount and time
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              transaction.amount,
              style: const TextStyle(
                fontFamily: 'Poppins',
                color: Color(0xFF949494),
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
    );
  }
}

// Custom painter for expense chart
class _ExpenseChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFF8282)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Sample data points (7 months)
    final data = [0.45, 0.38, 0.52, 0.42, 0.58, 0.48, 0.65];

    final path = Path();
    for (int i = 0; i < data.length; i++) {
      final spacing = size.width / (data.length + 1);
      final x = spacing * (i + 1);
      final y = size.height * (1 - data[i]);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Transaction data model
class _TransactionData {
  final String category;
  final String description;
  final String time;
  final String amount;
  final IconData icon;

  _TransactionData({
    required this.category,
    required this.description,
    required this.time,
    required this.amount,
    required this.icon,
  });
}
