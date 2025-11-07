import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/custom_back_button.dart';
import 'expense_detail_page.dart';

class ExpensesSeeAllPage extends StatefulWidget {
  const ExpensesSeeAllPage({super.key});

  @override
  State<ExpensesSeeAllPage> createState() => _ExpensesSeeAllPageState();
}

class _ExpensesSeeAllPageState extends State<ExpensesSeeAllPage> {
  String _selectedFilter = 'Daily'; // Daily, Weekly, Monthly, Yearly
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with back button
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 16, 15, 0),
              child: Row(
                children: [
                  CustomBackButton(
                    size: 40,
                    backgroundColor: const Color(0xFF2A2A2A),
                    iconColor: const Color(0xFFFFFFFF),
                  ),
                  const SizedBox(width: 15),
                  const Text(
                    'Expenses',
                    style: TextStyle(
                      color: Color(0xFFFFFFFF),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 19),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF191919),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFFFFFFF).withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(
                    color: Color(0xFF949494),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                    height: 1.5,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Super AI Search',
                    hintStyle: const TextStyle(
                      color: Color(0xFF949494),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
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
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 19),

            // Filter tabs with underline
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildFilterTab('Daily'),
                  _buildFilterTab('Weekly'),
                  _buildFilterTab('Monthly'),
                  _buildFilterTab('Yearly'),
                ],
              ),
            ),

            const SizedBox(height: 33),

            // Expenses donut chart section with legend on the right
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Expenses',
                    style: TextStyle(
                      color: Color(0xFFD6D6D6),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Manrope',
                      height: 1.366,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Chart and Legend side by side
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Donut chart with center total
                      SizedBox(
                        width: 166,
                        height: 166,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Colored donut chart using fl_chart
                            PieChart(
                              PieChartData(
                                sections: [
                                  PieChartSectionData(
                                    color: const Color(0xFFFF8282), // Shopping
                                    value: 35,
                                    title: '',
                                    radius: 40,
                                  ),
                                  PieChartSectionData(
                                    color: const Color(0xFFF982FF), // Food
                                    value: 44,
                                    title: '',
                                    radius: 40,
                                  ),
                                  PieChartSectionData(
                                    color: const Color(0xFF82FFB4), // Groceries
                                    value: 35,
                                    title: '',
                                    radius: 40,
                                  ),
                                  PieChartSectionData(
                                    color: const Color(0xFFA882FF), // Health
                                    value: 44,
                                    title: '',
                                    radius: 40,
                                  ),
                                  PieChartSectionData(
                                    color: const Color(0xFFFFF782), // Transpo
                                    value: 20,
                                    title: '',
                                    radius: 40,
                                  ),
                                ],
                                sectionsSpace: 0,
                                centerSpaceRadius: 63,
                                startDegreeOffset: -90,
                              ),
                            ),
                            // Center text
                            const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '\$994',
                                  style: TextStyle(
                                    color: Color(0xFFE6E6E6),
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    fontFamily: 'Manrope',
                                    height: 1.366,
                                  ),
                                ),
                                Text(
                                  'total',
                                  style: TextStyle(
                                    color: Color(0xFFE6E6E6),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Manrope',
                                    height: 1.366,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 26),
                      // Legend on the right
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 6),
                            _buildLegendItem(
                              'Shopping',
                              const Color(0xFFFF8282),
                            ),
                            const SizedBox(height: 28),
                            _buildLegendItem('Food', const Color(0xFFF982FF)),
                            const SizedBox(height: 28),
                            _buildLegendItem(
                              'Groceries',
                              const Color(0xFF82FFB4),
                            ),
                            const SizedBox(height: 28),
                            _buildLegendItem('Health', const Color(0xFFA882FF)),
                            const SizedBox(height: 28),
                            _buildLegendItem(
                              'Transpo',
                              const Color(0xFFFFF782),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 26),

            // Expenses list
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  children: [
                    _buildExpenseCard(
                      title: 'Shopping',
                      amount: '\$35',
                      percentChange: '15%',
                      isIncrease: true,
                      icon: Icons.shopping_bag,
                    ),
                    const SizedBox(height: 9),
                    _buildExpenseCard(
                      title: 'Food',
                      amount: '\$44',
                      percentChange: '15%',
                      isIncrease: false,
                      icon: Icons.restaurant,
                    ),
                    const SizedBox(height: 9),
                    _buildExpenseCard(
                      title: 'Groceries',
                      amount: '\$35',
                      percentChange: '15%',
                      isIncrease: true,
                      icon: Icons.local_grocery_store,
                    ),
                    const SizedBox(height: 9),
                    _buildExpenseCard(
                      title: 'Health',
                      amount: '\$44',
                      percentChange: '15%',
                      isIncrease: false,
                      icon: Icons.health_and_safety,
                    ),
                    const SizedBox(height: 9),
                    _buildExpenseCard(
                      title: 'Groceries',
                      amount: '\$35',
                      percentChange: '15%',
                      isIncrease: true,
                      icon: Icons.local_grocery_store,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to get category color
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Shopping':
        return const Color(0xFFFF8282);
      case 'Food':
        return const Color(0xFFF982FF);
      case 'Groceries':
        return const Color(0xFF82FFB4);
      case 'Health':
        return const Color(0xFFA882FF);
      case 'Transpo':
      case 'Transport':
        return const Color(0xFFFFF782);
      default:
        return const Color(0xFFD6D6D6);
    }
  }

  Widget _buildFilterTab(String title) {
    final isSelected = _selectedFilter == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = title;
        });
      },
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: isSelected
                  ? const Color(0xFFA47FFA)
                  : const Color(0xFFD6D6D6),
              fontSize: 12,
              fontWeight: FontWeight.w800,
              fontFamily: 'Manrope',
              height: 1.366,
            ),
          ),
          const SizedBox(height: 8),
          if (isSelected)
            Container(width: 63, height: 1, color: const Color(0xFFA47FFA)),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFD6D6D6),
            fontSize: 12,
            fontWeight: FontWeight.w500,
            fontFamily: 'Manrope',
            height: 1.366,
          ),
        ),
      ],
    );
  }

  Widget _buildExpenseCard({
    required String title,
    required String amount,
    required String percentChange,
    required bool isIncrease,
    required IconData icon,
  }) {
    final categoryColor = _getCategoryColor(title);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ExpenseDetailPage(
              category: title,
              amount: amount,
              percentage: percentChange,
              isIncrease: isIncrease,
              icon: icon,
            ),
          ),
        );
      },
      child: Container(
        height: 67,
        decoration: BoxDecoration(
          color: const Color(0xFF191919),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFD6D6D6).withOpacity(0.05),
            width: 2,
          ),
        ),
        child: Stack(
          children: [
            // Icon with category color
            Positioned(
              left: 19,
              top: 17,
              child: Container(
                width: 33,
                height: 33,
                decoration: BoxDecoration(
                  color: categoryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.white, size: 18),
              ),
            ),

            // Title
            Positioned(
              left: 61,
              top: 23,
              child: Text(
                title,
                style: const TextStyle(
                  color: Color(0xFFD6D6D6),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Manrope',
                  height: 1.366,
                ),
              ),
            ),

            // Amount
            Positioned(
              right: 23,
              top: 15,
              child: Text(
                amount,
                style: const TextStyle(
                  color: Color(0xFFD6D6D6),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Manrope',
                  height: 1.366,
                ),
              ),
            ),

            // Percent change
            Positioned(
              right: 23,
              top: 33,
              child: Row(
                children: [
                  Text(
                    percentChange,
                    style: const TextStyle(
                      color: Color(0xFFD6D6D6),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Manrope',
                      height: 1.366,
                    ),
                  ),
                  const SizedBox(width: 3),
                  Icon(
                    isIncrease ? Icons.arrow_upward : Icons.arrow_downward,
                    color: isIncrease
                        ? const Color(0xFFFF8282)
                        : const Color(0xFF8CFF82),
                    size: 10,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
