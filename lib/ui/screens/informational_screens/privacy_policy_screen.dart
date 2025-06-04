import 'package:AXMPAY/main.dart';
import 'package:AXMPAY/models/other_models.dart';
import 'package:AXMPAY/providers/user_service_provider.dart';
import 'package:AXMPAY/ui/screens/informational_screens/Information_Screen_Provider.dart';
import 'package:AXMPAY/ui/screens/informational_screens/information_screen_controller.dart';
import 'package:AXMPAY/ui/widgets/custom_container.dart';
import 'package:AXMPAY/ui/widgets/custom_responsive_sizes/responsive_size.dart';
import 'package:AXMPAY/ui/widgets/custom_text/custom_apptext.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> with TickerProviderStateMixin {
  late final UserServiceProvider userServiceProvider = UserServiceProvider();
  late InformationScreenController _controller;
  late Future<PrivacyPolicyList?> _privacyFuture;
  final ScrollController _scrollController = ScrollController();
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Add loading state
  bool _isLoading = true;

  // Map to get appropriate icons based on title keywords
  IconData _getIconForTitle(String title) {
    final String lowerTitle = title.toLowerCase();

    if (lowerTitle.contains('rights') || lowerTitle.contains('your')) {
      return Icons.person_outline_rounded;
    } else if (lowerTitle.contains('consent')) {
      return Icons.check_circle_outline_rounded;
    } else if (lowerTitle.contains('personal') || lowerTitle.contains('information')) {
      return Icons.info_outline_rounded;
    } else if (lowerTitle.contains('what we do') || lowerTitle.contains('use')) {
      return Icons.settings_applications_rounded;
    } else if (lowerTitle.contains('cookies')) {
      return Icons.cookie_outlined;
    } else if (lowerTitle.contains('protect') || lowerTitle.contains('security')) {
      return Icons.security_rounded;
    } else if (lowerTitle.contains('share') || lowerTitle.contains('sharing')) {
      return Icons.share_outlined;
    } else if (lowerTitle.contains('confidentiality') || lowerTitle.contains('data')) {
      return Icons.shield_rounded;
    } else if (lowerTitle.contains('links') || lowerTitle.contains('websites')) {
      return Icons.link_rounded;
    } else if (lowerTitle.contains('law') || lowerTitle.contains('governing')) {
      return Icons.gavel_rounded;
    } else {
      return Icons.privacy_tip_rounded;
    }
  }

  PrivacyPolicyList? _privacyList;

  void loadPrivacyPolicy(BuildContext context) async {
    try {
      _privacyList = await userServiceProvider.getPrivacyPolicy(context);
    } catch (e) {
      print('Error loading privacy policy: $e');
      // _privacyList will remain null, fallback data will be used
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = InformationScreenController(context);
    _privacyFuture = Future.value(userServiceProvider.getPrivacyPolicy(context));

    _fadeController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _fadeController.forward();

    // Load privacy policy after init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadPrivacyPolicy(context);
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  // Helper method to get privacy sections safely
  List<PrivacySection> _getPrivacySections() {
    if (_privacyList?.data != null && _privacyList!.data!.isNotEmpty) {
      return List.generate(_privacyList!.data!.length, (index) {
        final item = _privacyList!.data![index];
        return PrivacySection(
          content: item.content ?? "Content not available",
          icon: _getIconForTitle(item.title ?? ""),
          title: item.title ?? "Title not available",
        );
      });
    } else {
      return []; // Return empty list instead of fallback data
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator while data is being fetched
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Color(0xFFF8F9FD),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: colorScheme.primary),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
          ),
        ),
      );
    }

    final List<PrivacySection> privacySections = _getPrivacySections();

    // Show empty state if no data
    if (privacySections.isEmpty && !_isLoading) {
      return Scaffold(
        backgroundColor: Color(0xFFF8F9FD),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: colorScheme.primary),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.description_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
              SizedBox(height: 16),
              Text(
                "No Privacy Policy Available",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 8),
              Text(
                "Please try again later",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Color(0xFFF8F9FD),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: colorScheme.primary),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          controller: _scrollController,
          physics: BouncingScrollPhysics(),
          slivers: [
            _buildEnhancedHeader(),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 20.sp),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildPrivacySection(privacySections[index], index),
                  childCount: privacySections.length,
                ),
              ),
            ),
            _buildFooter(),
            SliverPadding(padding: EdgeInsets.only(bottom: 32.sp)),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedHeader() {
    return SliverToBoxAdapter(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6366F1),
              Color(0xFF8B5CF6),
              Color(0xFFEC4899),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Background decorative elements
            Positioned(
              right: -80,
              top: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            Positioned(
              left: -50,
              bottom: -80,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ),
            Positioned(
              right: 50,
              bottom: 20,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.15),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(24.sp, 120.sp, 24.sp, 50.sp),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon and title section
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(16.sp),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20.sp),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          Icons.privacy_tip_rounded,
                          color: Colors.white,
                          size: 32.sp,
                        ),
                      ),
                      SizedBox(width: 20.sp),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Privacy Policy",
                              style: TextStyle(
                                fontSize: 32.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(height: 8.sp),
                            Text(
                              "Effective: ${DateTime.now().toString().split(' ')[0]}",
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.white.withOpacity(0.85),
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 32.sp),

                  // Info card
                  Container(
                    padding: EdgeInsets.all(20.sp),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20.sp),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.shield_rounded,
                                color: Colors.white,
                                size: 20.sp,
                              ),
                            ),
                            SizedBox(width: 16.sp),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Your Privacy Matters",
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 4.sp),
                                  Text(
                                    "We're committed to protecting your personal information",
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Colors.white.withOpacity(0.9),
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.sp),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 12.sp),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12.sp),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem("🔒", "Encrypted", "Data"),
                              _buildStatItem("🛡️", "Secure", "Storage"),
                              _buildStatItem("👤", "Your", "Control"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String emoji, String title, String subtitle) {
    return Column(
      children: [
        Text(emoji, style: TextStyle(fontSize: 20.sp)),
        SizedBox(height: 4.sp),
        Text(
          title,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 10.sp,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildPrivacySection(PrivacySection section, int index) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 600 + (index * 100)),
      builder: (context, double value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(top: 20.sp, bottom: 4.sp),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.sp),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: Offset(0, 8),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section with gradient
            Container(
              padding: EdgeInsets.all(24.sp),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.primaryContainer.withOpacity(0.8),
                    colorScheme.primaryContainer.withOpacity(0.6),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.sp),
                  topRight: Radius.circular(20.sp),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12.sp),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16.sp),
                    ),
                    child: Icon(
                      section.icon,
                      color: colorScheme.primary,
                      size: 24.sp,
                    ),
                  ),
                  SizedBox(width: 16.sp),
                  Expanded(
                    child: Text(
                      section.title,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content section
            Padding(
              padding: EdgeInsets.all(24.sp),
              child: Text(
                section.content,
                style: TextStyle(
                  fontSize: 15.sp,
                  height: 1.7,
                  color: Colors.black87,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.fromLTRB(20.sp, 32.sp, 20.sp, 0),
        padding: EdgeInsets.all(24.sp),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.primary.withOpacity(0.1),
              colorScheme.secondary.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(20.sp),
          border: Border.all(
            color: colorScheme.primary.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.support_agent_rounded,
              size: 48.sp,
              color: colorScheme.primary,
            ),
            SizedBox(height: 16.sp),
            Text(
              "Questions About Your Privacy?",
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            SizedBox(height: 8.sp),
            Text(
              "Contact our privacy team at privacy@fustPay.net",
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.sp),
            GestureDetector(
              onTap:()=> _launchEmail('privacy@fustpay.net'),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 12.sp),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(25.sp),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.3),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  "Contact Support",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _launchEmail(String email) async {
  final Uri emailUri = Uri(scheme: 'mailto', path: email);
  if (!await launchUrl(emailUri)) {
    throw Exception('Could not launch $email');
  }
}
class PrivacySection {
  final String title;
  final String content;
  final IconData icon;

  PrivacySection({
    required this.title,
    required this.content,
    required this.icon,
  });
}