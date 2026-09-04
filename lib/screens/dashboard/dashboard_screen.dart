import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/gym_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gymProvider = Provider.of<GymProvider>(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {},
        ),
        title: const Text('Dashboard'),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {},
              ),
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
                            '12 this month',
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
                _buildMetricCard(
                  title: 'Today\'s Attendance',
                  value: '162',
                  subtitle: 'Present',
                  subtitleColor: Colors.green,
                  icon: Icons.how_to_reg,
                  iconColor: Colors.green,
                  iconBgColor: Colors.green.shade50,
                ),
                _buildMetricCard(
                  title: 'Today\'s Collection',
                  value: '${gymProvider.currencySymbol} ${gymProvider.totalCollection.toInt()}',
                  subtitle: '+18%',
                  subtitleColor: Colors.green,
                  icon: Icons.account_balance_wallet,
                  iconColor: Colors.blue,
                  iconBgColor: Colors.blue.shade50,
                ),
                _buildMetricCard(
                  title: 'Fees Due',
                  value: '${gymProvider.dueMembers}',
                  subtitle: 'Members',
                  subtitleColor: Colors.grey.shade600,
                  icon: Icons.receipt,
                  iconColor: Colors.orange,
                  iconBgColor: Colors.orange.shade50,
                ),
                _buildMetricCard(
                  title: 'Expiring Soon',
                  value: '${gymProvider.expiredMembers}',
                  subtitle: 'Members',
                  subtitleColor: Colors.grey.shade600,
                  icon: Icons.calendar_today,
                  iconColor: Colors.red,
                  iconBgColor: Colors.red.shade50,
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
                const Text(
                  '₹ 2,48,500',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '+15% from last month',
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
                      spots: const [
                        FlSpot(1, 40000),
                        FlSpot(5, 50000),
                        FlSpot(10, 80000),
                        FlSpot(15, 60000),
                        FlSpot(20, 110000),
                        FlSpot(25, 90000),
                        FlSpot(30, 160000),
                      ],
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
