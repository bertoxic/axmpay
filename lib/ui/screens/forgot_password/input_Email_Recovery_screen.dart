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

class _InputEmailRecoveryState extends State<InputEmailRecovery> with SingleTickerProviderStateMixin {
  final _inputEmailFormKey = GlobalKey<FormState>();
  String? email;
  var isLoading = false;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserServiceProvider>(context, listen: false);

    return Scaffold(
      body: Stack(
        children: [
          // Background design with custom shapes
          CustomPaint(
            painter: BackgroundPainter(colorScheme: colorScheme),
            size: Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height),
          ),
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
                          // Custom animated icon
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: const Duration(milliseconds: 800),
                            builder: (context, value, child) {
                              return Transform.scale(
                                scale: value,
                                child: Container(
                                  padding: EdgeInsets.all(20.sp),
                                  decoration: BoxDecoration(
                                    color: colorScheme.onPrimary.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.lock_reset,
                                    size: 60.sp,
                                    color: colorScheme.onPrimary,
                                  ),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 32.h),
                          AppText.title(
                            "Reset Password",
                            style: TextStyle(
                              color: colorScheme.onPrimary,
                              fontSize: 32.sp,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(height: 16.h),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 32.w),
                            child: AppText.caption(
                              "We'll send you a verification code to reset your password",
                              style: TextStyle(
                                color: colorScheme.onPrimary.withOpacity(0.9),
                                fontSize: 16.sp,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(height: 40.h),
                          Form(
                            key: _inputEmailFormKey,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 32.h),
                              decoration: BoxDecoration(
                                color: colorScheme.surface.withOpacity(0.95),
                                borderRadius: BorderRadius.circular(28),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  CustomTextField(
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
                                    prefixIcon: Icon(
                                      Icons.email_outlined,
                                      color: colorScheme.primary.withOpacity(0.7),
                                    ),
                                  ),
                                  SizedBox(height: 24.h),
                                  CustomButton(
                                    isLoading: isLoading,
                                    text: "Send Code",
                                    size: ButtonSize.large,
                                    onPressed: isLoading ? null : () async {
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
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 24.h),
                          TextButton.icon(
                            onPressed: () => context.pop(),
                            icon: Icon(
                              Icons.arrow_back_rounded,
                              size: 20.sp,
                              color: colorScheme.onPrimary,
                            ),
                            label: Text(
                              "Back to Login",
                              style: TextStyle(
                                color: colorScheme.onPrimary,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
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
}

// Custom background painter for unique design
class BackgroundPainter extends CustomPainter {
  final ColorScheme colorScheme;

  BackgroundPainter({required this.colorScheme});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          colorScheme.primary,
          colorScheme.primary.withBlue(colorScheme.primary.blue + 20),
          colorScheme.secondary,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    // Draw background
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Draw decorative shapes
    final shapePaint = Paint()
      ..color = colorScheme.onPrimary.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // Draw circles
    canvas.drawCircle(Offset(size.width * 0.1, size.height * 0.1), 60, shapePaint);
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.2), 40, shapePaint);
    canvas.drawCircle(Offset(size.width * 0.15, size.height * 0.8), 50, shapePaint);

    // Draw curved path
    final path = Path()
      ..moveTo(size.width, size.height * 0.7)
      ..quadraticBezierTo(
        size.width * 0.7,
        size.height * 0.8,
        size.width * 0.8,
        size.height * 0.9,
      )
      ..quadraticBezierTo(
        size.width * 0.9,
        size.height,
        size.width,
        size.height * 0.95,
      )
      ..lineTo(size.width, size.height * 0.7);

    canvas.drawPath(path, shapePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}