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

class _BottomTransactionConfirmSheetContentState
    extends State<BottomTransactionConfirmSheetContent> {
  bool _isLoading = false;

  Widget _buildTransactionDetail(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText.body(
            label,
            color: Colors.grey.shade600,
            style: TextStyle(fontSize: 14.sp),
          ),
          AppText.body(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: widget.controller,
      children: [
        SizedBox(height: 12.h),
        Center(
          child: Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        SizedBox(height: 20.h),
        Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SpacedContainer(
            margin: EdgeInsets.all(16.sp).copyWith(top: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      AppText.headline(
                        "₦${widget.transactionModel?.amount}",
                        style: TextStyle(
                          fontSize: 32.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
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
                SizedBox(height: 24.h),
                Container(
                  padding: EdgeInsets.all(16.sp),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _buildTransactionDetail(
                        "Account Number",
                        "${widget.transactionModel?.recipientAccount}",
                      ),
                      Divider(height: 16.h),
                      _buildTransactionDetail(
                        "Recipient's Name",
                        "${widget.transactionModel?.recipientAccountName}",
                      ),
                      Divider(height: 16.h),
                      _buildTransactionDetail(
                        "Recipient's Bank",
                        "${widget.transactionModel?.recipientBankName}",
                      ),
                      Divider(height: 16.h),
                      _buildTransactionDetail(
                        "Amount",
                        "₦${widget.transactionModel?.amount}",
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.blue.withOpacity(0.2)),
                  ),
                  padding: EdgeInsets.all(16.sp),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.account_balance_wallet,
                            color: Colors.blue,
                            size: 20.sp,
                          ),
                          SizedBox(width: 8.w),
                          AppText.body(
                            "Source Account",
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      AppText.body(
                        "${widget.transactionModel?.senderAccountName}",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      AppText.body(
                        "${widget.transactionModel?.senderAccountNumber}",
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 32.h),
                CustomButton(
                  text: "CONFIRM PAYMENT",
                  size: ButtonSize.large,
                  width: double.maxFinite,
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
                SizedBox(height:80.h),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleTap() async {
    if (widget.onTap != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        await widget.onTap!();
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }

      Navigator.pop(context);
    }
  }
}