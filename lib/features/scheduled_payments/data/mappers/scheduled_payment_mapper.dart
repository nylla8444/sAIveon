import 'package:drift/drift.dart';
import '../../domain/entities/scheduled_payment_entity.dart';
import '../../../../core/database/app_database.dart';

class ScheduledPaymentMapper {
  static ScheduledPaymentEntity toDomain(ScheduledPayment payment) {
    return ScheduledPaymentEntity(
      id: payment.id,
      name: payment.name,
      amount: payment.amount,
      frequency: payment.frequency,
      nextPaymentDate: payment.nextPaymentDate,
      expenseId: payment.expenseId,
      bankId: payment.bankId,
      serverId: payment.serverId,
      createdAt: payment.createdAt,
      updatedAt: payment.updatedAt,
      isDeleted: payment.isDeleted,
    );
  }

  static ScheduledPaymentsCompanion toCompanion(ScheduledPaymentEntity entity) {
    return ScheduledPaymentsCompanion(
      id: entity.id != null ? Value(entity.id!) : const Value.absent(),
      name: Value(entity.name),
      amount: Value(entity.amount),
      frequency: Value(entity.frequency),
      nextPaymentDate: Value(entity.nextPaymentDate),
      expenseId: Value(entity.expenseId),
      bankId: Value(entity.bankId),
      serverId: Value(entity.serverId),
      createdAt: entity.createdAt != null
          ? Value(entity.createdAt!)
          : Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
      isDeleted: Value(entity.isDeleted),
    );
  }

  static List<ScheduledPaymentEntity> toDomainList(
    List<ScheduledPayment> payments,
  ) {
    return payments.map((p) => toDomain(p)).toList();
  }
}
