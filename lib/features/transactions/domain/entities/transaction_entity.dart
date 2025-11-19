import 'package:equatable/equatable.dart';

class TransactionEntity extends Equatable {
  // Domain model for transactions
  final int? id;
  final String type; // 'send', 'receive', or 'transfer'
  final double amount;
  final String name;
  final String iconPath;
  final String status;
  final int statusColor;
  final int? bankId; // source bank
  final int? toBankId; // destination bank for transfers
  final DateTime date;
  final String? serverId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isDeleted;

  const TransactionEntity({
    this.id,
    required this.type,
    required this.amount,
    required this.name,
    required this.iconPath,
    required this.status,
    required this.statusColor,
    this.bankId,
    this.toBankId,
    required this.date,
    this.serverId,
    this.createdAt,
    this.updatedAt,
    this.isDeleted = false,
  });

  TransactionEntity copyWith({
    int? id,
    String? type,
    double? amount,
    String? name,
    String? iconPath,
    String? status,
    int? statusColor,
    int? bankId,
    int? toBankId,
    DateTime? date,
    String? serverId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return TransactionEntity(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      name: name ?? this.name,
      iconPath: iconPath ?? this.iconPath,
      status: status ?? this.status,
      statusColor: statusColor ?? this.statusColor,
      bankId: bankId ?? this.bankId,
      toBankId: toBankId ?? this.toBankId,
      date: date ?? this.date,
      serverId: serverId ?? this.serverId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  List<Object?> get props => [
    id,
    type,
    amount,
    name,
    iconPath,
    status,
    statusColor,
    bankId,
    toBankId,
    date,
    serverId,
    createdAt,
    updatedAt,
    isDeleted,
  ];
}
