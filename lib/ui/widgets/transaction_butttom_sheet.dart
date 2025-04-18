import 'package:AXMPAY/main.dart';
import 'package:AXMPAY/ui/widgets/custom_responsive_sizes/responsive_size.dart';
import 'package:flutter/material.dart';
import 'package:AXMPAY/models/transaction_model.dart';
import '../../models/recepients_model.dart';
import '../../utils/color_generator.dart';
import 'custom_buttons.dart';
import 'custom_container.dart';
import 'custom_text/custom_apptext.dart';

class BottomTransactionConfirmSheetContent extends StatefulWidget {
  final ScrollController controller;
  final Future<void> Function()? onTap;
  final TransactionModel? transactionModel;

  const BottomTransactionConfirmSheetContent({
    super.key,
    required this.controller,
    this.onTap,
    this.transactionModel,
  });

  @override
  _BottomTransactionConfirmSheetContentState createState() =>
      _BottomTransactionConfirmSheetContentState();
}

class _BottomTransactionConfirmSheetContentState extends State<BottomTransactionConfirmSheetContent> {
  bool _isLoading = false;

  Widget _buildTransactionDetail(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText.body(
            label,
            color: Colors.grey.shade700,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
          ),
          AppText.body(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ListView(
        controller: widget.controller,
        padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 12.h),
        children: [
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          SizedBox(height: 20.h),
          Center(
            child: Column(
              children: [
                AppText.headline(
                  "₦${widget.transactionModel?.amount}",
                  style: TextStyle(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                SizedBox(height: 8.h),
                AppText.body(
                  "Transaction Details",
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(16.sp),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _buildTransactionDetail("Account Number", "${widget.transactionModel?.recipientAccount}"),
                Divider(height: 16.h),
                _buildTransactionDetail("Recipient's Name", "${widget.transactionModel?.recipientAccountName}"),
                Divider(height: 16.h),
                _buildTransactionDetail("Recipient's Bank", "${widget.transactionModel?.recipientBankName}"),
                Divider(height: 16.h),
                _buildTransactionDetail("Amount", "₦${widget.transactionModel?.amount}"),
              ],
            ),
          ),

          SizedBox(height: 20.h),
          CustomButton(
            text: "CONFIRM PAYMENT",
            size: ButtonSize.large,
            width: double.infinity,
            onPressed: _isLoading ? null : _handleTap,
            customChild: _isLoading
                ? SizedBox(
              width: 24.w,
              height: 24.h,
              child: const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
                : Text(
              "CONFIRM PAYMENT",
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: 32.h),
          // Container(
          //   padding: EdgeInsets.all(16.sp),
          //   decoration: BoxDecoration(
          //     color: Colors.blue.withOpacity(0.1),
          //     borderRadius: BorderRadius.circular(16),
          //     border: Border.all(color: colorScheme.primary.withOpacity(0.2)),
          //   ),
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          //       Row(
          //         children: [
          //           Icon(Icons.account_balance_wallet, color: colorScheme.primary, size: 20.sp),
          //           SizedBox(width: 8.w),
          //           AppText.body("Source Account",
          //               style: TextStyle(fontSize: 14.sp, color: Colors.grey[600])),
          //         ],
          //       ),
          //       SizedBox(height: 12.h),
          //       AppText.body("${widget.transactionModel?.senderAccountName}",
          //           style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
          //       SizedBox(height: 4.h),
          //       AppText.body("${widget.transactionModel?.senderAccountNumber}",
          //           style: TextStyle(fontSize: 14.sp, color: Colors.grey[600])),
          //     ],
          //   ),
          // ),
          // SizedBox(height: 80.h),
        ],
      ),
    );
  }

  Future<void> _handleTap() async {
    if (widget.onTap != null) {
      setState(() => _isLoading = true);
      try {
        await widget.onTap!();
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
      Navigator.pop(context);
    }
  }
}
