import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/di/service_locator.dart';
import '../../../banks/domain/entities/bank_entity.dart';

class EditBankPage extends StatefulWidget {
  final int? bankId;
  final String bankName;
  final String balance;

  const EditBankPage({
    super.key,
    this.bankId,
    required this.bankName,
    required this.balance,
  });

  @override
  State<EditBankPage> createState() => _EditBankPageState();
}

class _EditBankPageState extends State<EditBankPage> {
  late TextEditingController _nameController;
  late TextEditingController _balanceController;
  // Loaded entity to preserve non-edited fields
  dynamic _loadedBank;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.bankName);
    _balanceController = TextEditingController(
      text: widget.balance.replaceAll('\$', ''),
    );

    // Load latest entity if id is provided
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.bankId != null) {
        try {
          // Access repo via ServiceProvider
          final locator = ServiceProvider.of(context);
          final entity = await locator.bankRepository.getBankById(
            widget.bankId!,
          );
          if (entity != null && mounted) {
            setState(() {
              _loadedBank = entity;
              _nameController.text = entity.name;
              _balanceController.text = entity.balance.toStringAsFixed(0);
            });
          }
        } catch (e) {
          debugPrint('EditBank load error: $e');
        }
      }
    });
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

  Future<void> _onSave() async {
    // ANSI + emoji tags for visibility in VS Code terminal
    const red = '\x1B[31m';
    const green = '\x1B[32m';
    const yellow = '\x1B[33m';
    const reset = '\x1B[0m';

    final name = _nameController.text.trim();
    final raw = _balanceController.text.trim();
    final amount = double.tryParse(raw);

    if (name.isEmpty) {
      _showSnack('Please enter a bank/wallet name');
      return;
    }
    if (amount == null) {
      _showSnack('Please enter a valid amount');
      return;
    }

    try {
      final locator = ServiceProvider.of(context);
      final id = widget.bankId;

      print(
        '🟨 ${yellow}[DB] UPDATE_BANK_REQUEST id=$id name="$name" amount=$amount${reset}',
      );

      if (id == null) {
        await locator.bankRepository.addBank(
          BankEntity(
            id: null,
            name: name,
            accountNumber:
                (_loadedBank as BankEntity?)?.accountNumber ?? '0000',
            balance: amount.toDouble(),
            color: (_loadedBank as BankEntity?)?.color ?? '#A882FF',
            logoPath: (_loadedBank as BankEntity?)?.logoPath,
            serverId: (_loadedBank as BankEntity?)?.serverId,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            isDeleted: false,
          ),
        );
      } else {
        final base = _loadedBank as BankEntity?;
        final updated = BankEntity(
          id: id,
          name: name,
          accountNumber: base?.accountNumber ?? '0000',
          balance: amount.toDouble(),
          color: base?.color ?? '#A882FF',
          logoPath: base?.logoPath,
          serverId: base?.serverId,
          createdAt: base?.createdAt ?? DateTime.now(),
          updatedAt: DateTime.now(),
          isDeleted: base?.isDeleted ?? false,
        );
        await locator.bankRepository.updateBank(updated);
      }

      print('🟩 ${green}[DB] UPDATE_BANK_SUCCESS id=${widget.bankId}${reset}');
      if (mounted) Navigator.pop(context);
    } catch (e, st) {
      print('🟥 ${red}[DB] UPDATE_BANK_ERROR: $e${reset}');
      print('🟥 ${red}$st${reset}');
      _showSnack('Failed to save changes: $e');
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
