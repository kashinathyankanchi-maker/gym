class MembershipPlan {
  final String id;
  final String name;
  final String duration; // e.g. "1 Month", "3 Months", "1 Year"
  final double price;
  final String description;
  final String status; // 'Active' or 'Inactive'

  MembershipPlan({
    required this.id,
    required this.name,
    required this.duration,
    required this.price,
    required this.description,
    this.status = 'Active',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'duration': duration,
        'price': price,
        'description': description,
        'status': status,
      };

  factory MembershipPlan.fromJson(Map<String, dynamic> json) => MembershipPlan(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        duration: json['duration'] ?? '',
        price: (json['price'] as num?)?.toDouble() ?? 0.0,
        description: json['description'] ?? '',
        status: json['status'] ?? 'Active',
      );
}
