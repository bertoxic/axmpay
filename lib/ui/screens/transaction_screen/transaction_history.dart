import 'package:AXMPAY/ui/widgets/custom_responsive_sizes/responsive_size.dart';
import 'package:AXMPAY/ui/widgets/custom_text/custom_apptext.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../models/transaction_model.dart';
import '../../../providers/user_service_provider.dart';

class TransactionHistoryPage extends StatelessWidget {
  const TransactionHistoryPage({super.key});

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
            // The error has already been handled by the API service,
            // so we just need to display an error state to the user
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 60),
                    const SizedBox(height: 16),
                    const Text(
                      "An error occurred while fetching transactions.",
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        // Refresh the page
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const TransactionHistoryPage()),
                        );
                      },
                      child: const Text("Retry"),
                    ),
                  ],
                ),
              ),
            );
          } else if (snapshot.hasData && snapshot.data != null && snapshot.data!.isNotEmpty) {
            // Display the transaction history
            return Scaffold(
              appBar: AppBar( centerTitle: false, title: const Text("Transaction details"), ),
              body: Column(
                children: [
                  const SizedBox(height: 30,),
                  Expanded(
                    child: ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {

                        return InkWell(
                           onTap: ()async{
                            SpecificTransactionData transactionData= await userProvider.fetchTransactionDetails(context, snapshot.data![index].trxID.toString());
                            if(!context.mounted) return;
                             context.pushNamed(
                               'transaction_details',
                               pathParameters: {'trxID': snapshot.data![index].trxID.toString()},
                               extra: transactionData,
                             );
                           },
                          child: SizedBox(
                            child: Container(
                              //elevation: 2,
                              decoration:  BoxDecoration(color: Colors.white,
                               borderRadius: BorderRadius.circular(12),
                               boxShadow: [
                                 BoxShadow(
                                     blurRadius: 3,
                                     color: Colors.grey.shade300,
                                     spreadRadius: 2.7,
                                   offset: const Offset(1,3)
                                 )
                               ]
                              ),
                              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          AppText.body(
                                            snapshot.data![index].accountName,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                           SizedBox(height: 2.h),
                                          AppText.caption('Transaction ID: ${snapshot.data![index].trxID}',
                                            style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
                                          ),
                                          Row(
                                            children: [
                                              AppText.caption('Date: ',
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                              ),
                                              AppText.caption(snapshot.data![index].dateCreated,
                                                style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
                                              ),
                                            ],
                                          ),
                                          AppText.caption(
                                              snapshot.data![index].type,
                                            style: TextStyle(color: snapshot.data![index].type=="Credit"?Colors.green.shade400:Colors.red.shade400) ,),
                                        ],
                                      ),
                                    ),
                                     SizedBox(width: 16.w),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '${snapshot.data![index].action == 'Receive' ? '+' : '-'}\₦${snapshot.data![index].amount}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12.sp,
                                            color: snapshot.data![index].action == 'Receive' ? Colors.green : Colors.red,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: _getStatusColor(snapshot.data![index].status),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            snapshot.data![index].status,
                                            style: const TextStyle(color: Colors.white, fontSize: 12),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          } else {
            // No data or empty list
            return const Center(child: Text("No transactions found."));
          }
        },
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