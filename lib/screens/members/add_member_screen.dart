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
  final _dobController = TextEditingController();
  final _joinDateController = TextEditingController(text: '01 Sep 2026');
  final _durationController = TextEditingController(text: '1 Month');
  final _feesController = TextEditingController(text: '1500');
  final _paidController = TextEditingController(text: '1500');
  final _expiryController = TextEditingController(text: '30 Sep 2026');
  final _notesController = TextEditingController();

  String? _selectedPlan;
  String _selectedStatus = 'Active';

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _joinDateController.dispose();
    _durationController.dispose();
    _feesController.dispose();
    _paidController.dispose();
    _expiryController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _saveMember() {
    if (_formKey.currentState!.validate()) {
      final planToSave = _selectedPlan ?? 'Monthly Plan';

      Provider.of<GymProvider>(context, listen: false).addMember(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        dob: _dobController.text.trim(),
        plan: planToSave,
        duration: _durationController.text.trim(),
        status: _selectedStatus,
        totalFees: double.tryParse(_feesController.text.trim()) ?? 1500,
        paidAmount: double.tryParse(_paidController.text.trim()) ?? 1500,
        joinDate: _joinDateController.text.trim(),
        expiryDate: _expiryController.text.trim(),
        notes: _notesController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Member added successfully!'), backgroundColor: Colors.green),
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
              _buildLabel('Full Name *'),
              TextFormField(
                controller: _nameController,
                validator: (v) => v == null || v.isEmpty ? 'Please enter member name' : null,
                decoration: _buildInputDecoration('e.g. Rahul Kumar'),
              ),
              const SizedBox(height: 16),

              _buildLabel('Phone Number *'),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                validator: (v) => v == null || v.isEmpty ? 'Please enter phone number' : null,
                decoration: _buildInputDecoration('e.g. +91 9876543210'),
              ),
              const SizedBox(height: 16),

              _buildLabel('Date of Birth (Optional)'),
              TextFormField(
                controller: _dobController,
                decoration: _buildInputDecoration('DD/MM/YYYY'),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Joining Date'),
                        TextFormField(
                          controller: _joinDateController,
                          decoration: _buildInputDecoration('01 Sep 2026'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Duration'),
                        TextFormField(
                          controller: _durationController,
                          decoration: _buildInputDecoration('1 Month'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              _buildLabel('Membership Plan'),
              DropdownButtonFormField<String>(
                value: _selectedPlan,
                decoration: _buildInputDecoration(''),
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
                      _durationController.text = match.duration;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Membership Fee *'),
                        TextFormField(
                          controller: _feesController,
                          keyboardType: TextInputType.number,
                          validator: (v) => v == null || v.isEmpty ? 'Enter fee' : null,
                          decoration: _buildInputDecoration('1500'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Amount Paid'),
                        TextFormField(
                          controller: _paidController,
                          keyboardType: TextInputType.number,
                          decoration: _buildInputDecoration('1500'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              _buildLabel('Expiry Date'),
              TextFormField(
                controller: _expiryController,
                decoration: _buildInputDecoration('30 Sep 2026'),
              ),
              const SizedBox(height: 16),

              _buildLabel('Status'),
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: _buildInputDecoration(''),
                items: const [
                  DropdownMenuItem(value: 'Active', child: Text('Active')),
                  DropdownMenuItem(value: 'Due', child: Text('Due')),
                  DropdownMenuItem(value: 'Expired', child: Text('Expired')),
                  DropdownMenuItem(value: 'Suspended', child: Text('Suspended')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedStatus = val);
                },
              ),
              const SizedBox(height: 16),

              _buildLabel('Notes (Optional)'),
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: _buildInputDecoration('Special requests or medical notes...'),
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

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
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
