import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/gym_provider.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  final List<Map<String, String>> _faqs = const [
    {
      'question': 'How do I add a new member?',
      'answer': 'Navigate to the Members tab and click on the purple "+" button at the top right. Fill out the member details and save.',
    },
    {
      'question': 'How do I record attendance?',
      'answer': 'Go to the Attendance tab, search for the member, and tap "Mark Present" or "Mark Absent".',
    },
    {
      'question': 'How do I backup my gym data?',
      'answer': 'Go to More > Backup & Restore and click "Copy Backup JSON to Clipboard". You can save this text securely.',
    },
    {
      'question': 'Can I change membership plans?',
      'answer': 'Yes, go to More > Membership Plans to add or edit custom plans. When creating/editing members, you can assign these plans.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final gymProvider = Provider.of<GymProvider>(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Help & Support'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Contact Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6236FF), Color(0xFF4A19FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Icon(Icons.support_agent, color: Colors.white, size: 48),
                const SizedBox(height: 12),
                const Text(
                  'Need Help?',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'We are here to assist you with Hemant Gym App',
                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        final Uri uri = Uri(scheme: 'tel', path: gymProvider.gymPhone);
                        if (await canLaunchUrl(uri)) await launchUrl(uri);
                      },
                      icon: const Icon(Icons.phone, size: 18),
                      label: const Text('Call Support'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF6236FF),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),

          const SizedBox(height: 24),
          const Text(
            'Frequently Asked Questions',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 12),

          ..._faqs.map((faq) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: ExpansionTile(
                  title: Text(
                    faq['question']!,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                      child: Text(
                        faq['answer']!,
                        style: TextStyle(color: Colors.grey.shade700, fontSize: 13, height: 1.4),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
