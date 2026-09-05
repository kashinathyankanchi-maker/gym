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
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _showMarkAttendanceOptions(BuildContext context, GymProvider gymProvider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Mark Attendance',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  )
                ],
              ),
              Text(
                'Date: $_formattedDateDisplay',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Mark All Present', style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () {
                  gymProvider.markAllAttendance(_dateStr, 'Present');
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('All members marked Present for selected date')),
                  );
                },
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.highlight_off),
                label: const Text('Mark All Absent', style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () {
                  gymProvider.markAllAttendance(_dateStr, 'Absent');
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('All members marked Absent for selected date')),
                  );
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
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

    // Filter by tab and search query (name, ID, or phone)
    final filteredData = memberAttendanceData.where((item) {
      final Member m = item['member'];
      final q = _searchQuery.trim().toLowerCase();
      final matchesSearch = q.isEmpty ||
          m.name.toLowerCase().contains(q) ||
          m.id.toLowerCase().contains(q) ||
          m.phone.toLowerCase().contains(q);

      if (_selectedTabIndex == 1) return matchesSearch && item['status'] == 'Present';
      if (_selectedTabIndex == 2) return matchesSearch && item['status'] == 'Absent';
      return matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FE),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            // Return to Dashboard if stack permits
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
        centerTitle: true,
        title: const Text(
          'Today\'s Attendance',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined, color: Colors.black),
            onPressed: _pickDate,
          )
        ],
      ),
      body: Column(
        children: [
          // Date Selector Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF6236FF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, color: Colors.white, size: 24),
                    onPressed: () => _changeDate(-1),
                  ),
                  Text(
                    _formattedDateDisplay,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, color: Colors.white, size: 24),
                    onPressed: () => _changeDate(1),
                  ),
                ],
              ),
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search member...',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
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

          // Filter Tabs (All, Present, Absent)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                _buildFilterTab(
                  index: 0,
                  label: 'All (${allMembers.length})',
                  activeBgColor: const Color(0xFF383838),
                  activeTextColor: Colors.white,
                  inactiveBorderColor: Colors.grey.shade300,
                  inactiveTextColor: Colors.grey.shade700,
                ),
                const SizedBox(width: 8),
                _buildFilterTab(
                  index: 1,
                  label: 'Present ($presentCount)',
                  activeBgColor: const Color(0xFF4CAF50),
                  activeTextColor: Colors.white,
                  inactiveBorderColor: const Color(0xFFA5D6A7),
                  inactiveTextColor: const Color(0xFF2E7D32),
                ),
                const SizedBox(width: 8),
                _buildFilterTab(
                  index: 2,
                  label: 'Absent ($absentCount)',
                  activeBgColor: const Color(0xFFEF5350),
                  activeTextColor: Colors.white,
                  inactiveBorderColor: const Color(0xFFEF9A9A),
                  inactiveTextColor: const Color(0xFFD32F2F),
                ),
              ],
            ),
          ),

          // Member Attendance List
          Expanded(
            child: filteredData.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_search, size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(
                          'No members found',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    itemCount: filteredData.length,
                    separatorBuilder: (context, index) => Divider(color: Colors.grey.shade200, height: 1),
                    itemBuilder: (context, index) {
                      final item = filteredData[index];
                      final Member member = item['member'];
                      final isPresent = item['status'] == 'Present';
                      final String checkInTime = item['time'];

                      return InkWell(
                        onTap: () {
                          final newStatus = isPresent ? 'Absent' : 'Present';
                          gymProvider.markAttendance(member.id, _dateStr, newStatus);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          child: Row(
                            children: [
                              // Avatar circle
                              Container(
                                width: 44,
                                height: 44,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFE8E5FF),
                                  shape: BoxShape.circle,
                                ),
                                child: ClipOval(
                                  child: Image.network(
                                    member.avatarUrl,
                                    width: 44,
                                    height: 44,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Center(
                                      child: Text(
                                        member.name.isNotEmpty ? member.name[0].toUpperCase() : 'M',
                                        style: const TextStyle(
                                          color: Color(0xFF6236FF),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),

                              // Member Name
                              Expanded(
                                child: Text(
                                  member.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),

                              // Check-in Time
                              Text(
                                checkInTime,
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 16),

                              // Checkmark Button Icon
                              Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  color: isPresent ? const Color(0xFF4CAF50) : Colors.transparent,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isPresent ? const Color(0xFF4CAF50) : Colors.grey.shade400,
                                    width: 2,
                                  ),
                                ),
                                child: isPresent
                                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Bottom Section: Summary Cards & Mark Attendance Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Present / Absent Cards Side-by-Side
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '$presentCount',
                              style: const TextStyle(
                                color: Color(0xFF2E7D32),
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Present',
                              style: TextStyle(
                                color: Color(0xFF2E7D32),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '$absentCount',
                              style: const TextStyle(
                                color: Color(0xFFD32F2F),
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Absent',
                              style: TextStyle(
                                color: Color(0xFFD32F2F),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // + Mark Attendance Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => _showMarkAttendanceOptions(context, gymProvider),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6236FF),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, size: 20, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Mark Attendance',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
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

  Widget _buildFilterTab({
    required int index,
    required String label,
    required Color activeBgColor,
    required Color activeTextColor,
    required Color inactiveBorderColor,
    required Color inactiveTextColor,
  }) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedTabIndex = index),
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? activeBgColor : Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: isSelected ? Colors.transparent : inactiveBorderColor,
              width: 1.5,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? activeTextColor : inactiveTextColor,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

