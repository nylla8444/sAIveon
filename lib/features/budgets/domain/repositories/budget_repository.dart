import '../entities/budget_entity.dart';

abstract class IBudgetRepository {
  /// Watch all budgets as a stream
  Stream<List<BudgetEntity>> watchAllBudgets();

  /// Get budgets for a specific month and year
  Future<List<BudgetEntity>> getBudgetsByMonthYear(int month, int year);

  /// Get or create monthly overall budget for a specific month and year
  Future<BudgetEntity> getOrCreateMonthlyBudget(int month, int year);

  /// Add a new budget
  Future<int> addBudget(BudgetEntity budget);

  /// Update an existing budget
  Future<void> updateBudget(BudgetEntity budget);

  /// Delete a budget (soft delete)
  Future<void> deleteBudget(int id);
}
