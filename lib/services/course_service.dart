import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/course.dart';
import '../models/module.dart';
import '../models/lesson.dart';

class CourseService {
  static const _coursesKey = 'courses';
  static const _modulesKey = 'modules';
  static const _lessonsKey = 'lessons';

  // In-memory fallback storage
  static String? _coursesCache;
  static String? _modulesCache;
  static String? _lessonsCache;
  static bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Initialize with sample data if empty
      if (!prefs.containsKey(_coursesKey)) {
        await _initializeSampleData();
      }
      _isInitialized = true;
    } catch (e) {
      // Fallback to in-memory storage
      if (_coursesCache == null) {
        await _initializeSampleData();
      }
      _isInitialized = true;
    }
  }

  Future<List<Course>> getAllCourses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final coursesJson = prefs.getString(_coursesKey);
      if (coursesJson != null) {
        final List<dynamic> coursesList = jsonDecode(coursesJson);
        return coursesList.map((json) => Course.fromJson(json)).toList();
      }
    } catch (e) {
      // Use in-memory cache
      if (_coursesCache != null) {
        final List<dynamic> coursesList = jsonDecode(_coursesCache!);
        return coursesList.map((json) => Course.fromJson(json)).toList();
      }
    }
    return [];
  }

  Future<Course?> getCourseById(String id) async {
    final courses = await getAllCourses();
    try {
      return courses.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<Course>> getFeaturedCourses() async {
    final courses = await getAllCourses();
    return courses.take(5).toList();
  }

  Future<List<Course>> searchCourses(String query) async {
    final courses = await getAllCourses();
    final lowerQuery = query.toLowerCase();
    return courses.where((c) {
      return c.title.toLowerCase().contains(lowerQuery) ||
          c.description.toLowerCase().contains(lowerQuery) ||
          c.instructor.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  Future<List<Course>> filterCourses({
    List<String>? categories,
    CourseLevel? level,
    bool? isFree,
    double? maxPrice,
  }) async {
    var courses = await getAllCourses();

    if (categories != null && categories.isNotEmpty) {
      courses = courses.where((c) {
        return c.categories.any((cat) => categories.contains(cat));
      }).toList();
    }

    if (level != null) {
      courses = courses.where((c) => c.level == level).toList();
    }

    if (isFree != null) {
      courses = courses.where((c) => c.isFree == isFree).toList();
    }

    if (maxPrice != null) {
      courses = courses.where((c) {
        final price = c.promotionalPrice ?? c.price;
        return price <= maxPrice;
      }).toList();
    }

    return courses;
  }

  Future<List<String>> getAllCategories() async {
    final courses = await getAllCourses();
    final categories = <String>{};
    for (final course in courses) {
      categories.addAll(course.categories);
    }
    return categories.toList()..sort();
  }

  Future<List<Module>> getModulesByCourseId(String courseId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final modulesJson = prefs.getString(_modulesKey);
      if (modulesJson != null) {
        final List<dynamic> modulesList = jsonDecode(modulesJson);
        final modules = modulesList.map((json) => Module.fromJson(json)).toList();
        return modules.where((m) => m.courseId == courseId).toList()
          ..sort((a, b) => a.order.compareTo(b.order));
      }
    } catch (e) {
      if (_modulesCache != null) {
        final List<dynamic> modulesList = jsonDecode(_modulesCache!);
        final modules = modulesList.map((json) => Module.fromJson(json)).toList();
        return modules.where((m) => m.courseId == courseId).toList()
          ..sort((a, b) => a.order.compareTo(b.order));
      }
    }
    return [];
  }

  Future<List<Lesson>> getLessonsByModuleId(String moduleId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lessonsJson = prefs.getString(_lessonsKey);
      if (lessonsJson != null) {
        final List<dynamic> lessonsList = jsonDecode(lessonsJson);
        final lessons = lessonsList.map((json) => Lesson.fromJson(json)).toList();
        return lessons.where((l) => l.moduleId == moduleId).toList()
          ..sort((a, b) => a.order.compareTo(b.order));
      }
    } catch (e) {
      if (_lessonsCache != null) {
        final List<dynamic> lessonsList = jsonDecode(_lessonsCache!);
        final lessons = lessonsList.map((json) => Lesson.fromJson(json)).toList();
        return lessons.where((l) => l.moduleId == moduleId).toList()
          ..sort((a, b) => a.order.compareTo(b.order));
      }
    }
    return [];
  }

  Future<List<Lesson>> getLessonsByCourseId(String courseId) async {
    final modules = await getModulesByCourseId(courseId);
    final allLessons = <Lesson>[];
    
    for (final module in modules) {
      final lessons = await getLessonsByModuleId(module.id);
      allLessons.addAll(lessons);
    }
    
    return allLessons;
  }

  Future<Lesson?> getLessonById(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lessonsJson = prefs.getString(_lessonsKey);
      if (lessonsJson != null) {
        final List<dynamic> lessonsList = jsonDecode(lessonsJson);
        final lessons = lessonsList.map((json) => Lesson.fromJson(json)).toList();
        return lessons.firstWhere((l) => l.id == id);
      }
    } catch (e) {
      if (_lessonsCache != null) {
        final List<dynamic> lessonsList = jsonDecode(_lessonsCache!);
        final lessons = lessonsList.map((json) => Lesson.fromJson(json)).toList();
        return lessons.firstWhere((l) => l.id == id);
      }
    }
    return null;
  }

  Future<void> _initializeSampleData() async {
    final now = DateTime.now();
    
    final courses = [
      Course(
        id: '1',
        title: 'Flutter Complete Guide',
        description: 'Master Flutter development from basics to advanced concepts. Build beautiful, cross-platform mobile apps.',
        thumbnailUrl: 'https://picsum.photos/400/300?random=1',
        previewVideoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
        instructor: 'Sarah Johnson',
        instructorAvatar: 'https://i.pravatar.cc/150?img=1',
        level: CourseLevel.beginner,
        categories: ['Mobile Development', 'Flutter'],
        totalDurationMinutes: 480,
        price: 49.99,
        isFree: false,
        learningObjectives: [
          'Build cross-platform mobile apps',
          'Master Flutter widgets and state management',
          'Implement navigation and routing',
          'Work with APIs and databases',
        ],
        createdAt: now,
        updatedAt: now,
      ),
      Course(
        id: '2',
        title: 'Dart Programming Fundamentals',
        description: 'Learn Dart programming language from scratch. Perfect foundation for Flutter development.',
        thumbnailUrl: 'https://picsum.photos/400/300?random=2',
        instructor: 'Michael Chen',
        instructorAvatar: 'https://i.pravatar.cc/150?img=2',
        level: CourseLevel.beginner,
        categories: ['Programming', 'Dart'],
        totalDurationMinutes: 240,
        price: 29.99,
        isFree: true,
        learningObjectives: [
          'Understand Dart syntax and features',
          'Work with classes and objects',
          'Handle async programming',
          'Use Dart for real projects',
        ],
        createdAt: now,
        updatedAt: now,
      ),
      Course(
        id: '3',
        title: 'Advanced State Management',
        description: 'Deep dive into Flutter state management patterns including Provider, Riverpod, and Bloc.',
        thumbnailUrl: 'https://picsum.photos/400/300?random=3',
        instructor: 'Emily Rodriguez',
        instructorAvatar: 'https://i.pravatar.cc/150?img=3',
        level: CourseLevel.advanced,
        categories: ['Mobile Development', 'Flutter', 'Architecture'],
        totalDurationMinutes: 360,
        price: 79.99,
        promotionalPrice: 59.99,
        isFree: false,
        learningObjectives: [
          'Master Provider pattern',
          'Implement Riverpod',
          'Build with Bloc pattern',
          'Choose the right state solution',
        ],
        createdAt: now,
        updatedAt: now,
      ),
      Course(
        id: '4',
        title: 'Firebase for Flutter Apps',
        description: 'Integrate Firebase services into your Flutter apps. Authentication, Firestore, Storage, and more.',
        thumbnailUrl: 'https://picsum.photos/400/300?random=4',
        previewVideoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
        instructor: 'David Kumar',
        instructorAvatar: 'https://i.pravatar.cc/150?img=4',
        level: CourseLevel.intermediate,
        categories: ['Mobile Development', 'Backend', 'Firebase'],
        totalDurationMinutes: 420,
        price: 69.99,
        isFree: false,
        learningObjectives: [
          'Setup Firebase in Flutter',
          'Implement authentication',
          'Work with Firestore database',
          'Handle file uploads',
        ],
        createdAt: now,
        updatedAt: now,
      ),
      Course(
        id: '5',
        title: 'UI/UX Design for Mobile Apps',
        description: 'Create stunning mobile app interfaces. Learn design principles, Material Design, and user experience.',
        thumbnailUrl: 'https://picsum.photos/400/300?random=5',
        instructor: 'Lisa Anderson',
        instructorAvatar: 'https://i.pravatar.cc/150?img=5',
        level: CourseLevel.beginner,
        categories: ['Design', 'UI/UX'],
        totalDurationMinutes: 300,
        price: 39.99,
        isFree: false,
        learningObjectives: [
          'Understand design principles',
          'Master Material Design',
          'Create user-friendly interfaces',
          'Design for accessibility',
        ],
        createdAt: now,
        updatedAt: now,
      ),
    ];

    final modules = [
      // Flutter Complete Guide modules
      Module(
        id: '1',
        courseId: '1',
        title: 'Getting Started',
        description: 'Introduction to Flutter and setup',
        order: 1,
        createdAt: now,
        updatedAt: now,
      ),
      Module(
        id: '2',
        courseId: '1',
        title: 'Flutter Basics',
        description: 'Learn basic Flutter widgets and concepts',
        order: 2,
        createdAt: now,
        updatedAt: now,
      ),
      Module(
        id: '3',
        courseId: '1',
        title: 'State Management',
        description: 'Managing state in Flutter apps',
        order: 3,
        createdAt: now,
        updatedAt: now,
      ),
      // Dart Programming modules
      Module(
        id: '4',
        courseId: '2',
        title: 'Dart Basics',
        description: 'Variables, types, and control flow',
        order: 1,
        createdAt: now,
        updatedAt: now,
      ),
      Module(
        id: '5',
        courseId: '2',
        title: 'Object-Oriented Programming',
        description: 'Classes, inheritance, and polymorphism',
        order: 2,
        createdAt: now,
        updatedAt: now,
      ),
    ];

    final lessons = [
      // Module 1 lessons
      Lesson(
        id: '1',
        moduleId: '1',
        title: 'Welcome to Flutter',
        description: 'Introduction to the course and Flutter framework',
        videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
        durationSeconds: 480,
        order: 1,
        notes: 'Flutter is Google\'s UI toolkit for building beautiful apps.',
        createdAt: now,
        updatedAt: now,
      ),
      Lesson(
        id: '2',
        moduleId: '1',
        title: 'Setting up Flutter',
        description: 'Install Flutter SDK and setup development environment',
        videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
        durationSeconds: 720,
        order: 2,
        resources: [
          Resource(
            id: 'r1',
            title: 'Flutter Installation Guide',
            url: 'https://flutter.dev/docs/get-started/install',
            type: ResourceType.link,
          ),
        ],
        createdAt: now,
        updatedAt: now,
      ),
      Lesson(
        id: '3',
        moduleId: '1',
        title: 'Your First Flutter App',
        description: 'Create and run your first Flutter application',
        videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
        durationSeconds: 900,
        order: 3,
        createdAt: now,
        updatedAt: now,
      ),
      // Module 2 lessons
      Lesson(
        id: '4',
        moduleId: '2',
        title: 'Understanding Widgets',
        description: 'Learn about StatelessWidget and StatefulWidget',
        videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
        durationSeconds: 1080,
        order: 1,
        createdAt: now,
        updatedAt: now,
      ),
      Lesson(
        id: '5',
        moduleId: '2',
        title: 'Layout Widgets',
        description: 'Master Row, Column, Stack, and Container',
        videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
        durationSeconds: 960,
        order: 2,
        createdAt: now,
        updatedAt: now,
      ),
      // Module 4 lessons (Dart)
      Lesson(
        id: '6',
        moduleId: '4',
        title: 'Variables and Data Types',
        description: 'Learn about Dart variables, types, and constants',
        videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4',
        durationSeconds: 600,
        order: 1,
        createdAt: now,
        updatedAt: now,
      ),
    ];

    final coursesJson = jsonEncode(courses.map((c) => c.toJson()).toList());
    final modulesJson = jsonEncode(modules.map((m) => m.toJson()).toList());
    final lessonsJson = jsonEncode(lessons.map((l) => l.toJson()).toList());
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_coursesKey, coursesJson);
      await prefs.setString(_modulesKey, modulesJson);
      await prefs.setString(_lessonsKey, lessonsJson);
    } catch (e) {
      // Fallback to in-memory storage
      _coursesCache = coursesJson;
      _modulesCache = modulesJson;
      _lessonsCache = lessonsJson;
    }
  }
}
