import 'package:flutter/material.dart';

class MonthlyBudgetPage extends StatelessWidget {
  const MonthlyBudgetPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text(
                      '< Monthly Budget',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        color: Color(0xFFD6D6D6),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        height: 1.366,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Progress bar section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 19),
              child: Column(
                children: [
                  // Text above progress bar
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Spend: \$3,300 / \$5,000',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Color(0xFF949494),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          height: 1.5,
                        ),
                      ),
                      Text(
                        '66%',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Color(0xFF949494),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Progress bar - light background (43% opacity), dark progress (100% opacity)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Stack(
                      children: [
                        // Light background - A882FF at 43% opacity
                        Container(
                          height: 20,
                          decoration: BoxDecoration(
                            color: const Color(0xFFA882FF).withOpacity(0.43),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        // Dark progress - A882FF at 100% opacity
                        FractionallySizedBox(
                          widthFactor: 0.66, // 66%
                          child: Container(
                            height: 20,
                            decoration: BoxDecoration(
                              color: const Color(0xFFA882FF),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  children: [
                    // Monthly Budget Chart
                    _buildMonthlyBudgetChart(),

                    const SizedBox(height: 14),

                    // Last 6 Periods Chart
                    _buildLast6PeriodsChart(),

                    const SizedBox(height: 14),

                    // Expenses Donut Chart
                    _buildExpensesChart(),

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

  Widget _buildMonthlyBudgetChart() {
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
          const Text(
            'Monthly Budget',
            style: TextStyle(
              fontFamily: 'Manrope',
              color: Color(0xFFD6D6D6),
              fontSize: 12,
              fontWeight: FontWeight.w800,
              height: 1.366,
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
                // Chart area
                Expanded(
                  child: CustomPaint(
                    painter: _MonthlyBudgetChartPainter(),
                    child: Container(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // X-axis labels - perfectly centered under each data point
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Space for Y-axis labels
              const SizedBox(width: 50),
              const SizedBox(width: 9),
              // Labels positioned at data point centers
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
    );
  }

  Widget _buildLast6PeriodsChart() {
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
          const Text(
            'Last 6 periods',
            style: TextStyle(
              fontFamily: 'Manrope',
              color: Color(0xFFD6D6D6),
              fontSize: 12,
              fontWeight: FontWeight.w800,
              height: 1.366,
            ),
          ),
          const SizedBox(height: 12),
          // Chart area
          SizedBox(
            height: 134,
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
                // Chart bars
                Expanded(
                  child: CustomPaint(
                    painter: _Last6PeriodsChartPainter(),
                    child: Container(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // X-axis labels - perfectly centered under each bar
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Space for Y-axis labels
              const SizedBox(width: 50),
              const SizedBox(width: 9),
              // Labels positioned at bar centers
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
                            6,
                          ),
                          _buildCenteredXAxisLabel(
                            'Feb',
                            constraints.maxWidth,
                            1,
                            6,
                          ),
                          _buildCenteredXAxisLabel(
                            'Mar',
                            constraints.maxWidth,
                            2,
                            6,
                          ),
                          _buildCenteredXAxisLabel(
                            'Apr',
                            constraints.maxWidth,
                            3,
                            6,
                          ),
                          _buildCenteredXAxisLabel(
                            'May',
                            constraints.maxWidth,
                            4,
                            6,
                          ),
                          _buildCenteredXAxisLabel(
                            'Jun',
                            constraints.maxWidth,
                            5,
                            6,
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
          const SizedBox(height: 16),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Within', const Color(0xFFA882FF)),
              const SizedBox(width: 16),
              _buildLegendItem('Risk', const Color(0xFFFFE282)),
              const SizedBox(width: 16),
              _buildLegendItem('Overspending', const Color(0xFFFF8282)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpensesChart() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFF101010),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.06), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Expenses',
            style: TextStyle(
              fontFamily: 'Manrope',
              color: Color(0xFFD6D6D6),
              fontSize: 12,
              fontWeight: FontWeight.w800,
              height: 1.366,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // Donut chart
              SizedBox(
                width: 166,
                height: 166,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(166, 166),
                      painter: _DonutChartPainter(),
                    ),
                    const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '\$994',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            color: Color(0xFFE6E6E6),
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            height: 1.366,
                          ),
                        ),
                        Text(
                          'total',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            color: Color(0xFFE6E6E6),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            height: 1.366,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 34),
              // Legend
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildExpenseLegendItem(
                      'Shopping',
                      const Color(0xFFFF8282),
                    ),
                    const SizedBox(height: 12),
                    _buildExpenseLegendItem('Food', const Color(0xFFF982FF)),
                    const SizedBox(height: 12),
                    _buildExpenseLegendItem(
                      'Groceries',
                      const Color(0xFF82FFB4),
                    ),
                    const SizedBox(height: 12),
                    _buildExpenseLegendItem('Health', const Color(0xFFA882FF)),
                    const SizedBox(height: 12),
                    _buildExpenseLegendItem('Transpo', const Color(0xFFFFF782)),
                  ],
                ),
              ),
            ],
          ),
        ],
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
    // Calculate position using spaceEvenly logic
    final spacing = width / (total + 1);
    final centerX = spacing * (index + 1);

    return Positioned(
      left: centerX,
      child: Transform.translate(
        offset: const Offset(
          -15,
          0,
        ), // Shift left by half approximate text width
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

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 15,
          height: 15,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Manrope',
            color: Color(0xFFC6C6C6),
            fontSize: 10,
            fontWeight: FontWeight.w500,
            height: 1.366,
          ),
        ),
      ],
    );
  }

  Widget _buildExpenseLegendItem(String label, Color color) {
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
            fontFamily: 'Manrope',
            color: Color(0xFFD6D6D6),
            fontSize: 12,
            fontWeight: FontWeight.w500,
            height: 1.366,
          ),
        ),
      ],
    );
  }
}

// Custom painter for Monthly Budget chart
class _MonthlyBudgetChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // Budget line data points (values: $1200, $1400, $1600, $1500, $1800, $1900, $2000)
    // Normalized to 0-1 where 1 = $2500
    final budgetData = [
      0.48, // Jan: $1200
      0.56, // Feb: $1400
      0.64, // Mar: $1600
      0.60, // Apr: $1500
      0.72, // May: $1800
      0.76, // Jun: $1900
      0.80, // July: $2000
    ];

    // Spending line data points (values: $900, $1100, $1300, $1200, $1500, $1600, $1700)
    final spendingData = [
      0.36, // Jan: $900
      0.44, // Feb: $1100
      0.52, // Mar: $1300
      0.48, // Apr: $1200
      0.60, // May: $1500
      0.64, // Jun: $1600
      0.68, // July: $1700
    ];

    // Draw purple budget line
    final budgetPaint = Paint()
      ..color = const Color(0xFFBA9BFF)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final budgetPath = Path();
    for (int i = 0; i < budgetData.length; i++) {
      // Use spaceEvenly logic: equal spacing on both sides and between items
      final spacing = width / (budgetData.length + 1);
      final x = spacing * (i + 1);
      final y = height * (1 - budgetData[i]);
      if (i == 0) {
        budgetPath.moveTo(x, y);
      } else {
        budgetPath.lineTo(x, y);
      }
    }
    canvas.drawPath(budgetPath, budgetPaint);

    // Draw red spending line
    final spendingPaint = Paint()
      ..color = const Color(0xFFFF8282)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final spendingPath = Path();
    for (int i = 0; i < spendingData.length; i++) {
      // Use spaceEvenly logic: equal spacing on both sides and between items
      final spacing = width / (spendingData.length + 1);
      final x = spacing * (i + 1);
      final y = height * (1 - spendingData[i]);
      if (i == 0) {
        spendingPath.moveTo(x, y);
      } else {
        spendingPath.lineTo(x, y);
      }
    }
    canvas.drawPath(spendingPath, spendingPaint);

    // Draw circles at data points for purple line
    final circlePaint = Paint()
      ..color = const Color(0xFFBA9BFF)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < budgetData.length; i++) {
      final spacing = width / (budgetData.length + 1);
      final x = spacing * (i + 1);
      final y = height * (1 - budgetData[i]);
      canvas.drawCircle(Offset(x, y), 3, circlePaint);
    }

    // Draw circles at data points for red line
    circlePaint.color = const Color(0xFFFF8282);
    for (int i = 0; i < spendingData.length; i++) {
      final spacing = width / (spendingData.length + 1);
      final x = spacing * (i + 1);
      final y = height * (1 - spendingData[i]);
      canvas.drawCircle(Offset(x, y), 3, circlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom painter for Last 6 Periods chart
class _Last6PeriodsChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    final barWidth = 16.0;

    // Bar data with actual values (max $2500)
    final bars = [
      {
        'height': 0.58,
        'color': const Color(0xFFA882FF),
        'value': '\$1,450',
      }, // Jan - Within ($1450)
      {
        'height': 0.83,
        'color': const Color(0xFFFF8282),
        'value': '\$2,075',
      }, // Feb - Overspending ($2075)
      {
        'height': 0.69,
        'color': const Color(0xFFFFE282),
        'value': '\$1,725',
      }, // Mar - Risk ($1725)
      {
        'height': 0.64,
        'color': const Color(0xFFA882FF),
        'value': '\$1,600',
      }, // Apr - Within ($1600)
      {
        'height': 0.58,
        'color': const Color(0xFFA882FF),
        'value': '\$1,450',
      }, // May - Within ($1450)
      {
        'height': 0.50,
        'color': const Color(0xFFA882FF),
        'value': '\$1,250',
      }, // Jun - Within ($1250)
    ];

    for (int i = 0; i < bars.length; i++) {
      // Position bars to match MainAxisAlignment.spaceEvenly
      // Equal spacing on both sides and between all items
      final spacing = size.width / (bars.length + 1);
      final centerX = spacing * (i + 1);
      final x = centerX - (barWidth / 2);

      final barHeight = size.height * (bars[i]['height'] as double);
      paint.color = bars[i]['color'] as Color;

      final rect = RRect.fromRectAndCorners(
        Rect.fromLTWH(x, size.height - barHeight, barWidth, barHeight),
        topLeft: const Radius.circular(4),
        topRight: const Radius.circular(4),
      );
      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom painter for Donut chart
class _DonutChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 20) / 2;

    // Define segments with realistic expense distribution
    // Total = $994: Shopping $250 (25.2%), Food $220 (22.1%), Groceries $200 (20.1%),
    //                Health $180 (18.1%), Transpo $144 (14.5%)
    final segments = [
      {
        'start': -90.0,
        'sweep': 52.0,
        'color': const Color(0xFFFFF782),
        'value': 144,
        'label': 'Transpo',
      }, // Transpo - yellow ($144, 14.5%)
      {
        'start': -38.0,
        'sweep': 65.0,
        'color': const Color(0xFFA882FF),
        'value': 180,
        'label': 'Health',
      }, // Health - purple ($180, 18.1%)
      {
        'start': 27.0,
        'sweep': 72.0,
        'color': const Color(0xFF82FFB4),
        'value': 200,
        'label': 'Groceries',
      }, // Groceries - green ($200, 20.1%)
      {
        'start': 99.0,
        'sweep': 80.0,
        'color': const Color(0xFFF982FF),
        'value': 220,
        'label': 'Food',
      }, // Food - pink ($220, 22.1%)
      {
        'start': 179.0,
        'sweep': 91.0,
        'color': const Color(0xFFFF8282),
        'value': 250,
        'label': 'Shopping',
      }, // Shopping - red ($250, 25.2%)
    ];

    for (final segment in segments) {
      paint.color = segment['color'] as Color;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        _degreesToRadians(segment['start'] as double),
        _degreesToRadians(segment['sweep'] as double),
        false,
        paint,
      );
    }
  }

  double _degreesToRadians(double degrees) {
    return degrees * 3.141592653589793 / 180;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
