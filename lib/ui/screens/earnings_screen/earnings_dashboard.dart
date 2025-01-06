import 'package:AXMPAY/constants/app_colors.dart';
import 'package:AXMPAY/main.dart';
import 'package:AXMPAY/models/ResponseModel.dart';
import 'package:AXMPAY/ui/widgets/custom_buttons.dart';
import 'package:AXMPAY/ui/widgets/custom_container.dart';
import 'package:AXMPAY/ui/widgets/custom_dialog.dart';
import 'package:AXMPAY/ui/widgets/custom_responsive_sizes/responsive_size.dart';
import 'package:AXMPAY/ui/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../models/user_model.dart';
import '../../../providers/user_service_provider.dart';
import '../../widgets/custom_container/wavey_container.dart';
import '../../widgets/custom_text/custom_apptext.dart';

class EarningBalanceDashboard extends StatefulWidget {
  const EarningBalanceDashboard({Key? key}) : super(key: key);

  @override
  State<EarningBalanceDashboard> createState() => _EarningBalanceDashboardState();
}

class _EarningBalanceDashboardState extends State<EarningBalanceDashboard>
    with SingleTickerProviderStateMixin {
  late UserServiceProvider _userServiceProvider;
  late UserData? userData;
  late TabController _tabController;
  late TextEditingController _amtController;
  final formatter = NumberFormat.currency(locale: 'en_US', symbol: '₦');

  Map<String, dynamic>? referralData;
  List<ReferralData> activeReferrals = [];
  List<ReferralData> pendingReferrals = [];
  bool isLoading = true;
  List<ReferralData> inactiveReferrals = [];
  @override
  void initState() {
    super.initState();
    _userServiceProvider =
        Provider.of<UserServiceProvider>(context, listen: false);
    _tabController = TabController(length: 2, vsync: this);
    _amtController = TextEditingController();
    _tabController.addListener(
        _handleTabChange); // Add listener for tab changes
    _fetchReferralData();
  }
  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      setState(() {
        // Update the lists based on tab index
        if (_tabController.index == 1) {
          // When switching to inactive/unverified tab
          inactiveReferrals = pendingReferrals;
          pendingReferrals = [];
        } else {
          // When switching back to active tab
          pendingReferrals = inactiveReferrals;
          inactiveReferrals = [];
        }
      });
    }
  }
  Future<void> _fetchReferralData() async {
    try {
      setState(() => isLoading = true);
      final ResponseResult? response = await _userServiceProvider.fetchReferralDetails(context);

      if (response?.status == ResponseStatus.success && response?.data != null) {
        final data = response!.data as Map<String, dynamic>;
        final referrals = (data['referrals'] as List<dynamic>);

        setState(() {
          referralData = data;
          activeReferrals = referrals
              .where((ref) => ref['refStatus'].toString().toLowerCase() == 'active')
              .map((ref) => ReferralData(
            ref['username'] ?? '',
            ref['refStatus'] ?? '',
            double.tryParse(ref['revenue'].toString()) ?? 0.0,
            _getAvatarColor(ref['username'] ?? ''),
          ))
              .toList();

          pendingReferrals = referrals
              .where((ref) => ref['refStatus'].toString().toLowerCase() == 'pending')
              .map((ref) => ReferralData(
            ref['username'] ?? '',
            ref['refStatus'] ?? '',
            double.tryParse(ref['revenue'].toString()) ?? 0.0,
            _getAvatarColor(ref['username'] ?? ''),
          ))
              .toList();
        });
      } else {
        print('Failed to fetch referral data: ${response?.message}');
      }
    } catch (e) {
      print('Error fetching referral data: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Color _getAvatarColor(String username) {
    if (username.isEmpty) return Colors.grey;
    final colors = [
      Colors.purple[100]!,
      Colors.deepOrange,
      Colors.green,
      Colors.brown,
      Colors.amber,
      Colors.blue,
      Colors.teal,
    ];
    return colors[username.hashCode % colors.length];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    userData = _userServiceProvider.userdata;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double earningAmt = double.parse(userData?.earn ?? "0.00");
    final double accountAmt = double.parse(userData?.availableBalance ?? "0.00");
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: size.height),
            child: Stack(
              children: [
                _buildTopContainer(),
                _buildBalanceCard(earningAmt, accountAmt,_amtController),
                _buildTabSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopContainer() {
    return Container(
      height: 180.h,
      color: Colors.grey.shade600,
      padding: EdgeInsets.all(12.0.sp),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                child: Icon(Icons.person, size: 34.sp),
                backgroundColor: Colors.grey.shade300,
                radius: 24.sp,
              ),
              SizedBox(width: 10.sp),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.title("Welcome back",
                        color: Colors.grey.shade200),
                    AppText.body("${userData?.fullName}",
                        color: Colors.grey.shade200),
                  ],
                ),
              ),

            ],
          ),
        ],
        
      ),
    );
  }

  Widget _buildBalanceCard(double earningAmt, double accountAmt, TextEditingController amtctrl) {
    return Positioned(
      top: 80.h,
      left: 0,
      right: 0,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        child: AnimatedWavyBackgroundContainer(
          height: 160.h,
          backgroundColor: const Color(0xff5d3cf8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: const Color(0xff462eb4),
          ),
          child: _buildBalanceCardContent(earningAmt, accountAmt,amtctrl),
        ),
      ),
    );
  }

  Widget _buildBalanceCardContent(double earningAmt, double accountAmt, TextEditingController amtCtrl) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Earning Balance',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 8.h),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    formatter.format(earningAmt),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 4.h),
                AppText.caption(
                  '(estimated total of available Earnings)',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 10.sp,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                AppText.body(
                  "total payout",
                  color: Colors.grey.shade200,
                ),
                AppText.body(
                  formatter.format(accountAmt),
                  color: Colors.grey.shade200,
                ),
                const Spacer(),
                CustomButton( onPressed:() => _showCustomDialog(context,amtCtrl),
                  text: "Withdraw",foregroundColor:AppColors.primary,backgroundColor: AppColors.lightgrey,),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSection() {
    return Positioned(
      top: 240.h,
      left: 0,
      right: 0,
      child: SpacedContainer(
        margin: EdgeInsets.symmetric(vertical: 4.h, horizontal: 1.w),
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 1.w),
        containerColor: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Theme(
                data: Theme.of(context).copyWith(
                  tabBarTheme: TabBarTheme(
                    labelStyle: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                    unselectedLabelStyle: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                child: TabBar(
                  controller: _tabController,
                  labelColor: colorScheme.primary,
                  unselectedLabelColor: Colors.grey[400],
                  indicatorColor: colorScheme.primary,
                  indicatorWeight: 3,
                  indicatorSize: TabBarIndicatorSize.label,
                  tabs: [
                    Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_outline, size: 20.sp),
                          SizedBox(width: 8.w),
                          const Text('Verified'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.pending_outlined, size: 20.sp),
                          SizedBox(width: 8.w),
                          const Text('Inactive'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (isLoading)
                Container(
                  height: 200.h,
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                      strokeWidth: 3,
                    ),
                  ),
                )
              else
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 500.h,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildReferralList(activeReferrals, true),
                      _buildReferralList(_tabController.index == 1 ? inactiveReferrals : pendingReferrals, false),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReferralList(List<ReferralData> referrals, bool isActive) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.primary,
                colorScheme.primary.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatCard(
                'Total Referrals',
                '${referralData?['totalReferrals'] ?? 0}',
                Icons.people_outline,
              ),
              Container(
                height: 40.h,
                width: 1,
                color: Colors.white.withOpacity(0.3),
              ),
              _buildStatCard(
                isActive ? 'Active' : 'Inactive',
                isActive
                    ? '${referralData?['activeReferrals'] ?? 0}'
                    : '${referralData?['pendingReferrals'] ?? 0}',
                isActive ? Icons.verified_user_outlined : Icons.hourglass_empty,
              ),
            ],
          ),
        ),
        Expanded(
          child: referrals.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isActive ? Icons.people_outline : Icons.pending_actions,
                  size: 48.sp,
                  color: Colors.grey[300],
                ),
                SizedBox(height: 16.h),
                Text(
                  'No ${isActive ? 'active' : 'inactive'} referrals yet',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )
              : ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: referrals.length,
            itemBuilder: (context, index) {
              final referral = referrals[index];
              return AnimatedScale(
                scale: 1.0,
                duration: Duration(milliseconds: 200 + (index * 50)),
                child: _buildReferralCard(referral),
              );
            },
          ),
        ),
        SizedBox(height: 100.h),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.sp),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 20.sp,
          ),
        ),
        SizedBox(width: 12.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.white.withOpacity(0.8),
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 20.sp,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReferralCard(ReferralData referral) {
    final String displayChar = referral.username.isNotEmpty
        ? referral.username[0].toUpperCase()
        : '?';

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // Handle tap
            },
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 20.w,
                vertical: 16.h,
              ),
              child: Row(
                children: [
                  Hero(
                    tag: 'avatar_${referral.username}',
                    child: Container(
                      width: 50.w,
                      height: 50.w,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            referral.avatarColor,
                            referral.avatarColor.withOpacity(0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: referral.avatarColor.withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 0,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          displayChar,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w600,
                          ),
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
                          referral.username.isEmpty ? 'Unknown User' : referral.username,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(referral.status).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                _tabController.index == 1 ? 'Inactive' : referral.status,
                                style: TextStyle(
                                  color: _getStatusColor(referral.status),
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Revenue',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        formatter.format(referral.revenue),
                        style: TextStyle(
                          color: Colors.green[600],
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green[600]!;
      case 'pending':
        return Colors.orange[600]!;
      case 'inactive':
        return Colors.grey[600]!;
      default:
        return Colors.blue[600]!;
    }
  }
  void  _showCustomDialog(BuildContext context, TextEditingController _amountController) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Track loading state
        bool isLoading = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title Section
                    Center(
                      child: Text(
                        "Withdraw Earnings",
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // Input Field Section
                    Text(
                      "Amount to Withdraw",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    CustomTextField(
                      fieldName: "amount",
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: "Enter amount",
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                        fillColor: Colors.grey.shade100,
                        filled: true,
                        prefixIcon: Icon(Icons.fiber_smart_record_sharp, color: colorScheme.primary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // Button Section
                    Center(
                      child: CustomButton(
                        size: ButtonSize.large,
                        isLoading: isLoading, // Show loading indicator
                        onPressed: isLoading
                            ? null // Disable button while loading
                            : () async {
                          setState(() {
                            isLoading = true; // Start loading
                          });
                          try {
                            ResponseResult? resp = await _userServiceProvider.cashOutEarnings(
                              context,
                              _amountController.text,
                            );
                            if (resp?.status == ResponseStatus.failed) {
                              CustomPopup.show(
                                context: context,
                                type: PopupType.error,
                                title: "Failed",
                                message: resp?.message ?? "Failed request",
                              );
                            } else if (resp?.status == ResponseStatus.success) {
                              CustomPopup.show(
                                context: context,
                                type: PopupType.success,
                                title: "Success",
                                message: resp?.message ?? "Withdrawal was successful",
                              );
                              _amountController.clear();
                            }
                          } catch (e) {
                            CustomPopup.show(
                              context: context,
                              type: PopupType.error,
                              title: "Error",
                              message: "An error occurred during the process, try again later",
                            );
                          } finally {
                            setState(() {
                              isLoading = false; // End loading
                            });
                          }
                        },
                        text: 'Withdraw',
                      ),
                    ),

                    // Footer Section
                    SizedBox(height: 16.h),
                    Center(
                      child: Text(
                        "Ensure you enter the correct amount.",
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }


}


class ReferralData {
  final String username;
  final String status;
  final double revenue;
  final Color avatarColor;

  ReferralData(this.username, this.status, this.revenue, this.avatarColor);
}