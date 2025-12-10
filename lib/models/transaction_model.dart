class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final String type; // 'masuk' (income) atau 'keluar' (expense)
  final DateTime date;

  TransactionModel({required this.id, required this.title, required this.amount, required this.type, required this.date});

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      type: json['type'] ?? 'keluar',
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'amount': amount,
      'type': type,
      'date': date.toIso8601String(),
    };
  }
}