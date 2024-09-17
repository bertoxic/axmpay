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
      appBar: AppBar( iconTheme: IconThemeData(color: Colors.grey.shade200),
        title: Text("FAQs",style: TextStyle(color: Colors.grey.shade200),),
        elevation: 0,
        backgroundColor: colorScheme.primary,
      ),
      body: FutureBuilder<AxmpayFaqList?>(
        future: _faqsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData && snapshot.data!.faqs != null) {
            if (_isExpanded.isEmpty) {
              _isExpanded = List.generate(snapshot.data!.faqs!.length, (_) => false);
            }
            return _buildFAQList(snapshot.data!.faqs!);
          } else {
            return const Center(child: Text("No FAQs available"));
          }
        },
      ),
    );
  }

  Widget _buildFAQList(List<AxmpayFaq> faqs) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: SpacedContainer(
            child: AppText.display(
              "Frequently Asked Questions",
              color: colorScheme.primary,
              textAlign: TextAlign.center,
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
      ],
    );
  }

  Widget _buildFAQItem(AxmpayFaq faq, int index) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 8.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          backgroundColor: colorScheme.primary.withOpacity(0.2),
          leading: CircleAvatar(
            radius: 12.sp,
            backgroundColor: _isExpanded[index]
                ? Colors.green.withOpacity(0.7)
                : Colors.grey.withOpacity(0.5),
            child: Icon(Icons.question_mark, size: 12.sp, color: Colors.white),
          ),
          title: Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: AppText.title(
              faq.question,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: colorScheme.primary,
              ),
            ),
          ),
          children: [
            Padding(
              padding: EdgeInsets.all(16.sp),
              child: Text(
                faq.answer,
                style: TextStyle(fontSize: 11.sp, color: colorScheme.onSurface),
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
    );
  }
}