import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../models/course.dart';
import '../../providers/auth_provider.dart';
import '../../providers/course_provider.dart';
import '../../widgets/course_card.dart';
import '../../widgets/carousel_course_card.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_nav.dart';
import '../../theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _searchController = TextEditingController();
  List<Course> _searchResults = [];
  bool _isSearching = false;
  int _carouselCurrentIndex = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    final courseProvider = context.read<CourseProvider>();
    final results = await courseProvider.searchCourses(query);

    setState(() {
      _searchResults = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final courseProvider = context.watch<CourseProvider>();

    return Scaffold(
      appBar: const CustomAppBar(),
      body: courseProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.lg, AppSpacing.md, AppSpacing.sm),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                            ),
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: _performSearch,
                            style: context.textStyles.bodyMedium,
                            decoration: InputDecoration(
                              hintText: 'Search courses, instructors...',
                              prefixIcon: Icon(
                                Icons.search_rounded,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear_rounded, size: 20),
                                      onPressed: () {
                                        _searchController.clear();
                                        _performSearch('');
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
                        if (_isSearching) ...[
                          SizedBox(height: AppSpacing.lg),
                          Row(
                            children: [
                              Icon(
                                Icons.search_rounded,
                                color: Theme.of(context).colorScheme.primary,
                                size: 24,
                              ),
                              SizedBox(width: AppSpacing.sm),
                              Text(
                                'Search Results',
                                style: context.textStyles.headlineSmall?.bold,
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                if (_isSearching)
                  _searchResults.isEmpty
                      ? SliverFillRemaining(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off_rounded,
                                  size: 64,
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                                ),
                                SizedBox(height: AppSpacing.md),
                                Text(
                                  'No courses found',
                                  style: context.textStyles.bodyLarge?.withColor(
                                    Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : SliverPadding(
                          padding: AppSpacing.paddingMd,
                          sliver: SliverGrid(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.7,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) => CourseCard(course: _searchResults[index]),
                              childCount: _searchResults.length,
                            ),
                          ),
                        )
                else ...[
                  FeaturedCoursesCarousel(
                    onIndexChanged: (index) {
                      setState(() {
                        _carouselCurrentIndex = index;
                      });
                    },
                    currentIndex: _carouselCurrentIndex,
                  ),
                  CategoriesSection(),
                  AllCoursesSection(),
                ],
              ],
            ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 0),
    );
  }
}

class FeaturedCoursesCarousel extends StatelessWidget {
  final Function(int) onIndexChanged;
  final int currentIndex;

  const FeaturedCoursesCarousel({
    super.key,
    required this.onIndexChanged,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    final courseProvider = context.watch<CourseProvider>();

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.lg, AppSpacing.md, AppSpacing.md),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Icon(
                    Icons.star_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                Text(
                  'Featured Courses',
                  style: context.textStyles.headlineSmall?.bold,
                ),
              ],
            ),
          ),
          FutureBuilder<List<Course>>(
            future: courseProvider.getFeaturedCourses(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox(
                  height: 280,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              // Limit to only 3 carousel cards
              final courses = snapshot.data!.take(3).toList();
              return Column(
                children: [
                  CarouselSlider.builder(
                    itemCount: 3,
                    itemBuilder: (context, index, realIndex) {
                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                        child: CarouselCourseCard(course: courses[index]),
                      );
                    },
                    options: CarouselOptions(
                      height: 300,
                      viewportFraction: 0.75,
                      enlargeCenterPage: true,
                      enlargeFactor: 0.2,
                      autoPlay: true,
                      autoPlayInterval: const Duration(seconds: 4),
                      autoPlayAnimationDuration: const Duration(milliseconds: 800),
                      autoPlayCurve: Curves.easeInOutCubic,
                      onPageChanged: (index, reason) {
                        onIndexChanged(index);
                      },
                    ),
                  ),
                  SizedBox(height: AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      3,
                      (index) => Container(
                        width: currentIndex == index ? 24 : 8,
                        height: 8,
                        margin: EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: currentIndex == index
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}

class CategoriesSection extends StatelessWidget {
  const CategoriesSection({super.key});

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'programming':
        return Icons.code_rounded;
      case 'design':
        return Icons.palette_rounded;
      case 'business':
        return Icons.business_center_rounded;
      case 'marketing':
        return Icons.campaign_rounded;
      case 'photography':
        return Icons.camera_alt_rounded;
      case 'music':
        return Icons.music_note_rounded;
      case 'fitness':
        return Icons.fitness_center_rounded;
      case 'language':
        return Icons.language_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final courseProvider = context.watch<CourseProvider>();

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.lg, AppSpacing.md, AppSpacing.md),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Icon(
                    Icons.grid_view_rounded,
                    color: Theme.of(context).colorScheme.secondary,
                    size: 20,
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                Text(
                  'Categories',
                  style: context.textStyles.headlineSmall?.bold,
                ),
              ],
            ),
          ),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: AppSpacing.horizontalMd,
              itemCount: courseProvider.categories.length,
              itemBuilder: (context, index) {
                final category = courseProvider.categories[index];
                return Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: InkWell(
                    onTap: () {
                      context.push('/browse?category=$category');
                    },
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    child: Container(
                      width: 100,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline,
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _getCategoryIcon(category),
                              color: Theme.of(context).colorScheme.primary,
                              size: 24,
                            ),
                          ),
                          SizedBox(height: AppSpacing.xs),
                          Text(
                            category,
                            style: context.textStyles.labelSmall?.semiBold,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}

class AllCoursesSection extends StatelessWidget {
  const AllCoursesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final courseProvider = context.watch<CourseProvider>();

    return SliverToBoxAdapter(
      child: Padding(
        padding: AppSpacing.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Icon(
                        Icons.library_books_rounded,
                        color: Theme.of(context).colorScheme.tertiary,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Text(
                      'All Courses',
                      style: context.textStyles.headlineSmall?.bold,
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () => context.push('/browse'),
                  icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                  label: Text(
                    'View All',
                    style: context.textStyles.labelMedium?.semiBold,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.md),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.68,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: courseProvider.courses.length,
              itemBuilder: (context, index) {
                return CourseCard(course: courseProvider.courses[index]);
              },
            ),
            SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}
