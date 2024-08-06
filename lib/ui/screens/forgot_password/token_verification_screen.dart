import 'package:fintech_app/main.dart';
import 'package:fintech_app/ui/%20widgets/custom_buttons.dart';
import 'package:fintech_app/ui/%20widgets/custom_responsive_sizes/responsive_size.dart';
import 'package:fintech_app/ui/%20widgets/custom_text/custom_apptext.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OTPVerificationScreen extends StatefulWidget {
  @override
  _OTPVerificationScreenState createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  String? Otp;
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
         Otp = _controllers.map((c) => c.text).join();
        print('otp entered: $Otp');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('otp Verification'),
      ),
      body: Column(
        children: [
          Container(
            height: 400.h,
          ),
          Container(
            margin: EdgeInsets.all(16.h),
            width: 400.w,
            height: 240.h,
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.4),
                borderRadius:  const BorderRadius.all(Radius.circular(16))
            ),
            child: Padding(
              padding:  EdgeInsets.all(8.h).copyWith(top: 20.h),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Center(
                      child: AppText.body("Please input password sent to your email,"),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      4,
                          (index) => Container(
                        width: 50,
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        child: TextField(
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
                          onChanged: (_) => _onChanged(index),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30.h,),
                   CustomButton(size: ButtonSize.large,
                    text: "confirm",
                    onPressed: (){
                     if (Otp!=null) {
                       if (Otp?.length != 4){

                       }
            }
                     }                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       ,)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}