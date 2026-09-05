import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/gym_provider.dart';
import '../../models/member.dart';
import 'member_profile_screen.dart';
import 'add_member_screen.dart';

class MembersScreen extends StatefulWidget {
  final int initialTab;

  const MembersScreen({super.key, this.initialTab = 0});

  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  late int _selectedTabIndex;
  final List<String> _tabs = ['All', 'Active', 'Expired', 'Suspended'];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedTabIndex = widget.initialTab;
  }

  @override
  void didUpdateWidget(covariant MembersScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTab != widget.initialTab) {
      setState(() {
        _selectedTabIndex = widget.initialTab;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final gymProvider = Provider.of<GymProvider>(context);

    // Filter members based on tab and search
    List<Member> displayMembers = gymProvider.members.where((m) {
      final status = m.computedStatus;
      final matchesSearch = m.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          m.id.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          m.phone.contains(_searchQuery);

      if (!matchesSearch) return false;

      if (_selectedTabIndex == 1) {
        return status == 'Active';
      } else if (_selectedTabIndex == 2) {
        return status == 'Expired' || status == 'Due';
      } else if (_selectedTabIndex == 3) {
        return status == 'Suspended';
      }
      return true; // All
    }).toList();

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
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddMemberScreen()),
                  );
                },
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
              onChanged: (val) => setState(() => _searchQuery = val),
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

          // Filter Buttons (All | Active | Expired | Suspended)
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
            child: displayMembers.isEmpty
                ? Center(
                    child: Text(
                      'No members found',
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: displayMembers.length,
                    separatorBuilder: (context, index) => Divider(color: Colors.grey.shade200, height: 1),
                    itemBuilder: (context, index) {
                      final member = displayMembers[index];
                      final status = member.computedStatus;

                      Color statusColor;
                      if (status == 'Active') {
                        statusColor = Colors.green;
                      } else if (status == 'Due') {
                        statusColor = Colors.orange;
                      } else if (status == 'Expired') {
                        statusColor = Colors.red;
                      } else {
                        statusColor = Colors.grey.shade700; // Suspended
                      }

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 4),
                        leading: CircleAvatar(
                          radius: 24,
                          backgroundColor: const Color(0xFFEAE4FF),
                          backgroundImage: NetworkImage(member.avatarUrl),
                        ),
                        title: Text(
                          member.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          'ID: ${member.id}',
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              status,
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
                              builder: (context) => MemberProfileScreen(member: member),
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
