import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/widgets/index.dart';
import '../../../../core/di/service_locator.dart';
import '../../domain/entities/scheduled_payment_entity.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../../../expenses/domain/entities/expense_entity.dart';
import 'edit_scheduled_payment_page.dart';

class ScheduledPaymentDetailPage extends StatefulWidget {
  final int paymentId;

  const ScheduledPaymentDetailPage({super.key, required this.paymentId});

  @override
  State<ScheduledPaymentDetailPage> createState() =>
      _ScheduledPaymentDetailPageState();
}

class _ScheduledPaymentDetailPageState
    extends State<ScheduledPaymentDetailPage> {
  ScheduledPaymentEntity? _payment;
  ExpenseEntity? _expense;
  bool _isLoading = true;
  List<dynamic> _linkedTransactions = [];

  @override
  void initState() {
    super.initState();
    // Use WidgetsBinding to ensure context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPayment();
    });
  }

  Future<void> _loadPayment() async {
    try {
      final services = ServiceProvider.of(context);
      final repository = services.scheduledPaymentRepository;
      final transactionRepository = services.transactionRepository;
      final expenseRepository = services.expenseRepository;

      final payment = await repository.getScheduledPaymentById(
        widget.paymentId,
      );

      if (mounted && payment != null) {
        // Load expense category if linked
        ExpenseEntity? expense;
        if (payment.expenseId != null) {
          final expenses = await expenseRepository.watchAllExpenses().first;
          expense = expenses.firstWhere(
            (e) => e.id == payment.expenseId,
            orElse: () => expenses.first,
          );
        }

        // Load linked transactions for this payment from stream
        transactionRepository.watchAllTransactions().first.then((
          allTransactions,
        ) {
          if (mounted) {
            final linked = allTransactions
                .where((t) => t.scheduledPaymentId == payment.id)
                .toList();

            setState(() {
              _payment = payment;
              _expense = expense;
              _linkedTransactions = linked;
              _isLoading = false;
            });
          }
        });
      } else if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _markAsDone() async {
    if (_payment == null || _expense == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment category not found'),
            backgroundColor: Color(0xFFFF8282),
          ),
        );
      }
      return;
    }

    // First, let user select a bank
    final selectedBankId = await _showBankSelectionDialog();
    if (selectedBankId == null) return; // User cancelled

    final services = ServiceProvider.of(context);
    final paymentRepository = services.scheduledPaymentRepository;
    final transactionRepository = services.transactionRepository;
    final expenseRepository = services.expenseRepository;

    try {
      // Create an expense record
      final newExpense = ExpenseEntity(
        category: _expense!.category,
        amount: _payment!.amount,
        iconPath: _expense!.iconPath,
        iconColor: _expense!.iconColor,
        bankId: selectedBankId,
        description: 'Scheduled Payment: ${_payment!.name}',
        date: DateTime.now(),
      );

      await expenseRepository.addExpense(newExpense);

      // Create a transaction for this payment with category info
      final newTransaction = TransactionEntity(
        type: 'send',
        amount: _payment!.amount,
        name: '${_expense!.category} - ${_payment!.name}',
        iconPath: _expense!.iconPath,
        status: 'Completed',
        statusColor: 0xFF82FFB4,
        bankId: selectedBankId,
        scheduledPaymentId: _payment!.id,
        date: DateTime.now(),
        isDeleted: false,
      );

      await transactionRepository.addTransaction(newTransaction);

      if (_payment!.frequency == 'once') {
        // One-time payment: delete it
        await paymentRepository.deleteScheduledPayment(_payment!.id!);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment marked as complete and removed'),
              backgroundColor: Color(0xFF82FFB4),
            ),
          );
          Navigator.pop(context); // Go back since payment is deleted
        }
      } else {
        // Recurring payment: update next payment date
        DateTime nextDate;
        final currentDate = _payment!.nextPaymentDate;

        switch (_payment!.frequency) {
          case 'weekly':
            nextDate = DateTime(
              currentDate.year,
              currentDate.month,
              currentDate.day + 7,
            );
            break;
          case 'monthly':
            nextDate = DateTime(
              currentDate.year,
              currentDate.month + 1,
              currentDate.day,
            );
            break;
          case 'yearly':
            nextDate = DateTime(
              currentDate.year + 1,
              currentDate.month,
              currentDate.day,
            );
            break;
          default:
            nextDate = currentDate;
        }

        final updatedPayment = _payment!.copyWith(nextPaymentDate: nextDate);
        await paymentRepository.updateScheduledPayment(updatedPayment);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment marked as paid for this period'),
              backgroundColor: Color(0xFF82FFB4),
            ),
          );

          // Reload the payment data
          _loadPayment();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<int?> _showBankSelectionDialog() async {
    final services = ServiceProvider.of(context);
    final bankRepository = services.bankRepository;

    // Get all banks
    final banks = await bankRepository.watchAllBanks().first;

    if (banks.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please add a bank account first'),
            backgroundColor: Color(0xFFFF8282),
          ),
        );
      }
      return null;
    }

    return showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF191919),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Select Bank Account',
            style: TextStyle(
              color: Color(0xFFD6D6D6),
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w700,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: banks.length,
              itemBuilder: (context, index) {
                final bank = banks[index];
                return ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color(
                        int.parse(bank.color.replaceFirst('#', '0xFF')),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.account_balance,
                      color: Color(0xFF191919),
                      size: 20,
                    ),
                  ),
                  title: Text(
                    bank.name,
                    style: const TextStyle(
                      color: Color(0xFFD6D6D6),
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    ServiceProvider.of(
                      context,
                    ).currencyService.format(bank.balance),
                    style: const TextStyle(
                      color: Color(0xFF949494),
                      fontFamily: 'Poppins',
                      fontSize: 12,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context, bank.id);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Color(0xFF949494),
                  fontFamily: 'Manrope',
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  IconData _getIconFromName(String name) {
    final nameLower = name.toLowerCase();
    if (nameLower.contains('car') || nameLower.contains('vehicle')) {
      return Icons.directions_car;
    } else if (nameLower.contains('internet') || nameLower.contains('wifi')) {
      return Icons.wifi;
    } else if (nameLower.contains('home') || nameLower.contains('rent')) {
      return Icons.home;
    } else if (nameLower.contains('phone') || nameLower.contains('mobile')) {
      return Icons.phone;
    } else if (nameLower.contains('electric') || nameLower.contains('power')) {
      return Icons.electric_bolt;
    } else if (nameLower.contains('water')) {
      return Icons.water_drop;
    } else if (nameLower.contains('insurance') ||
        nameLower.contains('health')) {
      return Icons.health_and_safety;
    } else {
      return Icons.payment;
    }
  }

  String _getStatusText(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;

    if (difference < 0) {
      return 'Overdue';
    } else if (difference == 0) {
      return 'Due today';
    } else if (difference == 1) {
      return 'Due tomorrow';
    } else {
      return 'Due in $difference days';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF050505),
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xFFBA9BFF)),
        ),
      );
    }

    if (_payment == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF050505),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    CustomBackButton(
                      size: 40,
                      backgroundColor: const Color(0xFF2A2A2A),
                      iconColor: const Color(0xFFFFFFFF),
                    ),
                    const SizedBox(width: 15),
                    const Text(
                      'Payment Details',
                      style: TextStyle(
                        color: Color(0xFFFFFFFF),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
                const Expanded(
                  child: Center(
                    child: Text(
                      'Payment not found',
                      style: TextStyle(
                        color: Color(0xFF949494),
                        fontSize: 16,
                        fontFamily: 'Manrope',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final currencyService = ServiceProvider.of(context).currencyService;
    final title = _payment!.name;
    final amount = '-${currencyService.formatWhole(_payment!.amount)}';
    final status = _getStatusText(_payment!.nextPaymentDate);
    final date = DateFormat('d MMM').format(_payment!.nextPaymentDate);
    final icon = _getIconFromName(_payment!.name);

    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: SafeArea(
        child: SingleChildScrollView(
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
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFFFFFFFF),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Mark as Done button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 31),
                child: ElevatedButton(
                  onPressed: () => _markAsDone(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF82FFB4),
                    foregroundColor: const Color(0xFF191919),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _payment!.frequency == 'once'
                        ? 'Mark as Paid & Complete'
                        : 'Mark This Period as Paid',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Manrope',
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Payment card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 31),
                child: GestureDetector(
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditScheduledPaymentPage(
                          paymentId: widget.paymentId,
                        ),
                      ),
                    );

                    // Reload if edit was successful
                    if (result == true && mounted) {
                      _loadPayment();
                    }
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
                        // Icon
                        Positioned(
                          left: 15,
                          top: 22,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFFFFFF),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              icon,
                              color: const Color(0xFF191919),
                              size: 14,
                            ),
                          ),
                        ),

                        // Title
                        Positioned(
                          left: 48,
                          top: 17,
                          child: Text(
                            title,
                            style: const TextStyle(
                              color: Color(0xFFD6D6D6),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Manrope',
                              height: 1.366,
                            ),
                          ),
                        ),

                        // Amount
                        Positioned(
                          right: 28,
                          top: 18,
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

                        // Status
                        Positioned(
                          left: 48,
                          top: 33,
                          child: Text(
                            status,
                            style: TextStyle(
                              color: status.toLowerCase().contains('overdue')
                                  ? const Color(0xFFFF8282)
                                  : const Color(0xFFADACAC),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Manrope',
                              height: 1.366,
                            ),
                          ),
                        ),

                        // Date
                        Positioned(
                          right: 28,
                          top: 35,
                          child: Text(
                            date,
                            style: const TextStyle(
                              color: Color(0xFFADACAC),
                              fontSize: 10,
                              fontWeight: FontWeight.w300,
                              fontFamily: 'Manrope',
                              height: 1.366,
                            ),
                          ),
                        ),

                        // Arrow
                        const Positioned(
                          right: 8,
                          top: 26,
                          child: Icon(
                            Icons.chevron_right,
                            color: Color(0xFFD6D6D6),
                            size: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Transaction History section
              const Padding(
                padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                child: Text(
                  'Transaction History',
                  style: TextStyle(
                    color: Color(0xFFD6D6D6),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Manrope',
                    height: 1.366,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Transaction cards - show real linked transactions
              if (_linkedTransactions.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: Text(
                    _payment!.frequency == 'once'
                        ? 'No payment history yet. Mark as paid to complete.'
                        : 'No payment history yet. Mark periods as paid to track history.',
                    style: const TextStyle(
                      color: Color(0xFF9E9E9E),
                      fontSize: 11,
                      fontFamily: 'Manrope',
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              else
                ..._linkedTransactions.map((transaction) {
                  final currencyService = ServiceProvider.of(
                    context,
                  ).currencyService;
                  final date = DateFormat(
                    'dd MMMM yyyy',
                  ).format(transaction.date);
                  final time = DateFormat('hh:mma').format(transaction.date);
                  final amount =
                      '-${currencyService.formatWhole(transaction.amount)}';

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildTransactionCard(
                      date: date,
                      description: transaction.name,
                      time: time,
                      amount: amount,
                    ),
                  );
                }),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionCard({
    required String date,
    required String description,
    required String time,
    required String amount,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Container(
        height: 91,
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
            // Date label (top left)
            Positioned(
              left: 16,
              top: 14,
              child: Text(
                date,
                style: const TextStyle(
                  color: Color(0xFFC6C6C6),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Manrope',
                  height: 1.366,
                ),
              ),
            ),

            // Divider line
            Positioned(
              left: 108,
              top: 22.63,
              child: Container(
                width: 179.01,
                height: 1,
                color: const Color(0xFFC6C6C6),
              ),
            ),

            // Icon
            Positioned(
              left: 16,
              top: 46,
              child: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: Color(0xFF82FFB4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Color(0xFF191919),
                  size: 14,
                ),
              ),
            ),

            // Description with green circle indicator
            Positioned(
              left: 51,
              top: 47,
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF82FFB4),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    description,
                    style: const TextStyle(
                      color: Color(0xFFE6E6E6),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Manrope',
                      height: 1.366,
                    ),
                  ),
                ],
              ),
            ),

            // Time
            Positioned(
              left: 51,
              top: 63,
              child: Text(
                time,
                style: const TextStyle(
                  color: Color(0xFF9E9E9E),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Poppins',
                  height: 1.5,
                ),
              ),
            ),

            // Amount
            Positioned(
              right: 16,
              top: 47,
              child: Text(
                amount,
                style: const TextStyle(
                  color: Color(0xFF949494),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Poppins',
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
