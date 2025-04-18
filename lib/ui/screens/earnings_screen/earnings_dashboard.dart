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
    _userServiceProvider = Provider.of<UserServiceProvider>(context, listen: false);
    _tabController = TabController(length: 2, vsync: this);
    _amtController = TextEditingController();
    _tabController.addListener(_handleTabChange);
    _fetchReferralData();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      setState(() {
        if (_tabController.index == 1) {
          inactiveReferrals = pendingReferrals;
          pendingReferrals = [];
        } else {
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
      Color(0xFF9575CD), // Purple 300
      Color(0xFFBA68C8), // Purple 300
      Color(0xFF4DD0E1), // Cyan 300
      Color(0xFF4DB6AC), // Teal 300
      Color(0xFF81C784), // Green 300
      Color(0xFFFFB74D), // Orange 300
      Color(0xFFFF8A65), // Deep Orange 300
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
    _amtController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double earningAmt = double.parse(userData?.earn ?? "0.00");
    final double accountAmt = double.parse(userData?.availableBalance ?? "0.00");
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color(0xff462eb4),
        title: Text('Earnings & Referrals',
            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: _fetchReferralData,
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: size.height),
            child: Stack(
              children: [
                _buildTopContainer(),
                _buildBalanceCard(earningAmt, accountAmt, _amtController),
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
      height: 120.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xff462eb4), Color(0xff6c4ef9)],
        ),
      ),
      padding: EdgeInsets.all(16.0.sp).copyWith(top: 0),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(3.sp),
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.5), width: 2)
            ),
            child: CircleAvatar(
              child: Icon(Icons.person, size: 34.sp, color: Color(0xff462eb4)),
              backgroundColor: Colors.white,
              radius: 24.sp,
            ),
          ),
          SizedBox(width: 16.sp),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Welcome back",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  "${userData?.fullName ?? 'User'}",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(8.sp),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12.sp),
            ),
            child: Icon(
              Icons.notifications_none_outlined,
              color: Colors.white,
              size: 24.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(double earningAmt, double accountAmt, TextEditingController amtctrl) {
    return Positioned(
      top: 100.h,
      left: 0,
      right: 0,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Card(
          elevation: 8,
          shadowColor: Color(0xff462eb4).withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: AnimatedWavyBackgroundContainer(
            height: 180.h,
            backgroundColor: const Color(0xff5d3cf8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xff5d3cf8), Color(0xff462eb4)],
              ),
            ),
            child: _buildBalanceCardContent(earningAmt, accountAmt, amtctrl),
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCardContent(double earningAmt, double accountAmt, TextEditingController amtCtrl) {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Earning Balance',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      formatter.format(earningAmt),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28.sp,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      color: Colors.white,
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      formatter.format(accountAmt),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            '(estimated total of available Earnings)',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12.sp,
            ),
          ),
          Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: Icon(Icons.payments_outlined, size: 20.sp),
              label: Text(
                "Withdraw Now",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16.sp,
                ),
              ),
              onPressed: () => _showCustomDialog(context, amtCtrl),
              style: ElevatedButton.styleFrom(
                foregroundColor: Color(0xff462eb4),
                backgroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSection() {
    return Positioned(
      top: 300.h,
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        margin: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
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
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TabBar(
                  controller: _tabController,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey[600],
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Color(0xff5d3cf8),
                  ),
                  tabs: [
                    Tab(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle_outline, size: 20.sp),
                            SizedBox(width: 8.w),
                            Text(
                              'Verified',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Tab(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.pending_outlined, size: 20.sp),
                            SizedBox(width: 8.w),
                            Text(
                              'Inactive',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (isLoading)
              Container(
                height: 200.h,
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xff5d3cf8)),
                    strokeWidth: 3,
                  ),
                ),
              )
            else
              Container(
                height: 412.h,
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
    );
  }

  Widget _buildReferralList(List<ReferralData> referrals, bool isActive) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.all(16),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xff5d3cf8),
                Color(0xff462eb4),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Color(0xff5d3cf8).withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatCard(
                'Total Referrals',
                '${referralData?['totalReferrals'] ?? 0}',
                Icons.people_alt_outlined,
              ),
              Container(
                height: 50.h,
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
              ? _buildEmptyState(isActive)
              : ListView.builder(
            padding: EdgeInsets.all(16.w),
            itemCount: referrals.length,
            itemBuilder: (context, index) {
              final referral = referrals[index];
              return AnimatedOpacity(
                opacity: 1.0,
                duration: Duration(milliseconds: 500 + (index * 100)),
                child: _buildReferralCard(referral),
              );
            },
          ),
        ),
        SizedBox(height: 30.h,)
      ],
    );
  }

  Widget _buildEmptyState(bool isActive) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20.sp),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              isActive ? Icons.people_outline : Icons.pending_actions,
              size: 48.sp,
              color: Color(0xff5d3cf8).withOpacity(0.7),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'No ${isActive ? 'active' : 'inactive'} referrals yet',
            style: TextStyle(
              fontSize: 18.sp,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            isActive
                ? 'Invite users to earn rewards'
                : 'Referrals awaiting verification will appear here',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20.h),
          if (isActive)
            ElevatedButton.icon(
              icon: Icon(Icons.share, size: 18.sp),
              label: Text('Share Referral Link'),
              onPressed: () {
                // Share functionality
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Color(0xff5d3cf8),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(12.sp),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24.sp,
          ),
        ),
        SizedBox(width: 16.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.white.withOpacity(0.8),
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              value,
              style: TextStyle(
                fontSize: 22.sp,
                color: Colors.white,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
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
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // Handle tap
            },
            child: Padding(
              padding: EdgeInsets.all(16.sp),
              child: Row(
                children: [
                  Hero(
                    tag: 'avatar_${referral.username}',
                    child: Container(
                      width: 60.w,
                      height: 60.w,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            referral.avatarColor,
                            referral.avatarColor.withOpacity(0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
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
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w700,
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
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 6.h,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(referral.status).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _getStatusIcon(referral.status),
                                    size: 14.sp,
                                    color: _getStatusColor(referral.status),
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    _tabController.index == 1 ? 'Inactive' : referral.status,
                                    style: TextStyle(
                                      color: _getStatusColor(referral.status),
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
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
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
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

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Icons.check_circle_outline;
      case 'pending':
        return Icons.hourglass_empty;
      case 'inactive':
        return Icons.remove_circle_outline;
      default:
        return Icons.info_outline;
    }
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

  void _showCustomDialog(BuildContext context, TextEditingController amountController) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        bool isLoading = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24.0),
              ),
              elevation: 10,
              child: Container(
                padding: EdgeInsets.all(24.sp),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10.sp),
                          decoration: BoxDecoration(
                            color: Color(0xff5d3cf8).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.account_balance_wallet,
                            color: Color(0xff5d3cf8),
                            size: 24.sp,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            "Withdraw Earnings",
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            padding: EdgeInsets.all(4.sp),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              color: Colors.grey[600],
                              size: 20.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h),

                    // Available balance
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.sp),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.grey[200]!,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Available Balance",
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            formatter.format(double.parse(userData?.earn ?? "0.00")),
                            style: TextStyle(
                              fontSize: 24.sp,
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // Input field
                    Text(
                      "Amount to Withdraw",
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    CustomTextField(
                      fieldName: "amount",
                      controller: amountController,
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
                              amountController.text,
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
                              amountController.clear();
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