
import 'dart:ui';

import 'package:AXMPAY/main.dart';
import 'package:AXMPAY/models/transaction_model.dart';
import 'package:AXMPAY/models/user_model.dart';
import 'package:AXMPAY/providers/user_service_provider.dart';
import 'package:AXMPAY/ui/screens/earnings_screen/earnings_dashboard.dart';
import 'package:AXMPAY/ui/screens/informational_screens/frequently_asked_questions.dart';
import 'package:AXMPAY/ui/screens/passcode_screen/passcode_set_up.dart';
import 'package:AXMPAY/ui/screens/registration/update_user_details_page.dart';
import 'package:AXMPAY/ui/screens/upgrade_account/upgrade_account_form.dart';
import 'package:AXMPAY/ui/widgets/custom_dialog.dart';
import 'package:AXMPAY/ui/widgets/custom_responsive_sizes/responsive_size.dart';
import 'package:AXMPAY/ui/widgets/custom_text/custom_apptext.dart';
import 'package:AXMPAY/ui/widgets/svg_maker/svg_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../widgets/custom_container/wavey_container.dart';
import '../transaction_screen/success_receipt_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late AnimationController _loadingController;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey();
  String? phoneNumberValue = "";
  TopUpPayload? topUpPayload;
  DataBundle? dataBundle;
  late TextEditingController phoneController;
  late TextEditingController amountController;
  late TextEditingController serviceProviderController;
  late UserServiceProvider userProvider;
  Future<DataBundleList?>? _dataBundleList;
  bool phoneIsValid = false;
  bool _isLoadingHistory = false;

  bool isData = false;

  String? serviceProviderNetwork;
  late Future<List<TransactionHistoryModel>> _transactionHistoryFuture;
  late Future <UserData?> _userDetailsFuture;
  final formatter = NumberFormat.currency(locale: 'en_US', symbol: '\₦');
   double? balance;
   double? earnings;
  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    phoneController = TextEditingController();
    amountController = TextEditingController();
    serviceProviderController = TextEditingController();
    userProvider = Provider.of<UserServiceProvider>(context, listen: false);
    _transactionHistoryFuture = _fetchTransactionHistory();
    _userDetailsFuture = _fetchUserDetails();
  }
  Future<List<TransactionHistoryModel>> _fetchTransactionHistory() {
    return Provider.of<UserServiceProvider>(context, listen: false).fetchTransactionHistory(context);
  }
 Future<UserData?> _fetchUserDetails() {
    return Provider.of<UserServiceProvider>(context, listen: false).getUserDetails(context);
  }

  Future<void> _retryFetchingTransactions() async {
    setState(() {
      _transactionHistoryFuture = _fetchTransactionHistory();
      _userDetailsFuture = _fetchUserDetails();

    });
    await _transactionHistoryFuture;
  }
  @override
  void dispose() {
    _loadingController.dispose();
    super.dispose();
  }
  Widget _buildShimmerLoading() {
    return ListView.builder(
      itemCount: 8,
      padding: EdgeInsets.only(top: 10),
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 8.h),
          child: Container(
            padding: EdgeInsets.all(8.sp),
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
              baseColor: Colors.grey[200]!,
              highlightColor: Colors.grey[100]!,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Transaction Icon Placeholder
                  Container(
                    width: 34.w,
                    height: 34.h,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],  // Changed color
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  SizedBox(width: 8.w),
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
                              width: 100.w,
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
                                  width: 40.w,
                                  height: 10.h,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],  // Changed color
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ],
                            ),
                            // Status Badge Placeholder
                            // Container(
                            //   width: 70.w,
                            //   height: 24.h,
                            //   decoration: BoxDecoration(
                            //     color: Colors.grey[300],  // Changed color
                            //     borderRadius: BorderRadius.circular(8),
                            //   ),
                           // ),
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
  @override
  Widget build(BuildContext context) {
    balance = double.tryParse(userProvider.userdata?.availableBalance.toString() ?? '0');
    earnings = double.tryParse(userProvider.userdata?.earn.toString() ?? '0');
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.background,
        actions: [
          IconButton(
            icon: Icon(Icons.help, color: Theme.of(context).colorScheme.primary),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => FAQs()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.notifications, color: Theme.of(context).colorScheme.onSurface),
            onPressed: () {
              // Add notification functionality
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _retryFetchingTransactions,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            color: Theme.of(context).colorScheme.background,
            child: Column(
              children: [
                Consumer<UserServiceProvider>(
                    builder: (context, userProvider, child) {
                      return _buildUserInfoCard(userProvider);
                    }
                ),
                buildQuickActionsCard(),
                _buildTransactionHistoryCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfoCard(UserServiceProvider userProvider) {
    balance = double.tryParse(userProvider.userdata?.availableBalance?.toString() ?? '0');

    return Container(
      margin: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.sp),
        color:colorScheme.primary ,
        // gradient: LinearGradient(
        //   begin: Alignment.topLeft,
        //   end: Alignment.bottomRight,
        //   colors: [
        //     colorScheme.primary,
        //     colorScheme.primary.withOpacity(0.8),
        //     Color.lerp(colorScheme.primary, Colors.blue, 0.3) ?? colorScheme.primary,
        //   ],
        //   stops: const [0.0, 0.6, 1.0],
        // ),
        boxShadow: [
          BoxShadow(
            blurRadius: 12,
            color: colorScheme.primary.withOpacity(0.6),
            spreadRadius: 2,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.sp),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Hero(
                    tag: 'user_avatar',
                    child: CircleAvatar(
                      radius: 16.sp,
                      backgroundColor: colorScheme.onPrimary,
                      child: Text(
                        "${userProvider.userdata?.username?.substring(0, 1).toUpperCase()}",
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${userProvider.userdata?.firstname} ${userProvider.userdata?.lastname}",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onPrimary,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          "A/C: ${userProvider.userdata?.accountNumber}",
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: colorScheme.onPrimary.withOpacity(0.8),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(8.w),

                    child: SvgIcon(
                      "assets/images/axmpay_logo.svg",
                      color: colorScheme.onPrimary.withOpacity(0.9),
                      width: 32.w,
                      height: 32.h,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: colorScheme.onPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.sp),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Available Balance",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: colorScheme.onPrimary.withOpacity(0.7),
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      formatter.format(balance),
                      style: TextStyle(
                        fontSize: 32.sp,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height:8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: colorScheme.onPrimary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.sp),
                    ),
                    child: Text(
                      "Earnings: ${formatter.format(earnings)}",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: userProvider.userdata!.accountNumber ?? ""));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Account number copied to clipboard'),
                          backgroundColor: colorScheme.primary,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      );
                    },
                    icon: Icon(Icons.copy_rounded, size: 16.sp),
                    label: Text("Copy A/C", style: TextStyle(fontSize: 12.sp)),
                    style: TextButton.styleFrom(
                      backgroundColor: colorScheme.onPrimary,
                      foregroundColor: colorScheme.primary,
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.sp),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildQuickActionsCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.w),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 2,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.grey.shade50,
              ],
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.flash_on,
                      size: 20.sp,
                      color: Theme.of(context).primaryColor,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      "Quick Actions",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildQuickActionButton(
                      Icons.add,
                      "Add Funds",
                          () => _showCustomDialog(context),
                    ),
                    _buildQuickActionButton(
                      Icons.send_rounded,
                      "Transfer",
                          () => context.pushNamed("/transferPage"),
                    ),
                    _buildQuickActionButton(
                      Icons.phone_android_rounded,
                      "Recharge",
                          () => context.pushNamed("top_up"),
                    ),
                    // _buildQuickActionButton(
                    //   Icons.history_rounded,
                    //   "History",
                    //       () => context.pushNamed("/transaction_history_page"),
                    // ),
                    _buildQuickActionButton(
                      Icons.account_balance_wallet_rounded,
                      "Earnings",
                          () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => EarningBalanceDashboard(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: colorScheme.primary, size: 20.sp),
          ),
          SizedBox(height: 8.h),
          Text(label, style: TextStyle(fontSize: 12.sp)),
        ],
      ),
    );
  }

  Widget _buildTransactionHistoryCard() {
    return Card(
      margin: EdgeInsets.all(12.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Recent Transactions",
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => context.pushNamed("/transaction_history_page"),
                  child: Text("See All", style: TextStyle(color: colorScheme.primary)),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            SizedBox(
              height: 360.h,
              child: FutureBuilder<List<TransactionHistoryModel>>(
                future: _transactionHistoryFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildShimmerLoading();
                  } else if (snapshot.hasError) {
                    return _buildErrorWidget();
                  } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: _buildTransactionList(snapshot.data!),
                    );
                  } else {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.history, size: 48.sp, color: Colors.grey),
                          SizedBox(height: 16.h),
                          Text(
                            "No transactions yet",
                            style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
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
          const Text(
            "An error occurred while fetching transactions.",
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
          _retryFetchingTransactions() ;

            },
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }
  Widget _buildTransactionList(List<TransactionHistoryModel> transactions) {
    return TransactionListWidget(transactions: transactions);
  }

  void _showCustomDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Container(
                  padding: EdgeInsets.all(24.w),
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        SizedBox(height: 16.h),
                        Text(
                          "account name",
                          style: TextStyle(fontSize: 9.sp, color: Colors.grey[600]),
                        ),
                        Text(
                          "${userProvider.userdata?.fullName?.toUpperCase()??"" .toUpperCase()}",
                          style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          "9 Payment service bank",
                          style: TextStyle(fontSize:14.sp, color: Colors.grey[600],fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          "account number",
                          style: TextStyle(fontSize: 9.sp, color: Colors.grey[600]),
                        ),
                        Text(
                          "${userProvider.userdata?.accountNumber}",
                          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 16.h),
                        ElevatedButton(
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: userProvider.userdata!.accountNumber??""));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Account number copied to clipboard')),
                              );
                              Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.onPrimary,
                            ),
                            child: Text('Copy Account Number')
                        ),
                        Text(
                          "Transfer to this account number",
                          style: TextStyle(fontSize: 9.sp, color: Colors.grey[600]),
                        ),


                      ]
                  )));
        });
  }
}


class TransactionListWidget extends StatefulWidget {
  final List<TransactionHistoryModel> transactions;

  const TransactionListWidget({
    Key? key,
    required this.transactions,
  }) : super(key: key);

  @override
  _TransactionListWidgetState createState() => _TransactionListWidgetState();
}

class _TransactionListWidgetState extends State<TransactionListWidget> {
  String? processingTransactionId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 16.h),
      itemCount: widget.transactions.length,
      itemBuilder: (context, index) {
        // Group transactions by date
        final showDateHeader = index == 0 ||
            !isSameDay(widget.transactions[index].dateCreated,
                widget.transactions[index - 1].dateCreated);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showDateHeader) ...[
              Padding(
                padding: EdgeInsets.only(top: index == 0 ? 0 : 24.h, bottom: 12.h),
                child: Text(
                  _formatDateHeader(widget.transactions[index].dateCreated),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                    fontSize: 13.sp,
                  ),
                ),
              ),
            ],
            TransactionItemWidget(
              transaction: widget.transactions[index],
              isProcessing: processingTransactionId == widget.transactions[index].trxID,
              onTap: () => _handleTransactionTap(widget.transactions[index]),
            ),
          ],
        );
      },
    );
  }

  String _formatDateHeader(String dateString) {
    final date = DateTime.parse(dateString);
    final now = DateTime.now();

    if (isSameDay(dateString, now.toString())) {
      return 'Today';
    } else if (isSameDay(dateString, now.subtract(Duration(days: 1)).toString())) {
      return 'Yesterday';
    }
    return DateFormat('MMMM d, yyyy').format(date);
  }

  bool isSameDay(String date1, String date2) {
    final d1 = DateTime.parse(date1);
    final d2 = DateTime.parse(date2);
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  Future<void> _handleTransactionTap(TransactionHistoryModel transaction) async {
    if (processingTransactionId != null) return;

    setState(() {
      processingTransactionId = transaction.trxID;
    });

    try {
      final userProvider = Provider.of<UserServiceProvider>(context, listen: false);
      final transactionData = await userProvider.fetchTransactionDetails(
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
          title: "Error occurred",
          message: "Unable to get transaction details",
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          processingTransactionId = null;
        });
      }
    }
  }
}

class TransactionItemWidget extends StatelessWidget {
  final TransactionHistoryModel transaction;
  final bool isProcessing;
  final VoidCallback onTap;

  const TransactionItemWidget({
    Key? key,
    required this.transaction,
    required this.isProcessing,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isReceive = transaction.action == 'Receive';
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: InkWell(
        onTap: isProcessing ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withOpacity(0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              if (isProcessing)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                    child: LinearProgressIndicator(
                      backgroundColor: isReceive ? Colors.green[600] : Colors.red[600],
                      valueColor: AlwaysStoppedAnimation<Color>(colorScheme.onPrimaryContainer),
                      minHeight: 2,
                    ),
                  ),
                ),
              Padding(
                padding: EdgeInsets.all(12.w),
                child: Row(
                  children: [
                    _buildTransactionIcon(isReceive),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  transaction.accountName,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15.sp,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                '${isReceive ? '+' : '-'}\₦${_formatAmount(transaction.amount)}',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15.sp,
                                  color: isReceive ? Colors.green[600] : Colors.red[600],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 6.h),
                          Row(
                            children: [
                              Container(

                                child: Text(
                                  isReceive ? 'Received' : 'Sent',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: isReceive ? Colors.green[600] : Colors.red[600],
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                _formatTime(transaction.dateCreated),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                  fontSize: 11.sp,
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionIcon(bool isReceive) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: (isReceive ? Colors.green[600] : Colors.red[600])?.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        isReceive ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
        color: isReceive ? Colors.green[600] : Colors.red[600],
        size: 20.sp,
      ),
    );
  }

  String _formatAmount(String amount) {
    final value = double.tryParse(amount) ?? 0;
    return NumberFormat("#,##0.00").format(value);
  }

  String _formatTime(String dateString) {
    final date = DateTime.parse(dateString);
    return DateFormat('hh:mm a').format(date).toLowerCase();
  }
}


