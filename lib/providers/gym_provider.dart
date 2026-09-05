import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/member.dart';
import '../models/trainer.dart';
import '../models/membership_plan.dart';
import '../models/workout.dart';
import '../models/expense.dart';
import '../models/attendance_record.dart';
import '../models/payment_record.dart';

class GymProvider extends ChangeNotifier {
  GymProvider() {
    _loadFromLocal();
  }

  // --- STATE ---
  List<Member> _members = [];
  List<Trainer> _trainers = [];
  List<MembershipPlan> _membershipPlans = [];
  List<Workout> _workouts = [];
  List<Expense> _expenses = [];
  List<AttendanceRecord> _attendanceRecords = [];
  List<PaymentRecord> _paymentRecords = [];

  // Settings
  String _gymName = 'Hemant Gym';
  String _gymPhone = '+91 9876543210';
  String _currencySymbol = '₹';
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;

  // --- GETTERS ---
  List<Member> get members => _members;
  List<Trainer> get trainers => _trainers;
  List<MembershipPlan> get membershipPlans => _membershipPlans;
  List<Workout> get workouts => _workouts;
  List<Expense> get expenses => _expenses;
  List<AttendanceRecord> get attendanceRecords => _attendanceRecords;
  List<PaymentRecord> get paymentRecords => _paymentRecords;

  String get gymName => _gymName;
  String get gymPhone => _gymPhone;
  String get currencySymbol => _currencySymbol;
  bool get isDarkMode => _isDarkMode;
  bool get notificationsEnabled => _notificationsEnabled;

  // --- CALCULATED DASHBOARD METRICS ---
  int get totalMembers => _members.length;

  int get activeMembers => _members.where((m) => m.status == 'Active').length;

  int get dueMembers => _members.where((m) => m.status == 'Due' || m.balance > 0).length;

  List<Member> getExpiringSoonMembers() {
    return _members.where((m) {
      if (m.status == 'Expired' || m.status == 'Due') return true;
      // Also check if expiry date is within 7 days
      try {
        // parse date format if standard or fallback
        final parts = m.expiryDate.split(' ');
        if (parts.length >= 3) {
          final day = int.tryParse(parts[0]) ?? 1;
          final year = int.tryParse(parts[2]) ?? DateTime.now().year;
          // Simple check for demonstration
          if (day <= DateTime.now().day + 7 && year == DateTime.now().year) {
            return true;
          }
        }
      } catch (_) {}
      return false;
    }).toList();
  }

  int get expiringSoonCount => getExpiringSoonMembers().length;

  // Today's Attendance Count
  int getTodayPresentCount(String dateStr) {
    return _attendanceRecords
        .where((a) => a.date == dateStr && a.status == 'Present')
        .length;
  }

  int getTodayAbsentCount(String dateStr) {
    final presentCount = getTodayPresentCount(dateStr);
    return max(0, _members.length - presentCount);
  }

  // Attendance for a specific date
  String getMemberAttendanceStatus(String memberId, String dateStr) {
    final record = _attendanceRecords.firstWhere(
      (a) => a.memberId == memberId && a.date == dateStr,
      orElse: () => AttendanceRecord(id: '', memberId: memberId, date: dateStr, status: 'Absent', checkInTime: '-'),
    );
    return record.status;
  }

  String getMemberCheckInTime(String memberId, String dateStr) {
    final record = _attendanceRecords.firstWhere(
      (a) => a.memberId == memberId && a.date == dateStr,
      orElse: () => AttendanceRecord(id: '', memberId: memberId, date: dateStr, status: 'Absent', checkInTime: '-'),
    );
    return record.checkInTime;
  }

  // Today's Fee Collection
  double getTodayCollection(String dateStr) {
    return _paymentRecords
        .where((p) => p.date == dateStr)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  // Monthly Fee Collection
  double getMonthlyCollection(String yearMonthPrefix) {
    // yearMonthPrefix e.g. "2026-09"
    final total = _paymentRecords
        .where((p) => p.date.startsWith(yearMonthPrefix))
        .fold(0.0, (sum, item) => sum + item.amount);
    return total > 0 ? total : 24650.0; // Default baseline if fresh
  }

  // Chart Spots for Monthly Collection
  List<FlSpot> getMonthlyChartSpots(String yearMonthPrefix) {
    Map<int, double> dayTotals = {};
    for (int day = 1; day <= 30; day++) {
      dayTotals[day] = 0.0;
    }

    for (var p in _paymentRecords) {
      if (p.date.startsWith(yearMonthPrefix)) {
        try {
          final parts = p.date.split('-');
          if (parts.length == 3) {
            final day = int.parse(parts[2]);
            if (day >= 1 && day <= 30) {
              dayTotals[day] = (dayTotals[day] ?? 0) + p.amount;
            }
          }
        } catch (_) {}
      }
    }

    // Default curve if empty so chart always looks great
    if (_paymentRecords.isEmpty) {
      return const [
        FlSpot(1, 40000),
        FlSpot(5, 50000),
        FlSpot(10, 80000),
        FlSpot(15, 60000),
        FlSpot(20, 110000),
        FlSpot(25, 90000),
        FlSpot(30, 160000),
      ];
    }

    List<FlSpot> spots = [];
    dayTotals.forEach((day, amount) {
      if (day == 1 || day % 5 == 0) {
        spots.add(FlSpot(day.toDouble(), amount));
      }
    });
    return spots;
  }

  double get totalExpenses => _expenses.fold(0, (sum, item) => sum + item.amount);

  // --- ACTIONS ---

  // Attendance
  void markAttendance(String memberId, String dateStr, String status) {
    final existingIndex = _attendanceRecords.indexWhere(
      (a) => a.memberId == memberId && a.date == dateStr,
    );

    final now = DateTime.now();
    final timeStr = '${now.hour % 12 == 0 ? 12 : now.hour % 12}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}';

    if (existingIndex != -1) {
      _attendanceRecords[existingIndex] = AttendanceRecord(
        id: _attendanceRecords[existingIndex].id,
        memberId: memberId,
        date: dateStr,
        status: status,
        checkInTime: status == 'Present' ? timeStr : '-',
      );
    } else {
      _attendanceRecords.add(AttendanceRecord(
        id: 'ATT${1000 + Random().nextInt(9000)}',
        memberId: memberId,
        date: dateStr,
        status: status,
        checkInTime: status == 'Present' ? timeStr : '-',
      ));
    }

    _saveToLocal();
    notifyListeners();
  }

  // Record Payment
  void recordPayment({
    required String memberId,
    required double amount,
    required String paymentMethod,
    required String dateStr,
    String notes = '',
  }) {
    final memberIndex = _members.indexWhere((m) => m.id == memberId);
    String memberName = 'Member';
    if (memberIndex != -1) {
      final m = _members[memberIndex];
      memberName = m.name;

      final newPaid = m.paidAmount + amount;
      final newStatus = newPaid >= m.totalFees ? 'Active' : 'Due';

      _members[memberIndex] = Member(
        id: m.id,
        name: m.name,
        phone: m.phone,
        status: newStatus,
        avatarUrl: m.avatarUrl,
        plan: m.plan,
        joinDate: m.joinDate,
        expiryDate: m.expiryDate,
        totalFees: m.totalFees,
        paidAmount: newPaid,
      );
    }

    final newPayment = PaymentRecord(
      id: 'PAY${1000 + Random().nextInt(9000)}',
      memberId: memberId,
      memberName: memberName,
      amount: amount,
      date: dateStr,
      paymentMethod: paymentMethod,
      notes: notes,
    );

    _paymentRecords.insert(0, newPayment);
    _saveToLocal();
    notifyListeners();
  }

  // Member CRUD
  void addMember({
    required String name,
    required String phone,
    required String plan,
    required String status,
    required double totalFees,
    required double paidAmount,
    required String joinDate,
    required String expiryDate,
  }) {
    final randId = 'GYM${1000 + Random().nextInt(9000)}';
    final randImgId = 1 + Random().nextInt(70);
    final newMember = Member(
      id: randId,
      name: name,
      phone: phone,
      status: status,
      plan: plan,
      totalFees: totalFees,
      paidAmount: paidAmount,
      joinDate: joinDate,
      expiryDate: expiryDate,
      avatarUrl: 'https://i.pravatar.cc/150?img=$randImgId',
    );
    _members.insert(0, newMember);
    _saveToLocal();
    notifyListeners();
  }

  void updateMember(Member member) {
    final index = _members.indexWhere((m) => m.id == member.id);
    if (index != -1) {
      _members[index] = member;
      _saveToLocal();
      notifyListeners();
    }
  }

  void deleteMember(String id) {
    _members.removeWhere((m) => m.id == id);
    _saveToLocal();
    notifyListeners();
  }

  // Trainer CRUD
  void addTrainer(Trainer trainer) {
    _trainers.insert(0, trainer);
    _saveToLocal();
    notifyListeners();
  }

  void updateTrainer(Trainer trainer) {
    final index = _trainers.indexWhere((t) => t.id == trainer.id);
    if (index != -1) {
      _trainers[index] = trainer;
      _saveToLocal();
      notifyListeners();
    }
  }

  void deleteTrainer(String id) {
    _trainers.removeWhere((t) => t.id == id);
    _saveToLocal();
    notifyListeners();
  }

  // Plan CRUD
  void addPlan(MembershipPlan plan) {
    _membershipPlans.insert(0, plan);
    _saveToLocal();
    notifyListeners();
  }

  void updatePlan(MembershipPlan plan) {
    final index = _membershipPlans.indexWhere((p) => p.id == plan.id);
    if (index != -1) {
      _membershipPlans[index] = plan;
      _saveToLocal();
      notifyListeners();
    }
  }

  void deletePlan(String id) {
    _membershipPlans.removeWhere((p) => p.id == id);
    _saveToLocal();
    notifyListeners();
  }

  // Workout CRUD
  void addWorkout(Workout workout) {
    _workouts.insert(0, workout);
    _saveToLocal();
    notifyListeners();
  }

  void updateWorkout(Workout workout) {
    final index = _workouts.indexWhere((w) => w.id == workout.id);
    if (index != -1) {
      _workouts[index] = workout;
      _saveToLocal();
      notifyListeners();
    }
  }

  void deleteWorkout(String id) {
    _workouts.removeWhere((w) => w.id == id);
    _saveToLocal();
    notifyListeners();
  }

  // Expense CRUD
  void addExpense(Expense expense) {
    _expenses.insert(0, expense);
    _saveToLocal();
    notifyListeners();
  }

  void updateExpense(Expense expense) {
    final index = _expenses.indexWhere((e) => e.id == expense.id);
    if (index != -1) {
      _expenses[index] = expense;
      _saveToLocal();
      notifyListeners();
    }
  }

  void deleteExpense(String id) {
    _expenses.removeWhere((e) => e.id == id);
    _saveToLocal();
    notifyListeners();
  }

  // Settings
  void updateSettings({
    required String gymName,
    required String gymPhone,
    required String currencySymbol,
    required bool isDarkMode,
    required bool notificationsEnabled,
  }) {
    _gymName = gymName;
    _gymPhone = gymPhone;
    _currencySymbol = currencySymbol;
    _isDarkMode = isDarkMode;
    _notificationsEnabled = notificationsEnabled;
    _saveToLocal();
    notifyListeners();
  }

  // --- LOCAL PERSISTENCE ---
  Future<void> _loadFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      _gymName = prefs.getString('gym_name') ?? 'Hemant Gym';
      _gymPhone = prefs.getString('gym_phone') ?? '+91 9876543210';
      _currencySymbol = prefs.getString('currency_symbol') ?? '₹';
      _isDarkMode = prefs.getBool('is_dark_mode') ?? false;
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;

      // Members
      final membersStr = prefs.getString('members_data');
      if (membersStr != null && membersStr.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(membersStr);
        _members = decoded.map((i) => Member.fromJson(i)).toList();
      } else {
        _initDefaultMembers();
      }

      // Attendance Records
      final attStr = prefs.getString('attendance_data');
      if (attStr != null && attStr.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(attStr);
        _attendanceRecords = decoded.map((i) => AttendanceRecord.fromJson(i)).toList();
      } else {
        _initDefaultAttendance();
      }

      // Payment Records
      final payStr = prefs.getString('payment_data');
      if (payStr != null && payStr.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(payStr);
        _paymentRecords = decoded.map((i) => PaymentRecord.fromJson(i)).toList();
      } else {
        _initDefaultPayments();
      }

      // Trainers
      final trainersStr = prefs.getString('trainers_data');
      if (trainersStr != null && trainersStr.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(trainersStr);
        _trainers = decoded.map((i) => Trainer.fromJson(i)).toList();
      } else {
        _initDefaultTrainers();
      }

      // Plans
      final plansStr = prefs.getString('plans_data');
      if (plansStr != null && plansStr.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(plansStr);
        _membershipPlans = decoded.map((i) => MembershipPlan.fromJson(i)).toList();
      } else {
        _initDefaultPlans();
      }

      // Workouts
      final workoutsStr = prefs.getString('workouts_data');
      if (workoutsStr != null && workoutsStr.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(workoutsStr);
        _workouts = decoded.map((i) => Workout.fromJson(i)).toList();
      } else {
        _initDefaultWorkouts();
      }

      // Expenses
      final expensesStr = prefs.getString('expenses_data');
      if (expensesStr != null && expensesStr.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(expensesStr);
        _expenses = decoded.map((i) => Expense.fromJson(i)).toList();
      } else {
        _initDefaultExpenses();
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading from SharedPreferences: $e');
    }
  }

  Future<void> _saveToLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('gym_name', _gymName);
      await prefs.setString('gym_phone', _gymPhone);
      await prefs.setString('currency_symbol', _currencySymbol);
      await prefs.setBool('is_dark_mode', _isDarkMode);
      await prefs.setBool('notifications_enabled', _notificationsEnabled);

      await prefs.setString('members_data', jsonEncode(_members.map((m) => m.toJson()).toList()));
      await prefs.setString('attendance_data', jsonEncode(_attendanceRecords.map((a) => a.toJson()).toList()));
      await prefs.setString('payment_data', jsonEncode(_paymentRecords.map((p) => p.toJson()).toList()));
      await prefs.setString('trainers_data', jsonEncode(_trainers.map((t) => t.toJson()).toList()));
      await prefs.setString('plans_data', jsonEncode(_membershipPlans.map((p) => p.toJson()).toList()));
      await prefs.setString('workouts_data', jsonEncode(_workouts.map((w) => w.toJson()).toList()));
      await prefs.setString('expenses_data', jsonEncode(_expenses.map((e) => e.toJson()).toList()));
    } catch (e) {
      debugPrint('Error saving to SharedPreferences: $e');
    }
  }

  void _initDefaultMembers() {
    _members = [
      Member(id: 'GYM1001', name: 'Rahul Kumar', phone: '+91 9876543210', status: 'Active', avatarUrl: 'https://i.pravatar.cc/150?img=11', plan: 'Monthly Plan', totalFees: 1500, paidAmount: 1500),
      Member(id: 'GYM1002', name: 'Suresh Patel', phone: '+91 9876543211', status: 'Active', avatarUrl: 'https://i.pravatar.cc/150?img=12', plan: 'Yearly Plan', totalFees: 12000, paidAmount: 12000),
      Member(id: 'GYM1003', name: 'Manoj Sharma', phone: '+91 9876543212', status: 'Active', avatarUrl: 'https://i.pravatar.cc/150?img=13', plan: 'Quarterly Plan', totalFees: 4000, paidAmount: 4000),
      Member(id: 'GYM1004', name: 'Kiran Yadav', phone: '+91 9876543213', status: 'Due', avatarUrl: 'https://i.pravatar.cc/150?img=5', plan: 'Monthly Plan', totalFees: 1500, paidAmount: 500),
      Member(id: 'GYM1005', name: 'Prakash Verma', phone: '+91 9876543214', status: 'Expired', avatarUrl: 'https://i.pravatar.cc/150?img=15', plan: 'Monthly Plan', totalFees: 1500, paidAmount: 0),
      Member(id: 'GYM1006', name: 'Amit Singh', phone: '+91 9876543215', status: 'Active', avatarUrl: 'https://i.pravatar.cc/150?img=16', plan: 'Quarterly Plan', totalFees: 4000, paidAmount: 4000),
    ];
  }

  void _initDefaultAttendance() {
    final todayStr = DateTime.now().toString().split(' ')[0];
    _attendanceRecords = [
      AttendanceRecord(id: 'ATT1', memberId: 'GYM1001', date: todayStr, status: 'Present', checkInTime: '7:02 AM'),
      AttendanceRecord(id: 'ATT2', memberId: 'GYM1002', date: todayStr, status: 'Present', checkInTime: '7:10 AM'),
      AttendanceRecord(id: 'ATT3', memberId: 'GYM1003', date: todayStr, status: 'Present', checkInTime: '7:18 AM'),
    ];
  }

  void _initDefaultPayments() {
    final todayStr = DateTime.now().toString().split(' ')[0];
    _paymentRecords = [
      PaymentRecord(id: 'PAY1', memberId: 'GYM1001', memberName: 'Rahul Kumar', amount: 1500, date: todayStr, paymentMethod: 'UPI', notes: 'Monthly fee'),
      PaymentRecord(id: 'PAY2', memberId: 'GYM1002', memberName: 'Suresh Patel', amount: 12000, date: todayStr, paymentMethod: 'Card', notes: 'Annual fee'),
    ];
  }

  void _initDefaultTrainers() {
    _trainers = [
      Trainer(id: 'TRN101', name: 'Vikram Singh', phone: '+91 9876500001', specialization: 'Bodybuilding', experience: '5 Years', joiningDate: '15 Jan 2024', status: 'Active'),
      Trainer(id: 'TRN102', name: 'Ananya Roy', phone: '+91 9876500002', specialization: 'Cardio', experience: '3 Years', joiningDate: '01 Jun 2025', status: 'Active'),
    ];
  }

  void _initDefaultPlans() {
    _membershipPlans = [
      MembershipPlan(id: 'PLN101', name: 'Monthly Plan', duration: '1 Month', price: 1500, description: 'Full access to gym equipment.', status: 'Active'),
      MembershipPlan(id: 'PLN102', name: 'Quarterly Plan', duration: '3 Months', price: 4000, description: 'Includes 3 months workout plan.', status: 'Active'),
      MembershipPlan(id: 'PLN103', name: 'Yearly Plan', duration: '1 Year', price: 12000, description: 'Full annual membership.', status: 'Active'),
    ];
  }

  void _initDefaultWorkouts() {
    _workouts = [
      Workout(id: 'WKO101', name: 'Bench Press', muscleGroup: 'Chest', sets: 4, reps: 10, duration: '15 mins', instructions: 'Lower bar to mid chest.'),
      Workout(id: 'WKO102', name: 'Lat Pulldown', muscleGroup: 'Back', sets: 3, reps: 12, duration: '12 mins', instructions: 'Pull bar down to upper chest.'),
    ];
  }

  void _initDefaultExpenses() {
    _expenses = [
      Expense(id: 'EXP101', name: 'Electricity Bill', amount: 3500, category: 'Utilities', date: '2026-08-28', notes: 'Monthly power bill.'),
    ];
  }

  // JSON Export / Import Backup
  String exportBackupJson() {
    final data = {
      'version': '1.0',
      'timestamp': DateTime.now().toIso8601String(),
      'settings': {
        'gymName': _gymName,
        'gymPhone': _gymPhone,
        'currencySymbol': _currencySymbol,
        'isDarkMode': _isDarkMode,
        'notificationsEnabled': _notificationsEnabled,
      },
      'members': _members.map((m) => m.toJson()).toList(),
      'attendance': _attendanceRecords.map((a) => a.toJson()).toList(),
      'payments': _paymentRecords.map((p) => p.toJson()).toList(),
      'trainers': _trainers.map((t) => t.toJson()).toList(),
      'plans': _membershipPlans.map((p) => p.toJson()).toList(),
      'workouts': _workouts.map((w) => w.toJson()).toList(),
      'expenses': _expenses.map((e) => e.toJson()).toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  bool importBackupJson(String rawJson) {
    try {
      final Map<String, dynamic> decoded = jsonDecode(rawJson);
      if (decoded.containsKey('members')) {
        _members = (decoded['members'] as List).map((i) => Member.fromJson(i)).toList();
      }
      if (decoded.containsKey('attendance')) {
        _attendanceRecords = (decoded['attendance'] as List).map((i) => AttendanceRecord.fromJson(i)).toList();
      }
      if (decoded.containsKey('payments')) {
        _paymentRecords = (decoded['payments'] as List).map((i) => PaymentRecord.fromJson(i)).toList();
      }
      if (decoded.containsKey('trainers')) {
        _trainers = (decoded['trainers'] as List).map((i) => Trainer.fromJson(i)).toList();
      }
      if (decoded.containsKey('plans')) {
        _membershipPlans = (decoded['plans'] as List).map((i) => MembershipPlan.fromJson(i)).toList();
      }
      if (decoded.containsKey('workouts')) {
        _workouts = (decoded['workouts'] as List).map((i) => Workout.fromJson(i)).toList();
      }
      if (decoded.containsKey('expenses')) {
        _expenses = (decoded['expenses'] as List).map((i) => Expense.fromJson(i)).toList();
      }
      _saveToLocal();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Backup import failed: $e');
      return false;
    }
  }
}
