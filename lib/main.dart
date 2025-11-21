import 'dart:async';
import 'package:flutter/material.dart';
import 'core/widgets/index.dart';
import 'core/di/service_locator.dart';
import 'core/config/env.dart';
import 'features/banks/banks.dart';
import 'features/banks/domain/entities/bank_entity.dart';
import 'features/transactions/domain/entities/transaction_entity.dart';
import 'features/transactions/transactions.dart';
// TransactionHistorySection types are exported via the transactions barrel
import 'features/budgets/budgets.dart';
import 'features/expenses/expenses.dart';
import 'features/scheduled_payments/scheduled_payments.dart';
import 'features/statistics/statistics.dart';
import 'features/home/home.dart';
import 'features/settings/settings.dart';
import 'features/notifications/notifications.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ServiceLocator? _serviceLocator;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    print('🔵 START: Initializing services...');
    try {
      print('🔵 Loading environment variables...');
      await Env.load();
      print('🔵 Environment loaded');

      final serviceLocator = ServiceLocator();
      print('🔵 ServiceLocator created');

      await serviceLocator.initialize();
      print('🔵 ServiceLocator initialized successfully');

      if (mounted) {
        setState(() {
          _serviceLocator = serviceLocator;
          _isInitialized = true;
        });
        print('🟢 COMPLETE: Services ready!');
      }
    } catch (e, stackTrace) {
      print('🔴 ERROR during initialization: $e');
      print('Stack trace: $stackTrace');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _serviceLocator == null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: const Color(0xFF050505),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: const Color(0xFFA882FF)),
                const SizedBox(height: 16),
                Text(
                  'Initializing...',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ServiceProvider(
      serviceLocator: _serviceLocator!,
      child: MaterialApp(
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
      ),
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

  String _formatCurrency(double value) {
    final whole = value.abs().toStringAsFixed(0);
    final s = '\$' + whole;
    return value < 0 ? '-' + s : s;
  }

  String _formatTime(DateTime date) {
    final h = date.hour > 12
        ? date.hour - 12
        : (date.hour == 0 ? 12 : date.hour);
    final m = date.minute.toString().padLeft(2, '0');
    final p = date.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m$p';
  }

  IconData _iconForTransaction(String type) {
    switch (type) {
      case 'receive':
        return Icons.arrow_downward;
      case 'transfer':
        return Icons.swap_horiz;
      case 'send':
      default:
        return Icons.arrow_upward;
    }
  }

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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotificationsPage(),
                      ),
                    );
                  },
                ),

                // Balance Section - Using modular BalanceSection widget
                const SizedBox(height: 20),
                // Total balance from all banks
                Builder(
                  builder: (context) {
                    final locator = ServiceProvider.of(context);
                    return StreamBuilder<List<BankEntity>>(
                      stream: locator.bankRepository.watchAllBanks(),
                      builder: (context, snapshot) {
                        final banks = snapshot.data ?? const <BankEntity>[];
                        final total = banks.fold<double>(
                          0,
                          (sum, b) => sum + (b.balance),
                        );
                        final text = _formatCurrency(total);
                        return BalanceSection(balance: text);
                      },
                    );
                  },
                ),

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
                Builder(
                  builder: (context) {
                    final locator = ServiceProvider.of(context);
                    return StreamBuilder<List<BankEntity>>(
                      stream: locator.bankRepository.watchAllBanks(),
                      builder: (context, snapshot) {
                        final banks = snapshot.data ?? const <BankEntity>[];
                        final items = banks.map((b) {
                          final amount = _formatCurrency(b.balance);
                          return BankCardData(
                            name: b.name,
                            amount: amount,
                            icon: Icons.account_balance,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BankDetailPage(
                                    bankId: b.id!,
                                    bankName: b.name,
                                    balance: amount,
                                  ),
                                ),
                              );
                            },
                            onArrowTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BankDetailPage(
                                    bankId: b.id!,
                                    bankName: b.name,
                                    balance: amount,
                                  ),
                                ),
                              );
                            },
                          );
                        }).toList();

                        return BanksHorizontalScrollSection(
                          banks: items,
                          onAddBank: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AddBankPage(),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),

                // Transaction History - Using modular component
                const SizedBox(height: 30),
                Builder(
                  builder: (context) {
                    final locator = ServiceProvider.of(context);
                    return StreamBuilder<List<TransactionEntity>>(
                      stream: locator.transactionRepository
                          .watchAllTransactions(),
                      builder: (context, snapshot) {
                        final txns =
                            snapshot.data ?? const <TransactionEntity>[];

                        return StreamBuilder(
                          stream: locator.bankRepository.watchAllBanks(),
                          builder: (context, bankSnap) {
                            final banks = bankSnap.data ?? const [];
                            final bankNames = {
                              for (final b in banks)
                                if (b.id != null) b.id!: b.name,
                            };

                            final recent = txns.map((t) {
                              final isIncome = t.type == 'receive';
                              final sign = isIncome ? '+' : '-';
                              final amt = _formatCurrency(t.amount);
                              final time = _formatTime(t.date);

                              String bankName;
                              if (t.type == 'transfer' &&
                                  t.bankId != null &&
                                  t.toBankId != null) {
                                final fromBank = bankNames[t.bankId!] ?? '-';
                                final toBank = bankNames[t.toBankId!] ?? '-';
                                bankName = '$fromBank → $toBank';
                              } else {
                                bankName = t.bankId != null
                                    ? (bankNames[t.bankId!] ?? '-')
                                    : '-';
                              }

                              return TransactionData(
                                id: t.id!,
                                title: t.name,
                                subtitle: bankName,
                                amount: '$sign$amt',
                                time: time,
                                date: t.date,
                                type: t.type,
                                rawAmount: t.amount,
                                bankId: t.bankId,
                                icon: _iconForTransaction(t.type),
                              );
                            }).toList();

                            return TransactionHistorySection(
                              transactions: recent.toList(),
                              onSeeAllTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const TransactionHistoryPage(),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                ),

                // Monthly Budget Section - Using modular component
                const SizedBox(height: 30),
                MonthlyBudgetSection(
                  onSeeAllTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MonthlyBudgetPage(),
                      ),
                    );
                  },
                ),

                // Monthly Spending Line Graph - Using modular component
                const SizedBox(height: 30),
                const SpendingLineChartSection(),

                // Expenses Section - Using modular component
                const SizedBox(height: 30),
                ExpensesHorizontalScrollSection(
                  onSeeAllTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ExpensesSeeAllPage(),
                      ),
                    );
                  },
                ),

                // Scheduled Payments - Using modular component
                const SizedBox(height: 30),
                Builder(
                  builder: (context) {
                    final locator = ServiceProvider.of(context);
                    return StreamBuilder(
                      stream: locator.scheduledPaymentRepository
                          .watchAllScheduledPayments(),
                      builder: (context, snapshot) {
                        final payments = snapshot.data ?? [];
                        // Filter out deleted payments and sort by date
                        final activePayments =
                            payments.where((p) => !p.isDeleted).toList()..sort(
                              (a, b) => a.nextPaymentDate.compareTo(
                                b.nextPaymentDate,
                              ),
                            );

                        return ScheduledPaymentsSection(
                          payments: activePayments,
                          onSeeAllTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ScheduledPaymentsPage(),
                              ),
                            );
                          },
                          onPaymentTap: (payment) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ScheduledPaymentDetailPage(
                                      paymentId: payment.id!,
                                    ),
                              ),
                            );
                          },
                        );
                      },
                    );
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
