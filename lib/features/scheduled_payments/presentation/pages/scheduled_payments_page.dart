import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'scheduled_payment_detail_page.dart';
import 'add_scheduled_payment_page.dart';
import '../../../../core/widgets/index.dart';
import '../../../../core/di/service_locator.dart';
import '../../domain/entities/scheduled_payment_entity.dart';

class ScheduledPaymentsPage extends StatefulWidget {
  const ScheduledPaymentsPage({super.key});

  @override
  State<ScheduledPaymentsPage> createState() => _ScheduledPaymentsPageState();
}

class _ScheduledPaymentsPageState extends State<ScheduledPaymentsPage> {
  String _selectedFilter = 'All'; // All, Active, Overdue
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  IconData _getIconFromName(String name) {
    final nameLower = name.toLowerCase();
    if (nameLower.contains('car') || nameLower.contains('vehicle')) {
      return Icons.directions_car;
    } else if (nameLower.contains('internet') || nameLower.contains('wifi')) {
      return Icons.wifi;
    } else if (nameLower.contains('home') || nameLower.contains('rent') || nameLower.contains('house')) {
      return Icons.home;
    } else if (nameLower.contains('phone') || nameLower.contains('mobile')) {
      return Icons.phone;
    } else if (nameLower.contains('electric') || nameLower.contains('power')) {
      return Icons.electric_bolt;
    } else if (nameLower.contains('water')) {
      return Icons.water_drop;
    } else if (nameLower.contains('insurance') || nameLower.contains('health')) {
      return Icons.health_and_safety;
    } else {
      return Icons.payment;
    }
  }

  String _getStatusText(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(DateTime(now.year, now.month, now.day)).inDays;
    
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

  bool _isOverdue(DateTime dueDate) {
    final now = DateTime.now();
    return dueDate.isBefore(DateTime(now.year, now.month, now.day));
  }

  List<ScheduledPaymentEntity> _filterPayments(List<ScheduledPaymentEntity> payments) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return payments.where((payment) {
      if (_selectedFilter == 'All') {
        return true;
      } else if (_selectedFilter == 'Active') {
        return payment.nextPaymentDate.isAfter(today) ||
            payment.nextPaymentDate.isAtSameMomentAs(today);
      } else if (_selectedFilter == 'Overdue') {
        return payment.nextPaymentDate.isBefore(today);
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final scheduledPaymentRepository = ServiceProvider.of(context).scheduledPaymentRepository;

    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: SafeArea(
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
                  const Text(
                    'Scheduled Payments',
                    style: TextStyle(
                      color: Color(0xFFFFFFFF),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 19),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF191919),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFFFFFFF).withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(
                    color: Color(0xFF949494),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                    height: 1.5,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Super AI Search',
                    hintStyle: const TextStyle(
                      color: Color(0xFF949494),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                      height: 1.5,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xFF949494),
                      size: 16,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 19),

            // Filter tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Row(
                children: [
                  _buildFilterTab('All'),
                  const SizedBox(width: 47),
                  _buildFilterTab('Active'),
                  const SizedBox(width: 47),
                  _buildFilterTab('Overdue'),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Payments list
            Expanded(
              child: StreamBuilder(
                stream: scheduledPaymentRepository.watchAllScheduledPayments(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFBA9BFF),
                      ),
                    );
                  }

                  final allPayments = snapshot.data ?? [];
                  final activePayments = allPayments
                      .where((p) => !p.isDeleted)
                      .toList()
                    ..sort((a, b) => a.nextPaymentDate.compareTo(b.nextPaymentDate));
                  
                  final filteredPayments = _filterPayments(activePayments);

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: Column(
                      children: [
                        const SizedBox(height: 9),
                        if (filteredPayments.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(40),
                            child: Text(
                              _selectedFilter == 'All'
                                  ? 'No scheduled payments yet'
                                  : 'No ${_selectedFilter.toLowerCase()} payments',
                              style: const TextStyle(
                                color: Color(0xFF949494),
                                fontSize: 14,
                                fontFamily: 'Manrope',
                              ),
                            ),
                          )
                        else
                          ...filteredPayments.map((payment) {
                            return Column(
                              children: [
                                _buildPaymentCard(
                                  paymentId: payment.id!,
                                  title: payment.name,
                                  amount: '-\$${payment.amount.toStringAsFixed(0)}',
                                  status: _getStatusText(payment.nextPaymentDate),
                                  date: DateFormat('d MMM').format(payment.nextPaymentDate),
                                  isOverdue: _isOverdue(payment.nextPaymentDate),
                                  icon: _getIconFromName(payment.name),
                                ),
                                const SizedBox(height: 9),
                              ],
                            );
                          }),
                        _buildAddNewCard(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTab(String title) {
    final isSelected = _selectedFilter == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = title;
        });
      },
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: isSelected
                  ? const Color(0xFFA47FFA)
                  : const Color(0xFFD6D6D6),
              fontSize: 12,
              fontWeight: FontWeight.w800,
              fontFamily: 'Manrope',
              height: 1.366,
            ),
          ),
          const SizedBox(height: 6),
          if (isSelected)
            Container(
              width: title == 'All' ? 16 : (title == 'Active' ? 38 : 51),
              height: 1,
              color: const Color(0xFFA47FFA),
            ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard({
    required int paymentId,
    required String title,
    required String amount,
    required String status,
    required String date,
    required bool isOverdue,
    required IconData icon,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ScheduledPaymentDetailPage(
              paymentId: paymentId,
            ),
          ),
        );
      },
      child: Container(
        height: 67,
        decoration: BoxDecoration(
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
                child: Icon(icon, color: const Color(0xFF191919), size: 14),
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
              right: 30,
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
                  color: isOverdue
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
              right: 30,
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
              top: 22,
              child: Icon(
                Icons.chevron_right,
                color: Color(0xFFD6D6D6),
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddNewCard() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AddScheduledPaymentPage(),
          ),
        );
      },
      child: Container(
        height: 67,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFD6D6D6).withOpacity(0.4),
            width: 2,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: Stack(
          children: [
            // Plus icon
            Positioned(
              left: 51,
              top: 21,
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFD6D6D6).withOpacity(0.6),
                    width: 2,
                    strokeAlign: BorderSide.strokeAlignInside,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.add,
                    color: const Color(0xFFD6D6D6).withOpacity(0.6),
                    size: 16,
                  ),
                ),
              ),
            ),

            // Text
            const Positioned(
              left: 85,
              top: 26,
              child: Text(
                'Add new',
                style: TextStyle(
                  color: Color(0xFFD6D6D6),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Manrope',
                  height: 1.366,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
