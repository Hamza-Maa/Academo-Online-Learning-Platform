import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/course.dart';
import '../../models/purchase.dart';
import '../../providers/auth_provider.dart';
import '../../providers/course_provider.dart';
import '../../services/purchase_service.dart';
import '../../theme.dart';

class PurchasePage extends StatefulWidget {
  final String courseId;

  const PurchasePage({
    super.key,
    required this.courseId,
  });

  @override
  State<PurchasePage> createState() => _PurchasePageState();
}

class _PurchasePageState extends State<PurchasePage> {
  Course? _course;
  bool _isLoading = true;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadCourse();
  }

  Future<void> _loadCourse() async {
    final courseProvider = context.read<CourseProvider>();
    final course = await courseProvider.getCourseById(widget.courseId);
    
    setState(() {
      _course = course;
      _isLoading = false;
    });
  }

  Future<void> _processPurchase() async {
    if (_course == null) return;

    setState(() {
      _isProcessing = true;
    });

    final authProvider = context.read<AuthProvider>();
    final purchaseService = PurchaseService();

    try {
      // Create purchase record
      final purchase = await purchaseService.createPurchase(
        userId: authProvider.currentUser!.id,
        courseId: _course!.id,
        amount: _course!.promotionalPrice ?? _course!.price,
      );

      // Simulate Mamopay payment processing
      await Future.delayed(const Duration(seconds: 2));

      // Random payment result for demo (in production, use actual Mamopay API)
      final success = DateTime.now().second % 3 != 0; // 66% success rate

      if (success) {
        // Update purchase status
        await purchaseService.updatePurchaseStatus(
          purchaseId: purchase.id,
          status: PaymentStatus.success,
          transactionId: 'MAMOPAY_${DateTime.now().millisecondsSinceEpoch}',
        );

        // Add course to user's purchased courses via auth service
        final authService = context.read<AuthProvider>();
        await authService.addPurchasedCourse(_course!.id);

        if (mounted) {
          context.go('/purchase-success/${purchase.id}');
        }
      } else {
        await purchaseService.updatePurchaseStatus(
          purchaseId: purchase.id,
          status: PaymentStatus.failed,
        );

        if (mounted) {
          context.go('/purchase-failed/${purchase.id}');
        }
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Purchase failed: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _course == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final finalPrice = _course!.promotionalPrice ?? _course!.price;
    final hasDiscount = _course!.promotionalPrice != null;
    final discount = hasDiscount ? _course!.price - _course!.promotionalPrice! : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course Preview Section
            Container(
              margin: AppSpacing.paddingMd,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Course Image
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppRadius.lg),
                    ),
                    child: Image.network(
                      _course!.thumbnailUrl,
                      width: double.infinity,
                      height: 180,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: double.infinity,
                        height: 180,
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        child: const Icon(Icons.image_not_supported, size: 48),
                      ),
                    ),
                  ),
                  // Course Info
                  Padding(
                    padding: AppSpacing.paddingMd,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _course!.title,
                          style: context.textStyles.titleLarge?.bold,
                        ),
                        SizedBox(height: AppSpacing.xs),
                        Row(
                          children: [
                            Icon(
                              Icons.person_outline,
                              size: 16,
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                            SizedBox(width: AppSpacing.xs),
                            Text(
                              _course!.instructor,
                              style: context.textStyles.bodyMedium?.withColor(
                                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Order Summary Section
            Padding(
              padding: AppSpacing.horizontalMd,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: AppSpacing.lg),
                  Text(
                    'Order Summary',
                    style: context.textStyles.titleLarge?.bold,
                  ),
                  SizedBox(height: AppSpacing.md),
                  Container(
                    padding: AppSpacing.paddingLg,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Course Price Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.school_outlined,
                                  size: 20,
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                                SizedBox(width: AppSpacing.sm),
                                Text(
                                  'Course Price',
                                  style: context.textStyles.bodyLarge,
                                ),
                              ],
                            ),
                            Text(
                              '\$${_course!.price.toStringAsFixed(2)}',
                              style: hasDiscount
                                  ? context.textStyles.bodyLarge?.withColor(
                                      Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                                    ).copyWith(
                                      decoration: TextDecoration.lineThrough,
                                    )
                                  : context.textStyles.bodyLarge?.semiBold,
                            ),
                          ],
                        ),
                        // Discount Row
                        if (hasDiscount) ...[
                          SizedBox(height: AppSpacing.md),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Icon(
                                      Icons.local_offer,
                                      size: 16,
                                      color: Colors.green,
                                    ),
                                  ),
                                  SizedBox(width: AppSpacing.sm),
                                  Text(
                                    'Special Discount',
                                    style: context.textStyles.bodyLarge?.withColor(Colors.green),
                                  ),
                                ],
                              ),
                              Text(
                                '-\$${discount.toStringAsFixed(2)}',
                                style: context.textStyles.bodyLarge?.bold.withColor(Colors.green),
                              ),
                            ],
                          ),
                        ],
                        Padding(
                          padding: AppSpacing.verticalMd,
                          child: Divider(
                            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                          ),
                        ),
                        // Total Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Amount',
                              style: context.textStyles.titleLarge?.bold,
                            ),
                            Text(
                              '\$${finalPrice.toStringAsFixed(2)}',
                              style: context.textStyles.headlineSmall?.bold.withColor(
                                Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Payment Method Section
            Padding(
              padding: AppSpacing.horizontalMd,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: AppSpacing.xl),
                  Text(
                    'Payment Method',
                    style: context.textStyles.titleLarge?.bold,
                  ),
                  SizedBox(height: AppSpacing.md),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: AppSpacing.paddingMd,
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Icon(
                          Icons.account_balance_wallet,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      title: Text(
                        'Mamopay',
                        style: context.textStyles.titleMedium?.semiBold,
                      ),
                      subtitle: Row(
                        children: [
                          Icon(
                            Icons.verified_user,
                            size: 14,
                            color: Colors.green.withValues(alpha: 0.8),
                          ),
                          SizedBox(width: AppSpacing.xs),
                          Text(
                            'Secure & encrypted',
                            style: context.textStyles.bodySmall?.withColor(
                              Colors.green.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Info Banner
            Padding(
              padding: AppSpacing.paddingMd,
              child: Column(
                children: [
                  SizedBox(height: AppSpacing.lg),
                  Container(
                    padding: AppSpacing.paddingMd,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.4),
                          Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Icon(
                            Icons.all_inclusive,
                            color: Theme.of(context).colorScheme.primary,
                            size: 24,
                          ),
                        ),
                        SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Lifetime Access',
                                style: context.textStyles.titleSmall?.semiBold.withColor(
                                  Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              SizedBox(height: AppSpacing.xs),
                              Text(
                                'Learn at your own pace with unlimited access',
                                style: context.textStyles.bodySmall?.withColor(
                                  Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppSpacing.md),
                  // Security badges
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.lock_outline,
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                      SizedBox(width: AppSpacing.xs),
                      Text(
                        'Secure checkout • Money-back guarantee',
                        style: context.textStyles.bodySmall?.withColor(
                          Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(
          left: AppSpacing.md,
          right: AppSpacing.md,
          top: AppSpacing.md,
          bottom: AppSpacing.md + MediaQuery.of(context).padding.bottom,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: FilledButton(
          onPressed: _isProcessing ? null : _processPurchase,
          style: FilledButton.styleFrom(
            padding: AppSpacing.paddingMd,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
          ),
          child: _isProcessing
              ? const Text('Processing...')
              : Text(
                  'Purchase',
                  style: context.textStyles.titleMedium?.bold,
                ),
        ),
      ),
    );
  }
}
