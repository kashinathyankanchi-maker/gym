import 'package:flutter/material.dart';


class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  final List<Map<String, dynamic>> _menuItems = const [
    {'icon': Icons.people, 'title': 'Trainers'},
    {'icon': Icons.list_alt, 'title': 'Membership Plans'},
    {'icon': Icons.fitness_center, 'title': 'Workout Library'},
    {'icon': Icons.receipt, 'title': 'Expenses'},
    {'icon': Icons.chat, 'title': 'Communication'},
    {'icon': Icons.cloud, 'title': 'Backup & Restore'},
    {'icon': Icons.settings, 'title': 'Settings'},
    {'icon': Icons.help_outline, 'title': 'Help & Support'},
    {'icon': Icons.info_outline, 'title': 'About App'},
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
            onTap: () {},
          );
        },
      ),
    );
  }
}
