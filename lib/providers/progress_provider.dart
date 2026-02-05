import 'package:flutter/foundation.dart';
import '../models/progress.dart';
import '../services/progress_service.dart';

class ProgressProvider extends ChangeNotifier {
  final ProgressService _progressService = ProgressService();
  
  Map<String, Progress> _progressCache = {};

  Future<Progress?> getCourseProgress(String userId, String courseId) async {
    final key = '${userId}_$courseId';
    if (_progressCache.containsKey(key)) {
      return _progressCache[key];
    }
    
    final progress = await _progressService.getCourseProgress(userId, courseId);
    if (progress != null) {
      _progressCache[key] = progress;
    }
    return progress;
  }

  Future<List<Progress>> getUserProgress(String userId) async {
    return await _progressService.getUserProgress(userId);
  }

  Future<void> updateLessonProgress({
    required String userId,
    required String courseId,
    required String lessonId,
    required int watchedSeconds,
    bool? isCompleted,
  }) async {
    await _progressService.updateLessonProgress(
      userId: userId,
      courseId: courseId,
      lessonId: lessonId,
      watchedSeconds: watchedSeconds,
      isCompleted: isCompleted,
    );
    
    // Refresh cache
    final key = '${userId}_$courseId';
    _progressCache.remove(key);
    await getCourseProgress(userId, courseId);
    
    notifyListeners();
  }

  Future<void> markLessonComplete({
    required String userId,
    required String courseId,
    required String lessonId,
  }) async {
    await _progressService.markLessonComplete(
      userId: userId,
      courseId: courseId,
      lessonId: lessonId,
    );
    
    // Refresh cache
    final key = '${userId}_$courseId';
    _progressCache.remove(key);
    await getCourseProgress(userId, courseId);
    
    notifyListeners();
  }

  Future<LessonProgress?> getLessonProgress({
    required String userId,
    required String courseId,
    required String lessonId,
  }) async {
    return await _progressService.getLessonProgress(
      userId: userId,
      courseId: courseId,
      lessonId: lessonId,
    );
  }

  double getCourseProgressPercentage(String userId, String courseId, int totalLessons) {
    final key = '${userId}_$courseId';
    final progress = _progressCache[key];
    return progress?.calculatePercentage(totalLessons) ?? 0;
  }

  void clearCache() {
    _progressCache.clear();
    notifyListeners();
  }
}
