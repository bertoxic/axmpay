import 'package:AXMPAY/ui/widgets/custom_responsive_sizes/responsive_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../models/transaction_model.dart';
import '../../../utils/pdf_and_image_generator/dowload_receipt.dart';

class TransactionDetailScreen extends StatelessWidget {
  final GlobalKey receiptKey = GlobalKey();
  final SpecificTransactionData transaction;
   TransactionDetailScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.type.toLowerCase() == 'credit';
    final themeColor = isCredit
        ? const Color(0xFF0A8754)  // Rich green for credit
        : const Color(0xFFE63946); // Modern red for debit

    // Set status bar color to match theme
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: Colors.grey[50],
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_back, size: 20, color: Colors.black87),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.share_outlined, size: 20, color: Colors.black87),
              ),
              onPressed: () {
                // Share transaction details
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: RepaintBoundary(
          key: receiptKey,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Container(
                color: Colors.white,
                child: Column(
                  children: [
                    _buildTransactionStatus(themeColor, isCredit),
                    const SizedBox(height: 16),
                    _buildAmountDisplay(themeColor, isCredit),
                    const SizedBox(height: 32),
                    _buildInfoCards(context, themeColor),
                    const SizedBox(height: 24),
                    _buildActionButtons(context, themeColor),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'success':
        return 'Completed Successfully';
      case 'pending':
        return 'Processing';
      case 'failed':
        return 'Transaction Failed';
      default:
        return status;
    }
  }
  Widget _buildTransactionStatus(Color themeColor, bool isCredit) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            spreadRadius: 1,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Transaction status icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isCredit
                  ? Colors.green.withOpacity(0.8)
                  : Colors.red.withOpacity(0.8),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCredit ? Icons.arrow_downward : Icons.arrow_upward,
              color: isCredit ? Colors.white.withOpacity(0.9) : Colors.white.withOpacity(0.9),
              size: 18,
            ),
          ),
          const SizedBox(width: 12),

          // Transaction details
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isCredit ? 'Funds Received' : 'Payment Sent',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
    DateFormat('d MMM yyy,  HH:mma').format(transaction.timeCreated) ?? 'Just now',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),

          const Spacer(),

          // Status indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isCredit
                  ? Colors.green.withOpacity(0.1)
                  : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isCredit ? 'Completed' : 'Sent',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isCredit ? Colors.green[700] : Colors.orange[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountDisplay(Color themeColor, bool isCredit) {
    double? transactionAmount = double.tryParse(transaction.amount?.toString() ?? '0');
    final formatter = NumberFormat.currency(locale: 'en_US', symbol: '₦');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            themeColor.withOpacity(0.95),
            themeColor,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: themeColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _getStatusText(transaction.status),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${isCredit ? '+' : '-'} ${formatter.format(transactionAmount)}',
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
           SizedBox(height: 16.h),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              transaction.action,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
           SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                color: Colors.white,
                size: 14,
              ),
              const SizedBox(width: 6),
              Text(
                DateFormat('MMMM d, yyyy • HH:mm').format(transaction.timeCreated),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCards(BuildContext context, Color themeColor) {
    double? balAfter = double.tryParse(transaction.balAfter?.toString() ?? '0');
    double? transactionFee = double.tryParse(transaction.fee?.toString() ?? '0');
    double? totalAmt = double.tryParse(transaction.totalAmount?.toString() ?? '0');
    final formatter = NumberFormat.currency(locale: 'en_US', symbol: '₦');

    return Column(
      children: [
        _buildInfoCard(
          'Transaction Details',
          [
            _buildInfoRow('Transaction ID', transaction.trxID),
            _buildInfoRow('Type', transaction.type),
            _buildInfoRow(
                (transaction.action == "Data" || transaction.action == "Airtime")
                    ? "Description"
                    : "Account",
                transaction.accountName),
          ],
          leading: Icons.receipt_long_rounded,
          themeColor: themeColor,
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          'Financial Details',
          [
            _buildInfoRow('Fee', formatter.format(transactionFee)),
            _buildInfoRow('Total Amount', formatter.format(totalAmt)),
            _buildInfoRow('Balance After', formatter.format(balAfter)),
          ],
          leading: Icons.account_balance_wallet_outlined,
          themeColor: themeColor,
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          'Additional Information',
          [
            _buildInfoRow('Narration', transaction.narration),
          ],
          leading: Icons.info_outline_rounded,
          themeColor: themeColor,
        ),
      ],
    );
  }

  Widget _buildInfoCard(
      String title,
      List<Widget> details, {
        required IconData leading,
        required Color themeColor,
      }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: themeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    leading,
                    color: themeColor,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: details),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, Color themeColor) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () async{
              await downloadTransactionReceipt(
              transaction: transaction,
              context: context,
              receiptKey: receiptKey,
              format: 'image', // or 'image'
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: themeColor,
              side: BorderSide(color: themeColor),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image, size: 18, color: themeColor),
                const SizedBox(width: 8),
                const Text(
                  'Download Image',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () async{
              await downloadTransactionReceipt(
                transaction: transaction,
                context: context,
                receiptKey: receiptKey,
                format: 'pdf', // or 'image'
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: themeColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.picture_as_pdf_rounded, size: 18),
                const SizedBox(width: 8),
                const Text(
                  'Download pdf',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'success':
        return const Color(0xFF0A8754);
      case 'pending':
        return const Color(0xFFF9A826);
      case 'failed':
        return const Color(0xFFE63946);
      default:
        return Colors.grey;
    }
  }
}