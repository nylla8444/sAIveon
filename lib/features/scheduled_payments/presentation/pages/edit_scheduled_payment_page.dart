import 'package:flutter/material.dart';
import '../../../../core/widgets/index.dart';
import '../../../../core/di/service_locator.dart';
import '../../domain/entities/scheduled_payment_entity.dart';

class EditScheduledPaymentPage extends StatefulWidget {
  final int paymentId;

  const EditScheduledPaymentPage({super.key, required this.paymentId});

  @override
  State<EditScheduledPaymentPage> createState() =>
      _EditScheduledPaymentPageState();
}

class _EditScheduledPaymentPageState extends State<EditScheduledPaymentPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dueDateController = TextEditingController();
  IconData _selectedIcon = Icons.payment;
  DateTime? _selectedDate;
  String _selectedFrequency = 'once';
  ScheduledPaymentEntity? _payment;
  bool _isLoading = true;

  final List<Map<String, dynamic>> _frequencyOptions = [
    {'value': 'once', 'label': 'One Time'},
    {'value': 'weekly', 'label': 'Weekly'},
    {'value': 'monthly', 'label': 'Monthly'},
    {'value': 'yearly', 'label': 'Yearly'},
  ];

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
    // Use WidgetsBinding to ensure context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPaymentData();
    });
  }

  Future<void> _loadPaymentData() async {
    try {
      final repository = ServiceProvider.of(context).scheduledPaymentRepository;
      final payment = await repository.getScheduledPaymentById(
        widget.paymentId,
      );

      if (payment != null && mounted) {
        setState(() {
          _payment = payment;
          _titleController.text = payment.name;
          _amountController.text = payment.amount.toStringAsFixed(2);
          _selectedDate = payment.nextPaymentDate;
          _selectedFrequency = payment.frequency;

          // Format date display
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
              '${payment.nextPaymentDate.day} ${months[payment.nextPaymentDate.month - 1]}';

          // Set icon based on name
          _selectedIcon = _getIconFromName(payment.name);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading payment: $e'),
            backgroundColor: const Color(0xFFFF8282),
          ),
        );
      }
    }
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

                // Frequency
                const Text(
                  'Frequency',
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
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedFrequency,
                      isExpanded: true,
                      dropdownColor: const Color(0xFF191919),
                      icon: const Padding(
                        padding: EdgeInsets.only(right: 15),
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          color: Color(0xFF949494),
                        ),
                      ),
                      style: const TextStyle(
                        color: Color(0xFFD6D6D6),
                        fontSize: 14,
                        fontFamily: 'Poppins',
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      items: _frequencyOptions.map((option) {
                        return DropdownMenuItem<String>(
                          value: option['value'] as String,
                          child: Text(option['label'] as String),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedFrequency = newValue;
                          });
                        }
                      },
                    ),
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
                        _selectedDate = pickedDate;
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
                  onTap: () async {
                    if (_titleController.text.isNotEmpty &&
                        _amountController.text.isNotEmpty &&
                        _selectedDate != null) {
                      try {
                        final repository = ServiceProvider.of(
                          context,
                        ).scheduledPaymentRepository;

                        final updatedPayment = _payment!.copyWith(
                          name: _titleController.text,
                          amount: double.parse(_amountController.text),
                          frequency: _selectedFrequency,
                          nextPaymentDate: _selectedDate,
                        );

                        await repository.updateScheduledPayment(updatedPayment);

                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Payment updated successfully!'),
                              backgroundColor: Color(0xFFBA9BFF),
                            ),
                          );
                          Navigator.pop(
                            context,
                            true,
                          ); // Return true to indicate success
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error updating payment: $e'),
                              backgroundColor: const Color(0xFFFF8282),
                            ),
                          );
                        }
                      }
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
                              onPressed: () async {
                                try {
                                  final repository = ServiceProvider.of(
                                    context,
                                  ).scheduledPaymentRepository;
                                  await repository.deleteScheduledPayment(
                                    _payment!.id!,
                                  );

                                  if (mounted) {
                                    Navigator.pop(context); // Close dialog
                                    Navigator.pop(context); // Close edit page
                                    Navigator.pop(context); // Close detail page
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Payment deleted successfully!',
                                        ),
                                        backgroundColor: Color(0xFFFF8282),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    Navigator.pop(context); // Close dialog
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Error deleting payment: $e',
                                        ),
                                        backgroundColor: const Color(
                                          0xFFFF8282,
                                        ),
                                      ),
                                    );
                                  }
                                }
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
