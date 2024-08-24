import 'package:fintech_app/main.dart';
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

class OTPVerificationScreen extends StatefulWidget {
  final String email;
  const OTPVerificationScreen({super.key, required this.email});
  @override
  _OTPVerificationScreenState createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
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
      if (index < 3) {
        _focusNodes[index + 1].requestFocus();
      } else {
         otp = _controllers.map((c) => c.text).join();
        print('otp entered: $otp');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserServiceProvider>(context, listen: false);

    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 500.h,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0.w, vertical: 16.h),
            child: Form(
              key: _inputOTPFormKey,
              child: Container(
                width: 400.w,
                height: 240.h,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.4),
                    borderRadius:  const BorderRadius.all(Radius.circular(20))
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AppText.title("Enter Otp code"),
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  AppText.body("Please input code sent to your email:"),
                                      AppText.body(widget.email,color: colorScheme.onBackground,),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        4,
                            (index) => Container(
                          width: 50,
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          child: CustomTextField(
                            validator: (value)=>FormValidator.validate(value, ValidatorType.digits,fieldName: "$index"),
                            controller: _controllers[index],
                            focusNode: _focusNodes[index],
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(1),
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (_) => _onChanged(index), fieldName: '$index',
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 30.h,),
                     CustomButton(size: ButtonSize.large,
                      text: "confirm",
                      onPressed: ()async{

                       if (!mounted) return;
                       String? status;
                       try{
                         status = await userProvider.verifyOTPForPasswordChange(context, widget.email, otp!);
                         if(status.toString() !="failed"){
                           if (!mounted) return;
                           await CustomPopup.show(backgroundColor:colorScheme.onBackground,type: PopupType.error ,title: "Check your email", message: "Inputted otp might be wrong", context: context);
                         }
                         if (_inputOTPFormKey.currentState!.validate()) {
                           if (!mounted) return;
                           context.pushNamed("/change_password_screen",
                             pathParameters: {"email":widget.email, "otp":otp!}
                           );

                         }("/change_password_screen");

                       }catch(e) {
                         if (!mounted) return;
                       }
                       if (_inputOTPFormKey.currentState!.validate()) {
                         if (!mounted) return;
                         context.pushNamed("/change_password_screen",
                             pathParameters: {"email":widget.email, "otp":otp!}
                         );
                       }

                       if (otp!=null) {
                         if (otp?.length != 4){
                         }
              }
                       context.pushNamed("/change_password_screen");
                       }                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       ,)
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}