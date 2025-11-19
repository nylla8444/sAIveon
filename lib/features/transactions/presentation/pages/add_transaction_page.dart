import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/di/service_locator.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../../banks/domain/entities/bank_entity.dart';

enum TransactionType { income, spending, transfer }

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  TransactionType _selectedType = TransactionType.income;

  // Form controllers
  final TextEditingController _amountController = TextEditingController();
  int? _selectedBankId;
  String? _selectedAccount;
  int? _selectedToBankId; // For transfers
  String? _selectedToAccount; // For transfers
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedCategory;

  // Categories based on transaction type
  final Map<TransactionType, List<String>> _categoriesByType = {
    TransactionType.income: [
      'Salary',
      'Freelance',
      'Business',
      'Investment',
      'Gift',
      'Bonus',
      'Other Income',
    ],
    TransactionType.spending: [
      'Food & Dining',
      'Shopping',
      'Transportation',
      'Bills & Utilities',
      'Entertainment',
      'Healthcare',
      'Education',
      'Groceries',
      'Other Expenses',
    ],
    TransactionType.transfer: [
      'Savings',
      'Emergency Fund',
      'Investment Account',
      'Loan Payment',
      'Credit Card Payment',
      'Other Transfer',
    ],
  };

  List<String> get _currentCategories => _categoriesByType[_selectedType]!;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Return button - bigger and more tappable
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 4,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.arrow_back_ios,
                          color: Color(0xFFD6D6D6),
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Return',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            color: Color(0xFFD6D6D6),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            height: 1.366,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // Main card container
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF101010),
                    border: Border.all(
                      color: const Color(0xFFFFFFFF).withValues(alpha: 0.06),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(13),
                  child: Column(
                    children: [
                      // Tab selector
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildTab('Income', TransactionType.income),
                          _buildTab('Spending', TransactionType.spending),
                          _buildTab('Transfer', TransactionType.transfer),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // Input fields
                      _buildAmountField(),

                      const SizedBox(height: 7),

                      _buildAccountField(),

                      if (_selectedType == TransactionType.transfer) ...[
                        const SizedBox(height: 7),
                        _buildToAccountField(),
                      ],

                      const SizedBox(height: 7),

                      _buildDateTimeField(),

                      const SizedBox(height: 7),

                      _buildCategoryField(),

                      const SizedBox(height: 27),

                      // Save button
                      GestureDetector(
                        onTap: _onSave,
                        child: Container(
                          width: double.infinity,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFFBA9BFF),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'Save',
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              color: Color(0xFF050505),
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              height: 1.366,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTab(String label, TransactionType type) {
    final isSelected = _selectedType == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedType = type),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Manrope',
              color: isSelected
                  ? const Color(0xFFA47FFA)
                  : const Color(0xFFD6D6D6),
              fontSize: 15,
              fontWeight: FontWeight.w800,
              height: 1.366,
            ),
          ),
          const SizedBox(height: 7),
          if (isSelected)
            Container(
              width: label == 'Income'
                  ? 76
                  : label == 'Spending'
                  ? 119
                  : 84,
              height: 2,
              color: const Color(0xFFA47FFA),
            ),
        ],
      ),
    );
  }

  // Amount input field
  Widget _buildAmountField() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFF191919),
        border: Border.all(
          color: const Color(0xFFFFFFFF).withValues(alpha: 0.05),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          const Icon(Icons.attach_money, color: Color(0xFFD6D6D6), size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(
                fontFamily: 'Manrope',
                color: Color(0xFFD6D6D6),
                fontSize: 12,
                fontWeight: FontWeight.w700,
                height: 1.366,
              ),
              decoration: const InputDecoration(
                hintText: 'Amount',
                hintStyle: TextStyle(
                  fontFamily: 'Manrope',
                  color: Color(0xFFD6D6D6),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  height: 1.366,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Account selection field
  Widget _buildAccountField() {
    final label = _selectedType == TransactionType.transfer
        ? 'From Account'
        : 'Account';
    final hint = _selectedAccount ?? label;

    return GestureDetector(
      onTap: () => _showAccountPicker(isSource: true),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFF191919),
          border: Border.all(
            color: const Color(0xFFFFFFFF).withValues(alpha: 0.05),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            const Icon(
              Icons.account_balance_wallet,
              color: Color(0xFFD6D6D6),
              size: 24,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                hint,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  color: Color(0xFFD6D6D6),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  height: 1.366,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFFD6D6D6), size: 15),
          ],
        ),
      ),
    );
  }

  // Destination account field for transfers
  Widget _buildToAccountField() {
    return GestureDetector(
      onTap: () => _showAccountPicker(isSource: false),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFF191919),
          border: Border.all(
            color: const Color(0xFFFFFFFF).withValues(alpha: 0.05),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            const Icon(Icons.arrow_forward, color: Color(0xFFD6D6D6), size: 24),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                _selectedToAccount ?? 'To Account',
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  color: Color(0xFFD6D6D6),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  height: 1.366,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFFD6D6D6), size: 15),
          ],
        ),
      ),
    );
  }

  // Date and Time picker field
  Widget _buildDateTimeField() {
    String displayText = 'Date and Time';
    if (_selectedDate != null) {
      displayText =
          '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}';
      if (_selectedTime != null) {
        displayText += ' ${_selectedTime!.format(context)}';
      }
    }

    return GestureDetector(
      onTap: () => _showDateTimePicker(),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFF191919),
          border: Border.all(
            color: const Color(0xFFFFFFFF).withValues(alpha: 0.05),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today,
              color: Color(0xFFD6D6D6),
              size: 24,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                displayText,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  color: Color(0xFFD6D6D6),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  height: 1.366,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFFD6D6D6), size: 15),
          ],
        ),
      ),
    );
  }

  // Category selection field
  Widget _buildCategoryField() {
    return GestureDetector(
      onTap: () => _showCategoryPicker(),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFF191919),
          border: Border.all(
            color: const Color(0xFFFFFFFF).withValues(alpha: 0.05),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            const Icon(Icons.category, color: Color(0xFFD6D6D6), size: 24),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                _selectedCategory ?? 'Select category',
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  color: Color(0xFFD6D6D6),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  height: 1.366,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFFD6D6D6), size: 15),
          ],
        ),
      ),
    );
  }

  // Show account picker modal
  void _showAccountPicker({bool isSource = true}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF101010),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final locator = ServiceProvider.of(context);
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isSource
                    ? 'Select Source Account'
                    : 'Select Destination Account',
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  color: Color(0xFFD6D6D6),
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 320,
                child: StreamBuilder<List<BankEntity>>(
                  stream: locator.bankRepository.watchAllBanks(),
                  builder: (context, snapshot) {
                    final banks = snapshot.data ?? const <BankEntity>[];
                    if (banks.isEmpty) {
                      return const Center(
                        child: Text(
                          'No banks found. Add one first.',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            color: Color(0xFFD6D6D6),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: banks.length,
                      itemBuilder: (context, index) {
                        final bank = banks[index];
                        return ListTile(
                          title: Text(
                            bank.name,
                            style: const TextStyle(
                              fontFamily: 'Manrope',
                              color: Color(0xFFD6D6D6),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            _formatMoney(bank.balance),
                            style: const TextStyle(
                              fontFamily: 'Manrope',
                              color: Color(0xFF9E9E9E),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              if (isSource) {
                                _selectedBankId = bank.id;
                                _selectedAccount = bank.name;
                              } else {
                                _selectedToBankId = bank.id;
                                _selectedToAccount = bank.name;
                              }
                            });
                            Navigator.pop(context);
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Show date and time picker
  Future<void> _showDateTimePicker() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFBA9BFF),
              onPrimary: Color(0xFF000000),
              surface: Color(0xFF101010),
              onSurface: Color(0xFFD6D6D6),
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: _selectedTime ?? TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.dark(
                primary: Color(0xFFBA9BFF),
                onPrimary: Color(0xFF000000),
                surface: Color(0xFF101010),
                onSurface: Color(0xFFD6D6D6),
              ),
            ),
            child: child!,
          );
        },
      );

      if (time != null) {
        setState(() {
          _selectedDate = date;
          _selectedTime = time;
        });
      }
    }
  }

  // Show category picker modal
  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF101010),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Category',
              style: TextStyle(
                fontFamily: 'Manrope',
                color: Color(0xFFD6D6D6),
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 300,
              child: ListView(
                children: _currentCategories
                    .map(
                      (category) => ListTile(
                        title: Text(
                          category,
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            color: Color(0xFFD6D6D6),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        onTap: () {
                          setState(() => _selectedCategory = category);
                          Navigator.pop(context);
                        },
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onSave() async {
    const red = '\x1B[31m';
    const green = '\x1B[32m';
    const yellow = '\x1B[33m';
    const reset = '\x1B[0m';

    final raw = _amountController.text.trim();
    final amount = double.tryParse(raw);

    if (amount == null || amount <= 0) {
      _showSnack('Please enter a valid amount');
      return;
    }
    if (_selectedBankId == null) {
      _showSnack('Please select an account');
      return;
    }
    if (_selectedType == TransactionType.transfer &&
        _selectedToBankId == null) {
      _showSnack('Please select a destination account');
      return;
    }
    if (_selectedType == TransactionType.transfer &&
        _selectedBankId == _selectedToBankId) {
      _showSnack('Source and destination accounts must be different');
      return;
    }
    if (_selectedCategory == null) {
      _showSnack('Please select a category');
      return;
    }

    try {
      final type = _selectedType == TransactionType.income
          ? 'receive'
          : (_selectedType == TransactionType.transfer ? 'transfer' : 'send');

      // Build date from selected date/time or now
      final dt = _selectedDate != null && _selectedTime != null
          ? DateTime(
              _selectedDate!.year,
              _selectedDate!.month,
              _selectedDate!.day,
              _selectedTime!.hour,
              _selectedTime!.minute,
            )
          : DateTime.now();

      print(
        '🟨 ${yellow}[DB] ADD_TRANSACTION_REQUEST type=$type amount=$amount category=$_selectedCategory${reset}',
      );

      final locator = ServiceProvider.of(context);
      await locator.transactionRepository.addTransaction(
        TransactionEntity(
          id: null,
          type: type,
          amount: amount,
          name: _selectedCategory!,
          iconPath: 'default',
          status: 'completed',
          statusColor: 0xFF00FF00,
          bankId: _selectedBankId,
          toBankId: _selectedType == TransactionType.transfer
              ? _selectedToBankId
              : null,
          date: dt,
          serverId: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isDeleted: false,
        ),
      );

      print('🟩 ${green}[DB] ADD_TRANSACTION_SUCCESS${reset}');
      if (mounted) Navigator.pop(context);
    } catch (e, st) {
      print('🟥 ${red}[DB] ADD_TRANSACTION_ERROR: $e${reset}');
      print('🟥 ${red}$st${reset}');
      _showSnack('Failed to save transaction: $e');
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _formatMoney(double value) {
    final s = value.toStringAsFixed(2);
    // Simple thousands separator
    final parts = s.split('.');
    final whole = parts[0];
    final decimals = parts[1];
    final chars = whole.split('').reversed.toList();
    final out = <String>[];
    for (int i = 0; i < chars.length; i++) {
      if (i > 0 && i % 3 == 0) out.add(',');
      out.add(chars[i]);
    }
    final withCommas = out.reversed.join();
    return ' \$${withCommas}.$decimals'.replaceFirst('\u0000', '');
  }
}
