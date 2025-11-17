import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  String? _selectedAccount;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedCategory;

  // Available options
  final List<String> _accounts = ['Bank A', 'Bank B', 'Bank C', 'Bank D'];
  final List<String> _categories = [
    'Groceries',
    'Shopping',
    'Food',
    'Transportation',
    'Entertainment',
    'Bills',
    'Salary',
    'Investment',
    'Other',
  ];

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

                      const SizedBox(height: 7),

                      _buildDateTimeField(),

                      const SizedBox(height: 7),

                      _buildCategoryField(),

                      const SizedBox(height: 27),

                      // Save button
                      GestureDetector(
                        onTap: () {
                          // TODO: Save transaction
                          print('Save transaction');
                          Navigator.pop(context);
                        },
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
    return GestureDetector(
      onTap: () => _showAccountPicker(),
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
                _selectedAccount ?? 'Account',
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
  void _showAccountPicker() {
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
              'Select Account',
              style: TextStyle(
                fontFamily: 'Manrope',
                color: Color(0xFFD6D6D6),
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 20),
            ..._accounts.map(
              (account) => ListTile(
                title: Text(
                  account,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    color: Color(0xFFD6D6D6),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  setState(() => _selectedAccount = account);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
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
                children: _categories
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
}
