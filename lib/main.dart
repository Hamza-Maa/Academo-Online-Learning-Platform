import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme.dart';
import 'nav.dart';
import 'providers/auth_provider.dart';
import 'providers/course_provider.dart';
import 'providers/progress_provider.dart';

/// Main entry point for the application
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize SharedPreferences early to ensure web plugin is loaded
  try {
    debugPrint('🚀 Main: Initializing SharedPreferences...');
    await SharedPreferences.getInstance();
    debugPrint('✅ Main: SharedPreferences initialized successfully');
  } catch (e) {
    debugPrint('❌ Main: SharedPreferences initialization failed: $e');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => CourseProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => ProgressProvider()),
      ],
      child: MaterialApp.router(
        title: 'LearnHub',
        debugShowCheckedModeBanner: false,
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
