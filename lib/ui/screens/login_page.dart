import 'dart:convert';

import 'package:AXMPAY/main.dart';
import 'package:AXMPAY/models/ResponseModel.dart';
import 'package:AXMPAY/providers/user_service_provider.dart';
import 'package:AXMPAY/ui/widgets/custom_responsive_sizes/responsive_size.dart';
import 'package:AXMPAY/ui/widgets/custom_text/custom_apptext.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:AXMPAY/constants/text_constants.dart';
import 'package:AXMPAY/ui/widgets/custom_buttons.dart';
import 'package:AXMPAY/ui/widgets/custom_container.dart';
import 'package:AXMPAY/ui/widgets/custom_textfield.dart';

import '../../models/user_model.dart';
import '../../providers/authentication_provider.dart';
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthenticationProvider>(context);
    final size = MediaQuery.of(context).size;
    final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      body: Stack(children: [
        // Custom Background with Curved Division
        CustomPaint(
          size: Size(size.width, size.height),
          painter: BackgroundPainter(
            primaryColor: Theme.of(context).colorScheme.primary,
          ),
        ),
        // Main Content
        SafeArea(
          child: Column(
            children: [
              SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 24.w,
                    right: 24.w,
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child:Container(
                    constraints: BoxConstraints(
                      minHeight: size.height - MediaQuery.of(context).padding.top,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: keyboardVisible ? 20.h : 40.h),
                          if (!keyboardVisible)
                            Center(
                              child: TweenAnimationBuilder(
                                tween: Tween<double>(begin: 0, end: 1),
                                duration: const Duration(milliseconds: 1200),
                                builder: (context, double value, child) {
                                  return Transform.scale(
                                    scale: value,
                                    child: Container(
                                      width: 120.w,
                                      height: 120.h,
                                      padding: EdgeInsets.symmetric(
                                          vertical: 12.w, horizontal: 12.w),
                                      decoration: BoxDecoration(
                                        // gradient: LinearGradient(
                                        //   begin: Alignment.topLeft,
                                        //   end: Alignment.bottomRight,
                                        //   colors: [
                                        //     Colors.white.withOpacity(0.2),
                                        //     Colors.white.withOpacity(0.1),
                                        //   ],
                                        // ),
                                        borderRadius: BorderRadius.circular(30),
                                        // boxShadow: [
                                        //   BoxShadow(
                                        //     color: Colors.black.withOpacity(0.2),
                                        //     blurRadius: 20,
                                        //     spreadRadius: 5,
                                        //   ),
                                        // ],
                                      ),
                                      child: SvgIcon(
                                          "assets/images/axmpay_logo.svg",
                                          color: Colors.grey.shade200,
                                          width: 24.w,
                                          height: 40.h),
                                    ),
                                  );
                                },
                              ),
                            ),
                          SizedBox(height: keyboardVisible ? 16.h : 32.h),
                          if (!keyboardVisible)
                            FadeTransition(
                              opacity: _fadeAnimation,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Welcome back!',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium
                                        ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 32.sp,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withOpacity(0.1),
                                          offset: const Offset(2, 2),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    'Please sign in to continue.',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(
                                          color: Colors.white.withOpacity(0.9),
                                          fontSize: 16.sp,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          SizedBox(height: keyboardVisible ? 20.h : 40.h),
                          buildTextField(
                            controller: _emailController,
                            labelText: 'Email',
                            hintText: 'Enter your email address',
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: validateEmail,
                          ),
                          SizedBox(height: 20.h),
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
                              onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          SizedBox(height: 10.h),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () =>
                                  context.pushNamed("forgot_password_input_mail"),
                              child: Text(
                                'Forgot password?',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.2),
                                      offset: const Offset(1, 1),
                                      blurRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 80.h),
                          Container(
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
                            child: Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      elevation: 0,
                                      backgroundColor: colorScheme.primary,
                                      foregroundColor:
                                          Theme.of(context).colorScheme.primary,
                                      padding: EdgeInsets.symmetric(
                                          vertical: 16.h, horizontal: 16.w),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
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
                                              fontSize: 18.sp,
                                              fontWeight: FontWeight.w600,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onPrimary,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          //const Spacer(),
                          SizedBox(height: 32.h),
                          Center(
                            child: TextButton(
                              onPressed: () => context.pushNamed("register"),
                              child: RichText(
                                text: TextSpan(
                                  text: "Don't have an account? ",
                                  style: TextStyle(
                                    color: colorScheme.primary.withOpacity(0.9),
                                    fontSize: 14.sp,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: "Sign up",
                                      style: TextStyle(
                                        color: colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 16.h),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ]),
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
          fontSize: 16.sp,
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
          contentPadding:
              EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        ),
      ),
    );
  }

  // Validation methods and login handler remain the same
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 4) {
      return 'Password must be at least 4 characters long';
    }
    return null;
  }

  void _handleLogin(AuthenticationProvider authProvider) async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      LoginDetails userDetails = LoginDetails(
        email: _emailController.text,
        password: _passwordController.text,
      );

      try {
        var resp = await authProvider.login(context, userDetails);
        if (!mounted) return;

        UserServiceProvider userServiceProvider =
            Provider.of<UserServiceProvider>(context, listen: false);

        if (resp == null) {
          throw Exception('Login response is null');
        }

        if (resp.status == ResponseStatus.failed) {
          CustomPopup.show(
            type: PopupType.error,
            context: context,
            message: resp.message,
            title: "Login Failed",
          );
          return;
        }

        if (userServiceProvider.userdata?.userStatus.toString().toLowerCase() ==
            "confirmed") {
          const storage = FlutterSecureStorage();
          String? passCodeMapString = await storage.read(key: 'passcodeMap');

          if (passCodeMapString == null) {
            context.pushNamed(
              'passcode_setup_screen',
              pathParameters: {'email': userDetails.email ?? ""},
            );
          } else {
            var passCodeMap = jsonDecode(passCodeMapString);
            if (passCodeMap["email"] == userDetails.email) {
              context.goNamed("/home");
            } else {
              context.pushNamed(
                'passcode_setup_screen',
                pathParameters: {'email': userDetails.email ?? ""},
              );
            }
          }
        } else {
          context.goNamed("user_details_page");
        }
      } catch (e) {
        if (!mounted) return;
        CustomPopup.show(
          type: PopupType.error,
          context: context,
          message: 'Login failed: ${e.toString()}',
          title: "Error",
        );
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
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

    // Draw the curved path for the top section
    path.moveTo(0, 0);
    path.lineTo(0, size.height * 0.65);

    // Create bezier curve
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.7,
      size.width * 0.5,
      size.height * 0.65,
    );

    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.6,
      size.width,
      size.height * 0.65,
    );

    path.lineTo(size.width, 0);
    path.close();

    // Draw the primary color section
    canvas.drawPath(path, paint);

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
          Rect.fromLTWH(0, size.height * 0.6, size.width, size.height * 0.4));

    final bottomPath = Path()
      ..moveTo(0, size.height * 0.65)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width, size.height * 0.65)
      ..quadraticBezierTo(
        size.width * 0.75,
        size.height * 0.6,
        size.width * 0.5,
        size.height * 0.65,
      )
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height * 0.7,
        0,
        size.height * 0.65,
      );

    canvas.drawPath(bottomPath, bottomPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
