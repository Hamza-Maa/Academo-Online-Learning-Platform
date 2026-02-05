import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/lesson.dart';
import '../../models/course.dart';
import '../../providers/auth_provider.dart';
import '../../providers/course_provider.dart';
import '../../providers/progress_provider.dart';
import '../../theme.dart';

class VideoPlayerPage extends StatefulWidget {
  final String courseId;
  final String lessonId;

  const VideoPlayerPage({
    super.key,
    required this.courseId,
    required this.lessonId,
  });

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  VideoPlayerController? _controller;
  Lesson? _lesson;
  Course? _course;
  List<Lesson> _allLessons = [];
  bool _isLoading = true;
  bool _showControls = true;
  double _playbackSpeed = 1.0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final courseProvider = context.read<CourseProvider>();
    final authProvider = context.read<AuthProvider>();
    
    final lesson = await courseProvider.getLessonById(widget.lessonId);
    final course = await courseProvider.getCourseById(widget.courseId);
    final allLessons = await courseProvider.getLessonsByCourseId(widget.courseId);

    if (lesson == null || course == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lesson not found')),
        );
        context.pop();
      }
      return;
    }

    setState(() {
      _lesson = lesson;
      _course = course;
      _allLessons = allLessons;
    });

    // Load saved progress
    if (authProvider.isAuthenticated) {
      final progressProvider = context.read<ProgressProvider>();
      final lessonProgress = await progressProvider.getLessonProgress(
        userId: authProvider.currentUser!.id,
        courseId: widget.courseId,
        lessonId: widget.lessonId,
      );

      _initializeVideoPlayer(
        lesson.videoUrl,
        startPosition: lessonProgress?.watchedSeconds ?? 0,
      );
    } else {
      _initializeVideoPlayer(lesson.videoUrl);
    }
  }

  Future<void> _initializeVideoPlayer(String url, {int startPosition = 0}) async {
    _controller = VideoPlayerController.networkUrl(Uri.parse(url));
    
    try {
      await _controller!.initialize();
      if (startPosition > 0) {
        await _controller!.seekTo(Duration(seconds: startPosition));
      }
      _controller!.play();
      
      _controller!.addListener(_videoListener);
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading video: $e')),
        );
      }
    }
  }

  void _videoListener() {
    if (_controller == null || !mounted) return;

    // Save progress every 5 seconds
    final position = _controller!.value.position.inSeconds;
    if (position % 5 == 0) {
      _saveProgress();
    }

    // Auto-play next lesson when current finishes
    if (_controller!.value.position >= _controller!.value.duration &&
        !_controller!.value.isPlaying) {
      _playNextLesson();
    }
  }

  Future<void> _saveProgress() async {
    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isAuthenticated || _controller == null) return;

    final progressProvider = context.read<ProgressProvider>();
    final watchedSeconds = _controller!.value.position.inSeconds;
    final totalSeconds = _controller!.value.duration.inSeconds;
    final isCompleted = watchedSeconds >= (totalSeconds * 0.9);

    await progressProvider.updateLessonProgress(
      userId: authProvider.currentUser!.id,
      courseId: widget.courseId,
      lessonId: widget.lessonId,
      watchedSeconds: watchedSeconds,
      isCompleted: isCompleted,
    );
  }

  void _playNextLesson() {
    final currentIndex = _allLessons.indexWhere((l) => l.id == widget.lessonId);
    if (currentIndex != -1 && currentIndex < _allLessons.length - 1) {
      final nextLesson = _allLessons[currentIndex + 1];
      context.go('/video/${widget.courseId}/${nextLesson.id}');
    }
  }

  void _toggleFullScreen() {
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    }
  }

  void _changePlaybackSpeed() {
    final speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0];
    final currentIndex = speeds.indexOf(_playbackSpeed);
    final nextSpeed = speeds[(currentIndex + 1) % speeds.length];
    
    setState(() {
      _playbackSpeed = nextSpeed;
    });
    _controller?.setPlaybackSpeed(nextSpeed);
  }

  Future<void> _markAsComplete() async {
    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isAuthenticated) return;

    final progressProvider = context.read<ProgressProvider>();
    await progressProvider.markLessonComplete(
      userId: authProvider.currentUser!.id,
      courseId: widget.courseId,
      lessonId: widget.lessonId,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lesson marked as complete')),
      );
    }
  }

  @override
  void dispose() {
    _saveProgress();
    _controller?.removeListener(_videoListener);
    _controller?.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _lesson == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: MediaQuery.of(context).orientation == Orientation.portrait
          ? AppBar(
              title: Text(_course?.title ?? 'Video Player'),
            )
          : null,
      body: MediaQuery.of(context).orientation == Orientation.landscape
          ? _buildVideoPlayer()
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildVideoPlayer(),
                  Padding(
                    padding: AppSpacing.paddingMd,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _lesson!.title,
                          style: context.textStyles.headlineSmall?.bold,
                        ),
                        if (_lesson!.description != null) ...[
                          SizedBox(height: AppSpacing.sm),
                          Text(
                            _lesson!.description!,
                            style: context.textStyles.bodyMedium,
                          ),
                        ],
                        SizedBox(height: AppSpacing.md),
                        FilledButton.icon(
                          onPressed: _markAsComplete,
                          icon: const Icon(Icons.check_circle),
                          label: const Text('Mark as Complete'),
                        ),
                        if (_lesson!.resources.isNotEmpty) ...[
                          SizedBox(height: AppSpacing.lg),
                          Text(
                            'Resources',
                            style: context.textStyles.titleLarge?.bold,
                          ),
                          SizedBox(height: AppSpacing.sm),
                          ..._lesson!.resources.map((resource) => Card(
                                child: ListTile(
                                  leading: Icon(_getResourceIcon(resource.type)),
                                  title: Text(resource.title),
                                  trailing: const Icon(Icons.download),
                                  onTap: () => _openResource(resource.url),
                                ),
                              )),
                        ],
                        if (_lesson!.notes != null) ...[
                          SizedBox(height: AppSpacing.lg),
                          Text(
                            'Lesson Notes',
                            style: context.textStyles.titleLarge?.bold,
                          ),
                          SizedBox(height: AppSpacing.sm),
                          Card(
                            child: Padding(
                              padding: AppSpacing.paddingMd,
                              child: Text(
                                _lesson!.notes!,
                                style: context.textStyles.bodyMedium,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildVideoPlayer() {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const AspectRatio(
        aspectRatio: 16 / 9,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _showControls = !_showControls;
        });
      },
      child: AspectRatio(
        aspectRatio: _controller!.value.aspectRatio,
        child: Stack(
          alignment: Alignment.center,
          children: [
            VideoPlayer(_controller!),
            if (_showControls)
              Container(
                color: Colors.black.withValues(alpha: 0.5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.replay_10, color: Colors.white),
                          onPressed: () {
                            final currentPosition = _controller!.value.position;
                            _controller!.seekTo(currentPosition - const Duration(seconds: 10));
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                            size: 48,
                          ),
                          onPressed: () {
                            setState(() {
                              _controller!.value.isPlaying
                                  ? _controller!.pause()
                                  : _controller!.play();
                            });
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.forward_10, color: Colors.white),
                          onPressed: () {
                            final currentPosition = _controller!.value.position;
                            _controller!.seekTo(currentPosition + const Duration(seconds: 10));
                          },
                        ),
                      ],
                    ),
                    const Spacer(),
                    Padding(
                      padding: AppSpacing.paddingMd,
                      child: Column(
                        children: [
                          VideoProgressIndicator(
                            _controller!,
                            allowScrubbing: true,
                            colors: VideoProgressColors(
                              playedColor: Theme.of(context).colorScheme.primary,
                              bufferedColor: Colors.grey,
                              backgroundColor: Colors.white.withValues(alpha: 0.3),
                            ),
                          ),
                          SizedBox(height: AppSpacing.sm),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDuration(_controller!.value.position),
                                style: const TextStyle(color: Colors.white),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: Text(
                                      '${_playbackSpeed}x',
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                    onPressed: _changePlaybackSpeed,
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.fullscreen, color: Colors.white),
                                    onPressed: _toggleFullScreen,
                                  ),
                                ],
                              ),
                              Text(
                                _formatDuration(_controller!.value.duration),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  IconData _getResourceIcon(ResourceType type) {
    switch (type) {
      case ResourceType.pdf:
        return Icons.picture_as_pdf;
      case ResourceType.link:
        return Icons.link;
      case ResourceType.document:
        return Icons.description;
    }
  }

  Future<void> _openResource(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open resource')),
        );
      }
    }
  }
}
