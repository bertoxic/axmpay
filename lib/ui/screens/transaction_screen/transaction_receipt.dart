import 'dart:ffi';

import 'package:AXMPAY/main.dart';
import 'package:AXMPAY/models/transaction_model.dart';
import 'package:AXMPAY/ui/widgets/custom_responsive_sizes/responsive_size.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReceiptPopup extends StatelessWidget {
  final ReceiptData? receiptData;

  const ReceiptPopup({
    Key? key,
    required this.receiptData,

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double? balance = double.tryParse(receiptData?.order.amount.toString() ?? '0');
    double? merchantCharge = double.tryParse(receiptData?.merchant.merchantFeeAmount.toString() ?? '0');
    final formatter = NumberFormat.currency(locale: 'en_US', symbol: '\₦');
    return Dialog(
      child: Container(
        padding:  EdgeInsets.all(16.sp),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Text(
              'AXMpay',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold,color: colorScheme.primary),
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: colorScheme.primary,
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 12.sp,vertical: 4.sp),
                    child:  Center(
                      child: Text(
                        DateFormat('EEE, MMM d, yyyy • h:mm:ss a').format(DateTime.now()),
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade100),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      //border: Border.all(color: Colors.grey,width: 0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Row(
                        children: [
                          Text(
                            "Success",
                            style: TextStyle( fontWeight: FontWeight.normal,color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            _buildInfoRow('Token Type', 'Debit'),
            _buildInfoRow('Recipient Name', receiptData?.customer.account.name??""),
            _buildInfoRow('Recipient Bank Code', receiptData?.customer.account.bank??""),
            _buildInfoRow('Recipient AccountNumber', receiptData?.customer.account.number??""),
            _buildInfoRow('Sender Name', receiptData?.customer.account.sendername??""),
            _buildInfoRow('Amount', '${formatter.format(balance)}'),
            _buildInfoRow('Desc', receiptData?.order.description??""),
            _buildInfoRow('Charge', '${formatter.format(merchantCharge)} '),
             _buildInfoRow('Total', '${formatter.format( merchantCharge??0.00+balance!)}'),
            // _buildInfoRow('Operator', operator),
            SizedBox(height: 16.h),
            const Center(
              child: Text(
                'AXMpay',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey)),
          Text(value, style: TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  void showReceiptPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ReceiptPopup(
        receiptData: receiptData,
      ),
    );
  }
}

