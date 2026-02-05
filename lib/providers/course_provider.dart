import 'package:flutter/foundation.dart';
import '../models/course.dart';
import '../models/module.dart';
import '../models/lesson.dart';
import '../services/course_service.dart';

class CourseProvider extends ChangeNotifier {
  final CourseService _courseService = CourseService();
  
  List<Course> _courses = [];
  List<Course> get courses => _courses;
  
  List<String> _categories = [];
  List<String> get categories => _categories;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _courseService.initialize();
      await loadCourses();
      await loadCategories();
    } catch (e) {
      debugPrint('Error initializing CourseProvider: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCourses() async {
    _courses = await _courseService.getAllCourses();
    notifyListeners();
  }

  Future<void> loadCategories() async {
    _categories = await _courseService.getAllCategories();
    notifyListeners();
  }

  Future<Course?> getCourseById(String id) async {
    return await _courseService.getCourseById(id);
  }

  Future<List<Course>> getFeaturedCourses() async {
    return await _courseService.getFeaturedCourses();
  }

  Future<List<Course>> searchCourses(String query) async {
    return await _courseService.searchCourses(query);
  }

  Future<List<Course>> filterCourses({
    List<String>? categories,
    CourseLevel? level,
    bool? isFree,
    double? maxPrice,
  }) async {
    return await _courseService.filterCourses(
      categories: categories,
      level: level,
      isFree: isFree,
      maxPrice: maxPrice,
    );
  }

  Future<List<Module>> getModulesByCourseId(String courseId) async {
    return await _courseService.getModulesByCourseId(courseId);
  }

  Future<List<Lesson>> getLessonsByModuleId(String moduleId) async {
    return await _courseService.getLessonsByModuleId(moduleId);
  }

  Future<List<Lesson>> getLessonsByCourseId(String courseId) async {
    return await _courseService.getLessonsByCourseId(courseId);
  }

  Future<Lesson?> getLessonById(String id) async {
    return await _courseService.getLessonById(id);
  }

  Future<List<Course>> getAllCourses() async {
    return await _courseService.getAllCourses();
  }
}
