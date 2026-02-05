import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/purchase.dart';
import '../../models/course.dart';
import '../../providers/auth_provider.dart';
import '../../providers/course_provider.dart';
import '../../services/purchase_service.dart';
import '../../theme.dart';

class PurchaseHistoryPage extends StatefulWidget {
  const PurchaseHistoryPage({super.key});

  @override
  State<PurchaseHistoryPage> createState() => _PurchaseHistoryPageState();
}

class _PurchaseHistoryPageState extends State<PurchaseHistoryPage> {
  List<Purchase> _purchases = [];
  Map<String, Course> _coursesMap = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPurchases();
  }

  Future<void> _loadPurchases() async {
    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isAuthenticated) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final purchaseService = PurchaseService();
    final courseProvider = context.read<CourseProvider>();

    final purchases = await purchaseService.getUserPurchases(
      authProvider.currentUser!.id,
    );

    final coursesMap = <String, Course>{};
    for (final purchase in purchases) {
      final course = await courseProvider.getCourseById(purchase.courseId);
      if (course != null) {
        coursesMap[purchase.courseId] = course;
      }
    }

    setState(() {
      _purchases = purchases;
      _coursesMap = coursesMap;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    if (!authProvider.isAuthenticated) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Purchase History'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 80,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
              ),
              SizedBox(height: AppSpacing.lg),
              Text(
                'Please login to view purchase history',
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
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchase History'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _purchases.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 80,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                      ),
                      SizedBox(height: AppSpacing.lg),
                      Text(
                        'No purchases yet',
                        style: context.textStyles.titleLarge,
                      ),
                      SizedBox(height: AppSpacing.sm),
                      Text(
                        'Your purchase history will appear here',
                        style: context.textStyles.bodyMedium?.withColor(
                          Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: AppSpacing.paddingMd,
                  itemCount: _purchases.length,
                  itemBuilder: (context, index) {
                    final purchase = _purchases[index];
                    final course = _coursesMap[purchase.courseId];
                    
                    return PurchaseHistoryCard(
                      purchase: purchase,
                      course: course,
                    );
                  },
                ),
    );
  }
}

class PurchaseHistoryCard extends StatelessWidget {
  final Purchase purchase;
  final Course? course;

  const PurchaseHistoryCard({
    super.key,
    required this.purchase,
    this.course,
  });

  Color _getStatusColor(BuildContext context, PaymentStatus status) {
    switch (status) {
      case PaymentStatus.success:
        return Colors.green;
      case PaymentStatus.failed:
        return Theme.of(context).colorScheme.error;
      case PaymentStatus.pending:
        return Colors.orange;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      child: Padding(
        padding: AppSpacing.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    course?.title ?? 'Unknown Course',
                    style: context.textStyles.titleMedium?.semiBold,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(context, purchase.status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(
                    purchase.status.name.toUpperCase(),
                    style: context.textStyles.labelSmall?.bold.withColor(
                      _getStatusColor(context, purchase.status),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                SizedBox(width: AppSpacing.xs),
                Text(
                  _formatDate(purchase.createdAt),
                  style: context.textStyles.bodySmall?.withColor(
                    Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
            if (purchase.transactionId != null) ...[
              SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  Icon(
                    Icons.receipt,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  SizedBox(width: AppSpacing.xs),
                  Text(
                    purchase.transactionId!,
                    style: context.textStyles.bodySmall?.withColor(
                      Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ],
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Amount',
                  style: context.textStyles.bodyMedium?.semiBold,
                ),
                Text(
                  '\$${purchase.amount.toStringAsFixed(2)}',
                  style: context.textStyles.titleMedium?.bold.withColor(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
