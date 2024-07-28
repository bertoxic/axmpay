import 'dart:async';

import 'package:fintech_app/ui/%20widgets/custom_responsive_sizes/responsive_size.dart';
import 'package:fintech_app/ui/%20widgets/custom_text/custom_apptext.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:fintech_app/constants/text_constants.dart';
import 'package:fintech_app/ui/%20widgets/custom_buttons.dart';
import 'package:fintech_app/ui/%20widgets/custom_container.dart';
import 'package:fintech_app/ui/%20widgets/custom_textfield.dart';
import 'package:fintech_app/utils/form_validator.dart';

import '../../constants/app_colors.dart';
import '../../main.dart';
import '../../models/user_model.dart';
import '../../providers/authentication_provider.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
   LoginPage({super.key});
  @override
  Widget build(BuildContext context) {
     LoginDetails userdetails =LoginDetails(email: "oyehbaze@gmail.com", password: "1234");
    final authProvider = Provider.of<AuthenticationProvider>(context);
    return  Form(
      key: _formKey,
      child: Scaffold(
        appBar: AppBar(title: const Text("Signin to your account"),),
         body:  Container(
           margin: EdgeInsets.all(12.sp).copyWith(top: 40.sp),
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),

        color: colorScheme.primaryContainer,),
           child: Column(
             mainAxisSize: MainAxisSize.min,
             children: [
                SpacedContainer(
                   child: Align(
                     alignment: Alignment.topLeft,
                       child: Padding(
                         padding: EdgeInsets.symmetric(horizontal: 20),
                         child: AppText.subtitle("welcome back"),
                       )) ),
               SpacedContainer(
                 margin:  EdgeInsets.symmetric(horizontal: double.parse(20.w.toString())),
                   child: CustomTextField(
                     labelText: "Email",
                     hintText: "enter email address",
                       fieldName: Fields.email,
                     prefixIcon: Icon(Icons.email_outlined),
                     controller: _emailController,
                   //  validator: (value)=>FormValidator.validate(value, ValidatorType.email,fieldName:Fields.email),
                   )
               ),
               SpacedContainer(
                 margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                   child: CustomTextField(
                     fieldName: Fields.password,
                     hintText: "enter password",
                     labelText: "password",
                     prefixIcon: const Icon(Icons.lock),
                     controller: _passwordController,
                     //validator: (value)=>FormValidator.validate(value, ValidatorType.password,fieldName:Fields.password),

                   )
               ),
                SpacedContainer(
                margin:  EdgeInsets.symmetric(horizontal: 20.w),
                  child: Row(
                    children: [
                      Expanded(
                        child: CustomButton(onPressed: (){
                          if(_formKey.currentState!.validate()){}
                          userdetails.email = _emailController.value.text;
                          userdetails.password = _passwordController.value.text;
                          authProvider.Login(userdetails);

                          context.goNamed("/home");
                        },
                          type: ButtonType.elevated,
                          backgroundColor: Colors.green,
                        text: "Login",
                        ),
                      ),
                    ],
                  ),
                )
             ],
           ),
         ),
      ),
    );
  }
}
