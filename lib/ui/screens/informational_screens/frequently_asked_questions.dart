import 'package:AXMPAY/main.dart';
import 'package:AXMPAY/models/other_models.dart';
import 'package:AXMPAY/providers/user_service_provider.dart';
import 'package:AXMPAY/ui/screens/informational_screens/Information_Screen_Provider.dart';
import 'package:AXMPAY/ui/screens/informational_screens/information_screen_controller.dart';
import 'package:AXMPAY/ui/widgets/custom_container.dart';
import 'package:AXMPAY/ui/widgets/custom_responsive_sizes/responsive_size.dart';
import 'package:AXMPAY/ui/widgets/custom_text/custom_apptext.dart';
import 'package:flutter/material.dart';

class FAQs extends StatefulWidget {
  FAQs({Key? key}) : super(key: key);

  @override
  State<FAQs> createState() => _FAQsState();
}

class _FAQsState extends State<FAQs> {
  late final UserServiceProvider userServiceProvider;
  late InformationScreenController _controller;
  late Future<AxmpayFaqList?> _faqsFuture;
  List<bool> _isExpanded = [];

  @override
  void initState() {
    super.initState();
    _controller = InformationScreenController(context);
    _faqsFuture = _controller.getAxmList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          "FAQs",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
        backgroundColor: colorScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.primary.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: FutureBuilder<AxmpayFaqList?>(
          future: _faqsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  color: colorScheme.primary,
                ),
              );
            } else if (snapshot.hasData && snapshot.data!.faqs != null) {
              if (_isExpanded.isEmpty) {
                _isExpanded = List.generate(snapshot.data!.faqs!.length, (_) => false);
              }
              return _buildFAQList(snapshot.data!.faqs!);
            } else {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.question_answer_outlined,
                      size: 48.sp,
                      color: colorScheme.primary.withOpacity(0.5),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      "No FAQs available",
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: colorScheme.primary.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildFAQList(List<AxmpayFaq> faqs) {
    return CustomScrollView(
      physics: BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 24.h),
            child: Column(
              children: [
                Icon(
                  Icons.help_outline_rounded,
                  size: 48.sp,
                  color: colorScheme.primary,
                ),
                SizedBox(height: 16.h),
                AppText.display(
                  "Frequently Asked Questions",
                  color: colorScheme.primary,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 8.h),
                AppText.body(
                  "Find answers to common questions",
                  color: colorScheme.primary.withOpacity(0.7),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14.sp),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildFAQItem(faqs[index], index),
              childCount: faqs.length,
            ),
          ),
        ),
        SliverPadding(padding: EdgeInsets.only(bottom: 24.h)),
      ],
    );
  }

  Widget _buildFAQItem(AxmpayFaq faq, int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      margin: EdgeInsets.symmetric(vertical: 8.h),
      child: Card(
        elevation: _isExpanded[index] ? 4 : 2,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: _isExpanded[index]
                ? colorScheme.primary.withOpacity(0.2)
                : Colors.transparent,
          ),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            backgroundColor: Colors.white,
            collapsedBackgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            leading: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: _isExpanded[index]
                      ? [colorScheme.primary, colorScheme.primary.withOpacity(0.7)]
                      : [Colors.grey.withOpacity(0.5), Colors.grey.withOpacity(0.3)],
                ),
              ),
              child: CircleAvatar(
                radius: 16.sp,
                backgroundColor: Colors.transparent,
                child: Icon(
                  _isExpanded[index] ? Icons.remove : Icons.add,
                  size: 16.sp,
                  color: Colors.white,
                ),
              ),
            ),
            title: Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: AppText.title(
                faq.question,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: _isExpanded[index]
                      ? colorScheme.primary
                      : colorScheme.onSurface,
                ),
              ),
            ),
            children: [
              Container(
                padding: EdgeInsets.all(16.sp),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(16),
                  ),
                ),
                child: Text(
                  faq.answer,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: colorScheme.onSurface.withOpacity(0.8),
                    height: 1.5,
                  ),
                ),
              ),
            ],
            onExpansionChanged: (expanded) {
              setState(() {
                _isExpanded[index] = expanded;
              });
            },
          ),
        ),
      ),
    );
  }
}