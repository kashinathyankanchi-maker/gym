import 'package:flutter/material.dart';


class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  int _selectedTabIndex = 0;
  final List<String> _tabs = ['All (320)', 'Present (162)', 'Absent (158)'];

  final List<Map<String, dynamic>> _members = [
    {
      'name': 'Rahul Kumar',
      'time': '7:02 AM',
      'status': 'Present',
      'avatarUrl': 'https://i.pravatar.cc/150?img=11',
    },
    {
      'name': 'Suresh Patel',
      'time': '7:10 AM',
      'status': 'Present',
      'avatarUrl': 'https://i.pravatar.cc/150?img=12',
    },
    {
      'name': 'Manoj Sharma',
      'time': '7:18 AM',
      'status': 'Present',
      'avatarUrl': 'https://i.pravatar.cc/150?img=13',
    },
    {
      'name': 'Kiran Yadav',
      'time': '-',
      'status': 'Absent',
      'avatarUrl': 'https://i.pravatar.cc/150?img=5',
    },
    {
      'name': 'Prakash Verma',
      'time': '-',
      'status': 'Absent',
      'avatarUrl': 'https://i.pravatar.cc/150?img=15',
    },
    {
      'name': 'Amit Singh',
      'time': '-',
      'status': 'Absent',
      'avatarUrl': 'https://i.pravatar.cc/150?img=16',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {},
        ),
        title: const Text('Today\'s Attendance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () {},
          )
        ],
      ),
      body: Column(
        children: [
          // Date Selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF6236FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, color: Colors.white),
                    onPressed: () {},
                  ),
                  const Text(
                    '01 Sep 2026, Monday',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search member...',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
              ),
            ),
          ),
          
          // Tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Row(
              children: List.generate(_tabs.length, (index) {
                final isSelected = _selectedTabIndex == index;
                Color bgColor = Colors.white;
                Color textColor = Colors.grey.shade600;
                
                if (isSelected) {
                  if (index == 1) {
                    bgColor = Colors.green;
                    textColor = Colors.white;
                  } else if (index == 2) {
                    bgColor = Colors.red;
                    textColor = Colors.white;
                  } else {
                    bgColor = Colors.grey.shade800;
                    textColor = Colors.white;
                  }
                } else {
                  if (index == 1) textColor = Colors.green;
                  if (index == 2) textColor = Colors.red;
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedTabIndex = index;
                      });
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? Colors.transparent : Colors.grey.shade300,
                        ),
                      ),
                      child: Text(
                        _tabs[index],
                        style: TextStyle(
                          color: textColor,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          // Member List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _members.length,
              separatorBuilder: (context, index) => Divider(color: Colors.grey.shade200, height: 1),
              itemBuilder: (context, index) {
                final member = _members[index];
                final isPresent = member['status'] == 'Present';

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 4),
                  leading: CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(member['avatarUrl']),
                  ),
                  title: Text(
                    member['name'],
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        member['time'],
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: isPresent ? Colors.green : Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isPresent ? Colors.green : Colors.grey.shade400,
                            width: 2,
                          ),
                        ),
                        child: isPresent
                            ? const Icon(Icons.check, size: 16, color: Colors.white)
                            : null,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Bottom Summary Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              '162',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Present',
                              style: TextStyle(
                                color: Colors.green.shade700,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              '158',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Absent',
                              style: TextStyle(
                                color: Colors.red.shade700,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add),
                    label: const Text('Mark Attendance'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6236FF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
