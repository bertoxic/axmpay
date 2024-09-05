import 'package:fintech_app/main.dart';
import 'package:fintech_app/models/ResponseModel.dart';
import 'package:fintech_app/models/user_model.dart';
import 'package:fintech_app/providers/user_service_provider.dart';
import 'package:fintech_app/ui/widgets/custom_buttons.dart';
import 'package:fintech_app/ui/widgets/custom_responsive_sizes/responsive_size.dart';
import 'package:fintech_app/ui/widgets/custom_text/custom_apptext.dart';
import 'package:fintech_app/utils/form_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../widgets/custom_dialog.dart';
import '../../widgets/custom_textfield.dart';

class NewUserOTPVerificationScreen extends StatefulWidget {
  final PreRegisterDetails preRegisterDetails;
  const NewUserOTPVerificationScreen({Key? key, required this.preRegisterDetails}) : super(key: key);

  @override
  _NewUserOTPVerificationScreenState createState() => _NewUserOTPVerificationScreenState();
}

class _NewUserOTPVerificationScreenState extends State<NewUserOTPVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  final _inputOTPFormKey = GlobalKey<FormState>();
  String? otp;
  bool _isLoading = false;

  @override
  void dispose() {
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserServiceProvider>(context, listen: false);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 40.h),
                Icon(Icons.lock_outline, size: 80.h, color: colorScheme.primary),
                SizedBox(height: 24.h),
                AppText.title(
                  "OTP Verification",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16.h),
                AppText.body(
                  "Please enter the 6-digit code sent to:",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16.sp, color: colorScheme.onSurface.withOpacity(0.7)),
                ),
                SizedBox(height: 8.h),
                AppText.body(
                  widget.preRegisterDetails.email,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: colorScheme.primary),
                ),
                SizedBox(height: 32.h),
                Form(
                  key: _inputOTPFormKey,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(
                      6,
                          (index) => SizedBox(
                        width: 50.w,
                        child: CustomTextField(
                          validator: (value) => FormValidator.validate(value, ValidatorType.digits, fieldName: "Digit ${index + 1}"),
                          controller: _controllers[index],
                          focusNode: _focusNodes[index],
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(1),
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: colorScheme.primary),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: colorScheme.primary, width: 2),
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
                _isLoading
                    ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
                    : CustomButton(
                  size: ButtonSize.large,
                  text: "Verify OTP",
                  onPressed: _verifyOTP,
                ),
                SizedBox(height: 24.h),
                TextButton(
                  onPressed: () {
                    // TODO: Implement resend OTP functionality
                  },
                  child: Text(
                    "Didn't receive the code? Resend",
                    style: TextStyle(color: colorScheme.primary, fontSize: 16.sp),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _verifyOTP() async {
    if (!_inputOTPFormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userProvider = Provider.of<UserServiceProvider>(context, listen: false);
      final resp = await userProvider.emailVerification(context, otp!);

      if (!mounted) return;

      if (resp.status.toString() == "failed") {
        await CustomPopup.show(
          backgroundColor: colorScheme.onPrimary,
          type: PopupType.error,
          title: "Verification Failed",
          message: "${resp.message}.",
          context: context,
        );
      } else {
        context.pushNamed("/login", pathParameters: {"email": widget.preRegisterDetails.email, "otp": otp!});
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