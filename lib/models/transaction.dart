import 'package:hive/hive.dart';

part 'transaction.g.dart';

@HiveType(typeId: 0)
class Transaction extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  double amount;

  @HiveField(2)
  String category;

  @HiveField(3)
  String type; // 'expense' or 'income'

  @HiveField(4)
  DateTime date;

  @HiveField(5)
  String? note;

  @HiveField(6)
  String currency;

  Transaction({
    required this.id,
    required this.amount,
    required this.category,
    required this.type,
    required this.date,
    this.note,
    this.currency = 'USD',
  });

  Transaction copyWith({
    String? id,
    double? amount,
    String? category,
    String? type,
    DateTime? date,
    String? note,
    String? currency,
  }) {
    return Transaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      type: type ?? this.type,
      date: date ?? this.date,
      note: note ?? this.note,
      currency: currency ?? this.currency,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'category': category,
      'type': type,
      'date': date.toIso8601String(),
      'note': note,
      'currency': currency,
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      amount: json['amount'].toDouble(),
      category: json['category'],
      type: json['type'],
      date: DateTime.parse(json['date']),
      note: json['note'],
      currency: json['currency'],
    );
  }
}