import 'package:AXMPAY/models/ResponseModel.dart';
import 'package:AXMPAY/providers/user_service_provider.dart';
import 'package:AXMPAY/ui/screens/upgrade_account/upgrade_user_details_field.dart';
import 'package:AXMPAY/ui/screens/upgrade_account/upgrade_account_controller.dart';
import 'package:AXMPAY/ui/widgets/custom_dialog.dart';
import 'package:AXMPAY/ui/widgets/custom_responsive_sizes/responsive_size.dart';
import 'package:AXMPAY/ui/widgets/file_picker/photo_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../main.dart';
import '../../../models/user_model.dart';
import '../../../providers/authentication_provider.dart';
import '../../../utils/form_validator.dart';
import '../../widgets/custom_container.dart';
import '../../widgets/custom_dropdown.dart';
import '../../widgets/custom_text/custom_apptext.dart';
import '../../widgets/custom_textfield.dart';

class UpgradeAccountPage extends StatefulWidget {
  const UpgradeAccountPage({super.key});

  @override
  State<UpgradeAccountPage> createState() => _UpdateUserDetailsPageState();
}

class _UpdateUserDetailsPageState extends State<UpgradeAccountPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  late UpgradeAccountController _controller;
  late UserServiceProvider userprovider;
  late UserData userData;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _controller = UpgradeAccountController(context);
    userprovider = Provider.of<UserServiceProvider>(context, listen: false);
    userData = userprovider.userdata!;
  }

  @override
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
          tabs: const [
           // Tab(text: 'Basic Info'),
            Tab(text: 'Identification'),
          //  Tab(text: 'Address'),
          //  Tab(text: 'Additional Info'),
            Tab(text: 'Documents'),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: TabBarView(
          controller: _tabController,
          children: [
           // _buildBasicInfoTab(),
            _buildIdentificationTab(),
           // _buildAddressTab(),
          //  _buildAdditionalInfoTab(),
            _buildDocumentsTab(),
          ],
        ),
      ),
      bottomNavigationBar: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              child: _isLoading
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : const Text('Submit'),
              onPressed: _isLoading
                  ? null
                  : () async {
                setState(() => _isLoading = true);
                bool isFormValid = true;
                for (int i = 0; i < _tabController.length; i++) {
                  _tabController.animateTo(i);
                  await Future.delayed(const Duration(milliseconds: 300));
                  if (!_formKey.currentState!.validate()) {
                    isFormValid = false;
                    break;
                  }
                }

                if (isFormValid) {
                  _controller.createUserWalletPayload();
                  ResponseResult? responseResult = await _controller.upgradeUserWalletInServer();
                  if (responseResult?.status != ResponseStatus.success) {
                    if(!mounted) return;
                    CustomPopup.show(
                      type: PopupType.error,
                      context: context,
                      title: responseResult?.status.toString() ?? "",
                      message: responseResult?.message ?? "",
                    );
                  }
                }
                setState(() => _isLoading = false);
              },
            ),
          );
        },
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
                      onChanged: (value) {},
                      fieldName: 'BVN',
                      validator:(value)=> FormValidator.validate(value, ValidatorType.isEmpty,fieldName: "BVN"),
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
                      readOnly: true,
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
                  child: DropdownTextField(
                  controller: _controller.idTypeController,
                    validator: (value)=>FormValidator.validate(value, ValidatorType.isEmpty,fieldName: "Political exposed person"),
                    onChange: (value ) {
                      setState(() {
                        _controller.idTypeController.text = value??""!;
                      });

                    }, options: const ["National ID","Driver's License","Voter's card","International PassPort"],
                    labelText: 'Identification Type',
                    hintText: 'Select type of identification?',
                    prefixIcon: Icons.person_pin_outlined,
                    fieldName: 'P.E.P',
                    displayStringForOption: (options )  =>options,
                  )
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
                          firstDate:  DateTime.now().subtract(Duration(days: 5780)),
                          lastDate:  DateTime.now(),
                          onChange: (value) {},
                          validator:(value)=> FormValidator.validate(value, ValidatorType.isEmpty,fieldName: "ID Issue Date"),
                        ),
                      ),
                      SpacedContainer(
                        child: DatePickerTextField(
                          labelText: 'ID Expiry Date',
                          firstDate:  DateTime.now(),
                          lastDate:  DateTime.now().add(const Duration(days: 10780)),
                          dateController: _controller.idExpiryDateController,
                          onChange: (value) {},
                          validator:(value)=> FormValidator.validate(value, ValidatorType.isEmpty,fieldName: "ID Expiry Date"),
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
                        validator:(value)=> FormValidator.validate(value, ValidatorType.isEmpty,fieldName: "House Number"),

                      ),
                    ),
                    SpacedContainer(
                      child: UpdateUserDetailsField(
                        labelText: 'Street Name',
                        fieldController: _controller.streetNameController,
                        onChanged: (value) {},
                        fieldName: '',
                        validator:(value)=> FormValidator.validate(value, ValidatorType.isEmpty,fieldName: "Street Name"),

                      ),
                    ),
                    SpacedContainer(
                      child: UpdateUserDetailsField( 
                        labelText: 'State',
                        fieldController: _controller.stateController,
                        onChanged: (value) {}, fieldName: '',
                        validator:(value)=> FormValidator.validate(value, ValidatorType.isEmpty,fieldName: "State"),
                      ),
                    ),
                    SpacedContainer(
                      child: UpdateUserDetailsField( 
                        labelText: 'City',
                        fieldController: _controller.cityController,
                        onChanged: (value) {}, fieldName: '',
                        validator:(value)=> FormValidator.validate(value, ValidatorType.isEmpty,fieldName: "City"),

                      ),
                    ),
                    SpacedContainer(
                      child: UpdateUserDetailsField( 
                        labelText: 'Local Government',
                        fieldController: _controller.localGovernmentController,
                        onChanged: (value) {}, fieldName: '',
                        validator:(value)=> FormValidator.validate(value, ValidatorType.isEmpty,fieldName: "Local Government"),

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
                        validator:(value)=> FormValidator.validate(value, ValidatorType.isEmpty,fieldName: "PEP"),

                      ),
                    ),
                    SpacedContainer(  
                      child: UpdateUserDetailsField(
                        labelText: 'Nearest Landmark',
                        fieldController: _controller.nearestLandMarkController,
                        onChanged: (value) {}, fieldName: '',
                        validator:(value)=> FormValidator.validate(value, ValidatorType.isEmpty,fieldName: "Landmark"),

                      ),
                    ),
                    SpacedContainer(
                      child: UpdateUserDetailsField(
                        labelText: 'Place of Birth',
                        fieldController: _controller.placeOfBirthController,
                        onChanged: (value) {}, fieldName: '',
                        validator:(value)=> FormValidator.validate(value, ValidatorType.isEmpty,fieldName: "Place of Birth"),

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
                        validator: (value) {
                          if (value != null && value is String) {
                            return _controller.fileSizeValidator(value); }
                          return null;
                        },
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
                        validator: (value) {
                            if (value != null && value is String) {
                            return _controller.fileSizeValidator(value); }
                            return null;
                    },
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
                        validator: (value) {
                          if (value != null && value is String) {
                            return _controller.fileSizeValidator(value); }
                          return null;
                        },
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
                        validator: (value) {
                          if (value != null && value is String) {
                            return _controller.fileSizeValidator(value); }
                          return null;
                        },
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
                        validator: (value) {
                          if (value != null && value is String) {
                            return _controller.fileSizeValidator(value); }
                          return null;
                        },
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
                        validator: (value) {
                          if (value != null && value is String) {
                            return _controller.fileSizeValidator(value); }
                          return null;
                        },
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
  DateTime?  firstDate;
  DateTime?  lastDate;
  DatePickerTextField({
    super.key,
    required this.context,
    required this.onChange,
    required this.dateController,
    this.validator,
    this.labelText,
    this.firstDate,
    this.lastDate,
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
      firstDate: widget.firstDate??DateTime.now().subtract(Duration(days: 10342)),
      lastDate: widget.lastDate??DateTime.now().add(Duration(days: 10780)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        widget.dateController.text =
            DateFormat('yyyy-MM-dd').format(_selectedDate!);
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
      validator: widget.validator,
      // onChanged: ,
      fieldName: '',
    );
  }
}

String? validator(String? input) {
  if (input == null || input.isEmpty) {
    return "field cannot be empty";
  } else {
    return null;
  }
}
