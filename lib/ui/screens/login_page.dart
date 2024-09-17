import 'package:AXMPAY/models/ResponseModel.dart';
import 'package:AXMPAY/providers/user_service_provider.dart';
import 'package:AXMPAY/ui/widgets/custom_responsive_sizes/responsive_size.dart';
import 'package:AXMPAY/ui/widgets/custom_text/custom_apptext.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:AXMPAY/constants/text_constants.dart';
import 'package:AXMPAY/ui/widgets/custom_buttons.dart';
import 'package:AXMPAY/ui/widgets/custom_container.dart';
import 'package:AXMPAY/ui/widgets/custom_textfield.dart';

import '../../main.dart';
import '../../models/user_model.dart';
import '../../providers/authentication_provider.dart';
import '../widgets/custom_dialog.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthenticationProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title:  Text("Sign in to your account",style: TextStyle(color: colorScheme.primary.withOpacity(0.5)),),
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
                    'Welcome back!',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Please sign in to continue.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  SizedBox(height: 32.h),
                  buildTextField(
                    controller: _emailController,
                    labelText: 'Email',
                    hintText: 'Enter your email address',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: validateEmail,
                  ),
                  SizedBox(height: 16.h),
                  buildTextField(
                    controller: _passwordController,
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    prefixIcon: Icons.lock_outline,
                    obscureText: _obscurePassword,
                    validator: validatePassword,
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                      ),
                      onPressed: _isLoading ? null : () => _handleLogin(authProvider),
                      child: _isLoading
                          ? SizedBox(
                        height: 24.h,
                        width: 24.w,
                        child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                          : Text('Login', style: TextStyle(fontSize: 16.sp, color: Colors.white)),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Center(
                    child: TextButton(
                      onPressed: () =>  context.pushNamed("forgot_password_input_mail"),
                      child: Text(
                        'Forgot password?',
                        style: TextStyle(color: Theme.of(context).colorScheme.primary),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Center(
                    child: TextButton(
                      onPressed: () => context.pushNamed("register"),
                      child: Text(
                        "Don't have an account? Sign up",
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
    required String hintText,
    required IconData prefixIcon,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: Icon(prefixIcon),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
      ),
    );
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
    if (value.length < 4) {
      return 'Password must be at least 4 characters long';
    }
    return null;
  }

  void _handleLogin(AuthenticationProvider authProvider) async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      LoginDetails userDetails = LoginDetails(
        email: _emailController.text,
        password: _passwordController.text,
      );

      try {
        var resp = await authProvider.login(context, userDetails);
        UserServiceProvider userServiceProvider = Provider.of<UserServiceProvider>(context,listen: false);
        if (resp != null) {
          if(resp.status== ResponseStatus.failed){
            CustomPopup.show(
              context: context, message: resp.message,title: "Error:${resp.status}",
            );
            return;
          }
          if (userServiceProvider.userdata?.status == "Verified") {
           const storage = FlutterSecureStorage();
            bool hasPasscode = await storage.read(key: 'passcode')==null;
            if (hasPasscode) {
              if(!mounted) return;
              context.pushNamed("passcode_setup_screen");
            }else if(!hasPasscode){
              if(!mounted) return;
              context.goNamed("/home");
            }
          } else {
            if(!mounted) return;
            context.goNamed("user_details_page");
          }
        }
      } catch (e) {
        CustomPopup.show(
            context: context, message: 'Login failed: ${e.toString()}',title: "Error",
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }
}