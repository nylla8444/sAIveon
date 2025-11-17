import 'package:flutter/material.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final List<NotificationData> _notifications = [
    NotificationData(
      title: 'Budget Alert',
      time: 'Today | 8:30 PM',
      message: 'You have exceeded 90% of your monthly budget.',
      icon: Icons.notifications_active,
      isUnread: true,
    ),
    NotificationData(
      title: 'New Transaction',
      time: 'Today | 7:24 AM',
      message: 'You received a payment of \$50.',
      icon: Icons.payment,
      isUnread: true,
    ),
    NotificationData(
      title: 'Expense Alert',
      time: '1 day ago | 2:30 PM',
      message: 'Your grocery expense was higher than usual.',
      icon: Icons.warning_amber,
      isUnread: false,
    ),
    NotificationData(
      title: 'Bill Reminder',
      time: '2 days ago | 10:12 AM',
      message: 'Don\'t forget to pay your electricity bill!',
      icon: Icons.receipt_long,
      isUnread: false,
    ),
  ];

  void _markAllAsRead() {
    setState(() {
      for (var notification in _notifications) {
        notification.isUnread = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with back button and mark all as read
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button with text
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Row(
                      children: const [
                        Icon(
                          Icons.arrow_back_ios,
                          color: Color(0xFFD6D6D6),
                          size: 12,
                        ),
                        Text(
                          ' Notifications',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            color: Color(0xFFD6D6D6),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            height: 1.366,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Mark all as read
                  GestureDetector(
                    onTap: _markAllAsRead,
                    child: const Text(
                      'Mark all as read',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        color: Color(0xFFBA9BFF),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        height: 1.366,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Notifications list
              Expanded(
                child: ListView.separated(
                  itemCount: _notifications.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    return _buildNotificationCard(_notifications[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(NotificationData notification) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF191919),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFD6D6D6).withOpacity(0.05),
          width: 2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon container
          Container(
            width: 31,
            height: 31,
            decoration: BoxDecoration(
              color: const Color(0xFF101010),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              notification.icon,
              color: const Color(0xFFFFFFFF),
              size: 18,
            ),
          ),

          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and time
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          color: Color(0xFFD6D6D6),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          height: 1.366,
                        ),
                      ),
                    ),
                    if (notification.isUnread)
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(left: 8, top: 5),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF8282),
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 4),

                // Time
                Text(
                  notification.time,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    color: const Color(0xFFADACAC),
                    fontSize: 8,
                    fontWeight: notification.isUnread
                        ? FontWeight.w500
                        : FontWeight.w400,
                    height: 1.366,
                  ),
                ),

                const SizedBox(height: 11),

                // Message
                Text(
                  notification.message,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    color: Color(0xFFADACAC),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    height: 1.366,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NotificationData {
  final String title;
  final String time;
  final String message;
  final IconData icon;
  bool isUnread;

  NotificationData({
    required this.title,
    required this.time,
    required this.message,
    required this.icon,
    this.isUnread = false,
  });
}
