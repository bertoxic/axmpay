import 'package:AXMPAY/main.dart';
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

class _InputEmailRecoveryState extends State<InputEmailRecovery> {
  final _inputEmailFormKey = GlobalKey<FormState>();
  String? email;

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserServiceProvider>(context, listen: false);

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [colorScheme.primary, colorScheme.secondary],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 40.h),
                  Icon(
                    Icons.lock_reset,
                    size: 80.sp,
                    color: colorScheme.onPrimary,
                  ),
                  SizedBox(height: 24.h),
                  AppText.title(
                    "Password Recovery",
                    style: TextStyle(
                      color: colorScheme.onPrimary,
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  AppText.caption(
                    "Enter the email address associated with your account",
                    style: TextStyle(
                      color: colorScheme.onPrimary.withOpacity(0.8),
                      fontSize: 16.sp,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 40.h),
                  Form(
                    key: _inputEmailFormKey,
                    child: Container(
                      padding: EdgeInsets.all(24.sp),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          CustomTextField(
                            onChanged: (value) {
                              email = value;
                            },
                            validator: (value) => FormValidator.validate(
                              value,
                              ValidatorType.email,
                              fieldName: "Email",
                            ),
                            fieldName: 'emailAddress',
                            hintText: "Enter email address",
                            prefixIcon: Icon(Icons.email, color: colorScheme.primary),
                          ),
                          SizedBox(height: 24.h),
                          CustomButton(
                            text: "Recover Password",
                            size: ButtonSize.large,
                            onPressed: () async {
                              if (_inputEmailFormKey.currentState!.validate()) {
                                try {
                                  String? status = await userProvider.sendVerificationCode(context, email!);
                                  if (status.toString() != "failed") {
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
                                      title: "Email Not Found",
                                      message: "The email address was not found in our database.",
                                      context: context,
                                    );
                                  }
                                } catch (e) {
                                  context.pushNamed(
                                    "/forgot_password_otp",
                                    pathParameters: {'email': email!},
                                  );
                                  if (!mounted) return;
                                  await CustomPopup.show(
                                    backgroundColor: colorScheme.onPrimary,
                                    type: PopupType.error,
                                    title: "Error",
                                    message: "An unexpected error occurred. Please try again.$e",
                                    context: context,
                                  );
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  TextButton(
                    onPressed: () => context.pop(),
                    child: Text(
                      "Back to Login",
                      style: TextStyle(
                        color: colorScheme.onPrimary,
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
    );
  }
}