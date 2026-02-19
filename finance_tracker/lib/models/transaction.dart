class Transaction {
  final String id;
  final String title;
  final double amount;
  final String type;
  final String category;
  final String date;
  final String? note;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.note,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'].toString(),
      title: json['title'],
      amount: (json['amount'] as num).toDouble(),
      type: json['type'],
      category: json['category'],
      date: json['date'],
      note: json['note'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'amount': amount,
      'type': type,
      'category': category,
      'date': date,
      if (note != null) 'note': note,
    };
  }
}