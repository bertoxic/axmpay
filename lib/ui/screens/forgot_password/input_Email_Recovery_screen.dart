import 'package:fintech_app/main.dart';
import 'package:fintech_app/ui/widgets/custom_buttons.dart';
import 'package:fintech_app/ui/widgets/custom_dialog.dart';
import 'package:fintech_app/ui/widgets/custom_responsive_sizes/responsive_size.dart';
import 'package:fintech_app/ui/widgets/custom_text/custom_apptext.dart';
import 'package:fintech_app/ui/widgets/custom_textfield.dart';
import 'package:fintech_app/utils/form_validator.dart';
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
    final userProvider =
        Provider.of<UserServiceProvider>(context, listen: false);

    return Scaffold(
      body: Column(
        children: [
          Container(
            //  color: Colors.grey,
            height: 500.h,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0.w, vertical: 16.h),
            child: Form(
              key: _inputEmailFormKey,
              child: Container(
                width: 400.w,
                height: 240.h,
                padding: EdgeInsets.all(8.sp),
                decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.4),
                    borderRadius: const BorderRadius.all(Radius.circular(20))),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppText.title("Input Email Address here"),
                    Align(
                      alignment: Alignment.center,
                      child: AppText.caption(
                        "enter the email address associated with your account ",
                        style: const TextStyle(
                          overflow: TextOverflow.clip,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(
                      height: 20.h,
                    ),
                    Padding(
                      padding:
                          EdgeInsets.all(8.0.h).copyWith(bottom: 16.h, top: 0),
                      child: CustomTextField(
                        onChanged: (value) {
                          email = value;
                          print(email);
                        },
                        validator: (value) => FormValidator.validate(
                          value,
                          ValidatorType.email,
                          fieldName: "",
                        ),
                        fieldName: 'emailAddress',
                        hintText: "enter email address",
                      ),
                    ),
                    CustomButton(
                      text: "Recover Password",
                      size: ButtonSize.large,
                      onPressed: () async{
                        if (!mounted) return;
                        String? status;
                        try{
                           status = await userProvider.sendVerificationCode(context, email!);
                           if(status.toString() !="failed"){
                             if (!mounted) return;
                              await CustomPopup.show(backgroundColor:colorScheme.onBackground,type: PopupType.error ,title: "Check your email", message: "Inputted Email address was not found in the database", context: context);
                           }
                          if (_inputEmailFormKey.currentState!.validate()) {
                            if (!mounted) return;
                            context.pushNamed("/forgot_password_otp",
                              pathParameters: {'email': email!},
                            );

                          }("/forgot_password_otp");

                      }catch(e) {
                          if (!mounted) return;
                        }
                        if (_inputEmailFormKey.currentState!.validate()) {
                          context.pushNamed("/forgot_password_otp",
                            pathParameters: {'email': email!},
                          );
                        }("/forgot_password_otp");
                      },
                    ),
                    SizedBox(
                      height: 16.h,
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
