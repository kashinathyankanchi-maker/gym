import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/gym_provider.dart';
import '../../models/workout.dart';

class AddEditWorkoutScreen extends StatefulWidget {
  final Workout? workout;

  const AddEditWorkoutScreen({super.key, this.workout});

  @override
  State<AddEditWorkoutScreen> createState() => _AddEditWorkoutScreenState();
}

class _AddEditWorkoutScreenState extends State<AddEditWorkoutScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _setsController;
  late TextEditingController _repsController;
  late TextEditingController _durationController;
  late TextEditingController _instructionsController;
  String _muscleGroup = 'Chest';

  final List<String> _muscleGroups = ['Chest', 'Back', 'Legs', 'Arms', 'Core', 'Full Body'];

  bool get isEditing => widget.workout != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.workout?.name ?? '');
    _setsController = TextEditingController(text: widget.workout?.sets.toString() ?? '3');
    _repsController = TextEditingController(text: widget.workout?.reps.toString() ?? '12');
    _durationController = TextEditingController(text: widget.workout?.duration ?? '15 mins');
    _instructionsController = TextEditingController(text: widget.workout?.instructions ?? '');
    _muscleGroup = widget.workout?.muscleGroup ?? 'Chest';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _setsController.dispose();
    _repsController.dispose();
    _durationController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<GymProvider>(context, listen: false);
      final id = isEditing ? widget.workout!.id : 'WKO${100 + Random().nextInt(900)}';

      final newWorkout = Workout(
        id: id,
        name: _nameController.text.trim(),
        muscleGroup: _muscleGroup,
        sets: int.tryParse(_setsController.text.trim()) ?? 3,
        reps: int.tryParse(_repsController.text.trim()) ?? 12,
        duration: _durationController.text.trim(),
        instructions: _instructionsController.text.trim(),
      );

      if (isEditing) {
        provider.updateWorkout(newWorkout);
      } else {
        provider.addWorkout(newWorkout);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Exercise' : 'Add Exercise'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Exercise Name'),
              TextFormField(
                controller: _nameController,
                validator: (v) => v == null || v.isEmpty ? 'Enter exercise name' : null,
                decoration: _buildInputDecoration('e.g. Bench Press, Incline Dumbbell Fly'),
              ),
              const SizedBox(height: 16),
              _buildLabel('Muscle Group'),
              DropdownButtonFormField<String>(
                value: _muscleGroup,
                decoration: _buildInputDecoration(''),
                items: _muscleGroups
                    .map((mg) => DropdownMenuItem(value: mg, child: Text(mg)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _muscleGroup = val);
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Sets'),
                        TextFormField(
                          controller: _setsController,
                          keyboardType: TextInputType.number,
                          decoration: _buildInputDecoration('3'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Reps'),
                        TextFormField(
                          controller: _repsController,
                          keyboardType: TextInputType.number,
                          decoration: _buildInputDecoration('12'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildLabel('Duration'),
              TextFormField(
                controller: _durationController,
                decoration: _buildInputDecoration('e.g. 15 mins'),
              ),
              const SizedBox(height: 16),
              _buildLabel('Instructions'),
              TextFormField(
                controller: _instructionsController,
                maxLines: 4,
                decoration: _buildInputDecoration('Step by step guide to perform exercise safely...'),
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
                    isEditing ? 'Update Exercise' : 'Save Exercise',
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
