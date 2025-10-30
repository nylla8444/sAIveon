import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'widgets/header_section.dart';
import 'widgets/balance_section.dart';
import 'widgets/achievement_card_section.dart';
import 'widgets/banks_horizontal_scroll_section.dart';
import 'widgets/transaction_history_section.dart';
import 'widgets/monthly_budget_section.dart';
import 'widgets/spending_line_chart_section.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finance App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF050505),
        fontFamily: 'Manrope',
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFFA882FF),
          secondary: const Color(0xFFBA9BFF),
          surface: const Color(0xFF101010),
        ),
      ),
      home: const FinanceHomePage(),
    );
  }
}

class FinanceHomePage extends StatefulWidget {
  const FinanceHomePage({super.key});

  @override
  State<FinanceHomePage> createState() => _FinanceHomePageState();
}

class _FinanceHomePageState extends State<FinanceHomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            Column(
              children: [
                // Top Header Section - Using modular HeaderSection widget
                HeaderSection(
                  userName: 'Allyn Ralf Ledesma',
                  hasNotification: true,
                  onProfileTap: () {
                    // TODO: Navigate to profile page
                  },
                  onNotificationTap: () {
                    // TODO: Navigate to notifications page
                  },
                ),

                // Scrollable Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Balance Section - Using modular BalanceSection widget
                        const SizedBox(height: 15),
                        const BalanceSection(balance: '\$888.00'),

                        // Achievement Card - Using modular AchievementCardSection with donut chart
                        const SizedBox(height: 20),
                        AchievementCardSection(
                          title: 'Well done!',
                          description:
                              'Your spending reduce by 2% from last month.',
                          amount: '\$100',
                          subtitle: 'saved',
                          percentage: 0.66, // 66% saved
                          onViewDetailsTap: () {
                            // TODO: Navigate to achievement details
                          },
                        ),

                        // Banks/Wallets Section - Using modular component
                        const SizedBox(height: 30),
                        BanksHorizontalScrollSection(
                          banks: [
                            BankCardData(
                              name: 'Bank A',
                              amount: '\$120',
                              icon: Icons.account_balance,
                              onTap: () {
                                // TODO: Navigate to Bank A details
                                print('Bank A tapped');
                              },
                              onArrowTap: () {
                                // TODO: Navigate to Bank A details
                                print('Bank A arrow tapped');
                              },
                            ),
                            BankCardData(
                              name: 'Bank B',
                              amount: '\$440',
                              icon: Icons.account_balance,
                              onTap: () {
                                print('Bank B tapped');
                              },
                            ),
                            BankCardData(
                              name: 'Bank C',
                              amount: '\$154',
                              icon: Icons.account_balance,
                              onTap: () {
                                print('Bank C tapped');
                              },
                            ),
                            BankCardData(
                              name: 'Bank D',
                              amount: '\$174',
                              icon: Icons.account_balance,
                              onTap: () {
                                print('Bank D tapped');
                              },
                            ),
                          ],
                        ),

                        // Transaction History - Using modular component
                        const SizedBox(height: 30),
                        TransactionHistorySection(
                          transactions: [
                            TransactionData(
                              title: 'Bank Transfer',
                              subtitle: 'Bank A',
                              amount: '+\$2',
                              time: '06:40PM',
                              icon: Icons.account_balance_wallet,
                              onTap: () {
                                print('Bank Transfer tapped');
                              },
                            ),
                            TransactionData(
                              title: 'Transportation',
                              subtitle: 'Bank A',
                              amount: '-\$2',
                              time: '06:40PM',
                              icon: Icons.directions_car,
                              onTap: () {
                                print('Transportation tapped');
                              },
                            ),
                            TransactionData(
                              title: 'Groceries',
                              subtitle: 'Bank B',
                              amount: '-\$45',
                              time: '04:20PM',
                              icon: Icons.shopping_cart,
                            ),
                            TransactionData(
                              title: 'Salary',
                              subtitle: 'Bank A',
                              amount: '+\$2500',
                              time: '09:00AM',
                              icon: Icons.payments,
                            ),
                          ],
                          onSeeAllTap: () {
                            // TODO: Navigate to full transaction history page
                            print('See All transactions tapped');
                          },
                        ),

                        // Monthly Budget Section - Using modular component
                        const SizedBox(height: 30),
                        MonthlyBudgetSection(
                          spent: 3300,
                          limit: 5000,
                          onSeeAllTap: () {
                            // TODO: Navigate to budget details
                            print('Monthly Budget See All tapped');
                          },
                        ),

                        // Monthly Spending Line Graph - Using modular component
                        const SizedBox(height: 30),
                        SpendingLineChartSection(
                          chartData: {
                            ChartPeriod.daily: [
                              const FlSpot(0, 800),
                              const FlSpot(1, 1000),
                              const FlSpot(2, 1800),
                              const FlSpot(3, 1200),
                              const FlSpot(4, 900),
                              const FlSpot(5, 1600),
                              const FlSpot(6, 1300),
                            ],
                            ChartPeriod.weekly: [
                              const FlSpot(0, 1200),
                              const FlSpot(1, 1500),
                              const FlSpot(2, 2000),
                              const FlSpot(3, 1700),
                              const FlSpot(4, 1400),
                              const FlSpot(5, 1900),
                              const FlSpot(6, 1600),
                            ],
                            ChartPeriod.monthly: [
                              const FlSpot(0, 1500),
                              const FlSpot(1, 1800),
                              const FlSpot(2, 2200),
                              const FlSpot(3, 2000),
                              const FlSpot(4, 1700),
                              const FlSpot(5, 2100),
                              const FlSpot(6, 1900),
                            ],
                          },
                        ), // Expenses Section
                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Expenses',
                              style: TextStyle(
                                color: Color(0xFFD6D6D6),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const Text(
                              'See All',
                              style: TextStyle(
                                color: Color(0xFFC6C6C6),
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        SizedBox(
                          height: 148,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              _buildExpenseCard(
                                'Groceries',
                                '\$44',
                                '15%',
                                true,
                              ),
                              const SizedBox(width: 10),
                              _buildExpenseCard(
                                'Shopping',
                                '\$158',
                                '2%',
                                false,
                              ),
                              const SizedBox(width: 10),
                              _buildExpenseCard('Food', '\$44', '15%', true),
                              const SizedBox(width: 10),
                              _buildExpenseCard('Toys', '\$44', '15%', true),
                            ],
                          ),
                        ),

                        // Scheduled Payments
                        const SizedBox(height: 30),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF101010),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.06),
                              width: 2,
                            ),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Scheduled Payments',
                                    style: TextStyle(
                                      color: Color(0xFFD6D6D6),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const Text(
                                    'See All',
                                    style: TextStyle(
                                      color: Color(0xFFC6C6C6),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15),
                              _buildPaymentItem(
                                'Car Insurance',
                                '-\$65',
                                'Due date in 15 days',
                                '12 Oct',
                              ),
                              const SizedBox(height: 10),
                              _buildPaymentItem(
                                'Internet',
                                '-\$35',
                                'Overdue',
                                '10 Oct',
                                isOverdue: true,
                              ),
                              const SizedBox(height: 10),
                              _buildPaymentItem(
                                'Home Service Fee',
                                '-\$35',
                                'Overdue',
                                '10 Oct',
                                isOverdue: true,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Bottom Navigation - Positioned at bottom (node 2064-610)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 94,
                decoration: const BoxDecoration(color: Colors.transparent),
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    // Background bar (68px height at bottom)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 68,
                        color: const Color(0xFF101010),
                      ),
                    ),
                    // Navigation items
                    Positioned(
                      bottom: 20,
                      child: SizedBox(
                        width: 280,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildNavItem(
                              Icons.account_balance_wallet_outlined,
                              0,
                            ),
                            _buildNavItem(Icons.bar_chart_outlined, 1),
                            const SizedBox(width: 60),
                            _buildNavItem(Icons.auto_awesome_outlined, 3),
                            _buildNavItem(Icons.apps_outlined, 4),
                          ],
                        ),
                      ),
                    ),
                    // Center elevated button
                    Positioned(top: 0, child: _buildCenterButton()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: SizedBox(
        width: 28,
        height: 28,
        child: Icon(
          icon,
          color: isSelected ? const Color(0xFFBA9BFF) : Colors.white,
          size: 28, // Bigger icons
        ),
      ),
    );
  }

  Widget _buildCenterButton() {
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = 2),
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: const Color(0xFFBA9BFF),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFBA9BFF).withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.add_rounded,
          color: Color(
            0xFF050505,
          ), // Match background color for proper contrast
          size: 32,
        ),
      ),
    );
  }

  Widget _buildExpenseCard(
    String category,
    String amount,
    String percentage,
    bool isIncrease,
  ) {
    return Container(
      width: 89,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF191919),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 33,
            height: 33,
            decoration: BoxDecoration(
              color: const Color(0xFFE6E6E6),
              borderRadius: BorderRadius.circular(16.5),
            ),
            child: const Icon(
              Icons.shopping_cart,
              color: Colors.black,
              size: 18,
            ),
          ),
          const Spacer(),
          Text(
            category,
            style: const TextStyle(
              color: Color(0xFFD6D6D6),
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: const TextStyle(color: Color(0xFFB7B7B7), fontSize: 12),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                isIncrease ? Icons.arrow_upward : Icons.arrow_downward,
                color: isIncrease
                    ? const Color(0xFFFF8282)
                    : const Color(0xFF8CFF82),
                size: 10,
              ),
              const SizedBox(width: 4),
              Text(
                percentage,
                style: const TextStyle(
                  color: Color(0xFFD6D6D6),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentItem(
    String title,
    String amount,
    String status,
    String date, {
    bool isOverdue = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.receipt, color: Colors.white, size: 12),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFFD6D6D6),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  status,
                  style: TextStyle(
                    color: isOverdue
                        ? const Color(0xFFFF8282)
                        : const Color(0xFFADACAC),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: const TextStyle(
                  color: Color(0xFFD6D6D6),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                date,
                style: const TextStyle(
                  color: Color(0xFFADACAC),
                  fontSize: 10,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: Color(0xFFD6D6D6), size: 15),
        ],
      ),
    );
  }
}
