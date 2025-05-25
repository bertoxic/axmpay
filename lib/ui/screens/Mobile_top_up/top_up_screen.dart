import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:AXMPAY/models/ResponseModel.dart';
import 'package:AXMPAY/ui/screens/Mobile_top_up/top_up_screen_contoller.dart';
import 'package:AXMPAY/ui/widgets/custom_dialog.dart';
import 'package:AXMPAY/ui/widgets/custom_responsive_sizes/responsive_size.dart';
import 'package:AXMPAY/ui/widgets/svg_maker/svg_icon.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../../main.dart';
import '../../../models/transaction_model.dart';
import '../../../providers/user_service_provider.dart';
import '../../widgets/custom_buttons.dart';
import '../../widgets/custom_container.dart';
import '../../widgets/custom_dropdown.dart';
import '../../widgets/custom_text/custom_apptext.dart';
import '../../widgets/custom_textfield.dart';
import '../passcode_screen/passcode_screen.dart';

class MobileTopUp extends StatefulWidget {
  const MobileTopUp({Key? key}) : super(key: key);

  @override
  State<MobileTopUp> createState() => _MobileTopUpState();
}

class _MobileTopUpState extends State<MobileTopUp> {
  String? phoneNumberValue;
  TopUpPayload? topUpPayload;
  DataBundle? dataBundle;
  late TopUpController _topUpController;
  late TextEditingController phoneController;
  late TextEditingController amountController;
  late UserServiceProvider userProvider;
  Future<DataBundleList?>? _dataBundleList;
  bool phoneIsValid = false;
  bool isData = false;
  bool isDataSelected = false;
  DataBundle? selectedDataBundle;
  String? serviceProviderNetwork;
  bool isSelectingDataBundle = true;
  Future<ResponseResult?>? _phoneCheckFuture;

  @override
  void initState() {
    super.initState();
    phoneController = TextEditingController();
    amountController = TextEditingController();
    _topUpController = TopUpController();
    userProvider = Provider.of<UserServiceProvider>(context, listen: false);
    phoneController.addListener(_onPhoneChanged);
  }

  Timer? _debounceTimer;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    phoneController.removeListener(_onPhoneChanged);
    phoneController.dispose();
    amountController.dispose();
    super.dispose();
  }

  // Add this method to handle phone number formatting
  String _formatPhoneNumber(String phone) {
    if (phone.isEmpty) return phone;

    // Remove any non-numeric characters
    phone = phone.replaceAll(RegExp(r'[^0-9]'), '');

    // If number doesn't start with 0, add it
    if (!phone.startsWith('0')) {
      phone = '0$phone';
    }

    // Limit to 11 digits
    if (phone.length > 11) {
      phone = phone.substring(0, 11);
    }

    return phone;
  }

  void _onPhoneChanged() {
    // Get the current value and format it
    String formattedNumber = _formatPhoneNumber(phoneController.text.trim());

    // Only update if the number is different to avoid infinite loop
    if (formattedNumber != phoneController.text) {
      phoneController.value = TextEditingValue(
        text: formattedNumber,
        selection: TextSelection.collapsed(offset: formattedNumber.length),
      );
    }

    // Reset states if phone number is being changed
    if (phoneNumberValue != formattedNumber) {
      setState(() {
        phoneIsValid = false;
        serviceProviderNetwork = null;
        _phoneCheckFuture = null;
        _resetDataState();
      });
    }

    // Only make API call when we have exactly 11 digits and it starts with 0
    if (formattedNumber.length == 11 && formattedNumber.startsWith('0')) {
      setState(() {
        phoneNumberValue = formattedNumber;
        phoneIsValid = true;
        _phoneCheckFuture = _checkPhoneNumber(formattedNumber);
      });
    }
  }

  Future<ResponseResult?> _checkPhoneNumber(String phoneNumber) async {
    // Add debounce to prevent rapid API calls
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer!.cancel();
    }

    return Future.delayed(const Duration(milliseconds: 500), () async {
      try {
        final result =
        await userProvider.getNetworkProvider(context, phoneNumber);
        if (mounted) {
          setState(() {
            if (result?.status == ResponseStatus.success) {
              final data = result?.data as Map<String, dynamic>?;
              serviceProviderNetwork = data?["network"];
            } else {
              serviceProviderNetwork = null;
              phoneIsValid = false;
            }
          });
        }
        return result;
      } catch (e) {
        print("Error checking phone number: $e");
        if (mounted) {
          setState(() {
            serviceProviderNetwork = null;
            phoneIsValid = false;
          });
        }
        return null;
      }
    });
  }

// Add this method to centralize data state reset
  void _resetDataState() {
    isDataSelected = false;
    selectedDataBundle = null;
    _dataBundleList = null;
    isSelectingDataBundle = true;
    dataBundle = null;
    if (amountController.text.isNotEmpty) {
      amountController.clear();
    }
  }

  bool _isValidPhoneNumber(String phoneNumber) {
    // Must start with 0 and be exactly 11 digits
    return phoneNumber.startsWith('0') && phoneNumber.length == 11;
  }

  Color? _getProviderColor(String providerLogo) {
    switch (providerLogo) {
      case "9MOBILE":
        return Colors.green;
      case "GLO":
        return Colors.green;
      case "AIRTEL":
        return Color(0xFFDD4343);
      case "MTN":
        return Color(0xFFEBB53B);
    }
    return colorScheme.primary;}

  Future<DataBundleList?> _getListOfDataBundles() async {
    if (!phoneIsValid) return null;
    try {
      final result =
      await userProvider.getDataPlans(context, phoneNumberValue!);
      if (mounted) {
        setState(() {
          _dataBundleList = Future.value(result);
        });
      }
      return result;
    } catch (e) {
      print("Error fetching data bundles: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mobile Top Up", style: TextStyle(fontWeight: FontWeight.w600)),
        elevation: 0,
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [colorScheme.primary.withOpacity(0.05), Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPhoneNumberInput(),
                SizedBox(height: 24.h),
                _buildServiceProviderInfo(),
                SizedBox(height: 24.h),
                _buildTopUpTypeSelection(),
                SizedBox(height: 24.h),
                if (!isDataSelected) _buildAmountInput(),
                if (isDataSelected) _buildDataBundleSelection(),
                SizedBox(height: 32.h),
                _buildTopUpButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildPhoneNumberInput() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 6.w, bottom: 12.h),
            child: Row(
              children: [
                Icon(
                  Icons.phone_android_rounded,
                  size: 20.sp,
                  color: colorScheme.primary,
                ),
                SizedBox(width: 8.w),
                AppText.body(
                  "Phone Number",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[800],
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [Colors.white, Colors.grey[50]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                Container(
                  height: 58.h,
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primary,
                        colorScheme.primary.withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppText.caption(
                        "+234",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15.sp,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: CustomTextField(
                    fieldName: "phone",
                    controller: phoneController,
                    onChanged: (value) {
                      String formattedNumber = _formatPhoneNumber(value);
                      if (formattedNumber != value) {
                        phoneController.value = TextEditingValue(
                          text: formattedNumber,
                          selection: TextSelection.collapsed(offset: formattedNumber.length),
                        );
                      }
                    },
                    onEditingComplete: () {
                      _onPhoneChanged();
                    },
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      fillColor: Colors.transparent,
                      filled: true,
                      hintText: "Enter phone number",
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: const BorderRadius.horizontal(right: Radius.circular(16)),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: const BorderRadius.horizontal(right: Radius.circular(16)),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: const BorderRadius.horizontal(right: Radius.circular(16)),
                        borderSide: BorderSide(color: colorScheme.primary, width: 2),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceProviderInfo() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey[50]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: FutureBuilder<ResponseResult?>(
        future: _phoneCheckFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SizedBox(
              height: 80.h,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 32.w,
                      height: 32.w,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                        strokeWidth: 3,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      "Detecting network...",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red[200]!, width: 1),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red[600], size: 24.sp),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      "Error verifying number: ${snapshot.error}",
                      style: TextStyle(
                        color: Colors.red[700],
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasData) {
            if (snapshot.data?.status.toString().toLowerCase() ==
                ResponseStatus.failed.toString().toLowerCase()) {
              return Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red[200]!, width: 1),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red[600], size: 24.sp),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        "${snapshot.data?.message}",
                        style: TextStyle(
                          color: Colors.red[700],
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 56.h,
                    width: 56.h,
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.grey[100]!,
                          Colors.grey[50]!,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: _topUpController.getServiceProviderLogo(
                      serviceProviderNetwork ?? "",
                    ),
                  ),
                  SizedBox(width: 20.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Network Provider",
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[500],
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        serviceProviderNetwork ?? "",
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey[800],
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }
          }
          return Row(
            children: [
              Expanded(child: Center(child: Text("Enter a valid phone number"),)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAmountInput() {
    if (isData) return const SizedBox();
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 6.w, bottom: 12.h),
            child: Row(
              children: [
                Icon(
                  FontAwesomeIcons.nairaSign,
                  size: 18.sp,
                  color: colorScheme.primary,
                ),
                SizedBox(width: 8.w),
                AppText.body(
                  "Amount",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[800],
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Colors.grey[50]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: CustomTextField(
              fieldName: "amount",
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                fillColor: Colors.transparent,
                filled: true,
                hintText: "Enter amount",
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                ),
                prefixIcon: Container(
                  margin: EdgeInsets.all(12.w),
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    FontAwesomeIcons.nairaSign,
                    color: colorScheme.primary,
                    size: 16.sp,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: colorScheme.primary, width: 2),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildPhoneNumberInputx() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
            child: AppText.body(
              "Phone Number",
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ),
          Row(
            children: [
              Container(
                height: 52.h,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.horizontal(left: Radius.circular(12)),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: AppText.caption(
                    "Ng +234",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: CustomTextField(
                  fieldName: "phone",
                  controller: phoneController,
                  onChanged: (value) {
                    String formattedNumber = _formatPhoneNumber(value);
                    if (formattedNumber != value) {
                      phoneController.value = TextEditingValue(
                        text: formattedNumber,
                        selection: TextSelection.collapsed(offset: formattedNumber.length),
                      );
                    }
                  },
                  onEditingComplete: () {
                    _onPhoneChanged();
                  },
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    hintText: "Enter phone number",
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.horizontal(right: Radius.circular(12)),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.horizontal(right: Radius.circular(12)),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.horizontal(right: Radius.circular(12)),
                      borderSide: BorderSide(color: colorScheme.primary, width: 1),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceProviderInfox() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: FutureBuilder<ResponseResult?>(
        future: _phoneCheckFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
              ),
            );
          } else if (snapshot.hasError) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(
                "An error occurred while verifying the number: ${snapshot.error}",
                style: TextStyle(color: Colors.red[700], fontSize: 14.sp),
                textAlign: TextAlign.center,
              ),
            );
          } else if (snapshot.hasData) {
            if (snapshot.data?.status.toString().toLowerCase() ==
                ResponseStatus.failed.toString().toLowerCase()) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Text(
                  "${snapshot.data?.message}",
                  style: TextStyle(color: Colors.red[700], fontSize: 14.sp),
                  textAlign: TextAlign.center,
                ),
              );
            } else {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 48.h,
                    width: 48.h,
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _topUpController.getServiceProviderLogo(
                      serviceProviderNetwork ?? "",
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Text(
                    serviceProviderNetwork ?? "",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              );
            }
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildAmountInputx() {
    if (isData) return SizedBox();
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
            child: AppText.body(
              "Amount",
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ),
          CustomTextField(
            fieldName: "amount",
            controller: amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              fillColor: Colors.white,
              filled: true,
              hintText: "Enter amount",
              hintStyle: TextStyle(color: Colors.grey[400]),
              //prefixIcon: Icon(Icons.account_balance_wallet, color: colorScheme.primary),
              prefixIcon: Icon(FontAwesomeIcons.nairaSign, color: colorScheme.primary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.primary, width: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopUpTypeSelection() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                isDataSelected = false;
                isData = false;
              });
            },
            child: Container(
              height: 110.h,
              decoration: BoxDecoration(
                color: isDataSelected ? Colors.white : colorScheme.primary,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: (isDataSelected ? Colors.black : colorScheme.primary)
                        .withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.phone_android,
                    size: 36.sp,
                    color: isDataSelected ? Colors.grey[600] : Colors.white,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    "Airtime",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: isDataSelected ? Colors.grey[600] : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                isDataSelected = true;
                isData = true;
                _dataBundleList = _getListOfDataBundles();
              });
            },
            child: Container(
              height: 110.h,
              decoration: BoxDecoration(
                color: isDataSelected ? colorScheme.primary : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: (isDataSelected ? colorScheme.primary : Colors.black)
                        .withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.data_usage,
                    size: 36.sp,
                    color: isDataSelected ? Colors.white : Colors.grey[600],
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    "Data",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: isDataSelected ? Colors.white : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDataBundleCard(DataBundle item, bool isSelected) {
    return Container(
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        color: isSelected
            ? _getProviderColor(serviceProviderNetwork ?? "")
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isSelected
                ? _getProviderColor(serviceProviderNetwork ?? "")
                : Colors.black)
            !.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: isSelectingDataBundle
            ? MainAxisAlignment.center
            : MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: !isSelectingDataBundle
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(8.sp),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withOpacity(0.2)
                      : _getProviderColor(serviceProviderNetwork ?? "")
                      ?.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.data_usage,
                  size: 24.sp,
                  color: isSelected
                      ? Colors.white
                      : _getProviderColor(serviceProviderNetwork ?? ""),
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                item.dataBundle,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.grey[800],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              Text(
                '₦${item.amount}',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white.withOpacity(0.9) : Colors.grey[600],
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                item.validity,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: isSelected ? Colors.white.withOpacity(0.7) : Colors.grey[500],
                ),
              ),
            ],
          ),
          if (!isSelectingDataBundle)
            Container(
              padding: EdgeInsets.all(8.sp),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: GestureDetector(
                onTap: (){
                  setState(() {
                    isSelectingDataBundle = true;
                    selectedDataBundle = null;
                    amountController.clear();
                  });
                },
                child: Icon(
                  Icons.arrow_forward,
                  color: isSelected ? Colors.white : Colors.grey[400],
                  size: 20.sp,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTopUpButton() {
    return CustomButton(
      height: 56.h,
      text: "Top Up Now",
      width: double.infinity,

      onPressed: () {
        // Validate phone number
        if (!phoneIsValid || phoneNumberValue == null || phoneNumberValue!.isEmpty) {
          CustomPopup.show(
            type: PopupType.error,
            context: context,
            message: "Please enter a valid phone number",
            title: "Invalid Phone Number",
          );
          return;
        }

        // Validate network provider
        if (serviceProviderNetwork == null || serviceProviderNetwork!.isEmpty) {
          CustomPopup.show(
            type: PopupType.error,
            context: context,
            message: "Unable to determine service provider. Please check the number and try again.",
            title: "No Service Provider",
          );
          return;
        }

        // Validate amount for airtime
        if (!isDataSelected) {
          final amount = amountController.text.trim();
          if (amount.isEmpty) {
            CustomPopup.show(
              type: PopupType.error,
              context: context,
              message: "Please enter an amount for airtime top-up",
              title: "Missing Amount",
            );
            return;
          }

          final parsedAmount = double.tryParse(amount);
          if (parsedAmount == null || parsedAmount <= 0) {
            CustomPopup.show(
              type: PopupType.error,
              context: context,
              message: "Please enter a valid amount for airtime top-up",
              title: "Invalid Amount",
            );
            return;
          }
        }

        // Validate data bundle selection
        if (isDataSelected && selectedDataBundle == null) {
          CustomPopup.show(
            type: PopupType.error,
            context: context,
            message: "Please select a data bundle",
            title: "Missing Data Bundle",
          );
          return;
        }

        // Create TopUpPayload with validated data
        final topup = TopUpPayload(
          phoneNumber: phoneNumberValue!,
          amount: isDataSelected ? selectedDataBundle!.amount! : amountController.text.trim(),
          network: serviceProviderNetwork!,
          productId: isDataSelected ? (selectedDataBundle!.productId ?? "") : "",
        );

        _showBottomSheet(
          context,
          topup,
          userProvider,
              () async {
            try {
              final correctPass = await showDialog<bool>(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.6,
                        maxWidth: MediaQuery.of(context).size.width * 0.9,
                      ),
                      child: const PasscodeInputScreen(),
                    ),
                  );
                },
              );

              if (correctPass == true) {
                ResponseResult? resp;
                if (isDataSelected) {
                  resp = await userProvider.topUpData(context, topup);
                } else {
                  resp = await userProvider.buyAirtime(context, topup);
                }

                if (!mounted) return;

                if (resp?.status == ResponseStatus.failed) {
                  CustomPopup.show(
                    type: PopupType.error,
                    context: context,
                    title: "Top-up Failed",
                    message: resp?.message?.toString() ?? "An error occurred ",
                  );
                } else {
                  Navigator.pop(context); // Close bottom sheet
                  CustomPopup.show(
                    type: PopupType.success,
                    context: context,
                    message: "Top-up successful",
                    title: "Success",
                  );
                  // Reset form after successful transaction
                  _resetForm();
                }
              } else if (correctPass == false) {
                if (!mounted) return;
                CustomPopup.show(
                  type: PopupType.error,
                  context: context,
                  title: "Wrong Passcode",
                  message: "Please enter the correct passcode",
                );
              }
            } catch (e) {
              if (!mounted) return;
              CustomPopup.show(
                type: PopupType.error,
                context: context,
                message: "An error occurred during top-up}",
                title: "Error",
              );
            }
          },
        );
      },
    );

// Add this method to reset the form

  }
  void _resetForm() {
    setState(() {
      phoneController.clear();
      amountController.clear();
      phoneNumberValue = null;
      phoneIsValid = false;
      serviceProviderNetwork = null;
      _phoneCheckFuture = null;
      _resetDataState();
    });
  }
  Widget _buildDataBundleSelection() {
    if (!isDataSelected) return const SizedBox();

    // Reset data bundle if phone number changes
    if (!phoneIsValid) {
      _resetDataState();
      return const SizedBox();
    }

    return FutureBuilder<DataBundleList?>(
      future: _dataBundleList,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Error loading data bundles: ${snapshot.error}"),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _dataBundleList = _getListOfDataBundles();
                    });
                  },
                  child: Text("Retry"),
                ),
              ],
            ),
          );
        } else if (snapshot.hasData &&
            snapshot.data?.dataBundles.isNotEmpty == true) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText.body("Data Bundle",
                      style: TextStyle(
                          fontSize: 18.sp, fontWeight: FontWeight.bold)),
                  if (!isSelectingDataBundle && selectedDataBundle != null)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          isSelectingDataBundle = true;
                          selectedDataBundle = null;
                          amountController.clear();
                        });
                      },
                      child: Text("Change",
                          style: TextStyle(color: colorScheme.primary)),
                    ),
                ],
              ),
              SizedBox(height: 16.h),
              if (isSelectingDataBundle)
                _buildDataBundleGrid(snapshot.data!.dataBundles)
              else if (selectedDataBundle != null)
                _buildDataBundleCard(selectedDataBundle!, true),
            ],
          );
        } else {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("No data bundles available for this number"),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _dataBundleList = _getListOfDataBundles();
                    });
                  },
                  child: Text("Retry"),
                ),
              ],
            ),
          );
        }
      },
    );
  }
  Widget _buildDataBundleGrid(List<DataBundle> bundles) {
    return SizedBox(
      height: 340.h,
      child: GridView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        physics: const AlwaysScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.2,
          crossAxisSpacing: 16.w,
          mainAxisSpacing: 16.h,
        ),
        itemCount: bundles.length,
        itemBuilder: (context, index) {
          final item = bundles[index];
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedDataBundle = item;
                dataBundle = item;
                amountController.text = item.amount ?? '';
                isSelectingDataBundle = false;
              });
            },
            child: _buildDataBundleCard(item, false),
          );
        },
      ),
    );
  }
  void _showBottomSheet(BuildContext context, TopUpPayload topUpPayload, UserServiceProvider userp,
      Future<void> Function() onTap,
      ) {showModalBottomSheet(context: context, isScrollControlled: true, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20)),),
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (_, controller) => BottomSheetContent(
        topUpPayload,
        controller: controller,
        userp: userp,
        onTap: onTap,
      ),
    ),
  );
  }
}

class BottomSheetContent extends StatefulWidget {
  final TopUpPayload topUpPayload;
  final ScrollController controller;
  final UserServiceProvider userp;
  final Future<void> Function() onTap;

  const BottomSheetContent(this.topUpPayload,
      {Key? key,
        required this.controller,
        required this.userp,
        required this.onTap})
      : super(key: key);

  @override
  State<BottomSheetContent> createState() => _BottomSheetContentState();
}

class _BottomSheetContentState extends State<BottomSheetContent> {
  bool _isLoading = false;

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: widget.controller,
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      children: [
        Center(
          child: Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        SizedBox(height: 24.h),
        Center(
          child: Container(
            padding: EdgeInsets.all(16.sp),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.phone_android_rounded,
              size: 32.sp,
              color: colorScheme.primary,
            ),
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          "Confirm Top Up",
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8.h),
        Text(
          "Please review your airtime purchase details",
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 32.h),
        Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: [
              _buildInfoRow("Amount", "₦${widget.topUpPayload.amount}"),
              Divider(height: 16.h),
              _buildInfoRow("Phone Number", widget.topUpPayload.phoneNumber),
              Divider(height: 16.h),
              _buildInfoRow("Network", widget.topUpPayload.network),
            ],
          ),
        ),
        SizedBox(height: 24.h),
        CustomButton(
          onPressed: _isLoading ? null : _handleTopUp,
          customChild: _isLoading
              ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 24.w,
                height: 24.h,
                child: const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 2.5,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                "Processing...",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          )
              : Text(
            "Confirm Top Up",
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          text: "Confirm Top Up",
          size: ButtonSize.large,
          width: double.infinity,
        ),
        // SizedBox(height: 32.h),
        // _buildAccountInfo(widget.userp),

        SizedBox(height: 16.h),
      ],
    );
  }

  Future<void> _handleTopUp() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await widget.onTap();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

// Widget _buildAccountInfo(UserServiceProvider userp) {
//   return Container(
//     decoration: BoxDecoration(
//       color: Colors.blue.withOpacity(0.1),
//       borderRadius: BorderRadius.circular(16),
//       border: Border.all(color: colorScheme.primary.withOpacity(0.2)),
//     ),
//     padding: EdgeInsets.all(16.w),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Container(
//               padding: EdgeInsets.all(8.w),
//               decoration: BoxDecoration(
//                 color: colorScheme.primary.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Icon(
//                 Icons.account_balance_wallet,
//                 color: colorScheme.primary,
//                 size: 20.sp,
//               ),
//             ),
//             SizedBox(width: 12.w),
//             Text(
//               "Account to be Debited",
//               style: TextStyle(
//                 fontSize: 14.sp,
//                 color: Colors.grey[700],
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ],
//         ),
//         SizedBox(height: 12.h),
//         Text(
//           userp.userdata?.firstname ?? "",
//           style: TextStyle(
//             fontSize: 16.sp,
//             fontWeight: FontWeight.w600,
//             color: Colors.black87,
//           ),
//         ),
//         SizedBox(height: 4.h),
//         Text(
//           "Available Balance",
//           style: TextStyle(
//             fontSize: 12.sp,
//             color: Colors.grey[600],
//           ),
//         ),
//       ],
//     ),
//   );
// }