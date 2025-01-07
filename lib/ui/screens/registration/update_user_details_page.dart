import 'package:AXMPAY/constants/lists.dart';
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
import '../../../constants/text_constants.dart';
import '../../../main.dart';
import '../../../models/user_model.dart';
import '../../../providers/authentication_provider.dart';
import '../../../utils/form_validator.dart';
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
  final _scrollController = ScrollController();
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _controller = RegistrationController(context);
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.offset > 0 && !_isScrolled) {
      setState(() => _isScrolled = true);
    } else if (_scrollController.offset <= 0 && _isScrolled) {
      setState(() => _isScrolled = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildSectionCard({required String title, required List<Widget> children}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16.h),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.h),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getSectionIcon(title),
                    color: colorScheme.primary,
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.h),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  IconData _getSectionIcon(String title) {
    switch (title) {
      case 'Basic Information':
        return Icons.person_outline;
      case 'Address':
        return Icons.location_on_outlined;
      case 'Personal Information':
        return Icons.badge_outlined;
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    UserDetails userdetails = UserDetails(
      firstName: "",
      lastName: "",
      dateOfBirth: "",
      email: "",
    );

    return Form(
      key: _formKey,
      child: Scaffold(
        backgroundColor: colorScheme.background,
        appBar: AppBar(
          title: const Text('Update Profile'),
          elevation: _isScrolled ? 2 : 0,
          backgroundColor: _isScrolled ? colorScheme.surface : Colors.transparent,
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              children: [
                SizedBox(height: 16.h),

                // Profile Header
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50.w,
                        backgroundColor: colorScheme.primary.withOpacity(0.1),
                        child: Icon(
                          Icons.person_outline,
                          size: 50.w,
                          color: colorScheme.primary,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            size: 20.w,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24.h),

                // Basic Information Section
                _buildSectionCard(
                  title: 'Basic Information',
                  children: [
                    CustomTextField(
                      labelText: 'First Name',
                      hintText: 'Enter your First Name',
                      controller: _controller.first_name,
                      prefixIcon: const Icon(Icons.person_outline),
                      validator: (value) => FormValidator.validate(value, ValidatorType.isEmpty, fieldName: "firstName"),
                      fieldName: Fields.name,
                      readOnly: true,
                      onChanged: (value) => userdetails.firstName = value,
                    ),
                    SizedBox(height: 16.h),
                    CustomTextField(
                      labelText: 'Last Name',
                      hintText: 'Enter your Last Name',
                      controller:  _controller.last_name,
                      readOnly: true,
                      validator: (value)=>FormValidator.validate(value, ValidatorType.isEmpty,fieldName: "lastName"),
                      prefixIcon: const Icon(Icons.person), fieldName: Fields.name,
                      onChanged: (value){
                        userdetails.lastName = value;
                      },

                    ),
                    SizedBox(height: 16.h),
                    CustomTextField(
                      labelText: 'Email',
                      hintText: 'Enter your email',
                      readOnly: true,
                      prefixIcon: const Icon(Icons.email_outlined),
                      onChanged: (value){
                        userdetails.email = value;
                      },
                      keyboardType: TextInputType.emailAddress,
                      fieldName: Fields.email,
                      controller: _controller.emailController,
                      validator: (value)=>FormValidator.validate(value, ValidatorType.email,fieldName: Fields.email),
                    ),
                    SizedBox(height: 16.h),
                    CustomTextField(
                      border: InputBorder.none,
                      labelText: 'Phone',
                      hintText: 'Enter phone number',
                      prefixIcon: const Icon(Icons.phone),

                      fieldName: 'phone',
                      onChanged: (value){
                        userdetails.phone = value;
                      },
                      controller: _controller.phone_number,
                      validator: (value) => FormValidator.validate(value, ValidatorType.isEmpty, fieldName: "Phone number"),
                    ),
                    // Add other basic information fields here
                  ],
                ),

                // Address Section
                _buildSectionCard(
                  title: 'Address',
                  children: [
                    DropdownTextField(
                      labelText: 'Country',
                      hintText: 'Select your country',
                      prefixIcon: Icons.public,
                      controller: _controller.country,
                      onChange: (value) {},
                      fieldName: "country",
                      validator: (value) => FormValidator.validate(value, ValidatorType.isEmpty, fieldName: "country"),
                      options: Countries,
                      displayStringForOption: (options) => options,
                    ),
                    SizedBox(height: 16.h),
                    CustomTextField(
                      labelText: 'State',
                      hintText: 'name of state',
                      controller: _controller.state,
                      validator: (value)=>FormValidator.validate(value, ValidatorType.isEmpty,fieldName: "state"),
                      prefixIcon: const Icon(Icons.location_history), fieldName: Fields.name,
                      onChanged: (value){
                        userdetails.address?.state = value;
                      },

                    ),
                    SizedBox(height: 16.h),
                    CustomTextField(
                      labelText: 'City',
                      hintText: 'Enter name of your City',
                      controller: _controller.city,
                      validator: (value)=>FormValidator.validate(value, ValidatorType.isEmpty,fieldName: "city"),
                      prefixIcon: const Icon(Icons.location_city), fieldName: Fields.name,
                      onChanged: (value){
                        userdetails.address?.city = value;
                      },

                    ),
                    SizedBox(height: 16.h),
                    CustomTextField(
                      labelText: 'Street name',
                      hintText: 'Enter street name',
                      controller: _controller.streetAddress,
                      prefixIcon: const Icon(Icons.add_road_outlined),
                      onChanged: (value){
                        userdetails.address?.street = value;
                      },
                      keyboardType: TextInputType.text,
                      fieldName: Fields.email,
                      validator: (value)=>FormValidator.validate(value, ValidatorType.isEmpty,fieldName: "street address"),
                    ),
                    SizedBox(height: 16.h),
                    CustomTextField(
                      labelText: 'L.G.A',
                      hintText: 'Local Government Area',
                      prefixIcon: const Icon(Icons.location_searching),
                      controller: _controller.localGovArea,
                      onChanged: (value){
                      },
                      keyboardType: TextInputType.text,
                      fieldName: "Local Government Area",
                      validator: (value)=>FormValidator.validate(value, ValidatorType.isEmpty,fieldName: "L.G.A"),
                    ),
                    SizedBox(height: 16.h),
                    CustomTextField(
                      labelText: 'House Number',
                      hintText: 'Your House Number',
                      prefixIcon: const Icon(Icons.discount),
                      controller: _controller.houseNumber,
                      onChanged: (value){
                      },
                      keyboardType: TextInputType.text,
                      fieldName: "House Number",
                      validator: (value)=>FormValidator.validate(value, ValidatorType.isEmpty,fieldName: "House Number"),
                    ),
                    SizedBox(height: 16.h),
                    CustomTextField(
                      labelText: 'Nearest LandMark',
                      hintText: 'Nearest LandMark',
                      prefixIcon: const Icon(Icons.add_home),
                      controller: _controller.nearestLandMark,
                      onChanged: (value){
                      },
                      keyboardType: TextInputType.text,
                      fieldName: "Nearest LandMark",
                      validator: (value)=>FormValidator.validate(value, ValidatorType.isEmpty,fieldName: "Nearest LandMark"),
                    ),
                  ],
                ),

                // Personal Information Section
                _buildSectionCard(
                  title: 'Personal Information',
                  children: [
                    DatePickerTextField(
                      context: context,
                      onChange: (value) {
                        print(value);
                      },
                      dateController: _controller.date_of_birth,
                      validator: (value) => FormValidator.validate(value, ValidatorType.isEmpty, fieldName: "date of birth"),
                    ),
                    SizedBox(height: 16.h),


                    DropdownTextField(
                      controller: _controller.gender,
                      validator: (value)=>FormValidator.validate(value, ValidatorType.isEmpty,fieldName: "gender"),
                      onChange: (value ) {
                        setState(() {
                          _controller.gender.text = value??""!;
                        });

                      }, options: ["male","female"],
                      labelText: 'Gender', hintText: 'please select aa gender',
                      prefixIcon: Icons.female,
                      fieldName: 'gender',
                      displayStringForOption: (options )  =>options,
                    ),
                    SizedBox(height: 16.h),
                    CustomTextField(
                      labelText: 'BVN',
                      hintText: 'input your valid BVN',
                      validator: (value)=>FormValidator.validate(value, ValidatorType.digits,fieldName: "BVN"),

                      prefixIcon: const Icon(Icons.perm_identity), fieldName: Fields.name,
                      onChanged: (value){
                      },
                      controller: _controller.bvn,
                    ),
                    SizedBox(height: 16.h),
                    CustomTextField(
                      labelText: 'place of birth',
                      hintText: 'your place of birth',

                      validator: (value)=>FormValidator.validate(value, ValidatorType.isEmpty,fieldName: "place of Birth"),
                      prefixIcon: const Icon(Icons.location_on), fieldName: Fields.name,
                      onChanged: (value){
                        userdetails.nin = value;
                      },
                      controller: _controller.placeOfBirthController,
                    ),
                    SizedBox(height: 16.h),
                    DropdownTextField(
                      controller: _controller.PEP,
                      validator: (value)=>FormValidator.validate(value, ValidatorType.isEmpty,fieldName: "Political exposed person"),
                      onChange: (value ) {
                        setState(() {
                          _controller.PEP.text = value??""!;
                        });

                      }, options: const ["Yes","No"],
                      labelText: 'P.E.P', hintText: 'Political Exposed Person?',
                      prefixIcon: Icons.perm_identity_sharp,
                      fieldName: 'P.E.P',
                      displayStringForOption: (options )  =>options,
                    ),
                    SizedBox(height: 16.h),
                    CustomTextField(
                      labelText: 'referrer id',
                      hintText: 'This field is optional',
                      prefixIcon: const Icon(Icons.man_3_outlined), fieldName: Fields.name,
                      onChanged: (value){
                        userdetails.nin = value;
                      },
                      controller: _controller.refby,
                      // validator: (value)=>FormValidator.validate(value, ValidatorType.remarks,fieldName: "referrerID"),

                    ),
                    SizedBox(height: 16.h),
                  ],
                ),

                SizedBox(height: 24.h),

                // Submit Button
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32.w),
                  child: CustomButton(
                    text: "Update Profile",
                    size: ButtonSize.large,
                    backgroundColor: colorScheme.primary,
                    foregroundColor: Colors.white,
                    borderRadius: 12,
                    isLoading: false,
                    isDisabled: false,
                    type: ButtonType.elevated,
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        ResponseResult? resp = await _controller.createNewUserWallet();
                        if (resp?.status == ResponseStatus.failed) {
                          CustomPopup.show(
                            type: PopupType.error,
                            context: context,
                            title: "Error:",
                            message: resp?.message ?? "An error occurred",
                          );
                        } else if (resp?.status == ResponseStatus.success) {
                          CustomPopup.show(
                            type: PopupType.success,
                            context: context,
                            title: resp?.status.toString() ?? "Success",
                            message: resp?.message ?? "",
                          );
                          await Future.delayed(const Duration(seconds: 1));
                          final storage = const FlutterSecureStorage();
                          bool hasPasscode = await storage.read(key: 'passcode') == null;
                          if (!mounted) return;
                          if (hasPasscode) {
                            context.pushNamed("passcode_setup_screen");
                          } else {
                            context.goNamed("/home");
                          }
                        }
                      }
                    },
                  ),
                ),
                SizedBox(height: 32.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Keep DatePickerTextField and DropdownTextField implementations as they were...


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

//-------------------------------------- gender picker-----------------------------------------

class DropdownTextField<T> extends StatefulWidget {
  final Function(T?) onChange;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final List<T> options;
  final String labelText;
  final String hintText;
  final IconData prefixIcon;
  final String fieldName;
  final String Function(T) displayStringForOption;

  const DropdownTextField({
    Key? key,
    required this.onChange,
    required this.controller,
    required this.options,
    required this.labelText,
    required this.hintText,
    required this.prefixIcon,
    required this.fieldName,
    required this.displayStringForOption,
    this.validator,
  }) : super(key: key);

  @override
  _DropdownTextFieldState<T> createState() => _DropdownTextFieldState<T>();
}

class _DropdownTextFieldState<T> extends State<DropdownTextField<T>> {
  T? _selectedOption;

  void _showDropdown() async {
    final RenderBox textFieldBox = context.findRenderObject() as RenderBox;
    final textFieldPosition = textFieldBox.localToGlobal(Offset.zero);

    final T? selectedOption = await showMenu<T>(
      context: context,
      position: RelativeRect.fromLTRB(
        textFieldPosition.dx,
        textFieldPosition.dy + textFieldBox.size.height,
        textFieldPosition.dx + textFieldBox.size.width,
        textFieldPosition.dy + textFieldBox.size.height,
      ),
      items: widget.options.map((T option) {
        return PopupMenuItem<T>(
          value: option,
          child: Text(widget.displayStringForOption(option)),
        );
      }).toList(),
    );

    if (selectedOption != null) {
      setState(() {
        _selectedOption = selectedOption;
        widget.controller.text = widget.displayStringForOption(selectedOption);
        widget.onChange(selectedOption);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: widget.controller,
      labelText: widget.labelText,
      prefixIcon: Icon(widget.prefixIcon),
      suffixIcon: Icon(Icons.arrow_drop_down),
      hintText: _selectedOption != null
          ? widget.displayStringForOption(_selectedOption!)
          : widget.hintText,
      readOnly: true,
      onTap: _showDropdown,
      validator: widget.validator,
      fieldName: widget.fieldName,
    );
  }
}
String? validator(String? input){
  if (input == null || input.isEmpty) {
    return "Date cannot be empty";
  }else{
    return null;
  }

}