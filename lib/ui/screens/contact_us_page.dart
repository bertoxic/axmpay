import 'package:AXMPAY/main.dart';
import 'package:AXMPAY/ui/widgets/custom_responsive_sizes/responsive_size.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({Key? key}) : super(key: key);

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(scheme: 'mailto', path: email);
    if (!await launchUrl(emailUri)) {
      throw Exception('Could not launch $email');
    }
  }

  Future<void> _launchPhone(String phone) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phone);
    if (!await launchUrl(phoneUri)) {
      throw Exception('Could not launch $phone');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Stack(
        children: [
          // Animated background pattern
          // Positioned.fill(
          //   child: CustomPaint(
          //     painter: GridPainter(),
          //   ),
          // ),
          // Content
          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Column(
                      children: [
                        SizedBox(height: 40.h),
                        // Animated logo container
                        Container(
                          height: 120.h,
                          width: 120.h,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.transparent,
                            border: Border.all(
                              color: Colors.purpleAccent.withOpacity(0.5),
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: ShaderMask(
                              shaderCallback: (bounds) => LinearGradient(
                                colors: [
                                  Colors.purpleAccent,
                                  Colors.blueAccent,
                                ],
                              ).createShader(bounds),
                              child: FaIcon(
                                FontAwesomeIcons.handshake,
                                color: Colors.white,
                                size: 50.h,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 32.h),
                        Text(
                          'Connect With Us',
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontSize: 32.sp,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Choose your preferred way to reach out',
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 16.sp,
                          ),
                        ),
                        SizedBox(height: 40.h),
                      ],
                    ),
                  ),
                ),
                // Social media grid
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  sliver: SliverGrid(
                    delegate: SliverChildListDelegate([
                      _buildSocialCard(
                        icon: FontAwesomeIcons.facebook,
                        title: 'Facebook',
                        handle: 'fustpay',
                        gradient: [Colors.blue[700]!, Colors.blue[400]!],
                        onTap: () => _launchURL('https://facebook.com/fustpay'),
                      ),
                      _buildSocialCard(
                        icon: FontAwesomeIcons.tiktok,
                        title: 'TikTok',
                        handle: '@fustpay',
                        gradient: [Colors.black87, Colors.grey[800]!],
                        onTap: () => _launchURL('https://tiktok.com/@fustpay'),
                      ),
                      _buildSocialCard(
                        icon: FontAwesomeIcons.xTwitter,
                        title: 'X',
                        handle: '_fustpay',
                        gradient: [Colors.grey[900]!, Colors.grey[800]!],
                        onTap: () => _launchURL('https://x.com/_fustpay'),
                      ),
                      _buildSocialCard(
                        icon: FontAwesomeIcons.threads,
                        title: 'Threads',
                        handle: '@fustpay',
                        gradient: [Colors.purple[900]!, Colors.purple[700]!],
                        onTap: () => _launchURL('https://threads.net/@fustpay'),
                      ),
                    ]),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16.h,
                      crossAxisSpacing: 16.w,
                      childAspectRatio: 1.1,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(24.w),
                    child: Column(
                      children: [
                        SizedBox(height: 32.h),
                        _buildContactCard(
                          icon: FontAwesomeIcons.envelope,
                          title: 'Email Us',
                          info: 'support@fustpay.net',
                          onTap: () => _launchEmail('support@fustpay.net'),
                        ),
                        SizedBox(height: 16.h),
                        _buildContactCard(
                          icon: FontAwesomeIcons.phone,
                          title: 'Call Us',
                          info: '(+234) 803 9876 467',
                          onTap: () => _launchPhone('+2348039876467'),
                        ),
                        SizedBox(height: 32.h),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialCard({
    required IconData icon,
    required String title,
    required String handle,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient,
          ),
          borderRadius: BorderRadius.circular(20.w),
          boxShadow: [
            BoxShadow(
              color: gradient[0].withOpacity(0.3),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.w),
          child: BackdropFilter(
            filter: ColorFilter.mode(
              Colors.black.withOpacity(0.1),
              BlendMode.softLight,
            ),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FaIcon(
                    icon,
                    color: Colors.white,
                    size: 28.w,
                  ),
                  Spacer(),
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    handle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14.sp,
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

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String info,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(16.w),
          border: Border.all(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
        padding: EdgeInsets.all(20.w),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                //color: Colors.grey[400],
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(12.w),
              ),
              child: FaIcon(
                icon,
                color: Colors.white,
                size: 24.w,
              ),
            ),
            SizedBox(width: 16.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  info,
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[600],
              size: 16.w,
            ),
          ],
        ),
      ),
    );
  }
}

// Custom painter for the animated grid background
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[900]!.withOpacity(0.3)
      ..strokeWidth = 1;

    final spacing = 30.0;

    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i, size.height),
        paint,
      );
    }

    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(
        Offset(0, i),
        Offset(size.width, i),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}