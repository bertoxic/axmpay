import 'package:AXMPAY/ui/widgets/custom_responsive_sizes/responsive_size.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/transaction_model.dart';

class TransactionDetailScreen extends StatelessWidget {
  final SpecificTransactionData transaction;

  const TransactionDetailScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Transaction Details',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.arrow_back, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: constraints.maxWidth * 0.04,
                  vertical: 16.h,
                ),
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: 600,
                  ),
                  decoration: BoxDecoration(
                    // color: Colors.white,
                    // borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(constraints),
                      SizedBox(
                        height: 16.h,
                      ),
                      _buildDetailsList(constraints),
                      SizedBox(height: 16.h),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BoxConstraints constraints) {
    double? transactionAmount =
    double.tryParse(transaction.amount?.toString() ?? '0');
    final formatter = NumberFormat.currency(locale: 'en_US', symbol: '₦');
    final isCredit = transaction.type.toLowerCase() == 'credit';
    final baseColor =
    isCredit ? const Color(0xFF2E7D32) : const Color(0xFFD32F2F);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(constraints.maxWidth * 0.06),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            baseColor.withOpacity(0.95),
            baseColor,
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: baseColor.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Transaction Icon with Animated Background
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
              border:
              Border.all(color: Colors.white.withOpacity(0.3), width: 2),
            ),
            child: Icon(
              isCredit ? Icons.account_balance_wallet : Icons.payment,
              color: Colors.white,
              size: constraints.maxWidth * 0.08,
            ),
          ),
          SizedBox(height: 20.h),

          // Amount Display
          Text(
            '${isCredit ? '+' : '-'} ${formatter.format(transactionAmount)}',
            style: TextStyle(
              fontSize: constraints.maxWidth * 0.08,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 16.h),

          // Transaction Type Pill
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(30),
              border:
              Border.all(color: Colors.white.withOpacity(0.3), width: 1),
            ),
            child: Text(
              transaction.action,
              style: TextStyle(
                fontSize: constraints.maxWidth * 0.04,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // Date and Time with Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.access_time,
                color: Colors.white.withOpacity(0.9),
                size: constraints.maxWidth * 0.04,
              ),
              SizedBox(width: 8.w),
              Text(
                DateFormat('MMMM d, yyyy • HH:mm')
                    .format(transaction.timeCreated),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: constraints.maxWidth * 0.035,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsList(BoxConstraints constraints) {
    double? balAfter = double.tryParse(transaction.balAfter?.toString() ?? '0');
    double? transactionFee =
    double.tryParse(transaction.fee?.toString() ?? '0');
    double? totalAmt =
    double.tryParse(transaction.totalAmount?.toString() ?? '0');
    final formatter = NumberFormat.currency(locale: 'en_US', symbol: '₦');

    return Container(
      padding: EdgeInsets.all(constraints.maxWidth * 0.05),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Transaction Information', constraints),
          SizedBox(height: 16.h),
          _buildDetailItem('Transaction ID:', transaction.trxID, constraints),
          _buildDetailDivider(),
          _buildDetailItem(
            (transaction.action == "Data" || transaction.action == "Airtime")
                ? "Description:"
                : "Account:",
            transaction.accountName,
            constraints,
          ),
          _buildDetailDivider(),
          _buildDetailItem('Status:', transaction.status, constraints,
              isStatus: true),
          _buildDetailDivider(),
          _buildDetailItem('Type:', transaction.type, constraints),
          SizedBox(height: 24.h),
          _buildSectionTitle('Financial Details', constraints),
          SizedBox(height: 16.h),
          _buildDetailItem(
              'Fee:', formatter.format(transactionFee), constraints),
          _buildDetailDivider(),
          _buildDetailItem(
              'Total Amount:', formatter.format(totalAmt), constraints),
          _buildDetailDivider(),
          _buildDetailItem(
              'Balance After:', formatter.format(balAfter), constraints),
          SizedBox(height: 24.h),
          _buildSectionTitle('Additional Information', constraints),
          SizedBox(height: 16.h),
          _buildDetailItem('Narration:', transaction.narration, constraints),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, BoxConstraints constraints) {
    return Text(
      title,
      style: TextStyle(
        fontSize: constraints.maxWidth * 0.045,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildDetailDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Divider(
        color: Colors.grey[200],
        thickness: 1,
      ),
    );
  }

  Widget _buildDetailItem(
      String label, String value, BoxConstraints constraints,
      {bool isStatus = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: constraints.maxWidth * 0.035,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: isStatus
                ? buildStatusChip(value, constraints)
                : Text(
              value,
              style: TextStyle(
                fontSize: constraints.maxWidth * 0.04,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildStatusChip(String status, BoxConstraints constraints) {
    final statusConfig = _getStatusConfig(status);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: constraints.maxWidth * 0.03,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            statusConfig.color.withOpacity(0.8),
            statusConfig.color,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: statusConfig.color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusConfig.icon,
            color: Colors.white,
            size: constraints.maxWidth * 0.035,
          ),
          SizedBox(width: 4.w),
          Text(
            status,
            style: TextStyle(
              color: Colors.white,
              fontSize: constraints.maxWidth * 0.035,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  StatusConfig _getStatusConfig(String status) {
    switch (status.toLowerCase()) {
      case 'success':
        return StatusConfig(Colors.green, Icons.check_circle);
      case 'pending':
        return StatusConfig(Colors.orange, Icons.access_time);
      case 'failed':
        return StatusConfig(Colors.red, Icons.error);
      default:
        return StatusConfig(Colors.grey, Icons.info);
    }
  }
}

class StatusConfig {
  final Color color;
  final IconData icon;

  StatusConfig(this.color, this.icon);
}
