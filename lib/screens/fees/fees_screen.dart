import 'package:flutter/material.dart';


class FeesScreen extends StatefulWidget {
  const FeesScreen({super.key});

  @override
  State<FeesScreen> createState() => _FeesScreenState();
}

class _FeesScreenState extends State<FeesScreen> {
  int _selectedTabIndex = 0;
  final List<String> _tabs = ['Collect Fee', 'Payment History'];
  
  String _selectedPaymentMethod = 'Cash';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {},
        ),
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
                  children: List.generate(_tabs.length, (index) {
                    final isSelected = _selectedTabIndex == index;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedTabIndex = index;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF6236FF) : Colors.transparent,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            _tabs[index],
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.grey.shade600,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
            
            if (_selectedTabIndex == 0) _buildCollectFeeTab()
            else const Center(child: Text('Payment History')),
          ],
        ),
      ),
      bottomNavigationBar: _selectedTabIndex == 0 ? Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {},
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
      ) : null,
    );
  }

  Widget _buildCollectFeeTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Member Info Card
          Row(
            children: [
              const CircleAvatar(
                radius: 24,
                backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11'),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Rahul Kumar',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      'ID: GYM1001',
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Active',
                  style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w500),
                ),
              )
            ],
          ),
          const SizedBox(height: 32),
          
          // Plan Details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDetailColumn('Plan', 'Monthly'),
              _buildDetailColumn('Due Date', '01 Sep 2026'),
              _buildDetailColumn('Amount Due', '₹500', valueColor: Colors.red),
            ],
          ),
          const SizedBox(height: 32),
          
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
              _buildPaymentMethodOption('UPI', Icons.qr_code_scanner), // Closest to UPI icon
              const SizedBox(width: 12),
              _buildPaymentMethodOption('Card', Icons.credit_card),
              const SizedBox(width: 12),
              _buildPaymentMethodOption('Other', Icons.more_horiz),
            ],
          ),
          const SizedBox(height: 32),
          
          // Amount
          const Text(
            'Amount',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 8),
          TextField(
            decoration: InputDecoration(
              prefixText: '₹ ',
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
          const SizedBox(height: 24),
          
          // Notes
          const Text(
            'Notes (Optional)',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 8),
          TextField(
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Add a note...',
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
