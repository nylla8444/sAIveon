import '../entities/scheduled_payment_entity.dart';

abstract class IScheduledPaymentRepository {
  /// Watch all scheduled payments as a stream
  Stream<List<ScheduledPaymentEntity>> watchAllScheduledPayments();

  /// Get upcoming payments within the next X days
  Future<List<ScheduledPaymentEntity>> getUpcomingPayments(int daysAhead);

  /// Get a scheduled payment by ID
  Future<ScheduledPaymentEntity?> getScheduledPaymentById(int id);

  /// Add a new scheduled payment
  Future<int> addScheduledPayment(ScheduledPaymentEntity payment);

  /// Update an existing scheduled payment
  Future<void> updateScheduledPayment(ScheduledPaymentEntity payment);

  /// Delete a scheduled payment (soft delete)
  Future<void> deleteScheduledPayment(int id);
}
