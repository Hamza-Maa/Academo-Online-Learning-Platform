import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/progress.dart';

class ProgressService {
  static const _progressKey = 'progress';

  Future<Progress?> getCourseProgress(String userId, String courseId) async {
    final allProgress = await _getAllProgress();
    try {
      return allProgress.firstWhere(
        (p) => p.userId == userId && p.courseId == courseId,
      );
    } catch (e) {
      return null;
    }
  }

  Future<List<Progress>> getUserProgress(String userId) async {
    final allProgress = await _getAllProgress();
    return allProgress.where((p) => p.userId == userId).toList();
  }

  Future<void> updateLessonProgress({
    required String userId,
    required String courseId,
    required String lessonId,
    required int watchedSeconds,
    bool? isCompleted,
  }) async {
    final progress = await getCourseProgress(userId, courseId);
    final now = DateTime.now();

    final lessonProgress = LessonProgress(
      lessonId: lessonId,
      watchedSeconds: watchedSeconds,
      isCompleted: isCompleted ?? false,
      lastWatchedAt: now,
    );

    final updatedProgress = progress?.copyWith(
          lessonProgress: {
            ...progress.lessonProgress,
            lessonId: lessonProgress,
          },
          updatedAt: now,
        ) ??
        Progress(
          id: '${userId}_$courseId',
          userId: userId,
          courseId: courseId,
          lessonProgress: {lessonId: lessonProgress},
          createdAt: now,
          updatedAt: now,
        );

    await _saveProgress(updatedProgress);
  }

  Future<void> markLessonComplete({
    required String userId,
    required String courseId,
    required String lessonId,
  }) async {
    final progress = await getCourseProgress(userId, courseId);
    final now = DateTime.now();

    final existingLesson = progress?.lessonProgress[lessonId];
    final lessonProgress = LessonProgress(
      lessonId: lessonId,
      watchedSeconds: existingLesson?.watchedSeconds ?? 0,
      isCompleted: true,
      lastWatchedAt: now,
    );

    final updatedProgress = progress?.copyWith(
          lessonProgress: {
            ...progress.lessonProgress,
            lessonId: lessonProgress,
          },
          updatedAt: now,
        ) ??
        Progress(
          id: '${userId}_$courseId',
          userId: userId,
          courseId: courseId,
          lessonProgress: {lessonId: lessonProgress},
          createdAt: now,
          updatedAt: now,
        );

    await _saveProgress(updatedProgress);
  }

  Future<LessonProgress?> getLessonProgress({
    required String userId,
    required String courseId,
    required String lessonId,
  }) async {
    final progress = await getCourseProgress(userId, courseId);
    return progress?.lessonProgress[lessonId];
  }

  Future<List<Progress>> _getAllProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final progressJson = prefs.getString(_progressKey);
    if (progressJson == null) return [];

    try {
      final List<dynamic> progressList = jsonDecode(progressJson);
      return progressList.map((json) => Progress.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> _saveProgress(Progress progress) async {
    final allProgress = await _getAllProgress();
    
    final index = allProgress.indexWhere(
      (p) => p.userId == progress.userId && p.courseId == progress.courseId,
    );

    if (index != -1) {
      allProgress[index] = progress;
    } else {
      allProgress.add(progress);
    }

    final prefs = await SharedPreferences.getInstance();
    final progressJson = jsonEncode(allProgress.map((p) => p.toJson()).toList());
    await prefs.setString(_progressKey, progressJson);
  }
}
