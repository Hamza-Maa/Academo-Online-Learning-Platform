import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showNotification;

  const CustomAppBar({
    super.key,
    this.title = 'Academo',
    this.showNotification = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return AppBar(
      elevation: 0,
      toolbarHeight: 70,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
            ],
          ),
        ),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: const Icon(
              Icons.school_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Text(
            title,
            style: context.textStyles.headlineSmall?.bold.withColor(Colors.white),
          ),
        ],
      ),
      actions: [
        if (showNotification)
          Container(
            margin: EdgeInsets.only(right: AppSpacing.sm),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.notifications_outlined,
                color: Colors.white,
              ),
              onPressed: () {
                // TODO: Implement notifications
              },
            ),
          ),
        if (!authProvider.isAuthenticated)
          Container(
            margin: EdgeInsets.only(right: AppSpacing.md),
            child: TextButton(
              onPressed: () => context.push('/login'),
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Theme.of(context).colorScheme.primary,
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
              ),
              child: Text(
                'Login',
                style: context.textStyles.labelLarge?.semiBold.withColor(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          )
        else
          SizedBox(width: AppSpacing.md),
      ],
    );
  }
}
