import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme.dart';

class ReportProblemPage extends StatefulWidget {
  const ReportProblemPage({super.key});

  @override
  State<ReportProblemPage> createState() => _ReportProblemPageState();
}

class _ReportProblemPageState extends State<ReportProblemPage> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String _selectedCategory = 'Technical Issue';
  String _selectedPriority = 'Medium';
  bool _isLoading = false;

  final List<String> _categories = [
    'Technical Issue',
    'Account Problem',
    'Payment Issue',
    'Course Content',
    'Video Playback',
    'App Crash',
    'Feature Request',
    'Other',
  ];

  final List<String> _priorities = ['Low', 'Medium', 'High', 'Urgent'];

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isLoading = false);

    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          icon: Icon(
            Icons.check_circle_outline,
            size: 60,
            color: Theme.of(context).colorScheme.secondary,
          ),
          title: const Text('Report Submitted'),
          content: const Text(
            'Thank you for your report! Our support team will review it and get back to you within 24-48 hours.',
          ),
          actions: [
            FilledButton(
              onPressed: () {
                context.pop(); // Close dialog
                context.pop(); // Go back to previous screen
              },
              child: const Text('Done'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Report a Problem',
          style: context.textStyles.headlineSmall?.bold,
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: AppSpacing.paddingMd,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Container(
                  padding: AppSpacing.paddingLg,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.errorContainer.withValues(alpha: 0.3),
                        colorScheme.errorContainer.withValues(alpha: 0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colorScheme.error.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.support_agent,
                          size: 32,
                          color: colorScheme.error,
                        ),
                      ),
                      SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'We\'re here to help',
                              style: context.textStyles.titleMedium?.bold,
                            ),
                            SizedBox(height: AppSpacing.xs),
                            Text(
                              'Describe your issue and our team will get back to you soon',
                              style: context.textStyles.bodySmall?.withColor(
                                colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: AppSpacing.xl),

                // User Info (if logged in)
                if (user != null) ...[
                  Container(
                    padding: AppSpacing.paddingMd,
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: colorScheme.outline.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                          child: user.photoUrl != null
                              ? ClipOval(
                                  child: Image.network(
                                    user.photoUrl!,
                                    width: 48,
                                    height: 48,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Icon(
                                      Icons.person,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                )
                              : Icon(
                                  Icons.person,
                                  color: colorScheme.primary,
                                ),
                        ),
                        SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.name,
                                style: context.textStyles.titleSmall?.medium,
                              ),
                              Text(
                                user.email,
                                style: context.textStyles.bodySmall?.withColor(
                                  colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppSpacing.xl),
                ],

                // Category Selection
                Text(
                  'Category',
                  style: context.textStyles.titleSmall?.bold,
                ),
                SizedBox(height: AppSpacing.sm),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.category_outlined, color: colorScheme.primary),
                    filled: true,
                    fillColor: colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: BorderSide(
                        color: colorScheme.outline.withValues(alpha: 0.2),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: BorderSide(
                        color: colorScheme.outline.withValues(alpha: 0.2),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: BorderSide(
                        color: colorScheme.primary,
                        width: 2,
                      ),
                    ),
                  ),
                  items: _categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedCategory = value);
                    }
                  },
                ),

                SizedBox(height: AppSpacing.lg),

                // Priority Selection
                Text(
                  'Priority',
                  style: context.textStyles.titleSmall?.bold,
                ),
                SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  children: _priorities.map((priority) {
                    final isSelected = priority == _selectedPriority;
                    Color priorityColor;
                    switch (priority) {
                      case 'Low':
                        priorityColor = const Color(0xFF22C55E);
                        break;
                      case 'Medium':
                        priorityColor = const Color(0xFFF59E0B);
                        break;
                      case 'High':
                        priorityColor = const Color(0xFFEF4444);
                        break;
                      case 'Urgent':
                        priorityColor = const Color(0xFF991B1B);
                        break;
                      default:
                        priorityColor = colorScheme.primary;
                    }

                    return FilterChip(
                      label: Text(priority),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() => _selectedPriority = priority);
                      },
                      backgroundColor: colorScheme.surface,
                      selectedColor: priorityColor.withValues(alpha: 0.2),
                      checkmarkColor: priorityColor,
                      labelStyle: TextStyle(
                        color: isSelected ? priorityColor : colorScheme.onSurface,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                      side: BorderSide(
                        color: isSelected 
                            ? priorityColor
                            : colorScheme.outline.withValues(alpha: 0.2),
                        width: isSelected ? 2 : 1,
                      ),
                    );
                  }).toList(),
                ),

                SizedBox(height: AppSpacing.lg),

                // Subject Field
                Text(
                  'Subject',
                  style: context.textStyles.titleSmall?.bold,
                ),
                SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: _subjectController,
                  style: context.textStyles.bodyLarge,
                  decoration: InputDecoration(
                    hintText: 'Brief summary of the issue',
                    hintStyle: context.textStyles.bodyMedium?.withColor(
                      colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                    prefixIcon: Icon(Icons.subject, color: colorScheme.primary),
                    filled: true,
                    fillColor: colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: BorderSide(
                        color: colorScheme.outline.withValues(alpha: 0.2),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: BorderSide(
                        color: colorScheme.outline.withValues(alpha: 0.2),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: BorderSide(
                        color: colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: BorderSide(
                        color: colorScheme.error,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a subject';
                    }
                    return null;
                  },
                ),

                SizedBox(height: AppSpacing.lg),

                // Description Field
                Text(
                  'Description',
                  style: context.textStyles.titleSmall?.bold,
                ),
                SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: _descriptionController,
                  style: context.textStyles.bodyLarge,
                  maxLines: 6,
                  decoration: InputDecoration(
                    hintText: 'Describe the problem in detail...\n\nInclude:\n• What you were doing\n• What went wrong\n• Any error messages',
                    hintStyle: context.textStyles.bodyMedium?.withColor(
                      colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                    filled: true,
                    fillColor: colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: BorderSide(
                        color: colorScheme.outline.withValues(alpha: 0.2),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: BorderSide(
                        color: colorScheme.outline.withValues(alpha: 0.2),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: BorderSide(
                        color: colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: BorderSide(
                        color: colorScheme.error,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please describe the problem';
                    }
                    if (value.trim().length < 20) {
                      return 'Please provide more details (at least 20 characters)';
                    }
                    return null;
                  },
                ),

                SizedBox(height: AppSpacing.xl),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isLoading ? null : _submitReport,
                    style: FilledButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colorScheme.onPrimary,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.send),
                              SizedBox(width: AppSpacing.sm),
                              Text(
                                'Submit Report',
                                style: context.textStyles.titleSmall?.bold,
                              ),
                            ],
                          ),
                  ),
                ),

                SizedBox(height: AppSpacing.md),

                // Cancel Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => context.pop(),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: context.textStyles.titleSmall?.medium,
                    ),
                  ),
                ),

                SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
