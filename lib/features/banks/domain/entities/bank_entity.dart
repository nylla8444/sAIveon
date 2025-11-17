import 'package:equatable/equatable.dart';

class BankEntity extends Equatable {
  final int? id;
  final String name;
  final String accountNumber;
  final double balance;
  final String color;
  final String? logoPath;
  final String? serverId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isDeleted;

  const BankEntity({
    this.id,
    required this.name,
    required this.accountNumber,
    required this.balance,
    required this.color,
    this.logoPath,
    this.serverId,
    this.createdAt,
    this.updatedAt,
    this.isDeleted = false,
  });

  BankEntity copyWith({
    int? id,
    String? name,
    String? accountNumber,
    double? balance,
    String? color,
    String? logoPath,
    String? serverId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return BankEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      accountNumber: accountNumber ?? this.accountNumber,
      balance: balance ?? this.balance,
      color: color ?? this.color,
      logoPath: logoPath ?? this.logoPath,
      serverId: serverId ?? this.serverId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    accountNumber,
    balance,
    color,
    logoPath,
    serverId,
    createdAt,
    updatedAt,
    isDeleted,
  ];
}
