import 'dart:async';
import '../../features/notifications/domain/entities/notification_entity.dart';
import '../../features/notifications/domain/repositories/notification_repository.dart';
import '../../features/scheduled_payments/domain/entities/scheduled_payment_entity.dart';
import '../../features/scheduled_payments/domain/repositories/scheduled_payment_repository.dart';

/// Service to check scheduled payments and create notifications for payments due tomorrow
class ScheduledPaymentNotificationService {
  final IScheduledPaymentRepository _scheduledPaymentRepository;
  final INotificationRepository _notificationRepository;
  Timer? _dailyCheckTimer;
  StreamSubscription? _paymentsSubscription;

  ScheduledPaymentNotificationService(
    this._scheduledPaymentRepository,
    this._notificationRepository,
  );

  /// Initialize the service and start daily checks
  void initialize() {
    print('  → Initializing Scheduled Payment Notification Service...');

    // Run initial check
    _checkUpcomingPayments();

    // Schedule daily checks at midnight (or every 24 hours from now)
    _scheduleDailyCheck();

    print('  ✓ Scheduled Payment Notification Service initialized');
  }

  /// Schedule a timer to run daily checks
  void _scheduleDailyCheck() {
    // Calculate time until next midnight
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final durationUntilMidnight = tomorrow.difference(now);

    // Schedule first check at midnight
    Future.delayed(durationUntilMidnight, () {
      _checkUpcomingPayments();

      // Then check every 24 hours
      _dailyCheckTimer = Timer.periodic(
        const Duration(hours: 24),
        (_) => _checkUpcomingPayments(),
      );
    });
  }

  /// Check for payments due tomorrow and create notifications
  Future<void> _checkUpcomingPayments() async {
    try {
      print('  [Scheduler] Checking for upcoming scheduled payments...');

      // Get all scheduled payments
      final paymentsStream = _scheduledPaymentRepository
          .watchAllScheduledPayments();

      // Listen to the stream once to get current data
      _paymentsSubscription?.cancel();
      final payments = await paymentsStream.first;

      final now = DateTime.now();
      final tomorrow = DateTime(now.year, now.month, now.day + 1);

      for (final payment in payments) {
        // Check if payment is due tomorrow
        if (_isDueTomorrow(payment.nextPaymentDate, tomorrow)) {
          await _createPaymentReminder(payment);
        }
      }

      print('  [Scheduler] Finished checking payments');
    } catch (e) {
      print('  [Scheduler] Error in _checkUpcomingPayments: $e');
    }
  }

  /// Check if a date is tomorrow
  bool _isDueTomorrow(DateTime paymentDate, DateTime tomorrow) {
    final paymentDay = DateTime(
      paymentDate.year,
      paymentDate.month,
      paymentDate.day,
    );

    return paymentDay.year == tomorrow.year &&
        paymentDay.month == tomorrow.month &&
        paymentDay.day == tomorrow.day;
  }

  /// Create a notification reminder for a scheduled payment
  Future<void> _createPaymentReminder(ScheduledPaymentEntity payment) async {
    try {
      final notification = NotificationEntity(
        title: 'Payment Reminder',
        message:
            '${payment.name} of \$${payment.amount.toStringAsFixed(2)} is due tomorrow!',
        timestamp: DateTime.now(),
        isRead: false,
        type: 'payment_reminder',
      );

      await _notificationRepository.addNotification(notification);
      print('  [Scheduler] Created notification for payment: ${payment.name}');
    } catch (e) {
      print('  [Scheduler] Error creating notification: $e');
    }
  }

  /// Manually trigger a check (useful for testing)
  Future<void> checkNow() async {
    await _checkUpcomingPayments();
  }

  /// Dispose of resources
  void dispose() {
    _dailyCheckTimer?.cancel();
    _paymentsSubscription?.cancel();
    print('  [Scheduler] Scheduled Payment Notification Service disposed');
  }
}
