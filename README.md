# Academo - Online Learning Platform

A modern, cross-platform educational app built with Flutter that provides an intuitive learning experience with course management, video lessons, progress tracking, and seamless purchases.

## 📱 Features

### Core Features
- **Course Catalog** - Browse and discover courses across various categories
- **Video Learning** - High-quality video lessons with custom player
- **Progress Tracking** - Track your learning journey with detailed progress metrics
- **Favorites** - Save courses for later access
- **Purchases** - Seamless course purchase flow with history tracking

### User Management
- **Authentication** - Sign up, login, and password recovery
- **Profile Management** - Edit user profile and preferences
- **Settings** - Customize app experience

### Support & Legal
- **Help Center** - Get answers to common questions
- **Report Issues** - Submit problems directly through the app
- **Legal Pages** - Terms of service and privacy policy

## 🎨 Design System

- **Design Language**: Material 3
- **Typography**: Inter font family (Google Fonts)
- **Theme**: Automatic light/dark mode support
- **Navigation**: Bottom navigation with smooth transitions
- **Responsive**: Optimized for mobile and web platforms

## 🛠️ Technologies

- **Flutter**: 3.32.2+
- **Navigation**: go_router (v16.2.0) - Declarative routing
- **State Management**: Provider pattern
- **Fonts**: Google Fonts (Inter family)
- **Architecture**: Clean architecture with services and providers

## 📁 Project Structure

```
lib/
├── main.dart                 # App entry point
├── nav.dart                  # Routing configuration
├── theme.dart                # Theme and styling constants
├── models/                   # Data models
│   ├── user.dart
│   ├── course.dart
│   ├── module.dart
│   ├── lesson.dart
│   ├── progress.dart
│   └── purchase.dart
├── services/                 # Business logic services
│   ├── auth_service.dart
│   ├── course_service.dart
│   ├── progress_service.dart
│   └── purchase_service.dart
├── providers/                # State management providers
│   ├── auth_provider.dart
│   ├── course_provider.dart
│   └── progress_provider.dart
├── pages/                    # App screens
│   ├── auth/                 # Authentication screens
│   ├── home/                 # Home screen
│   ├── browse/               # Course browsing
│   ├── course/               # Course details
│   ├── video/                # Video player
│   ├── my_courses/           # User's courses
│   ├── favorites/            # Saved courses
│   ├── purchase/             # Purchase flow
│   ├── profile/              # User profile
│   ├── settings/             # App settings
│   ├── support/              # Help and support
│   └── legal/                # Legal documents
├── widgets/                  # Reusable widgets
│   ├── custom_app_bar.dart
│   ├── custom_bottom_nav.dart
│   ├── course_card.dart
│   └── carousel_course_card.dart
└── utils/                    # Utility functions
    └── auth_utils.dart
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.32.2 or higher)
- Dart SDK
- IDE (VS Code, Android Studio, or Dreamflow)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Hamza-Maa/Academo---Online-Learning-Platform.git
   cd academo
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Platform-Specific Setup

#### Android
No additional setup required. The app is ready to run on Android devices and emulators.

#### iOS
Ensure you have Xcode installed and configured:
```bash
cd ios
pod install
cd ..
flutter run
```

#### Web
```bash
flutter run -d chrome
```

## 🏗️ Architecture

### Navigation
- Uses **go_router** for declarative routing
- All routes defined in `lib/nav.dart`
- Navigation via `context.go()`, `context.push()`, and `context.pop()`

### State Management
- **Provider** pattern for global state
- Providers handle auth, courses, and progress
- Services contain business logic

### Data Layer
- Local storage with SharedPreferences
- Sample data available for development
- Ready for backend integration (Firebase/Supabase)

## 📝 Configuration

### Theme Customization
Edit `lib/theme.dart` to customize:
- Color schemes (light/dark mode)
- Typography (font sizes, weights)
- Spacing constants
- Border radius values

### Adding Routes
1. Add route constant to `AppRoutes` class in `lib/nav.dart`
2. Add `GoRoute` to the routes list
3. Use the route in navigation: `context.go(AppRoutes.yourRoute)`

## 🎯 Usage

### User Flow
1. **Home Screen** - View featured and recommended courses
2. **Browse** - Explore courses by category
3. **Course Details** - See curriculum, reviews, and pricing
4. **Purchase** - Complete course purchase
5. **My Courses** - Access purchased courses
6. **Video Player** - Watch lessons with progress tracking
7. **Profile** - Manage account and settings

### Development Tips
- Use `const` constructors for better performance
- Reference theme colors via `Theme.of(context).colorScheme`
- Use `AppSpacing` constants for consistent spacing
- Extract reusable UI patterns into widget classes

## 🧪 Testing

```bash
# Run unit tests
flutter test

# Run with coverage
flutter test --coverage
```

## 🔒 Backend Integration

The app is currently using local storage with sample data. To integrate a backend:

1. **Firebase** - Open Firebase panel in Dreamflow and complete setup
2. **Supabase** - Open Supabase panel in Dreamflow and configure

Services are designed to easily switch from local to cloud storage.

## 🤝 Contributing

Contributions are welcome! Please follow these guidelines:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code Style
- Follow the conventions in `AGENTS.md`
- Use meaningful variable and function names
- Add comments for complex logic
- Keep widgets focused and reusable

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👥 Authors

Built with ❤️ using Flutter

## 📧 Support

- **Help Center**: In-app help section
- **Issues**: Submit via the app's "Report a Problem" feature
- **Email**: hamza.maatougui@outlook.com

## 🙏 Acknowledgments

- Material Design 3 guidelines
- Flutter community
- Google Fonts for the Inter font family
- All contributors and users

---

**Happy Learning! 📚✨**
