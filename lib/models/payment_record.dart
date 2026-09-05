class PaymentRecord {
  final String id;
  final String memberId;
  final String memberName;
  final double amount;
  final String date; // Format: YYYY-MM-DD
  final String paymentMethod; // 'Cash', 'UPI', 'Card', 'Other'
  final String notes;

  PaymentRecord({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.amount,
    required this.date,
    required this.paymentMethod,
    this.notes = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'memberId': memberId,
        'memberName': memberName,
        'amount': amount,
        'date': date,
        'paymentMethod': paymentMethod,
        'notes': notes,
      };

  factory PaymentRecord.fromJson(Map<String, dynamic> json) => PaymentRecord(
        id: json['id'] ?? '',
        memberId: json['memberId'] ?? '',
        memberName: json['memberName'] ?? '',
        amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
        date: json['date'] ?? '',
        paymentMethod: json['paymentMethod'] ?? 'Cash',
        notes: json['notes'] ?? '',
      );
}
