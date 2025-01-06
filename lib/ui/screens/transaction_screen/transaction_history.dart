import 'package:AXMPAY/ui/widgets/custom_dialog.dart';
import 'package:AXMPAY/ui/widgets/custom_responsive_sizes/responsive_size.dart';
import 'package:AXMPAY/ui/widgets/custom_text/custom_apptext.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart'; // Add this import

import '../../../models/transaction_model.dart';
import '../../../providers/user_service_provider.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TransactionHistoryPage extends StatefulWidget {
  const TransactionHistoryPage({super.key});

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  late Future<List<TransactionHistoryModel>> _transactionHistoryFuture;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  String? _processingTransactionId;

  @override
  void initState() {
    super.initState();
    _transactionHistoryFuture = _fetchTransactionHistory();
  }

  Future<List<TransactionHistoryModel>> _fetchTransactionHistory() {
    return Provider.of<UserServiceProvider>(context, listen: false)
        .fetchTransactionHistory(context);
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _transactionHistoryFuture = _fetchTransactionHistory();
    });
  }

  String _formatDateHeader(String dateString) {
    final date = DateTime.parse(dateString);
    final now = DateTime.now();

    if (_isSameDay(date, now)) {
      return 'Today';
    } else if (_isSameDay(date, now.subtract(const Duration(days: 1)))) {
      return 'Yesterday';
    }
    return DateFormat('MMMM d, yyyy').format(date);
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
  Widget _buildShimmerLoading() {
    return ListView.builder(
      itemCount: 8,
      padding: EdgeInsets.only(top: 30),
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Container(
            padding: EdgeInsets.all(16.sp),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.08),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Transaction Icon Placeholder
                  Container(
                    width: 48.w,
                    height: 48.h,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],  // Changed color
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  // Transaction Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Name Placeholder
                            Container(
                              width: 150.w,
                              height: 14.h,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],  // Changed color
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            // Amount Placeholder
                            Container(
                              width: 80.w,
                              height: 14.h,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],  // Changed color
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Transaction ID Placeholder
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 100.w,
                                  height: 10.h,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],  // Changed color
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Container(
                                  width: 80.w,
                                  height: 10.h,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],  // Changed color
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ],
                            ),
                            // Status Badge Placeholder
                            Container(
                              width: 70.w,
                              height: 24.h,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],  // Changed color
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  Future<void> _handleTransactionTap(TransactionHistoryModel transaction, UserServiceProvider userProvider) async {
    if (_processingTransactionId != null) return; // Prevent multiple clicks

    setState(() {
      _processingTransactionId = transaction.trxID;
    });

    try {
      print("Fetching transaction details for ${transaction.trxID}");
      SpecificTransactionData transactionData = await userProvider.fetchTransactionDetails(
        context,
        transaction.trxID.toString(),
      );

      if (!mounted) return;

      await context.pushNamed(
        'transaction_details',
        pathParameters: {'trxID': transaction.trxID.toString()},
        extra: transactionData,
      );
    } catch (e) {
      if (mounted) {
        CustomPopup.show(
            type: PopupType.error,
            context: context,
            title: "error occurred",
            message: "error fetching transaction details"
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _processingTransactionId = null;
        });
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserServiceProvider>(context, listen: false);

    return Material(
      child: FutureBuilder<List<TransactionHistoryModel>>(
        future: _transactionHistoryFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildShimmerLoading();
          } else if (snapshot.hasError) {
            return _buildErrorWidget();
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return Scaffold(
              appBar: AppBar(
                centerTitle: false,
                title: const Text("Transactions History"),
                elevation: 0,
              ),
              body: RefreshIndicator(
                key: _refreshIndicatorKey,
                onRefresh: _handleRefresh,
                color: Theme.of(context).primaryColor,
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 30),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final transaction = snapshot.data![index];

                    // Check if we need to show a date header
                    final showDateHeader = index == 0 || !_isSameDay(
                      DateTime.parse(snapshot.data![index].dateCreated),
                      DateTime.parse(snapshot.data![index - 1].dateCreated),
                    );

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (showDateHeader) ...[
                          Padding(
                            padding: EdgeInsets.only(
                              top: index == 0 ? 0 : 24.h,
                              bottom: 12.h,
                              left: 4.w,
                            ),
                            child: Text(
                              _formatDateHeader(transaction.dateCreated),
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                                fontSize: 13.sp,
                              ),
                            ),
                          ),
                        ],
                        _TransactionItem(
                          transaction: transaction,
                          userProvider: userProvider,
                          isProcessing: _processingTransactionId == transaction.trxID,
                          onTap: () => _handleTransactionTap(transaction, userProvider),
                        ),
                      ],
                    );
                  },
                ),
              ),
            );
          } else {
            return _buildEmptyState();
          }
        },
      ),
    );
  }

// ... rest of the existing methods (_buildShimmerLoading, _buildErrorWidget,
// _buildEmptyState, _handleTransactionTap) remain the same

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.hourglass_empty, size: 64.sp, color: Colors.grey),
          SizedBox(height: 16.h),
          Text(
            "No transactions found",
            style: TextStyle(fontSize: 16.sp, color: Colors.grey),
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: _handleRefresh,
            child: Text("Refresh"),
          ),
        ],
      ),
    );
  }
  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 60.sp),
          SizedBox(height: 16.h),
          Text(
            "An error occurred while fetching transactions.",
            style: TextStyle(fontSize: 16.sp),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _transactionHistoryFuture = _fetchTransactionHistory();
              });
            },
            child: Text("Retry"),
          ),
        ],
      ),
    );
  }
}


class _TransactionItem extends StatelessWidget {
  final TransactionHistoryModel transaction;
  final UserServiceProvider userProvider;
  final bool isProcessing;
  final VoidCallback onTap;

  const _TransactionItem({
    Key? key,
    required this.transaction,
    required this.userProvider,
    required this.isProcessing,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: InkWell(
        onTap: isProcessing ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.08),
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(16.sp),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Transaction Icon Container
                Container(
                  width: 48.w,
                  height: 48.h,
                  decoration: BoxDecoration(
                    color: transaction.action == 'Receive'
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: isProcessing
                        ? SizedBox(
                      width: 24.w,
                      height: 24.h,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: transaction.action == 'Receive'
                            ? Colors.green
                            : Colors.red,
                      ),
                    )
                        : Icon(
                      transaction.action == 'Receive'
                          ? Icons.arrow_downward_rounded
                          : Icons.arrow_upward_rounded,
                      color: transaction.action == 'Receive'
                          ? Colors.green
                          : Colors.red,
                      size: 24.sp,
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                // Transaction Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: AppText.body(
                              transaction.accountName,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14.sp,
                                color: Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${transaction.action == 'Receive' ? '+' : '-'}\₦${transaction.amount}',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 12.sp,
                              color: transaction.action == 'Receive'
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppText.caption(
                                  'TRX ID: ${transaction.trxID}',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12.sp,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                AppText.caption(
                                  transaction.dateCreated,
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: transaction.action == 'Receive'
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              transaction.action,
                              style: TextStyle(
                                color: transaction.action == 'Receive'
                                    ? Colors.green
                                    : Colors.red,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

