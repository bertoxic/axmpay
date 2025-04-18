import 'package:AXMPAY/constants/lists.dart';
import 'package:AXMPAY/models/ResponseModel.dart';
import 'package:AXMPAY/ui/screens/registration/registration_controller.dart';
import 'package:AXMPAY/ui/widgets/custom_buttons.dart';
import 'package:AXMPAY/ui/widgets/custom_dialog.dart';
import 'package:AXMPAY/ui/widgets/custom_dropdown.dart';
import 'package:AXMPAY/ui/widgets/custom_responsive_sizes/responsive_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dojah_kyc/flutter_dojah_kyc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../constants/text_constants.dart';
import '../../../main.dart';
import '../../../models/user_model.dart';
import '../../../utils/datepicker.dart';
import '../../../utils/form_validator.dart';
import '../../widgets/custom_textfield.dart';
import 'dart:math';

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
  bool _isLoading = false;
  bool _isKYCLoading = false;
  bool _isBvnVerified = false;
  late UserDetails userDetails;

  @override
  void initState() {
    super.initState();
    _controller = RegistrationController(context);
    _scrollController.addListener(_onScroll);
    _initializeUserData();
  }

  void _initializeUserData() {
    // Initialize with user data from a proper source
    setState(() {
      userDetails = UserDetails(
        firstName: "",
        lastName: "",
        dateOfBirth: "",
        email: "",
      );
    });

    Future.delayed(Duration.zero, () async {
      try {
        // Example: Get user data from storage or API
        // final userData = await getUserDataFromApi();
        // _controller.first_name.text = userData.firstName;
        // _controller.last_name.text = userData.lastName;
        // ...etc
      } catch (e) {
        _showSnackBar('Failed to load user data: ${e.toString()}');
      }
    });
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

  bool _validatePersonalDetails() {
    if (_controller.first_name.text.isEmpty ||
        _controller.last_name.text.isEmpty ||
        _controller.date_of_birth.text.isEmpty ||
        _controller.gender.text.isEmpty) {
      _showSnackBar('Please fill all details in personal section before BVN verification');
      return false;
    }
    return true;
  }

  Future<void> _verifyBVN() async {
    if (_controller.bvn.text.isEmpty) {
      _showSnackBar('Please enter your BVN first');
      return;
    }

    // Validate that personal details are filled first
    if (!_validatePersonalDetails()) {
      return;
    }

    setState(() => _isKYCLoading = true);

    try {
      // Use actual user data for verification without setting state here
      // The state will be set in the callback functions
      ShowWidgetID(
        context,
        _isBvnVerified,
        _controller.first_name.text,
        _controller.last_name.text,
        _controller.emailController.text,
        _controller.date_of_birth.text,
        _controller.gender.text,
        _controller.bvn.text,
        onSuccess: () {
          setState(() {
            _isBvnVerified = true;
            _isKYCLoading = false;
          });
          _showSnackBar('BVN verified successfully');
        },
        onError: (String errorMessage) {
          setState(() {
            _isBvnVerified = false;
            _isKYCLoading = false;
          });
          _showSnackBar('BVN verification failed: $errorMessage');
        },
        onClose: () {
          setState(() {
            _isKYCLoading = false;
          });
          _showSnackBar('BVN verification canceled');
        },
      );
    } catch (e) {
      setState(() => _isKYCLoading = false);
      _showSnackBar('Failed to verify BVN: ${e.toString()}');
    }
  }

  void _showDojahKYC() {
    if (_controller.bvn.text.isEmpty) {
      _showSnackBar('Please enter your BVN first');
      return;
    }

    // Validates that personal details are filled first
    if (!_validatePersonalDetails()) {
      return;
    }

    // user data for verification
    ShowWidgetID(
      context,
      _isBvnVerified,
      _controller.first_name.text,
      _controller.last_name.text,
      _controller.emailController.text,
      _controller.date_of_birth.text,
      _controller.gender.text,
      _controller.bvn.text,
      onSuccess: () {
        setState(() {
          _isBvnVerified = true;
          _isKYCLoading= false;
        });
      },
      onError: (String errorMessage) {
        setState(() {
          _isBvnVerified = false;
          _isKYCLoading = false;
        });
      },
      onClose: () {
        setState(() {
          _isBvnVerified = false;
          _isKYCLoading = false;
        });

      },
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: _isBvnVerified ? Colors.green : colorScheme.primary,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
    required IconData icon
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.h),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16.w),
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
            padding: EdgeInsets.all(18.h),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.h),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: colorScheme.primary,
                    size: 24.w,
                  ),
                ),
                SizedBox(width: 16.w),
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
          Divider(
            color: colorScheme.onSurface.withOpacity(0.1),
            thickness: 1,
          ),
          Padding(
            padding: EdgeInsets.all(18.h),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Scaffold(
        backgroundColor: colorScheme.background,
        appBar: AppBar(
          title: const Text('Update Profile'),
          elevation: _isScrolled ? 2 : 0,
          backgroundColor: _isScrolled ? colorScheme.surface : Colors.transparent,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: colorScheme.primary),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 18.w),
                child: Column(
                  children: [
                    SizedBox(height: 20.h),

                    // Profile Header
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            padding: EdgeInsets.all(4.w),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: colorScheme.primary,
                                width: 2,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 60.w,
                              backgroundColor: colorScheme.primary.withOpacity(0.1),
                              child: Icon(
                                Icons.person_outline,
                                size: 60.w,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: EdgeInsets.all(10.w),
                              decoration: BoxDecoration(
                                color: colorScheme.primary,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
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

                    SizedBox(height: 28.h),

                    // Basic Information Section
                    _buildSectionCard(
                      title: 'Basic Information',
                      icon: Icons.person,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                labelText: 'First Name',
                                hintText: 'Enter your First Name',
                                controller: _controller.first_name,
                                prefixIcon: const Icon(Icons.person_outline),
                                validator: (value) => FormValidator.validate(value, ValidatorType.isEmpty, fieldName: "firstName"),
                                fieldName: Fields.name,
                                readOnly: true,
                                onChanged: (value) => userDetails.firstName = value,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: CustomTextField(
                                labelText: 'Last Name',
                                hintText: 'Enter your Last Name',
                                controller: _controller.last_name,
                                readOnly: true,
                                validator: (value) => FormValidator.validate(value, ValidatorType.isEmpty, fieldName: "lastName"),
                                prefixIcon: const Icon(Icons.person),
                                fieldName: Fields.name,
                                onChanged: (value) {
                                  userDetails.lastName = value;
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 18.h),
                        CustomTextField(
                          labelText: 'Email',
                          hintText: 'Enter your email',
                          readOnly: true,
                          prefixIcon: const Icon(Icons.email_outlined),
                          onChanged: (value) {
                            userDetails.email = value;
                          },
                          keyboardType: TextInputType.emailAddress,
                          fieldName: Fields.email,
                          controller: _controller.emailController,
                          validator: (value) => FormValidator.validate(value, ValidatorType.email, fieldName: Fields.email),
                        ),
                        SizedBox(height: 18.h),
                        CustomTextField(
                          border: InputBorder.none,
                          labelText: 'Phone',
                          hintText: 'Enter phone number',
                          prefixIcon: const Icon(Icons.phone),
                          fieldName: 'phone',
                          onChanged: (value) {
                            userDetails.phone = value;
                            _controller.phone_number.text = value;
                          },
                          controller: _controller.phone_number,
                          validator: (value) => FormValidator.validate(value, ValidatorType.isEmpty, fieldName: "Phone number"),
                        ),
                      ],
                    ),

                    // Address Section
                    _buildSectionCard(
                      title: 'Address',
                      icon: Icons.location_on,
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
                        SizedBox(height: 18.h),
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                labelText: 'State',
                                hintText: 'Name of state',
                                controller: _controller.state,
                                validator: (value) => FormValidator.validate(value, ValidatorType.isEmpty, fieldName: "state"),
                                prefixIcon: const Icon(Icons.location_history),
                                fieldName: Fields.name,
                                onChanged: (value) {
                                  userDetails.address?.state = value;
                                },
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: CustomTextField(
                                labelText: 'City',
                                hintText: 'Enter city name',
                                controller: _controller.city,
                                validator: (value) => FormValidator.validate(value, ValidatorType.isEmpty, fieldName: "city"),
                                prefixIcon: const Icon(Icons.location_city),
                                fieldName: Fields.name,
                                onChanged: (value) {
                                  userDetails.address?.city = value;
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 18.h),
                        CustomTextField(
                          labelText: 'Street Name',
                          hintText: 'Enter street name',
                          controller: _controller.streetAddress,
                          prefixIcon: const Icon(Icons.add_road_outlined),
                          onChanged: (value) {
                            userDetails.address?.street = value;
                          },
                          keyboardType: TextInputType.text,
                          fieldName: Fields.email,
                          validator: (value) => FormValidator.validate(value, ValidatorType.isEmpty, fieldName: "street address"),
                        ),
                        SizedBox(height: 18.h),
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                labelText: 'L.G.A',
                                hintText: 'Local Government Area',
                                prefixIcon: const Icon(Icons.location_searching),
                                controller: _controller.localGovArea,
                                onChanged: (value) {},
                                keyboardType: TextInputType.text,
                                fieldName: "Local Government Area",
                                validator: (value) => FormValidator.validate(value, ValidatorType.isEmpty, fieldName: "L.G.A"),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: CustomTextField(
                                labelText: 'House Number',
                                hintText: 'Your House Number',
                                prefixIcon: const Icon(Icons.home),
                                controller: _controller.houseNumber,
                                onChanged: (value) {},
                                keyboardType: TextInputType.text,
                                fieldName: "House Number",
                                validator: (value) => FormValidator.validate(value, ValidatorType.isEmpty, fieldName: "House Number"),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 18.h),
                        CustomTextField(
                          labelText: 'Nearest Landmark',
                          hintText: 'Nearest Landmark',
                          prefixIcon: const Icon(Icons.add_location_alt),
                          controller: _controller.nearestLandMark,
                          onChanged: (value) {},
                          keyboardType: TextInputType.text,
                          fieldName: "Nearest Landmark",
                          validator: (value) => FormValidator.validate(value, ValidatorType.isEmpty, fieldName: "Nearest Landmark"),
                        ),
                      ],
                    ),

                    // Personal Information Section
                    _buildSectionCard(
                      title: 'Personal Information',
                      icon: Icons.assignment_ind,
                      children: [
                        DatePickerTextField(
                          context: context,
                          dateFormat: DateFormat("yyy-MM-dd"),
                          onChange: (value) {
                            userDetails.dateOfBirth = value ?? "";
                            setState(() {
                              _controller.date_of_birth.text = value??"";

                            });
                          },
                          dateController: _controller.date_of_birth,
                          validator: (value) => FormValidator.validate(
                              value, ValidatorType.isEmpty,
                              fieldName: "date of birth"
                          ),
                        ),
                        SizedBox(height: 18.h),
                        DropdownTextField(
                          controller: _controller.gender,
                          validator: (value) => FormValidator.validate(
                              value, ValidatorType.isEmpty,
                              fieldName: "gender"
                          ),
                          onChange: (value) {
                            setState(() {
                              _controller.gender.text = value ?? "";
                            });
                          },
                          options: ["Male", "Female", "Other"],
                          labelText: 'Gender',
                          hintText: 'Please select a gender',
                          prefixIcon: Icons.person_pin,
                          fieldName: 'gender',
                          displayStringForOption: (options) => options,
                        ),
                        SizedBox(height: 18.h),
                        Row(
                          children: [
                            Expanded(
                              flex: 7,
                              child: CustomTextField(
                                labelText: 'BVN',
                                hintText: 'Input your valid BVN',
                                validator: (value) => FormValidator.validate(
                                    value, ValidatorType.digits,
                                    fieldName: "BVN"
                                ),
                                prefixIcon: const Icon(Icons.perm_identity),
                                fieldName: Fields.name,
                                onChanged: (value) {
                                  _controller.bvn.text = value??"";
                                },
                                controller: _controller.bvn,
                                suffixIcon: _isBvnVerified
                                    ? Icon(Icons.check_circle, color: Colors.green)
                                    : null,
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              flex: 3,
                              child: ElevatedButton(
                                onPressed: _verifyBVN,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colorScheme.primary,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: 15.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text('Verify'),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.h),
                        if (!_isBvnVerified)
                          Center(
                            child: TextButton.icon(
                              onPressed: _showDojahKYC,
                              icon: Icon(Icons.verified_user, color: colorScheme.primary),
                              label: Text(
                                ' KYC for Verification',
                                style: TextStyle(color: colorScheme.primary),
                              ),
                            ),
                          ),
                        SizedBox(height: 18.h),
                        CustomTextField(
                          labelText: 'Place of Birth',
                          hintText: 'Your place of birth',
                          validator: (value) => FormValidator.validate(value, ValidatorType.isEmpty, fieldName: "Place of Birth"),
                          prefixIcon: const Icon(Icons.location_on),
                          fieldName: Fields.name,
                          onChanged: (value) {
                            userDetails.dateOfBirth = value;
                          },
                          controller: _controller.placeOfBirthController,
                        ),
                        SizedBox(height: 18.h),
                        DropdownTextField(
                          controller: _controller.PEP,
                          validator: (value) => FormValidator.validate(value, ValidatorType.isEmpty, fieldName: "Politically Exposed Person"),
                          onChange: (value) {
                            setState(() {
                              _controller.PEP.text = value ?? "";
                            });
                          },
                          options: const ["Yes", "No"],
                          labelText: 'P.E.P',
                          hintText: 'Politically Exposed Person?',
                          prefixIcon: Icons.gavel,
                          fieldName: 'P.E.P',
                          displayStringForOption: (options) => options,
                        ),
                        SizedBox(height: 18.h),
                        CustomTextField(
                          labelText: 'Referrer ID',
                          hintText: 'This field is optional',
                          prefixIcon: const Icon(Icons.people),
                          fieldName: Fields.name,
                          onChanged: (value) {
                            _controller.refby.text = value;                          },
                          controller: _controller.refby,
                        ),
                      ],
                    ),

                    SizedBox(height: 28.h),

                    // Submit Button
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32.w),
                      child: CustomButton(
                        text: "Update Profile",
                        size: ButtonSize.large,
                        backgroundColor: colorScheme.primary,
                        foregroundColor: Colors.white,
                        borderRadius: 12,
                        isDisabled:_isLoading,
                        type: ButtonType.elevated,
                        onPressed:_isLoading
                            ? null  // Disable the button when loading
                            : () async {
                          if (_formKey.currentState!.validate()// && _isBvnVerified
                          ) {
                            setState(() {
                             _isLoading = true;
                            });
                            try {
                              ResponseResult? resp = await _controller.createNewUserWallet();
                              if (resp?.status == ResponseStatus.failed) {
                                if (mounted) {
                                  setState(() {
                                   _isLoading = false;
                                  });
                                  CustomPopup.show(
                                    type: PopupType.error,
                                    context: context,
                                    title: "Error",
                                    message: resp?.message ?? "An error occurred",
                                  );
                                }
                              } else if (resp?.status == ResponseStatus.success) {
                                if (mounted) {
                                  // Show success popup
                                  CustomPopup.show(
                                    type: PopupType.success,
                                    context: context,
                                    title: "Success",
                                    message: resp?.message ?? "Operation successful",
                                  );

                                  // Wait for 1 second to show the popup
                                  await Future.delayed(const Duration(seconds: 1));

                                  // Check for passcode
                                  final storage = const FlutterSecureStorage();
                                  String? storedPasscode = await storage.read(key: 'passcode');
                                  bool hasPasscode = storedPasscode != null;

                                  setState(() {
                                   _isLoading = false;
                                  });

                                  // Dismiss the popup before navigation
                                  Navigator.of(context).pop(); // This dismisses the popup

                                  // Navigate after showing popup
                                  if (!mounted) return;
                                  if (!hasPasscode) {
                                    context.pushNamed("passcodesetup-screen");
                                  } else {
                                    context.goNamed("home");
                                  }
                                }
                              }
                            } catch (e) {
                              if (mounted) {
                                setState(() {
                                 _isLoading = false;
                                });
                                CustomPopup.show(
                                  type: PopupType.error,
                                  context: context,
                                  title: "Error",
                                  message: "An unexpected error occurred",
                                );
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
            // Loading overlay
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: Center(
                  child: Container(
                    padding: EdgeInsets.all(24.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          "Processing...",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

void ShowWidgetID(BuildContext context, bool verified, String firstName, String lastName, String email, String dateOfBirth, String gender, String bvn, {
  Function? onSuccess,
  Function(String)? onError,
  Function? onClose,
}) {


  final metaData = {
    "first_name": firstName,
    "last_name": lastName,
    "email": email,
    "dob": dateOfBirth,
    "gender": gender.toLowerCase(),
  };

  final govData = {
    "bvn": bvn,
    //"nin": "", // Keep empty for now
    "dl": "",
    "mobile": ""
  };

  final config = {
    'widget_id': dotenv.env['WIDGET_ID']
  };

  DojahKYC? _dojahKYC;
  _dojahKYC = DojahKYC(
    appId: dotenv.env['APP_ID']!,
    publicKey: dotenv.env['PUBLIC_KEY']!,
    type: "custom",
    userData: metaData,
    govData: govData,
    config: config,
  );
  print(govData);
  print(config);
  print(metaData);
  _dojahKYC.open(
      context,
      onSuccess: (result) {
        print(result);
        if (onSuccess != null) {
          onSuccess();
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Verification successful!'),
            backgroundColor: Colors.green,
          ),
        );
      },
      onClose: (close) {
        print('Widget Closed');
        if (onClose != null) {
          onClose();
        }
      },
      onError: (error) {
        print(error);
        if (onError != null) {
          onError(error.toString());
        }
        // Handle error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Verification failed: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
  );
}
String? validator(String? input) {
  if (input == null || input.isEmpty) {
    return "This field cannot be empty";
  } else {
    return null;
  }
}