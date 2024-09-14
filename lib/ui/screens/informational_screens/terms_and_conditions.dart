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
  List<bool> _isExpanded = [];
  int _selectedIndex = -1;

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
        title: Text("Terms and Conditions",style: TextStyle(color: Colors.grey.shade300),),
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
            if (_isExpanded.isEmpty) {
              _isExpanded = List.generate(sortedTerms.length, (_) => false);
            }
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Container(
                    padding: EdgeInsets.all(16.sp),
                    decoration:  BoxDecoration(
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
                          style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold, color: Colors.grey.shade200),
                        ),
                        SizedBox(height: 8.sp),
                        AppText.body(
                          "Please read our terms and conditions carefully.",
                          color: Colors.white.withOpacity(0.8),
                          style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade200),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final term = sortedTerms[index];
                      return AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        margin: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 8.sp),
                        decoration: BoxDecoration(
                          color: _selectedIndex == index
                              ? colorScheme.primaryContainer
                              : colorScheme.surface,
                          borderRadius: BorderRadius.circular(16.sp),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Theme(
                          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            leading: CircleAvatar(
                              backgroundColor: colorScheme.primary,
                              child: Text(
                                term.sectionNumber,
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                            title: Text(
                              "Section ${term.sectionNumber}",
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            subtitle: Text(
                              "Parent Section: ${term.parentSection}",
                              style: TextStyle(fontSize: 12.sp, color: colorScheme.onSurface.withOpacity(0.6)),
                            ),
                            children: [
                              Padding(
                                padding: EdgeInsets.all(16.sp),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      term.content,
                                      style: TextStyle(fontSize: 14.sp, height: 1.5),
                                    ),
                                    SizedBox(height: 8.sp),
                                    Text(
                                      "Date Added: ${term.dateAdded}",
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        fontStyle: FontStyle.italic,
                                        color: colorScheme.onSurface.withOpacity(0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            onExpansionChanged: (expanded) {
                              setState(() {
                                _isExpanded[index] = expanded;
                                _selectedIndex = expanded ? index : -1;
                              });
                            },
                          ),
                        ),
                      );
                    },
                    childCount: sortedTerms.length,
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(height: 24.sp),
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