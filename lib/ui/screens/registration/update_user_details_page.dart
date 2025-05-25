import 'dart:async';

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
import '../../../utils/sharedPrefernce.dart';
import '../../widgets/custom_textfield.dart';
import 'dart:math';

class UpdateUserDetailsPage extends StatefulWidget {
  const UpdateUserDetailsPage({super.key});

  @override
  State<UpdateUserDetailsPage> createState() => _UpdateUserDetailsPageState();
}

class _UpdateUserDetailsPageState extends State<UpdateUserDetailsPage> {
  // Form and Controllers
  final _formKey = GlobalKey<FormState>();
  late RegistrationController _controller;
  final _scrollController = ScrollController();

  // State Variables
  bool _isScrolled = false;
  bool _isLoading = false;
  bool _isKYCLoading = false;
  bool _isBvnVerified = false;
  late UserDetails userDetails;
  String? _authToken;

  @override
  void initState() {
    super.initState();
    _controller = RegistrationController(context);
    _scrollController.addListener(_onScroll);
    _initializeUserData();
    _loadAuthToken();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ==================== INITIALIZATION METHODS ====================

  void _initializeUserData() {
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
        // TODO: Load user data from API or storage
        // final userData = await getUserDataFromApi();
        // _populateUserData(userData);
      } catch (e) {
        _showSnackBar('Failed to load user data: ${e.toString()}');
      }
    });
  }

  Future<void> _loadAuthToken() async {
    try {
      _authToken = await SharedPreferencesUtil.getString('auth_token');
      if (_authToken == null || _authToken!.isEmpty) {
        _showSnackBar('Authentication token not found. Please login again.');
        // TODO: Navigate to login screen
      }
    } catch (e) {
      _showSnackBar('Failed to load authentication token: ${e.toString()}');
    }
  }

  void _onScroll() {
    if (_scrollController.offset > 0 && !_isScrolled) {
      setState(() => _isScrolled = true);
    } else if (_scrollController.offset <= 0 && _isScrolled) {
      setState(() => _isScrolled = false);
    }
  }

  // ==================== VALIDATION METHODS ====================

  bool _validatePersonalDetails() {
    if (_controller.first_name.text.isEmpty || _controller.last_name.text.isEmpty) {
      _showSnackBar('Please fill all details in personal section before BVN verification');
      return false;
    }
    return true;
  }

  bool _validateAuthToken() {
    if (_authToken == null || _authToken!.isEmpty) {
      _showSnackBar('Authentication required. Please login again.');
      return false;
    }
    return true;
  }

  // ==================== BVN VERIFICATION METHODS ====================

// ==================== BVN VERIFICATION METHODS ====================

  Future<void> _verifyBVN() async {
    if (!_validateAuthToken()) return;

    if (_controller.bvn.text.isEmpty) {
      _showSnackBar('Please enter your BVN first');
      return;
    }

    if (!_validatePersonalDetails()) return;

    setState(() => _isKYCLoading = true);

    try {
      await _showDojahKYC(
        onSuccess: () {
          // Add a slight delay to ensure the widget has fully closed
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              setState(() {
                _isBvnVerified = true;
                _isKYCLoading = false;
              });
              _showSnackBar('BVN verified successfully', isSuccess: true);
            }
          });
        },
        onError: (String errorMessage) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              setState(() {
                _isBvnVerified = false;
                _isKYCLoading = false;
              });
              _showSnackBar('BVN verification failed: $errorMessage', isError: true);
            }
          });
        },
        onClose: () {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              setState(() {
                _isKYCLoading = false;
              });
              // Don't show canceled message if verification was successful
              if (!_isBvnVerified) {
                _showSnackBar('BVN verification canceled');
              }
            }
          });
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isKYCLoading = false);
        _showSnackBar('Failed to verify BVN: ${e.toString()}', isError: true);
      }
    }
  }

  Future<void> _showDojahKYC({
    Function? onSuccess,
    Function(String)? onError,
    Function? onClose,
  }) async {
    if (!_validateAuthToken()) return;

    if (_controller.bvn.text.isEmpty) {
      _showSnackBar('Please enter your BVN first');
      return;
    }

    if (!_validatePersonalDetails()) return;

    final metaData = {
      "first_name": _controller.first_name.text,
      "last_name": _controller.last_name.text,
      "email": _controller.emailController.text,
      "dob": _controller.date_of_birth.text,
      "gender": _controller.gender.text.toLowerCase(),
      "auth_token": _authToken,
    };

    final govData = {
      "bvn": _controller.bvn.text,
      "dl": "",
      "mobile": _controller.phone_number.text,
      "auth_token": _authToken,
    };

    final config = {
      'widget_id': dotenv.env['WIDGET_ID'],
      // Add these configuration options to handle redirection properly
      'redirect_url': 'app://close', // Custom URL scheme for your app
      'auto_close': true, // Automatically close after successful verification
      'close_on_success': true, // Close the widget on successful verification
    };

    try {
      final dojahKYC = DojahKYC(
        appId: dotenv.env['APP_ID']!,
        publicKey: dotenv.env['PUBLIC_KEY']!,
        type: "custom",
        userData: metaData,
        govData: govData,
        config: config,
      );

      print('MetaData: $metaData');
      print('GovData: $govData');
      print('Config: $config');

      dojahKYC.open(
        context,
        onSuccess: (result) {
          print('KYC Success: $result');
          // Force close any open web views or modals
          Navigator.of(context, rootNavigator: true).popUntil((route) => route.isFirst);

          if (onSuccess != null) {
            onSuccess();
          }
        },
        onClose: (close) {
          print('KYC Widget Closed: $close');
          // Ensure we're back to the main screen
          Navigator.of(context, rootNavigator: true).popUntil((route) => route.isFirst);

          if (onClose != null) {
            onClose();
          }
        },
        onError: (error) {
          print('KYC Error: $error');
          // Force close on error as well
          Navigator.of(context, rootNavigator: true).popUntil((route) => route.isFirst);

          if (onError != null) {
            onError(error.toString());
          }
        },
      );
    } catch (e) {
      print('DojahKYC Exception: $e');
      if (onError != null) {
        onError(e.toString());
      }
    }
  }

// Alternative method using Timer to handle stuck webview
  Future<void> _showDojahKYCWithTimeout({
    Function? onSuccess,
    Function(String)? onError,
    Function? onClose,
  }) async {if (!_validateAuthToken()) return;

    if (_controller.bvn.text.isEmpty) {
      _showSnackBar('Please enter your BVN first');
      return;
    }

    if (!_validatePersonalDetails()) return;

    // Set a timeout to handle cases where the widget gets stuck
    Timer? timeoutTimer;
    bool hasCompleted = false;

    void completeVerification() {
      if (!hasCompleted) {
        hasCompleted = true;
        timeoutTimer?.cancel();
      }
    }

    // Set a 5-minute timeout
    timeoutTimer = Timer(const Duration(minutes: 5), () {
      if (!hasCompleted) {
        print('KYC Timeout - forcing close');
        Navigator.of(context, rootNavigator: true).popUntil((route) => route.isFirst);
        if (mounted) {
          _showSnackBar('Verification timed out. Please try again.', isError: true);
          setState(() => _isKYCLoading = false);
        }
      }
    });

    final metaData = {
      "first_name": _controller.first_name.text,
      "last_name": _controller.last_name.text,
      "email": _controller.emailController.text,
      "dob": _controller.date_of_birth.text,
      "gender": _controller.gender.text.toLowerCase(),
      "auth_token": _authToken,
    };

    final govData = {
      "bvn": _controller.bvn.text,
      "dl": "",
      "mobile": _controller.phone_number.text,
      "auth_token": _authToken,
    };

    final config = {
      'widget_id': dotenv.env['WIDGET_ID'],
      'redirect_url': 'app://close',
      'auto_close': true,
      'close_on_success': true,
    };

    try {
      final dojahKYC = DojahKYC(
        appId: dotenv.env['APP_ID']!,
        publicKey: dotenv.env['PUBLIC_KEY']!,
        type: "custom",
        userData: metaData,
        govData: govData,
        config: config,
      );

      dojahKYC.open(
        context,
        onSuccess: (result) {
          completeVerification();
          print('KYC Success: $result');

          // Force navigation back to your app
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context, rootNavigator: true).popUntil((route) => route.isFirst);
          });

          if (onSuccess != null) {
            onSuccess();
          }
        },
        onClose: (close) {
          completeVerification();
          print('KYC Widget Closed: $close');

          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context, rootNavigator: true).popUntil((route) => route.isFirst);
          });

          if (onClose != null) {
            onClose();
          }
        },
        onError: (error) {
          completeVerification();
          print('KYC Error: $error');

          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context, rootNavigator: true).popUntil((route) => route.isFirst);
          });

          if (onError != null) {
            onError(error.toString());
          }
        },
      );
    } catch (e) {
      completeVerification();
      print('DojahKYC Exception: $e');
      if (onError != null) {
        onError(e.toString());
      }
    }
  }

// Enhanced BVN Section with better UX

  // ==================== FORM SUBMISSION ====================

  Future<void> _handleFormSubmission() async {
    if (!_validateAuthToken()) return;

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Include auth token in the request
      ResponseResult? resp = await _controller.createNewUserWallet();

      if (!mounted) return;

      setState(() => _isLoading = false);

      if (resp?.status == ResponseStatus.failed) {
        _showErrorPopup(resp?.message ?? "An error occurred");
      } else if (resp?.status == ResponseStatus.success) {
        await _handleSuccessfulSubmission(resp?.message ?? "Operation successful");
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        print("Error occurred: ${e.toString()}");
        _showErrorPopup("An unexpected error occurred: ${e.toString()}");
      }
    }
  }

  Future<void> _handleSuccessfulSubmission(String message) async {
    _showSuccessPopup(message);

    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    try {
      final storage = const FlutterSecureStorage();
      String? storedPasscode = await storage.read(key: 'passcode');
      bool hasPasscode = storedPasscode != null;

      String userEmail = _getUserEmail();

      if (!hasPasscode) {
        context.pushReplacementNamed(
            "passcode_setup_screen",
            pathParameters: {"email": userEmail}
        );
      } else {
        context.goNamed("home");
      }
    } catch (navError) {
      print("Navigation error: ${navError.toString()}");
      if (mounted) {
        _showSnackBar("Navigation error: Please restart the app", isError: true);
      }
    }
  }

  String _getUserEmail() {
    return _controller.emailController.text.isNotEmpty
        ? _controller.emailController.text
        : userDetails.email.isNotEmpty
        ? userDetails.email
        : "user@example.com";
  }

  // ==================== UI HELPER METHODS ====================

  void _showSnackBar(String message, {bool isSuccess = false, bool isError = false}) {
    if (!mounted) return;

    Color backgroundColor = colorScheme.primary;
    if (isSuccess) backgroundColor = Colors.green;
    if (isError) backgroundColor = Colors.red;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorPopup(String message) {
    CustomPopup.show(
      type: PopupType.error,
      context: context,
      title: "Error",
      message: message,
    );
  }

  void _showSuccessPopup(String message) {
    CustomPopup.show(
      type: PopupType.success,
      context: context,
      title: "Success",
      message: message,
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
          _buildSectionHeader(title, icon),
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

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
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
    );
  }

  Widget _buildProfileHeader() {
    return Center(
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
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
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
    );
  }

  // ==================== BUILD METHOD ====================

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
                    _buildProfileHeader(),
                    SizedBox(height: 28.h),
                    _buildBasicInformationSection(),
                    _buildPersonalInformationSection(),
                    SizedBox(height: 28.h),
                    _buildSubmitButton(),
                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ),
            if (_isLoading) _buildLoadingOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInformationSection() {
    return _buildSectionCard(
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
                onChanged: (value) => userDetails.lastName = value,
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
          onChanged: (value) => userDetails.email = value,
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
    );
  }

  Widget _buildPersonalInformationSection() {
    return _buildSectionCard(
      title: 'Personal Information',
      icon: Icons.assignment_ind,
      children: [
        DatePickerTextField(
          context: context,
          dateFormat: DateFormat("yyy-MM-dd"),
          onChange: (value) {
            userDetails.dateOfBirth = value ?? "";
            setState(() {
              _controller.date_of_birth.text = value ?? "";
            });
          },
          dateController: _controller.date_of_birth,
          validator: (value) => FormValidator.validate(
              value, ValidatorType.isEmpty,
              fieldName: "date of birth"
          ),
        ),
        SizedBox(height: 18.h),
        _buildBVNSection(),
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
            _controller.refby.text = value;
          },
          controller: _controller.refby,
        ),
      ],
    );
  }
  Widget _buildBVNSection() {
    return Column(
      children: [
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
                  _controller.bvn.text = value ?? "";
                  // Reset verification status when BVN changes
                  if (_isBvnVerified) {
                    setState(() {
                      _isBvnVerified = false;
                    });
                  }
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
                onPressed: _isKYCLoading ? null : _verifyBVN,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isKYCLoading
                      ? colorScheme.primary.withOpacity(0.5)
                      : colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 15.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isKYCLoading
                    ? SizedBox(
                  width: 16.w,
                  height: 16.h,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                    : Text('Verify'),
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        if (_isBvnVerified)
          Container(
            padding: EdgeInsets.all(12.h),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 20.w),
                SizedBox(width: 8.w),
                Text(
                  'BVN Successfully Verified',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )
        else if (!_isKYCLoading)
          Center(
            child: TextButton.icon(
              onPressed: () => _showDojahKYC(),
              icon: Icon(Icons.verified_user, color: colorScheme.primary),
              label: Text(
                'Complete KYC Verification',
                style: TextStyle(color: colorScheme.primary),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.w),
      child: CustomButton(
        text: "Update Profile",
        size: ButtonSize.large,
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        borderRadius: 12,
        isDisabled: _isLoading,
        type: ButtonType.elevated,
        onPressed: _isLoading ? null : _handleFormSubmission,
      ),
    );
  }
}

// ==================== UTILITY FUNCTIONS ====================

String? validator(String? input) {
  if (input == null || input.isEmpty) {
    return "This field cannot be empty";
  }
  return null;
}