import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme.dart';

/// Shows a dialog prompting user to login
/// [redirectRoute] is the route to navigate to after successful login
Future<void> showLoginPromptDialog(
  BuildContext context, {
  String? message,
  String? redirectRoute,
}) async {
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(
              Icons.lock_person_rounded,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'Login Required',
              style: context.textStyles.titleLarge?.bold,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message ?? 'You need to be logged in to access this feature.',
            style: context.textStyles.bodyLarge?.withColor(
              Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Container(
            padding: AppSpacing.paddingMd,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Create an account or login to continue',
                    style: context.textStyles.bodySmall?.withColor(
                      Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
          ),
          child: Text(
            'Cancel',
            style: context.textStyles.titleSmall?.medium,
          ),
        ),
        FilledButton.icon(
          onPressed: () {
            context.pop();
            // Navigate to login with redirect parameter
            final loginRoute = redirectRoute != null 
                ? '/login?redirect=$redirectRoute'
                : '/login';
            context.push(loginRoute);
          },
          style: FilledButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
          icon: const Icon(Icons.login, size: 20),
          label: Text(
            'Login',
            style: context.textStyles.titleSmall?.semiBold,
          ),
        ),
      ],
    ),
  );
}
