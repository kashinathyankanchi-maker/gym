import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/gym_provider.dart';

class BackupRestoreScreen extends StatefulWidget {
  const BackupRestoreScreen({super.key});

  @override
  State<BackupRestoreScreen> createState() => _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends State<BackupRestoreScreen> {
  final TextEditingController _restoreTextController = TextEditingController();
  bool _isProcessing = false;

  Future<void> _backupToStorage(GymProvider provider) async {
    setState(() => _isProcessing = true);
    final path = await provider.backupToMobileStorage();
    setState(() => _isProcessing = false);

    if (path != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Backup saved successfully to:\n$path'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 4),
        ),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save backup to mobile storage'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _restoreFromStorage(GymProvider provider) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restore from Mobile Storage'),
        content: const Text(
          'This will search your device\'s "Hemant Gym" folder for saved backup data and restore all members, attendance, payments, trainers, and settings.\n\nDo you wish to proceed?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _isProcessing = true);
              final success = await provider.restoreFromMobileStorage();
              setState(() => _isProcessing = false);

              if (!mounted) return;
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Old app data successfully restored from "Hemant Gym" folder!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('No backup file found in "Hemant Gym" folder on mobile storage.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.green),
            child: const Text('Restore Now', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _copyBackupToClipboard(GymProvider provider) {
    final jsonStr = provider.exportBackupJson();
    Clipboard.setData(ClipboardData(text: jsonStr));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Backup JSON copied to clipboard!')),
    );
  }

  void _confirmRestoreFromClipboard(GymProvider provider) {
    final rawText = _restoreTextController.text.trim();
    if (rawText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please paste backup JSON data to restore')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Restore Data'),
        content: const Text(
          'WARNING: This will replace all current app members, trainers, plans, workouts, expenses, and settings with the restored data.\n\nDo you wish to proceed?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              final success = provider.importBackupJson(rawText);
              if (success) {
                _restoreTextController.clear();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('App data successfully restored!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Invalid or corrupted backup JSON data!'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Restore Data'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gymProvider = Provider.of<GymProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FE),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Backup & Restore',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Folder Location Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE8E5FF),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF6236FF)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.folder_special, color: Color(0xFF6236FF), size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Mobile Storage Folder: "Hemant Gym"',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF6236FF)),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'All data is automatically backed up to the "Hemant Gym" folder in mobile storage. When you reinstall or update the app, old data is auto-restored!',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Card 1: Mobile Storage Backup & Restore Buttons
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.sd_card, color: Color(0xFF6236FF)),
                      SizedBox(width: 10),
                      Text(
                        'Mobile Storage Sync',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Save backup directly to your device storage or restore old data after reinstalling the app.',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                  const SizedBox(height: 16),

                  // Backup to Mobile Storage Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _isProcessing ? null : () => _backupToStorage(gymProvider),
                      icon: const Icon(Icons.save_alt, color: Colors.white),
                      label: const Text('Backup to "Hemant Gym" Folder', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6236FF),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Restore from Mobile Storage Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: _isProcessing ? null : () => _restoreFromStorage(gymProvider),
                      icon: const Icon(Icons.settings_backup_restore, color: Color(0xFF4CAF50)),
                      label: const Text('Restore from "Hemant Gym" Folder', style: TextStyle(color: Color(0xFF4CAF50), fontWeight: FontWeight.bold, fontSize: 14)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF4CAF50), width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Card 2: Manual JSON Export (Clipboard)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.content_copy, color: Colors.grey),
                      SizedBox(width: 10),
                      Text(
                        'Clipboard JSON Backup',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Copy backup JSON text to transfer data manually to another device.',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: OutlinedButton.icon(
                      onPressed: () => _copyBackupToClipboard(gymProvider),
                      icon: const Icon(Icons.copy),
                      label: const Text('Copy Backup JSON to Clipboard'),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Card 3: Manual JSON Restore (Text input)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.paste, color: Colors.orange),
                      SizedBox(width: 10),
                      Text(
                        'Manual JSON Restore',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _restoreTextController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Paste backup JSON string here...',
                      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: OutlinedButton.icon(
                      onPressed: () => _confirmRestoreFromClipboard(gymProvider),
                      icon: const Icon(Icons.restore, color: Colors.orange),
                      label: const Text('Restore from Text', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.orange),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
