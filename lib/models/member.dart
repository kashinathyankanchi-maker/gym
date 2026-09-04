class Member {
  final String id;
  final String name;
  final String status; // 'Active', 'Due', 'Expired'
  final String avatarUrl;
  final String plan; // 'Monthly', 'Yearly'
  final String joinDate;
  final String expiryDate;
  final double totalFees;
  final double paidAmount;

  Member({
    required this.id,
    required this.name,
    required this.status,
    required this.avatarUrl,
    this.plan = 'Monthly',
    this.joinDate = '01 Sep 2026',
    this.expiryDate = '30 Sep 2026',
    this.totalFees = 1500,
    this.paidAmount = 1000,
  });

  double get balance => totalFees - paidAmount;
}
