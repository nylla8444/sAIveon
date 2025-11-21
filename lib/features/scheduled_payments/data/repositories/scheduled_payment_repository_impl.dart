import '../../domain/entities/scheduled_payment_entity.dart';
import '../../domain/repositories/scheduled_payment_repository.dart';
import '../../../../core/database/app_database.dart';
import '../mappers/scheduled_payment_mapper.dart';

class ScheduledPaymentRepositoryImpl implements IScheduledPaymentRepository {
  final AppDatabase _database;

  ScheduledPaymentRepositoryImpl(this._database);

  @override
  Stream<List<ScheduledPaymentEntity>> watchAllScheduledPayments() {
    return _database.watchAllScheduledPayments().map(
      ScheduledPaymentMapper.toDomainList,
    );
  }

  @override
  Future<List<ScheduledPaymentEntity>> getUpcomingPayments(
    int daysAhead,
  ) async {
    final payments = await _database.getUpcomingPayments(daysAhead);
    return ScheduledPaymentMapper.toDomainList(payments);
  }

  @override
  Future<ScheduledPaymentEntity?> getScheduledPaymentById(int id) async {
    final payment = await _database.getScheduledPaymentById(id);
    return payment != null ? ScheduledPaymentMapper.toDomain(payment) : null;
  }

  @override
  Future<int> addScheduledPayment(ScheduledPaymentEntity payment) async {
    final companion = ScheduledPaymentMapper.toCompanion(payment);
    return await _database.insertScheduledPayment(companion);
  }

  @override
  Future<void> updateScheduledPayment(ScheduledPaymentEntity payment) async {
    final companion = ScheduledPaymentMapper.toCompanion(payment);
    await _database.updateScheduledPayment(companion);
  }

  @override
  Future<void> deleteScheduledPayment(int id) async {
    await _database.softDeleteScheduledPayment(id);
  }
}
