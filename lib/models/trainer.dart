class Trainer {
  final String id;
  final String name;
  final String phone;
  final String specialization;
  final String experience; // e.g. "3 Years"
  final String joiningDate;
  final String status; // 'Active' or 'Inactive'

  Trainer({
    required this.id,
    required this.name,
    required this.phone,
    required this.specialization,
    required this.experience,
    required this.joiningDate,
    this.status = 'Active',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'specialization': specialization,
        'experience': experience,
        'joiningDate': joiningDate,
        'status': status,
      };

  factory Trainer.fromJson(Map<String, dynamic> json) => Trainer(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        phone: json['phone'] ?? '',
        specialization: json['specialization'] ?? '',
        experience: json['experience'] ?? '',
        joiningDate: json['joiningDate'] ?? '',
        status: json['status'] ?? 'Active',
      );
}
