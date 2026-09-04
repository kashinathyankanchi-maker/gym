import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/gym_provider.dart';

class AddMemberScreen extends StatefulWidget {
  const AddMemberScreen({super.key});

  @override
  State<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends State<AddMemberScreen> {
  final _nameController = TextEditingController();
  String? _selectedPlan;
  String _selectedStatus = 'Active';

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveMember() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a name')),
      );
      return;
    }
    
    final planToSave = _selectedPlan ?? 'Monthly Plan';

    Provider.of<GymProvider>(context, listen: false).addMember(
      _nameController.text.trim(),
      _selectedStatus,
      planToSave,
    );
    
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final gymProvider = Provider.of<GymProvider>(context);
    final plans = gymProvider.membershipPlans;

    if (_selectedPlan == null && plans.isNotEmpty) {
      _selectedPlan = plans.first.name;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Member'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Member Name', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Enter full name',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Membership Plan', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedPlan,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: plans.map((p) {
                return DropdownMenuItem<String>(
                  value: p.name,
                  child: Text('${p.name} (${gymProvider.currencySymbol}${p.price.toInt()})'),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedPlan = val);
              },
            ),
            const SizedBox(height: 24),
            const Text('Status', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: const [
                DropdownMenuItem(value: 'Active', child: Text('Active')),
                DropdownMenuItem(value: 'Due', child: Text('Due')),
                DropdownMenuItem(value: 'Expired', child: Text('Expired')),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _selectedStatus = val);
              },
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveMember,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6236FF),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Save Member', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
