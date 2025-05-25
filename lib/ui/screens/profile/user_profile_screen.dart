import 'package:AXMPAY/main.dart';
import 'package:AXMPAY/models/user_model.dart';
import 'package:AXMPAY/providers/user_service_provider.dart';
import 'package:AXMPAY/ui/screens/upgrade_account/verification/verifydetails.dart';
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
    // Get screen size for better responsiveness
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.height < 600;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Stack(
          children: [
            // Header container
            _buildHeader(context, userService.userdata),

            // Content container with proper spacing from top
            Padding(
              padding: EdgeInsets.only(
                // Dynamically calculate top padding based on screen size
                top: MediaQuery.of(context).size.height < 600
                    ? 240.h  // Even smaller offset for very small screens
                    : (MediaQuery.of(context).size.height < 700 ? 260.h : 280.h),
                bottom: 24.h,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildAccountInfo(context, userService.userdata),
                  SizedBox(height: 20.h),
                  _buildProfileOptions(context),
                  SizedBox(height: 50.h), // Reduced bottom padding
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, UserData? userData) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    // Adjust height based on screen size - use smaller percentage for very small screens
    final headerHeight = screenHeight < 600
        ? screenHeight * 0.32  // 32% for small screens
        : screenHeight * 0.35; // 35% for normal screens
    final safeAreaTop = mediaQuery.padding.top;

    return Container(
      width: double.infinity,
      height: headerHeight,
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
        bottom: false, // Don't consider bottom safe area for header
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Use minimum space needed
            children: [
              // Top bar with adaptive sizing
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText.title(
                    "Profile",
                    color: colorScheme.onPrimary,
                    style: TextStyle(
                      fontSize: mediaQuery.size.height < 600 ? 18.sp : 20.sp,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.settings, color: colorScheme.onPrimary),
                    iconSize: mediaQuery.size.height < 600 ? 20.sp : 24.sp,
                    constraints: BoxConstraints.tightFor(
                      width: mediaQuery.size.height < 600 ? 36.w : 40.w,
                      height: mediaQuery.size.height < 600 ? 36.w : 40.w,
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
              Expanded(
                child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Calculate avatar size based on available space
                      final avatarSize = (constraints.maxHeight * 0.3).clamp(30.0, 45.0);
                      final isVerySmall = constraints.maxHeight < 100;

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(2.w),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: CircleAvatar(
                              radius: avatarSize,
                              backgroundColor: Colors.white.withOpacity(0.9),
                              child: Icon(
                                  Icons.person,
                                  size: avatarSize * 0.8,
                                  color: colorScheme.primary
                              ),
                            ),
                          ),
                          SizedBox(height: isVerySmall ? 4.h : 8.h),
                          AppText.title(
                            "${userData?.firstname} ${userData?.lastname}",
                            style: TextStyle(
                              fontSize: isVerySmall ? 16.sp : 18.sp,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                          SizedBox(height: isVerySmall ? 2.h : 4.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified, color: Colors.green, size: isVerySmall ? 14.sp : 18.sp),
                              SizedBox(width: 4.w),
                              Flexible(
                                child: AppText.body(
                                  "${userData?.verificationStatus}",
                                  color: Colors.white,
                                  style: TextStyle(fontSize: isVerySmall ? 12.sp : 14.sp, color: Colors.grey.shade200),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Icon(Icons.flag, color: Colors.white, size: isVerySmall ? 14.sp : 18.sp),
                              SizedBox(width: 4.w),
                              Flexible(
                                child: AppText.body(
                                  "Tier ${userService.userdata?.tier}",
                                  color: Colors.white,
                                  style: TextStyle(fontSize: isVerySmall ? 12.sp : 14.sp, color: Colors.grey.shade200),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    }
                ),
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
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText.caption(label, color: Colors.grey[600]),
              AppText.body(
                value,
                style: TextStyle(fontWeight: FontWeight.w600),
                // Add overflow handling for long texts
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
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
              // onTap: () => {
              // // Navigate to SecondScreen
              // Navigator.push(
              // context,
              // MaterialPageRoute(builder: (context) => VerificationScreen(onVerificationComplete: (bool){
              //   var us = userService.userdata;
              //   print(bool);
              // }, usrprovider: userService,)),
              // )
                   // }
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
      borderRadius: showBorder ? null : BorderRadius.only(
        bottomLeft: Radius.circular(20),
        bottomRight: Radius.circular(20),
      ),
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