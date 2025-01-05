import 'package:AXMPAY/ui/widgets/custom_responsive_sizes/responsive_size.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF5E35B1),
              Color(0xFFA783E3),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              children: [
                SizedBox(height: 40.h),

                FaIcon(
                  FontAwesomeIcons.handshake,
                  color: Colors.white,
                  size: 60.h,
                ),
                SizedBox(height: 16.h),
                // "Drop us a line" text
                Text(
                  'Drop us a line',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                // Dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    3,
                        (index) => Container(
                      margin: EdgeInsets.symmetric(horizontal: 4.w),
                      width: 8.w,
                      height: 8.w,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 40.h),
                Text(
                  'Contact Us',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 24.h),
                // Social Media Links
                _buildSocialLink(
                  icon: FontAwesomeIcons.facebook,
                  title: 'Visit our Facebook',
                  subtitle: 'fustpay',
                  iconColor: Color(0xFF1877F2), // Facebook blue
                ),
                SizedBox(height: 16.h),
                _buildSocialLink(
                  icon: FontAwesomeIcons.tiktok,
                  title: 'Visit our TikTok',
                  subtitle: '@fustpay',
                  iconColor: Colors.black,
                ),
                SizedBox(height: 16.h),
                _buildSocialLink(
                  icon: FontAwesomeIcons.xTwitter,
                  title: 'Visit our X',
                  subtitle: '_fustpay',
                  iconColor: Colors.black,
                ),
                SizedBox(height: 16.h),
                _buildSocialLink(
                  icon: FontAwesomeIcons.threads,
                  title: 'Visit our Threads',
                  subtitle: '@fustpay',
                  iconColor: Colors.black,
                ),
                Spacer(),
                // Contact Information
                _buildContactInfo(
                  icon: FontAwesomeIcons.envelope,
                  text: 'support@fustpay.net',
                ),
                SizedBox(height: 16.h),
                _buildContactInfo(
                  icon: FontAwesomeIcons.phone,
                  text: '(+234) 803 9876 467',
                ),
                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialLink({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.w),
      ),
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          FaIcon(
            icon,
            size: 24.w,
            color: iconColor,
          ),
          SizedBox(width: 16.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          Spacer(),
          FaIcon(
            FontAwesomeIcons.chevronRight,
            color: Colors.grey[400],
            size: 20.w,
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo({
    required IconData icon,
    required String text,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FaIcon(
          icon,
          color: Colors.white70,
          size: 20.h,
        ),
        SizedBox(width: 8.w),
        Text(
          text,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16.sp,
          ),
        ),
      ],
    );
  }
}