import 'package:flutter/material.dart';

import 'dashboard/dashboard_screen.dart';
import 'members/members_screen.dart';
import 'attendance/attendance_screen.dart';
import 'fees/fees_screen.dart';
import 'more/more_screen.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;
  final int initialMemberTab;

  const MainScreen({
    super.key,
    this.initialIndex = 0,
    this.initialMemberTab = 0,
  });

  static void switchTab(BuildContext context, int index, {int memberTab = 0}) {
    final state = context.findAncestorStateOfType<_MainScreenState>();
    state?.navigateToTab(index, memberTab: memberTab);
  }

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex;
  late int _memberTabFilter;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _memberTabFilter = widget.initialMemberTab;
  }

  void navigateToTab(int index, {int memberTab = 0}) {
    setState(() {
      _currentIndex = index;
      _memberTabFilter = memberTab;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const DashboardScreen(),
      MembersScreen(initialTab: _memberTabFilter),
      const AttendanceScreen(),
      const FeesScreen(),
      const MoreScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Colors.grey.shade400,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: 'Members',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.access_time),
              label: 'Attendance',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.attach_money),
              label: 'Fees',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu),
              label: 'More',
            ),
          ],
        ),
      ),
    );
  }
}
