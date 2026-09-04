import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/gym_provider.dart';
import '../../models/expense.dart';

class AddEditExpenseScreen extends StatefulWidget {
  final Expense? expense;

  const AddEditExpenseScreen({super.key, this.expense});

  @override
  State<AddEditExpenseScreen> createState() => _AddEditExpenseScreenState();
}

class _AddEditExpenseScreenState extends State<AddEditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _amountController;
  late TextEditingController _dateController;
  late TextEditingController _notesController;
  String _category = 'Utilities';

  final List<String> _categories = [
    'Utilities',
    'Equipment',
    'Rent',
    'Maintenance',
    'Salaries',
    'Other'
  ];

  bool get isEditing => widget.expense != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.expense?.name ?? '');
    _amountController = TextEditingController(text: widget.expense?.amount != null ? widget.expense!.amount.toInt().toString() : '');
    _dateController = TextEditingController(text: widget.expense?.date ?? DateTime.now().toString().split(' ')[0]);
    _notesController = TextEditingController(text: widget.expense?.notes ?? '');
    _category = widget.expense?.category ?? 'Utilities';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _dateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<GymProvider>(context, listen: false);
      final id = isEditing ? widget.expense!.id : 'EXP${100 + Random().nextInt(900)}';

      final newExpense = Expense(
        id: id,
        name: _nameController.text.trim(),
        amount: double.tryParse(_amountController.text.trim()) ?? 0.0,
        category: _category,
        date: _dateController.text.trim(),
        notes: _notesController.text.trim(),
      );

      if (isEditing) {
        provider.updateExpense(newExpense);
      } else {
        provider.addExpense(newExpense);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Expense' : 'Add Expense'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Expense Name'),
              TextFormField(
                controller: _nameController,
                validator: (v) => v == null || v.isEmpty ? 'Enter expense title' : null,
                decoration: _buildInputDecoration('e.g. Electricity Bill, Dumbbell repair'),
              ),
              const SizedBox(height: 16),
              _buildLabel('Amount'),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? 'Enter amount' : null,
                decoration: _buildInputDecoration('e.g. 2500'),
              ),
              const SizedBox(height: 16),
              _buildLabel('Category'),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: _buildInputDecoration(''),
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _category = val);
                },
              ),
              const SizedBox(height: 16),
              _buildLabel('Date'),
              TextFormField(
                controller: _dateController,
                decoration: _buildInputDecoration('YYYY-MM-DD'),
              ),
              const SizedBox(height: 16),
              _buildLabel('Notes'),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: _buildInputDecoration('Optional notes or receipt references...'),
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
                    isEditing ? 'Update Expense' : 'Save Expense',
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
