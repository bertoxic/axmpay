import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:AXMPAY/models/ResponseModel.dart';
import 'package:AXMPAY/ui/screens/Mobile_top_up/top_up_screen_contoller.dart';
import 'package:AXMPAY/ui/widgets/custom_dialog.dart';
import 'package:AXMPAY/ui/widgets/custom_responsive_sizes/responsive_size.dart';
import 'package:AXMPAY/ui/widgets/svg_maker/svg_icon.dart';
import 'package:flutter/material.dart';
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
  String? phoneNumberValue = "";
  TopUpPayload? topUpPayload;
  DataBundle? dataBundle;
  late TopUpController _topUpController;
  late TextEditingController phoneController;
  late TextEditingController amountController;
  late UserServiceProvider userProvider;
  Future<DataBundleList?>? _dataBundleList;
  bool phoneIsValid = false;
  bool isData = false;
  String? serviceProviderNetwork;

  @override
  void initState() {
    super.initState();
    phoneController = TextEditingController();
    amountController = TextEditingController();
    _topUpController = TopUpController();
    userProvider = Provider.of<UserServiceProvider>(context, listen: false);
  }

  @override
  void dispose() {
    phoneController.dispose();
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mobile Top Up"),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPhoneNumberInput(),
              SizedBox(height: 20.h),
              _buildServiceProviderInfo(),
              SizedBox(height: 20.h),
              _buildAmountInput(),
              SizedBox(height: 20.h),
              _buildTopUpTypeDropdown(),
              SizedBox(height: 20.h),
              _buildDataBundleDropdown(),
              SizedBox(height: 30.h),
              _buildTopUpButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneNumberInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.body("Phone Number"),
        SizedBox(height: 8.h),
        Row(
          children: [
            Container(
              height: 48.h,
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.horizontal(left: Radius.circular(8)),
              ),
              child: Center(
                child: AppText.caption(
                  "Ng +234",
                  color: Colors.white,
                ),
              ),
            ),
            Expanded(
              child: CustomTextField(
                fieldName: "phone",
                controller: phoneController,
                onChanged: (value) {
                  phoneNumberValue = value.toString();
                  _checkPhoneNumber();
                },
                decoration: InputDecoration(
                  fillColor: Colors.grey.shade100,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.horizontal(right: Radius.circular(8)),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildServiceProviderInfo() {
    return FutureBuilder<ResponseResult?>(
      future: _checkPhoneNumber(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text("An error occurred while verifying the number: ${snapshot.error}");
        } else if (snapshot.hasData && phoneIsValid) {
          final data = snapshot.data?.data as Map<String, dynamic>?;
          serviceProviderNetwork = data?["network"];
          if (snapshot.data?.status == ResponseStatus.failed) {
            return Text("${snapshot.data?.message}");
          } else {
            return Row(
              children: [
                SizedBox(
                  height: 40.h,
                  width: 40.h,
                  child: _topUpController.getServiceProviderLogo(serviceProviderNetwork ?? ""),
                ),
                SizedBox(width: 12.w),
                Text(
                  serviceProviderNetwork ?? "",
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),
              ],
            );
          }
        }
        return SizedBox();
      },
    );
  }

  Widget _buildAmountInput() {
    if (isData) return SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.body("Amount"),
        SizedBox(height: 8.h),
        CustomTextField(
          fieldName: "amount",
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            fillColor: Colors.grey.shade100,
            filled: true,
            prefixIcon: Icon(Icons.attach_money, color: colorScheme.primary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopUpTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.body("Top Up Type"),
        SizedBox(height: 8.h),
        CustomDropdown<String>(
          items: const ['Airtime', 'Data'],
          initialValue: "Airtime",
          onChanged: (newValue) {
            setState(() {
              isData = newValue == 'Data';
              if (isData) {
                _getListOfDataBundles();
              }
            });
          },
          itemBuilder: (item) => Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
            child: Text(item),
          ),
          selectedItemBuilder: (item) => Text(item),
        ),
      ],
    );
  }

  Widget _buildDataBundleDropdown() {
    if (!isData) return SizedBox();
    return FutureBuilder<DataBundleList?>(
      future: _dataBundleList,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text("Error loading data bundles: ${snapshot.error}");
        } else if (snapshot.hasData && phoneIsValid) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText.body("Select Data Bundle"),
              SizedBox(height: 8.h),
              CustomDropdown<DataBundle>(
                items: snapshot.data!.dataBundles,
                initialValue: snapshot.data?.dataBundles.isNotEmpty == true ? snapshot.data?.dataBundles[0] : null,
                onChanged: (newValue) {
                  setState(() {
                    dataBundle = newValue;
                    amountController.text = newValue?.amount ?? '';
                  });
                },
                itemBuilder: (item) => ListTile(
                  leading: Icon(Icons.money),
                  title: Text(item.dataBundle),
                  subtitle: Text('${item.validity} - ₦${item.amount}'),
                ),
                selectedItemBuilder: (item) => Text("${item.dataBundle} - ₦${item.amount}"),
              ),
            ],
          );
        }
        return SizedBox();
      },
    );
  }

  Widget _buildTopUpButton() {
    return CustomButton(
      height: 48.h,
      text: "Top Up",
      width: double.infinity,
      onPressed: () {
        if (!phoneIsValid) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please enter a valid phone number")),
          );
          return;
        }

        TopUpPayload topup = TopUpPayload(
          phoneNumber: phoneNumberValue!,
          amount: amountController.text,
          network: serviceProviderNetwork!,
          productId: isData ? dataBundle?.productId ?? "" : "",
        );

        _showBottomSheet(
          context,
          topup,
          userProvider,
              () async {
            try {
              bool correctPass = await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return Dialog(
                    child:ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.6,
                        maxWidth: MediaQuery.of(context).size.width * 0.9,
                      ),
                      child: const PasscodeInputScreen(),
                    ),
                  );
                },
              );
              if(correctPass){
              ResponseResult? resp = await userProvider.buyAirtime(context, topup);
              if(resp?.status == ResponseStatus.failed){
                if(!mounted) return;
                CustomPopup.show(context: context,
                    title: "error occured: ${resp?.status.toString()}",
                    message: "${resp?.message.toString()}");
              }
              if(!mounted) return;

              Navigator.pop(context); // Close the bottom sheet
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Top-up successful")),
              );
              }else{
                if(!mounted) return;
                CustomPopup.show(context: context,
                    title: "wrong passcode inputted}",
                    message: "Please use a correct passcode");
              }
            } catch (e) {
              print("Error during top-up: $e");
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Top-up failed: $e")),
              );
            }
          },
        );
      },
    );
  }

  Future<DataBundleList?> _getListOfDataBundles() async {
    if (!phoneIsValid) return null;
    try {
      final result = await userProvider.getDataPlans(context, phoneNumberValue!);
      setState(() {
        _dataBundleList = Future.value(result);
      });
      return result;
    } catch (e) {
      print("Error fetching data bundles: $e");
      return null;
    }
  }

  Future<ResponseResult?> _checkPhoneNumber() async {
    String? phoneNumber = phoneController.text.trim();
    if (phoneNumber.isEmpty) return null;

    setState(() {
      phoneIsValid = false;
    });

    if (phoneNumber.length == 10 && !phoneNumber.startsWith('0')) {
      phoneNumber = '0$phoneNumber';
    }

    if (phoneNumber.length == 11 && phoneNumber.startsWith('0')) {
      setState(() {
        phoneIsValid = true;
        phoneNumberValue = phoneNumber;
      });

      try {
        return await userProvider.getNetworkProvider(context, phoneNumber);
      } catch (e) {
        print("Error checking phone number: $e");
        return null;
      }
    }
    return null;
  }
}

void _showBottomSheet(
    BuildContext context,
    TopUpPayload topUpPayload,
    UserServiceProvider userp,
    Future<void> Function() onTap,
    ) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
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

class BottomSheetContent extends StatefulWidget {
  final TopUpPayload topUpPayload;
  final ScrollController controller;
  final UserServiceProvider userp;
  final Future<void> Function() onTap;

  const BottomSheetContent(
      this.topUpPayload,
      {Key? key, required this.controller, required this.userp, required this.onTap}
      ) : super(key: key);

  @override
  State<BottomSheetContent> createState() => _BottomSheetContentState();
}

class _BottomSheetContentState extends State<BottomSheetContent> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: widget.controller,
      padding: EdgeInsets.all(20.w),
      children: [
        Center(
          child: Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        SizedBox(height: 20.h),
        Text(
          "Confirm Top Up",
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 30.h),
        _buildInfoRow("Amount", "₦${widget.topUpPayload.amount}"),
        _buildInfoRow("Phone Number", widget.topUpPayload.phoneNumber),
        _buildInfoRow("Network", widget.topUpPayload.network),
        SizedBox(height: 20.h),
        _buildAccountInfo(widget.userp),
        SizedBox(height: 30.h),
        CustomButton(
          onPressed: _isLoading ? null : () async {
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
          },
          customChild: _isLoading
              ? SizedBox(
            width: 24.w,
            height: 24.h,
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
              : Text("SEND"),
          text: "Confirm Top Up",
          size: ButtonSize.large,
          width: double.infinity,
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
          Text(value, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildAccountInfo(UserServiceProvider userp) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFDEFFE6),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.all(12.w),
      child: Row(
        children: [
          Icon(Icons.account_balance_wallet, color: colorScheme.primary, size: 18.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Account to be Debited", style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
                SizedBox(height: 4.h),
                Text(userp.userdata?.firstname??"", style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
  }