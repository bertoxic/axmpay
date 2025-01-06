import 'package:AXMPAY/main.dart';
import 'package:AXMPAY/models/user_model.dart';
import 'package:AXMPAY/providers/user_service_provider.dart';
import 'package:AXMPAY/ui/widgets/custom_responsive_sizes/responsive_size.dart';
import 'package:AXMPAY/ui/widgets/custom_text/custom_apptext.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class UserProfileScreen extends StatefulWidget {
  UserProfileScreen({Key? key}) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late UserServiceProvider userService;

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    userService = Provider.of<UserServiceProvider>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(context, userService.userdata),
              Transform.translate(
                offset: Offset(0, -20.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildAccountInfo(context, userService.userdata),
                    SizedBox(height: 20.h),
                    _buildProfileOptions(context),
                    SizedBox(height: 80.h), // Add bottom padding
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, UserData? userData) {
    return Container(
      height: 320.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            colorScheme.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40.sp),
          bottomRight: Radius.circular(40.sp),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText.title("Profile", color: colorScheme.onPrimary),
                  IconButton(
                    icon: Icon(Icons.settings, color: colorScheme.onPrimary),
                    onPressed: () {},
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: CircleAvatar(
                  radius: 45.sp,
                  backgroundColor: Colors.white.withOpacity(0.9),
                  child: Icon(Icons.person, size: 45.sp, color: colorScheme.primary),
                ),
              ),
              SizedBox(height: 16.h),
              AppText.title("${userData?.firstname} ${userData?.lastname}",
                style: TextStyle(fontWeight: FontWeight.w600,color: colorScheme.onPrimaryContainer),
              ),
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.verified, color: Colors.green, size: 18.sp),
                  SizedBox(width: 8.w),
                  AppText.body("${userData?.verificationStatus}", color: Colors.white),
                  SizedBox(width: 16.w),
                  Icon(Icons.flag, color: Colors.white, size: 18.sp),
                  SizedBox(width: 8.w),
                  AppText.body("Tier ${userService.userdata?.tier}", color: Colors.white),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountInfo(BuildContext context, UserData? userData) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow(Icons.credit_card, "Account Number", "${userData?.accountNumber}"),
          SizedBox(height: 16.h),
          _buildInfoRow(Icons.verified_user, "BVN", "${userData?.bvn}"),
          SizedBox(height: 16.h),
          _buildInfoRow(Icons.email, "Email", "${userData?.email}"),
          SizedBox(height: 16.h),
          _buildInfoRow(Icons.phone, "Phone", "${userData?.phone}"),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: colorScheme.primary, size: 20.sp),
        ),
        SizedBox(width: 16.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText.caption(label, color: Colors.grey[600]),
            AppText.body(value, style: TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }

  Widget _buildProfileOptions(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          if (!(userService.userdata?.verificationStatus.toLowerCase() == "pending" ||
              userService.userdata?.verificationStatus.toLowerCase() == "verified"))
            _buildOptionTile(
              context,
              icon: Icons.upgrade_rounded,
              title: "Upgrade your account",
              subtitle: "Enhance your account capabilities",
              color: colorScheme.primary,
              onTap: () => context.pushNamed("upgrade_account_page"),
            ),
          _buildOptionTile(
            context,
            icon: Icons.lock,
            title: "Change your password",
            subtitle: "Update your security settings",
            color: Colors.blue,
            onTap: () => context.pushNamed("forgot_password_input_mail"),
          ),
          _buildOptionTile(
            context,
            icon: Icons.file_copy,
            title: "Terms and conditions",
            subtitle: "Read our terms of service",
            color: Colors.orange,
            onTap: () => context.pushNamed("terms_and_conditions"),
          ),
          _buildOptionTile(
            context,
            icon: Icons.help_outline,
            title: "FAQ",
            subtitle: "Get answers to common questions",
            color: Colors.green,
            onTap: () => context.pushNamed("frequently_asked_questions"),
          ),
          _buildOptionTile(
            context,
            icon: Icons.mail,
            title: "Contact us",
            subtitle: "Get in touch with our support team",
            color: Colors.purple,
            onTap: () => context.pushNamed("contact_us"),
          ),
          _buildOptionTile(
            context,
            icon: Icons.exit_to_app,
            title: "Log out",
            subtitle: "Sign out of your account",
            color: Colors.red,
            onTap: () => context.goNamed("login"),
            showBorder: false,
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile(BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    VoidCallback? onTap,
    bool showBorder = true,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        decoration: BoxDecoration(
          border: showBorder ? Border(
            bottom: BorderSide(color: Colors.grey.shade200, width: 1),
          ) : null,
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24.sp),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.body(title, style: TextStyle(fontWeight: FontWeight.w600)),
                  SizedBox(height: 4.h),
                  AppText.caption(subtitle, color: Colors.grey[600]),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16.sp, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}