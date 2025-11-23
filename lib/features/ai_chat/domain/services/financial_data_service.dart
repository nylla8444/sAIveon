import 'package:drift/drift.dart';
import 'package:intl/intl.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/services/currency_service.dart';

/// Service to gather and format financial data for AI analysis
///
/// Note: This service now uses dynamic currency formatting from CurrencyService.
class FinancialDataService {
  final AppDatabase _database;
  final CurrencyService _currencyService;

  FinancialDataService(this._database, this._currencyService);

  /// Get comprehensive financial summary for AI context
  Future<String> getFinancialSummary() async {
    final banks = await _getAllBanks();
    final recentTransactions = await _getRecentTransactions();
    final budgets = await _getCurrentBudgets();
    final expenses = await _getMonthlyExpenses();
    final scheduledPayments = await _getScheduledPayments();
    final insights = await _generateInsights();

    final buffer = StringBuffer();
    buffer.writeln('# User Financial Data\n');

    buffer.writeln('## Bank Accounts');
    buffer.writeln(banks);
    buffer.writeln();

    buffer.writeln('## Recent Transactions (Last 30 days)');
    buffer.writeln(recentTransactions);
    buffer.writeln();

    buffer.writeln('## Current Month Budgets');
    buffer.writeln(budgets);
    buffer.writeln();

    buffer.writeln('## Monthly Expenses Breakdown');
    buffer.writeln(expenses);
    buffer.writeln();

    buffer.writeln('## Scheduled Payments');
    buffer.writeln(scheduledPayments);
    buffer.writeln();

    buffer.writeln('## Financial Insights');
    buffer.writeln(insights);

    return buffer.toString();
  }

  Future<String> _getAllBanks() async {
    final banks = await (_database.select(
      _database.banks,
    )..where((t) => t.isDeleted.equals(false))).get();

    if (banks.isEmpty) {
      return 'No bank accounts registered.';
    }

    final buffer = StringBuffer();
    double totalBalance = 0;

    for (var bank in banks) {
      buffer.writeln(
        '- ${bank.name} (${bank.accountNumber}): ${_currencyService.format(bank.balance)}',
      );
      totalBalance += bank.balance;
    }

    buffer.writeln('\nTotal Balance: ${_currencyService.format(totalBalance)}');
    return buffer.toString();
  }

  Future<String> _getRecentTransactions() async {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));

    final transactions =
        await (_database.select(_database.transactions)
              ..where(
                (t) =>
                    t.isDeleted.equals(false) &
                    t.date.isBiggerOrEqualValue(thirtyDaysAgo),
              )
              ..orderBy([(t) => OrderingTerm.desc(t.date)])
              ..limit(20))
            .get();

    if (transactions.isEmpty) {
      return 'No transactions in the last 30 days.';
    }

    final buffer = StringBuffer();
    double totalIncome = 0;
    double totalSpending = 0;
    double totalTransfers = 0;

    for (var tx in transactions) {
      final dateStr = DateFormat('MMM dd, yyyy').format(tx.date);
      final typeEmoji = tx.type == 'receive'
          ? '💰'
          : (tx.type == 'send' ? '💸' : '🔄');

      buffer.writeln(
        '$typeEmoji ${tx.name}: ${_currencyService.format(tx.amount)} - $dateStr',
      );

      if (tx.type == 'receive') {
        totalIncome += tx.amount;
      } else if (tx.type == 'send') {
        totalSpending += tx.amount;
      } else {
        totalTransfers += tx.amount;
      }
    }

    buffer.writeln('\nSummary:');
    buffer.writeln('- Income: ${_currencyService.format(totalIncome)}');
    buffer.writeln('- Spending: ${_currencyService.format(totalSpending)}');
    buffer.writeln('- Transfers: ${_currencyService.format(totalTransfers)}');
    buffer.writeln(
      '- Net: ${_currencyService.format(totalIncome - totalSpending)}',
    );

    return buffer.toString();
  }

  Future<String> _getCurrentBudgets() async {
    final now = DateTime.now();

    final budgets =
        await (_database.select(_database.budgets)
              ..where((t) => t.isDeleted.equals(false))
              ..where((t) => t.month.equals(now.month))
              ..where((t) => t.year.equals(now.year)))
            .get();

    if (budgets.isEmpty) {
      return 'No budgets set for current month.';
    }

    final buffer = StringBuffer();
    double totalBudget = 0;
    double totalSpent = 0;

    for (var budget in budgets) {
      final remaining = budget.budgetAmount - budget.spentAmount;
      final percentage = (budget.spentAmount / budget.budgetAmount * 100).clamp(
        0,
        100,
      );
      final status = percentage >= 90 ? '⚠️' : (percentage >= 70 ? '⚡' : '✅');

      buffer.writeln(
        '$status ${budget.category}: ${_currencyService.format(budget.spentAmount)} / ${_currencyService.format(budget.budgetAmount)} (${percentage.toStringAsFixed(0)}% used, ${_currencyService.format(remaining)} remaining)',
      );

      totalBudget += budget.budgetAmount;
      totalSpent += budget.spentAmount;
    }

    buffer.writeln('\nTotal Budget: ${_currencyService.format(totalBudget)}');
    buffer.writeln('Total Spent: ${_currencyService.format(totalSpent)}');
    buffer.writeln(
      'Remaining: ${_currencyService.format(totalBudget - totalSpent)}',
    );

    return buffer.toString();
  }

  Future<String> _getMonthlyExpenses() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    final transactions =
        await (_database.select(_database.transactions)..where(
              (t) =>
                  t.isDeleted.equals(false) &
                  t.type.equals('send') &
                  t.date.isBiggerOrEqualValue(startOfMonth) &
                  t.date.isSmallerOrEqualValue(endOfMonth),
            ))
            .get();

    if (transactions.isEmpty) {
      return 'No expenses recorded this month.';
    }

    final categoryTotals = <String, double>{};
    double totalExpenses = 0;

    for (var tx in transactions) {
      categoryTotals[tx.name] = (categoryTotals[tx.name] ?? 0) + tx.amount;
      totalExpenses += tx.amount;
    }

    final buffer = StringBuffer();
    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    for (var entry in sortedCategories) {
      final percentage = (entry.value / totalExpenses * 100);
      buffer.writeln(
        '- ${entry.key}: ${_currencyService.format(entry.value)} (${percentage.toStringAsFixed(1)}%)',
      );
    }

    buffer.writeln(
      '\nTotal Expenses: ${_currencyService.format(totalExpenses)}',
    );

    return buffer.toString();
  }

  Future<String> _getScheduledPayments() async {
    final payments =
        await (_database.select(_database.scheduledPayments)
              ..where((t) => t.isDeleted.equals(false))
              ..orderBy([(t) => OrderingTerm.asc(t.nextPaymentDate)]))
            .get();

    if (payments.isEmpty) {
      return 'No scheduled payments.';
    }

    final buffer = StringBuffer();
    double totalUpcoming = 0;

    for (var payment in payments) {
      final dateStr = DateFormat(
        'MMM dd, yyyy',
      ).format(payment.nextPaymentDate);
      final daysUntil = payment.nextPaymentDate
          .difference(DateTime.now())
          .inDays;

      buffer.writeln(
        '- ${payment.name}: ${_currencyService.format(payment.amount)} - $dateStr (${payment.frequency}, in $daysUntil days)',
      );
      totalUpcoming += payment.amount;
    }

    buffer.writeln(
      '\nTotal Upcoming: ${_currencyService.format(totalUpcoming)}',
    );

    return buffer.toString();
  }

  Future<String> _generateInsights() async {
    final buffer = StringBuffer();

    // Calculate spending trends
    final now = DateTime.now();
    final currentMonthStart = DateTime(now.year, now.month, 1);
    final lastMonthStart = DateTime(now.year, now.month - 1, 1);
    final lastMonthEnd = DateTime(now.year, now.month, 0, 23, 59, 59);

    final currentMonthSpending = await _getSpendingForPeriod(
      currentMonthStart,
      now,
    );
    final lastMonthSpending = await _getSpendingForPeriod(
      lastMonthStart,
      lastMonthEnd,
    );

    if (lastMonthSpending > 0) {
      final change =
          ((currentMonthSpending - lastMonthSpending) /
          lastMonthSpending *
          100);
      if (change > 10) {
        buffer.writeln(
          '⚠️ Spending is up ${change.toStringAsFixed(1)}% compared to last month.',
        );
      } else if (change < -10) {
        buffer.writeln(
          '✅ Spending is down ${change.abs().toStringAsFixed(1)}% compared to last month.',
        );
      } else {
        buffer.writeln(
          '📊 Spending is relatively stable compared to last month.',
        );
      }
    }

    // Check for budget alerts
    final budgets =
        await (_database.select(_database.budgets)
              ..where((t) => t.isDeleted.equals(false))
              ..where((t) => t.month.equals(now.month))
              ..where((t) => t.year.equals(now.year)))
            .get();

    final overBudget = budgets
        .where((b) => b.spentAmount > b.budgetAmount)
        .toList();
    if (overBudget.isNotEmpty) {
      buffer.writeln(
        '⚠️ ${overBudget.length} budget(s) exceeded: ${overBudget.map((b) => b.category).join(", ")}',
      );
    }

    final nearLimit = budgets
        .where(
          (b) =>
              b.spentAmount >= b.budgetAmount * 0.9 &&
              b.spentAmount <= b.budgetAmount,
        )
        .toList();
    if (nearLimit.isNotEmpty) {
      buffer.writeln(
        '⚡ ${nearLimit.length} budget(s) near limit (90%+): ${nearLimit.map((b) => b.category).join(", ")}',
      );
    }

    return buffer.toString();
  }

  Future<double> _getSpendingForPeriod(DateTime start, DateTime end) async {
    final transactions =
        await (_database.select(_database.transactions)..where(
              (t) =>
                  t.isDeleted.equals(false) &
                  t.type.equals('send') &
                  t.date.isBiggerOrEqualValue(start) &
                  t.date.isSmallerOrEqualValue(end),
            ))
            .get();

    return transactions.fold<double>(0, (sum, tx) => sum + tx.amount);
  }
}
