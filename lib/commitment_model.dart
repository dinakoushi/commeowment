class Commitment {
  String id;
  String title;
  double amount;
  bool isPaid;
  DateTime createdAt;

  Commitment({
    required this.id,
    required this.title,
    required this.amount,
    this.isPaid = false,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'isPaid': isPaid,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static Commitment fromJson(Map<String, dynamic> json) {
    return Commitment(
      id: json['id'],
      title: json['title'],
      amount: json['amount'].toDouble(),
      isPaid: json['isPaid'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
