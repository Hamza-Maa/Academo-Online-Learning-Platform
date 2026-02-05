import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme.dart';

class PurchaseFailedPage extends StatelessWidget {
  final String purchaseId;

  const PurchaseFailedPage({
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
                  color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline,
                  size: 80,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              SizedBox(height: AppSpacing.xl),
              Text(
                'Payment Failed',
                style: context.textStyles.headlineMedium?.bold,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.md),
              Text(
                'Unfortunately, your payment could not be processed. Please try again or contact support.',
                style: context.textStyles.bodyLarge,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.sm),
              Text(
                'Reference ID: $purchaseId',
                style: context.textStyles.bodySmall?.withColor(
                  Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.xxl),
              FilledButton(
                onPressed: () => context.pop(),
                child: const Text('Try Again'),
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
