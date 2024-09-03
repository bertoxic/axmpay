  import 'package:fintech_app/main.dart';
import 'package:fintech_app/ui/widgets/custom_responsive_sizes/responsive_size.dart';
import 'package:fintech_app/ui/widgets/custom_text/custom_apptext.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class UserProfileScreen extends StatelessWidget {
    const UserProfileScreen({super.key});

    @override
    Widget build(BuildContext context) {
      double width =  MediaQuery.sizeOf(context).width;
      double height =  MediaQuery.sizeOf(context).height;
      return  SizedBox(
        height: height,
        width: width,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SizedBox(
            height: height,
            width: width,
            child: Container(
              color: colorScheme.onPrimary,
              child: Stack(
               fit: StackFit.expand,
                children: [
                  Positioned(
                    top: 0,  width: width,
                    child: Container(
                      height: 250.h,
                      width: 500,
                      decoration: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28))
                      ),
                      child: const Text("obey"),
                    ),
                  ),
                  Positioned(
                    top: 50.h, left: 20.w,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 100.h,
                          width: 100.w,
                          decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: const BorderRadius.all(Radius.circular(12))),
                          child: const Text('TOM june'),
                        ),
                        SizedBox(width: 20.w,),
                         Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             Container(
                               child: Column(
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 children: [
                                   AppText.title("Jude Bakerly",color: colorScheme.onPrimary,),
                                   AppText.body("JudeBakerly@gmail.com",color: colorScheme.onPrimary,),
                                   AppText.body("phone: +345 784 9847",color: colorScheme.onPrimary,),
                                 ],
                               ),
                             ),
                             SizedBox(height: 20.h,),
                             Row(
                               children: [
                                 AppText.body("status: verified",color: Colors.grey.shade300,),
                                 const Icon(Icons.verified, color: Colors.green,)
                               ],
                             ),
                           ],
                         ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 220.h,
                    left: 20.w, width:(width-40.h),
                    child: Container(
                      height: 100.h,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 5,spreadRadius: 0.4,offset: Offset(3,2))
                        ]
                      ),
                      child:   Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("AccountNumber: 0098345763"),
                                AppText.caption("BVN: 22034576831"),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 340.h,
                    left: 10.w, width:(width-20.h),
                    child: Container(
                      height: 500.h,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12)
                      ),
                      child:   Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: (){
                                context.pushNamed("forgot_password_input_mail");
                              },
                              child:      Container(
                                padding:  EdgeInsets.all(8.0.sp ),
                                margin: EdgeInsets.symmetric(vertical:
                                4.h),
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(Radius.circular(28)),
                                  color: colorScheme.onPrimary,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Row(
                                      children: [
                                        const CircleAvatar(backgroundColor: Colors.grey,
                                            child: Icon(Icons.lock)),//lutrozesp
                                        const SizedBox(width: 10,),// u@gufum.com
                                        AppText.body("Change your password"),
                                      ],
                                    ),
                                    const Icon(Icons.arrow_forward_ios_sharp)
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              padding:  EdgeInsets.all(8.0.sp ),
                              margin: EdgeInsets.symmetric(vertical:
                              4.h),
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(Radius.circular(28)),
                                color: colorScheme.onPrimary,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                    children: [
                                      const CircleAvatar(backgroundColor: Colors.redAccent,
                                          child: Icon(Icons.file_copy)),//lutrozesp
                                      const SizedBox(width: 10,),// u@gufum.com
                                      AppText.body("Terms and conditions"),
                                    ],
                                  ),
                                  const Icon(Icons.arrow_forward_ios_sharp)
                                ],
                              ),
                            ),
                            Container(
                              padding:  EdgeInsets.all(8.0.sp ),
                              margin: EdgeInsets.symmetric(vertical:
                              4.h),
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(Radius.circular(28)),
                                color: colorScheme.onPrimary,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                    children: [
                                      const CircleAvatar(backgroundColor: Colors.green,
                                          child: Icon(Icons.pending_actions_rounded)),//lutrozesp
                                      const SizedBox(width: 10,),// u@gufum.com
                                      AppText.body("FAQ"),
                                    ],
                                  ),
                                  const Icon(Icons.arrow_forward_ios_sharp)
                                ],
                              ),
                            ),
                            Container(
                              padding:  EdgeInsets.all(8.0.sp ),
                              margin: EdgeInsets.symmetric(vertical:
                              4.h),
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(Radius.circular(28)),
                                color: colorScheme.onPrimary,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                    children: [
                                      const CircleAvatar(backgroundColor: Colors.orange,
                                          child: Icon(Icons.mail_lock_sharp)),//lutrozespu@gufum.com
                                      const SizedBox(width: 10,),// u@gufum.com
                                      AppText.body("Contact us"),
                                    ],
                                  ),
                                  const Icon(Icons.arrow_forward_ios_sharp)
                                ],
                              ),
                            ),
                            Container(
                              padding:  EdgeInsets.all(8.0.sp ),
                              margin: EdgeInsets.symmetric(vertical:
                              4.h),
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(Radius.circular(28)),
                                color: colorScheme.onPrimary,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                    children: [
                                      const CircleAvatar(backgroundColor: Colors.purple,
                                          child: Icon(Icons.exit_to_app_outlined)),//lutrozesp
                                      const SizedBox(width: 10,),// u@gufum.com
                                      AppText.body("Log out"),
                                    ],
                                  ),
                                  const Icon(Icons.arrow_forward_ios_sharp)
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }
