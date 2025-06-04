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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Change Password',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF1E293B),
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.05,
              vertical: size.height * 0.02,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: size.height * 0.02),
                _buildHeader(colorScheme, size),
                SizedBox(height: size.height * 0.04),
                _buildPasswordForm(colorScheme, size),
                SizedBox(height: size.height * 0.03),
                _buildChangeButton(colorScheme, size),
                SizedBox(height: size.height * 0.025),
                _buildPasswordRequirements(colorScheme, size),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme, Size size) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF667EEA),
            Color(0xFF764BA2),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667EEA).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: size.width * 0.16,
            width: size.width * 0.16,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.security,
              size: size.width * 0.08,
              color: Colors.white,
            ),
          ),
          SizedBox(height: size.height * 0.02),
          const Text(
            "Secure Your Account",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: size.height * 0.008),
          const Text(
            "Update your password to keep your account protected",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordForm(ColorScheme colorScheme, Size size) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: _passwordFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Password Details",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 20),

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
              icon: Icons.lock_outline,
              color: const Color(0xFF64748B),
            ),
            const SizedBox(height: 20),

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
              icon: Icons.lock_reset,
              color: const Color(0xFF059669),
            ),
            const SizedBox(height: 20),

            // Confirm New Password
            _buildPasswordField(
              controller: _confirmPasswordController,
              label: "Confirm New Password",
              hint: "Confirm your new password",
              isPasswordVisible: _confirmPasswordVisible,
              toggleVisibility: () => setState(() => _confirmPasswordVisible = !_confirmPasswordVisible),
              validator: (value) => _validateConfirmPassword(value),
              icon: Icons.verified_user,
              color: const Color(0xFF7C3AED),
            ),
          ],
        ),
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
    required IconData icon,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 16,
                color: color,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: controller,
          obscureText: !isPasswordVisible,
          validator: validator,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w400,
            ),
            filled: true,
            fillColor: const Color(0xFFF1F5F9),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Colors.grey.shade200,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: color.withOpacity(0.6),
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFFEF4444),
                width: 1,
              ),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                isPasswordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: Colors.grey.shade500,
                size: 20,
              ),
              onPressed: toggleVisibility,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChangeButton(ColorScheme colorScheme, Size size) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFF667EEA),
            Color(0xFF764BA2),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667EEA).withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleChangePassword,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2.5,
          ),
        )
            : const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shield_outlined,
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 12),
            Text(
              "Update Password",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordRequirements(ColorScheme colorScheme, Size size) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF059669).withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF059669).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.info_outline,
                  size: 18,
                  color: Color(0xFF059669),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "Password Requirements",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildRequirementItem("At least 8 characters long", Icons.check_circle),
          _buildRequirementItem("At least one uppercase letter", Icons.check_circle),
          _buildRequirementItem("At least one number", Icons.check_circle),
          _buildRequirementItem("At least one special character", Icons.check_circle),
        ],
      ),
    );
  }

  Widget _buildRequirementItem(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: const Color(0xFF059669).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 16,
              color: const Color(0xFF059669),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF475569),
                fontWeight: FontWeight.w500,
              ),
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