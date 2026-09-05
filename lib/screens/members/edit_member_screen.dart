import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/gym_provider.dart';
import '../../models/member.dart';

class EditMemberScreen extends StatefulWidget {
  final Member member;

  const EditMemberScreen({super.key, required this.member});

  @override
  State<EditMemberScreen> createState() => _EditMemberScreenState();
}

class _EditMemberScreenState extends State<EditMemberScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _feesController;
  late TextEditingController _paidController;
  late TextEditingController _expiryController;
  late String _selectedPlan;
  late String _selectedStatus;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.member.name);
    _phoneController = TextEditingController(text: widget.member.phone);
    _feesController = TextEditingController(text: widget.member.totalFees.toInt().toString());
    _paidController = TextEditingController(text: widget.member.paidAmount.toInt().toString());
    _expiryController = TextEditingController(text: widget.member.expiryDate);
    _selectedPlan = widget.member.plan;
    _selectedStatus = widget.member.status;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _feesController.dispose();
    _paidController.dispose();
    _expiryController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<GymProvider>(context, listen: false);
      final updated = Member(
        id: widget.member.id,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        status: _selectedStatus,
        avatarUrl: widget.member.avatarUrl,
        plan: _selectedPlan,
        joinDate: widget.member.joinDate,
        expiryDate: _expiryController.text.trim(),
        totalFees: double.tryParse(_feesController.text.trim()) ?? widget.member.totalFees,
        paidAmount: double.tryParse(_paidController.text.trim()) ?? widget.member.paidAmount,
      );

      provider.updateMember(updated);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Member details updated!'), backgroundColor: Colors.green),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final gymProvider = Provider.of<GymProvider>(context);
    final plans = gymProvider.membershipPlans;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Member'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Full Name'),
              TextFormField(
                controller: _nameController,
                validator: (v) => v == null || v.isEmpty ? 'Enter full name' : null,
                decoration: _buildInputDecoration('Name'),
              ),
              const SizedBox(height: 16),
              _buildLabel('Phone Number'),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: _buildInputDecoration('Phone'),
              ),
              const SizedBox(height: 16),
              _buildLabel('Membership Plan'),
              DropdownButtonFormField<String>(
                value: plans.any((p) => p.name == _selectedPlan) ? _selectedPlan : (plans.isNotEmpty ? plans.first.name : 'Monthly Plan'),
                decoration: _buildInputDecoration(''),
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
              const SizedBox(height: 16),
              _buildLabel('Status'),
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: _buildInputDecoration(''),
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
                        _buildLabel('Total Fees'),
                        TextFormField(
                          controller: _feesController,
                          keyboardType: TextInputType.number,
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
                        _buildLabel('Paid Amount'),
                        TextFormField(
                          controller: _paidController,
                          keyboardType: TextInputType.number,
                          decoration: _buildInputDecoration('1000'),
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
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6236FF),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Update Member', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
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
