import 'package:AXMPAY/ui/widgets/custom_responsive_sizes/responsive_size.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../main.dart';
import '../../../providers/user_service_provider.dart';
import '../../../utils/form_validator.dart';
import '../../widgets/custom_buttons.dart';
import '../../widgets/custom_dialog.dart';
import '../../widgets/custom_text/custom_apptext.dart';
import '../../widgets/custom_textfield.dart';

class ChangePasswordScreen extends StatefulWidget {
  final String email;
  final String otp;
   ChangePasswordScreen({Key? key, required this.email, required this.otp}) : super(key: key);

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _inputPasswordFormKey = GlobalKey<FormState>();
  late final TextEditingController _passOneController;
  late final TextEditingController _passTwoController;
  late final UserServiceProvider _userProvider;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _userProvider = Provider.of<UserServiceProvider>(context, listen: false);
    _passOneController = TextEditingController();
    _passTwoController = TextEditingController();
  }

  @override
  void dispose() {
    _passOneController.dispose();
    _passTwoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 40.h),
                Icon(Icons.lock_reset, size: 80.sp, color: colorScheme.primary),
                SizedBox(height: 24.h),
                AppText.headline("Change Your Password"),
                SizedBox(height: 8.h),
                AppText.body(
                  "Enter the new password you intend to use.",
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 40.h),
                _buildPasswordForm(),
                SizedBox(height: 24.h),
                _buildResetButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordForm() {
    return Form(
      key: _inputPasswordFormKey,
      child: Column(
        children: [
          CustomTextField(
            controller: _passOneController,
            // validator: (value) => FormValidator.validate(
            //   value,
            //   ValidatorType.password,
            //   fieldName: "Password",
            // ),
            fieldName: "New Password",
            hintText: "Enter new password",
            obscureText: true,
          ),
          SizedBox(height: 16.h),
          CustomTextField(
            controller: _passTwoController,
            validator: (value) => _checkInputtedPassword(value),
            fieldName: 'Confirm Password',
            hintText: "Confirm your password",
            obscureText: true,
          ),
        ],
      ),
    );
  }

  Widget _buildResetButton() {
    return CustomButton(
      text: "Reset Password",
      size: ButtonSize.large,
      isLoading: _isLoading,
      onPressed: _handleResetPassword,
    );
  }

  Future<void> _handleResetPassword() async {
    if (!_inputPasswordFormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final status = await _userProvider.changeUserPassword(
        context,
        widget.email,
        widget.otp,
        _passOneController.text,
      );

      if (status == "failed") {
        await _showErrorPopup("Email or OTP might be wrong");
      } else {
        await _showSuccessPopup();
        if (!mounted) return;
        context.goNamed("login");
      }
    } catch (e) {
      await _showErrorPopup("An unexpected error occurred");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showErrorPopup(String message) async {
    if (!mounted) return;
    await CustomPopup.show(
      backgroundColor: colorScheme.onPrimary,
      type: PopupType.error,
      title: "An Error Occurred",
      message: message,
      context: context,
    );
  }

  Future<void> _showSuccessPopup() async {
    if (!mounted) return;
    await CustomPopup.show(
      backgroundColor: colorScheme.onPrimary,
      type: PopupType.success,
      title: "Password Change Success",
      message: "Your password has been updated",
      context: context,
    );
  }

  String? _checkInputtedPassword(String? value) {
    if (value != _passOneController.text) {
      return "Passwords do not match";
    }
    return null;
  }
}