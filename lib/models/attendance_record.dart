class AttendanceRecord {
  final String id;
  final String memberId;
  final String date; // Format: YYYY-MM-DD
  final String status; // 'Present' or 'Absent'
  final String checkInTime; // e.g. "07:15 AM"

  AttendanceRecord({
    required this.id,
    required this.memberId,
    required this.date,
    required this.status,
    required this.checkInTime,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'memberId': memberId,
        'date': date,
        'status': status,
        'checkInTime': checkInTime,
      };

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) => AttendanceRecord(
        id: json['id'] ?? '',
        memberId: json['memberId'] ?? '',
        date: json['date'] ?? '',
        status: json['status'] ?? 'Present',
        checkInTime: json['checkInTime'] ?? '',
      );
}
