import 'package:flutter/material.dart';
import '../../theme.dart';

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms & Conditions'),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Terms & Conditions',
              style: context.textStyles.headlineMedium?.bold,
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'Last updated: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
              style: context.textStyles.bodySmall?.withColor(
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            _buildSection(
              context,
              '1. Acceptance of Terms',
              'By accessing and using LearnHub, you accept and agree to be bound by the terms and provision of this agreement.',
            ),
            _buildSection(
              context,
              '2. Use License',
              'Permission is granted to temporarily access the courses on LearnHub for personal, non-commercial use only.',
            ),
            _buildSection(
              context,
              '3. Course Access',
              'Upon successful purchase, you will receive lifetime access to the course content. This access is non-transferable and for your personal use only.',
            ),
            _buildSection(
              context,
              '4. User Account',
              'You are responsible for maintaining the confidentiality of your account and password. You agree to accept responsibility for all activities that occur under your account.',
            ),
            _buildSection(
              context,
              '5. Intellectual Property',
              'The course content, including videos, documents, and materials, are owned by LearnHub and its instructors. You may not reproduce, distribute, or create derivative works without written permission.',
            ),
            _buildSection(
              context,
              '6. Refund Policy',
              'We offer a 30-day money-back guarantee for all paid courses. If you are not satisfied with a course, contact us within 30 days of purchase for a full refund.',
            ),
            _buildSection(
              context,
              '7. Prohibited Activities',
              'You may not use the platform to: violate any laws, infringe on intellectual property rights, transmit viruses or malicious code, or engage in any harmful activities.',
            ),
            _buildSection(
              context,
              '8. Limitation of Liability',
              'LearnHub shall not be liable for any indirect, incidental, special, consequential or punitive damages resulting from your use or inability to use the platform.',
            ),
            _buildSection(
              context,
              '9. Changes to Terms',
              'We reserve the right to modify these terms at any time. We will notify users of any changes by posting the new Terms & Conditions on this page.',
            ),
            _buildSection(
              context,
              '10. Contact Us',
              'If you have any questions about these Terms & Conditions, please contact us at support@learnhub.com',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: context.textStyles.titleMedium?.semiBold,
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            content,
            style: context.textStyles.bodyMedium,
          ),
        ],
      ),
    );
  }
}
