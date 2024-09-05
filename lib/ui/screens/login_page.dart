
import 'package:fintech_app/ui/widgets/custom_responsive_sizes/responsive_size.dart';
import 'package:fintech_app/ui/widgets/custom_text/custom_apptext.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:fintech_app/constants/text_constants.dart';
import 'package:fintech_app/ui/widgets/custom_buttons.dart';
import 'package:fintech_app/ui/widgets/custom_container.dart';
import 'package:fintech_app/ui/widgets/custom_textfield.dart';

import '../../main.dart';
import '../../models/user_model.dart';
import '../../providers/authentication_provider.dart';

class LoginPage extends StatefulWidget {

   LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

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
                         padding: const EdgeInsets.symmetric(horizontal: 20),
                         child: AppText.subtitle("welcome back"),
                       )) ),
               SpacedContainer(
                 margin:  EdgeInsets.symmetric(horizontal: double.parse(20.w.toString())),
                   child: CustomTextField(
                     labelText: "Email",
                     hintText: "enter email address",
                       fieldName: Fields.email,
                     prefixIcon: const Icon(Icons.email_outlined),
                     controller: _emailController,
                   //  validator: (value)=>FormValidator.validate(value, ValidatorType.email,fieldName:Fields.email),
                   )
               ),
               SpacedContainer(
                 margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                  child: Center(
                    child: Row(
                      children: [
                        _isLoading? SizedBox(  height: 12.h, width: 12.w,
                            child: const CircularProgressIndicator(color: Colors.purple)):CustomButton(
                          onPressed:_isLoading?null: () async {
                            setState(() {
                              _isLoading = true;
                            });
                          if(_formKey.currentState!.validate()){
                          }
                          userdetails.email = _emailController.value.text;
                          userdetails.password = _passwordController.value.text;
                         var data = await authProvider.login(context, userdetails);
                         if(data!=null){
                          if( data["status"] == "Verified"){
                            context.goNamed("/home");
                          }else{
                            context.goNamed("user_details_page");
                          }
                         }
                              setState(() {
                                _isLoading=false;
                              });
                        },
                          type: ButtonType.elevated,
                          backgroundColor: colorScheme.primary,
                        text: "Login",
                        ),
                      ],
                    ),
                  ),
                ),
               Center(
                 child: GestureDetector(
                   onTap: () {
                     setState(() {
                       _isLoading = true;
                     });

                     _isLoading? const CircularProgressIndicator():SizedBox();
                     context.pushNamed("/change_password_screen");
                     setState(() {
                       _isLoading = false;
                     });
                   },
                   child: const Text(
                     'forgot password?',
                     style: TextStyle(
                       color: Colors.blue,
                     ),
                   ),
                 ),
               )
             ],
           ),
         ),
      ),
    );
  }
}
