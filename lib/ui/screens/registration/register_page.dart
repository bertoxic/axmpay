import 'dart:convert';
import 'package:AXMPAY/main.dart';
import 'package:AXMPAY/providers/user_service_provider.dart';
import 'package:AXMPAY/ui/widgets/custom_responsive_sizes/responsive_size.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../constants/text_constants.dart';
import '../../../models/user_model.dart';
import '../../../providers/authentication_provider.dart';
import '../../widgets/custom_container.dart';
import '../../widgets/custom_text/custom_apptext.dart';
import '../../widgets/custom_textfield.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late UserServiceProvider userServiceProvider;
  PreRegisterDetails registerDetails = PreRegisterDetails(lastName: "", firstName: "", password: "", email: "");
  bool isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) =>
    userServiceProvider = Provider.of<UserServiceProvider>(context, listen: false)
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create your account'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.onBackground,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome!',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Please fill in your details to create an account.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  SizedBox(height: 32.h),
                  buildTextField(
                    controller: _firstNameController,
                    labelText: 'First Name',
                    prefixIcon: Icons.person_outline,
                    onChanged: (value) => registerDetails.firstName = value,
                  ),
                  SizedBox(height: 16.h),
                  buildTextField(
                    controller: _lastNameController,
                    labelText: 'Last Name',
                    prefixIcon: Icons.person_outline,
                    onChanged: (value) => registerDetails.lastName = value,
                  ),
                  SizedBox(height: 16.h),
                  buildTextField(
                    controller: _emailController,
                    labelText: 'Email',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (value) => registerDetails.email = value,
                    validator: (value) => validateEmail(value),
                  ),
                  SizedBox(height: 16.h),
                  buildTextField(
                    controller: _passwordController,
                    labelText: 'Password',
                    prefixIcon: Icons.lock_outline,
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    validator: (value) => validatePassword(value),
                  ),
                  SizedBox(height: 16.h),
                  buildTextField(
                    controller: _confirmPasswordController,
                    labelText: 'Confirm Password',
                    prefixIcon: Icons.lock_outline,
                    obscureText: _obscureConfirmPassword,
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                    ),
                    validator: (value) => validateConfirmPassword(value, _passwordController.text),
                  ),
                  SizedBox(height: 32.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: isLoading ? null : _handleRegistration,
                      child: isLoading
                          ? SizedBox(
                        height: 24.h,
                        width: 24.w,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                          : Text('Sign Up', style: TextStyle(fontSize: 16.sp)),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Center(
                    child: TextButton(
                      onPressed: () => context.pushNamed("login"),
                      child: Text(
                        'Already have an account? Sign in',
                        style: TextStyle(color: Theme.of(context).colorScheme.primary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData prefixIcon,
     String? fieldName,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    void Function(String)? onChanged,
    String? Function(String?)? validator,
  }) {
    return CustomTextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      onChanged: onChanged,
      validator: validator,
        labelText: labelText,
        prefixIcon: Icon(prefixIcon),
        suffixIcon: suffixIcon,
      // decoration: InputDecoration(
      //   labelText: labelText,
      //   prefixIcon: Icon(prefixIcon),
      //   suffixIcon: suffixIcon,
      //   border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      //   filled: true,
      //   fillColor: Theme.of(context).colorScheme.surface,
      // ),
      fieldName: fieldName??"",
    );
  }

  void _handleRegistration() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);

      registerDetails.password = _confirmPasswordController.text;

      try {
        String status = await userServiceProvider.createAccount(context, registerDetails);
        print(status);

        if (mounted) {
          context.pushNamed(
            "verify_new_user_email_screen",
            pathParameters: {'preRegistrationString': jsonEncode(registerDetails.toJSON())},
          );
        }
      } catch (e) {
        print('Error creating account: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create account: $e')),
        );
      } finally {
        if (mounted) {
          setState(() => isLoading = false);
        }
      }
    }
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    return null;
  }

  String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }
}