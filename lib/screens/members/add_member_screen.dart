import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/gym_provider.dart';

class AddMemberScreen extends StatefulWidget {
  const AddMemberScreen({super.key});

  @override
  State<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends State<AddMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _feesController = TextEditingController(text: '1500');
  final _paidController = TextEditingController(text: '1500');
  final _expiryController = TextEditingController(text: '30 Sep 2026');

  String? _selectedPlan;
  String _selectedStatus = 'Active';

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _feesController.dispose();
    _paidController.dispose();
    _expiryController.dispose();
    super.dispose();
  }

  void _saveMember() {
    if (_formKey.currentState!.validate()) {
      final planToSave = _selectedPlan ?? 'Monthly Plan';
      final todayStr = '01 Sep 2026';

      Provider.of<GymProvider>(context, listen: false).addMember(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim().isEmpty ? '+91 9876543210' : _phoneController.text.trim(),
        plan: planToSave,
        status: _selectedStatus,
        totalFees: double.tryParse(_feesController.text.trim()) ?? 1500,
        paidAmount: double.tryParse(_paidController.text.trim()) ?? 1500,
        joinDate: todayStr,
        expiryDate: _expiryController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New member added successfully!'), backgroundColor: Colors.green),
      );

      Navigator.pop(context);
    }
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Full Name', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                validator: (v) => v == null || v.isEmpty ? 'Please enter member name' : null,
                decoration: InputDecoration(
                  hintText: 'Enter full name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Phone Number', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: '+91 9876543210',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
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
                  if (val != null) {
                    setState(() {
                      _selectedPlan = val;
                      final match = plans.firstWhere((p) => p.name == val, orElse: () => plans.first);
                      _feesController.text = match.price.toInt().toString();
                      _paidController.text = match.price.toInt().toString();
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
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
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total Fees', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _feesController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Paid Amount', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _paidController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Expiry Date', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _expiryController,
                decoration: InputDecoration(
                  hintText: 'e.g. 30 Sep 2026',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 32),
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
      ),
    );
  }
}
