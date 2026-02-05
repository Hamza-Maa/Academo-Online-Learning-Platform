import 'package:flutter/material.dart';
import '../../theme.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Policy',
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
              '1. Information We Collect',
              'We collect information you provide directly to us, including name, email address, phone number, and payment information when you create an account or make a purchase.',
            ),
            _buildSection(
              context,
              '2. How We Use Your Information',
              'We use your information to provide and improve our services, process transactions, send you updates and marketing communications, and ensure platform security.',
            ),
            _buildSection(
              context,
              '3. Information Sharing',
              'We do not sell your personal information. We may share your information with service providers who assist us in operating our platform, such as payment processors.',
            ),
            _buildSection(
              context,
              '4. Data Security',
              'We implement appropriate security measures to protect your personal information from unauthorized access, alteration, disclosure, or destruction.',
            ),
            _buildSection(
              context,
              '5. Cookies and Tracking',
              'We use cookies and similar tracking technologies to track activity on our platform and hold certain information to improve user experience.',
            ),
            _buildSection(
              context,
              '6. Your Rights (GDPR)',
              'Under GDPR, you have the right to access, rectify, erase, restrict processing, and port your personal data. You can exercise these rights by contacting us.',
            ),
            _buildSection(
              context,
              '7. Data Retention',
              'We retain your personal information for as long as necessary to provide our services and comply with legal obligations.',
            ),
            _buildSection(
              context,
              '8. Children\'s Privacy',
              'Our services are not directed to children under 13. We do not knowingly collect personal information from children under 13.',
            ),
            _buildSection(
              context,
              '9. International Data Transfers',
              'Your information may be transferred to and maintained on servers located outside your country. We ensure appropriate safeguards are in place.',
            ),
            _buildSection(
              context,
              '10. Changes to Privacy Policy',
              'We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page.',
            ),
            _buildSection(
              context,
              '11. Contact Us',
              'If you have any questions about this Privacy Policy or want to exercise your rights, please contact us at privacy@learnhub.com',
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
