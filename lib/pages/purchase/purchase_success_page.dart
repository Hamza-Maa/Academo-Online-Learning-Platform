import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme.dart';

class PurchaseSuccessPage extends StatelessWidget {
  final String purchaseId;

  const PurchaseSuccessPage({
    super.key,
    required this.purchaseId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.paddingLg,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.purchasedIndicator.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 80,
                  color: AppColors.purchasedIndicator,
                ),
              ),
              SizedBox(height: AppSpacing.xl),
              Text(
                'Payment Successful!',
                style: context.textStyles.headlineMedium?.bold,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.md),
              Text(
                'Your purchase has been completed successfully. You now have full access to the course.',
                style: context.textStyles.bodyLarge,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.sm),
              Text(
                'Transaction ID: $purchaseId',
                style: context.textStyles.bodySmall?.withColor(
                  Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.xxl),
              FilledButton(
                onPressed: () => context.go('/my-courses'),
                child: const Text('Go to My Courses'),
              ),
              SizedBox(height: AppSpacing.md),
              OutlinedButton(
                onPressed: () => context.go('/'),
                child: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
