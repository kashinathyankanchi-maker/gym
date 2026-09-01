import 'package:flutter/material.dart';


class WorkoutPlanScreen extends StatelessWidget {
  final Map<String, dynamic> memberData;

  const WorkoutPlanScreen({super.key, required this.memberData});

  final List<Map<String, dynamic>> _exercises = const [
    {
      'name': 'Bench Press',
      'sets': '4 Sets × 10 Reps',
      'weight': '40 KG',
      'completed': true,
      'image': 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?q=80&w=150&auto=format&fit=crop',
    },
    {
      'name': 'Incline Dumbbell Press',
      'sets': '3 Sets × 12 Reps',
      'weight': '12 KG',
      'completed': true,
      'image': 'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?q=80&w=150&auto=format&fit=crop',
    },
    {
      'name': 'Cable Fly',
      'sets': '3 Sets × 15 Reps',
      'weight': '15 KG',
      'completed': true,
      'image': 'https://images.unsplash.com/photo-1534438097544-e3498845e28a?q=80&w=150&auto=format&fit=crop',
    },
    {
      'name': 'Push Ups',
      'sets': '3 Sets × 15 Reps',
      'weight': 'Body Weight',
      'completed': true,
      'image': 'https://images.unsplash.com/photo-1598971639058-fab354c622fb?q=80&w=150&auto=format&fit=crop',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Workout Plan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () {},
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Card
            Container(
              margin: const EdgeInsets.all(16),
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: const DecorationImage(
                  image: NetworkImage('https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?q=80&w=600&auto=format&fit=crop'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(Colors.black54, BlendMode.darken),
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    memberData['name'] ?? 'Rahul Kumar',
                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Chest Day',
                    style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6236FF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Day 1 of 5',
                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),

            // Exercise List
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _exercises.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final exercise = _exercises[index];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          exercise['image'],
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              exercise['name'],
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              exercise['sets'],
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              exercise['weight'],
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      if (exercise['completed'])
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check, color: Colors.white, size: 16),
                        )
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.check),
          label: const Text('Workout Completed', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}
