import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'widgets/header_section.dart';
import 'widgets/balance_section.dart';
import 'widgets/achievement_card_section.dart';
import 'widgets/banks_horizontal_scroll_section.dart';
import 'widgets/transaction_history_section.dart';
import 'widgets/monthly_budget_section.dart';
import 'widgets/spending_line_chart_section.dart';
import 'widgets/expenses_horizontal_scroll_section.dart';
import 'widgets/scheduled_payments_section.dart';
import 'pages/statistics_page.dart';
import 'pages/ai_page.dart';
import 'pages/more_page.dart';
import 'pages/add_transaction_page.dart';

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

  Widget _getCurrentPage() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomePage();
      case 1:
        return const StatisticsPage();
      case 2:
        return const AIPage();
      case 3:
        return const MorePage();
      default:
        return _buildHomePage();
    }
  }

  Widget _buildHomePage() {
    return Column(
      children: [
        // Scrollable Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Section - Using modular HeaderSection widget
                const SizedBox(height: 20),
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

                // Balance Section - Using modular BalanceSection widget
                const SizedBox(height: 20),
                const BalanceSection(balance: '\$888.00'),

                // Achievement Card - Using modular AchievementCardSection with donut chart
                const SizedBox(height: 20),
                AchievementCardSection(
                  title: 'Well done!',
                  description: 'Your spending reduce by 2% from last month.',
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
                ),

                // Expenses Section - Using modular component
                const SizedBox(height: 30),
                ExpensesHorizontalScrollSection(
                  expenses: [
                    ExpenseData(
                      category: 'Groceries',
                      amount: '\$44',
                      percentage: '15%',
                      isIncrease: true,
                      icon: Icons.shopping_cart,
                      onTap: () {
                        print('Groceries expense tapped');
                      },
                    ),
                    ExpenseData(
                      category: 'Shopping',
                      amount: '\$158',
                      percentage: '2%',
                      isIncrease: false,
                      icon: Icons.shopping_bag,
                      onTap: () {
                        print('Shopping expense tapped');
                      },
                    ),
                    ExpenseData(
                      category: 'Food',
                      amount: '\$44',
                      percentage: '15%',
                      isIncrease: true,
                      icon: Icons.restaurant,
                    ),
                    ExpenseData(
                      category: 'Toys',
                      amount: '\$44',
                      percentage: '15%',
                      isIncrease: true,
                      icon: Icons.toys,
                    ),
                    ExpenseData(
                      category: 'Transport',
                      amount: '\$120',
                      percentage: '8%',
                      isIncrease: true,
                      icon: Icons.directions_car,
                      onTap: () {
                        print('Transport expense tapped');
                      },
                    ),
                  ],
                  onSeeAllTap: () {
                    // TODO: Navigate to all expenses page
                    print('Expenses See All tapped');
                  },
                ),

                // Scheduled Payments - Using modular component
                const SizedBox(height: 30),
                ScheduledPaymentsSection(
                  payments: [
                    ScheduledPaymentData(
                      title: 'Car Insurance',
                      amount: '-\$65',
                      status: 'Due date in 15 days',
                      date: '12 Oct',
                      isOverdue: false,
                      icon: Icons.drive_eta,
                      onTap: () {
                        print('Car Insurance payment tapped');
                      },
                    ),
                    ScheduledPaymentData(
                      title: 'Internet',
                      amount: '-\$35',
                      status: 'Overdue',
                      date: '10 Oct',
                      isOverdue: true,
                      icon: Icons.wifi,
                      onTap: () {
                        print('Internet payment tapped');
                      },
                    ),
                    ScheduledPaymentData(
                      title: 'Home Service Fee',
                      amount: '-\$35',
                      status: 'Overdue',
                      date: '10 Oct',
                      isOverdue: true,
                      icon: Icons.home,
                      onTap: () {
                        print('Home Service Fee payment tapped');
                      },
                    ),
                  ],
                  onSeeAllTap: () {
                    // TODO: Navigate to all scheduled payments page
                    print('Scheduled Payments See All tapped');
                  },
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: SafeArea(
        child: Stack(
          children: [
            // Main content - switch pages based on selected index
            _getCurrentPage(),

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
                            _buildNavItem(Icons.auto_awesome_outlined, 2),
                            _buildNavItem(Icons.apps_outlined, 3),
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
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddTransactionPage()),
        );
      },
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
}
