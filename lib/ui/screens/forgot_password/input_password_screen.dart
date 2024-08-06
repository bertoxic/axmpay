import 'package:fintech_app/ui/%20widgets/custom_buttons.dart';
import 'package:fintech_app/ui/%20widgets/custom_responsive_sizes/responsive_size.dart';
import 'package:fintech_app/ui/%20widgets/custom_text/custom_apptext.dart';
import 'package:fintech_app/ui/%20widgets/custom_textfield.dart';
import 'package:flutter/cupertino.dart';

class InputPassword extends StatelessWidget {
  const InputPassword({super.key});

  @override
  Widget build(BuildContext context) {
    return  Column(
      children: [
        Container(
          height: 400.h,
        ),
        Column(
          children: [
            AppText.body("Add Email Address here"),
            AppText.caption("enter the email address associated with your account "),
            SizedBox(height: 20.h,),
             const CustomTextField(fieldName: 'emailAddress'),
            const CustomButton(text: "Recover Password"),
          ],
        )
      ],
    );
  }
}
