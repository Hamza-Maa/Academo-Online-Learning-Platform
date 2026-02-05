import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'pages/home/home_page.dart';
import 'pages/auth/login_page.dart';
import 'pages/auth/signup_page.dart';
import 'pages/auth/forgot_password_page.dart';
import 'pages/course/course_details_page.dart';
import 'pages/video/video_player_page.dart';
import 'pages/my_courses/my_courses_page.dart';
import 'pages/favorites/favorites_page.dart';
import 'pages/browse/browse_page.dart';
import 'pages/settings/settings_page.dart';
import 'pages/purchase/purchase_page.dart';
import 'pages/purchase/purchase_success_page.dart';
import 'pages/purchase/purchase_failed_page.dart';
import 'pages/purchase/purchase_history_page.dart';
import 'pages/legal/terms_page.dart';
import 'pages/legal/privacy_page.dart';
import 'pages/profile/edit_profile_page.dart';
import 'pages/support/help_center_page.dart';
import 'pages/support/report_problem_page.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        pageBuilder: (context, state) => NoTransitionPage(
          child: const HomePage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        pageBuilder: (context, state) {
          final redirectRoute = state.uri.queryParameters['redirect'];
          return NoTransitionPage(
            child: LoginPage(redirectRoute: redirectRoute),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.signup,
        name: 'signup',
        pageBuilder: (context, state) => NoTransitionPage(
          child: const SignupPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: 'forgot-password',
        pageBuilder: (context, state) => NoTransitionPage(
          child: const ForgotPasswordPage(),
        ),
      ),
      GoRoute(
        path: '${AppRoutes.courseDetails}/:courseId',
        name: 'course-details',
        pageBuilder: (context, state) {
          final courseId = state.pathParameters['courseId']!;
          return NoTransitionPage(
            child: CourseDetailsPage(courseId: courseId),
          );
        },
      ),
      GoRoute(
        path: '/video/:courseId/:lessonId',
        name: 'video-player',
        pageBuilder: (context, state) {
          final courseId = state.pathParameters['courseId']!;
          final lessonId = state.pathParameters['lessonId']!;
          return NoTransitionPage(
            child: VideoPlayerPage(courseId: courseId, lessonId: lessonId),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.myCourses,
        name: 'my-courses',
        pageBuilder: (context, state) => NoTransitionPage(
          child: const MyCoursesPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.favorites,
        name: 'favorites',
        pageBuilder: (context, state) => NoTransitionPage(
          child: const FavoritesPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.browse,
        name: 'browse',
        pageBuilder: (context, state) {
          final category = state.uri.queryParameters['category'];
          return NoTransitionPage(
            child: BrowsePage(category: category),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        pageBuilder: (context, state) => NoTransitionPage(
          child: const SettingsPage(),
        ),
      ),
      GoRoute(
        path: '${AppRoutes.purchase}/:courseId',
        name: 'purchase',
        pageBuilder: (context, state) {
          final courseId = state.pathParameters['courseId']!;
          return NoTransitionPage(
            child: PurchasePage(courseId: courseId),
          );
        },
      ),
      GoRoute(
        path: '${AppRoutes.purchaseSuccess}/:purchaseId',
        name: 'purchase-success',
        pageBuilder: (context, state) {
          final purchaseId = state.pathParameters['purchaseId']!;
          return NoTransitionPage(
            child: PurchaseSuccessPage(purchaseId: purchaseId),
          );
        },
      ),
      GoRoute(
        path: '${AppRoutes.purchaseFailed}/:purchaseId',
        name: 'purchase-failed',
        pageBuilder: (context, state) {
          final purchaseId = state.pathParameters['purchaseId']!;
          return NoTransitionPage(
            child: PurchaseFailedPage(purchaseId: purchaseId),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.purchaseHistory,
        name: 'purchase-history',
        pageBuilder: (context, state) => NoTransitionPage(
          child: const PurchaseHistoryPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.terms,
        name: 'terms',
        pageBuilder: (context, state) => NoTransitionPage(
          child: const TermsPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.privacy,
        name: 'privacy',
        pageBuilder: (context, state) => NoTransitionPage(
          child: const PrivacyPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.editProfile,
        name: 'edit-profile',
        pageBuilder: (context, state) => NoTransitionPage(
          child: const EditProfilePage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.helpCenter,
        name: 'help-center',
        pageBuilder: (context, state) => NoTransitionPage(
          child: const HelpCenterPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.reportProblem,
        name: 'report-problem',
        pageBuilder: (context, state) => NoTransitionPage(
          child: const ReportProblemPage(),
        ),
      ),
    ],
  );
}

class AppRoutes {
  static const String home = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String courseDetails = '/course';
  static const String myCourses = '/my-courses';
  static const String favorites = '/favorites';
  static const String browse = '/browse';
  static const String settings = '/settings';
  static const String purchase = '/purchase';
  static const String purchaseSuccess = '/purchase-success';
  static const String purchaseFailed = '/purchase-failed';
  static const String purchaseHistory = '/purchase-history';
  static const String terms = '/terms';
  static const String privacy = '/privacy';
  static const String editProfile = '/edit-profile';
  static const String helpCenter = '/help-center';
  static const String reportProblem = '/report-problem';
}
