import 'dart:convert';
import 'package:AXMPAY/main.dart';
import 'package:AXMPAY/ui/widgets/custom_responsive_sizes/responsive_size.dart';
import 'package:AXMPAY/utils/global_error_handler.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

import '../../models/ResponseModel.dart';
import '../../models/user_model.dart';
import '../../providers/authentication_provider.dart';
import '../../providers/user_service_provider.dart';
import '../widgets/custom_dialog.dart';
import '../widgets/svg_maker/svg_icon.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthenticationProvider>(context);
    final size = MediaQuery.of(context).size;
    final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    final viewInsets = MediaQuery.of(context).viewInsets;
    final padding = MediaQuery.of(context).padding;

    return Scaffold(
      // Add resizeToAvoidBottomInset to handle keyboard properly
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Custom Background with Curved Division
          CustomPaint(
            size: Size(size.width, size.height),
            painter: BackgroundPainter(
              primaryColor: Theme.of(context).colorScheme.primary,
            ),
          ),
          // Main Content with proper keyboard handling
          SafeArea(
            child: SingleChildScrollView(
              // Enable scrolling when keyboard appears
              physics: const ClampingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  constraints: BoxConstraints(
                    minHeight: size.height - padding.top - padding.bottom,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Calculate responsive values outside of build methods
                        Builder(
                          builder: (context) {
                            final isKeyboardVisible = viewInsets.bottom > 100;
                            final isSmallScreen = size.height < 700;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Logo section with adaptive sizing and keyboard handling
                                SizedBox(
                                    height: isKeyboardVisible
                                        ? 10
                                        : (isSmallScreen ? 20 : 40)),

                                // Only show logo when keyboard is not visible or on larger screens
                                if (!isKeyboardVisible || !isSmallScreen)
                                  Center(
                                    child: TweenAnimationBuilder(
                                      tween: Tween<double>(begin: 0, end: 1),
                                      duration:
                                          const Duration(milliseconds: 1200),
                                      builder: (context, double value, child) {
                                        return Transform.scale(
                                          scale: value,
                                          child: Container(
                                            width: isKeyboardVisible
                                                ? 60
                                                : (isSmallScreen ? 90 : 120),
                                            height: isKeyboardVisible
                                                ? 60
                                                : (isSmallScreen ? 90 : 120),
                                            padding: EdgeInsets.all(
                                                isKeyboardVisible
                                                    ? 6
                                                    : (isSmallScreen ? 8 : 12)),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                            child: SvgIcon(
                                              "assets/images/axmpay_logo.svg",
                                              color: Colors.grey.shade200,
                                              width: 24,
                                              height: 40,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),

                                // Welcome text with adaptive spacing and keyboard handling
                                SizedBox(
                                    height: isKeyboardVisible
                                        ? 8
                                        : (isSmallScreen ? 12 : 32)),

                                // Hide welcome text when keyboard is visible on small screens
                                if (!isKeyboardVisible)
                                  FadeTransition(
                                    opacity: _fadeAnimation,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Welcome back!',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineMedium
                                              ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontSize: isSmallScreen ? 24 : 32,
                                            shadows: [
                                              Shadow(
                                                color: Colors.black
                                                    .withOpacity(0.1),
                                                offset: const Offset(2, 2),
                                                blurRadius: 4,
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Please sign in to continue.',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.copyWith(
                                                color: Colors.white
                                                    .withOpacity(0.9),
                                                fontSize:
                                                    isSmallScreen ? 14 : 16,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),

                                // Form fields section with adaptive spacing
                                SizedBox(
                                    height: isKeyboardVisible
                                        ? 12
                                        : (isSmallScreen ? 16 : 40)),

                                // Email field
                                buildTextField(
                                  controller: _emailController,
                                  labelText: 'Email',
                                  hintText: 'Enter your email address',
                                  prefixIcon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: validateEmail,
                                ),

                                SizedBox(
                                    height: isKeyboardVisible
                                        ? 12
                                        : (isSmallScreen ? 16 : 20)),

                                // Password field
                                buildTextField(
                                  controller: _passwordController,
                                  labelText: 'Password',
                                  hintText: 'Enter your password',
                                  prefixIcon: Icons.lock_outline,
                                  obscureText: _obscurePassword,
                                  validator: validatePassword,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: Colors.white.withOpacity(0.7),
                                    ),
                                    onPressed: () => setState(() =>
                                        _obscurePassword = !_obscurePassword),
                                  ),
                                ),

                                SizedBox(height: 8),

                                // Forgot password with improved visibility and responsive layout
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: Colors.black.withOpacity(0.15),
                                    ),
                                    child: TextButton.icon(
                                      icon: Icon(
                                        Icons.lock_reset,
                                        size: 16,
                                        color: Colors.white.withOpacity(0.9),
                                      ),
                                      onPressed: () => context.pushNamed(
                                          "forgot_password_input_mail"),
                                      label: Text(
                                        'Forgot password?',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: isKeyboardVisible ? 12 : 14,
                                          shadows: [
                                            Shadow(
                                              color:
                                                  Colors.black.withOpacity(0.3),
                                              offset: const Offset(1, 1),
                                              blurRadius: 2,
                                            ),
                                          ],
                                        ),
                                      ),
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 4, horizontal: 8),
                                      ),
                                    ),
                                  ),
                                ),

                                // Adaptive spacing based on keyboard visibility
                                SizedBox(
                                    height: isKeyboardVisible
                                        ? 20
                                        : (isSmallScreen ? 40 : 80)),

                                // Login button with adaptive spacing
                                Container( padding: EdgeInsets.symmetric( horizontal:4.w),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.white,
                                        Colors.white.withOpacity(0.9),
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 10,
                                        spreadRadius: 0,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        elevation: 0,
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        foregroundColor: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        padding: EdgeInsets.symmetric(
                                          vertical: isKeyboardVisible
                                              ? 12
                                              : (isSmallScreen ? 12 : 16),
                                          horizontal: 16,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                      ),
                                      onPressed: _isLoading
                                          ? null
                                          : () => _handleLogin(authProvider),
                                      child: _isLoading
                                          ? const CircularProgressIndicator(
                                              color: Colors.deepPurple,
                                              strokeWidth: 2,
                                            )
                                          : Text(
                                              'Sign In',
                                              style: TextStyle(
                                                fontSize: isKeyboardVisible
                                                    ? 14
                                                    : (isSmallScreen ? 16 : 18),
                                                fontWeight: FontWeight.w600,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimary,
                                              ),
                                            ),
                                    ),
                                  ),
                                ),

                                // Sign up link with adaptive spacing
                                SizedBox(
                                    height: isKeyboardVisible
                                        ? 12
                                        : (isSmallScreen ? 16 : 32)),

                                // Sign up implementation
                                Center(
                                  child: TextButton(
                                    onPressed: () =>
                                        context.pushNamed("register"),
                                    child: RichText(
                                      text: TextSpan(
                                        text: "Don't have an account? ",
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .withOpacity(0.9),
                                          fontSize: isKeyboardVisible ? 12 : 14,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: "Sign up",
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              fontWeight: FontWeight.bold,
                                              fontSize:
                                                  isKeyboardVisible ? 12 : 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                SizedBox(height: 16),
                              ],
                            );
                          },
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
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required IconData prefixIcon,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(0.1),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        style: TextStyle(
          fontSize: 16,
          color: Colors.white,
        ),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(
            color: Colors.white.withOpacity(0.9),
          ),
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.5),
          ),
          prefixIcon: Icon(
            prefixIcon,
            color: Colors.white.withOpacity(0.9),
          ),
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Colors.white,
              width: 1,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.error,
              width: 1,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.error,
              width: 1,
            ),
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  String? validateEmail(String? value) {
    value = value?.trim();
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? validatePassword(String? value) {
    value = value?.trim();
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 4) {
      return 'Password must be at least 4 characters long';
    }
    return null;
  }

  Future<void> _handleLogin(AuthenticationProvider authProvider) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final userDetails = LoginDetails(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    try {
      final resp = await authProvider.login(context, userDetails);

      if (!mounted) return;

      final userServiceProvider =
          Provider.of<UserServiceProvider>(context, listen: false);

      if (resp == null) {
        throw Exception('Login response is null');
      }

      if (resp.status == ResponseStatus.failed) {
        await _showLoginFailedPopup(resp.message);
        return;
      }

      await _handleUserNavigation(userServiceProvider, userDetails);
    } catch (e) {
      if (!mounted) return;
      await _showErrorPopup(e);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showLoginFailedPopup(String message) async {
    await CustomPopup.show(
      type: PopupType.error,
      context: context,
      message: message,
      title: "Login Failed",
    );
    print("Login failed popup shown");
  }

  Future<void> _showErrorPopup(Object e) async {
    await CustomPopup.show(
      type: PopupType.error,
      context: context,
      message: 'Login failed: ${e.runtimeType}',
      title: "Error",
    );
  }

  Future<void> _handleUserNavigation(
      UserServiceProvider userServiceProvider, LoginDetails userDetails) async {
    if (userServiceProvider.userdata?.userStatus.toString().toLowerCase() ==
        "confirmed") {
      final storage = FlutterSecureStorage();
      final passCodeMapString = await storage.read(key: 'passcodeMap');

      if (passCodeMapString == null) {
        _navigateToPasscodeSetup(userDetails.email);
      } else {
        final passCodeMap = jsonDecode(passCodeMapString);

        if (passCodeMap["email"] == userDetails.email) {
          context.goNamed("home");
        } else {
          _navigateToPasscodeSetup(userDetails.email);
        }
      }
    } else {
      context.pushNamed("user_details_page");
    }
  }

  void _navigateToPasscodeSetup(String? email) {
    context.pushNamed(
      'passcode_setup_screen',
      pathParameters: {'email': email ?? ""},
    );
  }
}

class BackgroundPainter extends CustomPainter {
  final Color primaryColor;

  BackgroundPainter({required this.primaryColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final path = Path();

    // Create gradient for the top part
    paint.shader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        primaryColor,
        primaryColor.withBlue(150),
      ],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    // Adjust the curve height based on device size
    final curveHeight = size.height * 0.65;

    // Draw the curved path for the top section
    path.moveTo(0, 0);
    path.lineTo(0, curveHeight);

    // Create bezier curve
    path.quadraticBezierTo(
      size.width * 0.25,
      curveHeight + (size.height * 0.05),
      size.width * 0.5,
      curveHeight,
    );

    path.quadraticBezierTo(
      size.width * 0.75,
      curveHeight - (size.height * 0.05),
      size.width,
      curveHeight,
    );

    path.lineTo(size.width, 0);
    path.close();

    // Draw the primary color section
    canvas.drawPath(path, paint);

    // Create transition gradient to ensure smooth boundary
    final transitionPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          primaryColor.withOpacity(0.3),
          primaryColor.withOpacity(0.1),
        ],
      ).createShader(
        Rect.fromLTWH(0, curveHeight - 20, size.width, 40),
      );

    // Draw transition area
    final transitionPath = Path()
      ..moveTo(0, curveHeight - 20)
      ..lineTo(0, curveHeight + 20)
      ..lineTo(size.width, curveHeight + 20)
      ..lineTo(size.width, curveHeight - 20)
      ..close();

    canvas.drawPath(transitionPath, transitionPaint);

    // Create bottom section with white gradient
    final bottomPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withOpacity(0.9),
          Colors.white,
        ],
      ).createShader(
        Rect.fromLTWH(0, curveHeight, size.width, size.height - curveHeight),
      );

    final bottomPath = Path()
      ..moveTo(0, curveHeight)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width, curveHeight)
      ..quadraticBezierTo(
        size.width * 0.75,
        curveHeight - (size.height * 0.05),
        size.width * 0.5,
        curveHeight,
      )
      ..quadraticBezierTo(
        size.width * 0.25,
        curveHeight + (size.height * 0.05),
        0,
        curveHeight,
      );

    canvas.drawPath(bottomPath, bottomPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
