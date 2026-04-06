import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  // ==================== DATA ====================

  List<Map<String, String>> get _faqs => [
        {
          'q': 'How does AI scheduling work?',
          'a':
              'Our AI analyzes your tasks, priorities, and deadlines to create an optimized daily schedule that fits your work hours and focus preferences.'
        },
        {
          'q': 'How do I sync with Google Calendar?',
          'a':
              'Go to Calendar Sync from the dashboard and enable sync. You\'ll need to authorize with your Google account.'
        },
        {
          'q': 'Can I reschedule tasks?',
          'a':
              'Yes! Update or add tasks and tap "Generate Schedule" to get a new AI-optimized schedule.'
        },
        {
          'q': 'How do habit streaks work?',
          'a':
              'Complete a habit daily to build streaks. Missing a day resets the streak counter.'
        },
        {
          'q': 'Is my data secure?',
          'a':
              'Yes. We use JWT authentication, bcrypt password hashing, and encrypted connections to protect your data.'
        },
      ];

  // ==================== UI ====================

  @override
  Widget build(BuildContext context) {
    final contactFormKey = GlobalKey<FormState>();
    final subjectController = TextEditingController();
    final messageController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Help & Support')),
      body: Container(
        decoration:
            const BoxDecoration(gradient: AppTheme.splashGradient),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildFAQSection(context),
              const SizedBox(height: 24),
              _buildContactSection(
                context,
                contactFormKey,
                subjectController,
                messageController,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== HEADER ====================

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primary.withValues(alpha: 0.1),
            AppTheme.accent.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: AppTheme.primary.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.support_agent_rounded,
                color: Colors.white, size: 32),
          ),
          const SizedBox(height: 16),
          const Text(
            'How can we help?',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 6),
          const Text(
            'Find answers or contact us',
            style: TextStyle(
                color: AppTheme.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // ==================== FAQ ====================

  Widget _buildFAQSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Frequently Asked Questions',
          style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        ..._faqs.map((faq) => _buildFAQItem(context, faq)),
      ],
    );
  }

  Widget _buildFAQItem(
      BuildContext context, Map<String, String> faq) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: AppTheme.glassDecoration,
      child: Theme(
        data: Theme.of(context)
            .copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 4),
          childrenPadding:
              const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: const Icon(Icons.help_outline_rounded,
              color: AppTheme.primary, size: 20),
          title: Text(
            faq['q']!,
            style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600),
          ),
          iconColor: AppTheme.textSecondary,
          collapsedIconColor: AppTheme.textSecondary,
          children: [
            Text(
              faq['a']!,
              style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                  height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== CONTACT ====================

  Widget _buildContactSection(
    BuildContext context,
    GlobalKey<FormState> formKey,
    TextEditingController subjectController,
    TextEditingController messageController,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Contact Us',
          style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: AppTheme.glassDecoration,
          child: Form(
            key: formKey,
            child: Column(
              children: [
                _buildSubjectField(subjectController),
                const SizedBox(height: 14),
                _buildMessageField(messageController),
                const SizedBox(height: 20),
                _buildSubmitButton(
                    context, formKey, subjectController,
                    messageController),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectField(TextEditingController controller) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: AppTheme.textPrimary),
      decoration: const InputDecoration(
        labelText: 'Subject',
        prefixIcon: Icon(Icons.subject_rounded,
            color: AppTheme.textSecondary),
      ),
      validator: (v) =>
          v == null || v.isEmpty ? 'Enter a subject' : null,
    );
  }

  Widget _buildMessageField(TextEditingController controller) {
    return TextFormField(
      controller: controller,
      maxLines: 4,
      style: const TextStyle(color: AppTheme.textPrimary),
      decoration: const InputDecoration(
        labelText: 'Message',
        alignLabelWithHint: true,
        prefixIcon: Padding(
          padding: EdgeInsets.only(bottom: 60),
          child: Icon(Icons.message_outlined,
              color: AppTheme.textSecondary),
        ),
      ),
      validator: (v) =>
          v == null || v.isEmpty ? 'Enter your message' : null,
    );
  }

  Widget _buildSubmitButton(
    BuildContext context,
    GlobalKey<FormState> formKey,
    TextEditingController subjectController,
    TextEditingController messageController,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(14),
        ),
        child: ElevatedButton.icon(
          onPressed: () {
            if (formKey.currentState!.validate()) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'Message sent! We\'ll get back to you soon.'),
                  backgroundColor: AppTheme.success,
                ),
              );
              subjectController.clear();
              messageController.clear();
            }
          },
          icon: const Icon(Icons.send_rounded, size: 18),
          label: const Text('Send Message',
              style: TextStyle(fontWeight: FontWeight.w600)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
          ),
        ),
      ),
    );
  }
}
