import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/gym_provider.dart';
import '../../models/member.dart';

class CommunicationScreen extends StatefulWidget {
  const CommunicationScreen({super.key});

  @override
  State<CommunicationScreen> createState() => _CommunicationScreenState();
}

class _CommunicationScreenState extends State<CommunicationScreen> {
  Member? _selectedMember;
  String _selectedTemplate = 'Fee Reminder';
  late TextEditingController _messageController;

  final Map<String, String> _templates = {
    'Fee Reminder': 'Hi {NAME}, this is a friendly reminder from Hemant Gym that your membership fee is due. Please clear it at your earliest convenience. Thank you!',
    'Membership Expiry': 'Dear {NAME}, your membership at Hemant Gym will expire soon on {EXPIRY}. Please renew to continue your workout sessions!',
    'Welcome Message': 'Welcome to Hemant Gym, {NAME}! We are thrilled to have you onboard. Let us know if you need any assistance with your workouts.',
    'General Announcement': 'Hello {NAME}, please be advised of special holiday hours at Hemant Gym this weekend. Happy training!',
  };

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _updateMessageText();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _updateMessageText() {
    String template = _templates[_selectedTemplate] ?? '';
    final name = _selectedMember?.name ?? 'Member';
    final expiry = _selectedMember?.expiryDate ?? '30 Sep 2026';
    template = template.replaceAll('{NAME}', name).replaceAll('{EXPIRY}', expiry);
    _messageController.text = template;
  }

  Future<void> _makeCall() async {
    final phone = _selectedMember != null ? '+91 9876543210' : Provider.of<GymProvider>(context, listen: false).gymPhone;
    final Uri uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      _showToast('Calling not supported on this device');
    }
  }

  Future<void> _sendSMS() async {
    final message = Uri.encodeComponent(_messageController.text);
    final Uri uri = Uri.parse('sms:?body=$message');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      _showToast('SMS app could not be launched');
    }
  }

  Future<void> _sendWhatsApp() async {
    final message = Uri.encodeComponent(_messageController.text);
    // WhatsApp deep link format
    final Uri uri = Uri.parse('https://wa.me/?text=$message');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _showToast('WhatsApp could not be opened');
    }
  }

  void _showToast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final gymProvider = Provider.of<GymProvider>(context);
    final members = gymProvider.members;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Communication'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Select Member Card
            const Text(
              'Select Recipient Member',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<Member>(
              value: _selectedMember,
              decoration: InputDecoration(
                hintText: 'Select a member (Optional)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              items: members.map((m) {
                return DropdownMenuItem<Member>(
                  value: m,
                  child: Text('${m.name} (${m.status})'),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  _selectedMember = val;
                  _updateMessageText();
                });
              },
            ),

            const SizedBox(height: 20),
            const Text(
              'Select Predefined Template',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _templates.keys.map((templateKey) {
                final isSelected = _selectedTemplate == templateKey;
                return ChoiceChip(
                  label: Text(templateKey),
                  selected: isSelected,
                  selectedColor: const Color(0xFF6236FF),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedTemplate = templateKey;
                        _updateMessageText();
                      });
                    }
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 20),
            const Text(
              'Message Content',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _messageController,
              maxLines: 4,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),

            const SizedBox(height: 32),
            const Text(
              'Choose Action',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _makeCall,
                    icon: const Icon(Icons.phone, color: Colors.white),
                    label: const Text('Call', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _sendSMS,
                    icon: const Icon(Icons.sms, color: Colors.white),
                    label: const Text('SMS', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6236FF),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _sendWhatsApp,
                    icon: const Icon(Icons.chat_bubble, color: Colors.white),
                    label: const Text('WhatsApp', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
