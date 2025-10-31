import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/statistics_chart_section.dart';
import '../widgets/income_expenses_section.dart';
import '../widgets/income_value_section.dart';
import '../widgets/expenses_value_section.dart';
import '../widgets/last_6_periods_section.dart';
import '../widgets/balance_with_banks_section.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section - Name, Profile Picture, Notification Bell
                _buildHeader(),

                const SizedBox(height: 20),

                // Search Bar
                _buildSearchBar(),

                const SizedBox(height: 30),

                // Statistics Chart Section
                StatisticsChartSection(
                  chartData: {
                    StatsPeriod.daily: [
                      const FlSpot(0, 800),
                      const FlSpot(1, 1200),
                      const FlSpot(2, 1500),
                      const FlSpot(3, 900),
                      const FlSpot(4, 1800),
                      const FlSpot(5, 1300),
                      const FlSpot(6, 2000),
                    ],
                    StatsPeriod.weekly: [
                      const FlSpot(0, 1200),
                      const FlSpot(1, 1500),
                      const FlSpot(2, 1800),
                      const FlSpot(3, 1400),
                    ],
                    StatsPeriod.monthly: [
                      const FlSpot(0, 1500),
                      const FlSpot(1, 1800),
                      const FlSpot(2, 2100),
                      const FlSpot(3, 1700),
                      const FlSpot(4, 2000),
                      const FlSpot(5, 2200),
                    ],
                    StatsPeriod.yearly: [
                      const FlSpot(0, 1000),
                      const FlSpot(1, 1400),
                      const FlSpot(2, 1800),
                      const FlSpot(3, 2100),
                      const FlSpot(4, 2300),
                    ],
                  },
                ),

                const SizedBox(height: 30),

                // Income and Expenses Section
                IncomeExpensesSection(
                  incomePercentage: '+5%',
                  expensesPercentage: '-2%',
                  onIncomeTap: () {
                    // TODO: Navigate to income details
                  },
                  onExpensesTap: () {
                    // TODO: Navigate to expenses details
                  },
                ),

                const SizedBox(height: 30),

                // Income Value Section with Progress Bar
                IncomeValueSection(
                  amount: '\$1,234',
                  progress: 0.56, // 56% progress (160/287 from Figma)
                  onTap: () {
                    // TODO: Navigate to income details
                  },
                ),

                const SizedBox(height: 15),

                // Expenses Value Section with Progress Bar
                ExpensesValueSection(
                  amount: '\$1,743',
                  progress: 0.79, // 79% progress (228/287 from Figma)
                  onTap: () {
                    // TODO: Navigate to expenses details
                  },
                ),

                const SizedBox(height: 30),

                // Last 6 Periods Bar Chart
                Last6PeriodsSection(
                  data: {
                    'Jan': const PeriodBarData(
                      within: 1200,
                      risk: 400,
                      overspending: 800,
                    ),
                    'Feb': const PeriodBarData(
                      within: 1600,
                      risk: 500,
                      overspending: 300,
                    ),
                    'Mar': const PeriodBarData(
                      within: 1400,
                      risk: 400,
                      overspending: 400,
                    ),
                    'Apr': const PeriodBarData(
                      within: 1500,
                      risk: 450,
                      overspending: 350,
                    ),
                    'May': const PeriodBarData(
                      within: 1300,
                      risk: 500,
                      overspending: 300,
                    ),
                    'Jun': const PeriodBarData(
                      within: 1100,
                      risk: 400,
                      overspending: 300,
                    ),
                  },
                ),

                const SizedBox(height: 30),

                // Balance with Banks Section
                BalanceWithBanksSection(
                  totalBalance: '\$888.00',
                  banks: [
                    BankBalanceData(
                      bankName: 'Bank A',
                      amount: '\$120',
                      icon: Icons.account_balance,
                      onTap: () {
                        // TODO: Navigate to Bank A details
                      },
                    ),
                    BankBalanceData(
                      bankName: 'Bank B',
                      amount: '\$440',
                      icon: Icons.account_balance,
                      onTap: () {
                        // TODO: Navigate to Bank B details
                      },
                    ),
                    BankBalanceData(
                      bankName: 'Bank C',
                      amount: '\$154',
                      icon: Icons.account_balance,
                      onTap: () {
                        // TODO: Navigate to Bank C details
                      },
                    ),
                    BankBalanceData(
                      bankName: 'Bank D',
                      amount: '\$174',
                      icon: Icons.account_balance,
                      onTap: () {
                        // TODO: Navigate to Bank D details
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SizedBox(
      height: 28,
      child: Row(
        children: [
          // Profile Picture (Layer 6 - circular avatar)
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFFD6D6D6),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFBA9BFF).withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: const Icon(Icons.person, color: Color(0xFF050505), size: 16),
          ),

          const SizedBox(width: 7),

          // Name - Allyn Ralf Ledesma
          const Expanded(
            child: Text(
              'Allyn Ralf Ledesma',
              style: TextStyle(
                color: Color(0xFFE6E6E6),
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins',
                height: 1.5,
              ),
            ),
          ),

          // Notification Bell with red dot
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 15,
                height: 16,
                alignment: Alignment.center,
                child: const Icon(
                  Icons.notifications_outlined,
                  color: Colors.white,
                  size: 15,
                ),
              ),
              // Red notification dot
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF8282),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      width: double.infinity,
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF191919),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFFFFFF).withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Search icon
          const Icon(Icons.search, color: Color(0xFF949494), size: 16),

          const SizedBox(width: 8),

          // Search placeholder text
          const Text(
            'Super AI Search',
            style: TextStyle(
              color: Color(0xFF949494),
              fontSize: 14,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
