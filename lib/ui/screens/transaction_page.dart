import 'package:fintech_app/constants/app_colors.dart';
import 'package:fintech_app/ui/%20widgets/custom_buttons.dart';
import 'package:fintech_app/ui/%20widgets/custom_container.dart';
import 'package:fintech_app/ui/%20widgets/custom_responsive_sizes/responsive_size.dart';
import 'package:fintech_app/ui/%20widgets/custom_text/custom_apptext.dart';
import 'package:fintech_app/ui/%20widgets/custom_textfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TransferScreen extends StatelessWidget {
  const TransferScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(),
      body: SpacedContainer(
        containerColor: Colors.grey.shade200,
        margin: const EdgeInsets.all(8),  
        child: SingleChildScrollView(
          child: Column(
                children: [
                  Padding(
                    padding:  EdgeInsets.symmetric(vertical: 12.0.sp),
                    child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(8.sp),
                            child:  CircleAvatar(radius: 20,
                            backgroundColor: Colors.grey.shade300,
                            child: Icon(Icons.person),
                            )),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText.caption("kanibari numan"),
                            AppText.body("07 74994888")
                          ],
                        ),

                      ],
                    ),
                  ),
                  Container(
                    height: 150.sp,
                    padding: EdgeInsets.all(12.sp),
                    decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(8)
                    ),

                    child: Column(
                      children: [
                        Row(
                          children: [
                            AppText.body("Amount"),
                            SizedBox(
                              width: 20.sp,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  color: Colors.green.shade200,
                                  borderRadius: BorderRadius.circular(16)
                              ),
                              child: SpacedContainer(
                                padding: EdgeInsets.all(4.sp),
                                child: AppText.caption(
                                  "transaction amount",
                                  color: Colors.green.shade800,
                                ),
                              ),

                            )
                          ],
                        ),
                        SizedBox(height: 8.sp,),
                        CustomTextField(
                          hintText: "  100 - 50 000 000",
                            prefix: AppText.body("\$"),
                            decoration: const InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderSide:BorderSide(color: Color(0xFAEAEAEA)),
                                    borderRadius: BorderRadius.all(Radius.circular(12))
                              ),
                              focusedBorder: UnderlineInputBorder(

                              )
                            ),
                            fieldName: "transaction_amount")
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 30.h,
                  ),
                  Container(
                    height: 150.h,
                    width: double.maxFinite,
                    padding: EdgeInsets.all(16.sp),
                    decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(8)
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText.body("Remark"),
                        SizedBox(height: 8.sp,),
                        CustomTextField(
                          hintText: "write anything here",
                            decoration: InputDecoration(
                              filled: true,
                                fillColor: AppColors.lightgrey,
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide.none
                                ),
                                focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.green.shade800)
                                )
                            ),
                            fieldName: "remark")
                      ],
                    ),),
  SizedBox(height: 50.h,),
                CustomButton(
                    text: "Confirm",
                  type: ButtonType.elevated,
                   size: ButtonSize.large,
                  width: 220.w,
                  onPressed: ()=> _showBottomSheet(context),
                )



                ],
          ),
        ),
      ),
    );
  }
}

void _showBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.1,
      maxChildSize: 0.65,
      expand: false,
      builder: (_, controller) => BottomSheetContent(controller: controller),
    ),
  );
}

class BottomSheetContent extends StatelessWidget {
  final ScrollController controller;

  const BottomSheetContent({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: controller,
      children: [
        SizedBox(height: 10.h),
        Center(
          child: Container(
            width: 40.h,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        SizedBox(height: 10.h),
        Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child:SpacedContainer(
            margin: EdgeInsets.all(12.sp),
            child: Column(
              children: [
                Center(
                  child: AppText.headline("800"),
                ),
                SizedBox(height: 16.h,),
                Padding(
                  padding:  EdgeInsets.symmetric(vertical: 4.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppText.body("Account number",color: Colors.grey.shade500,),
                      AppText.body("700 9890 8977"),
                    ],
                  ),
                ),
                Padding(
                  padding:  EdgeInsets.symmetric(vertical: 4.0.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppText.body("Recipient's Name",color: Colors.grey.shade500,),
                      AppText.body("Barry felix king"),
                    ],
                  ),
                ),
                Padding(
                  padding:  EdgeInsets.symmetric(vertical: 4.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppText.body("Amount",color: Colors.grey.shade500,),
                      AppText.body(" 700 "),
                    ],
                  ),
                ),
                SizedBox(height: 20.h,),
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xffdeffe6),
                    borderRadius: BorderRadius.circular(8)
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 10.w,vertical: 16.w),
                  width: double.maxFinite,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(Icons.wallet_sharp,color: Colors.green.shade700,),
                      //  SizedBox(width: 30.w,),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText.caption("Account to be Debited"),
                            AppText.caption("Azuma nioman"),
                          ],
                        ),
                       // SizedBox(width: 30.w,),
                        Row(
                          children: [
                            AppText.caption("Top up ", style: const TextStyle(fontSize: 12), ),
                            const Icon(Icons.arrow_forward_ios_outlined,size: 12,)
                          ],
                        ),
                        
                      ],
                    ),
                ),
                SizedBox(height: 40.h,),
                const CustomButton(text: "SEND", size: ButtonSize.large,width: double.maxFinite,)
              ],
            ),
          ),
        ),
      ],
    );
  }
}