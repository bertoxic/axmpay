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
    final formatter = NumberFormat.currency(locale: 'en_US', symbol: '₦');
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: size.height),
          child: IntrinsicHeight(
            child: Column(
              children: [
                Screenshot(
                  controller: screenshotController,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white,
                          Colors.blue.shade50.withOpacity(0.3),
                        ],
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(height: 20.h),
                            // Success Animation Container
                            Center(
                              child: Container(
                                width: 160.w,
                                height: 160.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.green.shade50,
                                      Colors.green.shade100,
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.green.withOpacity(0.2),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: CheckmarkWithSpots(
                                    size: 100.sp,
                                    color: Colors.green.shade500,
                                    spotCount: 24,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 40.h),
                            // Amount Section
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 20.h),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.03),
                                    blurRadius: 10,
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    formatter.format(amountTransfered),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 40.sp,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black87,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16.w,
                                      vertical: 6.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade50,
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: Text(
                                      "Transfer Successful",
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        color: Colors.green.shade700,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 24.h),
                            // Recipient Name
                            Text(
                              "Sent to",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              receiptData?.customer.account.name ?? "",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 24.h),
                            // Transaction Details Card
                            Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(color: Colors.grey.shade200),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(24.sp),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Transaction Details",
                                      style: TextStyle(
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    SizedBox(height: 20.h),
                                    _buildDetailRow(
                                      "Total Amount",
                                      formatter.format(totalCharged),
                                      isPrimary: true,
                                    ),
                                    _buildDivider(),
                                    _buildDetailRow(
                                      "Account Number",
                                      receiptData?.customer.account.number ?? "",
                                    ),
                                    _buildDetailRow(
                                      "From",
                                      receiptData?.customer.account.sendername ?? "",
                                    ),
                                    _buildDetailRow(
                                      "Service Charge",
                                      formatter.format(merchantCharge),
                                    ),
                                    _buildDetailRow(
                                      "Remark",
                                      receiptData?.narration ?? "",
                                    ),
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
                Expanded(child: SizedBox(height: 20.h)),
                // Bottom Buttons
                Container(
                  padding: EdgeInsets.all(20.sp),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: Icon(
                              Icons.download_rounded,
                              color: colorScheme.primary,
                              size: 20.sp,
                            ),
                            label: Text(
                              "Save Receipt",
                              style: TextStyle(fontSize: 14.sp),
                            ),
                            onPressed: () async {
                              await ReceiptGenerator.captureAndSaveImage(
                                context,
                                screenshotController,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: colorScheme.primary,
                              backgroundColor: Colors.white,
                              side: BorderSide(color: colorScheme.primary),
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: colorScheme.primary,
                              elevation: 0,
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              "Done",
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildDetailRow(String label, String value, {bool isPrimary = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: isPrimary ? 16.sp : 14.sp,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isPrimary ? FontWeight.bold : FontWeight.w500,
              fontSize: isPrimary ? 18.sp : 14.sp,
              color: isPrimary ? Colors.black87 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Divider(
        color: Colors.grey.shade200,
        thickness: 1,
      ),
    );
  }
}