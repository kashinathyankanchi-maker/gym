class Member {
  final String id;
  final String name;
  final String phone;
  final String dob; // Date of birth (optional)
  final String status; // 'Active', 'Due', 'Expired', 'Suspended'
  final bool isSuspended;
  final String avatarUrl;
  final String plan; // 'Monthly Plan', 'Yearly Plan', etc.
  final String duration; // '1 Month', '1 Year', etc.
  final String joinDate;
  final String expiryDate;
  final double totalFees;
  final double paidAmount;
  final String notes;

  Member({
    required this.id,
    required this.name,
    this.phone = '+91 9876543210',
    this.dob = '',
    this.status = 'Active',
    this.isSuspended = false,
    required this.avatarUrl,
    this.plan = 'Monthly Plan',
    this.duration = '1 Month',
    this.joinDate = '01 Sep 2026',
    this.expiryDate = '30 Sep 2026',
    this.totalFees = 1500,
    this.paidAmount = 1000,
    this.notes = '',
  });

  double get balance => totalFees - paidAmount;

  // Computed status dynamically calculated based on dates, payment, and suspension
  String get computedStatus {
    if (isSuspended || status == 'Suspended') return 'Suspended';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    DateTime? exp;
    try {
      final parts = expiryDate.split(' ');
      if (parts.length >= 3) {
        final day = int.tryParse(parts[0]) ?? 1;
        final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        final monthIndex = monthNames.indexWhere((m) => m.toLowerCase() == parts[1].toLowerCase()) + 1;
        final year = int.tryParse(parts[2]) ?? DateTime.now().year;
        if (monthIndex > 0) {
          exp = DateTime(year, monthIndex, day);
        }
      } else if (expiryDate.contains('-')) {
        exp = DateTime.parse(expiryDate);
      }
    } catch (_) {}

    if (exp != null && exp.isBefore(today)) {
      return 'Expired';
    }

    if (balance > 0) {
      return 'Due';
    }

    return 'Active';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'dob': dob,
        'status': status,
        'isSuspended': isSuspended,
        'avatarUrl': avatarUrl,
        'plan': plan,
        'duration': duration,
        'joinDate': joinDate,
        'expiryDate': expiryDate,
        'totalFees': totalFees,
        'paidAmount': paidAmount,
        'notes': notes,
      };

  factory Member.fromJson(Map<String, dynamic> json) => Member(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        phone: json['phone'] ?? '+91 9876543210',
        dob: json['dob'] ?? '',
        status: json['status'] ?? 'Active',
        isSuspended: json['isSuspended'] ?? false,
        avatarUrl: json['avatarUrl'] ?? 'https://i.pravatar.cc/150?img=11',
        plan: json['plan'] ?? 'Monthly Plan',
        duration: json['duration'] ?? '1 Month',
        joinDate: json['joinDate'] ?? '01 Sep 2026',
        expiryDate: json['expiryDate'] ?? '30 Sep 2026',
        totalFees: (json['totalFees'] as num?)?.toDouble() ?? 1500.0,
        paidAmount: (json['paidAmount'] as num?)?.toDouble() ?? 1000.0,
        notes: json['notes'] ?? '',
      );
}
