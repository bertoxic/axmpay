import 'package:AXMPAY/models/ResponseModel.dart';
import 'package:AXMPAY/ui/screens/registration/registration_controller.dart';
import 'package:AXMPAY/ui/widgets/custom_buttons.dart';
import 'package:AXMPAY/ui/widgets/custom_dialog.dart';
import 'package:AXMPAY/ui/widgets/custom_dropdown.dart';
import 'package:AXMPAY/ui/widgets/custom_responsive_sizes/responsive_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:AXMPAY/constants/app_colors.dart';

import '../../../constants/text_constants.dart';
import '../../../main.dart';
import '../../../models/user_model.dart';
import '../../../providers/authentication_provider.dart';
import '../../widgets/custom_container.dart';
import '../../widgets/custom_text/custom_apptext.dart';
import '../../widgets/custom_textfield.dart';

class UpdateUserDetailsPage extends StatefulWidget {

  const UpdateUserDetailsPage({super.key});

  @override
  State<UpdateUserDetailsPage> createState() => _UpdateUserDetailsPageState();
}

class _UpdateUserDetailsPageState extends State<UpdateUserDetailsPage> {

  final _formKey = GlobalKey<FormState>();
  late RegistrationController _controller;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = RegistrationController(context);
  }
  @override
  void dispose() {
    // TODO: implement dispose
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
     DateTime selectedDate;
    UserDetails  userdetails = UserDetails(
        firstName: "",
        lastName:"",
        dateOfBirth: "",
        email: "",
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
                                child: AppText.body("Basic information",),),
                            ),

                            SpacedContainer(
                              child: CustomTextField(
                                labelText: 'First Name',
                                hintText: 'Enter your First Name',
                                // decoration: InputDecoration(
                                //
                                //     enabledBorder: OutlineInputBorder(
                                //       borderRadius: BorderRadius.circular(20.0),
                                //       borderSide: const BorderSide(color: AppColors.lightgrey),
                                //     ),
                                //     focusedBorder: OutlineInputBorder(
                                //       borderRadius: BorderRadius.circular(20.0),
                                //       borderSide: const BorderSide(color: Colors.green),
                                //     ),
                                //     errorBorder: OutlineInputBorder(
                                //       borderRadius: BorderRadius.circular(20.0),
                                //       borderSide: const BorderSide(color: Colors.red),
                                //     ),
                                //     fillColor: AppColors.lightgrey,
                                //     filled: true
                                // ),
                                validator: null,
                                controller:  _controller.first_name,
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
                                controller:  _controller.last_name,
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
                                onChanged: (value){
                                  userdetails.email = value;
                                },
                                keyboardType: TextInputType.emailAddress,
                                fieldName: Fields.email,
                                controller: _controller.emailController,
                                // validator: (value)=>FormValidator.validate(value, ValidatorType.email,fieldName: Fields.email),
                              ),
                            ),
                            SpacedContainer(
                              child: CustomTextField(
                                border: InputBorder.none,
                                labelText: 'Phone',
                                hintText: 'Enter phone number',
                                prefixIcon: const Icon(Icons.phone),

                                obscureText: true, fieldName: Fields.password,
                                onChanged: (value){
                                  userdetails.phone = value;
                                },
                                controller: _controller.phone_number,
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
                                controller: _controller.state,
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
                                controller: _controller.city,
                                validator:null,
                                prefixIcon: const Icon(Icons.location_city), fieldName: Fields.name,
                                onChanged: (value){
                                  userdetails.address?.city = value;
                                },

                              ),
                            ),
                            SpacedContainer(
                              child: CustomTextField(
                                labelText: 'Street address',
                                hintText: 'Enter street name and number',
                                controller: _controller.street_address,
                                prefixIcon: const Icon(Icons.location_searching_outlined),
                                onChanged: (value){
                                  userdetails.address?.street = value;
                                },
                                keyboardType: TextInputType.text,
                                fieldName: Fields.email,
                                // validator: (value)=>FormValidator.validate(value, ValidatorType.email,fieldName: Fields.email),
                              ),
                            ),
                            SpacedContainer(
                              child: CustomTextField(
                                labelText: 'country',
                                hintText: 'country',
                                prefixIcon: const Icon(Icons.location_on),
                                controller: _controller.country,
                                onChanged: (value){
                                },
                                keyboardType: TextInputType.text,
                                fieldName: "country",
                                // validator: (value)=>FormValidator.validate(value, ValidatorType.email,fieldName: Fields.email),
                              ),
                            ),

                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h,), Container(
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
                                child: GestureDetector(
                                    onTap: (){
                                      _controller.selectDate(context);
                                    },child: AppText.body("Personal information",)),),
                            ),

                            SpacedContainer(
                              child: DatePickerTextField(context: context,onChange:(value){
                                    print(value);
                              }, dateController: _controller.date_of_birth,),
                            ),
                            SpacedContainer(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(18)
                                ),
                                child: CustomDropdown(
                                  initialValue: "Please pick your gender",
                                  itemBuilder: (item){
                                    return Padding(
                                      padding: EdgeInsets.all(8.sp),
                                      child: Row(
                                        children: [
                                          AppText.body(item),
                                        ],
                                      ),
                                    );
                                  },
                                  onChanged: (newValue) {
                                    setState(() {
                                        _controller.gender.text = newValue??"select value"!;
                                    });
                                  },
                                  selectedItemBuilder: (item) => Text(item),
                                  items: const <String>["Male","Female"],
                                ),
                              )
                            ),
                            SpacedContainer(
                              child: CustomTextField(
                                labelText: 'BVN',
                                hintText: 'input your valid BVN',

                                validator:null,
                                prefixIcon: const Icon(Icons.perm_identity), fieldName: Fields.name,
                                onChanged: (value){
                                },
                                controller: _controller.bvn,
                              ),
                            ),
                            SpacedContainer(
                              child: CustomTextField(
                                labelText: 'place of birth',
                                hintText: 'your place of birth',

                                validator:null,
                                prefixIcon: const Icon(Icons.location_on), fieldName: Fields.name,
                                onChanged: (value){
                                  userdetails.nin = value;
                                },
                                  controller: _controller.placeOfBirthController,
                              ),
                            ),
                            SpacedContainer(
                              child: CustomTextField(
                                labelText: 'referrer id',
                                hintText: 'who referred you',

                                validator:null,
                                prefixIcon: const Icon(Icons.man_3_outlined), fieldName: Fields.name,
                                onChanged: (value){
                                  userdetails.nin = value;
                                },
                                  controller: _controller.refby,
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
                                borderRadius: 12, //pirkofalto@gufum.com
                                isLoading: false,
                                isDisabled: false,
                                type: ButtonType.elevated,
                                onPressed: ()async{
                                ResponseResult? resp = await _controller.createNewUserWallet();
                                if(resp?.status == ResponseStatus.failed){
                                  CustomPopup.show(context: context, title: resp?.status.toString()??"error", message: resp?.message??"an error occured");
                                }else if(resp?.status==ResponseStatus.success){
                                 CustomPopup.show(context: context, title: resp?.status.toString()??"success", message: resp?.message??"");
                                 await  Future.delayed(Duration(seconds: 1));
                                 final storage = FlutterSecureStorage();
                                 bool hasPasscode = await storage.read(key: 'passcode')==null;
                                 if (hasPasscode) {
                                   if(!mounted) return;
                                   context.pushNamed("passcode_setup_screen");
                                 }else if(!hasPasscode){
                                   if(!mounted) return;
                                   context.goNamed("/home");
                                 }

                                }
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
      ),
    );

  }
}


class DatePickerTextField extends StatefulWidget {
  BuildContext context;
  Function(String?) onChange;
   TextEditingController dateController;
  String? Function(String?)? validator;
   DatePickerTextField({super.key,
     required this.context,
     required this.onChange,
     required this.dateController,
     this.validator,
   });

  @override
  _DatePickerTextFieldState createState() => _DatePickerTextFieldState();
}

class _DatePickerTextFieldState extends State<DatePickerTextField> {
  DateTime? _selectedDate;

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        widget.dateController.text = DateFormat('dd/MM/yyyy').format(_selectedDate!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: widget.dateController,
      labelText: 'Date of birth',
      prefixIcon: Icon(Icons.calendar_today),
      suffixIcon: Icon(Icons.arrow_drop_down),
      hintText: _selectedDate != null? _selectedDate.toString():'YYYY-MM-DD',
      readOnly: true,
      onTap: _selectDate,
      validator: validator,
      // onChanged: ,
      fieldName: '',
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