import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/course.dart';
import '../../providers/auth_provider.dart';
import '../../providers/course_provider.dart';
import '../../providers/progress_provider.dart';
import '../../widgets/course_card.dart';
import '../../widgets/custom_bottom_nav.dart';
import '../../theme.dart';

class MyCoursesPage extends StatefulWidget {
  const MyCoursesPage({super.key});

  @override
  State<MyCoursesPage> createState() => _MyCoursesPageState();
}

class _MyCoursesPageState extends State<MyCoursesPage> with SingleTickerProviderStateMixin {
  List<Course> _myCourses = [];
  List<Course> _favoriteCourses = [];
  Map<String, double> _courseProgress = {};
  bool _isLoading = true;
  
  // Tab controller
  late TabController _tabController;
  
  // Search and filter state
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedStatus = 'all'; // all, in-progress, completed, not-started
  String _sortBy = 'recent'; // recent, progress, title

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadMyCourses();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadMyCourses() async {
    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isAuthenticated) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final courseProvider = context.read<CourseProvider>();
    final progressProvider = context.read<ProgressProvider>();
    
    final purchasedIds = authProvider.currentUser!.purchasedCourses;
    final courses = <Course>[];
    final progress = <String, double>{};

    for (final courseId in purchasedIds) {
      final course = await courseProvider.getCourseById(courseId);
      if (course != null) {
        courses.add(course);
        
        final lessons = await courseProvider.getLessonsByCourseId(courseId);
        final courseProgress = await progressProvider.getCourseProgress(
          authProvider.currentUser!.id,
          courseId,
        );
        
        progress[courseId] = courseProgress?.calculatePercentage(lessons.length) ?? 0;
      }
    }

    // Also include free courses
    final allCourses = await courseProvider.getAllCourses();
    final freeCourses = allCourses.where((c) => c.isFree).toList();
    
    for (final course in freeCourses) {
      if (!courses.any((c) => c.id == course.id)) {
        courses.add(course);
        
        final lessons = await courseProvider.getLessonsByCourseId(course.id);
        final courseProgress = await progressProvider.getCourseProgress(
          authProvider.currentUser!.id,
          course.id,
        );
        
        progress[course.id] = courseProgress?.calculatePercentage(lessons.length) ?? 0;
      }
    }

    // Load favorites
    final favoriteIds = authProvider.currentUser!.favoriteCourses;
    final favorites = <Course>[];
    
    for (final courseId in favoriteIds) {
      final course = await courseProvider.getCourseById(courseId);
      if (course != null) {
        favorites.add(course);
      }
    }

    setState(() {
      _myCourses = courses;
      _favoriteCourses = favorites;
      _courseProgress = progress;
      _isLoading = false;
    });
  }

  List<Course> get _filteredCourses {
    final isMyCoursesTab = _tabController.index == 0;
    final sourceList = isMyCoursesTab ? _myCourses : _favoriteCourses;
    
    var filtered = sourceList.where((course) {
      // Search filter
      final matchesSearch = _searchQuery.isEmpty ||
          course.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          course.instructor.toLowerCase().contains(_searchQuery.toLowerCase());

      if (!matchesSearch) return false;

      // Status filter
      final progress = _courseProgress[course.id] ?? 0;
      switch (_selectedStatus) {
        case 'in-progress':
          return progress > 0 && progress < 100;
        case 'completed':
          return progress >= 100;
        case 'not-started':
          return progress == 0;
        default:
          return true;
      }
    }).toList();

    // Sort
    switch (_sortBy) {
      case 'progress':
        filtered.sort((a, b) {
          final progressA = _courseProgress[a.id] ?? 0;
          final progressB = _courseProgress[b.id] ?? 0;
          return progressB.compareTo(progressA);
        });
        break;
      case 'title':
        filtered.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'recent':
      default:
        // Keep original order (most recently added)
        break;
    }

    return filtered;
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                SizedBox(height: AppSpacing.lg),

                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.filter_list_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        'Filter & Sort',
                        style: context.textStyles.headlineSmall?.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                      style: IconButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.xl),

                // Status Filter Section
                Container(
                  padding: AppSpacing.paddingMd,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.timeline_rounded,
                            size: 20,
                            color: const Color(0xFF2563EB),
                          ),
                          SizedBox(width: AppSpacing.sm),
                          Text(
                            'Progress Status',
                            style: context.textStyles.titleMedium?.bold,
                          ),
                        ],
                      ),
                      SizedBox(height: AppSpacing.md),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: [
                          _buildFilterChip('All Courses', 'all', setModalState),
                          _buildFilterChip('In Progress', 'in-progress', setModalState),
                          _buildFilterChip('Completed', 'completed', setModalState),
                          _buildFilterChip('Not Started', 'not-started', setModalState),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppSpacing.lg),

                // Sort Options Section
                Container(
                  padding: AppSpacing.paddingMd,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.sort_rounded,
                            size: 20,
                            color: const Color(0xFF2563EB),
                          ),
                          SizedBox(width: AppSpacing.sm),
                          Text(
                            'Sort By',
                            style: context.textStyles.titleMedium?.bold,
                          ),
                        ],
                      ),
                      SizedBox(height: AppSpacing.md),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: [
                          _buildSortChip('Most Recent', 'recent', setModalState),
                          _buildSortChip('Progress', 'progress', setModalState),
                          _buildSortChip('Title', 'title', setModalState),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppSpacing.xl),

                // Apply Button
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF22C55E).withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        setState(() {}); // Refresh main page
                        Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.check_circle_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                            SizedBox(width: AppSpacing.sm),
                            Text(
                              'Apply Filters',
                              style: context.textStyles.titleMedium?.bold.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: AppSpacing.md),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, StateSetter setModalState) {
    final isSelected = _selectedStatus == value;
    return InkWell(
      onTap: () {
        setModalState(() {
          _selectedStatus = value;
        });
      },
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
                )
              : null,
          color: isSelected ? null : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              Padding(
                padding: EdgeInsets.only(right: AppSpacing.xs),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            Text(
              label,
              style: context.textStyles.bodyMedium?.copyWith(
                color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortChip(String label, String value, StateSetter setModalState) {
    final isSelected = _sortBy == value;
    return InkWell(
      onTap: () {
        setModalState(() {
          _sortBy = value;
        });
      },
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
                )
              : null,
          color: isSelected ? null : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF22C55E).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              Padding(
                padding: EdgeInsets.only(right: AppSpacing.xs),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            Text(
              label,
              style: context.textStyles.bodyMedium?.copyWith(
                color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  int get _activeFilterCount {
    int count = 0;
    if (_selectedStatus != 'all') count++;
    if (_sortBy != 'recent') count++;
    return count;
  }

  Widget _buildEmptyState() {
    final isMyCoursesTab = _tabController.index == 0;
    
    return Center(
      child: Padding(
        padding: AppSpacing.paddingLg,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: AppSpacing.paddingXl,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isMyCoursesTab ? Icons.school_outlined : Icons.favorite_border,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            SizedBox(height: AppSpacing.xl),
            Text(
              isMyCoursesTab ? 'No courses yet' : 'No favorites yet',
              style: context.textStyles.headlineMedium?.semiBold,
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              isMyCoursesTab
                  ? 'Start your learning journey by\nenrolling in a course'
                  : 'Start adding courses to\nyour favorites',
              textAlign: TextAlign.center,
              style: context.textStyles.bodyLarge?.withColor(
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            SizedBox(height: AppSpacing.xl),
            FilledButton.icon(
              onPressed: () => context.go('/'),
              icon: const Icon(Icons.explore),
              label: const Text('Browse Courses'),
              style: FilledButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.md,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    if (!authProvider.isAuthenticated) {
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('My Courses'),
          toolbarHeight: 64,
          titleSpacing: 24,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.school_outlined,
                size: 80,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
              ),
              SizedBox(height: AppSpacing.lg),
              Text(
                'Please login to view your courses',
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

    final filteredCourses = _filteredCourses;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('My Learning'),
        toolbarHeight: 64,
        titleSpacing: 24,
        actions: [
          SizedBox(width: AppSpacing.md),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(44),
          child: Container(
            height: 36,
            margin: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: TabBar(
              controller: _tabController,
              onTap: (index) {
                setState(() {}); // Refresh when switching tabs
              },
              padding: EdgeInsets.all(4),
              indicator: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
                ),
                borderRadius: BorderRadius.circular(AppRadius.sm),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              labelStyle: context.textStyles.bodyMedium?.semiBold,
              unselectedLabelStyle: context.textStyles.bodyMedium?.medium,
              tabs: const [
                Tab(text: 'My Courses'),
                Tab(text: 'Favorites'),
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : (_tabController.index == 0 && _myCourses.isEmpty) ||
                  (_tabController.index == 1 && _favoriteCourses.isEmpty)
              ? _buildEmptyState()
              : Column(
                  children: [
                    // Search Bar and Filter
                    Container(
                      color: Theme.of(context).colorScheme.surface,
                      padding: EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.sm,
                        AppSpacing.lg,
                        AppSpacing.md,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                                ),
                              ),
                              child: TextField(
                                controller: _searchController,
                                onChanged: (value) {
                                  setState(() {
                                    _searchQuery = value;
                                  });
                                },
                                decoration: InputDecoration(
                                  hintText: 'Search courses, instructors...',
                                  prefixIcon: Icon(
                                    Icons.search_rounded,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                  suffixIcon: _searchQuery.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(Icons.clear_rounded, size: 20),
                                          onPressed: () {
                                            _searchController.clear();
                                            setState(() {
                                              _searchQuery = '';
                                            });
                                          },
                                        )
                                      : null,
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: AppSpacing.md,
                                    vertical: AppSpacing.md,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: AppSpacing.sm),
                          // Enhanced Filter Button
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFF2563EB),
                                      const Color(0xFF1E40AF),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(AppRadius.md),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: _showFilterModal,
                                    borderRadius: BorderRadius.circular(AppRadius.md),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Icon(
                                        Icons.tune_rounded,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              if (_activeFilterCount > 0)
                                Positioned(
                                  right: -4,
                                  top: -4,
                                  child: Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF22C55E),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Theme.of(context).colorScheme.surface,
                                        width: 2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.2),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 20,
                                      minHeight: 20,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '$_activeFilterCount',
                                        style: context.textStyles.labelSmall?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Active Filters Display
                    if (_selectedStatus != 'all' || _sortBy != 'recent')
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.sm,
                        ),
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        child: Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          children: [
                            if (_selectedStatus != 'all')
                              Chip(
                                label: Text(
                                  _selectedStatus == 'in-progress'
                                      ? 'In Progress'
                                      : _selectedStatus == 'not-started'
                                          ? 'Not Started'
                                          : 'Completed',
                                ),
                                deleteIcon: const Icon(Icons.close, size: 16),
                                onDeleted: () {
                                  setState(() {
                                    _selectedStatus = 'all';
                                  });
                                },
                                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                labelStyle: context.textStyles.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            if (_sortBy != 'recent')
                              Chip(
                                label: Text(
                                  'Sort: ${_sortBy == 'progress' ? 'Progress' : 'Title'}',
                                ),
                                deleteIcon: const Icon(Icons.close, size: 16),
                                onDeleted: () {
                                  setState(() {
                                    _sortBy = 'recent';
                                  });
                                },
                                backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                                labelStyle: context.textStyles.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                          ],
                        ),
                      ),

                    // Results Count
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.md,
                      ),
                      child: Row(
                        children: [
                          Text(
                            '${filteredCourses.length} ${filteredCourses.length == 1 ? 'Course' : 'Courses'}',
                            style: context.textStyles.titleMedium?.semiBold,
                          ),
                        ],
                      ),
                    ),

                    // Courses List
                    Expanded(
                      child: filteredCourses.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.search_off,
                                    size: 64,
                                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                                  ),
                                  SizedBox(height: AppSpacing.lg),
                                  Text(
                                    'No courses found',
                                    style: context.textStyles.titleLarge,
                                  ),
                                  SizedBox(height: AppSpacing.sm),
                                  Text(
                                    'Try adjusting your filters',
                                    style: context.textStyles.bodyMedium?.withColor(
                                      Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : _tabController.index == 0
                              ? ListView.builder(
                                  padding: EdgeInsets.fromLTRB(
                                    AppSpacing.lg,
                                    0,
                                    AppSpacing.lg,
                                    AppSpacing.xl,
                                  ),
                                  itemCount: filteredCourses.length,
                                  itemBuilder: (context, index) {
                                    final course = filteredCourses[index];
                                    final progress = _courseProgress[course.id] ?? 0;
                                    
                                    return EnhancedMyCourseCard(
                                      course: course,
                                      progress: progress,
                                    );
                                  },
                                )
                              : GridView.builder(
                                  padding: EdgeInsets.fromLTRB(
                                    AppSpacing.lg,
                                    0,
                                    AppSpacing.lg,
                                    AppSpacing.xl,
                                  ),
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 0.65,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                  ),
                                  itemCount: filteredCourses.length,
                                  itemBuilder: (context, index) {
                                    return CourseCard(course: filteredCourses[index]);
                                  },
                                ),
                    ),
                  ],
                ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 2),
    );
  }
}

class EnhancedMyCourseCard extends StatelessWidget {
  final Course course;
  final double progress;

  const EnhancedMyCourseCard({
    super.key,
    required this.course,
    required this.progress,
  });

  Color _getProgressColor(BuildContext context) {
    if (progress == 0) return Theme.of(context).colorScheme.surfaceContainerHighest;
    if (progress < 30) return Colors.red;
    if (progress < 70) return Colors.orange;
    return Colors.green;
  }

  String _getProgressLabel() {
    if (progress == 0) return 'Not Started';
    if (progress >= 100) return 'Completed';
    return '${progress.toStringAsFixed(0)}% Complete';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: InkWell(
        onTap: () => context.push('/course/${course.id}'),
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Compact Thumbnail
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(AppRadius.md)),
                  child: Image.network(
                    course.thumbnailUrl,
                    width: 110,
                    height: 110,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: const BorderRadius.horizontal(left: Radius.circular(AppRadius.md)),
                      ),
                      child: Icon(
                        Icons.play_circle_outline,
                        size: 40,
                        color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ),
                // Progress Badge
                Positioned(
                  top: 6,
                  left: 6,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: _getProgressColor(context),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          progress >= 100
                              ? Icons.check_circle
                              : progress > 0
                                  ? Icons.play_circle_filled
                                  : Icons.circle_outlined,
                          color: Colors.white,
                          size: 12,
                        ),
                        if (progress > 0 && progress < 100) ...[
                          SizedBox(width: 3),
                          Text(
                            '${progress.toInt()}%',
                            style: context.textStyles.labelSmall?.bold.copyWith(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Course Info
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      course.title,
                      style: context.textStyles.titleMedium?.bold,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            course.instructor,
                            style: context.textStyles.bodySmall?.withColor(
                              Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.sm),

                    // Progress Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: progress / 100,
                        minHeight: 4,
                        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                        color: _getProgressColor(context),
                      ),
                    ),
                    SizedBox(height: 4),
                    
                    Text(
                      _getProgressLabel(),
                      style: context.textStyles.labelSmall?.withColor(
                        Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Action Button - Compact Icon
            Padding(
              padding: EdgeInsets.all(AppSpacing.sm),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: progress >= 100
                        ? [Color(0xFF22C55E), Color(0xFF16A34A)]
                        : progress > 0
                            ? [Color(0xFF22C55E), Color(0xFF16A34A)]
                            : [Color(0xFF2563EB), Color(0xFF1E40AF)],
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  boxShadow: [
                    BoxShadow(
                      color: (progress > 0 ? Color(0xFF22C55E) : Color(0xFF2563EB))
                          .withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => context.push('/course/${course.id}'),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    child: Icon(
                      progress >= 100
                          ? Icons.replay_rounded
                          : progress > 0
                              ? Icons.play_arrow_rounded
                              : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


}
