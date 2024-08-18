import 'package:fintech_app/main.dart';
import 'package:fintech_app/ui/widgets/custom_responsive_sizes/responsive_size.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:fintech_app/constants/app_colors.dart';
import 'package:fintech_app/utils/form_validator.dart';

import '../../constants/text_constants.dart';
import '../../models/user_model.dart';
import '../../providers/authentication_provider.dart';
import '../widgets/custom_container.dart';
import '../widgets/custom_text/custom_apptext.dart';
import '../widgets/custom_textfield.dart';

class RegisterPage extends StatelessWidget {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordController2 = TextEditingController();
  final TextEditingController _Date_of_Birth = TextEditingController();
  final TextEditingController _first_name = TextEditingController();
  final TextEditingController _last_name = TextEditingController();
  final TextEditingController _middle_name = TextEditingController();
  final TextEditingController _phone_number = TextEditingController();
  final TextEditingController _NIN = TextEditingController();
  final TextEditingController _address = TextEditingController();
  final TextEditingController _city = TextEditingController();
  final TextEditingController _state = TextEditingController();
  final TextEditingController _zip_code = TextEditingController();
  final TextEditingController _employment_status = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  RegisterPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
     RegisterDetails  registerDetails= RegisterDetails(name: "", password: "", email:"");
    final authProvider = Provider.of<AuthenticationProvider>(context);
    return Form(
      key: _formKey,
      child: Scaffold(
        appBar: AppBar(title: const Text('Create your account')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: colorScheme.primaryContainer,
            ),
            height: 1200.h,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[

                SpacedContainer(child: Align(
                  alignment: Alignment.centerLeft,
                  child: AppText.body("Registration information"),
                )),
                      SpacedContainer(  
                        child: CustomTextField(
                          labelText: 'First Name',
                          hintText: 'Enter your First Name',
                          decoration: InputDecoration(
                        
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20.0),
                                borderSide: BorderSide(color: AppColors.lightgrey),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20.0),
                                borderSide: BorderSide(color: Colors.green),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20.0),
                                borderSide: BorderSide(color: Colors.red),
                              ),
                              fillColor: AppColors.lightgrey,
                              filled: true
                          ),
                          validator: null,
                          prefixIcon: const Icon(Icons.person), fieldName: Fields.name,
                          onChanged: (value){
                            registerDetails.name = value;
                          },
                        
                        ),
                      ),  
                      SpacedContainer(
                        child: CustomTextField(
                          labelText: 'Last Name',
                          hintText: 'Enter your Last Name',
                          decoration: InputDecoration(
                        
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20.0),
                                borderSide: BorderSide(color: AppColors.lightgrey),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20.0),
                                borderSide: BorderSide(color: Colors.green),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20.0),
                                borderSide: const BorderSide(color: Colors.red),
                              ),
                              fillColor: AppColors.lightgrey,
                              filled: true
                          ),
                          validator:null,
                          prefixIcon: const Icon(Icons.person), fieldName: Fields.name,
                          onChanged: (value){
                            registerDetails.name = value;
                          },
                        
                        ),
                      ),


                SpacedContainer(
                  child: CustomTextField(
                    labelText: 'Email',
                    hintText: 'Enter your email',
                    prefixIcon: const Icon(Icons.email_outlined),

                    onChanged: (value){
                      registerDetails.email = value;
                    },
                    keyboardType: TextInputType.emailAddress,
                    fieldName: Fields.email,
                    controller: _emailController,
                   // validator: (value)=>FormValidator.validate(value, ValidatorType.email,fieldName: Fields.email),
                  ),
                ),
                SpacedContainer(
                  child: CustomTextField(
                    border: InputBorder.none,
                    labelText: 'Password',
                    hintText: 'Enter password',
                    prefixIcon: Icon(Icons.lock),
                    decoration: InputDecoration(
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: BorderSide(color: Colors.red),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: BorderSide(color: AppColors.lightgrey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Colors.green),
                        ),
                        fillColor: AppColors.lightgrey,
                        filled: true
                    ),
                    obscureText: true, fieldName: Fields.password,
                    onChanged: (value){
                      registerDetails.password = value;
                    },
                    controller: _passwordController,
                   // validator: (value) => FormValidator.validate(value, ValidatorType.password, fieldName: "password"),
                  ),
                ),
                const SizedBox(height: 20),
                SpacedContainer(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: colorScheme.primary,padding: EdgeInsets.symmetric(vertical: 20)),
                    onPressed: () {
                    // authProvider.Register(registerDetails);

                        if (_formKey.currentState!.validate()) {
                          context.goNamed("/home");
                        } else {
                          print('Form is not valid');

                      };
                      print(registerDetails.toJSON());
                      // _emailController.clear();
                      // _passwordController.clear();
                      // _nameController.clear();
                    },
                    child: const Center(child: Text('Sign Up', style: TextStyle(color: Colors.white),)),

                  ),
                ),
                const SizedBox(height: 20),

                Center(
                  child: GestureDetector(
                    onTap: () {
                      context.pushNamed("/login");
                    },
                    child: const Text(
                      'Already have an account? Sign in',
                      style: TextStyle(
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          )
        ),

      ),
    );
  }
}

String? validator(String? input){
  if (input == null || input.isEmpty) {
    return "Name cannot be empty";
  }else{
    return null;
  }

}