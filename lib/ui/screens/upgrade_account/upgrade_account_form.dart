import 'package:fintech_app/providers/user_service_provider.dart';
import 'package:fintech_app/ui/screens/upgrade_account/update_user_details_field.dart';
import 'package:fintech_app/ui/screens/upgrade_account/upgrade_account_controller.dart';
import 'package:fintech_app/ui/widgets/custom_buttons.dart';
import 'package:fintech_app/ui/widgets/custom_dialog.dart';
import 'package:fintech_app/ui/widgets/custom_responsive_sizes/responsive_size.dart';
import 'package:fintech_app/ui/widgets/file_picker/photo_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../constants/text_constants.dart';
import '../../../main.dart';
import '../../../models/user_model.dart';
import '../../../providers/authentication_provider.dart';
import '../../../utils/form_validator.dart';
import '../../widgets/custom_container.dart';
import '../../widgets/custom_text/custom_apptext.dart';
import '../../widgets/custom_textfield.dart';

class UpgradeAccountPage extends StatefulWidget {
  const UpgradeAccountPage({super.key});

  @override
  State<UpgradeAccountPage> createState() => _UpdateUserDetailsPageState();
}

class _UpdateUserDetailsPageState extends State<UpgradeAccountPage> {
  final _formKey = GlobalKey<FormState>();
  late UpgradeAccountController _controller;
  late UserServiceProvider userprovider;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = UpgradeAccountController(context);
     userprovider = Provider.of<UserServiceProvider>(context, listen: false);

  }

  @override
  Widget build(BuildContext context) {
    DateTime selectedDate;
    UserDetails userdetails = UserDetails(
      firstName: "",
      lastName: "",
      dateOfBirth: "",
      email: "",
    );
    final authProvider = Provider.of<AuthenticationProvider>(context);
    return Form(
      key: _formKey,
      child: Scaffold(
        appBar: AppBar(title: const Text('Update user details')),
        body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              height: 1200.h,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(20.w)),
                      child: SpacedContainer(
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 8.h, horizontal: 16.h),
                                child: AppText.body(
                                  "Basic information",
                                ),
                              ),
                            ),
                            SpacedContainer(
                              child: UpdateUserDetailsField(
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
                              fieldController: _controller.first_name,
                                prefixIcon: const Icon(Icons.person),
                                fieldName: Fields.name,
                                onChanged: (value) {
                                  userdetails.firstName = value;
                                },
                              ),
                            ),
                            SpacedContainer(
                              child: UpdateUserDetailsField(
                                labelText: 'Last Name',
                                hintText: 'Enter your Last Name',
                              fieldController: _controller.last_name,
                                validator: null,
                                prefixIcon: const Icon(Icons.person),
                                fieldName: Fields.name,
                                onChanged: (value) {
                                  userdetails.lastName = value;
                                },
                              ),
                            ),
                            SpacedContainer(
                              child: UpdateUserDetailsField(
                                labelText: 'Email',
                                hintText: 'Enter your email',
                                prefixIcon: const Icon(Icons.email_outlined),
                                 readOnly: true,
                                onChanged: (value) {
                                  userdetails.email = value;
                                },
                                keyboardType: TextInputType.emailAddress,
                                fieldName: Fields.email,
                              fieldController: _controller.emailController,
                                // validator: (value)=>FormValidator.validate(value, ValidatorType.email,fieldName: Fields.email),
                              ),
                            ),
                            SpacedContainer(
                              child: UpdateUserDetailsField(
                                labelText: 'Phone',
                                hintText: 'Enter phone number',
                                prefixIcon: const Icon(Icons.phone),
                                fieldName: Fields.password,
                                onChanged: (value) {
                                  userdetails.phone = value;
                                },
                              fieldController: _controller.phone_number,
                                // validator: (value) => FormValidator.validate(value, ValidatorType.password, fieldName: "password"),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10.h,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(20.w)),
                      child: SpacedContainer(
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 8.h, horizontal: 16.h),
                                child: AppText.body(
                                  "Address",
                                ),
                              ),
                            ),
                            SpacedContainer(
                              child: UpdateUserDetailsField(
                                labelText: 'State',
                                hintText: 'name of state',
                              fieldController: _controller.state,
                                validator: null,
                                prefixIcon: const Icon(Icons.location_history),
                                fieldName: Fields.name,
                                onChanged: (value) {
                                  userdetails.address?.state = value;
                                },
                              ),
                            ),
                            SpacedContainer(
                              child: UpdateUserDetailsField(
                                labelText: 'City',
                                hintText: 'Enter name of your City',
                              fieldController: _controller.city,
                                validator: null,
                                prefixIcon: const Icon(Icons.location_city),
                                fieldName: Fields.name,
                                onChanged: (value) {
                                  userdetails.address?.city = value;
                                },
                              ),
                            ),
                            SpacedContainer(
                              child: UpdateUserDetailsField(
                                labelText: 'Street address',
                                hintText: 'Enter street name and number',
                              fieldController: _controller.street_address,
                                prefixIcon: const Icon(
                                    Icons.location_searching_outlined),
                                onChanged: (value) {
                                  userdetails.address?.street = value;
                                },
                                keyboardType: TextInputType.text,
                                fieldName: Fields.email,
                                // validator: (value)=>FormValidator.validate(value, ValidatorType.email,fieldName: Fields.email),
                              ),
                            ),
                            SpacedContainer(
                              child: UpdateUserDetailsField(
                                labelText: 'country',
                                hintText: 'country',
                                prefixIcon: const Icon(Icons.location_on),
                              fieldController: _controller.country,
                                onChanged: (value) {},
                                keyboardType: TextInputType.text,
                                fieldName: "country",
                                validator: (value) => FormValidator.validate(
                                    value, ValidatorType.email,
                                    fieldName: Fields.email),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10.h,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(20.w)),
                      child: SpacedContainer(
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 8.h, horizontal: 16.h),
                                child: GestureDetector(
                                    onTap: () {
                                      _controller.selectDate(context);
                                    },
                                    child: AppText.body(
                                      "Personal information",
                                    )),
                              ),
                            ),
                            SpacedContainer(
                              child: DatePickerTextField(
                                context: context,
                                onChange: (value) {
                                  print(value);
                                },
                                dateController: _controller.date_of_birth,
                              ),
                            ),
                            SpacedContainer(
                              child: UpdateUserDetailsField(
                                labelText: 'Gender',
                                hintText: 'pick your gender',
                              fieldController: _controller.gender,
                                validator: null,
                                prefixIcon: const Icon(Icons.location_city),
                                fieldName: Fields.name,
                                onChanged: (value) {
                                  userdetails.address?.city = value;
                                },
                              ),
                            ),
                            SpacedContainer(
                              child: UpdateUserDetailsField(
                                labelText: 'BVN',
                                hintText: 'input your valid BVN',
                                validator: null,
                                prefixIcon: const Icon(Icons.location_city),
                                fieldName: Fields.name,
                                onChanged: (value) {},
                              fieldController: _controller.bvn,
                              ),
                            ),
                            SpacedContainer(
                              child: UpdateUserDetailsField(
                                labelText: "place of birth",
                                 hintText: "where were you born?",
                                fieldController: _controller.placeOfBirthController,
                                fieldName: Fields.name,),
                            ),
                            SpacedContainer(
                              child: UpdateUserDetailsField(
                                labelText: 'referrer id',
                                hintText: 'who referred you',
                                validator: null,
                                prefixIcon: const Icon(Icons.location_city),
                                fieldName: Fields.name,
                                onChanged: (value) {
                                  userdetails.nin = value;
                                },
                              fieldController: _controller.refby,
                              ),
                            ),
                            SpacedContainer(
                              child:PhotoPicker(
                                  hintText: "docs",
                                  labelText: "docs",
                                  prefixIcon: const Icon(Icons.file_copy),
                                  context: context,
                                  onChange: (value){
                                    print(value);
                                  },
                                  controller: _controller.imageInputController,
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
                          child: CustomButton(
                            text: "Submit",
                            size: ButtonSize.large,
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            borderRadius: 12,
                            isLoading: false,
                            isDisabled: false,
                            type: ButtonType.elevated,
                            onPressed: () {
                              _controller.updateUserDetailsModel();
                              _controller.updateUserDetailsToServer();
                              //_controller.walletPayloadToServer();
                              CustomPopup.show(
                                  context: context,
                                  title: "Select  a new Page",
                                  message:
                                      "Do you want to move to the next page?",
                                  actions: [
                                    PopupAction(
                                        text: "no",
                                        onPressed: () {
                                          // context.goNamed("/home");
                                          //context.pushNamed("/home");
                                        },
                                        color: Colors.green),
                                    PopupAction(
                                        text: "yes",
                                        onPressed: () {
                                          // context.pushNamed("/home");
                                        }),
                                  ]);
                            },
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            )),
      ),
    );
  }
}

class DatePickerTextField extends StatefulWidget {
  BuildContext context;
  Function(String?) onChange;
  TextEditingController dateController;
  String? Function(String?)? validator;
  DatePickerTextField({
    super.key,
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
        widget.dateController.text =
            DateFormat('dd/MM/yyyy').format(_selectedDate!);
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
      hintText: _selectedDate != null ? _selectedDate.toString() : 'YYYY-MM-DD',
      readOnly: true,
      onTap: _selectDate,
      validator: validator,
      // onChanged: ,
      fieldName: '',
    );
  }
}

String? validator(String? input) {
  if (input == null || input.isEmpty) {
    return "Name cannot be empty";
  } else {
    return null;
  }
}
