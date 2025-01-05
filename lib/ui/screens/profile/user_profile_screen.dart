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
  late UserServiceProvider userService ;
  @override
  void initState() {
    // TODO: implement initState
    WidgetsFlutterBinding.ensureInitialized();
    userService = Provider.of<UserServiceProvider>(context, listen: false);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context,userService.userdata),
            _buildAccountInfo(context,userService.userdata),
            _buildProfileOptions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, UserData? userData) {
    return Container(
      height: 250.h,
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28.sp),
          bottomRight: Radius.circular(28.sp),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 50.sp,
                backgroundColor: Colors.grey.shade200,
                child: Icon(Icons.person, size: 50.sp, color: colorScheme.primary),
              ),
              SizedBox(width: 20.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.title("${userData?.firstname} ${userData?.lastname}", color: colorScheme.onPrimary),
                    SizedBox(height: 4.h),
                    AppText.body("${userData?.email}", color: colorScheme.onPrimary),
                    SizedBox(height: 4.h),
                    AppText.body("${userData?.phone}", color: colorScheme.onPrimary),
                    SizedBox(height: 8.h),
                     Row(
                      children: [
                        AppText.body("${userData?.verificationStatus} upgrade", color: Colors.grey.shade300),
                        SizedBox(width: 4.w),
                        Icon(Icons.verified, color: Colors.green, size: 18.sp)
                      ],
                    ),
                    Row(
                      children: [
                        AppText.body("Tier: ${userService.userdata?.tier}", color: Colors.grey.shade300),
                        SizedBox(width: 4.w),
                        Icon(Icons.flag, color: Colors.white, size: 18.sp)
                      ],
                    ),
                  ],
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
      margin: EdgeInsets.all(20.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.body("Account Number: ${userData?.accountNumber}", style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 8.h),
          AppText.caption("BVN: ${userData?.bvn}"),
        ],
      ),
    );
  }

  Widget _buildProfileOptions(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
         // (userService.userdata?.verificationStatus.toLowerCase()=="pending"||userService.userdata?.verificationStatus.toLowerCase()=="verified")?SizedBox():_buildOptionTile(
          (userService.userdata?.verificationStatus.toLowerCase()=="pending"||userService.userdata?.verificationStatus.toLowerCase()=="verified")?SizedBox():_buildOptionTile(
            context,
            icon: Icons.upgrade_rounded,
            title: "Upgrade your account",
            color: colorScheme.primary,
            onTap: () => context.pushNamed("upgrade_account_page"),
          ),
          _buildOptionTile(
            context,
            icon: Icons.lock,
            title: "Change your password",
            color: Colors.grey,
            onTap: () => context.pushNamed("forgot_password_input_mail"),
          ),
          _buildOptionTile(
            context,
            icon: Icons.file_copy,
            title: "Terms and conditions",
            color: Colors.redAccent,
            onTap: ()=> context.pushNamed("terms_and_conditions"),
          ),
          _buildOptionTile(
            context,
            icon: Icons.help_outline,
            title: "FAQ",
            color: Colors.green,
            onTap: ()=>context.pushNamed("frequently_asked_questions"),
          ),
          _buildOptionTile(
            context,
            icon: Icons.mail,
            title: "Contact us",
            color: Colors.orange,
            onTap: ()=>context.pushNamed("contact_us")
          ),
          _buildOptionTile(
            context,
            icon: Icons.exit_to_app,
            title: "Log out",
            color: Colors.purple,
              onTap: () => context.goNamed("login")
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile(BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade300, width: 1)),
        ),
        child: Row(
          children: [
            CircleAvatar(backgroundColor: color, child: Icon(icon, color: Colors.white)),
            SizedBox(width: 16.w),
            Expanded(child: AppText.body(title)),
            Icon(Icons.arrow_forward_ios, size: 16.sp, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}