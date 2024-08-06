import 'package:fintech_app/main.dart';
import 'package:fintech_app/ui/%20widgets/custom_responsive_sizes/responsive_size.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/user_model.dart';

class TransactionDetailScreen extends StatelessWidget {
  final SpecificTransactionData transaction;

  const TransactionDetailScreen({Key? key, required this.transaction})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Details'),
        elevation: 0,
      ),
      body: Padding(
        padding:  EdgeInsets.all(12.w),
        child: SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
//              color: Colors.white,
              borderRadius: BorderRadius.circular(8)
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                _buildDetailsList(),
                SizedBox(height: 12,)
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: transaction.type.toLowerCase() == 'credit'
                  ? Colors.green[50]
                  : Colors.red[50],
              borderRadius: const BorderRadius.only(bottomRight: Radius.circular(12),bottomLeft: Radius.circular(12))
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '${transaction.type.toLowerCase() == 'credit' ? '+' : '-'} \$${transaction.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: transaction.type.toLowerCase() == 'credit'
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
                 SizedBox(height: 8.h),
                Text(
                  transaction.action,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Text(
                  DateFormat('MMMM d, yyyy HH:mm').format(transaction.timeCreated),
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsList() {
    return Container(
      decoration: BoxDecoration(
        color: transaction.type.toLowerCase() == 'credit'
            ? Colors.grey[50]
            : Colors.grey[50],
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(8),topRight: Radius.circular(8))

      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailItem('Transaction ID:', transaction.trxID),
            _buildDetailItem('Account:', transaction.accountName),
            _buildDetailItem('Status:', transaction.status, isStatus: true),
            _buildDetailItem('Type:', transaction.type),
            _buildDetailItem('Fee:', '\$${transaction.fee.toStringAsFixed(2)}'),
            _buildDetailItem('Total Amount:',
                '\$${transaction.totalAmount.toStringAsFixed(2)}'),
            _buildDetailItem('Balance After:', transaction.balAfter),
            _buildDetailItem('Narration:', transaction.narration),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, {bool isStatus = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.w,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          SizedBox(
            child: isStatus
                ? buildStatusChip(value)
                : Text(
                    value,
                    style: const TextStyle(fontSize: 16),
                  ),
          ),
        ],
      ),
    );
  }

  Widget buildStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'success':
        color = Colors.green;
        break;
      case 'pending':
        color = Colors.orange;
        break;
      case 'failed':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: EdgeInsets.all(4).copyWith(left: 16.w, right: 16.w),
      // width: 20.w,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
