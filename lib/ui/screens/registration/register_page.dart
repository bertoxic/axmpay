import 'dart:convert';

import 'package:fintech_app/main.dart';
import 'package:fintech_app/providers/user_service_provider.dart';
import 'package:fintech_app/ui/widgets/custom_responsive_sizes/responsive_size.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../constants/text_constants.dart';
import '../../../models/user_model.dart';
import '../../../providers/authentication_provider.dart';
import '../../widgets/custom_container.dart';
import '../../widgets/custom_text/custom_apptext.dart';
import '../../widgets/custom_textfield.dart';

class RegisterPage extends StatefulWidget {

  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameController = TextEditingController();

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  final TextEditingController _passwordController2 = TextEditingController();

   final TextEditingController _last_name = TextEditingController();

  final TextEditingController _first_name = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late UserServiceProvider userServiceProvider;
  PreRegisterDetails  registerDetails= PreRegisterDetails(lastName:"",firstName: "", password: "", email:"");
  String? passwordOne;

  bool isLoading= false;
  @override
  void initState() {
    // TODO: implement initState
    WidgetsBinding.instance.addPostFrameCallback((_)=>
    userServiceProvider = Provider.of<UserServiceProvider>(context,listen: false));
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    AuthenticationProvider authProvider = Provider.of<AuthenticationProvider>(context);
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
                          controller: _first_name,
                          validator: null,
                          prefixIcon: const Icon(Icons.person), fieldName: Fields.name,
                          onChanged: (value){
                            registerDetails.firstName = value;
                          },

                        ),
                      ),
                      SpacedContainer(
                        child: CustomTextField(
                          labelText: 'Last Name',
                          hintText: 'Enter your Last Name',
                          controller: _last_name,
                          validator:null,
                          prefixIcon: const Icon(Icons.person), fieldName: Fields.name,
                          onChanged: (value){
                            registerDetails.lastName = "${registerDetails.firstName} $value";
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
                    prefixIcon: const Icon(Icons.lock),
                    obscureText: true, fieldName: Fields.password,
                    onChanged: (value){
                      passwordOne = value;
                    },
                    controller: _passwordController,
                   // validator: (value) => FormValidator.validate(value, ValidatorType.password, fieldName: "password"),
                  ),
                ),
                SpacedContainer(
                  child: CustomTextField(
                    border: InputBorder.none,
                    labelText: 'confirm Password',
                    hintText: 'Confirm password',
                    prefixIcon: const Icon(Icons.lock_clock_rounded),
                    obscureText: true, fieldName: Fields.password,
                    validator: (value)=>checkInputtedPassword(value,passwordOne),
                    onChanged: (value){
                      registerDetails.password = value;
                    },
                    controller: _passwordController2,
                   // validator: (value) => FormValidator.validate(value, ValidatorType.password, fieldName: "password"),
                  ),
                ),
                 SizedBox(height: 80.h),
                SpacedContainer(
                  margin:  EdgeInsets.symmetric(horizontal: 10.w,vertical: 10.h),
                  width: double.maxFinite,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                     //padding: const EdgeInsets.symmetric(vertical: 20),
                    ),
                    onPressed: isLoading ? null : () async {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          isLoading = true;
                        });

                        // Update registerDetails
                        registerDetails.firstName = _first_name.text;
                        registerDetails.lastName = _last_name.text;
                        registerDetails.email = _emailController.text;
                        registerDetails.password = _passwordController2.text;

                        final jsonString = jsonEncode(registerDetails.toJSON());

                        try {
                          String status = await userServiceProvider.createAccount(
                              context,
                              registerDetails
                          );

                          print(status);

                          if (mounted) {
                            context.pushNamed(
                              "verify_new_user_email_screen",
                              pathParameters: {'preRegistrationString': jsonString},
                            );
                          }
                        } catch (e) {
                          print('Error creating account: $e');
                          // Show an error message to the user
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to create account: $e')),
                          );
                        } finally {
                          if (mounted) {
                            setState(() {
                              isLoading = false;
                            });
                          }
                        }
                      } else {
                        print('Form is not valid');
                        ScaffoldMessenger.of(context).showSnackBar(
                           SnackBar(backgroundColor: colorScheme.onPrimary,
                              showCloseIcon: true,
                              content: Text('Please fill all fields correctly')),
                        );
                      }
                    },
                    child: isLoading
                        ?  Padding(
                            padding:  EdgeInsets.symmetric(vertical: 1.0.h),
                            child: SizedBox(  height: 24.h, width: 24.w,
                                child: CircularProgressIndicator(color: Colors.white)))
                        : Padding(
                          padding:  EdgeInsets.symmetric(vertical: 12.0.h),
                          child: const Text('Sign Up', style: TextStyle(color: Colors.white)),
                        ),
                  ),
                ),
                const SizedBox(height: 20),

                Center(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isLoading = true;
                      });

                      isLoading? const CircularProgressIndicator():SizedBox();
                      context.pushNamed("/login");
                      setState(() {
                        isLoading = false;
                      });
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

String? checkInputtedPassword(String? value, String? passwordOne){
  if(value != passwordOne){
    return "passwords should be the same";
  }else  if (value == null || value.isEmpty) {
    return 'Please enter some text';
  }
  return null;
}