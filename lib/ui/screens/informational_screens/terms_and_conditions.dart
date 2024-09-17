import 'package:AXMPAY/main.dart';
import 'package:AXMPAY/models/other_models.dart';
import 'package:AXMPAY/providers/user_service_provider.dart';
import 'package:AXMPAY/ui/screens/informational_screens/Information_Screen_Provider.dart';
import 'package:AXMPAY/ui/screens/informational_screens/information_screen_controller.dart';
import 'package:AXMPAY/ui/widgets/custom_container.dart';
import 'package:AXMPAY/ui/widgets/custom_responsive_sizes/responsive_size.dart';
import 'package:AXMPAY/ui/widgets/custom_text/custom_apptext.dart';
import 'package:flutter/material.dart';

class TermsAndConditions extends StatefulWidget {
  TermsAndConditions({Key? key}) : super(key: key);

  @override
  State<TermsAndConditions> createState() => _TermsAndConditionsState();
}

class _TermsAndConditionsState extends State<TermsAndConditions> {
  late final UserServiceProvider userServiceProvider;
  late InformationScreenController _controller;
  late Future<AxmpayTermsList?> _termsFuture;

  @override
  void initState() {
    super.initState();
    _controller = InformationScreenController(context);
    _termsFuture = _controller.getAxmTermsList();
  }

  List<TermSection> _sortTerms(List<TermSection> terms) {
    return terms..sort((a, b) => a.sectionNumber.compareTo(b.sectionNumber));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( iconTheme: IconThemeData(color: Colors.grey.shade300),
        title: Text("Terms and Conditions" ,style: TextStyle(color: Colors.grey.shade300),),
        elevation: 0,
        backgroundColor: colorScheme.primary,
      ),
      body: FutureBuilder<AxmpayTermsList?>(
        future: _termsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData && snapshot.data!.data != null) {
            final sortedTerms = _sortTerms(snapshot.data!.data!);
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Container(
                    padding: EdgeInsets.all(16.sp),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText.display(
                          "Terms and Conditions",
                          color: Colors.white,
                          style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold,color: Colors.white.withOpacity(0.8),),
                        ),
                        SizedBox(height: 8.sp),
                        AppText.body(
                          "Please read our terms and conditions carefully.",
                          color: Colors.white.withOpacity(0.8),
                          style: TextStyle(fontSize: 14.sp, color: Colors.white.withOpacity(0.8),),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.all(16.sp),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        final term = sortedTerms[index];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 12.sp),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 6.sp),
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(8.sp),
                              ),
                              child: Text(
                                "Section ${term.sectionNumber}",
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ),
                            SizedBox(height: 12.sp),
                            Text(
                              term.content,
                              style: TextStyle(fontSize: 14.sp, height: 1.5),
                            ),
                            SizedBox(height: 8.sp),
                            Text(
                              "Parent Section: ${term.parentSection}",
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontStyle: FontStyle.italic,
                                color: colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                            SizedBox(height: 4.sp),
                            Text(
                              "Date Added: ${term.dateAdded}",
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontStyle: FontStyle.italic,
                                color: colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                            if (index < sortedTerms.length - 1)
                              Divider(height: 32.sp, thickness: 1.sp),
                          ],
                        );
                      },
                      childCount: sortedTerms.length,
                    ),
                  ),
                ),
              ],
            );
          } else {
            return Center(child: Text("No Terms and Conditions available"));
          }
        },
      ),
    );
  }
}