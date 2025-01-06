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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.colorScheme.primary,
        title: Text(
          'Upgrade Wallet',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60.h),
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              labelStyle: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
              tabs: const [
                Tab(
                  icon: Icon(Icons.badge_outlined),
                  text: 'Identification',
                ),
                Tab(
                  icon: Icon(Icons.document_scanner_outlined),
                  text: 'Documents',
                ),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary.withOpacity(0.05),
              Colors.white,
            ],
          ),
        ),
        child: Form(
          key: _formKey,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildIdentificationTab(),
              _buildDocumentsTab(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : Text(
                'Submit',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
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
                  ResponseResult? responseResult =
                  await _controller.upgradeUserWalletInServer();
                  if (responseResult?.status != ResponseStatus.success) {
                    if (!mounted) return;
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

  Widget _buildIdentificationTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Row(
                      children: [
                        Icon(
                          Icons.verified_user_outlined,
                          color: Theme.of(context).colorScheme.primary,
                          size: 24.w,
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          "Identification Details",
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: Colors.grey.withOpacity(0.2)),
                  Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      children: [
                        _buildDropdownField(
                          controller: _controller.idTypeController,
                          options: const [
                            "National ID",
                            "Driver's License",
                            "Voter's card",
                            "International PassPort"
                          ],
                          labelText: 'Identification Type',
                          hintText: 'Select type of identification',
                          icon: Icons.badge_outlined,
                        ),
                        SizedBox(height: 16.h),
                        _buildTextField(
                          controller: _controller.idNumberController,
                          labelText: 'ID Number',
                          icon: Icons.numbers_outlined,
                        ),
                        SizedBox(height: 16.h),
                        _buildDateField(
                          controller: _controller.idIssueDateController,
                          labelText: 'ID Issue Date',
                          firstDate: DateTime.now().subtract(Duration(days: 5780)),
                          lastDate: DateTime.now(),
                          icon: Icons.calendar_today_outlined,
                        ),
                        SizedBox(height: 16.h),
                        _buildDateField(
                          controller: _controller.idExpiryDateController,
                          labelText: 'ID Expiry Date',
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 10780)),
                          icon: Icons.event_outlined,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentsTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  children: [
                    Icon(
                      Icons.upload_file_outlined,
                      color: Theme.of(context).colorScheme.primary,
                      size: 24.w,
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      "Required Documents",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: Colors.grey.withOpacity(0.2)),
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  children: [
                    _buildDocumentUploader(
                      controller: _controller.userPhotoController,
                      label: "User Photo",
                      icon: Icons.person_outline,
                    ),
                    SizedBox(height: 16.h),
                    _buildDocumentUploader(
                      controller: _controller.idCardFrontController,
                      label: "ID Card Front",
                      icon: Icons.credit_card_outlined,
                    ),
                    SizedBox(height: 16.h),
                    _buildDocumentUploader(
                      controller: _controller.idCardBackController,
                      label: "ID Card Back",
                      icon: Icons.credit_card_outlined,
                    ),
                    SizedBox(height: 16.h),
                    _buildDocumentUploader(
                      controller: _controller.customerSignatureController,
                      label: "Customer Signature",
                      icon: Icons.draw_outlined,
                    ),
                    SizedBox(height: 16.h),
                    _buildDocumentUploader(
                      controller: _controller.utilityBillController,
                      label: "Utility Bill",
                      icon: Icons.receipt_outlined,
                    ),
                    SizedBox(height: 16.h),
                    _buildDocumentUploader(
                      controller: _controller.proofOfAddressController,
                      label: "Proof of Address",
                      icon: Icons.home_outlined,
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

  Widget _buildDropdownField({required TextEditingController controller, required List<String> options, required String labelText, required String hintText, required IconData icon,}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownTextField(
        controller: controller,
        validator: (value) =>
            FormValidator.validate(value, ValidatorType.isEmpty, fieldName: labelText),
        onChange: (value) {
          setState(() {
            controller.text = value ?? "";
          });
        },
        options: options,
        labelText: labelText,
        hintText: hintText,
        prefixIcon: icon,
        displayStringForOption: (option) => option, fieldName: '',
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String labelText, required IconData icon,}){
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: UpdateUserDetailsField(
        labelText: labelText,
        fieldController: controller,
        onChanged: (value) {},
        fieldName: '',
        prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.primary),
      ),
    );
  }

  Widget _buildDateField({required TextEditingController controller, required String labelText, required DateTime firstDate, required DateTime lastDate, required IconData icon,}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DatePickerTextField(
        labelText: labelText,
        dateController: controller,
        context: context,
        firstDate: firstDate,
        lastDate: lastDate,
        onChange: (value) {},
        validator: (value) =>
            FormValidator.validate(value, ValidatorType.isEmpty, fieldName: labelText),
      ),
    );
  }

  Widget _buildDocumentUploader({required TextEditingController controller, required String label, required IconData icon,}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: PhotoPicker(
        hintText: label,
        labelText: label,
        prefixIcon: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
        ),
        context: context,
        onChange: (value) {
          print(value);
        },
        controller: controller,
        validator: (value) {
          if (value != null && value is String) {
            return _controller.fileSizeValidator(value);
          }
          return null;
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
