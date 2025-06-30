import 'dart:async';
import 'package:AXMPAY/main.dart';
import 'package:AXMPAY/models/ResponseModel.dart';
import 'package:AXMPAY/models/user_model.dart';
import 'package:AXMPAY/providers/user_service_provider.dart';
import 'package:AXMPAY/ui/widgets/custom_buttons.dart';
import 'package:AXMPAY/ui/widgets/custom_responsive_sizes/responsive_size.dart';
import 'package:AXMPAY/ui/widgets/custom_text/custom_apptext.dart';
import 'package:AXMPAY/utils/form_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../../widgets/custom_dialog.dart';
import '../../widgets/custom_textfield.dart';

class NewUserOTPVerificationScreen extends StatefulWidget {
  final PreRegisterDetails preRegisterDetails;
  const NewUserOTPVerificationScreen({Key? key, required this.preRegisterDetails}) : super(key: key);

  @override
  _NewUserOTPVerificationScreenState createState() => _NewUserOTPVerificationScreenState();
}

class _NewUserOTPVerificationScreenState extends State<NewUserOTPVerificationScreen> with SingleTickerProviderStateMixin {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  final _inputOTPFormKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String? otp;
  String? email;
  bool _isLoading = false;
  int _resendSeconds = 120;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    _startResendTimer();
  }

  void _startResendTimer() {
    _resendTimer?.cancel(); // Cancel any existing timer
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && _resendSeconds > 0) {
        setState(() => _resendSeconds--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _resendTimer?.cancel(); // Cancel timer on dispose
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
      }
    } else if (_controllers[index].text.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  // Helper method to format timer display
  String _formatTimer(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.primary.withOpacity(0.3),
                    colorScheme.secondary.withOpacity(0.8),
                  ],
                ),
              ),
              child: Center(
                child: SafeArea(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(height: 40.h),
                            Hero(
                              tag: 'lockIcon',
                              child: Container(
                                padding: EdgeInsets.all(20.w),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Icon(
                                  Icons.lock_outline,
                                  size: 60.h,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ),
                            SizedBox(height: 24.h),
                            AnimatedTextKit(
                              animatedTexts: [
                                FadeAnimatedText(
                                  'OTP Verification',
                                  textAlign: TextAlign.center,
                                  textStyle: TextStyle(
                                    fontSize: 28.sp,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
                                  ),
                                  duration: const Duration(seconds: 2),
                                ),
                              ],
                              totalRepeatCount: 1,
                            ),
                            SizedBox(height: 16.h),
                            AppText.body(
                              "Please enter the 6-digit code sent to:",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                            SizedBox(height: 8.h),
                            AppText.body(
                              widget.preRegisterDetails.email,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                            SizedBox(height: 32.h),
                            Form(
                              key: _inputOTPFormKey,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: List.generate(
                                  6,
                                      (index) => SizedBox(
                                    width: 45.w,
                                    height: 55.h,
                                    child: CustomTextField(
                                      validator: (value) => FormValidator.validate(
                                        value,
                                        ValidatorType.digits,
                                        fieldName: "Digit ${index + 1}",
                                      ),
                                      controller: _controllers[index],
                                      focusNode: _focusNodes[index],
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        LengthLimitingTextInputFormatter(1),
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: colorScheme.surface,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide.none,
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                            color: colorScheme.primary,
                                            width: 2,
                                          ),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                            color: colorScheme.error,
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                      onChanged: (_) => _onChanged(index),
                                      fieldName: 'Digit ${index + 1}',
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 32.h),
                            if (_isLoading)
                              Center(
                                child: CircularProgressIndicator(
                                  color: colorScheme.primary,
                                  strokeWidth: 3,
                                ),
                              )
                            else
                              CustomButton(
                                size: ButtonSize.large,
                                text: "Verify OTP",
                                onPressed: _verifyOTP,
                              ),
                            SizedBox(height: 24.h),
                            TextButton(
                              onPressed: _resendSeconds == 0
                                  ? () {
                                setState(() => _resendSeconds = 120); // Reset to 2 minutes
                                _startResendTimer();
                                _resendOTP();
                              }
                                  : null,
                              child: Text(
                                _resendSeconds == 0
                                    ? "Resend Code"
                                    : "Resend Code in ${_formatTimer(_resendSeconds)}", // Show MM:SS format
                                style: TextStyle(
                                  color: _resendSeconds == 0
                                      ? colorScheme.primary
                                      : colorScheme.onSurface.withOpacity(0.5),
                                  fontSize: 16.sp,
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
          ),
        ],
      ),
    );
  }

  Future<void> _verifyOTP() async {
    if (!_inputOTPFormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userProvider = Provider.of<UserServiceProvider>(context, listen: false);
      ResponseResult resp = await userProvider.emailVerification(context, widget.preRegisterDetails.email, otp!);
      if (!mounted) return;

      if (resp.status == ResponseStatus.failed) {
        await CustomPopup.show(
          backgroundColor: colorScheme.onPrimary,
          type: PopupType.error,
          title: "Verification Failed",
          message: "${resp.message}.",
          context: context,
        );
      } else {
        if (!mounted) return;

        // Show success popup without waiting
        CustomPopup.show(
          backgroundColor: colorScheme.onPrimary,
          type: PopupType.success,
          title: "Verification Successful",
          message: "${resp.message}.",
          context: context,
        );

        Future.delayed(const Duration(milliseconds: 1800), () {
          if (mounted) {
            context.goNamed("login");
          }
        });
      }
    } catch (e) {
      if (!mounted) return;
      await CustomPopup.show(
        backgroundColor: colorScheme.onPrimary,
        type: PopupType.error,
        title: "Error",
        message: "An unexpected error occurred. Please try again later. $e",
        context: context,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resendOTP() async {
    setState(() => _isLoading = true);

    try {
      final userProvider = Provider.of<UserServiceProvider>(context, listen: false);
      ResponseResult resp = await userProvider.resendOtp(context, widget.preRegisterDetails.email);

      if (!mounted) return;

      if (resp.status == ResponseStatus.failed) {
        await CustomPopup.show(
          backgroundColor: colorScheme.onPrimary,
          type: PopupType.error,
          title: "Resend Failed",
          message: "${resp.message}.",
          context: context,
        );
      } else {
        await CustomPopup.show(
          backgroundColor: colorScheme.onPrimary,
          type: PopupType.success,
          title: "OTP Sent",
          message: "A new OTP has been sent to your email.",
          context: context,
        );
      }
    } catch (e) {
      await CustomPopup.show(
        backgroundColor: colorScheme.onPrimary,
        type: PopupType.error,
        title: "Error",
        message: "An unexpected error occurred. Please try again later.",
        context: context,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}