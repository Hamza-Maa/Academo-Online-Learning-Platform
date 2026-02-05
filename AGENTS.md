# AGENTS.md - AI Agent Development Guide

## Project Overview

**academo** is a Flutter starter project built with Material 3 design system, modern navigation patterns, and a comprehensive theming infrastructure. The project serves as a foundation for building cross-platform mobile and web applications with consistent design patterns and best practices.

**Key Technologies:**
- Flutter 3.32.2+ (Material 3)
- go_router (declarative routing)
- Google Fonts (Inter family)
- Provider (state management, ready to use)

---

## Architecture & Patterns

### 1. Navigation Architecture

**Router:** `go_router` (v16.2.0)
- **Configuration:** `lib/nav.dart`
- **Pattern:** Declarative routing with named routes
- **Route constants:** Defined in `AppRoutes` class

**Navigation Rules:**
- ✅ Use `context.go('/path')` for stack replacement
- ✅ Use `context.push('/path')` for stack navigation
- ✅ Use `context.pop()` to go back
- ❌ NEVER use `Navigator.push()` or `Navigator.pop()`

**Adding New Routes:**
1. Add route constant to `AppRoutes` class
2. Add `GoRoute` to `AppRouter.router` routes list
3. Use `NoTransitionPage` for instant transitions or customize as needed

### 2. State Management

**Provider:** Ready to use but not yet implemented
- Located in `lib/main.dart` (see commented example)
- Use `MultiProvider` to wrap `MaterialApp.router`
- Create ChangeNotifier classes for state

### 3. Theme System

**Centralized Theming:** `lib/theme.dart`

**Color Management:**
- All colors defined in `LightModeColors` and `DarkModeColors` classes
- ✅ Always reference theme colors via `Theme.of(context).colorScheme`
- ❌ Never hardcode color values in widgets
- Automatic light/dark mode switching based on system preference

**Typography:**
- Font family: **Inter** (via Google Fonts)
- Access via: `Theme.of(context).textTheme` or `context.textStyles`
- Font sizes defined in `FontSizes` class
- Text style extensions available: `.bold`, `.semiBold`, `.medium`, `.withColor()`, `.withSize()`

**Spacing System:**
- Constants: `AppSpacing.xs` (4), `.sm` (8), `.md` (16), `.lg` (24), `.xl` (32), `.xxl` (48)
- Edge insets: `AppSpacing.paddingMd`, `.horizontalLg`, `.verticalSm`, etc.
- ✅ Always use AppSpacing constants for consistent spacing
- ❌ Avoid hardcoded padding/margin values

**Border Radius:**
- Constants: `AppRadius.sm` (8), `.md` (12), `.lg` (16), `.xl` (24)
- Use for consistent rounded corners across the app

### 4. Widget Organization

**Current Structure:**
- Entry point: `lib/main.dart` (contains `MyApp` and `MyHomePage`)
- Single-file widgets acceptable for starter phase

**Scaling Guidelines:**
- Create reusable widgets as **public classes** (not functions or private classes)
- Split large widget trees into smaller, composable widgets
- Organize by feature when adding new pages:
  ```
  lib/
    pages/
      home/
        home_page.dart
        home_widgets.dart
      profile/
        profile_page.dart
        profile_widgets.dart
    widgets/
      shared/
        custom_button.dart
        custom_card.dart
  ```

---

## Code Style & Conventions

### Naming Conventions

**Files:**
- Use `snake_case` for all file names
- Example: `home_page.dart`, `user_profile_widget.dart`

**Classes:**
- Use `PascalCase` for class names
- Suffix widgets with purpose: `HomePage`, `ProfileCard`, `UserListItem`
- Service classes: `AuthService`, `DatabaseService`
- Data models: `User`, `Product`, `Order`

**Variables & Functions:**
- Use `camelCase` for variables and function names
- Private members: prefix with underscore `_counter`, `_incrementCounter`
- Constants: use `lowerCamelCase` for `const` or `final`, `UPPER_SNAKE_CASE` for compile-time constants in classes

**Route Constants:**
- Defined in `AppRoutes` class with descriptive names
- Example: `AppRoutes.home`, `AppRoutes.profile`

### Code Organization

**Imports:**
- Flutter SDK imports first
- Third-party package imports second
- Relative project imports last
- Example:
  ```dart
  import 'package:flutter/material.dart';
  import 'package:go_router/go_router.dart';
  import 'package:google_fonts/google_fonts.dart';
  
  import '../theme.dart';
  import '../widgets/custom_button.dart';
  ```

**Widget Structure:**
1. Constructor (with key parameter)
2. Fields
3. State initialization methods (if StatefulWidget)
4. Lifecycle methods
5. Build method
6. Helper methods (private)
7. Event handlers

### Flutter Best Practices

**Expression Bodies:**
- Use `=>` for one-liner getters and simple functions
- Example: `String get fullName => '$firstName $lastName';`

**Const Constructors:**
- Always use `const` for immutable widgets when possible
- Example: `const Text('Hello')`, `const SizedBox(height: 16)`

**Widget Reusability:**
- Extract repeated UI patterns into reusable widget classes
- Pass data via constructor parameters
- Make widgets configurable with optional parameters

**Avoid Overflow:**
- Wrap dynamic content in `Expanded`/`Flexible` inside `Row`/`Column`
- Use `SingleChildScrollView` for scrollable content
- Set `softWrap: true` and `overflow: TextOverflow.ellipsis` for text

---

## Common Implementation Patterns

### 1. Creating a New Page

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Padding(
        padding: AppSpacing.paddingMd,
        child: Column(
          children: [
            Text(
              'User Profile',
              style: context.textStyles.headlineMedium,
            ),
          ],
        ),
      ),
    );
  }
}
```

**Register Route:**
```dart
// In lib/nav.dart
GoRoute(
  path: AppRoutes.profile,
  name: 'profile',
  pageBuilder: (context, state) => NoTransitionPage(
    child: const ProfilePage(),
  ),
),

// Add to AppRoutes class
static const String profile = '/profile';
```

### 2. Using Theme Colors

```dart
Container(
  decoration: BoxDecoration(
    color: Theme.of(context).colorScheme.primaryContainer,
    borderRadius: BorderRadius.circular(AppRadius.md),
  ),
  child: Text(
    'Themed Container',
    style: Theme.of(context).textTheme.bodyLarge?.withColor(
      Theme.of(context).colorScheme.onPrimaryContainer,
    ),
  ),
)
```

### 3. Creating Custom Widgets

```dart
class CustomCard extends StatelessWidget {
  const CustomCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: AppSpacing.paddingMd,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: context.textStyles.titleMedium?.bold,
              ),
              SizedBox(height: AppSpacing.sm),
              Text(
                subtitle,
                style: context.textStyles.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### 4. Adding State Management

```dart
// 1. Create a provider
class CounterProvider extends ChangeNotifier {
  int _count = 0;
  int get count => _count;

  void increment() {
    _count++;
    notifyListeners();
  }
}

// 2. Register in main.dart
return MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => CounterProvider()),
  ],
  child: MaterialApp.router(
    // ... existing config
  ),
);

// 3. Use in widgets
final counter = context.watch<CounterProvider>();
Text('Count: ${counter.count}');

// Or for mutations only:
final counter = context.read<CounterProvider>();
counter.increment();
```

---

## Project-Specific Rules

### Design System Constraints

1. **AppBar Styling:**
   - Background: `Colors.transparent`
   - Elevation: `0` (flat design)
   - Access theme color: `AppBarTheme.of(context).backgroundColor`

2. **Card Styling:**
   - Elevation: `0`
   - Border: 1px outline with opacity
   - Border radius: 12px (AppRadius.md)

3. **Color Usage:**
   - Buttons should NOT have same color as icons
   - Use contrasting colors for better visual hierarchy
   - Follow Material 3 color roles (primary, secondary, tertiary)

### Platform Considerations

- **Web Support:** This project runs in Dreamflow's web-based IDE
- **Cross-Platform:** Design for both mobile and web from the start
- **Responsive Design:** Consider different screen sizes

### Dependencies

**Core Dependencies:**
- `go_router: ^16.2.0` - Routing
- `google_fonts: ^6.1.0` - Typography
- `provider: ^6.1.2` - State management

**When Adding Packages:**
- Prefer Flutter/Dart built-in solutions first
- Use well-maintained, popular packages
- Check web compatibility for Dreamflow preview
- Run `df pub add <package>` to install

### Error Handling

**Compile Errors:**
- Use `df analyze` to check for errors
- Fix all compile errors before completing tasks
- Never leave codebase in broken state

**Runtime Errors:**
- Use `df logs` to view console output
- Add `debugPrint()` statements for debugging
- Test in Dreamflow preview after changes

### String Handling

- Use `${variable}` for string interpolation
- Escape dollar signs: `"Price: \$9.99"`
- Escape quotes: `"She said \"hello\""`
- Use triple quotes for multiline strings
- UTF-8 characters directly in source: `'مرحبا'`, `'你好'`

---

## Development Workflow

### Before Making Changes

1. **Understand Intent:** Clarify requirements if ambiguous
2. **Check Existing Code:** Read relevant files before modifying
3. **Check Components:** Use tools to see if reusable widgets exist

### Making Changes

1. **Targeted Edits:** Only modify what's necessary
2. **Follow Conventions:** Match existing code style
3. **Use Theme System:** Reference theme colors and spacing
4. **Test Changes:** Verify in Dreamflow preview

### After Changes

1. **Verify Compilation:** Run `df analyze`
2. **Check Preview:** Ensure app runs without errors
3. **Hot Restart:** Use `df restart` if changes don't appear
4. **Documentation:** Update comments for significant changes

---

## Quick Reference

### Navigation
```dart
context.go('/profile');           // Replace stack
context.push('/settings');        // Push to stack
context.pop();                    // Go back
```

### Theme Access
```dart
Theme.of(context).colorScheme.primary
Theme.of(context).textTheme.headlineMedium
context.textStyles.bodyLarge.bold
AppSpacing.paddingMd
AppRadius.lg
```

### Common Widgets
```dart
Scaffold with AppBar
Column/Row with Expanded
Card with InkWell
SingleChildScrollView
SizedBox for spacing
Padding with AppSpacing
```

### Tools
```dart
df analyze          // Check for errors
df logs             // View runtime logs
df restart          // Hot restart preview
df pub add <pkg>    // Add package
df doc <query>      // Search documentation
```

---

## Getting Started Checklist

When working on this project:
- [ ] Understand the feature request completely
- [ ] Check `lib/nav.dart` for existing routes
- [ ] Review `lib/theme.dart` for available colors and spacing
- [ ] Use `AppSpacing` and `AppRadius` constants
- [ ] Follow go_router navigation patterns
- [ ] Reference theme colors (never hardcode)
- [ ] Create public widget classes (not functions)
- [ ] Test in Dreamflow preview
- [ ] Run `df analyze` before completion

---

**Last Updated:** Generated from codebase analysis
**Project Version:** 1.0.0+1
**Flutter Version:** 3.32.2+
