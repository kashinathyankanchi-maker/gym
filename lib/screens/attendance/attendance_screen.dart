import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/gym_provider.dart';
import '../../models/member.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  int _selectedTabIndex = 0; // 0: All, 1: Present, 2: Absent
  DateTime _selectedDate = DateTime.now();
  String _searchQuery = '';

  String get _dateStr => _selectedDate.toString().split(' ')[0];

  String get _formattedDateDisplay {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final dayStr = _selectedDate.day.toString().padLeft(2, '0');
    final monthStr = months[_selectedDate.month - 1];
    final weekdayStr = days[_selectedDate.weekday - 1];
    return '$dayStr $monthStr ${_selectedDate.year}, $weekdayStr';
  }

  void _changeDate(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final gymProvider = Provider.of<GymProvider>(context);
    final allMembers = gymProvider.members;

    // Calculate status for each member for current date
    final List<Map<String, dynamic>> memberAttendanceData = allMembers.map((m) {
      final status = gymProvider.getMemberAttendanceStatus(m.id, _dateStr);
      final time = gymProvider.getMemberCheckInTime(m.id, _dateStr);
      return {
        'member': m,
        'status': status,
        'time': time,
      };
    }).toList();

    final presentCount = memberAttendanceData.where((m) => m['status'] == 'Present').length;
    final absentCount = memberAttendanceData.where((m) => m['status'] == 'Absent').length;

    // Filter by tab and search
    final filteredData = memberAttendanceData.where((item) {
      final Member m = item['member'];
      final matchesSearch = m.name.toLowerCase().contains(_searchQuery.toLowerCase());
      if (_selectedTabIndex == 1) return matchesSearch && item['status'] == 'Present';
      if (_selectedTabIndex == 2) return matchesSearch && item['status'] == 'Absent';
      return matchesSearch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _pickDate,
          )
        ],
      ),
      body: Column(
        children: [
          // Date Selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF6236FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, color: Colors.white),
                    onPressed: () => _changeDate(-1),
                  ),
                  Text(
                    _formattedDateDisplay,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, color: Colors.white),
                    onPressed: () => _changeDate(1),
                  ),
                ],
              ),
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
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

          // Filter Tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Row(
              children: [
                _buildTabChip(0, 'All (${allMembers.length})', Colors.grey.shade800),
                _buildTabChip(1, 'Present ($presentCount)', Colors.green),
                _buildTabChip(2, 'Absent ($absentCount)', Colors.red),
              ],
            ),
          ),

          // Member List
          Expanded(
            child: filteredData.isEmpty
                ? Center(
                    child: Text(
                      'No attendance records found',
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredData.length,
                    separatorBuilder: (context, index) => Divider(color: Colors.grey.shade200, height: 1),
                    itemBuilder: (context, index) {
                      final item = filteredData[index];
                      final Member member = item['member'];
                      final isPresent = item['status'] == 'Present';

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 4),
                        leading: CircleAvatar(
                          radius: 20,
                          backgroundImage: NetworkImage(member.avatarUrl),
                        ),
                        title: Text(
                          member.name,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                        subtitle: Text(
                          'ID: ${member.id}',
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              item['time'],
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 16),
                            InkWell(
                              onTap: () {
                                final newStatus = isPresent ? 'Absent' : 'Present';
                                gymProvider.markAttendance(member.id, _dateStr, newStatus);
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: isPresent ? Colors.green : Colors.transparent,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isPresent ? Colors.green : Colors.grey.shade400,
                                    width: 2,
                                  ),
                                ),
                                child: isPresent
                                    ? const Icon(Icons.check, size: 18, color: Colors.white)
                                    : null,
                              ),
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
            child: Row(
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
                        Text(
                          '$presentCount',
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Present Today',
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
                        Text(
                          '$absentCount',
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Absent Today',
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
          ),
        ],
      ),
    );
  }

  Widget _buildTabChip(int index, String label, Color activeColor) {
    final isSelected = _selectedTabIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: InkWell(
        onTap: () => setState(() => _selectedTabIndex = index),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? activeColor : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? Colors.transparent : Colors.grey.shade300,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : activeColor,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
