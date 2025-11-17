import 'package:drift/drift.dart';
import '../../domain/entities/expense_entity.dart';
import '../../../../core/database/app_database.dart';

class ExpenseMapper {
  static ExpenseEntity toDomain(Expense expense) {
    return ExpenseEntity(
      id: expense.id,
      category: expense.category,
      amount: expense.amount,
      iconPath: expense.iconPath,
      iconColor: expense.iconColor,
      bankId: expense.bankId,
      description: expense.description,
      date: expense.date,
      serverId: expense.serverId,
      createdAt: expense.createdAt,
      updatedAt: expense.updatedAt,
      isDeleted: expense.isDeleted,
    );
  }

  static ExpensesCompanion toCompanion(ExpenseEntity entity) {
    return ExpensesCompanion(
      id: entity.id != null ? Value(entity.id!) : const Value.absent(),
      category: Value(entity.category),
      amount: Value(entity.amount),
      iconPath: Value(entity.iconPath),
      iconColor: Value(entity.iconColor),
      bankId: Value(entity.bankId),
      description: Value(entity.description),
      date: Value(entity.date),
      serverId: Value(entity.serverId),
      createdAt: entity.createdAt != null
          ? Value(entity.createdAt!)
          : Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
      isDeleted: Value(entity.isDeleted),
    );
  }

  static List<ExpenseEntity> toDomainList(List<Expense> expenses) {
    return expenses.map((e) => toDomain(e)).toList();
  }
}
