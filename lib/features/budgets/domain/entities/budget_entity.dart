import 'package:equatable/equatable.dart';

class BudgetEntity extends Equatable {
  // Domain model for budgets
  final int? id;
  final String category;
  final double budgetAmount;
  final double spentAmount;
  final int month;
  final int year;
  final int iconColor;
  final String? serverId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isDeleted;

  const BudgetEntity({
    this.id,
    required this.category,
    required this.budgetAmount,
    this.spentAmount = 0.0,
    required this.month,
    required this.year,
    required this.iconColor,
    this.serverId,
    this.createdAt,
    this.updatedAt,
    this.isDeleted = false,
  });

  BudgetEntity copyWith({
    int? id,
    String? category,
    double? budgetAmount,
    double? spentAmount,
    int? month,
    int? year,
    int? iconColor,
    String? serverId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return BudgetEntity(
      id: id ?? this.id,
      category: category ?? this.category,
      budgetAmount: budgetAmount ?? this.budgetAmount,
      spentAmount: spentAmount ?? this.spentAmount,
      month: month ?? this.month,
      year: year ?? this.year,
      iconColor: iconColor ?? this.iconColor,
      serverId: serverId ?? this.serverId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  List<Object?> get props => [
    id,
    category,
    budgetAmount,
    spentAmount,
    month,
    year,
    iconColor,
    serverId,
    createdAt,
    updatedAt,
    isDeleted,
  ];
}
