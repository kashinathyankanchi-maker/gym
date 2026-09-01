import 'package:flutter/material.dart';


import 'member_profile_screen.dart';

class MembersScreen extends StatefulWidget {
  const MembersScreen({super.key});

  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  int _selectedTabIndex = 0;
  final List<String> _tabs = ['All', 'Active', 'Expired', 'Suspended'];

  final List<Map<String, dynamic>> _members = [
    {
      'name': 'Rahul Kumar',
      'id': 'GYM1001',
      'status': 'Active',
      'avatarUrl': 'https://i.pravatar.cc/150?img=11',
    },
    {
      'name': 'Suresh Patel',
      'id': 'GYM1002',
      'status': 'Active',
      'avatarUrl': 'https://i.pravatar.cc/150?img=12',
    },
    {
      'name': 'Manoj Sharma',
      'id': 'GYM1003',
      'status': 'Active',
      'avatarUrl': 'https://i.pravatar.cc/150?img=13',
    },
    {
      'name': 'Kiran Yadav',
      'id': 'GYM1004',
      'status': 'Due',
      'avatarUrl': 'https://i.pravatar.cc/150?img=5',
    },
    {
      'name': 'Prakash Verma',
      'id': 'GYM1005',
      'status': 'Expired',
      'avatarUrl': 'https://i.pravatar.cc/150?img=15',
    },
    {
      'name': 'Amit Singh',
      'id': 'GYM1006',
      'status': 'Active',
      'avatarUrl': 'https://i.pravatar.cc/150?img=16',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {},
        ),
        title: const Text('Members'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF6236FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.add, color: Colors.white),
                onPressed: () {},
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search members...',
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
                        color: isSelected ? const Color(0xFF6236FF) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF6236FF) : Colors.grey.shade300,
                        ),
                      ),
                      child: Text(
                        _tabs[index],
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey.shade600,
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
                
                Color statusColor;
                if (member['status'] == 'Active') {
                  statusColor = Colors.green;
                } else if (member['status'] == 'Due') {
                  statusColor = Colors.orange;
                } else {
                  statusColor = Colors.red;
                }

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 4),
                  leading: CircleAvatar(
                    radius: 24,
                    backgroundImage: NetworkImage(member['avatarUrl']),
                  ),
                  title: Text(
                    member['name'],
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    'ID: ${member['id']}',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        member['status'],
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MemberProfileScreen(memberData: member),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
