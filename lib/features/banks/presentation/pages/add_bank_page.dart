import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/di/service_locator.dart';
import '../../../banks/domain/entities/bank_entity.dart';

class AddBankPage extends StatefulWidget {
  const AddBankPage({super.key});

  @override
  State<AddBankPage> createState() => _AddBankPageState();
}

class _AddBankPageState extends State<AddBankPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
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
                // Return button
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

                const SizedBox(height: 30),

                // Main card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: const Color(0xFF101010),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      const Text(
                        'Add Bank/Wallet',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          color: Color(0xFFD6D6D6),
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          height: 1.366,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Bank/Wallet Name Field
                      _buildNameField(),

                      const SizedBox(height: 15),

                      // Amount Field
                      _buildAmountField(),

                      const SizedBox(height: 25),

                      // Save button
                      GestureDetector(
                        onTap: _onSave,
                        child: Container(
                          width: double.infinity,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFFBA9BFF),
                            borderRadius: BorderRadius.circular(12),
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

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bank/Wallet Name',
          style: TextStyle(
            fontFamily: 'Manrope',
            color: Color(0xFFD6D6D6),
            fontSize: 13,
            fontWeight: FontWeight.w600,
            height: 1.366,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF191919),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _nameController,
            style: const TextStyle(
              fontFamily: 'Manrope',
              color: Color(0xFFD6D6D6),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            decoration: const InputDecoration(
              hintText: 'e.g. BDO, GCash, Maya',
              hintStyle: TextStyle(
                fontFamily: 'Manrope',
                color: Color(0xFF666666),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAmountField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Current Balance',
          style: TextStyle(
            fontFamily: 'Manrope',
            color: Color(0xFFD6D6D6),
            fontSize: 13,
            fontWeight: FontWeight.w600,
            height: 1.366,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF191919),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(
              fontFamily: 'Manrope',
              color: Color(0xFFD6D6D6),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            decoration: const InputDecoration(
              hintText: '\$0',
              hintStyle: TextStyle(
                fontFamily: 'Manrope',
                color: Color(0xFF666666),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 14),
              prefixText: '\$ ',
              prefixStyle: TextStyle(
                fontFamily: 'Manrope',
                color: Color(0xFFD6D6D6),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _onSave() async {
    final name = _nameController.text.trim();
    final raw = _amountController.text.trim();
    if (name.isEmpty) {
      _showSnack('Please enter a bank/wallet name');
      return;
    }
    final amount = double.tryParse(raw);
    if (amount == null) {
      _showSnack('Please enter a valid amount');
      return;
    }

    // ANSI colors for terminal logs
    const red = '\x1B[31m';
    const green = '\x1B[32m';
    const yellow = '\x1B[33m';
    const reset = '\x1B[0m';

    try {
      print(
        '${yellow}[DB] ADD_BANK_REQUEST name="$name" amount=$amount${reset}',
      );

      final locator = ServiceProvider.of(context);
      await locator.bankRepository.addBank(
        BankEntity(
          id: null,
          name: name,
          // Provide a non-empty placeholder to satisfy DB constraint (min length 1)
          accountNumber: '0000',
          balance: amount.toDouble(),
          color: '#A882FF',
          logoPath: null,
          serverId: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isDeleted: false,
        ),
      );

      print('${green}[DB] ADD_BANK_SUCCESS name="$name"${reset}');
      Navigator.pop(context);
    } catch (e, st) {
      print('${red}[DB] ADD_BANK_ERROR: $e${reset}');
      print('${red}$st${reset}');
      _showSnack('Failed to save bank: $e');
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
