import 'package:drift/drift.dart';
import '../../domain/entities/bank_entity.dart';
import '../../../../core/database/app_database.dart';

class BankMapper {
  /// Convert Drift Bank model to domain BankEntity
  static BankEntity toDomain(Bank bank) {
    return BankEntity(
      id: bank.id,
      name: bank.name,
      accountNumber: bank.accountNumber,
      balance: bank.balance,
      color: bank.color,
      logoPath: bank.logoPath,
      serverId: bank.serverId,
      createdAt: bank.createdAt,
      updatedAt: bank.updatedAt,
      isDeleted: bank.isDeleted,
    );
  }

  /// Convert domain BankEntity to Drift BanksCompanion (for insert/update)
  static BanksCompanion toCompanion(BankEntity entity) {
    return BanksCompanion(
      id: entity.id != null ? Value(entity.id!) : const Value.absent(),
      name: Value(entity.name),
      accountNumber: Value(entity.accountNumber),
      balance: Value(entity.balance),
      color: Value(entity.color),
      logoPath: Value(entity.logoPath),
      serverId: Value(entity.serverId),
      createdAt: entity.createdAt != null
          ? Value(entity.createdAt!)
          : Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
      isDeleted: Value(entity.isDeleted),
    );
  }

  /// Convert list of Drift Bank models to list of domain BankEntities
  static List<BankEntity> toDomainList(List<Bank> banks) {
    return banks.map((bank) => toDomain(bank)).toList();
  }
}
