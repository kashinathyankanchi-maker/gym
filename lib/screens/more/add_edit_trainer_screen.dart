import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/gym_provider.dart';
import '../../models/trainer.dart';

class AddEditTrainerScreen extends StatefulWidget {
  final Trainer? trainer;

  const AddEditTrainerScreen({super.key, this.trainer});

  @override
  State<AddEditTrainerScreen> createState() => _AddEditTrainerScreenState();
}

class _AddEditTrainerScreenState extends State<AddEditTrainerScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _specController;
  late TextEditingController _expController;
  late TextEditingController _joiningDateController;
  String _status = 'Active';

  bool get isEditing => widget.trainer != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.trainer?.name ?? '');
    _phoneController = TextEditingController(text: widget.trainer?.phone ?? '');
    _specController = TextEditingController(text: widget.trainer?.specialization ?? '');
    _expController = TextEditingController(text: widget.trainer?.experience ?? '');
    _joiningDateController = TextEditingController(text: widget.trainer?.joiningDate ?? '01 Jan 2026');
    _status = widget.trainer?.status ?? 'Active';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _specController.dispose();
    _expController.dispose();
    _joiningDateController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<GymProvider>(context, listen: false);
      final id = isEditing ? widget.trainer!.id : 'TRN${100 + Random().nextInt(900)}';

      final newTrainer = Trainer(
        id: id,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        specialization: _specController.text.trim(),
        experience: _expController.text.trim(),
        joiningDate: _joiningDateController.text.trim(),
        status: _status,
      );

      if (isEditing) {
        provider.updateTrainer(newTrainer);
      } else {
        provider.addTrainer(newTrainer);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Trainer' : 'Add Trainer'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Trainer Name'),
              TextFormField(
                controller: _nameController,
                validator: (v) => v == null || v.isEmpty ? 'Enter trainer name' : null,
                decoration: _buildInputDecoration('e.g. Vikram Singh'),
              ),
              const SizedBox(height: 16),
              _buildLabel('Phone Number'),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                validator: (v) => v == null || v.isEmpty ? 'Enter phone number' : null,
                decoration: _buildInputDecoration('e.g. +91 9876543210'),
              ),
              const SizedBox(height: 16),
              _buildLabel('Specialization'),
              TextFormField(
                controller: _specController,
                validator: (v) => v == null || v.isEmpty ? 'Enter specialization' : null,
                decoration: _buildInputDecoration('e.g. Powerlifting & Calisthenics'),
              ),
              const SizedBox(height: 16),
              _buildLabel('Experience'),
              TextFormField(
                controller: _expController,
                decoration: _buildInputDecoration('e.g. 4 Years'),
              ),
              const SizedBox(height: 16),
              _buildLabel('Joining Date'),
              TextFormField(
                controller: _joiningDateController,
                decoration: _buildInputDecoration('e.g. 01 Jan 2026'),
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
                    isEditing ? 'Update Trainer' : 'Save Trainer',
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
