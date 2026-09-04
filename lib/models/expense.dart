class Expense {
  final String id;
  final String name;
  final double amount;
  final String category; // "Equipment", "Utilities", "Rent", "Maintenance", "Salaries", "Other"
  final String date; // "YYYY-MM-DD" or formatted date
  final String notes;

  Expense({
    required this.id,
    required this.name,
    required this.amount,
    required this.category,
    required this.date,
    required this.notes,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'amount': amount,
        'category': category,
        'date': date,
        'notes': notes,
      };

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
        category: json['category'] ?? 'Other',
        date: json['date'] ?? '',
        notes: json['notes'] ?? '',
      );
}
