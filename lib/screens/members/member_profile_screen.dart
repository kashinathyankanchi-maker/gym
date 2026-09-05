import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/gym_provider.dart';
import '../../models/member.dart';
import 'edit_member_screen.dart';

class MemberProfileScreen extends StatelessWidget {
  final Member member;

  const MemberProfileScreen({super.key, required this.member});

  void _showRecordPaymentModal(BuildContext context, GymProvider provider, Member currentMember) {
    final amountController = TextEditingController(
      text: currentMember.balance > 0 ? currentMember.balance.toInt().toString() : '500',
    );
    String method = 'Cash';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Record Payment for ${currentMember.name}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(ctx),
                )
              ],
            ),
            const SizedBox(height: 16),
            const Text('Amount', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixText: '${provider.currencySymbol} ',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Payment Method', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            StatefulBuilder(
              builder: (context, setModalState) => DropdownButtonFormField<String>(
                value: method,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: const [
                  DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                  DropdownMenuItem(value: 'UPI', child: Text('UPI')),
                  DropdownMenuItem(value: 'Card', child: Text('Card')),
                  DropdownMenuItem(value: 'Other', child: Text('Other')),
                ],
                onChanged: (val) {
                  if (val != null) setModalState(() => method = val);
                },
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final amt = double.tryParse(amountController.text.trim()) ?? 0;
                  if (amt > 0) {
                    final todayStr = DateTime.now().toString().split(' ')[0];
                    provider.recordPayment(
                      memberId: currentMember.id,
                      amount: amt,
                      paymentMethod: method,
                      dateStr: todayStr,
                      notes: 'Payment recorded via profile',
                    );
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Payment of ${provider.currencySymbol}${amt.toInt()} recorded!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6236FF),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Save Payment', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gymProvider = Provider.of<GymProvider>(context);
    final currentMember = gymProvider.members.firstWhere(
      (m) => m.id == member.id,
      orElse: () => member,
    );
    final currency = gymProvider.currencySymbol;
    final status = currentMember.computedStatus;

    final presentDays = gymProvider.getMemberPresentDays(currentMember.id);
    final absentDays = gymProvider.getMemberAbsentDays(currentMember.id);
    final payments = gymProvider.getMemberPayments(currentMember.id);

    Color statusColor;
    if (status == 'Active') {
      statusColor = Colors.greenAccent;
    } else if (status == 'Due') {
      statusColor = Colors.orangeAccent;
    } else if (status == 'Expired') {
      statusColor = Colors.redAccent;
    } else {
      statusColor = Colors.grey.shade400; // Suspended
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Member Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditMemberScreen(member: currentMember),
                ),
              );
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Purple Header Card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7A4BFF), Color(0xFF5A25FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6236FF).withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: Colors.white,
                        backgroundImage: NetworkImage(currentMember.avatarUrl),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentMember.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'ID: ${currentMember.id}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: statusColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    status,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildHeaderAction(Icons.phone, 'Call'),
                      _buildHeaderAction(Icons.message, 'Message'),
                      _buildHeaderAction(Icons.qr_code, 'QR Code'),
                    ],
                  ),
                ],
              ),
            ),

            // Details Body
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Membership Details',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6236FF).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          currentMember.plan,
                          style: const TextStyle(
                            color: Color(0xFF6236FF),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow('Phone Number', currentMember.phone),
                  if (currentMember.dob.isNotEmpty) _buildDetailRow('Date of Birth', currentMember.dob),
                  _buildDetailRow('Join Date', currentMember.joinDate),
                  _buildDetailRow('Expiry Date', currentMember.expiryDate),

                  const SizedBox(height: 24),
                  const Text(
                    'Fees & Payments',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  _buildFeeRow('Total Fees', '$currency${currentMember.totalFees.toInt()}', Colors.black),
                  _buildFeeRow('Paid Amount', '$currency${currentMember.paidAmount.toInt()}', Colors.green),
                  _buildFeeRow('Balance Due', '$currency${currentMember.balance.toInt()}', currentMember.balance > 0 ? Colors.red : Colors.green),

                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showRecordPaymentModal(context, gymProvider, currentMember),
                      icon: const Icon(Icons.payment, color: Colors.white),
                      label: const Text('Record Payment', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Text(
                    'Attendance Summary',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Text('$presentDays', style: const TextStyle(color: Colors.green, fontSize: 18, fontWeight: FontWeight.bold)),
                              const Text('Days Present', style: TextStyle(color: Colors.green, fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Text('$absentDays', style: const TextStyle(color: Colors.red, fontSize: 18, fontWeight: FontWeight.bold)),
                              const Text('Days Absent', style: TextStyle(color: Colors.red, fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  if (payments.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Text(
                      'Payment History',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    ...payments.map((p) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${p.paymentMethod} Payment', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  Text(p.date, style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
                                ],
                              ),
                              Text('+$currency${p.amount.toInt()}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 15)),
                            ],
                          ),
                        )),
                  ],

                  const SizedBox(height: 32),
                  // Action buttons (Suspend/Reactivate & Delete)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            gymProvider.toggleMemberSuspension(currentMember.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  currentMember.isSuspended
                                      ? 'Member reactivated!'
                                      : 'Member marked as Suspended!',
                                ),
                              ),
                            );
                          },
                          icon: Icon(
                            currentMember.isSuspended ? Icons.play_arrow : Icons.block,
                            color: currentMember.isSuspended ? Colors.green : Colors.orange,
                          ),
                          label: Text(
                            currentMember.isSuspended ? 'Reactivate' : 'Suspend',
                            style: TextStyle(
                              color: currentMember.isSuspended ? Colors.green : Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: currentMember.isSuspended ? Colors.green : Colors.orange,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Delete Member'),
                                content: Text('Are you sure you want to delete ${currentMember.name}?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      gymProvider.deleteMember(currentMember.id);
                                      Navigator.pop(ctx);
                                      Navigator.pop(context);
                                    },
                                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );
                          },
                          icon: const Icon(Icons.delete, color: Colors.red),
                          label: const Text('Delete', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderAction(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF6236FF), size: 20),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildFeeRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: valueColor)),
        ],
      ),
    );
  }
}
