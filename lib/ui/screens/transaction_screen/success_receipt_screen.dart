import 'package:AXMPAY/main.dart';
import 'package:AXMPAY/ui/widgets/check_mark_widget.dart';
import 'package:AXMPAY/ui/widgets/custom_dialog.dart';
import 'package:AXMPAY/ui/widgets/custom_responsive_sizes/responsive_size.dart';
import 'package:AXMPAY/utils/pdf_and_image_generator/pdf_generator.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:screenshot/screenshot.dart';

import '../../../models/transaction_model.dart';

class TopUpSuccessScreen extends StatelessWidget {
  final ReceiptData? receiptData;
   TopUpSuccessScreen({Key? key, this.receiptData}) : super(key: key);
  final ScreenshotController screenshotController = ScreenshotController();
  @override
  Widget build(BuildContext context) {
    double? amountTransfered = double.tryParse(receiptData?.order.amount.toString() ?? '0');
    double? merchantCharge = double.tryParse(receiptData?.merchant.merchantFeeAmount.toString() ?? '0');
    double? totalCharged = (amountTransfered! + merchantCharge!);
    final formatter = NumberFormat.currency(locale: 'en_US', symbol: '\₦');
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Screenshot(
            controller: screenshotController,
            child: Container( color: Colors.grey.shade100,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 40),
                      Center(
                        child: CheckmarkWithSpots(
                          size: 150.sp,
                          color: Colors.green.shade500,
                          spotCount: 24,
                        ),
                      ),
                      const SizedBox(height: 20),
                       Text(
                        "Your transfer was successfully made to ${receiptData?.customer.account.name??""}",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                       SizedBox(height: 10.h),
                      Text(
                        "Amount Sent",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        formatter.format(amountTransfered)??"",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                       SizedBox(height: 30.h),
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding:  EdgeInsets.all(16.0.sp),
                          child: Column(
                            children: [
                              _buildDetailRow("Debited Amount", formatter.format(totalCharged??0)),
                              _buildDetailRow("Recipient Name", receiptData?.customer.account.name??""),
                              _buildDetailRow("Recipient Acct", receiptData?.customer.account.number??""),
                              _buildDetailRow("from", receiptData?.customer.account.sendername??""),
                                _buildDetailRow("charge", "${formatter.format(merchantCharge)}"),
                                _buildDetailRow("Remark", "${receiptData?.narration??""}"),
                            ],
                          ),
                        ),
                      ),

                    ],
                  ),
                ),
              ),
            ),

          ),
          Spacer(),
          Padding(
            padding:  EdgeInsets.all(16.0.w),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.photo, color: colorScheme.primary),
                    label: const Text("image"),
                    onPressed: () async {
                      //generatePDF(context);
                      await ReceiptGenerator.captureAndSaveImage(context, screenshotController);
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: colorScheme.primary,
                      backgroundColor: Colors.white,
                      side: BorderSide(color: colorScheme.primary),
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: colorScheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text("Done"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  void _generatePDF(BuildContext context) {
    try{
    if (receiptData != null) {
      ReceiptGenerator.generatePdf(context, receiptData!);
    } else {
      CustomPopup.show(type: PopupType.error,
        context: context, title: "unable to generate pdf", message:'Unable to generate PDF. Receipt data is missing.',
      );
    }
    }catch(e){
      CustomPopup.show(type: PopupType.error,
          context: context, title: "Error", message: e.toString());
    }
  }
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}