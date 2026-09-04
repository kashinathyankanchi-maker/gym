import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/gym_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _gymNameController;
  late TextEditingController _gymPhoneController;
  late String _currency;
  late bool _isDarkMode;
  late bool _notificationsEnabled;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<GymProvider>(context, listen: false);
    _gymNameController = TextEditingController(text: provider.gymName);
    _gymPhoneController = TextEditingController(text: provider.gymPhone);
    _currency = provider.currencySymbol;
    _isDarkMode = provider.isDarkMode;
    _notificationsEnabled = provider.notificationsEnabled;
  }

  @override
  void dispose() {
    _gymNameController.dispose();
    _gymPhoneController.dispose();
    super.dispose();
  }

  void _saveSettings() {
    Provider.of<GymProvider>(context, listen: false).updateSettings(
      gymName: _gymNameController.text.trim(),
      gymPhone: _gymPhoneController.text.trim(),
      currencySymbol: _currency,
      isDarkMode: _isDarkMode,
      notificationsEnabled: _notificationsEnabled,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings saved successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gym Profile Settings',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            _buildLabel('Gym Name'),
            TextField(
              controller: _gymNameController,
              decoration: _buildInputDecoration('e.g. Hemant Gym'),
            ),
            const SizedBox(height: 16),
            _buildLabel('Gym Phone Number'),
            TextField(
              controller: _gymPhoneController,
              keyboardType: TextInputType.phone,
              decoration: _buildInputDecoration('e.g. +91 9876543210'),
            ),

            const SizedBox(height: 24),
            const Text(
              'Preferences & Currency',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            _buildLabel('Currency Symbol'),
            DropdownButtonFormField<String>(
              value: _currency,
              decoration: _buildInputDecoration(''),
              items: const [
                DropdownMenuItem(value: '₹', child: Text('₹ (INR - Rupee)')),
                DropdownMenuItem(value: '\$', child: Text('\$ (USD - Dollar)')),
                DropdownMenuItem(value: '€', child: Text('€ (EUR - Euro)')),
                DropdownMenuItem(value: '£', child: Text('£ (GBP - Pound)')),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _currency = val);
              },
            ),

            const SizedBox(height: 24),
            const Text(
              'App Behavior',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Push Notifications'),
              subtitle: const Text('Fee reminders & membership alerts'),
              value: _notificationsEnabled,
              activeColor: const Color(0xFF6236FF),
              onChanged: (val) => setState(() => _notificationsEnabled = val),
            ),
            SwitchListTile(
              title: const Text('Dark Mode Theme'),
              subtitle: const Text('Enable dark color theme'),
              value: _isDarkMode,
              activeColor: const Color(0xFF6236FF),
              onChanged: (val) => setState(() => _isDarkMode = val),
            ),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6236FF),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Save Settings', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
