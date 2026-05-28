import 'package:flutter/material.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  static const _faqs = [
    (
      q: 'How do I book a service?',
      a: 'Go to any shop, tap a service or product, then press "Book Now". Follow the 3-step booking flow: choose your vehicle, select services/products, then pick a date and confirm.'
    ),
    (
      q: 'Can I cancel a booking?',
      a: 'Yes. Go to Profile → My Appointments, find the booking, and tap "Cancel". Cancellations are free if made more than 24 hours before the appointment.'
    ),
    (
      q: 'How do I track my repair progress?',
      a: 'Go to Profile → Repair Progress. Your mechanic will update the status as work progresses. You\'ll also receive notifications for each update.'
    ),
    (
      q: 'Where can I see my invoices?',
      a: 'Go to Profile → My Invoices. All completed bookings will have an invoice you can view and download.'
    ),
    (
      q: 'How do I add a vehicle to my profile?',
      a: 'Go to Profile → My Vehicles, then tap the + button. Fill in your car details and save.'
    ),
    (
      q: 'What payment methods are accepted?',
      a: 'Payments are handled directly at the shop. The app is used to book appointments — the mechanic will confirm payment options at the time of service.'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          // Hero banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red.shade700, Colors.red.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.support_agent,
                      size: 34, color: Colors.white),
                ),
                const SizedBox(height: 14),
                const Text(
                  'How can we help?',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(height: 6),
                Text(
                  'Find answers to common questions below\nor contact us directly.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.85)),
                ),
              ],
            ),
          ),

          // Contact cards
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
            child: Row(
              children: [
                const Expanded(
                  child: _ContactCard(
                    icon: Icons.email_outlined,
                    label: 'Email Us',
                    value: 'support@autocare.app',
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: _ContactCard(
                    icon: Icons.phone_outlined,
                    label: 'Call Us',
                    value: '+855 23 456 789',
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),

          // FAQ header
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              'Frequently Asked Questions',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),

          // FAQ list
          ...(_faqs.map((faq) => _FaqTile(question: faq.q, answer: faq.a))),

          // App info
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              'App Information',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const _InfoTile(
              icon: Icons.info_outline, label: 'Version', value: '1.0.0'),
          _InfoTile(
              icon: Icons.description_outlined,
              label: 'Terms of Service',
              onTap: () {}),
          _InfoTile(
              icon: Icons.privacy_tip_outlined,
              label: 'Privacy Policy',
              onTap: () {}),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _ContactCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600)),
          const SizedBox(height: 2),
          Text(value,
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w500, color: color)),
        ],
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  final String question;
  final String answer;

  const _FaqTile({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        shape: const Border(),
        leading: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.help_outline, size: 18, color: Colors.red.shade700),
        ),
        title: Text(
          question,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        children: [
          Text(
            answer,
            style: TextStyle(
                fontSize: 13, color: Colors.grey.shade700, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final VoidCallback? onTap;

  const _InfoTile({
    required this.icon,
    required this.label,
    this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: Colors.grey.shade600),
      ),
      title: Text(label, style: const TextStyle(fontSize: 14)),
      trailing: value != null
          ? Text(value!,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500))
          : onTap != null
              ? Icon(Icons.chevron_right, color: Colors.grey.shade400)
              : null,
      onTap: onTap,
    );
  }
}
