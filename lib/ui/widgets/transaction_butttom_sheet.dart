import 'package:fintech_app/ui/widgets/custom_responsive_sizes/responsive_size.dart';
import 'package:fintech_app/utils/color_generator.dart';
import 'package:flutter/material.dart';

import '../../models/recepients_model.dart';
import 'custom_buttons.dart';
import 'custom_container.dart';
import 'custom_text/custom_apptext.dart';

class BottomTransactionConfirmSheetContent extends StatelessWidget {
  final ScrollController controller;
  final Function()? onTap;
  TransactionModel? transactionModel;
  BottomTransactionConfirmSheetContent(
      {super.key, required this.controller, this.onTap, this.transactionModel});
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
          child: SpacedContainer(
            margin: EdgeInsets.all(12.sp),
            child: Column(
              children: [
                Center(
                  child: AppText.headline("${transactionModel?.amount}"),
                ),
                SizedBox(
                  height: 16.h,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppText.body(
                        "Account number",
                        color: Colors.grey.shade500,
                      ),
                      AppText.body("${transactionModel?.recipientAccount}"),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.0.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppText.body(
                        "Recipient's Name",
                        color: Colors.grey.shade500,
                      ),
                      AppText.body("${transactionModel?.recipientAccountName}"),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.0.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppText.body(
                        "Recipient's Bank",
                        color: Colors.grey.shade500,
                      ),
                      AppText.body("${transactionModel?.recipientBankName}"),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppText.body(
                        "Amount:",
                        color: Colors.grey.shade500,
                      ),
                      AppText.body(" ${transactionModel?.amount}")
                    ],
                  ),
                ),
                SizedBox(
                  height: 20.h,
                ),
                Container(
                  decoration: BoxDecoration(
                      //color: const Color(0xffdeffe6),
                      color: getRandomColor().withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8)),
                  padding:
                  EdgeInsets.symmetric(horizontal: 10.w, vertical: 16.w),
                  width: double.maxFinite,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        Icons.wallet_sharp,
                        color: getRandomColor(),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText.caption("Account to be Debited"),
                          AppText.caption(
                              "${transactionModel?.senderAccountName}"),
                          AppText.caption(
                            "${transactionModel?.senderAccountNumber}",
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      // SizedBox(width: 30.w,),
                      Row(
                        children: [
                          AppText.caption(
                            "Top up ",
                            style: const TextStyle(fontSize: 12),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios_outlined,
                            size: 12,
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 40.h,
                ),
                CustomButton(
                  text: "SEND",
                  size: ButtonSize.large,
                  width: double.maxFinite,
                  onPressed: onTap,
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}