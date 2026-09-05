import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/gym_provider.dart';
import '../../models/member.dart';
import '../../models/payment_record.dart';

class FeesScreen extends StatefulWidget {
  const FeesScreen({super.key});

  @override
  State<FeesScreen> createState() => _FeesScreenState();
}

class _FeesScreenState extends State<FeesScreen> {
  int _selectedTabIndex = 0; // 0: Collect Fee, 1: Payment History

  Member? _selectedMember;
  String _selectedPaymentMethod = 'Cash';
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  String _historySearchQuery = '';

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _selectMember(Member m) {
    setState(() {
      _selectedMember = m;
      final dueAmount = m.balance > 0 ? m.balance : m.totalFees;
      _amountController.text = dueAmount > 0 ? dueAmount.toInt().toString() : '500';
    });
  }

  void _showMemberSelectionSheet(BuildContext context, List<Member> members) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        String searchQuery = '';
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final filtered = members.where((m) {
              final q = searchQuery.trim().toLowerCase();
              return q.isEmpty ||
                  m.name.toLowerCase().contains(q) ||
                  m.id.toLowerCase().contains(q) ||
                  m.phone.toLowerCase().contains(q);
            }).toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Select Member',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      )
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    onChanged: (val) => setSheetState(() => searchQuery = val),
                    decoration: InputDecoration(
                      hintText: 'Search by name, ID or phone...',
                      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                      prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: filtered.isEmpty
                        ? Center(
                            child: Text(
                              'No members found',
                              style: TextStyle(color: Colors.grey.shade500),
                            ),
                          )
                        : ListView.separated(
                            itemCount: filtered.length,
                            separatorBuilder: (context, index) => Divider(color: Colors.grey.shade200, height: 1),
                            itemBuilder: (context, index) {
                              final m = filtered[index];
                              final isSelected = _selectedMember?.id == m.id;
                              return ListTile(
                                leading: CircleAvatar(
                                  radius: 20,
                                  backgroundColor: const Color(0xFFE8E5FF),
                                  backgroundImage: NetworkImage(m.avatarUrl),
                                ),
                                title: Text(
                                  m.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                subtitle: Text(
                                  'ID: ${m.id} • Plan: ${m.plan}',
                                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '₹${m.balance.toInt()}',
                                      style: TextStyle(
                                        color: m.balance > 0 ? Colors.red : Colors.green,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      m.computedStatus,
                                      style: TextStyle(
                                        color: m.computedStatus == 'Active' ? Colors.green : Colors.orange,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                                selected: isSelected,
                                onTap: () {
                                  _selectMember(m);
                                  Navigator.pop(ctx);
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _submitPayment(GymProvider gymProvider) {
    if (_selectedMember == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a member first')),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid payment amount greater than ₹0')),
      );
      return;
    }

    final todayStr = DateTime.now().toString().split(' ')[0];

    gymProvider.recordPayment(
      memberId: _selectedMember!.id,
      amount: amount,
      paymentMethod: _selectedPaymentMethod,
      dateStr: todayStr,
      notes: _notesController.text.trim(),
    );

    // Refresh selected member state from updated provider list
    final updatedMember = gymProvider.members.firstWhere(
      (m) => m.id == _selectedMember!.id,
      orElse: () => _selectedMember!,
    );

    setState(() {
      _selectedMember = updatedMember;
      _notesController.clear();
      _selectedTabIndex = 1; // Switch to Payment History tab
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment of ${gymProvider.currencySymbol}${amount.toInt()} collected for ${updatedMember.name}!'),
        backgroundColor: const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gymProvider = Provider.of<GymProvider>(context);
    final members = gymProvider.members;
    final currency = gymProvider.currencySymbol;

    // Auto-select first member if none selected
    if (_selectedMember == null && members.isNotEmpty) {
      _selectedMember = members.first;
      final dueAmount = _selectedMember!.balance > 0 ? _selectedMember!.balance : _selectedMember!.totalFees;
      _amountController.text = dueAmount > 0 ? dueAmount.toInt().toString() : '500';
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FE),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
        centerTitle: true,
        title: const Text(
          'Fees Collection',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Tab Switcher (Collect Fee | Payment History)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F7),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTabIndex = 0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _selectedTabIndex == 0 ? const Color(0xFF6236FF) : Colors.transparent,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Collect Fee',
                            style: TextStyle(
                              color: _selectedTabIndex == 0 ? Colors.white : Colors.grey.shade600,
                              fontWeight: _selectedTabIndex == 0 ? FontWeight.bold : FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTabIndex = 1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _selectedTabIndex == 1 ? const Color(0xFF6236FF) : Colors.transparent,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Payment History',
                            style: TextStyle(
                              color: _selectedTabIndex == 1 ? Colors.white : Colors.grey.shade600,
                              fontWeight: _selectedTabIndex == 1 ? FontWeight.bold : FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (_selectedTabIndex == 0)
              _buildCollectFeeTab(members, currency, gymProvider)
            else
              _buildPaymentHistoryTab(gymProvider, currency),
          ],
        ),
      ),
    );
  }

  Widget _buildCollectFeeTab(List<Member> members, String currency, GymProvider gymProvider) {
    if (members.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.people_outline, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 12),
              Text(
                'No members registered yet',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
              ),
            ],
          ),
        ),
      );
    }

    final m = _selectedMember ?? members.first;
    final statusColor = m.computedStatus == 'Active'
        ? const Color(0xFF2E7D32)
        : m.computedStatus == 'Due'
            ? Colors.orange.shade800
            : Colors.red.shade700;

    final statusBgColor = m.computedStatus == 'Active'
        ? const Color(0xFFE8F5E9)
        : m.computedStatus == 'Due'
            ? const Color(0xFFFFF3E0)
            : const Color(0xFFFFEBEE);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Member Info Card (Clickable to change member)
          InkWell(
            onTap: () => _showMemberSelectionSheet(context, members),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
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
                children: [
                  Row(
                    children: [
                      // Avatar
                      Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE8E5FF),
                          shape: BoxShape.circle,
                        ),
                        child: ClipOval(
                          child: Image.network(
                            m.avatarUrl,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Center(
                              child: Text(
                                m.name.isNotEmpty ? m.name[0].toUpperCase() : 'M',
                                style: const TextStyle(
                                  color: Color(0xFF6236FF),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Name & ID
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  m.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.grey.shade500),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'ID: ${m.id}',
                              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                            ),
                          ],
                        ),
                      ),

                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusBgColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          m.computedStatus,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 3 Details Columns: Plan | Due Date | Amount Due
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildDetailColumn('Plan', m.plan.replaceAll(' Plan', '')),
                      _buildDetailColumn('Due Date', m.expiryDate.isNotEmpty ? m.expiryDate : '01 Sep 2026'),
                      _buildDetailColumn(
                        'Amount Due',
                        '$currency${m.balance.toInt()}',
                        valueColor: m.balance > 0 ? const Color(0xFFE53935) : const Color(0xFF2E7D32),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Payment Method Selector
          const Text(
            'Payment Method',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildPaymentMethodOption('Cash', Icons.payments_outlined),
              const SizedBox(width: 10),
              _buildPaymentMethodOption('UPI', Icons.qr_code_scanner),
              const SizedBox(width: 10),
              _buildPaymentMethodOption('Card', Icons.credit_card_outlined),
              const SizedBox(width: 10),
              _buildPaymentMethodOption('Other', Icons.more_horiz),
            ],
          ),
          const SizedBox(height: 24),

          // Amount Field
          const Text(
            'Amount',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFF6236FF), width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Notes Field (Optional)
          const Text(
            'Notes (Optional)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Add a note...',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.all(14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFF6236FF), width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Collect Payment Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => _submitPayment(gymProvider),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6236FF),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Collect Payment',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPaymentHistoryTab(GymProvider provider, String currency) {
    final history = provider.paymentRecords.where((pay) {
      final q = _historySearchQuery.trim().toLowerCase();
      return q.isEmpty ||
          pay.memberName.toLowerCase().contains(q) ||
          pay.id.toLowerCase().contains(q) ||
          pay.paymentMethod.toLowerCase().contains(q);
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Search Field for Payment History
          TextField(
            onChanged: (val) => setState(() => _historySearchQuery = val),
            decoration: InputDecoration(
              hintText: 'Search payments by member or ID...',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
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
          const SizedBox(height: 16),

          if (history.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.receipt_long, size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    Text(
                      'No payment records found',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: history.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final PaymentRecord pay = history[index];
                final timeDisplay = pay.time.isNotEmpty ? ' • ${pay.time}' : '';

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Status/Method Icon
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.check_circle_outline, color: Color(0xFF2E7D32), size: 24),
                      ),
                      const SizedBox(width: 14),

                      // Member Name & Transaction Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pay.memberName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Method: ${pay.paymentMethod} • Date: ${pay.date}$timeDisplay',
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                            ),
                            Text(
                              'ID: ${pay.id}',
                              style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
                            ),
                            if (pay.notes.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Note: ${pay.notes}',
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 11, fontStyle: FontStyle.italic),
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Payment Amount
                      Text(
                        '+$currency${pay.amount.toInt()}',
                        style: const TextStyle(
                          color: Color(0xFF2E7D32),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildDetailColumn(String label, String value, {Color valueColor = Colors.black}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: valueColor),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodOption(String label, IconData icon) {
    final isSelected = _selectedPaymentMethod == label;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedPaymentMethod = label;
          });
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFF5F2FF) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? const Color(0xFF6236FF) : Colors.grey.shade200,
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? const Color(0xFF6236FF) : Colors.grey.shade600,
                size: 24,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? const Color(0xFF6236FF) : Colors.grey.shade600,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
