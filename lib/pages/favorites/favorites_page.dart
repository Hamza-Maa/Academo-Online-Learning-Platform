import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/course.dart';
import '../../providers/auth_provider.dart';
import '../../providers/course_provider.dart';
import '../../widgets/course_card.dart';
import '../../widgets/custom_bottom_nav.dart';
import '../../theme.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<Course> _favoriteCourses = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isAuthenticated) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final courseProvider = context.read<CourseProvider>();
    final favoriteIds = authProvider.currentUser!.favoriteCourses;
    final courses = <Course>[];

    for (final courseId in favoriteIds) {
      final course = await courseProvider.getCourseById(courseId);
      if (course != null) {
        courses.add(course);
      }
    }

    setState(() {
      _favoriteCourses = courses;
      _isLoading = false;
    });
  }

  List<Course> get _filteredCourses {
    if (_searchQuery.isEmpty) {
      return _favoriteCourses;
    }
    
    return _favoriteCourses.where((course) {
      return course.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             course.instructor.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             course.categories.any((cat) => cat.toLowerCase().contains(_searchQuery.toLowerCase()));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final filteredCourses = _filteredCourses;

    if (!authProvider.isAuthenticated) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Favorites'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.favorite_border,
                size: 80,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
              ),
              SizedBox(height: AppSpacing.lg),
              Text(
                'Please login to view favorites',
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
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: 64,
        titleSpacing: AppSpacing.lg,
        title: const Text('Favorites'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favoriteCourses.isEmpty
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
                          Icons.favorite_border,
                          size: 64,
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                        ),
                      ),
                      SizedBox(height: AppSpacing.lg),
                      Text(
                        'No favorites yet',
                        style: context.textStyles.titleLarge?.bold,
                      ),
                      SizedBox(height: AppSpacing.sm),
                      Padding(
                        padding: AppSpacing.horizontalXl,
                        child: Text(
                          'Start adding courses to your favorites',
                          style: context.textStyles.bodyMedium?.withColor(
                            Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: AppSpacing.xl),
                      FilledButton.icon(
                        onPressed: () => context.go('/'),
                        icon: const Icon(Icons.explore_rounded),
                        label: const Text('Browse Courses'),
                        style: FilledButton.styleFrom(
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
                    // Search Bar
                    Container(
                      padding: EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.md,
                        AppSpacing.lg,
                        AppSpacing.md,
                      ),
                      color: Theme.of(context).colorScheme.surface,
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
                          },
                        ),
                      ),
                    ),

                    const Divider(height: 1),

                    // Results Count
                    if (_favoriteCourses.isNotEmpty)
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
                              '${filteredCourses.length} ${filteredCourses.length == 1 ? 'course' : 'courses'} found',
                              style: context.textStyles.bodyMedium?.semiBold.withColor(
                                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Course Grid
                    Expanded(
                      child: filteredCourses.isEmpty
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
                                      'Try adjusting your search query',
                                      style: context.textStyles.bodyMedium?.withColor(
                                        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : GridView.builder(
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
                              itemCount: filteredCourses.length,
                              itemBuilder: (context, index) {
                                return CourseCard(course: filteredCourses[index]);
                              },
                            ),
                    ),
                  ],
                ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 3),
    );
  }
}
