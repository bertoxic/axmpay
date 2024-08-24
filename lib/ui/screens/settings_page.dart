import 'package:fintech_app/constants/app_colors.dart';
import 'package:fintech_app/ui/widgets/custom_responsive_sizes/responsive_size.dart';
import 'package:flutter/material.dart';
import '../widgets/custom_text/custom_apptext.dart';


class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return   Container(
      color: Colors.grey.shade200,
      child: CustomScrollView(
          scrollDirection: Axis.vertical,
          slivers:<Widget> [
          SliverAppBar(
            expandedHeight: 160.h,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30))),
            backgroundColor: Colors.green,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30)),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    colors: [
                      Color(0xB28EF8A4),
                      Color(0xB23ACE58),
                      Color(0xB20C6919)],
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      left: 12.h,
                        bottom: 12.h,
                        child:  Row(
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircleAvatar(
                                radius: 20,
                                child: Icon(Icons.person),
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppText.body("Amons davithe", color: AppColors.lightgrey,),
                                AppText.caption("908812003", color: AppColors.lightgrey,),
                              ],
                            )
                          ],
                        ))
                  ],
                ),
              ),
            ),
          ) ,
            SliverToBoxAdapter(
                child:
            Container(
              color: Colors.grey.shade200,
              child: Column(
                children: [
                  Container(

                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                    ),
                    margin: EdgeInsets.all(8.h),
                    //height: 100,
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.ad_units_outlined,),
                          title: Padding(padding: const EdgeInsets.all(8),
                         child: AppText.body("Transaction History"),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios_sharp),
                        ),
                        ListTile(
                          leading: const Icon(Icons.ad_units_outlined,),
                          title: Padding(padding: EdgeInsets.all(8.w).copyWith(left: 0,bottom: 0),
                         child: AppText.body("Account Limits"),
                          ),
                          subtitle: AppText.caption("view your transaction limits", color: Colors.grey,),
                          trailing: const Icon(Icons.arrow_forward_ios_sharp),
                        ),
                        ListTile(
                          leading: const Icon(Icons.ad_units_outlined,),
                          title: Padding(padding: EdgeInsets.all(8.w).copyWith(left: 0,bottom: 0),
                         child: AppText.body("Tranfer to me"),
                          ),
                          subtitle: AppText.caption("receive payments from other accounts", color: Colors.grey,),
                          trailing: const Icon(Icons.arrow_forward_ios_sharp),
                        ),
                        ListTile(
                          leading: const Icon(Icons.ad_units_outlined,),
                          title: Padding(padding: EdgeInsets.all(8.w).copyWith(left: 0,bottom: 0),
                         child: AppText.body("Bank Card /  Amount"),
                          ),
                          subtitle: AppText.caption("add new payment options", color: Colors.grey,),
                          trailing: const Icon(Icons.arrow_forward_ios_sharp),
                        ),
                      ],
                    ),
                  ),
                  Container(

                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                    ),
                    margin: EdgeInsets.all(8.h),
                    //height: 100,
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.ad_units_outlined,),
                          title: Padding(padding: const EdgeInsets.all(8),
                         child: AppText.body("Transaction History"),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios_sharp),
                        ),
                        ListTile(
                          leading: const Icon(Icons.ad_units_outlined,),
                          title: Padding(padding: EdgeInsets.all(8.w).copyWith(left: 0,bottom: 0),
                         child: AppText.body("Account Limits"),
                          ),
                          subtitle: AppText.caption("view your transaction limits", color: Colors.grey,),
                          trailing: const Icon(Icons.arrow_forward_ios_sharp),
                        ),
                        ListTile(
                          leading: const Icon(Icons.ad_units_outlined,),
                          title: Padding(padding: EdgeInsets.all(8.w).copyWith(left: 0,bottom: 0),
                         child: AppText.body("Transfer to me"),
                          ),
                          subtitle: AppText.caption("receive payments from other accounts", color: Colors.grey,),
                          trailing: const Icon(Icons.arrow_forward_ios_sharp),
                        ),
                        ListTile(
                          leading: const Icon(Icons.ad_units_outlined,),
                          title: Padding(padding: EdgeInsets.all(8.w).copyWith(left: 0,bottom: 0),
                         child: AppText.body("Bank Card /  Amount"),
                          ),
                          subtitle: AppText.caption("add new payment options", color: Colors.grey,),
                          trailing: const Icon(Icons.arrow_forward_ios_sharp),
                        ),
                      ],
                    ),
                  ),
                  Container(

                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                    ),
                    margin: EdgeInsets.all(8.h),
                    //height: 100,
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.ad_units_outlined,),
                          title: Padding(padding: const EdgeInsets.all(8),
                         child: AppText.body("Transaction History"),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios_sharp),
                        ),
                        ListTile(
                          leading: const Icon(Icons.transcribe_sharp,),
                          title: Padding(padding: EdgeInsets.all(8.w).copyWith(left: 0,bottom: 0),
                         child: AppText.body("Tranfer to me"),
                          ),
                          subtitle: AppText.caption("receive payments from other accounts", color: Colors.grey,),
                          trailing: const Icon(Icons.arrow_forward_ios_sharp),
                        ),
                        ListTile(
                          leading: const Icon(Icons.ad_units_outlined,),
                          title: Padding(padding: EdgeInsets.all(8.w).copyWith(left: 0,bottom: 0),
                         child: AppText.body("Bank Card /  Amount"),
                          ),
                          subtitle: AppText.caption("add new payment options", color: Colors.grey,),
                          trailing: const Icon(Icons.arrow_forward_ios_sharp),
                        ),
                      ],
                    ),
                  ),


                ],
              ),
            )

            )
          ],

      ),
    );
  }
}

