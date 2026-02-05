import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/course.dart';
import '../../models/module.dart';
import '../../models/lesson.dart';
import '../../providers/auth_provider.dart';
import '../../providers/course_provider.dart';
import '../../providers/progress_provider.dart';
import '../../utils/auth_utils.dart';
import '../../theme.dart';

class CourseDetailsPage extends StatefulWidget {
  final String courseId;

  const CourseDetailsPage({
    super.key,
    required this.courseId,
  });

  @override
  State<CourseDetailsPage> createState() => _CourseDetailsPageState();
}

class _CourseDetailsPageState extends State<CourseDetailsPage> {
  Course? _course;
  List<Module> _modules = [];
  Map<String, List<Lesson>> _moduleLessons = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCourseData();
  }

  Future<void> _loadCourseData() async {
    final courseProvider = context.read<CourseProvider>();
    
    final course = await courseProvider.getCourseById(widget.courseId);
    if (course == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Course not found')),
        );
        context.pop();
      }
      return;
    }

    final modules = await courseProvider.getModulesByCourseId(widget.courseId);
    final moduleLessons = <String, List<Lesson>>{};
    
    for (final module in modules) {
      final lessons = await courseProvider.getLessonsByModuleId(module.id);
      moduleLessons[module.id] = lessons;
    }

    setState(() {
      _course = course;
      _modules = modules;
      _moduleLessons = moduleLessons;
      _isLoading = false;
    });
  }

  void _handlePurchase() {
    final authProvider = context.read<AuthProvider>();
    
    if (!authProvider.isAuthenticated) {
      showLoginPromptDialog(
        context,
        message: 'Please login to purchase this course and start your learning journey.',
        redirectRoute: '/purchase/${widget.courseId}',
      );
      return;
    }

    context.push('/purchase/${widget.courseId}');
  }

  void _handleStartLearning() {
    if (_modules.isEmpty || _moduleLessons.isEmpty) return;
    
    final firstModule = _modules.first;
    final firstLesson = _moduleLessons[firstModule.id]?.first;
    
    if (firstLesson != null) {
      context.push('/video/${widget.courseId}/${firstLesson.id}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final hasPurchased = authProvider.hasPurchased(widget.courseId);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_course == null) {
      return const Scaffold(
        body: Center(child: Text('Course not found')),
      );
    }

    final totalLessons = _moduleLessons.values.fold<int>(
      0,
      (sum, lessons) => sum + lessons.length,
    );

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    _course!.thumbnailUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.primaryContainer,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Enhanced gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                  if (_course!.previewVideoUrl != null)
                    Positioned(
                      bottom: 20,
                      right: 20,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: FilledButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Preview Video'),
                                content: const Text('Video preview functionality'),
                                actions: [
                                  TextButton(
                                    onPressed: () => context.pop(),
                                    child: const Text('Close'),
                                  ),
                                ],
                              ),
                            );
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Theme.of(context).colorScheme.primary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                          icon: const Icon(Icons.play_arrow, size: 24),
                          label: const Text('Preview'),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              if (authProvider.isAuthenticated)
                Container(
                  margin: EdgeInsets.only(right: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: Icon(
                      authProvider.isFavorite(widget.courseId)
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: authProvider.isFavorite(widget.courseId) 
                          ? AppColors.cta 
                          : Colors.grey.shade600,
                    ),
                    onPressed: () => authProvider.toggleFavorite(widget.courseId),
                  ),
                ),
            ],
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppRadius.xl),
                  topRight: Radius.circular(AppRadius.xl),
                ),
              ),
              child: Padding(
                padding: AppSpacing.paddingMd,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category badges
                    if (_course!.categories.isNotEmpty)
                      Wrap(
                        spacing: AppSpacing.sm,
                        children: _course!.categories.take(2).map((category) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Text(
                            category.toUpperCase(),
                            style: context.textStyles.labelSmall?.semiBold.withColor(
                              Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        )).toList(),
                      ),
                    SizedBox(height: AppSpacing.md),
                    // Title
                    Text(
                      _course!.title,
                      style: context.textStyles.headlineMedium?.bold,
                    ),
                    SizedBox(height: AppSpacing.md),
                    // Instructor
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 22,
                            backgroundImage: NetworkImage(_course!.instructorAvatar),
                          ),
                        ),
                        SizedBox(width: AppSpacing.sm),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Instructor',
                              style: context.textStyles.bodySmall?.withColor(
                                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                            Text(
                              _course!.instructor,
                              style: context.textStyles.bodyLarge?.semiBold,
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.lg),
                    // Stats row with enhanced design
                    Container(
                      padding: AppSpacing.paddingMd,
                      decoration: BoxDecoration(
                        color: isDark 
                          ? Theme.of(context).colorScheme.surfaceContainerHighest
                          : const Color(0xFFF0F9FF),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(
                          color: isDark
                            ? Theme.of(context).colorScheme.outline.withValues(alpha: 0.2)
                            : Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _StatItem(
                            icon: Icons.signal_cellular_alt,
                            label: 'Level',
                            value: _course!.level.name.toUpperCase(),
                          ),
                          _VerticalDivider(),
                          _StatItem(
                            icon: Icons.access_time,
                            label: 'Duration',
                            value: _course!.formattedDuration,
                          ),
                          _VerticalDivider(),
                          _StatItem(
                            icon: Icons.play_circle_outline,
                            label: 'Lessons',
                            value: '$totalLessons',
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppSpacing.lg),
                    // About section
                    _SectionHeader(title: 'About This Course'),
                    SizedBox(height: AppSpacing.sm),
                    Text(
                      _course!.description,
                      style: context.textStyles.bodyLarge?.withColor(
                        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                      ),
                    ),
                    if (_course!.learningObjectives.isNotEmpty) ...[
                      SizedBox(height: AppSpacing.lg),
                      _SectionHeader(title: 'What You\'ll Learn'),
                      SizedBox(height: AppSpacing.sm),
                      Container(
                        padding: AppSpacing.paddingMd,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Column(
                          children: _course!.learningObjectives.map((objective) => Padding(
                                padding: EdgeInsets.only(bottom: AppSpacing.sm),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: AppColors.cta.withValues(alpha: 0.15),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.check,
                                        size: 16,
                                        color: AppColors.cta,
                                      ),
                                    ),
                                    SizedBox(width: AppSpacing.sm),
                                    Expanded(
                                      child: Text(
                                        objective,
                                        style: context.textStyles.bodyMedium,
                                      ),
                                    ),
                                  ],
                                ),
                              )).toList(),
                        ),
                      ),
                    ],
                    SizedBox(height: AppSpacing.lg),
                    _SectionHeader(title: 'Course Content'),
                    SizedBox(height: AppSpacing.sm),
                  ],
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final module = _modules[index];
                final lessons = _moduleLessons[module.id] ?? [];
                
                return ModuleTile(
                  module: module,
                  lessons: lessons,
                  courseId: widget.courseId,
                  canAccess: _course!.isFree || hasPurchased,
                );
              },
              childCount: _modules.length,
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: AppSpacing.paddingMd,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              if (!_course!.isFree) ...[
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Price',
                        style: context.textStyles.bodySmall?.withColor(
                          Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      Row(
                        children: [
                          if (_course!.promotionalPrice != null) ...[
                            Text(
                              '\$${_course!.price.toStringAsFixed(2)}',
                              style: context.textStyles.bodyLarge?.withColor(
                                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                              ).copyWith(
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            SizedBox(width: AppSpacing.sm),
                          ],
                          Text(
                            _course!.formattedPrice,
                            style: context.textStyles.headlineSmall?.bold.withColor(
                              Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: AppSpacing.md),
              ],
              SizedBox(
                width: 160,
                child: FilledButton.icon(
                  onPressed: (_course!.isFree || hasPurchased)
                      ? _handleStartLearning
                      : _handlePurchase,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: (_course!.isFree || hasPurchased)
                        ? AppColors.cta
                        : Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  icon: Icon(
                    (_course!.isFree || hasPurchased)
                        ? Icons.play_circle_filled
                        : Icons.shopping_cart,
                  ),
                  label: Text(
                    (_course!.isFree || hasPurchased)
                        ? 'Start Learning'
                        : 'Buy Now',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Enhanced stat item for course info
class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(
            icon,
            size: 24,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: context.textStyles.bodySmall?.withColor(
            Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        Text(
          value,
          style: context.textStyles.bodyMedium?.semiBold,
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: 1,
      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: AppSpacing.sm),
        Text(
          title,
          style: context.textStyles.titleLarge?.bold,
        ),
      ],
    );
  }
}

class ModuleTile extends StatefulWidget {
  final Module module;
  final List<Lesson> lessons;
  final String courseId;
  final bool canAccess;

  const ModuleTile({
    super.key,
    required this.module,
    required this.lessons,
    required this.courseId,
    required this.canAccess,
  });

  @override
  State<ModuleTile> createState() => _ModuleTileState();
}

class _ModuleTileState extends State<ModuleTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final totalDuration = widget.lessons.fold<int>(
      0,
      (sum, lesson) => sum + lesson.durationSeconds,
    );
    final minutes = totalDuration ~/ 60;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Padding(
              padding: AppSpacing.paddingMd,
              child: Row(
                children: [
                  // Module number badge
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.folder_outlined,
                        color: Theme.of(context).colorScheme.primary,
                        size: 24,
                      ),
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.module.title,
                          style: context.textStyles.titleMedium?.semiBold,
                        ),
                        if (widget.module.description != null) ...[
                          SizedBox(height: AppSpacing.xs),
                          Text(
                            widget.module.description!,
                            style: context.textStyles.bodySmall?.withColor(
                              Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        SizedBox(height: AppSpacing.xs),
                        Row(
                          children: [
                            Icon(
                              Icons.play_circle_outline,
                              size: 16,
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                            SizedBox(width: 4),
                            Text(
                              '${widget.lessons.length} lessons',
                              style: context.textStyles.bodySmall?.withColor(
                                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                            SizedBox(width: AppSpacing.sm),
                            Icon(
                              Icons.access_time,
                              size: 16,
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                            SizedBox(width: 4),
                            Text(
                              '$minutes min',
                              style: context.textStyles.bodySmall?.withColor(
                                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded)
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(AppRadius.md),
                  bottomRight: Radius.circular(AppRadius.md),
                ),
              ),
              child: Column(
                children: widget.lessons.map((lesson) => LessonTile(
                      lesson: lesson,
                      courseId: widget.courseId,
                      canAccess: widget.canAccess,
                    )).toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class LessonTile extends StatelessWidget {
  final Lesson lesson;
  final String courseId;
  final bool canAccess;

  const LessonTile({
    super.key,
    required this.lesson,
    required this.courseId,
    required this.canAccess,
  });

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: canAccess
          ? () => context.push('/video/$courseId/${lesson.id}')
          : null,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            // Play icon or lock icon
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: canAccess
                    ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(
                canAccess ? Icons.play_arrow : Icons.lock_outline,
                size: 20,
                color: canAccess 
                    ? Theme.of(context).colorScheme.primary 
                    : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.title,
                    style: context.textStyles.bodyMedium?.copyWith(
                      color: canAccess
                          ? Theme.of(context).colorScheme.onSurface
                          : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                  SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                      SizedBox(width: 4),
                      Text(
                        _formatDuration(lesson.durationSeconds),
                        style: context.textStyles.bodySmall?.withColor(
                          Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (canAccess)
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
              ),
          ],
        ),
      ),
    );
  }
}
