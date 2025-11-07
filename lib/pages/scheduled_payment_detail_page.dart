import 'package:flutter/material.dart';
import 'edit_scheduled_payment_page.dart';
import '../widgets/custom_back_button.dart';

class ScheduledPaymentDetailPage extends StatelessWidget {
  final String title;
  final String amount;
  final String status;
  final String date;
  final IconData icon;

  const ScheduledPaymentDetailPage({
    super.key,
    required this.title,
    required this.amount,
    required this.status,
    required this.date,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
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

              // Payment card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 31),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditScheduledPaymentPage(
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

              // Transaction cards
              _buildTransactionCard(
                date: '09 October 2025',
                description: 'Paid October 09, 2025',
                time: '06:40PM',
                amount: '-\$15',
              ),
              const SizedBox(height: 16),
              _buildTransactionCard(
                date: '05 October 2025',
                description: 'Paid October 05, 2025',
                time: '06:40PM',
                amount: '-\$15',
              ),
              const SizedBox(height: 16),
              _buildTransactionCard(
                date: '01 October 2025',
                description: 'Paid October 01, 2025',
                time: '06:40PM',
                amount: '-\$15',
              ),

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

            // Description
            Positioned(
              left: 51,
              top: 47,
              child: Text(
                description,
                style: const TextStyle(
                  color: Color(0xFFE6E6E6),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Manrope',
                  height: 1.366,
                ),
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
