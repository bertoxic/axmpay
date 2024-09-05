import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:fintech_app/main.dart';
import 'package:fintech_app/models/ResponseModel.dart';
import 'package:fintech_app/providers/user_service_provider.dart';
import 'package:fintech_app/ui/widgets/custom_buttons.dart';
import 'package:fintech_app/ui/widgets/custom_responsive_sizes/responsive_size.dart';
import 'package:fintech_app/ui/widgets/custom_text/custom_apptext.dart';
import 'package:fintech_app/utils/form_validator.dart';
import 'package:fintech_app/ui/widgets/custom_dialog.dart';
import 'package:fintech_app/ui/widgets/custom_textfield.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String email;
  const OTPVerificationScreen({Key? key, required this.email}) : super(key: key);

  @override
  _OTPVerificationScreenState createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  final _inputOTPFormKey = GlobalKey<FormState>();
  String? otp;

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
        print('OTP entered: $otp');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserServiceProvider>(context, listen: false);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child:  Container(
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [colorScheme.primary, colorScheme.secondary],
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 40.h),
                  Icon(Icons.lock_outline, size: 80, color: colorScheme.onPrimary),
                  SizedBox(height: 24.h),
                  AppText.headline("OTP Verification", color: Colors.grey.shade300,),
                  SizedBox(height: 16.h),
                  AppText.body(
                    "Please enter the 6-digit code sent to:",
                    textAlign: TextAlign.center,
                    color: Colors.grey.shade300,
                  ),
                  SizedBox(height: 8.h),
                  AppText.body(
                    widget.email,
                    color: Color(0xebcacdff),
                  ),
                  SizedBox(height: 40.h),
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
                  SizedBox(height: 40.h),
                  CustomButton(
                    size: ButtonSize.large,
                    text: "Verify OTP",
                    onPressed: () async {
                      if (_inputOTPFormKey.currentState!.validate()) {
                        try {
                          final resp = await userProvider.verifyOTPForPasswordChange(context, widget.email, otp!);
                          if (resp.status == "failed") {
                            await CustomPopup.show(
                              backgroundColor: colorScheme.error,
                              type: PopupType.error,
                              title: "Verification Failed",
                              message: "The OTP you entered is incorrect. Please try again.",
                              context: context,
                            );
                          } else {
                            context.pushNamed("/login");
                          }
                        } catch (e) {
                          await CustomPopup.show(
                            backgroundColor: colorScheme.error,
                            type: PopupType.error,
                            title: "Error",
                            message: "An unexpected error occurred. Please try again later.",
                            context: context,
                          );
                        }
                      }
                    },
                  ),
                  SizedBox(height: 24.h),
                  TextButton(
                    onPressed: () {
                      // TODO: Implement resend OTP functionality
                    },
                    child: Text(
                      "Resend OTP",
                      style: TextStyle(color: colorScheme.primary),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}