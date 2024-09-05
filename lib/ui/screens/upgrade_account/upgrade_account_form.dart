import 'package:fintech_app/providers/user_service_provider.dart';
import 'package:fintech_app/ui/screens/upgrade_account/upgrade_user_details_field.dart';
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

class _UpdateUserDetailsPageState extends State<UpgradeAccountPage> with SingleTickerProviderStateMixin{
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  late UpgradeAccountController _controller;
  late UserServiceProvider userprovider;
  late UserData userData;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _controller = UpgradeAccountController(context);
     userprovider = Provider.of<UserServiceProvider>(context, listen: false);
     userData = userprovider.userdata!;
  }
  void dispose() {
    _tabController.dispose();
    _controller.dispose();
    super.dispose();
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upgrade Wallet'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            Tab(text: 'Basic Info'),
            Tab(text: 'Identification'),
            Tab(text: 'Address'),
            Tab(text: 'Additional Info'),
            Tab(text: 'Documents'),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildBasicInfoTab(),
            _buildIdentificationTab(),
            _buildAddressTab(),
            _buildAdditionalInfoTab(),
            _buildDocumentsTab(),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          child: Text('Submit'),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              // Process data
            }
          },
        ),
      ),
    );
  }

  Widget _buildBasicInfoTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 10.h),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20.w),
            ),
            child:  SpacedContainer(
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.h),
                      child: AppText.body("Basic information"),
                    ),
                  ),
                  SpacedContainer(
                    child: UpdateUserDetailsField(
                      labelText: 'Account Number',
                      fieldController: _controller.accountNumberController,
                      readOnly: true,
                      onChanged: (value) {}, fieldName: '',
                    ),
                  ),
                  SpacedContainer(
                    child: UpdateUserDetailsField(
                      labelText: 'BVN',
                      fieldController: _controller.bvnController,
                      onChanged: (value) {}, fieldName: '',
                    ),
                  ),
                  SpacedContainer(
                    child: UpdateUserDetailsField( 
                      labelText: 'Account Name',
                      fieldController: _controller.accountNameController,
                      onChanged: (value) {}, fieldName: '',
                      readOnly: true,
                    ),
                  ),
                  SpacedContainer(  
                    child: UpdateUserDetailsField(
                      labelText: 'Phone Number',
                      fieldController: _controller.phoneNumberController,
                      onChanged: (value) {}, fieldName: '',
                    ),
                  ),
                  SpacedContainer(  
                    child: UpdateUserDetailsField(
                      labelText: 'Tier',
                      fieldController: _controller.tierController,
                      onChanged: (value) {}, fieldName: '',
                    ),
                  ),
                  SpacedContainer(
                    child: UpdateUserDetailsField(
                      labelText: 'Email',
                      fieldController: _controller.emailController,
                      onChanged: (value) {}, fieldName: '',
                      readOnly: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdentificationTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 10.h,),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20.w),
            ),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.h),
                    child: AppText.body("identification"),
                  ),
                ),
                SpacedContainer(
                  child: Column(
                    children: [
                      SpacedContainer(
                        child: UpdateUserDetailsField(
                          labelText: 'ID Type',
                          fieldController: _controller.idTypeController,
                          onChanged: (value) {}, fieldName: '',
                        ),
                      ),
                      SpacedContainer(
                        child: UpdateUserDetailsField(
                          labelText: 'ID Number',
                          fieldController: _controller.idNumberController,
                          onChanged: (value) {}, fieldName: '',
                        ),
                      ),
                      SpacedContainer(
                        child: DatePickerTextField(
                          labelText: 'ID Issue Date',
                          dateController: _controller.idIssueDateController,
                          context: context,
                          onChange: (value) {},
                          //fieldName: '',
                        ),
                      ),
                      SpacedContainer(
                        child: DatePickerTextField(
                          labelText: 'ID Expiry Date',
                          dateController: _controller.idExpiryDateController,
                          onChange: (value) {},
                          context: context,
                          //fieldName: '',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child:   Container(
          margin: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(20.w),
          ),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.h),
                  child: AppText.body("User Address"),
                ),
              ),
              SpacedContainer(
                child: Column(
                  children: [
                    SpacedContainer(  
                      child: UpdateUserDetailsField(
                        labelText: 'House Number',
                        fieldController: _controller.houseNumberController,
                        onChanged: (value) {},
                        fieldName: '',
                      ),
                    ),
                    SpacedContainer(
                      child: UpdateUserDetailsField(
                        labelText: 'Street Name',
                        fieldController: _controller.streetNameController,
                        onChanged: (value) {},
                        fieldName: '',
                      ),
                    ),
                    SpacedContainer(
                      child: UpdateUserDetailsField( 
                        labelText: 'State',
                        fieldController: _controller.stateController,
                        onChanged: (value) {}, fieldName: '',
                      ),
                    ),
                    SpacedContainer(
                      child: UpdateUserDetailsField( 
                        labelText: 'City',
                        fieldController: _controller.cityController,
                        onChanged: (value) {}, fieldName: '',
                      ),
                    ),
                    SpacedContainer(
                      child: UpdateUserDetailsField( 
                        labelText: 'Local Government',
                        fieldController: _controller.localGovernmentController,
                        onChanged: (value) {}, fieldName: '',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdditionalInfoTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child:   Container(
          margin: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(20.w),
          ),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.h),
                  child: AppText.body("Additional information"),
                ),
              ),
              SpacedContainer(
                child: Column(
                  children: [
                    SpacedContainer(  
                      child: UpdateUserDetailsField(
                        labelText: 'PEP',
                        fieldController: _controller.pepController,
                        onChanged: (value) {}, fieldName: '',
                      ),
                    ),
                    SpacedContainer(  
                      child: UpdateUserDetailsField(
                        labelText: 'Nearest Landmark',
                        fieldController: _controller.nearestLandMarkController,
                        onChanged: (value) {}, fieldName: '',
                      ),
                    ),
                    SpacedContainer(
                      child: UpdateUserDetailsField(
                        labelText: 'Place of Birth',
                        fieldController: _controller.placeOfBirthController,
                        onChanged: (value) {}, fieldName: '',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentsTab() {
    return SingleChildScrollView(
      child: Padding(
        padding:  EdgeInsets.symmetric(vertical: 16.0.h),
        child:   Container(
          margin: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(20.w),
          ),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.h),
                  child: AppText.body("Documents"),
                ),
              ),
              SpacedContainer(
                child: Column(
                  children: [
                    SpacedContainer(
                      child: PhotoPicker(
                        hintText: "User Photo",
                        labelText: "User Photo",
                        prefixIcon: const Icon(Icons.photo),
                        context: context,
                        onChange: (value) {
                          print(value);
                        },
                        controller: _controller.userPhotoController,
                      ),
                    ),
                    SpacedContainer(
                      child: PhotoPicker(  
                        hintText: "ID Card Front",
                        labelText: "ID Card Front",
                        prefixIcon: const Icon(Icons.credit_card),
                        context: context,
                        onChange: (value) {
                          print(value);
                        },
                        controller: _controller.idCardFrontController,
                      ),
                    ),
                    SpacedContainer(
                      child: PhotoPicker(  
                        hintText: "ID Card Back",
                        labelText: "ID Card Back",
                        prefixIcon: const Icon(Icons.credit_card),
                        context: context,
                        onChange: (value) {
                          print(value);
                        },
                        controller: _controller.idCardBackController,
                      ),
                    ),
                    SpacedContainer(
                      child: PhotoPicker(  
                        hintText: "Customer Signature",
                        labelText: "Customer Signature",
                        prefixIcon: const Icon(Icons.draw),
                        context: context,
                        onChange: (value) {
                          print(value);
                        },
                        controller: _controller.customerSignatureController,
                      ),
                    ),
                    SpacedContainer(
                      child: PhotoPicker(  
                        hintText: "Utility Bill",
                        labelText: "Utility Bill",
                        prefixIcon: const Icon(Icons.receipt),
                        context: context,
                        onChange: (value) {
                          print(value);
                        },
                        controller: _controller.utilityBillController,
                      ),
                    ),
                    SpacedContainer(
                      child: PhotoPicker(
                        hintText: "Proof of Address",
                        labelText: "Proof of Address",
                        prefixIcon: const Icon(Icons.home),
                        context: context,
                        onChange: (value) {
                          print(value);
                        },
                        controller: _controller.proofOfAddressController,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
  String?  labelText;
  DatePickerTextField({
    super.key,
    required this.context,
    required this.onChange,
    required this.dateController,
    this.validator,
    this.labelText,
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
      labelText: widget.labelText,
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
