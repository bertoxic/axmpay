import 'package:fintech_app/ui/widgets/custom_buttons.dart';
import 'package:fintech_app/ui/widgets/custom_dialog.dart';
import 'package:fintech_app/ui/widgets/custom_responsive_sizes/responsive_size.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:fintech_app/constants/app_colors.dart';

import '../../constants/text_constants.dart';
import '../../main.dart';
import '../../models/user_model.dart';
import '../../providers/authentication_provider.dart';
import '../widgets/custom_container.dart';
import '../widgets/custom_text/custom_apptext.dart';
import '../widgets/custom_textfield.dart';

class UpdateUserDetailsPage extends StatelessWidget {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _date_of_birth = TextEditingController();
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

  UpdateUserDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    UserDetails  userdetails = UserDetails(
        firstName: _first_name.value.text??"",
        lastName: _last_name.value.text??"",
        dateOfBirth: _date_of_birth.value.text??"",
        email: _emailController.value.text??"",
       );
    final authProvider = Provider.of<AuthenticationProvider>(context);
    return Form(
      key: _formKey,
      child: Scaffold(
        appBar: AppBar(title: const Text('Create your account')),
        body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              height: 1200.h,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:<Widget> [
                    Container(
                      decoration: BoxDecoration(
                          color:  colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(20.w)
                      ),
                      child: SpacedContainer(
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.h),
                                child: AppText.body("Personnal information",),),
                            ),

                            SpacedContainer(
                              child: CustomTextField(
                                labelText: 'First Name',
                                hintText: 'Enter your First Name',
                                decoration: InputDecoration(

                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                      borderSide: const BorderSide(color: AppColors.lightgrey),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                      borderSide: const BorderSide(color: Colors.green),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                      borderSide: const BorderSide(color: Colors.red),
                                    ),
                                    fillColor: AppColors.lightgrey,
                                    filled: true
                                ),
                                validator: null,
                                prefixIcon: const Icon(Icons.person), fieldName: Fields.name,
                                onChanged: (value){
                                  userdetails.firstName = value;
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
                                      borderSide: const BorderSide(color: AppColors.lightgrey),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                      borderSide: const BorderSide(color: Colors.green),
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
                                  userdetails.lastName = value;
                                },

                              ),
                            ),
                            SpacedContainer(
                              child: CustomTextField(
                                labelText: 'Email',
                                hintText: 'Enter your email',
                                prefixIcon: const Icon(Icons.email_outlined),
                                decoration: InputDecoration(

                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                      borderSide: const BorderSide(color: AppColors.lightgrey),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: const BorderSide(color: Colors.green),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                      borderSide: const BorderSide(color: Colors.red),
                                    ),
                                    fillColor: AppColors.lightgrey,
                                    filled: true
                                ),
                                onChanged: (value){
                                  userdetails.email = value;
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
                                labelText: 'Phone',
                                hintText: 'Enter phone number',
                                prefixIcon: const Icon(Icons.phone),
                                decoration: InputDecoration(
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                      borderSide: const BorderSide(color: Colors.red),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                      borderSide: const BorderSide(color: AppColors.lightgrey),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: const BorderSide(color: Colors.green),
                                    ),
                                    fillColor: AppColors.lightgrey,
                                    filled: true
                                ),
                                obscureText: true, fieldName: Fields.password,
                                onChanged: (value){
                                  userdetails.phone = value;
                                },
                                controller: _phone_number,
                                // validator: (value) => FormValidator.validate(value, ValidatorType.password, fieldName: "password"),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h,),
                    Container(
                      decoration: BoxDecoration(
                          color:  colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(20.w)
                      ),
                      child: SpacedContainer(
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.h),
                                child: AppText.body("Address",),),
                            ),

                            SpacedContainer(
                              child: CustomTextField(
                                labelText: 'State',
                                hintText: 'name of state',
                                decoration: InputDecoration(

                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                      borderSide: const BorderSide(color: AppColors.lightgrey),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                      borderSide: const BorderSide(color: Colors.green),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                      borderSide: const BorderSide(color: Colors.red),
                                    ),
                                    fillColor: AppColors.lightgrey,
                                    filled: true
                                ),
                                validator: null,
                                prefixIcon: const Icon(Icons.location_history), fieldName: Fields.name,
                                onChanged: (value){
                                  userdetails.address?.state = value;
                                },

                              ),
                            ),
                            SpacedContainer(
                              child: CustomTextField(
                                labelText: 'City',
                                hintText: 'Enter name of your City',
                                decoration: InputDecoration(

                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                      borderSide: const BorderSide(color: AppColors.lightgrey),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                      borderSide: const BorderSide(color: Colors.green),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                      borderSide: const BorderSide(color: Colors.red),
                                    ),
                                    fillColor: AppColors.lightgrey,
                                    filled: true
                                ),
                                validator:null,
                                prefixIcon: const Icon(Icons.location_city), fieldName: Fields.name,
                                onChanged: (value){
                                  userdetails.address?.city = value;
                                },

                              ),
                            ),
                            SpacedContainer(
                              child: CustomTextField(
                                labelText: 'Street',
                                hintText: 'Enter street name and number',
                                prefixIcon: const Icon(Icons.location_searching_outlined),
                                decoration: InputDecoration(

                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                      borderSide: const BorderSide(color: AppColors.lightgrey),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: const BorderSide(color: Colors.green),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                      borderSide: const BorderSide(color: Colors.red),
                                    ),
                                    fillColor: AppColors.lightgrey,
                                    filled: true
                                ),
                                onChanged: (value){
                                  userdetails.email = value;
                                },
                                keyboardType: TextInputType.emailAddress,
                                fieldName: Fields.email,
                                controller: _emailController,
                                // validator: (value)=>FormValidator.validate(value, ValidatorType.email,fieldName: Fields.email),
                              ),
                            ),
                            SpacedContainer(
                              child: CustomTextField(
                                labelText: 'Zip',
                                hintText: 'Zip',
                                prefixIcon: const Icon(Icons.location_on),
                                decoration: InputDecoration(

                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                      borderSide: const BorderSide(color: AppColors.lightgrey),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: const BorderSide(color: Colors.green),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                      borderSide: const BorderSide(color: Colors.red),
                                    ),
                                    fillColor: AppColors.lightgrey,
                                    filled: true
                                ),
                                onChanged: (value){
                                  userdetails.email = value;
                                },
                                keyboardType: TextInputType.emailAddress,
                                fieldName: Fields.email,
                                controller: _emailController,
                                // validator: (value)=>FormValidator.validate(value, ValidatorType.email,fieldName: Fields.email),
                              ),
                            ),

                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h,),
                    Container(
                      decoration: BoxDecoration(
                          color:  colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(20.w)
                      ),
                      child: SpacedContainer(
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.h),
                                child: AppText.body("Financial Information",),),
                            ),

                            SpacedContainer(
                              child: CustomTextField(
                                labelText: 'Annual income',
                                hintText: 'amount yearly: e.g 20 000 000  ',
                                validator: null,
                                prefixIcon: const Icon(Icons.location_history), fieldName: Fields.name,
                                onChanged: (value){
                                  userdetails.income = int.parse(value);
                                },

                              ),
                            ),
                            SpacedContainer(
                              child: CustomTextField(
                                labelText: 'Employment status',
                                hintText: 'employment status',
                                validator:null,
                                prefixIcon: const Icon(Icons.location_city), fieldName: Fields.name,
                                onChanged: (value){
                                  userdetails.employmentStatus = value;
                                },

                              ),
                            ),


                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10.h,
                    ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                            SpacedContainer(
                              child: CustomButton(text: "Submit",
                              size: ButtonSize.large,
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                borderRadius: 12,
                                isLoading: false,
                                isDisabled: false,
                                type: ButtonType.elevated,
                                onPressed: (){
                                  print("object");
                                  CustomPopup.show(
                                      context: context, title: "Select  a new Page",
                                      message: "Do you want to move to the next page?",
                                    actions: [
                                      PopupAction(text: "no", onPressed: (){
                                       // context.goNamed("/home");
                                        context.pushNamed("/home");
                                      },color: Colors.green),
                                      PopupAction(text: "yes", onPressed: (){
                                        context.pushNamed("/home");
                                      }),
                                    ]
                                  );
                                },
                              ),
                            )
                        ],
                      )
                  ],
                ),
              ),
            )
        ),
        floatingActionButton: FloatingActionButton(onPressed: () {  },backgroundColor: Colors.orange, ),
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