import 'package:flutter/material.dart';

import 'trainers_screen.dart';
import 'membership_plans_screen.dart';
import 'workout_library_screen.dart';
import 'expenses_screen.dart';
import 'communication_screen.dart';
import 'backup_restore_screen.dart';
import 'settings_screen.dart';
import 'help_support_screen.dart';
import 'about_app_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  final List<Map<String, dynamic>> _menuItems = const [
    {'icon': Icons.people, 'title': 'Trainers', 'screen': TrainersScreen()},
    {'icon': Icons.list_alt, 'title': 'Membership Plans', 'screen': MembershipPlansScreen()},
    {'icon': Icons.fitness_center, 'title': 'Workout Library', 'screen': WorkoutLibraryScreen()},
    {'icon': Icons.receipt, 'title': 'Expenses', 'screen': ExpensesScreen()},
    {'icon': Icons.chat, 'title': 'Communication', 'screen': CommunicationScreen()},
    {'icon': Icons.cloud, 'title': 'Backup & Restore', 'screen': BackupRestoreScreen()},
    {'icon': Icons.settings, 'title': 'Settings', 'screen': SettingsScreen()},
    {'icon': Icons.help_outline, 'title': 'Help & Support', 'screen': HelpSupportScreen()},
    {'icon': Icons.info_outline, 'title': 'About App', 'screen': AboutAppScreen()},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('More'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _menuItems.length,
        separatorBuilder: (context, index) => Divider(color: Colors.grey.shade200, height: 1),
        itemBuilder: (context, index) {
          final item = _menuItems[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            leading: Icon(item['icon'], color: Colors.grey.shade700, size: 24),
            title: Text(
              item['title'],
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
            ),
            trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => item['screen'] as Widget),
              );
            },
          );
        },
      ),
    );
  }
}
