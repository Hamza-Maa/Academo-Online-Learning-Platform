import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme.dart';

class LoginPage extends StatefulWidget {
  final String? redirectRoute;
  
  const LoginPage({super.key, this.redirectRoute});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      rememberMe: _rememberMe,
    );

    if (mounted) {
      if (success) {
        // Redirect to intended route or home
        final redirectTo = widget.redirectRoute ?? '/';
        context.go(redirectTo);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error ?? 'Login failed'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      body: Stack(
        children: [
          // Gradient Background Header
          Container(
            height: MediaQuery.of(context).size.height * 0.4,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                ],
              ),
            ),
          ),
          
          // Main Content
          SafeArea(
            child: Column(
              children: [
                // Top Navigation Bar
                Padding(
                  padding: AppSpacing.paddingMd,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => context.go('/'),
                        icon: const Icon(Icons.home_outlined, color: Colors.white),
                        tooltip: 'Home',
                      ),
                      TextButton(
                        onPressed: () => context.push('/signup'),
                        child: const Text(
                          'Get started',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // App Name
                const SizedBox(height: 40),
                const Text(
                  'Academo',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // White Card with Form
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: AppSpacing.horizontalLg,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppRadius.xl),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        padding: AppSpacing.paddingXl,
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Welcome Back',
                                style: context.textStyles.headlineMedium?.bold.withColor(
                                  LightModeColors.lightOnSurface,
                                ),
                              ),
                              SizedBox(height: AppSpacing.xs),
                              Text(
                                'Enter your details below',
                                style: context.textStyles.bodyMedium?.withColor(
                                  LightModeColors.lightOnSurface.withValues(alpha: 0.6),
                                ),
                              ),
                              SizedBox(height: AppSpacing.xl),
                              
                              // Email Input
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Email Address',
                                    style: context.textStyles.bodySmall?.withColor(
                                      LightModeColors.lightOnSurface.withValues(alpha: 0.6),
                                    ),
                                  ),
                                  SizedBox(height: AppSpacing.xs),
                                  TextFormField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    style: context.textStyles.bodyLarge?.withColor(LightModeColors.lightOnSurface),
                                    decoration: InputDecoration(
                                      hintText: 'your@email.com',
                                      filled: true,
                                      fillColor: const Color(0xFFF9FAFB),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(AppRadius.md),
                                        borderSide: BorderSide.none,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(AppRadius.md),
                                        borderSide: BorderSide.none,
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(AppRadius.md),
                                        borderSide: BorderSide(
                                          color: Theme.of(context).colorScheme.primary,
                                          width: 2,
                                        ),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 16,
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your email';
                                      }
                                      if (!value.contains('@')) {
                                        return 'Please enter a valid email';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                              
                              SizedBox(height: AppSpacing.lg),
                              
                              // Password Input
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Login Password',
                                    style: context.textStyles.bodySmall?.withColor(
                                      LightModeColors.lightOnSurface.withValues(alpha: 0.6),
                                    ),
                                  ),
                                  SizedBox(height: AppSpacing.xs),
                                  TextFormField(
                                    controller: _passwordController,
                                    obscureText: _obscurePassword,
                                    style: context.textStyles.bodyLarge?.withColor(LightModeColors.lightOnSurface),
                                    decoration: InputDecoration(
                                      hintText: '••••••••',
                                      filled: true,
                                      fillColor: const Color(0xFFF9FAFB),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(AppRadius.md),
                                        borderSide: BorderSide.none,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(AppRadius.md),
                                        borderSide: BorderSide.none,
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(AppRadius.md),
                                        borderSide: BorderSide(
                                          color: Theme.of(context).colorScheme.primary,
                                          width: 2,
                                        ),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 16,
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility_outlined,
                                          color: LightModeColors.lightOnSurface.withValues(alpha: 0.4),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscurePassword = !_obscurePassword;
                                          });
                                        },
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your password';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                              
                              SizedBox(height: AppSpacing.md),
                              
                              // Remember Me Checkbox
                              Row(
                                children: [
                                  SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: Checkbox(
                                      value: _rememberMe,
                                      onChanged: (value) {
                                        setState(() {
                                          _rememberMe = value ?? true;
                                        });
                                      },
                                      activeColor: Theme.of(context).colorScheme.primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: AppSpacing.sm),
                                  Text(
                                    'Remember me',
                                    style: context.textStyles.bodyMedium?.withColor(
                                      LightModeColors.lightOnSurface.withValues(alpha: 0.8),
                                    ),
                                  ),
                                  const Spacer(),
                                  TextButton(
                                    onPressed: () => context.push('/forgot-password'),
                                    child: Text(
                                      'Forgot password?',
                                      style: context.textStyles.bodyMedium?.withColor(
                                        Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              
                              SizedBox(height: AppSpacing.lg),
                              
                              // Sign In Button with Gradient
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Theme.of(context).colorScheme.primary,
                                      Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(AppRadius.md),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: authProvider.isLoading ? null : _handleLogin,
                                    borderRadius: BorderRadius.circular(AppRadius.md),
                                    child: Container(
                                      height: 56,
                                      alignment: Alignment.center,
                                      child: authProvider.isLoading
                                          ? const SizedBox(
                                              height: 24,
                                              width: 24,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                              ),
                                            )
                                          : const Text(
                                              'Sign In',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                              
                              SizedBox(height: AppSpacing.xl),
                              
                              // Divider
                              Row(
                                children: [
                                  Expanded(
                                    child: Divider(
                                      color: LightModeColors.lightOnSurface.withValues(alpha: 0.2),
                                    ),
                                  ),
                                  Padding(
                                    padding: AppSpacing.horizontalMd,
                                    child: Text(
                                      'Or sign in with',
                                      style: context.textStyles.bodySmall?.withColor(
                                        LightModeColors.lightOnSurface.withValues(alpha: 0.6),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Divider(
                                      color: LightModeColors.lightOnSurface.withValues(alpha: 0.2),
                                    ),
                                  ),
                                ],
                              ),
                              
                              SizedBox(height: AppSpacing.lg),
                              
                              // Social Login Buttons
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Google sign-in coming soon')),
                                        );
                                      },
                                      icon: const Icon(Icons.g_mobiledata, size: 24),
                                      label: const Text('Google'),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        side: BorderSide(
                                          color: LightModeColors.lightOnSurface.withValues(alpha: 0.2),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Facebook sign-in coming soon')),
                                        );
                                      },
                                      icon: const Icon(Icons.facebook, size: 20),
                                      label: const Text('Facebook'),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        side: BorderSide(
                                          color: LightModeColors.lightOnSurface.withValues(alpha: 0.2),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
