import 'dart:async';

import 'package:AXMPAY/constants/lists.dart';
import 'package:AXMPAY/models/ResponseModel.dart';
import 'package:AXMPAY/ui/screens/registration/registration_controller.dart';
import 'package:AXMPAY/ui/widgets/custom_buttons.dart';
import 'package:AXMPAY/ui/widgets/custom_dialog.dart';
import 'package:AXMPAY/ui/widgets/custom_dropdown.dart';
import 'package:AXMPAY/ui/widgets/custom_responsive_sizes/responsive_size.dart';
import 'package:flutter/foundation.dart';
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

class _UpdateUserDetailsPageState extends State<UpdateUserDetailsPage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  // Form and Controllers
  final _formKey = GlobalKey<FormState>();
  late RegistrationController _controller;
  final _scrollController = ScrollController();

  // State Variables
  bool _isScrolled = false;
  bool _isLoading = false;
  bool _isKYCLoading = false;
  bool _isNINVerified = false;
  late UserDetails userDetails;
  String? _authToken;

  @override
  void initState() {
    super.initState();
    _controller = RegistrationController(context);
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addObserver(this);
    _initializeUserData();
    _loadAuthToken();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
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
        if (mounted) {
          context.go('/login');
        }
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
    if (_controller.first_name.text.isEmpty ||
        _controller.last_name.text.isEmpty) {
      _showSnackBar(
          'Please fill all details in personal section before NIN verification');
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

  Future<void> _verifyNIN() async {
    if (!_validateAuthToken()) return;

    if (_controller.nin.text.isEmpty) {
      _showSnackBar('Please enter your NIN first');
      return;
    }

    if (!_validatePersonalDetails()) return;

    setState(() {
      _isKYCLoading = true;
      _isNINVerified = false;
    });

    try {
      await _showDojahKYCWithProperCleanup(
        onSuccess: () {
          print("KYC Success - NIN Verified");
          if (mounted) {
            setState(() {
              _isNINVerified = true;
              _isKYCLoading =
                  false; // Ensure loading is set to false on success
            });
            _showSnackBar('NIN verified successfully', isSuccess: true);
          }
        },
        onError: (String errorMessage) {
          print("KYC Error: $errorMessage");
          if (mounted) {
            setState(() {
              _isNINVerified = false;
              _isKYCLoading = false; // Set loading to false on error
            });
            _showSnackBar('NIN verification failed: $errorMessage',
                isError: true);
          }
        },
        onClose: () {
          print("KYC Widget Closed/Canceled");
          if (mounted) {
            setState(() {
              _isKYCLoading =
                  false; // Set loading to false when closed/canceled
              if (!_isNINVerified) {
                _showSnackBar('NIN verification was canceled');
              }
            });
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isKYCLoading = false; // Set loading to false on exception
          _isNINVerified = false;
        });
        _showSnackBar('Failed to verify NIN: ${e.toString()}', isError: true);
      }
    }
  }

  Future<void> _showDojahKYCWithProperCleanup({
    Function? onSuccess,
    Function(String)? onError,
    Function? onClose,
  }) async {
    if (!_validateAuthToken()) return;

    if (_controller.nin.text.isEmpty) {
      _showSnackBar('Please enter your NIN first');
      return;
    }

    if (!_validatePersonalDetails()) return;

    bool hasSucceeded = false;
    bool hasCompleted = false;
    bool isDisposed = false;

    // Safety cleanup function
    void safeCleanup() {
      if (!isDisposed) {
        isDisposed = true;
        if (mounted) {
          // Use a post-frame callback to ensure UI is stable
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _isKYCLoading) {
              setState(() {
                _isKYCLoading = false;
              });
            }
          });
        }
      }
    }

    Timer? safetyTimer = Timer(const Duration(minutes: 10), () {
      if (mounted && _isKYCLoading && !hasCompleted) {
        print('Safety timeout triggered - cleaning up KYC');
        safeCleanup();
        _showSnackBar('Verification timed out. Please try again.',
            isError: true);
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
      "nin": _controller.nin.text,
      "dl": "",
      "mobile": _controller.phone_number.text,
      "auth_token": _authToken,
    };

    final config = {
      'widget_id': dotenv.env['WIDGET_ID'],
      'redirect_url': 'app://close',
      'auto_close': true,
      'close_on_success': true,
      'debug': false,
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

      print('Starting KYC verification...');

      try {
        dojahKYC.open(
          context,
          onSuccess: (result) {
            print('KYC Success: $result');
            hasSucceeded = true;
            hasCompleted = true;
            safetyTimer?.cancel();

            // Let the onClose handle navigation since it will be called anyway
            if (onSuccess != null) {
              onSuccess();
            }
          },
          onClose: (close) {
            print('KYC Widget Closed: $close');

            // Update loading state immediately but don't navigate yet
            if (mounted) {
              setState(() {
                _isKYCLoading = false;
              });
            }

            if (!hasCompleted) {
              hasCompleted = true;
              safetyTimer.cancel();
            }

            // Handle navigation in post-frame callback
            WidgetsBinding.instance.addPostFrameCallback((_) {
              safeCleanup();

              // Only navigate back once, and only if needed
              try {
                if (context.canPop() && mounted) {
                  context.pop();
                }
              } catch (navError) {
                print('Navigation cleanup error (non-critical): $navError');
              }

              // Call onClose callback only if verification wasn't successful
              if (onClose != null && !hasSucceeded) {
                onClose();
              }
            });
          },
          onError: (error) {
            print('KYC Error: $error');
            hasCompleted = true;
            safetyTimer?.cancel();

            WidgetsBinding.instance.addPostFrameCallback((_) {
              safeCleanup();

              try {
                if (context.canPop() && mounted) {
                  context.pop();
                }
              } catch (navError) {
                print('Navigation cleanup error (non-critical): $navError');
              }

              if (onError != null) {
                onError(error.toString());
              }
            });
          },
        );
      } catch (openError) {
        print('Error opening KYC widget: $openError');
        hasCompleted = true;
        safetyTimer?.cancel();
        safeCleanup();

        if (onError != null) {
          onError('Failed to open verification: ${openError.toString()}');
        }
      }
    } catch (e) {
      print('DojahKYC Setup Exception: $e');
      hasCompleted = true;
      safetyTimer?.cancel();
      safeCleanup();

      if (onError != null) {
        onError('Setup failed: ${e.toString()}');
      }
    }
  }

// Enhanced app lifecycle handling
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.paused:
        // App is going to background
        if (_isKYCLoading) {
          print('App paused during KYC - will check on resume');
        }
        break;

      case AppLifecycleState.resumed:
        // App came back to foreground
        if (_isKYCLoading) {
          if (kDebugMode) {
            print('App resumed - checking KYC state');
          }
          // Give some time for the KYC widget to properly restore or cleanup
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted && _isKYCLoading && !_isNINVerified) {
              if (kDebugMode) {
                print('Cleaning up stuck KYC state after app resume');
              }
              setState(() {
                _isKYCLoading = false;
              });
              _showSnackBar('Please complete NIN verification');
            }
          });
        }
        break;

      case AppLifecycleState.detached:
        // App is being terminated
        if (_isKYCLoading) {
          _isKYCLoading = false;
        }
        break;

      default:
        break;
    }
  }

// Enhanced PopScope handling
  Widget buildEnhancedPopScope() {
    return PopScope(
      canPop: true, // Always allow back navigation
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (_isKYCLoading) {
          if (kDebugMode) {
            print('Back pressed during KYC - cleaning up');
          } // Clean up state
          setState(() {
            _isKYCLoading = false;
            _isNINVerified = false;
          });

          try {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context, rootNavigator: true)
                    .popUntil((route) => route.isFirst);
              }
            });
          } catch (e) {
            if (kDebugMode) {
              print('Cleanup error (non-critical): $e');
            }
          }

          _showSnackBar('KYC verification cancelled');
        }
      },
      child: buildMainScaffold(context), // Your existing scaffold code
    );
  }

  Future<void> _showDojahKYC({
    Function? onSuccess,
    Function(String)? onError,
    Function? onClose,
  }) async {
    if (!_validateAuthToken()) return;

    if (_controller.nin.text.isEmpty) {
      _showSnackBar('Please enter your NIN first');
      return;
    }

    if (!_validatePersonalDetails()) return;

    bool hasSucceeded = false;
    bool hasCompleted = false;

    // Add a safety timeout to reset loading state if widget gets stuck
    Timer? safetyTimer = Timer(const Duration(seconds: 30), () {
      if (mounted && _isKYCLoading && !hasCompleted) {
        print('Safety timeout triggered - resetting KYC loading state');
        setState(() {
          _isKYCLoading = false;
          _isNINVerified = false;
        });
        _showSnackBar('Verification timed out. Please try again.',
            isError: true);
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
      "nin": _controller.nin.text,
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

      print('MetaData: $metaData');
      print('GovData: $govData');
      print('Config: $config');

      dojahKYC.open(
        context,
        onSuccess: (result) {
          hasSucceeded = true;
          hasCompleted = true;
          safetyTimer?.cancel();

          print('KYC Success: $result');

          // Force close any open web views or modals
          Navigator.of(context, rootNavigator: true)
              .popUntil((route) => route.isFirst);

          if (onSuccess != null) {
            onSuccess();
          }
        },
        onClose: (close) {
          if (!hasCompleted) {
            hasCompleted = true;
            safetyTimer?.cancel();
          }

          print('KYC Widget Closed: $close');

          // Ensure we're back to the main screen
          Navigator.of(context, rootNavigator: true)
              .popUntil((route) => route.isFirst);

          // Always reset loading state on close, regardless of success
          if (mounted) {
            setState(() {
              _isKYCLoading = false;
            });
          }

          // Only call onClose if verification didn't succeed
          if (onClose != null && !hasSucceeded) {
            onClose();
          }
        },
        onError: (error) {
          hasCompleted = true;
          safetyTimer?.cancel();

          print('KYC Error: $error');

          // Force close on error as well
          Navigator.of(context, rootNavigator: true)
              .popUntil((route) => route.isFirst);

          if (onError != null) {
            onError(error.toString());
          }
        },
      );
    } catch (e) {
      hasCompleted = true;
      safetyTimer.cancel();

      print('DojahKYC Exception: $e');

      if (mounted) {
        setState(() {
          _isKYCLoading = false;
          _isNINVerified = false;
        });
      }

      if (onError != null) {
        onError(e.toString());
      }
    }
  }

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
        await _handleSuccessfulSubmission(
            resp?.message ?? "Operation successful");
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
        context.pushReplacementNamed("passcode_setup_screen",
            pathParameters: {"email": userEmail});
      } else {
        if (mounted) {
          context.goNamed("home");
        }
      }
    } catch (navError) {
      print("Navigation error: ${navError.toString()}");
      if (mounted) {
        _showSnackBar("Navigation error: Please restart the app",
            isError: true);
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

  void _showSnackBar(String message,
      {bool isSuccess = false, bool isError = false}) {
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

  Widget _buildSectionCard(
      {required String title,
      required List<Widget> children,
      required IconData icon}) {
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

  Widget buildMainScaffold(BuildContext context) {
    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: const Text('Update Profile'),
        elevation: _isScrolled ? 2 : 0,
        backgroundColor: _isScrolled ? colorScheme.surface : Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.primary),
          onPressed: () {
            // Reset KYC loading state when back button is pressed
            if (_isKYCLoading) {
              setState(() {
                _isKYCLoading = false;
                _isNINVerified = false;
              });
              _showSnackBar('KYC verification cancelled');
            }
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    SizedBox(height: 20.h),
                    _buildProfileHeader(),
                    SizedBox(height: 28.h),
                    _buildBasicInformationSection(),
                    _buildAddressInformationSection(),
                    _buildPersonalInformationSection(),
                    SizedBox(height: 28.h),
                    _buildSubmitButton(),
                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading) _buildLoadingOverlay(),
        ],
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
                validator: (value) => FormValidator.validate(
                    value, ValidatorType.isEmpty,
                    fieldName: "firstName"),
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
                validator: (value) => FormValidator.validate(
                    value, ValidatorType.isEmpty,
                    fieldName: "lastName"),
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
          validator: (value) => FormValidator.validate(
              value, ValidatorType.email,
              fieldName: Fields.email),
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
          validator: (value) => FormValidator.validate(
              value, ValidatorType.isEmpty,
              fieldName: "Phone number"),
        ),
      ],
    );
  }


  List<String> _getCountryNames() {
    return CountryMap.map((country) => country['name'] as String).toList();
  }

  List<String> _getStatesForCountry(String countryName) {
    final country = CountryMap.firstWhere(
          (country) => country['name'] == countryName,
      orElse: () => {'states': <String>[]},
    );
    return List<String>.from(country['states'] ?? []);
  }

  void _onCountryChanged(String? countryName) {
    setState(() {
      _controller.country.text = countryName ?? "";
      // Clear state when country changes
      _controller.state.text = "";
    });
  }

// Updated widget method
  Widget _buildAddressInformationSection() {
    return _buildSectionCard(
      title: 'Address Information',
      icon: Icons.location_on,
      children: [
        Row(
          children: [
            Expanded(
              child: DropdownTextField(
                controller: _controller.country,
                validator: (value) => FormValidator.validate(
                    value, ValidatorType.isEmpty,
                    fieldName: "country"),
                onChange: _onCountryChanged,
                options: _getCountryNames(),
                labelText: 'Country',
                hintText: 'Select country',
                prefixIcon: Icons.flag,
                fieldName: 'Country',
                displayStringForOption: (options) => options,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: DropdownTextField(
                controller: _controller.state,
                validator: (value) => FormValidator.validate(
                    value, ValidatorType.isEmpty,
                    fieldName: "state"),
                onChange: (value) {
                  setState(() {
                    _controller.state.text = value ?? "";
                  });
                },
                options: _controller.country.text.isNotEmpty
                    ? _getStatesForCountry(_controller.country.text)
                    : [],
                labelText: 'State',
                hintText: _controller.country.text.isEmpty
                    ? 'Select country first'
                    : 'Select state',
                prefixIcon: Icons.map,
                fieldName: 'State',
                displayStringForOption: (options) => options,
                // Disable the field if no country is selected

               // enabled: _controller.country.text.isNotEmpty,
              ),
            ),
          ],
        ),
        SizedBox(height: 18.h),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                labelText: 'City',
                hintText: 'Enter city',
                prefixIcon: const Icon(Icons.location_city),
                fieldName: "Fields.city",
                validator: (value) => FormValidator.validate(
                    value, ValidatorType.isEmpty,
                    fieldName: "city"),
                onChanged: (value) {
                  setState(() {
                    _controller.city.text = value ?? "";
                  });
                },
                controller: _controller.city,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: CustomTextField(
                labelText: 'Postal Code',
                hintText: 'Enter postal code',
                prefixIcon: const Icon(Icons.local_post_office),
                fieldName: "Fields.postalCode",
                validator: (value) => FormValidator.validate(
                    value, ValidatorType.isEmpty,
                    fieldName: "postal code"),
                onChanged: (value) {
                  setState(() {
                    _controller.zipCode.text = value ?? "";
                  });
                },
                controller: _controller.zipCode,
              ),
            ),
          ],
        ),
        SizedBox(height: 18.h),
        CustomTextField(
          labelText: 'Street Address',
          hintText: 'Enter your street address',
          prefixIcon: const Icon(Icons.home),
          fieldName: "streetAddress",
          validator: (value) => FormValidator.validate(
              value, ValidatorType.isEmpty,
              fieldName: "street address"),
          onChanged: (value) {
            setState(() {
              _controller.streetAddress.text = value ?? "";
            });
          },
          controller: _controller.streetAddress,
        ),
        SizedBox(height: 18.h),
        CustomTextField(
          labelText: 'Landmark (Optional)',
          hintText: 'Enter a nearby landmark',
          prefixIcon: const Icon(Icons.place),
          fieldName: "Fields.landmark",
          onChanged: (value) {
            setState(() {
              _controller.nearestLandMark.text = value ?? "";
            });
          },
          controller: _controller.nearestLandMark,
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
              fieldName: "date of birth"),
        ),
        SizedBox(height: 18.h),
        _buildNINSection(),
        SizedBox(height: 18.h),
        DropdownTextField(
          controller: _controller.PEP,
          validator: (value) => FormValidator.validate(
              value, ValidatorType.isEmpty,
              fieldName: "Politically Exposed Person"),
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

  Widget _buildNINSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 7,
              child: CustomTextField(
                labelText: 'NIN',
                hintText: 'Input your valid NIN',
                validator: (value) => FormValidator.validate(
                    value, ValidatorType.digits,
                    fieldName: "NIN"),
                prefixIcon: const Icon(Icons.perm_identity),
                fieldName: Fields.name,
                onChanged: (value) {
                  _controller.nin.text = value ?? "";
                  setState(() {
                    _isKYCLoading = false;
                  });
                  if (_isNINVerified && value != null && value.isNotEmpty) {
                    setState(() {
                      _isNINVerified = false;
                    });
                  }
                },
                controller: _controller.nin,
                suffixIcon: _isNINVerified
                    ? Icon(Icons.check_circle, color: Colors.green, size: 24.w)
                    : null,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              flex: 3,
              child: ElevatedButton(
                onPressed:
                    (_isKYCLoading || _isNINVerified) ? null : _verifyNIN,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isNINVerified
                      ? Colors.green
                      : _isKYCLoading
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
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(_isNINVerified ? 'Verified' : 'Verify'),
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        if (_isNINVerified)
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
                Expanded(
                  child: Text(
                    'NIN Successfully Verified',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                // Add a button to retry verification if needed
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isNINVerified = false;
                    });
                  },
                  child: Text(
                    'Re-verify',
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
              ],
            ),
          )
        else if (!_isKYCLoading)
          Center(
            child: TextButton.icon(
              onPressed: () => _verifyNIN(),
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

  @override
  Widget build(BuildContext context) {
    return buildEnhancedPopScope();
  }
}

// ==================== UTILITY FUNCTIONS ====================

String? validator(String? input) {
  if (input == null || input.isEmpty) {
    return "This field cannot be empty";
  }
  return null;
}
