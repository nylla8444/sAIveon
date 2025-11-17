import '../entities/expense_entity.dart';

abstract class IExpenseRepository {
  /// Watch all expenses as a stream
  Stream<List<ExpenseEntity>> watchAllExpenses();

  /// Get expenses by bank ID
  Future<List<ExpenseEntity>> getExpensesByBank(int bankId);

  /// Add a new expense
  Future<int> addExpense(ExpenseEntity expense);

  /// Update an existing expense
  Future<void> updateExpense(ExpenseEntity expense);

  /// Delete an expense (soft delete)
  Future<void> deleteExpense(int id);
}
