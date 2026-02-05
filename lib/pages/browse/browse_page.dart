import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/course.dart';
import '../../providers/auth_provider.dart';
import '../../providers/course_provider.dart';
import '../../widgets/course_card.dart';
import '../../widgets/custom_bottom_nav.dart';
import '../../theme.dart';

class BrowsePage extends StatefulWidget {
  final String? category;

  const BrowsePage({
    super.key,
    this.category,
  });

  @override
  State<BrowsePage> createState() => _BrowsePageState();
}

class _BrowsePageState extends State<BrowsePage> {
  List<String> _selectedCategories = [];
  CourseLevel? _selectedLevel;
  bool? _showFreeOnly;
  List<Course> _filteredCourses = [];
  bool _isLoading = false;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _selectedCategories = [widget.category!];
    }
    _applyFilters();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _applyFilters() async {
    setState(() {
      _isLoading = true;
    });

    final courseProvider = context.read<CourseProvider>();
    final courses = await courseProvider.filterCourses(
      categories: _selectedCategories.isEmpty ? null : _selectedCategories,
      level: _selectedLevel,
      isFree: _showFreeOnly,
    );

    // Apply search filter
    final filteredBySearch = _searchQuery.isEmpty
        ? courses
        : courses.where((course) {
            return course.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                   course.instructor.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                   course.categories.any((cat) => cat.toLowerCase().contains(_searchQuery.toLowerCase()));
          }).toList();

    setState(() {
      _filteredCourses = filteredBySearch;
      _isLoading = false;
    });
  }

  int get _activeFilterCount {
    int count = 0;
    if (_selectedCategories.isNotEmpty) count += _selectedCategories.length;
    if (_selectedLevel != null) count++;
    if (_showFreeOnly == true) count++;
    return count;
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildFilterSheet(),
    );
  }

  Widget _buildFilterSheet() {
    return StatefulBuilder(
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
                      Icons.tune_rounded,
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

              // Categories Section
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
                          Icons.category_rounded,
                          size: 20,
                          color: const Color(0xFF9333EA),
                        ),
                        SizedBox(width: AppSpacing.sm),
                        Text(
                          'Categories',
                          style: context.textStyles.titleMedium?.bold,
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.md),
                    Consumer<CourseProvider>(
                      builder: (context, provider, child) => Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: provider.categories.map((category) {
                          final isSelected = _selectedCategories.contains(category);
                          return _buildFilterChip(
                            category,
                            isSelected,
                            () {
                              setModalState(() {
                                if (isSelected) {
                                  _selectedCategories.remove(category);
                                } else {
                                  _selectedCategories.add(category);
                                }
                              });
                            },
                            setModalState,
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.lg),

              // Level Section
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
                          Icons.signal_cellular_alt,
                          size: 20,
                          color: const Color(0xFF2563EB),
                        ),
                        SizedBox(width: AppSpacing.sm),
                        Text(
                          'Level',
                          style: context.textStyles.titleMedium?.bold,
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.md),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: CourseLevel.values.map((level) {
                        final isSelected = _selectedLevel == level;
                        return _buildFilterChip(
                          level.name.toUpperCase(),
                          isSelected,
                          () {
                            setModalState(() {
                              _selectedLevel = isSelected ? null : level;
                            });
                          },
                          setModalState,
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.lg),

              // Price Section
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
                          Icons.attach_money_rounded,
                          size: 20,
                          color: const Color(0xFF22C55E),
                        ),
                        SizedBox(width: AppSpacing.sm),
                        Text(
                          'Price',
                          style: context.textStyles.titleMedium?.bold,
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.md),
                    _buildFilterChip(
                      'Free Courses Only',
                      _showFreeOnly ?? false,
                      () {
                        setModalState(() {
                          _showFreeOnly = (_showFreeOnly ?? false) ? null : true;
                        });
                      },
                      setModalState,
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
                      _applyFilters();
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
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap, StateSetter setModalState) {
    return InkWell(
      onTap: onTap,
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

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final courseProvider = context.watch<CourseProvider>();
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: 64,
        titleSpacing: AppSpacing.lg,
        title: const Text('Browse Courses'),
      ),
      body: Column(
        children: [
          // Search Bar with Filter Button
          Container(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            color: Theme.of(context).colorScheme.surface,
            child: Row(
              children: [
                // Search Bar
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
                                  _applyFilters();
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.md,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                        _applyFilters();
                      },
                    ),
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                
                // Filter Button with Badge
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
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
                          onTap: _showFilterDialog,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          child: const Padding(
                            padding: EdgeInsets.all(12),
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

          // Quick Category Filter
          if (courseProvider.categories.isNotEmpty)
            Container(
              height: 50,
              padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
              color: Theme.of(context).colorScheme.surface,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                itemCount: courseProvider.categories.length + 1,
                separatorBuilder: (context, index) => SizedBox(width: AppSpacing.sm),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    final allSelected = _selectedCategories.isEmpty;
                    return _buildQuickFilterChip(
                      context,
                      label: 'All',
                      isSelected: allSelected,
                      onTap: () {
                        setState(() {
                          _selectedCategories = [];
                        });
                        _applyFilters();
                      },
                    );
                  }
                  final category = courseProvider.categories[index - 1];
                  final isSelected = _selectedCategories.contains(category);
                  return _buildQuickFilterChip(
                    context,
                    label: category,
                    isSelected: isSelected,
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedCategories.remove(category);
                        } else {
                          _selectedCategories = [category];
                        }
                      });
                      _applyFilters();
                    },
                  );
                },
              ),
            ),

          const Divider(height: 1),

          // Active Filters Row
          if (_selectedLevel != null || _showFreeOnly == true)
            Container(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              color: Theme.of(context).colorScheme.surface,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    if (_selectedLevel != null)
                      _buildActiveFilterChip(
                        context,
                        label: _selectedLevel!.name.toUpperCase(),
                        onRemove: () {
                          setState(() {
                            _selectedLevel = null;
                          });
                          _applyFilters();
                        },
                      ),
                    if (_selectedLevel != null && _showFreeOnly == true)
                      SizedBox(width: AppSpacing.sm),
                    if (_showFreeOnly == true)
                      _buildActiveFilterChip(
                        context,
                        label: 'Free',
                        onRemove: () {
                          setState(() {
                            _showFreeOnly = null;
                          });
                          _applyFilters();
                        },
                      ),
                  ],
                ),
              ),
            ),

          // Results
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredCourses.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.search_off_rounded,
                                size: 64,
                                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                              ),
                            ),
                            SizedBox(height: AppSpacing.lg),
                            Text(
                              'No courses found',
                              style: context.textStyles.titleLarge?.bold,
                            ),
                            SizedBox(height: AppSpacing.sm),
                            Padding(
                              padding: AppSpacing.horizontalXl,
                              child: Text(
                                'Try adjusting your filters or search query',
                                style: context.textStyles.bodyMedium?.withColor(
                                  Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(height: AppSpacing.xl),
                            OutlinedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _selectedCategories = [];
                                  _selectedLevel = null;
                                  _showFreeOnly = null;
                                  _searchQuery = '';
                                  _searchController.clear();
                                });
                                _applyFilters();
                              },
                              icon: const Icon(Icons.refresh_rounded),
                              label: const Text('Clear All Filters'),
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppSpacing.lg,
                                  vertical: AppSpacing.md,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Column(
                        children: [
                          // Results Count
                          Container(
                            padding: EdgeInsets.fromLTRB(
                              AppSpacing.lg,
                              AppSpacing.md,
                              AppSpacing.lg,
                              AppSpacing.sm,
                            ),
                            color: Theme.of(context).colorScheme.surface,
                            child: Row(
                              children: [
                                Text(
                                  '${_filteredCourses.length} courses found',
                                  style: context.textStyles.bodyMedium?.semiBold.withColor(
                                    Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Course Grid
                          Expanded(
                            child: GridView.builder(
                              padding: EdgeInsets.fromLTRB(
                                AppSpacing.lg,
                                AppSpacing.md,
                                AppSpacing.lg,
                                AppSpacing.lg,
                              ),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.65,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                              itemCount: _filteredCourses.length,
                              itemBuilder: (context, index) {
                                return CourseCard(course: _filteredCourses[index]);
                              },
                            ),
                          ),
                        ],
                      ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 1),
    );
  }

  Widget _buildQuickFilterChip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildActiveFilterChip(
    BuildContext context, {
    required String label,
    required VoidCallback onRemove,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          SizedBox(width: AppSpacing.xs),
          GestureDetector(
            onTap: onRemove,
            child: Icon(
              Icons.close_rounded,
              size: 16,
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}
