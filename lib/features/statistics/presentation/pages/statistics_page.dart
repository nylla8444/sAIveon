import 'package:flutter/material.dart';
import '../widgets/statistics_chart_section.dart';
import '../widgets/income_expenses_section.dart';
import '../widgets/income_value_section.dart';
import '../../../expenses/presentation/widgets/expenses_value_section.dart';
import '../widgets/last_6_periods_section.dart';
import '../../../banks/presentation/widgets/balance_with_banks_section.dart';
import '../../../notifications/presentation/pages/notifications_page.dart';
import '../../../../core/di/service_locator.dart';
import '../../../banks/presentation/pages/bank_detail_page.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
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
                _buildHeader(context),

                const SizedBox(height: 20),

                // Search Bar
                _buildSearchBar(),

                const SizedBox(height: 30),

                // Statistics Chart Section
                const StatisticsChartSection(),

                const SizedBox(height: 30),

                // Income and Expenses Section - Connected to real data
                StreamBuilder<List<dynamic>>(
                  stream: ServiceProvider.of(
                    context,
                  ).transactionRepository.watchAllTransactions(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const SizedBox.shrink();
                    }

                    final now = DateTime.now();
                    final currentMonthStart = DateTime(now.year, now.month, 1);
                    final lastMonthStart = DateTime(now.year, now.month - 1, 1);
                    final lastMonthEnd = DateTime(
                      now.year,
                      now.month,
                      0,
                      23,
                      59,
                      59,
                    );

                    final transactions = snapshot.data!
                        .where((t) => !t.isDeleted)
                        .toList();
                    final currencyService = ServiceProvider.of(
                      context,
                    ).currencyService;

                    // Current month income and expenses
                    double currentIncome = 0;
                    double currentExpenses = 0;

                    for (var tx in transactions) {
                      if (tx.date.isAfter(currentMonthStart) &&
                          tx.date.isBefore(now)) {
                        if (tx.type == 'receive') {
                          currentIncome += tx.amount;
                        } else if (tx.type == 'send') {
                          currentExpenses += tx.amount;
                        }
                      }
                    }

                    // Last month income and expenses
                    double lastIncome = 0;
                    double lastExpenses = 0;

                    for (var tx in transactions) {
                      if (tx.date.isAfter(lastMonthStart) &&
                          tx.date.isBefore(lastMonthEnd)) {
                        if (tx.type == 'receive') {
                          lastIncome += tx.amount;
                        } else if (tx.type == 'send') {
                          lastExpenses += tx.amount;
                        }
                      }
                    }

                    // Calculate percentage changes
                    final incomeChange = lastIncome > 0
                        ? ((currentIncome - lastIncome) / lastIncome * 100)
                        : (currentIncome > 0 ? 100.0 : 0.0);
                    final expensesChange = lastExpenses > 0
                        ? ((currentExpenses - lastExpenses) /
                              lastExpenses *
                              100)
                        : (currentExpenses > 0 ? 100.0 : 0.0);

                    final incomePercentage =
                        '${incomeChange >= 0 ? '+' : ''}${incomeChange.toStringAsFixed(0)}%';
                    final expensesPercentage =
                        '${expensesChange >= 0 ? '+' : ''}${expensesChange.toStringAsFixed(0)}%';

                    // Calculate progress bars (relative to max value)
                    final maxIncome = currentIncome > lastIncome
                        ? currentIncome
                        : lastIncome;
                    final maxExpenses = currentExpenses > lastExpenses
                        ? currentExpenses
                        : lastExpenses;

                    final incomeProgress = maxIncome > 0
                        ? (currentIncome / maxIncome).clamp(0.0, 1.0)
                        : 0.0;
                    final expensesProgress = maxExpenses > 0
                        ? (currentExpenses / maxExpenses).clamp(0.0, 1.0)
                        : 0.0;

                    return Column(
                      children: [
                        // Income and Expenses Section
                        IncomeExpensesSection(
                          incomePercentage: incomePercentage,
                          expensesPercentage: expensesPercentage,
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
                          amount: currencyService.formatWhole(currentIncome),
                          progress: incomeProgress,
                          onTap: () {
                            // TODO: Navigate to income details
                          },
                        ),

                        const SizedBox(height: 15),

                        // Expenses Value Section with Progress Bar
                        ExpensesValueSection(
                          amount: currencyService.formatWhole(currentExpenses),
                          progress: expensesProgress,
                          onTap: () {
                            // TODO: Navigate to expenses details
                          },
                        ),
                      ],
                    );
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

                // Balance with Banks Section - Connected to real data
                StreamBuilder<List<dynamic>>(
                  stream: ServiceProvider.of(
                    context,
                  ).bankRepository.watchAllBanks(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const SizedBox.shrink();
                    }

                    final banks = snapshot.data!
                        .where((b) => !b.isDeleted)
                        .toList();
                    final currencyService = ServiceProvider.of(
                      context,
                    ).currencyService;

                    final totalBalance = banks.fold<double>(
                      0,
                      (sum, bank) => sum + bank.balance,
                    );

                    return BalanceWithBanksSection(
                      totalBalance: currencyService.format(totalBalance),
                      banks: banks.map((bank) {
                        return BankBalanceData(
                          bankName: bank.name,
                          amount: currencyService.format(bank.balance),
                          icon: Icons.account_balance,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BankDetailPage(
                                  bankId: bank.id,
                                  bankName: bank.name,
                                  balance: currencyService.format(bank.balance),
                                ),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    );
                  },
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsPage(),
                ),
              );
            },
            child: Stack(
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
