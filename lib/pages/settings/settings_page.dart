import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/progress_provider.dart';
import '../../widgets/custom_bottom_nav.dart';
import '../../theme.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  String _selectedLanguage = 'English';
  bool _darkModeEnabled = false;

  @override
  void initState() {
    super.initState();
    _darkModeEnabled = WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
  }

  void _showEditProfileDialog() {
    final authProvider = context.read<AuthProvider>();
    final nameController = TextEditingController(text: authProvider.currentUser?.name ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final success = await authProvider.updateProfile(
                name: nameController.text.trim(),
              );
              
              if (context.mounted) {
                context.pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Profile updated successfully' : 'Failed to update profile'),
                    backgroundColor: success ? null : Theme.of(context).colorScheme.error,
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    final languages = ['English', 'Spanish', 'French', 'German', 'Arabic', 'Chinese'];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages.map((lang) => RadioListTile<String>(
            title: Text(lang),
            value: lang,
            groupValue: _selectedLanguage,
            onChanged: (value) {
              setState(() => _selectedLanguage = value!);
              context.pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Language changed to $value')),
              );
            },
          )).toList(),
        ),
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              context.pop();
              final authProvider = context.read<AuthProvider>();
              final success = await authProvider.deleteAccount();
              
              if (context.mounted) {
                if (success) {
                  context.go('/login');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Account deleted successfully')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(authProvider.error ?? 'Failed to delete account'),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final progressProvider = context.watch<ProgressProvider>();
    final user = authProvider.currentUser;
    final colorScheme = Theme.of(context).colorScheme;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.settings_outlined,
                size: 80,
                color: colorScheme.onSurface.withValues(alpha: 0.3),
              ),
              SizedBox(height: AppSpacing.lg),
              Text(
                'Please login to access settings',
                style: context.textStyles.titleLarge,
              ),
              SizedBox(height: AppSpacing.lg),
              FilledButton(
                onPressed: () => context.push('/login'),
                child: const Text('Login'),
              ),
            ],
          ),
        ),
        bottomNavigationBar: const CustomBottomNav(currentIndex: 3),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: context.textStyles.headlineSmall?.bold,
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder<_UserStats>(
        future: _calculateStats(progressProvider, user.id),
        builder: (context, snapshot) {
          final stats = snapshot.data ?? _UserStats(0, 0);
          
          return SingleChildScrollView(
            child: Column(
              children: [
                // Profile Header
                Container(
                  margin: AppSpacing.paddingMd,
                  padding: AppSpacing.paddingLg,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primaryContainer,
                        colorScheme.primaryContainer.withValues(alpha: 0.5),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Avatar
                      Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: colorScheme.primary.withValues(alpha: 0.3),
                                width: 3,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                              child: user.photoUrl != null
                                  ? ClipOval(
                                      child: Image.network(
                                        user.photoUrl!,
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => Icon(
                                          Icons.person,
                                          size: 50,
                                          color: colorScheme.primary,
                                        ),
                                      ),
                                    )
                                  : Icon(
                                      Icons.person,
                                      size: 50,
                                      color: colorScheme.primary,
                                    ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _showEditProfileDialog,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: colorScheme.primaryContainer,
                                    width: 3,
                                  ),
                                ),
                                child: Icon(
                                  Icons.edit,
                                  size: 16,
                                  color: colorScheme.onPrimary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: AppSpacing.md),
                      
                      // Name
                      Text(
                        user.name,
                        style: context.textStyles.headlineSmall?.bold,
                      ),
                      
                      SizedBox(height: AppSpacing.xs),
                      
                      // Email
                      Text(
                        user.email,
                        style: context.textStyles.bodyMedium?.withColor(
                          colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                      
                      SizedBox(height: AppSpacing.lg),
                      
                      // Quick Stats
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _QuickStat(
                            icon: Icons.school_outlined,
                            value: '${user.purchasedCourses.length}',
                            label: 'Courses',
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: colorScheme.outline.withValues(alpha: 0.2),
                          ),
                          _QuickStat(
                            icon: Icons.emoji_events_outlined,
                            value: '${stats.completedCourses}',
                            label: 'Completed',
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: colorScheme.outline.withValues(alpha: 0.2),
                          ),
                          _QuickStat(
                            icon: Icons.access_time,
                            value: '${stats.totalHours}h',
                            label: 'Learned',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: AppSpacing.md),
                
                // Account Settings
                _SettingsSection(
                  title: 'Account',
                  children: [
                    _SettingsTile(
                      icon: Icons.person_outline,
                      title: 'Edit Profile',
                      subtitle: 'Update your name and photo',
                      onTap: () => context.push('/edit-profile'),
                    ),
                    _SettingsTile(
                      icon: Icons.email_outlined,
                      title: 'Email',
                      subtitle: user.email,
                      trailing: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.secondary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Text(
                          'Verified',
                          style: context.textStyles.labelSmall?.withColor(
                            colorScheme.secondary,
                          ),
                        ),
                      ),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Email verified')),
                        );
                      },
                    ),
                    _SettingsTile(
                      icon: Icons.receipt_long_outlined,
                      title: 'Purchase History',
                      subtitle: 'View all your transactions',
                      onTap: () => context.push('/purchase-history'),
                    ),
                  ],
                ),
                
                // Notifications
                _SettingsSection(
                  title: 'Notifications',
                  children: [
                    _SettingsTile(
                      icon: Icons.notifications_outlined,
                      title: 'Push Notifications',
                      subtitle: 'Receive course updates and reminders',
                      trailing: Switch(
                        value: _pushNotifications,
                        onChanged: (value) {
                          setState(() => _pushNotifications = value);
                        },
                      ),
                      onTap: null,
                    ),
                    _SettingsTile(
                      icon: Icons.email_outlined,
                      title: 'Email Notifications',
                      subtitle: 'Get updates via email',
                      trailing: Switch(
                        value: _emailNotifications,
                        onChanged: (value) {
                          setState(() => _emailNotifications = value);
                        },
                      ),
                      onTap: null,
                    ),
                  ],
                ),
                
                // Appearance
                _SettingsSection(
                  title: 'Appearance',
                  children: [
                    _SettingsTile(
                      icon: Icons.dark_mode_outlined,
                      title: 'Dark Mode',
                      subtitle: 'Adjust theme preference',
                      trailing: Switch(
                        value: _darkModeEnabled,
                        onChanged: (value) {
                          setState(() => _darkModeEnabled = value);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Theme changed to ${value ? 'dark' : 'light'} mode'),
                            ),
                          );
                        },
                      ),
                      onTap: null,
                    ),
                    _SettingsTile(
                      icon: Icons.language_outlined,
                      title: 'Language',
                      subtitle: _selectedLanguage,
                      onTap: _showLanguageDialog,
                    ),
                  ],
                ),
                
                // Privacy & Security
                _SettingsSection(
                  title: 'Privacy & Security',
                  children: [
                    _SettingsTile(
                      icon: Icons.lock_outline,
                      title: 'Change Password',
                      subtitle: 'Update your password',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Password change coming soon')),
                        );
                      },
                    ),
                    _SettingsTile(
                      icon: Icons.privacy_tip_outlined,
                      title: 'Privacy Policy',
                      subtitle: 'Read our privacy policy',
                      onTap: () => context.push('/privacy'),
                    ),
                    _SettingsTile(
                      icon: Icons.description_outlined,
                      title: 'Terms of Service',
                      subtitle: 'Read our terms',
                      onTap: () => context.push('/terms'),
                    ),
                  ],
                ),
                
                // Help & Support
                _SettingsSection(
                  title: 'Help & Support',
                  children: [
                    _SettingsTile(
                      icon: Icons.help_outline,
                      title: 'Help Center',
                      subtitle: 'Get help and support',
                      onTap: () => context.push('/help-center'),
                    ),
                    _SettingsTile(
                      icon: Icons.bug_report_outlined,
                      title: 'Report a Problem',
                      subtitle: 'Let us know about issues',
                      onTap: () => context.push('/report-problem'),
                    ),
                    _SettingsTile(
                      icon: Icons.info_outline,
                      title: 'About',
                      subtitle: 'App version 1.0.0',
                      onTap: () {
                        showAboutDialog(
                          context: context,
                          applicationName: 'Academo',
                          applicationVersion: '1.0.0',
                          applicationLegalese: '© 2024 Academo. All rights reserved.',
                        );
                      },
                    ),
                  ],
                ),
                
                SizedBox(height: AppSpacing.lg),
                
                // Logout Button
                Padding(
                  padding: AppSpacing.horizontalMd,
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Logout'),
                            content: const Text('Are you sure you want to logout?'),
                            actions: [
                              TextButton(
                                onPressed: () => context.pop(false),
                                child: const Text('Cancel'),
                              ),
                              FilledButton(
                                onPressed: () => context.pop(true),
                                child: const Text('Logout'),
                              ),
                            ],
                          ),
                        );
                        
                        if (confirmed == true && context.mounted) {
                          await authProvider.logout();
                          if (context.mounted) {
                            context.go('/login');
                          }
                        }
                      },
                      icon: Icon(
                        Icons.logout,
                        color: colorScheme.error,
                      ),
                      label: Text(
                        'Logout',
                        style: TextStyle(
                          color: colorScheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: AppSpacing.md,
                        ),
                        side: BorderSide(
                          color: colorScheme.error.withValues(alpha: 0.5),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
                
                SizedBox(height: AppSpacing.md),
                
                // Delete Account Button
                TextButton.icon(
                  onPressed: _showDeleteAccountDialog,
                  icon: Icon(
                    Icons.delete_outline,
                    color: colorScheme.error.withValues(alpha: 0.7),
                    size: 20,
                  ),
                  label: Text(
                    'Delete Account',
                    style: TextStyle(
                      color: colorScheme.error.withValues(alpha: 0.7),
                    ),
                  ),
                ),
                
                SizedBox(height: AppSpacing.xl),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 3),
    );
  }

  Future<_UserStats> _calculateStats(ProgressProvider progressProvider, String userId) async {
    final userProgress = await progressProvider.getUserProgress(userId);
    
    final totalWatchedSeconds = userProgress.fold<int>(
      0,
      (sum, progress) => sum + progress.lessonProgress.values.fold<int>(
        0,
        (lessonSum, lesson) => lessonSum + lesson.watchedSeconds,
      ),
    );
    
    final completedCoursesCount = userProgress.where((progress) {
      return progress.lessonProgress.values.isNotEmpty &&
          progress.lessonProgress.values.every((lesson) => lesson.isCompleted);
    }).length;

    final totalHours = (totalWatchedSeconds / 3600).round();

    return _UserStats(totalHours, completedCoursesCount);
  }
}

class _UserStats {
  final int totalHours;
  final int completedCourses;

  _UserStats(this.totalHours, this.completedCourses);
}

class _QuickStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _QuickStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Column(
      children: [
        Icon(
          icon,
          size: 24,
          color: colorScheme.primary,
        ),
        SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: context.textStyles.titleLarge?.bold,
        ),
        SizedBox(height: 2),
        Text(
          label,
          style: context.textStyles.bodySmall?.withColor(
            colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.sm,
          ),
          child: Text(
            title,
            style: context.textStyles.titleSmall?.semiBold.withColor(
              Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        Container(
          margin: AppSpacing.horizontalMd,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(
                  icon,
                  color: colorScheme.primary,
                  size: 22,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: context.textStyles.titleSmall?.medium,
                    ),
                    if (subtitle != null) ...[
                      SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: context.textStyles.bodySmall?.withColor(
                          colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              trailing ?? Icon(
                Icons.chevron_right,
                color: colorScheme.onSurface.withValues(alpha: 0.3),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
