import 'package:AXMPAY/main.dart';
import 'package:AXMPAY/ui/widgets/check_mark_widget.dart';
import 'package:AXMPAY/ui/widgets/custom_dialog.dart';
import 'package:AXMPAY/ui/widgets/custom_responsive_sizes/responsive_size.dart';
import 'package:AXMPAY/utils/pdf_and_image_generator/pdf_generator.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Background gradient
          Container(
            height: size.height * 0.4,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.green.withOpacity(0.1),
                  Colors.white,
                ],
              ),
            ),
          ),
          SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: size.height),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    Screenshot(
                      controller: screenshotController,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                        ),
                        child: SafeArea(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                SizedBox(height: 20.h),
                                // Success Animation Container with improved animation
                                Center(
                                  child: Container(
                                    width: 140.w,
                                    height: 140.w,
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
                                        size: 80.sp,
                                        color: Colors.green.shade600,
                                        spotCount: 24,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 30.h),
                                // Transaction Status and Date
                                Column(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16.w,
                                        vertical: 8.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade50,
                                        borderRadius: BorderRadius.circular(30),
                                        border: Border.all(color: Colors.green.shade200),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.check_circle,
                                              color: Colors.green.shade700,
                                              size: 16.sp
                                          ),
                                          SizedBox(width: 8.w),
                                          Text(
                                            "Transfer Successful",
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              color: Colors.green.shade700,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 8.h),
                                    Text(
                                      DateFormat('MMM d, yyyy • h:mm a').format(DateTime.now()),
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 24.h),
                                // Amount Section with improved styling
                                Container(
                                  padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 20.w),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 15,
                                        spreadRadius: 1,
                                        offset: Offset(0, 2),
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
                                          color: theme.colorScheme.primary,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        "Amount Transferred",
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 24.h),
                                // Recipient info with avatar
                                Container(
                                  padding: EdgeInsets.all(20.sp),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 15,
                                        spreadRadius: 1,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 50.w,
                                        height: 50.w,
                                        decoration: BoxDecoration(
                                          color: colorScheme.primary.withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Text(
                                            (receiptData?.customer.account.name?.isNotEmpty == true)
                                                ? receiptData!.customer.account.name![0].toUpperCase()
                                                : "?",
                                            style: TextStyle(
                                              fontSize: 20.sp,
                                              fontWeight: FontWeight.bold,
                                              color: colorScheme.primary,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 16.w),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              receiptData?.customer.account.name ?? "",
                                              style: TextStyle(
                                                fontSize: 18.sp,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            SizedBox(height: 4.h),
                                            Text(
                                              receiptData?.customer.account.number ?? "",
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 24.h),
                                // Transaction Details Card with improved layout
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 15,
                                        spreadRadius: 1,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(24.sp),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.receipt_long_rounded,
                                              color: colorScheme.primary,
                                              size: 20.sp,
                                            ),
                                            SizedBox(width: 8.w),
                                            Text(
                                              "Transaction Details",
                                              style: TextStyle(
                                                fontSize: 18.sp,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 16.h),
                                        _buildDetailRow(
                                          "Total Amount",
                                          formatter.format(totalCharged),
                                          isPrimary: true,
                                          theme: theme,
                                        ),
                                        _buildDivider(),
                                        _buildDetailRow(
                                          "Transfer Amount",
                                          formatter.format(amountTransfered),
                                          theme: theme,
                                        ),
                                        _buildDetailRow(
                                          "Service Charge",
                                          formatter.format(merchantCharge),
                                          theme: theme,
                                        ),
                                        _buildDivider(),
                                        _buildDetailRow(
                                          "From",
                                          receiptData?.customer.account.sendername ?? "",
                                          theme: theme,
                                        ),
                                        _buildDetailRow(
                                          "Transaction Code",
                                          receiptData?.code ?? "N/A",
                                          theme: theme,
                                        ),
                                        _buildDetailRow(
                                          "Remark",
                                          receiptData?.narration ?? "",
                                          theme: theme,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20.h),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(child: SizedBox(height: 20.h)),
                    // Bottom Buttons with better layout and options
                    Container(
                      padding: EdgeInsets.all(20.sp),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, -5),
                          ),
                        ],
                      ),
                      child: SafeArea(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                _buildActionButton(
                                  icon: Icons.download_rounded,
                                  label: "Save",
                                  onTap: () async {
                                    await ReceiptGenerator.captureAndSaveImage(
                                      context,
                                      screenshotController,
                                    );
                                  },
                                ),
                                SizedBox(width: 16.w),
                                _buildActionButton(
                                  icon: Icons.share_rounded,
                                  label: "Share",
                                  onTap: () async {
                                    final bytes = await screenshotController.capture();
                                    if (bytes != null) {
                                      // You'll need to implement sharing functionality
                                      // This is a placeholder for the share functionality
                                      // Share.shareXFiles([XFile.fromData(bytes, name: 'receipt.png')]);
                                    }
                                  },
                                ),
                                SizedBox(width: 16.w),
                                _buildActionButton(
                                  icon: Icons.print_rounded,
                                  label: "Print",
                                  onTap: () {
                                    // Implement print functionality
                                  },
                                ),
                              ],
                            ),
                            SizedBox(height: 16.h),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: colorScheme.primary,
                                elevation: 0,
                                padding: EdgeInsets.symmetric(vertical: 14.h),
                                minimumSize: Size(double.infinity, 55.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Text(
                                "Back to Home",
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SizedBox(height: 70.h,)
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: colorScheme.primary,
                size: 24.sp,
              ),
              SizedBox(height: 6.h),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isPrimary = false, required ThemeData theme}) {
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
              color: isPrimary ? theme.colorScheme.primary : Colors.black87,
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