import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/member.dart';
import '../models/trainer.dart';
import '../models/membership_plan.dart';
import '../models/workout.dart';
import '../models/expense.dart';

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

  String get gymName => _gymName;
  String get gymPhone => _gymPhone;
  String get currencySymbol => _currencySymbol;
  bool get isDarkMode => _isDarkMode;
  bool get notificationsEnabled => _notificationsEnabled;

  // Dashboard Stats
  int get totalMembers => _members.length;
  int get activeMembers => _members.where((m) => m.status == 'Active').length;
  int get dueMembers => _members.where((m) => m.status == 'Due').length;
  int get expiredMembers => _members.where((m) => m.status == 'Expired').length;
  double get totalCollection => _members.fold(0, (sum, item) => sum + item.paidAmount);
  double get totalExpenses => _expenses.fold(0, (sum, item) => sum + item.amount);

  // --- LOCAL STORAGE PERSISTENCE ---
  Future<void> _loadFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load Settings
      _gymName = prefs.getString('gym_name') ?? 'Hemant Gym';
      _gymPhone = prefs.getString('gym_phone') ?? '+91 9876543210';
      _currencySymbol = prefs.getString('currency_symbol') ?? '₹';
      _isDarkMode = prefs.getBool('is_dark_mode') ?? false;
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;

      // Load Members
      final membersJsonStr = prefs.getString('members_data');
      if (membersJsonStr != null && membersJsonStr.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(membersJsonStr);
        _members = decoded.map((item) => Member.fromJson(item)).toList();
      } else {
        _initDefaultMembers();
      }

      // Load Trainers
      final trainersJsonStr = prefs.getString('trainers_data');
      if (trainersJsonStr != null && trainersJsonStr.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(trainersJsonStr);
        _trainers = decoded.map((item) => Trainer.fromJson(item)).toList();
      } else {
        _initDefaultTrainers();
      }

      // Load Membership Plans
      final plansJsonStr = prefs.getString('plans_data');
      if (plansJsonStr != null && plansJsonStr.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(plansJsonStr);
        _membershipPlans = decoded.map((item) => MembershipPlan.fromJson(item)).toList();
      } else {
        _initDefaultPlans();
      }

      // Load Workouts
      final workoutsJsonStr = prefs.getString('workouts_data');
      if (workoutsJsonStr != null && workoutsJsonStr.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(workoutsJsonStr);
        _workouts = decoded.map((item) => Workout.fromJson(item)).toList();
      } else {
        _initDefaultWorkouts();
      }

      // Load Expenses
      final expensesJsonStr = prefs.getString('expenses_data');
      if (expensesJsonStr != null && expensesJsonStr.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(expensesJsonStr);
        _expenses = decoded.map((item) => Expense.fromJson(item)).toList();
      } else {
        _initDefaultExpenses();
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading data from SharedPreferences: $e');
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
      await prefs.setString('trainers_data', jsonEncode(_trainers.map((t) => t.toJson()).toList()));
      await prefs.setString('plans_data', jsonEncode(_membershipPlans.map((p) => p.toJson()).toList()));
      await prefs.setString('workouts_data', jsonEncode(_workouts.map((w) => w.toJson()).toList()));
      await prefs.setString('expenses_data', jsonEncode(_expenses.map((e) => e.toJson()).toList()));
    } catch (e) {
      debugPrint('Error saving data to SharedPreferences: $e');
    }
  }

  // --- DEFAULT INITIALIZERS ---
  void _initDefaultMembers() {
    _members = [
      Member(id: 'GYM1001', name: 'Rahul Kumar', status: 'Active', avatarUrl: 'https://i.pravatar.cc/150?img=11', plan: 'Monthly Plan'),
      Member(id: 'GYM1002', name: 'Suresh Patel', status: 'Active', avatarUrl: 'https://i.pravatar.cc/150?img=12', plan: 'Yearly Plan'),
      Member(id: 'GYM1003', name: 'Manoj Sharma', status: 'Active', avatarUrl: 'https://i.pravatar.cc/150?img=13', plan: 'Quarterly Plan'),
      Member(id: 'GYM1004', name: 'Kiran Yadav', status: 'Due', avatarUrl: 'https://i.pravatar.cc/150?img=5', paidAmount: 500, plan: 'Monthly Plan'),
      Member(id: 'GYM1005', name: 'Prakash Verma', status: 'Expired', avatarUrl: 'https://i.pravatar.cc/150?img=15', plan: 'Monthly Plan'),
      Member(id: 'GYM1006', name: 'Amit Singh', status: 'Active', avatarUrl: 'https://i.pravatar.cc/150?img=16', plan: 'Quarterly Plan'),
    ];
  }

  void _initDefaultTrainers() {
    _trainers = [
      Trainer(id: 'TRN101', name: 'Vikram Singh', phone: '+91 9876500001', specialization: 'Bodybuilding & Powerlifting', experience: '5 Years', joiningDate: '15 Jan 2024', status: 'Active'),
      Trainer(id: 'TRN102', name: 'Ananya Roy', phone: '+91 9876500002', specialization: 'Cardio & Crossfit', experience: '3 Years', joiningDate: '01 Jun 2025', status: 'Active'),
    ];
  }

  void _initDefaultPlans() {
    _membershipPlans = [
      MembershipPlan(id: 'PLN101', name: 'Monthly Plan', duration: '1 Month', price: 1500, description: 'Access to full gym equipment and cardio zone.', status: 'Active'),
      MembershipPlan(id: 'PLN102', name: 'Quarterly Plan', duration: '3 Months', price: 4000, description: 'Includes 3 months workout plan & steam bath access.', status: 'Active'),
      MembershipPlan(id: 'PLN103', name: 'Yearly Plan', duration: '1 Year', price: 12000, description: 'Full annual membership with 2 free personal training sessions.', status: 'Active'),
    ];
  }

  void _initDefaultWorkouts() {
    _workouts = [
      Workout(id: 'WKO101', name: 'Bench Press', muscleGroup: 'Chest', sets: 4, reps: 10, duration: '15 mins', instructions: 'Keep feet flat on ground, lower bar to mid-chest slowly.'),
      Workout(id: 'WKO102', name: 'Lat Pulldown', muscleGroup: 'Back', sets: 3, reps: 12, duration: '12 mins', instructions: 'Pull bar down to upper chest, squeeze shoulder blades.'),
      Workout(id: 'WKO103', name: 'Barbell Squats', muscleGroup: 'Legs', sets: 4, reps: 8, duration: '20 mins', instructions: 'Break at hips, squat to parallel, keep back straight.'),
      Workout(id: 'WKO104', name: 'Bicep Concentration Curls', muscleGroup: 'Arms', sets: 3, reps: 12, duration: '10 mins', instructions: 'Rest elbow on inner thigh, curl weight with full range.'),
    ];
  }

  void _initDefaultExpenses() {
    _expenses = [
      Expense(id: 'EXP101', name: 'Electricity Bill', amount: 3500, category: 'Utilities', date: '2026-08-28', notes: 'Monthly power bill for AC and machines.'),
      Expense(id: 'EXP102', name: 'Dumbbell Set Maintenance', amount: 1200, category: 'Maintenance', date: '2026-08-30', notes: 'Replaced rubber grips on 15kg dumbbells.'),
    ];
  }

  // --- MEMBER CRUD ---
  void addMember(String name, String status, String plan) {
    final randId = 'GYM${1000 + Random().nextInt(9000)}';
    final randImgId = 1 + Random().nextInt(70);
    final newMember = Member(
      id: randId,
      name: name,
      status: status,
      plan: plan,
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

  // --- TRAINER CRUD ---
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

  // --- MEMBERSHIP PLAN CRUD ---
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

  // --- WORKOUT CRUD ---
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

  // --- EXPENSE CRUD ---
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

  // --- SETTINGS CRUD ---
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

  // --- BACKUP & RESTORE ---
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
      if (decoded.containsKey('settings')) {
        final st = decoded['settings'];
        _gymName = st['gymName'] ?? _gymName;
        _gymPhone = st['gymPhone'] ?? _gymPhone;
        _currencySymbol = st['currencySymbol'] ?? _currencySymbol;
        _isDarkMode = st['isDarkMode'] ?? _isDarkMode;
        _notificationsEnabled = st['notificationsEnabled'] ?? _notificationsEnabled;
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
