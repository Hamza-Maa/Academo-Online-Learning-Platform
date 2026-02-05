import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme.dart';

class HelpCenterPage extends StatefulWidget {
  const HelpCenterPage({super.key});

  @override
  State<HelpCenterPage> createState() => _HelpCenterPageState();
}

class _HelpCenterPageState extends State<HelpCenterPage> {
  String _searchQuery = '';
  int? _expandedIndex;

  final List<_HelpCategory> _categories = [
    _HelpCategory(
      icon: Icons.play_circle_outline,
      title: 'Getting Started',
      color: const Color(0xFF2563EB),
      topics: [
        _HelpTopic(
          question: 'How do I sign up?',
          answer: 'To create an account, tap the "Sign Up" button on the login screen. Fill in your name, email, and password. You\'ll receive a verification email to confirm your account.',
        ),
        _HelpTopic(
          question: 'How do I purchase a course?',
          answer: 'Browse available courses, select one you\'re interested in, and tap "Enroll Now". You\'ll be guided through the payment process. Once complete, the course will appear in "My Courses".',
        ),
        _HelpTopic(
          question: 'Can I preview courses before buying?',
          answer: 'Yes! Each course page shows a preview video, detailed syllabus, instructor information, and student reviews to help you make an informed decision.',
        ),
      ],
    ),
    _HelpCategory(
      icon: Icons.school_outlined,
      title: 'Courses & Learning',
      color: const Color(0xFF22C55E),
      topics: [
        _HelpTopic(
          question: 'How do I track my progress?',
          answer: 'Your progress is automatically tracked as you watch lessons. Visit "My Courses" to see completion percentages and resume where you left off.',
        ),
        _HelpTopic(
          question: 'Can I download videos for offline viewing?',
          answer: 'Offline downloads are currently not available, but we\'re working on adding this feature soon. Stay tuned!',
        ),
        _HelpTopic(
          question: 'How long do I have access to a course?',
          answer: 'Once you purchase a course, you have lifetime access. Learn at your own pace and revisit lessons anytime.',
        ),
        _HelpTopic(
          question: 'Can I get a certificate after completing a course?',
          answer: 'Yes! Upon completing all lessons and any required assessments, you\'ll receive a certificate of completion that you can download and share.',
        ),
      ],
    ),
    _HelpCategory(
      icon: Icons.payment_outlined,
      title: 'Payments & Billing',
      color: const Color(0xFFF59E0B),
      topics: [
        _HelpTopic(
          question: 'What payment methods do you accept?',
          answer: 'We accept credit cards, debit cards, and PayPal. All transactions are secured with industry-standard encryption.',
        ),
        _HelpTopic(
          question: 'Can I get a refund?',
          answer: 'Yes, we offer a 30-day money-back guarantee. If you\'re not satisfied with a course, contact support for a full refund within 30 days of purchase.',
        ),
        _HelpTopic(
          question: 'Where can I view my purchase history?',
          answer: 'Go to Settings > Purchase History to view all your transactions, invoices, and payment details.',
        ),
      ],
    ),
    _HelpCategory(
      icon: Icons.account_circle_outlined,
      title: 'Account Settings',
      color: const Color(0xFF8B5CF6),
      topics: [
        _HelpTopic(
          question: 'How do I change my password?',
          answer: 'Go to Settings > Privacy & Security > Change Password. Enter your current password and choose a new one.',
        ),
        _HelpTopic(
          question: 'How do I update my profile information?',
          answer: 'Navigate to Settings and tap "Edit Profile". You can update your name, phone number, and profile photo.',
        ),
        _HelpTopic(
          question: 'Can I change my email address?',
          answer: 'Email addresses cannot be changed directly. Please contact support if you need to update your email.',
        ),
        _HelpTopic(
          question: 'How do I delete my account?',
          answer: 'Go to Settings and scroll to the bottom. Tap "Delete Account" and confirm. Note: This action is permanent and cannot be undone.',
        ),
      ],
    ),
    _HelpCategory(
      icon: Icons.bug_report_outlined,
      title: 'Troubleshooting',
      color: const Color(0xFFEF4444),
      topics: [
        _HelpTopic(
          question: 'Video won\'t play',
          answer: 'Try refreshing the page or checking your internet connection. If the issue persists, try clearing your app cache in Settings.',
        ),
        _HelpTopic(
          question: 'App crashes or freezes',
          answer: 'Make sure you\'re using the latest version of the app. If problems continue, try restarting your device or reinstalling the app.',
        ),
        _HelpTopic(
          question: 'I forgot my password',
          answer: 'On the login screen, tap "Forgot Password". Enter your email and we\'ll send you instructions to reset your password.',
        ),
      ],
    ),
  ];

  List<_HelpCategory> get _filteredCategories {
    if (_searchQuery.isEmpty) return _categories;

    return _categories.map((category) {
      final filteredTopics = category.topics.where((topic) {
        return topic.question.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            topic.answer.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();

      return _HelpCategory(
        icon: category.icon,
        title: category.title,
        color: category.color,
        topics: filteredTopics,
      );
    }).where((category) => category.topics.isNotEmpty).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final filteredCategories = _filteredCategories;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Help Center',
          style: context.textStyles.headlineSmall?.bold,
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Header Section
          Container(
            padding: AppSpacing.paddingMd,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primaryContainer.withValues(alpha: 0.3),
                  colorScheme.surface,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.help_outline,
                  size: 60,
                  color: colorScheme.primary,
                ),
                SizedBox(height: AppSpacing.md),
                Text(
                  'How can we help you?',
                  style: context.textStyles.headlineSmall?.bold,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppSpacing.sm),
                Text(
                  'Find answers to common questions',
                  style: context.textStyles.bodyMedium?.withColor(
                    colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppSpacing.lg),

                // Search Bar
                TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  style: context.textStyles.bodyLarge,
                  decoration: InputDecoration(
                    hintText: 'Search for help...',
                    hintStyle: context.textStyles.bodyMedium?.withColor(
                      colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                    prefixIcon: Icon(Icons.search, color: colorScheme.primary),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => setState(() => _searchQuery = ''),
                          )
                        : null,
                    filled: true,
                    fillColor: colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.md,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Categories List
          Expanded(
            child: filteredCategories.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 80,
                          color: colorScheme.onSurface.withValues(alpha: 0.3),
                        ),
                        SizedBox(height: AppSpacing.lg),
                        Text(
                          'No results found',
                          style: context.textStyles.titleLarge,
                        ),
                        SizedBox(height: AppSpacing.sm),
                        Text(
                          'Try different keywords',
                          style: context.textStyles.bodyMedium?.withColor(
                            colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.only(
                      left: AppSpacing.md,
                      right: AppSpacing.md,
                      top: AppSpacing.lg,
                      bottom: AppSpacing.xl,
                    ),
                    itemCount: filteredCategories.length,
                    itemBuilder: (context, index) {
                      final category = filteredCategories[index];
                      return _CategorySection(
                        category: category,
                        isExpanded: _expandedIndex == index,
                        onToggle: () {
                          setState(() {
                            _expandedIndex = _expandedIndex == index ? null : index;
                          });
                        },
                      );
                    },
                  ),
          ),

          // Contact Support Section
          Container(
            padding: AppSpacing.paddingMd,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: colorScheme.outline.withValues(alpha: 0.1),
                ),
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Still need help?',
                  style: context.textStyles.titleSmall?.bold,
                ),
                SizedBox(height: AppSpacing.sm),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => context.push('/report-problem'),
                    icon: const Icon(Icons.support_agent),
                    label: const Text('Contact Support'),
                    style: FilledButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  final _HelpCategory category;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _CategorySection({
    required this.category,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          // Category Header
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onToggle,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              child: Padding(
                padding: AppSpacing.paddingMd,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: category.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Icon(
                        category.icon,
                        color: category.color,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category.title,
                            style: context.textStyles.titleSmall?.bold,
                          ),
                          SizedBox(height: AppSpacing.xs),
                          Text(
                            '${category.topics.length} article${category.topics.length != 1 ? 's' : ''}',
                            style: context.textStyles.bodySmall?.withColor(
                              colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Topics
          if (isExpanded) ...[
            Divider(
              height: 1,
              color: colorScheme.outline.withValues(alpha: 0.1),
            ),
            ...category.topics.asMap().entries.map((entry) {
              final topic = entry.value;
              final isLast = entry.key == category.topics.length - 1;

              return _TopicItem(
                topic: topic,
                isLast: isLast,
              );
            }),
          ],
        ],
      ),
    );
  }
}

class _TopicItem extends StatefulWidget {
  final _HelpTopic topic;
  final bool isLast;

  const _TopicItem({
    required this.topic,
    required this.isLast,
  });

  @override
  State<_TopicItem> createState() => _TopicItemState();
}

class _TopicItemState extends State<_TopicItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.topic.question,
                          style: context.textStyles.bodyLarge?.medium,
                        ),
                      ),
                      Icon(
                        _isExpanded ? Icons.remove : Icons.add,
                        size: 20,
                        color: colorScheme.primary,
                      ),
                    ],
                  ),
                  if (_isExpanded) ...[
                    SizedBox(height: AppSpacing.sm),
                    Text(
                      widget.topic.answer,
                      style: context.textStyles.bodyMedium?.withColor(
                        colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        if (!widget.isLast)
          Divider(
            height: 1,
            indent: AppSpacing.md,
            endIndent: AppSpacing.md,
            color: colorScheme.outline.withValues(alpha: 0.1),
          ),
      ],
    );
  }
}

class _HelpCategory {
  final IconData icon;
  final String title;
  final Color color;
  final List<_HelpTopic> topics;

  _HelpCategory({
    required this.icon,
    required this.title,
    required this.color,
    required this.topics,
  });
}

class _HelpTopic {
  final String question;
  final String answer;

  _HelpTopic({
    required this.question,
    required this.answer,
  });
}
