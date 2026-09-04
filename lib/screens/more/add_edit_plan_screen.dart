import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/gym_provider.dart';
import '../../models/membership_plan.dart';

class AddEditPlanScreen extends StatefulWidget {
  final MembershipPlan? plan;

  const AddEditPlanScreen({super.key, this.plan});

  @override
  State<AddEditPlanScreen> createState() => _AddEditPlanScreenState();
}

class _AddEditPlanScreenState extends State<AddEditPlanScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _durationController;
  late TextEditingController _priceController;
  late TextEditingController _descController;
  String _status = 'Active';

  bool get isEditing => widget.plan != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.plan?.name ?? '');
    _durationController = TextEditingController(text: widget.plan?.duration ?? '1 Month');
    _priceController = TextEditingController(text: widget.plan?.price != null ? widget.plan!.price.toInt().toString() : '');
    _descController = TextEditingController(text: widget.plan?.description ?? '');
    _status = widget.plan?.status ?? 'Active';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _durationController.dispose();
    _priceController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<GymProvider>(context, listen: false);
      final id = isEditing ? widget.plan!.id : 'PLN${100 + Random().nextInt(900)}';

      final newPlan = MembershipPlan(
        id: id,
        name: _nameController.text.trim(),
        duration: _durationController.text.trim(),
        price: double.tryParse(_priceController.text.trim()) ?? 0.0,
        description: _descController.text.trim(),
        status: _status,
      );

      if (isEditing) {
        provider.updatePlan(newPlan);
      } else {
        provider.addPlan(newPlan);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Membership Plan' : 'Add Membership Plan'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Plan Name'),
              TextFormField(
                controller: _nameController,
                validator: (v) => v == null || v.isEmpty ? 'Enter plan name' : null,
                decoration: _buildInputDecoration('e.g. Monthly Plan, VIP Yearly'),
              ),
              const SizedBox(height: 16),
              _buildLabel('Duration'),
              TextFormField(
                controller: _durationController,
                validator: (v) => v == null || v.isEmpty ? 'Enter duration' : null,
                decoration: _buildInputDecoration('e.g. 1 Month, 6 Months, 1 Year'),
              ),
              const SizedBox(height: 16),
              _buildLabel('Price'),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? 'Enter price' : null,
                decoration: _buildInputDecoration('e.g. 1500'),
              ),
              const SizedBox(height: 16),
              _buildLabel('Description'),
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: _buildInputDecoration('Features included in this plan...'),
              ),
              const SizedBox(height: 16),
              _buildLabel('Status'),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: _buildInputDecoration(''),
                items: const [
                  DropdownMenuItem(value: 'Active', child: Text('Active')),
                  DropdownMenuItem(value: 'Inactive', child: Text('Inactive')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _status = val);
                },
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
                  child: Text(
                    isEditing ? 'Update Plan' : 'Save Plan',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
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
      padding: const EdgeInsets.only(bottom: 8.0),
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
