import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/gym_provider.dart';
import '../../models/member.dart';

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

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onMemberSelected(Member? m) {
    setState(() {
      _selectedMember = m;
      if (m != null) {
        _amountController.text = m.balance > 0 ? m.balance.toInt().toString() : '500';
      }
    });
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
        const SnackBar(content: Text('Please enter a valid amount')),
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment of ${gymProvider.currencySymbol}${amount.toInt()} recorded for ${_selectedMember!.name}!'),
        backgroundColor: Colors.green,
      ),
    );

    _notesController.clear();
    setState(() {
      _selectedTabIndex = 1; // Switch to Payment History tab
    });
  }

  @override
  Widget build(BuildContext context) {
    final gymProvider = Provider.of<GymProvider>(context);
    final members = gymProvider.members;
    final currency = gymProvider.currencySymbol;

    if (_selectedMember == null && members.isNotEmpty) {
      _selectedMember = members.first;
      _amountController.text = _selectedMember!.balance > 0 ? _selectedMember!.balance.toInt().toString() : '500';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fees Collection'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Tabs
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
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
                              fontWeight: _selectedTabIndex == 0 ? FontWeight.w600 : FontWeight.normal,
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
                            'Payment History (${gymProvider.paymentRecords.length})',
                            style: TextStyle(
                              color: _selectedTabIndex == 1 ? Colors.white : Colors.grey.shade600,
                              fontWeight: _selectedTabIndex == 1 ? FontWeight.w600 : FontWeight.normal,
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
              _buildCollectFeeTab(members, currency)
            else
              _buildPaymentHistoryTab(gymProvider, currency),
          ],
        ),
      ),
      bottomNavigationBar: _selectedTabIndex == 0
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () => _submitPayment(gymProvider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6236FF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Collect Payment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            )
          : null,
    );
  }

  Widget _buildCollectFeeTab(List<Member> members, String currency) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Select Member Dropdown
          const Text(
            'Select Member',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<Member>(
            value: _selectedMember,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            items: members.map((m) {
              return DropdownMenuItem<Member>(
                value: m,
                child: Text('${m.name} (${m.status})'),
              );
            }).toList(),
            onChanged: _onMemberSelected,
          ),
          const SizedBox(height: 24),

          // Member Info Card
          if (_selectedMember != null) ...[
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage(_selectedMember!.avatarUrl),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedMember!.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        'ID: ${_selectedMember!.id}',
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _selectedMember!.status == 'Active' ? Colors.green.shade50 : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _selectedMember!.status,
                    style: TextStyle(
                      color: _selectedMember!.status == 'Active' ? Colors.green : Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 24),

            // Plan Details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDetailColumn('Plan', _selectedMember!.plan),
                _buildDetailColumn('Expiry Date', _selectedMember!.expiryDate),
                _buildDetailColumn(
                  'Balance Due',
                  '$currency${_selectedMember!.balance.toInt()}',
                  valueColor: _selectedMember!.balance > 0 ? Colors.red : Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],

          // Payment Method
          const Text(
            'Payment Method',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildPaymentMethodOption('Cash', Icons.money),
              const SizedBox(width: 12),
              _buildPaymentMethodOption('UPI', Icons.qr_code_scanner),
              const SizedBox(width: 12),
              _buildPaymentMethodOption('Card', Icons.credit_card),
              const SizedBox(width: 12),
              _buildPaymentMethodOption('Other', Icons.more_horiz),
            ],
          ),
          const SizedBox(height: 24),

          // Amount
          const Text(
            'Amount',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _amountController,
            decoration: InputDecoration(
              prefixText: '$currency ',
              prefixStyle: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
              hintText: '500',
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 20),

          // Notes
          const Text(
            'Notes (Optional)',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _notesController,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'Add payment reference or receipt note...',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentHistoryTab(GymProvider provider, String currency) {
    final history = provider.paymentRecords;

    if (history.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: Text(
            'No payments recorded yet',
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: history.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final pay = history[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.check_circle, color: Colors.green),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pay.memberName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Method: ${pay.paymentMethod} • Date: ${pay.date}',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                    if (pay.notes.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        pay.notes,
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                      ),
                    ],
                  ],
                ),
              ),
              Text(
                '+$currency${pay.amount.toInt()}',
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
      },
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
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedPaymentMethod = label;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF6236FF).withOpacity(0.05) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? const Color(0xFF6236FF) : Colors.grey.shade200,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? const Color(0xFF6236FF) : Colors.grey.shade600, size: 24),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? const Color(0xFF6236FF) : Colors.grey.shade600,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
