import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/gym_provider.dart';
import '../main_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gymProvider = Provider.of<GymProvider>(context);
    final todayStr = DateTime.now().toString().split(' ')[0];
    final yearMonthPrefix = todayStr.substring(0, 7); // e.g. "2026-09"

    final presentToday = gymProvider.getTodayPresentCount(todayStr);
    final todayColl = gymProvider.getTodayCollection(todayStr);
    final monthlyColl = gymProvider.getMonthlyCollection(yearMonthPrefix);
    final chartSpots = gymProvider.getMonthlyChartSpots(yearMonthPrefix);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            MainScreen.switchTab(context, 4); // Switch to More screen
          },
        ),
        title: const Text('Dashboard'),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () => _showNotificationDialog(context, gymProvider),
              ),
              if (gymProvider.dueMembers > 0 || gymProvider.expiringSoonCount > 0)
                Positioned(
                  right: 12,
                  top: 12,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                )
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Good Morning, Alex 👋',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Here\'s what\'s happening today',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 20),

            // Total Members Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7A4BFF), Color(0xFF5A25FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6236FF).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Members',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${gymProvider.totalMembers}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.arrow_drop_up, color: Colors.greenAccent, size: 20),
                          Text(
                            '${gymProvider.totalMembers} active members',
                            style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12),
                          ),
                        ],
                      )
                    ],
                  ),
                  Icon(
                    Icons.people,
                    size: 64,
                    color: Colors.white.withOpacity(0.2),
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Metrics Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                GestureDetector(
                  onTap: () => MainScreen.switchTab(context, 2), // Switch to Attendance
                  child: _buildMetricCard(
                    title: 'Today\'s Attendance',
                    value: '$presentToday',
                    subtitle: 'Present',
                    subtitleColor: Colors.green,
                    icon: Icons.how_to_reg,
                    iconColor: Colors.green,
                    iconBgColor: Colors.green.shade50,
                  ),
                ),
                GestureDetector(
                  onTap: () => MainScreen.switchTab(context, 3), // Switch to Fees
                  child: _buildMetricCard(
                    title: 'Today\'s Collection',
                    value: '${gymProvider.currencySymbol} ${todayColl.toInt()}',
                    subtitle: 'Collected',
                    subtitleColor: Colors.green,
                    icon: Icons.account_balance_wallet,
                    iconColor: Colors.blue,
                    iconBgColor: Colors.blue.shade50,
                  ),
                ),
                GestureDetector(
                  onTap: () => MainScreen.switchTab(context, 1, memberTab: 2), // Switch to Members Due tab
                  child: _buildMetricCard(
                    title: 'Fees Due',
                    value: '${gymProvider.dueMembers}',
                    subtitle: 'Members',
                    subtitleColor: Colors.red,
                    icon: Icons.receipt,
                    iconColor: Colors.orange,
                    iconBgColor: Colors.orange.shade50,
                  ),
                ),
                GestureDetector(
                  onTap: () => MainScreen.switchTab(context, 1, memberTab: 2), // Switch to Members Expiring tab
                  child: _buildMetricCard(
                    title: 'Expiring Soon',
                    value: '${gymProvider.expiringSoonCount}',
                    subtitle: 'Members',
                    subtitleColor: Colors.orange,
                    icon: Icons.calendar_today,
                    iconColor: Colors.red,
                    iconBgColor: Colors.red.shade50,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Monthly Collection Chart
            const Text(
              'Monthly Collection',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '${gymProvider.currencySymbol} ${monthlyColl.toInt()}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Current Month Total',
                  style: TextStyle(
                    color: Colors.green.shade600,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 150,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          if (value == 50000) return const Text('50K', style: TextStyle(fontSize: 10, color: Colors.grey));
                          if (value == 100000) return const Text('100K', style: TextStyle(fontSize: 10, color: Colors.grey));
                          if (value == 150000) return const Text('150K', style: TextStyle(fontSize: 10, color: Colors.grey));
                          if (value == 200000) return const Text('200K', style: TextStyle(fontSize: 10, color: Colors.grey));
                          return const Text('');
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value % 5 == 0 && value > 0 && value <= 30) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text('${value.toInt()}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                            );
                          }
                          if (value == 1) {
                            return const Padding(
                              padding: EdgeInsets.only(top: 8.0),
                              child: Text('1', style: TextStyle(fontSize: 10, color: Colors.grey)),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 1,
                  maxX: 30,
                  minY: 0,
                  maxY: 200000,
                  lineBarsData: [
                    LineChartBarData(
                      spots: chartSpots,
                      isCurved: true,
                      color: const Color(0xFF6236FF),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: Colors.white,
                            strokeWidth: 2,
                            strokeColor: const Color(0xFF6236FF),
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF6236FF).withOpacity(0.2),
                            const Color(0xFF6236FF).withOpacity(0.0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showNotificationDialog(BuildContext context, GymProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.notifications_active, color: Color(0xFF6236FF)),
            SizedBox(width: 8),
            Text('Notifications'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const Icon(Icons.receipt, color: Colors.orange),
              title: Text('${provider.dueMembers} Members have fees due'),
              onTap: () {
                Navigator.pop(ctx);
                MainScreen.switchTab(context, 1, memberTab: 2);
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today, color: Colors.red),
              title: Text('${provider.expiringSoonCount} Memberships expiring soon'),
              onTap: () {
                Navigator.pop(ctx);
                MainScreen.switchTab(context, 1, memberTab: 2);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required Color subtitleColor,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: iconColor),
              ),
              const Spacer(),
            ],
          ),
          const Spacer(),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: subtitleColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
