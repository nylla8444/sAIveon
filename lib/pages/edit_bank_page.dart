import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EditBankPage extends StatefulWidget {
  final String bankName;
  final String balance;

  const EditBankPage({
    super.key,
    required this.bankName,
    required this.balance,
  });

  @override
  State<EditBankPage> createState() => _EditBankPageState();
}

class _EditBankPageState extends State<EditBankPage> {
  late TextEditingController _nameController;
  late TextEditingController _balanceController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.bankName);
    // Remove the $ symbol from balance for editing
    _balanceController = TextEditingController(
      text: widget.balance.replaceAll('\$', ''),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
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
                        'Edit Bank/Wallet',
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

                      // Balance Field
                      _buildBalanceField(),

                      const SizedBox(height: 25),

                      // Save button
                      GestureDetector(
                        onTap: () {
                          // TODO: Save the updated bank data
                          print(
                            'Save bank: ${_nameController.text}, \$${_balanceController.text}',
                          );
                          Navigator.pop(context);
                        },
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
            border: Border.all(
              color: const Color(0xFFBA9BFF).withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: TextField(
            controller: _nameController,
            style: const TextStyle(
              fontFamily: 'Manrope',
              color: Color(0xFFD6D6D6),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: 'e.g. BDO, GCash, Maya',
              hintStyle: const TextStyle(
                fontFamily: 'Manrope',
                color: Color(0xFF666666),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              suffixIcon: const Icon(
                Icons.edit,
                color: Color(0xFFBA9BFF),
                size: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceField() {
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
            border: Border.all(
              color: const Color(0xFFBA9BFF).withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: TextField(
            controller: _balanceController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(
              fontFamily: 'Manrope',
              color: Color(0xFFD6D6D6),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: '\$0',
              hintStyle: const TextStyle(
                fontFamily: 'Manrope',
                color: Color(0xFF666666),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              prefixText: '\$ ',
              prefixStyle: const TextStyle(
                fontFamily: 'Manrope',
                color: Color(0xFFD6D6D6),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              suffixIcon: const Icon(
                Icons.edit,
                color: Color(0xFFBA9BFF),
                size: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
