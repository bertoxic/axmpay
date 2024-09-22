
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
import '../../widgets/custom_container/wavey_container.dart';
import '../transaction_screen/success_receipt_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
  @override
  void initState() {
    super.initState();
    phoneController = TextEditingController();
    amountController = TextEditingController();
    serviceProviderController = TextEditingController();
    userProvider =  Provider.of<UserServiceProvider>(context, listen: false);
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
  Widget build(BuildContext context) {
    balance = double.tryParse(userProvider.userdata?.availableBalance?.toString() ?? '0');
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
                _buildQuickActionsCard(),
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
      margin: EdgeInsets.symmetric(vertical:16.h,horizontal: 12.w),
     // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      //elevation: 4,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:  BorderRadius.circular( 16.sp),
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                colorScheme.primary,
                colorScheme.primary,
                //const Color(0xB25C4DE5),
                //const Color(0xB20C93AB),
                // Color(0xB643C036),
                // const Color(0xFF5EE862),
              ]),
          boxShadow: [
            BoxShadow(
                blurRadius: 2,
                color: Colors.black.withOpacity(0.4),
                spreadRadius: 1.7,
                offset: const Offset(1,3)
            )
          ]
      ),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16.sp,
                  backgroundColor: colorScheme.onPrimary,
                  child: Text(
                    "${userProvider.userdata?.username?.substring(0, 1).toUpperCase()}",
                    style: TextStyle(color: colorScheme.primary, fontSize: 20.sp),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${userProvider.userdata?.firstname} ${userProvider.userdata?.lastname}",
                        style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: colorScheme.onPrimary),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        "A/C: ${userProvider.userdata?.accountNumber}",
                        style: TextStyle(fontSize: 9.sp, color: Colors.grey[300]),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: SizedBox( width: 30.w, height: 30.w,
                      child: SvgIcon("assets/images/axmpay_logo.svg", color: Colors.grey.shade200, width: 36.w, height: 40.h)),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Text(
              "Available Balance",
              style: TextStyle(fontSize:12.sp, color: Colors.grey[300]),
            ),
            SizedBox(height: 8.h),
            Text(
              formatter.format(balance),
              style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold, color: colorScheme.onPrimary,),
            ),
            SizedBox(height: 4.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                AppText.body(
                  "Earnings: ₦${userProvider.userdata?.earn ?? "0"}",
                  style: TextStyle(fontSize: 16.sp, color: Colors.grey[300]),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: userProvider.userdata!.accountNumber??""));
                    ScaffoldMessenger.of(context).showSnackBar(
                       SnackBar(content: Text('Account number copied to clipboard'),backgroundColor: colorScheme.primary),
                    );
                  },
                  icon: Icon(Icons.copy, size:10.sp),
                  label: Text("Copy A/C", style: TextStyle(fontSize: 10.sp,color: colorScheme.primary)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.onPrimary,
                    foregroundColor: colorScheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsCard() {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Quick Actions",
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildQuickActionButton(Icons.add, "Add Funds", () => _showCustomDialog(context)),
                _buildQuickActionButton(Icons.send, "Transfer", () => context.pushNamed("/transferPage")),
                _buildQuickActionButton(Icons.phone_android, "Recharge", () => context.pushNamed("top_up")),
                _buildQuickActionButton(Icons.history, "History", () => context.pushNamed("/transaction_history_page")),
                 _buildQuickActionButton(Icons.history, "History", (){  Navigator.of(context).push(
                     MaterialPageRoute(builder: (_) =>  EarningBalanceDashboard()));},)
                    ],
            ),
          ],
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
            child: Icon(icon, color: colorScheme.primary, size: 18.sp),
          ),
          SizedBox(height: 8.h),
          Text(label, style: TextStyle(fontSize: 10.sp)),
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
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Recent Transactions",
                  style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
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
                future: _fetchTransactionHistory(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return _buildErrorWidget();
                  } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    return _buildTransactionList(snapshot.data!);
                  } else {
                    return const Center(child: Text("No transactions found."));
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
    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        return TransactionItemWidget(transaction: transactions[index]);
      },
    );
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
                              primary: colorScheme.onPrimary,
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

class TransactionItemWidget extends StatefulWidget {
  final TransactionHistoryModel transaction;

  const TransactionItemWidget({Key? key, required this.transaction}) : super(key: key);

  @override
  _TransactionItemWidgetState createState() => _TransactionItemWidgetState();
}

class _TransactionItemWidgetState extends State<TransactionItemWidget> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _isLoading ? null : () async {
        if (_isLoading) return;
        setState(() {
          _isLoading = true;
        });
        try {
          final userProvider = Provider.of<UserServiceProvider>(context, listen: false);
          SpecificTransactionData transactionData = await userProvider.fetchTransactionDetails(
            context,
            widget.transaction.trxID.toString(),
          );
          if (!mounted) return;
          await context.pushNamed(
            'transaction_details',
            pathParameters: {'trxID': widget.transaction.trxID.toString()},
            extra: transactionData,
          );
        } catch (e) {
          if (mounted) {
           CustomPopup.show(
               type: PopupType.error,
               context: context,
               title: "Error occurred", message: "unable to get transaction details");
          }
        } finally {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        }
      },
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 4.h),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: widget.transaction.action == 'Receive' ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child:_isLoading?SizedBox( width: 12.w,height: 12.w,
                    child: CircularProgressIndicator( strokeWidth: 2.sp,color: widget.transaction.action == 'Receive' ? Colors.green : Colors.red,)): Icon(
                  widget.transaction.action == 'Receive' ? Icons.arrow_downward : Icons.arrow_upward,
                  color: widget.transaction.action == 'Receive' ? Colors.green : Colors.red,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.transaction.accountName,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize:10.sp),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      widget.transaction.dateCreated,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12.sp),
                    ),
                  ],
                ),
              ),
              AppText.caption(
                '${widget.transaction.action == 'Receive' ? '+' : '-'}\₦${widget.transaction.amount}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 10.sp,
                  color: widget.transaction.action == 'Receive' ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );}}



