// import 'package:AXMPAY/ui/widgets/custom_responsive_sizes/responsive_size.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
//
// import '../../../models/transaction_model.dart';
//
// class TransactionDetailScreen extends StatelessWidget {
//   final SpecificTransactionData transaction;
//
//   const TransactionDetailScreen({super.key, required this.transaction});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Transaction Details'),
//         elevation: 0,
//       ),
//       body: SafeArea(
//         child: LayoutBuilder(
//           builder: (context, constraints) {
//             return SingleChildScrollView(
//               child: Padding(
//                 padding: EdgeInsets.symmetric(
//                   horizontal: constraints.maxWidth * 0.04,
//                   vertical: 12.h,
//                 ),
//                 child: Container(
//                   constraints: BoxConstraints(
//                     maxWidth: 600, // Maximum width for better readability
//                   ),
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.stretch,
//                     children: [
//                       _buildHeader(constraints),
//                       _buildDetailsList(constraints),
//                       SizedBox(height: 12.h),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
//
//   Widget _buildHeader(BoxConstraints constraints) {
//     double? transactionAmount = double.tryParse(transaction.amount?.toString() ?? '0');
//     final formatter = NumberFormat.currency(locale: 'en_US', symbol: '₦');
//
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.all(constraints.maxWidth * 0.04),
//       decoration: BoxDecoration(
//         color: transaction.type.toLowerCase() == 'credit'
//             ? Colors.green[50]
//             : Colors.red[50],
//         borderRadius: const BorderRadius.only(
//           bottomRight: Radius.circular(12),
//           bottomLeft: Radius.circular(12),
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           FittedBox(
//             fit: BoxFit.scaleDown,
//             child: Text(
//               '${transaction.type.toLowerCase() == 'credit' ? '+' : '-'} ${formatter.format(transactionAmount)}',
//               style: TextStyle(
//                 fontSize: constraints.maxWidth * 0.08,
//                 fontWeight: FontWeight.bold,
//                 color: transaction.type.toLowerCase() == 'credit'
//                     ? Colors.green
//                     : Colors.red,
//               ),
//             ),
//           ),
//           SizedBox(height: 8.h),
//           Text(
//             transaction.action,
//             style: TextStyle(
//               fontSize: constraints.maxWidth * 0.045,
//               fontWeight: FontWeight.w500,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           SizedBox(height: 8.h),
//           Text(
//             DateFormat('MMMM d, yyyy HH:mm').format(transaction.timeCreated),
//             style: TextStyle(
//               color: Colors.grey,
//               fontSize: constraints.maxWidth * 0.035,
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDetailsList(BoxConstraints constraints) {
//     double? balAfter = double.tryParse(transaction.balAfter?.toString() ?? '0');
//     double? transactionFee = double.tryParse(transaction.fee?.toString() ?? '0');
//     double? totalAmt = double.tryParse(transaction.totalAmount?.toString() ?? '0');
//     final formatter = NumberFormat.currency(locale: 'en_US', symbol: '₦');
//
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.grey[50],
//         borderRadius: const BorderRadius.only(
//           topLeft: Radius.circular(8),
//           topRight: Radius.circular(8),
//         ),
//       ),
//       child: Padding(
//         padding: EdgeInsets.all(constraints.maxWidth * 0.04),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildDetailItem('Transaction ID:', transaction.trxID, constraints),
//             _buildDetailItem(
//               (transaction.action == "Data" || transaction.action == "Airtime")
//                   ? "Description:"
//                   : "Account:",
//               transaction.accountName,
//               constraints,
//             ),
//             _buildDetailItem('Status:', transaction.status, constraints, isStatus: true),
//             _buildDetailItem('Type:', transaction.type, constraints),
//             _buildDetailItem('Fee:', formatter.format(transactionFee), constraints),
//             _buildDetailItem('Total Amount:', formatter.format(totalAmt), constraints),
//             _buildDetailItem('Balance After:', formatter.format(balAfter), constraints),
//             _buildDetailItem('Narration:', transaction.narration, constraints),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildDetailItem(String label, String value, BoxConstraints constraints,
//       {bool isStatus = false}) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 8.h),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             label,
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//               color: Colors.grey,
//               fontSize: constraints.maxWidth * 0.035,
//             ),
//           ),
//           SizedBox(height: 4.h),
//           isStatus
//               ? buildStatusChip(value, constraints)
//               : Text(
//             value,
//             style: TextStyle(
//               fontSize: constraints.maxWidth * 0.04,
//             ),
//             softWrap: true,
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget buildStatusChip(String status, BoxConstraints constraints) {
//     Color color;
//     switch (status.toLowerCase()) {
//       case 'success':
//         color = Colors.green;
//         break;
//       case 'pending':
//         color = Colors.orange;
//         break;
//       case 'failed':
//         color = Colors.red;
//         break;
//       default:
//         color = Colors.grey;
//     }
//
//     return Container(
//       padding: EdgeInsets.symmetric(
//         horizontal: constraints.maxWidth * 0.03,
//         vertical: constraints.maxWidth * 0.01,
//       ),
//       decoration: BoxDecoration(
//         color: color,
//         borderRadius: BorderRadius.circular(4),
//       ),
//       child: Text(
//         status,
//         style: TextStyle(
//           color: Colors.white,
//           fontSize: constraints.maxWidth * 0.035,
//         ),
//       ),
//     );
//   }
// }