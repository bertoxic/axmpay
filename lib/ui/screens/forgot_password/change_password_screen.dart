import 'package:fintech_app/ui/widgets/custom_responsive_sizes/responsive_size.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../main.dart';
import '../../../providers/user_service_provider.dart';
import '../../../utils/form_validator.dart';
import '../../widgets/custom_buttons.dart';
import '../../widgets/custom_dialog.dart';
import '../../widgets/custom_text/custom_apptext.dart';
import '../../widgets/custom_textfield.dart';

class ChangePasswordScreen extends StatefulWidget {
  final String email;
  final String otp;
   const ChangePasswordScreen({super.key, required this.email, required this.otp});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}
class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
   String? password1;
   String? password2;
  final _inputPasswordFormKey = GlobalKey<FormState>();
  late final TextEditingController passOneController;
  late final TextEditingController passTwoController;
   late final UserServiceProvider userProvider;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
     userProvider = Provider.of<UserServiceProvider>(context, listen: false);
    passOneController = TextEditingController();
    passTwoController = TextEditingController();

  }

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
              key: _inputPasswordFormKey,
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
                        controller: passOneController,
                        validator: (value) => FormValidator.validate(
                          value,
                          ValidatorType.name,
                          fieldName: "password",
                        ),
                        fieldName: "password",
                        hintText: "enter password",
                        onChanged: (value){
                          password1 = passOneController.value.text;
                          print(password1);
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0.h).copyWith(bottom: 16.h,top: 0),
                      child: CustomTextField(
                        controller: passTwoController,
                        validator: (value) => checkInputtedPassword(value, password1),
                        fieldName: 'confirm_password',
                        hintText: "confirm your password",
                        onChanged: (value){
                          password2 = passTwoController.value.text;
                          print(password2);
                        },
                      ),
                    ),
                    CustomButton(
                      text: "Reset Password",
                      size: ButtonSize.large,
                      onPressed:() async {
                        if (!mounted) return;
                        String? status;
                        try{
                          status = await userProvider.changeUserPassword(context, widget.email, widget.otp, "");
                          if(status.toString() =="failed"){
                            if (!mounted) return;
                            await CustomPopup.show(backgroundColor:colorScheme.onBackground,type: PopupType.error ,title: "an Error occurred", message: "email or otp might be wrong", context: context);
                          }else{
                          if (_inputPasswordFormKey.currentState!.validate()) {
                            if (!mounted) return;
                            await CustomPopup.show(backgroundColor:colorScheme.onBackground,type: PopupType.success ,title: "password change Success", message: "your password has been updated", context: context);
                            if (!mounted) return;
                            Future.delayed(const Duration( seconds: 2));
                            context.pushNamed("/login");
                          }

                        }}catch(e) {
                          if (!mounted) return;
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
   String? checkInputtedPassword(String? value, String? passwordOne){
     if(value != passwordOne){
       return "passwords should be the same";
     }else  if (value == null || value.isEmpty) {
       return 'Please enter some text';
     }
     return null;
   }
}


