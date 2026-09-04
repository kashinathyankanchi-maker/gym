class Workout {
  final String id;
  final String name;
  final String muscleGroup; // e.g. "Chest", "Back", "Legs", "Arms", "Core", "Full Body"
  final int sets;
  final int reps;
  final String duration; // e.g. "15 mins"
  final String instructions;

  Workout({
    required this.id,
    required this.name,
    required this.muscleGroup,
    required this.sets,
    required this.reps,
    required this.duration,
    required this.instructions,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'muscleGroup': muscleGroup,
        'sets': sets,
        'reps': reps,
        'duration': duration,
        'instructions': instructions,
      };

  factory Workout.fromJson(Map<String, dynamic> json) => Workout(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        muscleGroup: json['muscleGroup'] ?? 'General',
        sets: json['sets'] ?? 3,
        reps: json['reps'] ?? 12,
        duration: json['duration'] ?? '15 mins',
        instructions: json['instructions'] ?? '',
      );
}
