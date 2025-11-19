import 'package:drift/drift.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../../../core/database/app_database.dart' as db;

class TransactionMapper {
  static TransactionEntity toDomain(db.Transaction transaction) {
    return TransactionEntity(
      id: transaction.id,
      type: transaction.type,
      amount: transaction.amount,
      name: transaction.name,
      iconPath: transaction.iconPath,
      status: transaction.status,
      statusColor: transaction.statusColor,
      bankId: transaction.bankId,
      toBankId: transaction.toBankId,
      date: transaction.date,
      serverId: transaction.serverId,
      createdAt: transaction.createdAt,
      updatedAt: transaction.updatedAt,
      isDeleted: transaction.isDeleted,
    );
  }

  static db.TransactionsCompanion toCompanion(TransactionEntity entity) {
    return db.TransactionsCompanion(
      id: entity.id != null ? Value(entity.id!) : const Value.absent(),
      type: Value(entity.type),
      amount: Value(entity.amount),
      name: Value(entity.name),
      iconPath: Value(entity.iconPath),
      status: Value(entity.status),
      statusColor: Value(entity.statusColor),
      bankId: Value(entity.bankId),
      toBankId: Value(entity.toBankId),
      date: Value(entity.date),
      serverId: Value(entity.serverId),
      createdAt: entity.createdAt != null
          ? Value(entity.createdAt!)
          : Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
      isDeleted: Value(entity.isDeleted),
    );
  }

  static List<TransactionEntity> toDomainList(
    List<db.Transaction> transactions,
  ) {
    return transactions.map((t) => toDomain(t)).toList();
  }
}
