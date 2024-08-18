import 'package:fintech_app/ui/widgets/custom_responsive_sizes/responsive_size.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../main.dart';
import '../../../utils/form_validator.dart';
import '../../widgets/custom_buttons.dart';
import '../../widgets/custom_text/custom_apptext.dart';
import '../../widgets/custom_textfield.dart';

class ChangePasswordScreen extends StatelessWidget {
   ChangePasswordScreen({super.key});
  final _inputEmailFormKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return   Scaffold(
      body:  Column(
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
               // height: 240.h,
                padding: EdgeInsets.all(8.sp),
                decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.4),
                    borderRadius: const BorderRadius.all(Radius.circular(20))),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppText.title("Change Your  password "),
                    Align(
                      alignment: Alignment.center,
                      child: AppText.caption(
                        "enter the new password you intend to use ",
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
                      padding: EdgeInsets.all(8.0.h).copyWith(bottom: 16.h,top: 0),
                      child: CustomTextField(
                        validator: (value) => FormValidator.validate(
                          value,
                          ValidatorType.email,
                          fieldName: "",
                        ),
                        fieldName: 'password',
                        hintText: "enter password",
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0.h).copyWith(bottom: 16.h,top: 0),
                      child: CustomTextField(
                        validator: (value) => FormValidator.validate(
                          value,
                          ValidatorType.email,
                          fieldName: "",
                        ),
                        fieldName: 'confirm_password',
                        hintText: "confirm your password",
                      ),
                    ),
                    CustomButton(
                      text: "Reset Password",
                      size: ButtonSize.large,
                      onPressed:(){
                        if (_inputEmailFormKey.currentState!.validate()) {

                        }

                      } ,
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


