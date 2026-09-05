class Member {
  final String id;
  final String name;
  final String phone;
  final String status; // 'Active', 'Due', 'Expired'
  final String avatarUrl;
  final String plan; // 'Monthly', 'Yearly', etc.
  final String joinDate;
  final String expiryDate;
  final double totalFees;
  final double paidAmount;

  Member({
    required this.id,
    required this.name,
    this.phone = '+91 9876543210',
    required this.status,
    required this.avatarUrl,
    this.plan = 'Monthly Plan',
    this.joinDate = '01 Sep 2026',
    this.expiryDate = '30 Sep 2026',
    this.totalFees = 1500,
    this.paidAmount = 1000,
  });

  double get balance => totalFees - paidAmount;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'status': status,
        'avatarUrl': avatarUrl,
        'plan': plan,
        'joinDate': joinDate,
        'expiryDate': expiryDate,
        'totalFees': totalFees,
        'paidAmount': paidAmount,
      };

  factory Member.fromJson(Map<String, dynamic> json) => Member(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        phone: json['phone'] ?? '+91 9876543210',
        status: json['status'] ?? 'Active',
        avatarUrl: json['avatarUrl'] ?? 'https://i.pravatar.cc/150?img=11',
        plan: json['plan'] ?? 'Monthly Plan',
        joinDate: json['joinDate'] ?? '01 Sep 2026',
        expiryDate: json['expiryDate'] ?? '30 Sep 2026',
        totalFees: (json['totalFees'] as num?)?.toDouble() ?? 1500.0,
        paidAmount: (json['paidAmount'] as num?)?.toDouble() ?? 1000.0,
      );
}
