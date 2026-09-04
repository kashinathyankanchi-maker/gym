import 'package:flutter/material.dart';
import '../models/member.dart';
import 'dart:math';

class GymProvider extends ChangeNotifier {
  List<Member> _members = [
    Member(
      id: 'GYM1001',
      name: 'Rahul Kumar',
      status: 'Active',
      avatarUrl: 'https://i.pravatar.cc/150?img=11',
    ),
    Member(
      id: 'GYM1002',
      name: 'Suresh Patel',
      status: 'Active',
      avatarUrl: 'https://i.pravatar.cc/150?img=12',
    ),
    Member(
      id: 'GYM1003',
      name: 'Manoj Sharma',
      status: 'Active',
      avatarUrl: 'https://i.pravatar.cc/150?img=13',
    ),
    Member(
      id: 'GYM1004',
      name: 'Kiran Yadav',
      status: 'Due',
      avatarUrl: 'https://i.pravatar.cc/150?img=5',
      paidAmount: 500,
    ),
    Member(
      id: 'GYM1005',
      name: 'Prakash Verma',
      status: 'Expired',
      avatarUrl: 'https://i.pravatar.cc/150?img=15',
    ),
    Member(
      id: 'GYM1006',
      name: 'Amit Singh',
      status: 'Active',
      avatarUrl: 'https://i.pravatar.cc/150?img=16',
    ),
  ];

  List<Member> get members => _members;
  int get totalMembers => _members.length;
  int get activeMembers => _members.where((m) => m.status == 'Active').length;
  int get dueMembers => _members.where((m) => m.status == 'Due').length;
  int get expiredMembers => _members.where((m) => m.status == 'Expired').length;
  
  double get totalCollection => _members.fold(0, (sum, item) => sum + item.paidAmount);

  void addMember(String name, String status, String plan) {
    // Generate a random ID and avatar
    final randId = 'GYM${1000 + Random().nextInt(9000)}';
    final randImgId = 1 + Random().nextInt(70);
    
    final newMember = Member(
      id: randId,
      name: name,
      status: status,
      plan: plan,
      avatarUrl: 'https://i.pravatar.cc/150?img=$randImgId',
    );
    
    _members.insert(0, newMember); // add to top
    notifyListeners();
  }

  void deleteMember(String id) {
    _members.removeWhere((m) => m.id == id);
    notifyListeners();
  }
}
