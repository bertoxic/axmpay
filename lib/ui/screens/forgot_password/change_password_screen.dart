import 'package:AXMPAY/models/ResponseModel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/user_service_provider.dart';
import '../../../utils/form_validator.dart';
import '../../widgets/custom_buttons.dart';
import '../../widgets/custom_dialog.dart';
import '../../widgets/custom_text/custom_apptext.dart';
import '../../widgets/custom_textfield.dart';

class ChangePasswordScreen extends StatefulWidget {
  final String? email;
  final String? otp;

  const ChangePasswordScreen({
    Key? key,
    this.email,
    this.otp,
  }) : super(key: key);

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _passwordFormKey = GlobalKey<FormState>();

  late final TextEditingController _oldPasswordController;
  late final TextEditingController _newPasswordController;
  late final TextEditingController _confirmPasswordController;
  late final UserServiceProvider _userProvider;

  bool _isLoading = false;
  bool _oldPasswordVisible = false;
  bool _newPasswordVisible = false;
  bool _confirmPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _userProvider = Provider.of<UserServiceProvider>(context, listen: false);
    _oldPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.primary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.06,
              vertical: size.height * 0.02,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: size.height * 0.03),
                _buildHeader(colorScheme, size),
                SizedBox(height: size.height * 0.05),
                _buildPasswordForm(colorScheme, size),
                SizedBox(height: size.height * 0.04),
                _buildChangeButton(colorScheme, size),
                SizedBox(height: size.height * 0.02),
                _buildPasswordRequirements(colorScheme, size),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme, Size size) {
    return Column(
      children: [
        Container(
          height: size.width * 0.2,
          width: size.width * 0.2,
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.lock_reset,
            size: size.width * 0.12,
            color: colorScheme.primary,
          ),
        ),
        SizedBox(height: size.height * 0.025),
        Text(
          "Change Your Password",
          style: TextStyle(
            fontSize: size.width * 0.06,
            fontWeight: FontWeight.bold,
            color: colorScheme.onBackground,
          ),
        ),
        SizedBox(height: size.height * 0.01),
        Text(
          "Create a strong password to keep your account secure",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: size.width * 0.04,
            color: colorScheme.onBackground.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordForm(ColorScheme colorScheme, Size size) {
    return Form(
      key: _passwordFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current Password
          _buildPasswordField(
            controller: _oldPasswordController,
            label: "Current Password",
            hint: "Enter your current password",
            isPasswordVisible: _oldPasswordVisible,
            toggleVisibility: () => setState(() => _oldPasswordVisible = !_oldPasswordVisible),
            validator: (value) => FormValidator.validate(
              value,
              ValidatorType.digits,
              fieldName: "Current password",
            ),
          ),
          SizedBox(height: size.height * 0.025),

          // New Password
          _buildPasswordField(
            controller: _newPasswordController,
            label: "New Password",
            hint: "Enter your new password",
            isPasswordVisible: _newPasswordVisible,
            toggleVisibility: () => setState(() => _newPasswordVisible = !_newPasswordVisible),
            validator: (value) => FormValidator.validate(
              value,
              ValidatorType.digits,
              fieldName: "New password",
            ),
          ),
          SizedBox(height: size.height * 0.025),

          // Confirm New Password
          _buildPasswordField(
            controller: _confirmPasswordController,
            label: "Confirm New Password",
            hint: "Confirm your new password",
            isPasswordVisible: _confirmPasswordVisible,
            toggleVisibility: () => setState(() => _confirmPasswordVisible = !_confirmPasswordVisible),
            validator: (value) => _validateConfirmPassword(value),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isPasswordVisible,
    required Function() toggleVisibility,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: !isPasswordVisible,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.grey.withOpacity(0.1),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey,
              ),
              onPressed: toggleVisibility,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChangeButton(ColorScheme colorScheme, Size size) {
    return SizedBox(
      width: double.infinity,
      height: size.height * 0.06,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleChangePassword,
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(
            color: colorScheme.onPrimary,
            strokeWidth: 2.5,
          ),
        )
            : const Text(
          "Change Password",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordRequirements(ColorScheme colorScheme, Size size) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Password Requirements:",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 8),
          _buildRequirementItem("At least 8 characters long"),
          _buildRequirementItem("At least one uppercase letter"),
          _buildRequirementItem("At least one number"),
          _buildRequirementItem("At least one special character"),
        ],
      ),
    );
  }

  Widget _buildRequirementItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 16,
            color: Colors.green,
          ),
          SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  String? _validateConfirmPassword(String? value) {
    if (value != _newPasswordController.text) {
      return "Passwords do not match";
    }
    if (value == null || value.isEmpty) {
      return "Please confirm your password";
    }
    return null;
  }

  Future<void> _handleChangePassword() async {
    if (!_passwordFormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final success = await _userProvider.changePassword(
        context,
        oldPassword: _oldPasswordController.text,
        newPassword: _newPasswordController.text,
      );

      if (success?.status != ResponseStatus.failed) {
        await _showSuccessPopup();
      } else {
        await _showErrorPopup("Failed to change password. Please check your current password.");
      }
    } catch (e) {
      await _showErrorPopup("An unexpected error occurred: ${e.toString()}");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showErrorPopup(String message) async {
    if (!mounted) return;
    await CustomPopup.show(
      backgroundColor: Theme.of(context).colorScheme.onPrimary,
      type: PopupType.error,
      title: "Error",
      message: message,
      context: context,
    );
  }

  Future<void> _showSuccessPopup() async {
    if (!mounted) return;
    await CustomPopup.show(
      backgroundColor: Theme.of(context).colorScheme.onPrimary,
      type: PopupType.success,
      title: "Success",
      message: "Your password has been changed successfully.",
      context: context,
    );
  }
}