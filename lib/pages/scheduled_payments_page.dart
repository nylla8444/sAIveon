import 'package:flutter/material.dart';
import 'scheduled_payment_detail_page.dart';
import 'add_scheduled_payment_page.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with back button
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 16, 15, 0),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Row(
                  children: [
                    Icon(
                      Icons.chevron_left,
                      color: Color(0xFFD6D6D6),
                      size: 20,
                    ),
                    SizedBox(width: 5),
                    Text(
                      'Scheduled Payments',
                      style: TextStyle(
                        color: Color(0xFFD6D6D6),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Manrope',
                        height: 1.366,
                      ),
                    ),
                  ],
                ),
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Column(
                  children: [
                    const SizedBox(height: 9),
                    _buildPaymentCard(
                      title: 'Car Insurance',
                      amount: '-\$65',
                      status: 'Due date in 15 days',
                      date: '12 Oct',
                      isOverdue: false,
                      icon: Icons.directions_car,
                    ),
                    const SizedBox(height: 9),
                    _buildPaymentCard(
                      title: 'Internet',
                      amount: '-\$35',
                      status: 'Overdue',
                      date: '10 Oct',
                      isOverdue: true,
                      icon: Icons.wifi,
                    ),
                    const SizedBox(height: 9),
                    _buildPaymentCard(
                      title: 'Home Service Fee',
                      amount: '-\$35',
                      status: 'Overdue',
                      date: '10 Oct',
                      isOverdue: true,
                      icon: Icons.home,
                    ),
                    const SizedBox(height: 9),
                    _buildAddNewCard(),
                    const SizedBox(height: 20),
                  ],
                ),
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
              title: title,
              amount: amount,
              status: status,
              date: date,
              icon: icon,
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
