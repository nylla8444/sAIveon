import 'package:drift/drift.dart';
import '../../domain/entities/budget_entity.dart';
import '../../../../core/database/app_database.dart';

class BudgetMapper {
  static BudgetEntity toDomain(Budget budget) {
    return BudgetEntity(
      id: budget.id,
      category: budget.category,
      budgetAmount: budget.budgetAmount,
      spentAmount: budget.spentAmount,
      month: budget.month,
      year: budget.year,
      iconColor: budget.iconColor,
      serverId: budget.serverId,
      createdAt: budget.createdAt,
      updatedAt: budget.updatedAt,
      isDeleted: budget.isDeleted,
    );
  }

  static BudgetsCompanion toCompanion(BudgetEntity entity) {
    return BudgetsCompanion(
      id: entity.id != null ? Value(entity.id!) : const Value.absent(),
      category: Value(entity.category),
      budgetAmount: Value(entity.budgetAmount),
      spentAmount: Value(entity.spentAmount),
      month: Value(entity.month),
      year: Value(entity.year),
      iconColor: Value(entity.iconColor),
      serverId: Value(entity.serverId),
      createdAt: entity.createdAt != null
          ? Value(entity.createdAt!)
          : Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
      isDeleted: Value(entity.isDeleted),
    );
  }

  static List<BudgetEntity> toDomainList(List<Budget> budgets) {
    return budgets.map((b) => toDomain(b)).toList();
  }
}
