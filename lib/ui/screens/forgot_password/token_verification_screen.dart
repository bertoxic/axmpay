import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:AXMPAY/main.dart';
import 'package:AXMPAY/models/ResponseModel.dart';
import 'package:AXMPAY/providers/user_service_provider.dart';
import 'package:AXMPAY/ui/widgets/custom_buttons.dart';
import 'package:AXMPAY/ui/widgets/custom_responsive_sizes/responsive_size.dart';
import 'package:AXMPAY/ui/widgets/custom_text/custom_apptext.dart';
import 'package:AXMPAY/utils/form_validator.dart';
import 'package:AXMPAY/ui/widgets/custom_dialog.dart';
import 'package:AXMPAY/ui/widgets/custom_textfield.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String email;
  const OTPVerificationScreen({Key? key, required this.email}) : super(key: key);

  @override
  _OTPVerificationScreenState createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen>
    with TickerProviderStateMixin {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  final _inputOTPFormKey = GlobalKey<FormState>();
  String? otp;
  bool isLoading = false;
  bool canResend = false;
  int countdown = 60;

  late AnimationController _mainController;
  late AnimationController _pulseController;
  late AnimationController _shakeController;
  late AnimationController _countdownController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startCountdown();
  }

  void _setupAnimations() {
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _countdownController = AnimationController(
      duration: const Duration(seconds: 60),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _mainController, curve: Curves.easeOutBack));

    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    _mainController.forward();
  }

  void _startCountdown() {
    _countdownController.forward();
    _countdownController.addListener(() {
      setState(() {
        countdown = (60 * (1 - _countdownController.value)).round();
        if (countdown <= 0) {
          canResend = true;
        }
      });
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    _shakeController.dispose();
    _countdownController.dispose();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onChanged(int index) {
    if (_controllers[index].text.length == 1) {
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        setState(() {
          otp = _controllers.map((c) => c.text).join();
        });
        // Auto-verify when all digits are entered
        Future.delayed(Duration(milliseconds: 500), () {
          if (otp?.length == 6) {
            _verifyOTP();
          }
        });
      }
    } else if (_controllers[index].text.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  void _shakeOnError() {
    _shakeController.reset();
    _shakeController.forward();
  }

  Future<void> _verifyOTP() async {
    if (_inputOTPFormKey.currentState!.validate() && otp?.length == 6) {
      setState(() {
        isLoading = true;
      });

      try {
        final userProvider = Provider.of<UserServiceProvider>(context, listen: false);
        final resp = await userProvider.verifyOTPForPasswordChange(context, widget.email, otp!);

        if (resp.status == ResponseStatus.failed) {
          if (!mounted) return;
          _shakeOnError();
          await CustomPopup.show(
            backgroundColor: colorScheme.onPrimary,
            type: PopupType.error,
            title: "Verification Failed",
            message: "The OTP you entered is incorrect. Please try again.",
            context: context,
          );
        } else {
          if (!mounted) return;
          context.pushNamed("change_password_screen",
              pathParameters: {"email": widget.email, "otp": otp!});
        }
      } catch (e) {
        if (!mounted) return;
        _shakeOnError();
        await CustomPopup.show(
          backgroundColor: colorScheme.onPrimary,
          type: PopupType.error,
          title: "Error",
          message: "An unexpected error occurred. Please try again later.",
          context: context,
        );
      } finally {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _resendOTP() async {
    if (!canResend) return;

    setState(() {
      canResend = false;
      countdown = 60;
    });

    _countdownController.reset();
    _startCountdown();

    try {
      final userProvider = Provider.of<UserServiceProvider>(context, listen: false);
      await userProvider.sendVerificationCode(context, widget.email);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('New OTP sent successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to resend OTP. Please try again.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Enhanced background
          CustomPaint(
            painter: OTPBackgroundPainter(colorScheme: colorScheme),
            size: Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height),
          ),
          // Floating elements
          ...List.generate(4, (index) => _buildFloatingElement(index)),
          SafeArea(
            child: SingleChildScrollView(
              child: Container(
                height: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 60.h),
                          // Animated icon with pulse effect
                          AnimatedBuilder(
                            animation: _pulseAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _pulseAnimation.value,
                                child: Container(
                                  padding: EdgeInsets.all(28.sp),
                                  decoration: BoxDecoration(
                                    gradient: RadialGradient(
                                      colors: [
                                        Colors.white.withOpacity(0.2),
                                        Colors.white.withOpacity(0.05),
                                        Colors.transparent,
                                      ],
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Container(
                                    padding: EdgeInsets.all(24.sp),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: colorScheme.primary.withOpacity(0.3),
                                          blurRadius: 25,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.security,
                                      size: 56.sp,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 40.h),
                          // Title with gradient effect
                          ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: [Colors.white, Colors.white.withOpacity(0.9)],
                            ).createShader(bounds),
                            child: AppText.headline(
                              "Verify Your Code",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 32.sp,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                          SizedBox(height: 16.h),
                          AppText.body(
                            "Enter the 6-digit verification code sent to:",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 16.sp,
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              widget.email,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(height: 48.h),
                          // OTP input fields with shake animation
                          AnimatedBuilder(
                            animation: _shakeAnimation,
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(_shakeAnimation.value * 10 * (1 - _shakeAnimation.value), 0),
                                child: Form(
                                  key: _inputOTPFormKey,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: List.generate(6, (index) => _buildOTPField(index)),
                                  ),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 40.h),
                          // Progress indicator
                          if (otp?.length == 6 && isLoading)
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 20.h),
                              child: Column(
                                children: [
                                  SizedBox(
                                    width: 32.sp,
                                    height: 32.sp,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 3,
                                    ),
                                  ),
                                  SizedBox(height: 12.h),
                                  Text(
                                    "Verifying...",
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          Spacer(),

                          // Resend section
                          Container(
                            padding: EdgeInsets.all(24.w),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  canResend ? "Didn't receive the code?" : "Resend code in",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 14.sp,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                if (!canResend)
                                  Text(
                                    "${countdown}s",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  )
                                else
                                  GestureDetector(
                                    onTap: _resendOTP,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(25),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.1),
                                            blurRadius: 10,
                                            offset: const Offset(0, 5),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.refresh,
                                            color: colorScheme.primary,
                                            size: 18.sp,
                                          ),
                                          SizedBox(width: 8.w),
                                          Text(
                                            "Resend Code",
                                            style: TextStyle(
                                              color: colorScheme.primary,
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          SizedBox(height: 24.h),
                          // Back button
                          GestureDetector(
                            onTap: () => context.pop(),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.arrow_back_ios_rounded,
                                    size: 16.sp,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    "Back",
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
                          SizedBox(height: 32.h),
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

  Widget _buildOTPField(int index) {
    return Container(
      width: 48.w,
      height: 56.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextFormField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        style: TextStyle(
          fontSize: 24.sp,
          fontWeight: FontWeight.w700,
          color: colorScheme.primary,
        ),
        inputFormatters: [
          LengthLimitingTextInputFormatter(1),
          FilteringTextInputFormatter.digitsOnly,
        ],
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: colorScheme.primary,
              width: 2,
            ),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: (_) => _onChanged(index),
        validator: (value) => FormValidator.validate(
          value,
          ValidatorType.digits,
          fieldName: "Digit ${index + 1}",
        ),
      ),
    );
  }

  Widget _buildFloatingElement(int index) {
    final positions = [
      Offset(60, 200),
      Offset(320, 150),
      Offset(40, 500),
      Offset(300, 450),
    ];

    final sizes = [25.0, 18.0, 22.0, 30.0];

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Positioned(
          left: positions[index].dx,
          top: positions[index].dy + (_pulseAnimation.value * 15 * (index.isEven ? 1 : -1)),
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

// Custom background painter for OTP screen
class OTPBackgroundPainter extends CustomPainter {
  final ColorScheme colorScheme;

  OTPBackgroundPainter({required this.colorScheme});

  @override
  void paint(Canvas canvas, Size size) {
    // Primary gradient background
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          colorScheme.primary,
          colorScheme.primary.withOpacity(0.9),
          colorScheme.secondary,
        ],
        stops: [0.0, 0.6, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Decorative elements
    final shapePaint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.fill;

    // Large decorative shapes
    canvas.drawCircle(
      Offset(size.width * 0.9, size.height * 0.1),
      100,
      shapePaint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.1, size.height * 0.25),
      60,
      shapePaint,
    );

    // Bottom wave pattern
    final wavePath = Path();
    wavePath.moveTo(0, size.height * 0.8);
    wavePath.quadraticBezierTo(
      size.width * 0.3,
      size.height * 0.75,
      size.width * 0.6,
      size.height * 0.8,
    );
    wavePath.quadraticBezierTo(
      size.width * 0.8,
      size.height * 0.85,
      size.width,
      size.height * 0.8,
    );
    wavePath.lineTo(size.width, size.height);
    wavePath.lineTo(0, size.height);
    wavePath.close();

    canvas.drawPath(wavePath, shapePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}