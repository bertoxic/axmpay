import 'package:AXMPAY/main.dart';
import 'package:AXMPAY/models/ResponseModel.dart';
import 'package:AXMPAY/ui/widgets/custom_buttons.dart';
import 'package:AXMPAY/ui/widgets/custom_dialog.dart';
import 'package:AXMPAY/ui/widgets/custom_responsive_sizes/responsive_size.dart';
import 'package:AXMPAY/ui/widgets/custom_text/custom_apptext.dart';
import 'package:AXMPAY/ui/widgets/custom_textfield.dart';
import 'package:AXMPAY/utils/form_validator.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../providers/user_service_provider.dart';

class InputEmailRecovery extends StatefulWidget {
  const InputEmailRecovery({super.key});

  @override
  State<InputEmailRecovery> createState() => _InputEmailRecoveryState();
}

class _InputEmailRecoveryState extends State<InputEmailRecovery> with TickerProviderStateMixin {
  final _inputEmailFormKey = GlobalKey<FormState>();
  String? email;
  var isLoading = false;
  late AnimationController _controller;
  late AnimationController _pulseController;
  late AnimationController _floatingController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _floatingAnimation;

  TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _floatingAnimation = Tween<double>(begin: -10.0, end: 10.0).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserServiceProvider>(context, listen: false);

    return Scaffold(
      body: Stack(
        children: [
          // Enhanced background design
          CustomPaint(
            painter: ModernBackgroundPainter(colorScheme: colorScheme),
            size: Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height),
          ),
          // Floating animated elements
          ...List.generate(5, (index) => _buildFloatingElement(index)),
          SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height,
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Animated icon with pulsing effect
                          AnimatedBuilder(
                            animation: _pulseAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _pulseAnimation.value,
                                child: Container(
                                  padding: EdgeInsets.all(24.sp),
                                  decoration: BoxDecoration(
                                    gradient: RadialGradient(
                                      colors: [
                                        colorScheme.primary.withOpacity(0.3),
                                        colorScheme.secondary.withOpacity(0.1),
                                        Colors.transparent,
                                      ],
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Container(
                                    padding: EdgeInsets.all(20.sp),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: colorScheme.primary.withOpacity(0.3),
                                          blurRadius: 20,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.shield_outlined,
                                      size: 48.sp,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 40.h),
                          // Title with gradient text effect
                          ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: [Colors.white, Colors.white.withOpacity(0.8)],
                            ).createShader(bounds),
                            child: AppText.title(
                              "Reset Password",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 36.sp,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                                height: 1.1,
                              ),
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 40.w),
                            child: AppText.caption(
                              "Enter your email address and we'll send you a secure verification code",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.85),
                                fontSize: 16.sp,
                                height: 1.6,
                                fontWeight: FontWeight.w400,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(height: 48.h),
                          // Modern card design
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 8.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 30,
                                  offset: const Offset(0, 15),
                                ),
                                BoxShadow(
                                  color: colorScheme.primary.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Form(
                              key: _inputEmailFormKey,
                              child: Padding(
                                padding: EdgeInsets.all(32.w),
                                child: Column(
                                  children: [
                                    // Email input with modern styling
                                    Container(
                                      decoration: BoxDecoration(
                                        color: colorScheme.primary.withOpacity(0.05),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: colorScheme.primary.withOpacity(0.1),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: CustomTextField(
                                        controller: _emailController,
                                        onChanged: (value) {
                                          email = _emailController.text;
                                        },
                                        validator: (value) => FormValidator.validate(
                                          value,
                                          ValidatorType.email,
                                          fieldName: "Email",
                                        ),
                                        fieldName: 'emailAddress',
                                        hintText: "Enter your email address",
                                        prefixIcon: Container(
                                          padding: EdgeInsets.all(12.sp),
                                          child: Icon(
                                            Icons.alternate_email,
                                            color: colorScheme.primary,
                                            size: 22.sp,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 32.h),
                                    // Custom gradient button
                                    Container(
                                      width: double.infinity,
                                      height: 56.h,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            colorScheme.primary,
                                            colorScheme.secondary,
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: colorScheme.primary.withOpacity(0.4),
                                            blurRadius: 15,
                                            offset: const Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(16),
                                          onTap: isLoading ? null : () async {
                                            if (_inputEmailFormKey.currentState!.validate()) {
                                              setState(() {
                                                isLoading = true;
                                              });
                                              try {
                                                ResponseResult? resp = await userProvider.sendVerificationCode(context, email!);
                                                if (resp?.status == ResponseStatus.success) {
                                                  if (!mounted) return;
                                                  context.pushNamed(
                                                    "/forgot_password_otp",
                                                    pathParameters: {'email': email!},
                                                  );
                                                } else {
                                                  if (!mounted) return;
                                                  await CustomPopup.show(
                                                    backgroundColor: colorScheme.onPrimary,
                                                    type: PopupType.error,
                                                    title: "Error",
                                                    message: "${resp?.message}",
                                                    context: context,
                                                  );
                                                }
                                              } catch (e) {
                                                if (!mounted) return;
                                                await CustomPopup.show(
                                                  backgroundColor: colorScheme.onPrimary,
                                                  type: PopupType.error,
                                                  title: "Error",
                                                  message: "An unexpected error occurred. Please try again.",
                                                  context: context,
                                                );
                                              } finally {
                                                setState(() {
                                                  isLoading = false;
                                                });
                                              }
                                            }
                                          },
                                          child: Center(
                                            child: isLoading
                                                ? SizedBox(
                                              width: 24.sp,
                                              height: 24.sp,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2.5,
                                              ),
                                            )
                                                : Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.send_rounded,
                                                  color: Colors.white,
                                                  size: 20.sp,
                                                ),
                                                SizedBox(width: 8.w),
                                                Text(
                                                  "Send Verification Code",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16.sp,
                                                    fontWeight: FontWeight.w600,
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 32.h),
                          // Back button with modern styling
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: InkWell(
                              onTap: () => context.pop(),
                              borderRadius: BorderRadius.circular(25),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.arrow_back_ios_rounded,
                                    size: 18.sp,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    "Back to Login",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildFloatingElement(int index) {
    final positions = [
      Offset(50, 150),
      Offset(300, 100),
      Offset(80, 600),
      Offset(320, 550),
      Offset(150, 350),
    ];

    final sizes = [30.0, 20.0, 25.0, 35.0, 15.0];

    return AnimatedBuilder(
      animation: _floatingAnimation,
      builder: (context, child) {
        return Positioned(
          left: positions[index].dx,
          top: positions[index].dy + (_floatingAnimation.value * (index.isEven ? 1 : -1)),
          child: Container(
            width: sizes[index],
            height: sizes[index],
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}

// Enhanced background painter
class ModernBackgroundPainter extends CustomPainter {
  final ColorScheme colorScheme;

  ModernBackgroundPainter({required this.colorScheme});

  @override
  void paint(Canvas canvas, Size size) {
    // Primary gradient background
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          colorScheme.primary,
          colorScheme.primary.withOpacity(0.8),
          colorScheme.secondary,
        ],
        stops: [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Geometric shapes overlay
    final shapePaint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.fill;

    // Large decorative circle
    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.15),
      120,
      shapePaint,
    );

    // Medium circle
    canvas.drawCircle(
      Offset(size.width * 0.15, size.height * 0.3),
      80,
      shapePaint,
    );

    // Abstract wave pattern
    final wavePath = Path();
    wavePath.moveTo(0, size.height * 0.7);
    wavePath.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.65,
      size.width * 0.5,
      size.height * 0.7,
    );
    wavePath.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.75,
      size.width,
      size.height * 0.7,
    );
    wavePath.lineTo(size.width, size.height);
    wavePath.lineTo(0, size.height);
    wavePath.close();

    canvas.drawPath(wavePath, shapePaint);

    // Angular geometric shape
    final geometricPath = Path();
    geometricPath.moveTo(size.width * 0.6, size.height * 0.1);
    geometricPath.lineTo(size.width * 0.9, size.height * 0.25);
    geometricPath.lineTo(size.width * 0.8, size.height * 0.4);
    geometricPath.lineTo(size.width * 0.5, size.height * 0.3);
    geometricPath.close();

    canvas.drawPath(geometricPath, shapePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}