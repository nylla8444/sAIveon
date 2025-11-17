import 'package:flutter/material.dart';
import '../../../../core/widgets/index.dart';

class EditScheduledPaymentPage extends StatefulWidget {
  final String title;
  final String amount;
  final String status;
  final String date;
  final IconData icon;

  const EditScheduledPaymentPage({
    super.key,
    required this.title,
    required this.amount,
    required this.status,
    required this.date,
    required this.icon,
  });

  @override
  State<EditScheduledPaymentPage> createState() =>
      _EditScheduledPaymentPageState();
}

class _EditScheduledPaymentPageState extends State<EditScheduledPaymentPage> {
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late TextEditingController _dueDateController;
  late IconData _selectedIcon;

  final List<Map<String, dynamic>> _iconOptions = [
    {'icon': Icons.payment, 'label': 'Payment'},
    {'icon': Icons.directions_car, 'label': 'Car'},
    {'icon': Icons.wifi, 'label': 'Internet'},
    {'icon': Icons.home, 'label': 'Home'},
    {'icon': Icons.phone, 'label': 'Phone'},
    {'icon': Icons.electric_bolt, 'label': 'Electric'},
    {'icon': Icons.water_drop, 'label': 'Water'},
    {'icon': Icons.health_and_safety, 'label': 'Insurance'},
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.title);
    // Remove the $ and - from amount
    final cleanAmount = widget.amount.replaceAll(RegExp(r'[^\d.]'), '');
    _amountController = TextEditingController(text: cleanAmount);
    _dueDateController = TextEditingController(text: widget.date);
    _selectedIcon = widget.icon;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _dueDateController.dispose();
    super.dispose();
  }

  void _showIconPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF191919),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 300,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Icon',
                style: TextStyle(
                  color: Color(0xFFD6D6D6),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Manrope',
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                  ),
                  itemCount: _iconOptions.length,
                  itemBuilder: (context, index) {
                    final iconData = _iconOptions[index];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedIcon = iconData['icon'] as IconData;
                        });
                        Navigator.pop(context);
                      },
                      child: Column(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: _selectedIcon == iconData['icon']
                                  ? const Color(0xFFBA9BFF)
                                  : const Color(0xFF2A2A2A),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              iconData['icon'] as IconData,
                              color: const Color(0xFFD6D6D6),
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            iconData['label'] as String,
                            style: const TextStyle(
                              color: Color(0xFF949494),
                              fontSize: 10,
                              fontFamily: 'Manrope',
                            ),
                          ),
                        ],
                      ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with back button
                Row(
                  children: [
                    CustomBackButton(
                      size: 40,
                      backgroundColor: const Color(0xFF2A2A2A),
                      iconColor: const Color(0xFFFFFFFF),
                    ),
                    const SizedBox(width: 15),
                    const Text(
                      'Edit Payment',
                      style: TextStyle(
                        color: Color(0xFFFFFFFF),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // Icon selector
                const Text(
                  'Icon',
                  style: TextStyle(
                    color: Color(0xFFD6D6D6),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Manrope',
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: _showIconPicker,
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFF191919),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFD6D6D6).withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 15),
                        Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFFFFF),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _selectedIcon,
                            color: const Color(0xFF191919),
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Tap to change icon',
                          style: TextStyle(
                            color: Color(0xFF949494),
                            fontSize: 14,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.chevron_right,
                          color: Color(0xFF949494),
                          size: 20,
                        ),
                        const SizedBox(width: 15),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Payment Title
                const Text(
                  'Payment Title',
                  style: TextStyle(
                    color: Color(0xFFD6D6D6),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Manrope',
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFF191919),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFD6D6D6).withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: _titleController,
                    style: const TextStyle(
                      color: Color(0xFFD6D6D6),
                      fontSize: 14,
                      fontFamily: 'Poppins',
                    ),
                    decoration: const InputDecoration(
                      hintText: 'e.g., Car Insurance',
                      hintStyle: TextStyle(
                        color: Color(0xFF949494),
                        fontSize: 14,
                        fontFamily: 'Poppins',
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Amount
                const Text(
                  'Amount',
                  style: TextStyle(
                    color: Color(0xFFD6D6D6),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Manrope',
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFF191919),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFD6D6D6).withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 15),
                        child: Text(
                          '\$',
                          style: TextStyle(
                            color: Color(0xFFD6D6D6),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(
                            color: Color(0xFFD6D6D6),
                            fontSize: 14,
                            fontFamily: 'Poppins',
                          ),
                          decoration: const InputDecoration(
                            hintText: '0.00',
                            hintStyle: TextStyle(
                              color: Color(0xFF949494),
                              fontSize: 14,
                              fontFamily: 'Poppins',
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Due Date
                const Text(
                  'Due Date',
                  style: TextStyle(
                    color: Color(0xFFD6D6D6),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Manrope',
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () async {
                    final DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2030),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.dark(
                              primary: Color(0xFFBA9BFF),
                              onPrimary: Color(0xFF191919),
                              surface: Color(0xFF191919),
                              onSurface: Color(0xFFD6D6D6),
                            ),
                            dialogBackgroundColor: const Color(0xFF191919),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (pickedDate != null) {
                      setState(() {
                        // Format as "15 Dec"
                        final months = [
                          'Jan',
                          'Feb',
                          'Mar',
                          'Apr',
                          'May',
                          'Jun',
                          'Jul',
                          'Aug',
                          'Sep',
                          'Oct',
                          'Nov',
                          'Dec',
                        ];
                        _dueDateController.text =
                            '${pickedDate.day} ${months[pickedDate.month - 1]}';
                      });
                    }
                  },
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFF191919),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFD6D6D6).withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Text(
                              _dueDateController.text.isEmpty
                                  ? 'Select due date'
                                  : _dueDateController.text,
                              style: TextStyle(
                                color: _dueDateController.text.isEmpty
                                    ? const Color(0xFF949494)
                                    : const Color(0xFFD6D6D6),
                                fontSize: 14,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(right: 15),
                          child: Icon(
                            Icons.calendar_today,
                            color: Color(0xFF949494),
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Save button
                GestureDetector(
                  onTap: () {
                    // TODO: Save data when backend is ready
                    if (_titleController.text.isNotEmpty &&
                        _amountController.text.isNotEmpty &&
                        _dueDateController.text.isNotEmpty) {
                      // Show success message
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Payment updated! (Backend pending)'),
                          backgroundColor: Color(0xFFBA9BFF),
                        ),
                      );
                      // Pop twice to go back to main page
                      Navigator.pop(context);
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please fill all fields'),
                          backgroundColor: Color(0xFFFF8282),
                        ),
                      );
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFFBA9BFF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text(
                        'Save Changes',
                        style: TextStyle(
                          color: Color(0xFF191919),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Manrope',
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Delete button
                GestureDetector(
                  onTap: () {
                    // Show confirmation dialog
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor: const Color(0xFF191919),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          title: const Text(
                            'Delete Payment',
                            style: TextStyle(
                              color: Color(0xFFD6D6D6),
                              fontFamily: 'Manrope',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          content: const Text(
                            'Are you sure you want to delete this scheduled payment?',
                            style: TextStyle(
                              color: Color(0xFF949494),
                              fontFamily: 'Manrope',
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
                            TextButton(
                              onPressed: () {
                                // TODO: Delete from backend
                                Navigator.pop(context); // Close dialog
                                Navigator.pop(context); // Close edit page
                                Navigator.pop(context); // Close detail page
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Payment deleted! (Backend pending)',
                                    ),
                                    backgroundColor: Color(0xFFFF8282),
                                  ),
                                );
                              },
                              child: const Text(
                                'Delete',
                                style: TextStyle(
                                  color: Color(0xFFFF8282),
                                  fontFamily: 'Manrope',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFFF8282),
                        width: 2,
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'Delete Payment',
                        style: TextStyle(
                          color: Color(0xFFFF8282),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Manrope',
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
