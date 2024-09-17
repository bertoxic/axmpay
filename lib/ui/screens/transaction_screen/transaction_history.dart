import 'package:AXMPAY/ui/widgets/custom_dialog.dart';
import 'package:AXMPAY/ui/widgets/custom_responsive_sizes/responsive_size.dart';
import 'package:AXMPAY/ui/widgets/custom_text/custom_apptext.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../models/transaction_model.dart';
import '../../../providers/user_service_provider.dart';

class TransactionHistoryPage extends StatefulWidget {
  const TransactionHistoryPage({super.key});

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  late Future<List<TransactionHistoryModel>> _transactionHistoryFuture;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _transactionHistoryFuture = _fetchTransactionHistory();
  }
  Future<List<TransactionHistoryModel>> _fetchTransactionHistory() {
    return Provider.of<UserServiceProvider>(context, listen: false).fetchTransactionHistory(context);
  }
  void _retryFetchingTransactions() {
    setState(() {
      _transactionHistoryFuture = _fetchTransactionHistory();
    });
  }
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserServiceProvider>(context, listen: false);

    return Material(
      child: FutureBuilder(
        future: userProvider.fetchTransactionHistory(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print("Error fetching transaction history: ${snapshot.error}");
            return _buildErrorWidget();
          } else if (snapshot.hasData && snapshot.data != null && snapshot.data!.isNotEmpty) {
            return Scaffold(
              appBar: AppBar(centerTitle: false, title: const Text("Transactions History")),
              body: Column(
                children: [
                  const SizedBox(height: 30),
                  Expanded(
                    child: ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        return _TransactionItem(transaction: snapshot.data![index], userProvider: userProvider);
                      },
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: Text("No transactions found."));
          }
        },
      ),
    );

  }
  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 60),
          SizedBox(height: 16),
          Text(
            "An error occurred while fetching transactions.",
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              _retryFetchingTransactions() ;

            },
            child: Text("Retry"),
          ),
        ],
      ),
    );
  }
}

class _TransactionItem extends StatefulWidget {
  final TransactionHistoryModel transaction;
  final UserServiceProvider userProvider;

  const _TransactionItem({Key? key, required this.transaction, required this.userProvider}) : super(key: key);

  @override
  _TransactionItemState createState() => _TransactionItemState();
}

class _TransactionItemState extends State<_TransactionItem> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _isLoading ? null : () async {
        print("Tapped on transaction ${widget.transaction.trxID}");
        if (_isLoading) return;
        setState(() {
          _isLoading = true;
        });
        try {
          print("Fetching transaction details for ${widget.transaction.trxID}");
          SpecificTransactionData transactionData = await widget.userProvider.fetchTransactionDetails(
            context,
            widget.transaction.trxID.toString(),
          );
          print("Fetched transaction details successfully");
          if (!mounted) return;
          print("Navigating to transaction details page");
          await context.pushNamed(
            'transaction_details',
            pathParameters: {'trxID': widget.transaction.trxID.toString()},
            extra: transactionData,
          );
          print("Navigation completed");
        } catch (e) {
          if (mounted) {
            CustomPopup.show(context: context, title: "error occured", message: "error fetching transaction details");

          }
        } finally {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              blurRadius: 3,
              color: Colors.grey.shade300,
              spreadRadius: 2.7,
              offset: const Offset(1, 3),
            )
          ],
        ),
        margin:  EdgeInsets.symmetric(vertical: 4.h, horizontal: 16.w),
        child: Padding(
          padding:  EdgeInsets.all(12.sp),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 50.h,
                padding: EdgeInsets.symmetric(horizontal: 8.w,vertical: 18.h),
                decoration: BoxDecoration(
                  color: widget.transaction.action == 'Receive' ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child:_isLoading?ConstrainedBox( //width: 12.w,height: 5.w,
                    constraints: BoxConstraints(maxWidth: 12.w,maxHeight: 12.w),
                    child: CircularProgressIndicator( strokeWidth: 2.sp,color: widget.transaction.action == 'Receive' ? Colors.green : Colors.red,)): Icon(
                  widget.transaction.action == 'Receive' ? Icons.arrow_downward : Icons.arrow_upward,
                  color: widget.transaction.action == 'Receive' ? Colors.green : Colors.red,
                ),
              ),
              SizedBox(width: 16.w),              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.body(
                      widget.transaction.accountName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2.h),
                    AppText.caption('Transaction ID: ${widget.transaction.trxID}',
                      style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
                    ),
                    Row(
                      children: [
                        AppText.caption('Date: ',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        AppText.caption(widget.transaction.dateCreated,
                          style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
                        ),
                      ],
                    ),
                    // AppText.caption(
                    //   widget.transaction.type,
                    //   style: TextStyle(color: widget.transaction.type == "Credit" ? Colors.green.shade400 : Colors.red.shade400),
                    // ),
                  ],
                ),
              ),
              SizedBox(width: 16.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${widget.transaction.action == 'Receive' ? '+' : '-'}\₦${widget.transaction.amount}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12.sp,
                      color: widget.transaction.action == 'Receive' ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 4),
                 // _isLoading?SizedBox( width: 12.w, height: 12.w,
                 //     child: CircularProgressIndicator(color: Colors.grey.shade400,)): Container(
                 //    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                 //    decoration: BoxDecoration(
                 //      color: _getStatusColor(widget.transaction.status),
                 //      borderRadius: BorderRadius.circular(12),
                 //    ),
                 //    child: Text(
                 //      widget.transaction.status,
                 //      style: const TextStyle(color: Colors.white, fontSize: 12),
                 //    ),
                 //  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }


  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'success':
        return Colors.green.shade200;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}