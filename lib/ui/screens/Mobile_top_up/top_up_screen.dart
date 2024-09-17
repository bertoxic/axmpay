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

  @override
  void dispose() {
    phoneController.removeListener(_onPhoneChanged);
    phoneController.dispose();
    amountController.dispose();
    super.dispose();
  }

  void _onPhoneChanged() {
    final phoneNumber = phoneController.text.trim();
    if (_isValidPhoneNumber(phoneNumber)) {
      setState(() {
        phoneNumberValue = phoneNumber;
        _phoneCheckFuture = _checkPhoneNumber(phoneNumber);
      });
    } else {
      setState(() {
        phoneIsValid = false;
        serviceProviderNetwork = null;
        _phoneCheckFuture = null;
      });
    }
  }

  bool _isValidPhoneNumber(String phoneNumber) {
    return phoneNumber.length == 11 && phoneNumber.startsWith('0');
  }

  Future<ResponseResult?> _checkPhoneNumber(String phoneNumber) async {
    try {
      final result = await userProvider.getNetworkProvider(context, phoneNumber);
      if (mounted) {
        setState(() {
          phoneIsValid = true;
          if (result?.status == ResponseStatus.success) {
            final data = result?.data as Map<String, dynamic>?;
            serviceProviderNetwork = data?["network"];
          }
        });
      }
      return result;
    } catch (e) {
      print("Error checking phone number: $e");
      return null;
    }
  }
  Color? _getProviderColor(String providerLogo){
    switch (providerLogo) {
      case "9MOBILE":
        return Colors.green;
      case "GLO":
        return Colors.green;
      case "AIRTEL":
        return Colors.red;
      case "MTN":
        return Colors.amber;}
    return colorScheme.primary;
  }
  Future<DataBundleList?> _getListOfDataBundles() async {
    if (!phoneIsValid) return null;
    try {
      final result = await userProvider.getDataPlans(context, phoneNumberValue!);
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
              _buildTopUpTypeSelection(),
              SizedBox(height: 20.h),
              if (!isDataSelected) _buildAmountInput(),
              if (isDataSelected) _buildDataBundleSelection(),
              SizedBox(height: 30.h),
              _buildTopUpButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneNumberInput(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.body("Phone Number"),
        SizedBox(height: 8.h),
        Row(
          children: [
            Container(
              height: 48.h,
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 0.h),
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
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
                  _checkPhoneNumber(value);
                },
                decoration: InputDecoration(
                  fillColor: Colors.grey.shade100,
                  filled: true,
                  border: const OutlineInputBorder(
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
      future: _phoneCheckFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text("An error occurred while verifying the number: ${snapshot.error}");
        } else if (snapshot.hasData && phoneIsValid) {
          if (snapshot.data?.status == ResponseStatus.failed) {
            return Text("${snapshot.data?.message}");
          } else {
            return Row( mainAxisAlignment: MainAxisAlignment.center,
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
        return const SizedBox();
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
            prefixIcon: Icon(Icons.fiber_smart_record_sharp, color: colorScheme.primary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  // Widget _buildTopUpTypeDropdown() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       AppText.body("Top Up Type"),
  //       SizedBox(height: 8.h),
  //       CustomDropdown<String>(
  //         items: const ['Airtime', 'Data'],
  //         initialValue: "Airtime",
  //         onChanged: (newValue) {
  //           setState(() {
  //             isData = newValue == 'Data';
  //             if (isData) {
  //               _dataBundleList = _getListOfDataBundles();
  //             }
  //           });
  //         },
  //         itemBuilder: (item) => Padding(
  //           padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
  //           child: Text(item),
  //         ),
  //         selectedItemBuilder: (item) => Text(item),
  //       ),
  //     ],
  //   );
  //
  // }
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
              height: 100.h,
              decoration: BoxDecoration(
                color: isDataSelected ? Colors.grey[200] : colorScheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.phone_android,
                    size: 40.sp,
                    color: isDataSelected ? Colors.grey[600] : Colors.white,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    "Airtime",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
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
              height: 100.h,
              decoration: BoxDecoration(
                color: isDataSelected ? colorScheme.primary : Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.data_usage,
                    size: 40.sp,
                    color: isDataSelected ? Colors.white : Colors.grey[600],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    "Data",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
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
  // Widget _buildDataBundleDropdown() {
  //   if (!isData) return SizedBox();
  //   return FutureBuilder<DataBundleList?>(
  //     future: _dataBundleList,
  //     builder: (context, snapshot) {
  //       if (snapshot.connectionState == ConnectionState.waiting) {
  //         return Center(child: CircularProgressIndicator());
  //       } else if (snapshot.hasError) {
  //         return Text("Error loading data bundles: ${snapshot.error}");
  //       } else if (snapshot.hasData && phoneIsValid) {
  //         return Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             AppText.body("Select Data Bundle"),
  //             SizedBox(height: 8.h),
  //             CustomDropdown<DataBundle>(
  //               items: snapshot.data!.dataBundles,
  //               initialValue: snapshot.data?.dataBundles.isNotEmpty == true ? snapshot.data?.dataBundles[0] : null,
  //               onChanged: (newValue) {
  //                 setState(() {
  //                   dataBundle = newValue;
  //                   amountController.text = newValue?.amount ?? '';
  //                 });
  //               },
  //               itemBuilder: (item) => ListTile(
  //                 leading: Icon(Icons.money    ),
  //                 title: Text(item.dataBundle),
  //                 subtitle: Text('${item.validity} - ₦${item.amount}'),
  //               ),
  //               selectedItemBuilder: (item) => Text("${item.dataBundle} - ₦${item.amount}"),
  //             ),
  //           ],
  //         );
  //       }
  //       return SizedBox();
  //     },
  //   );
  // }
  Widget _buildDataBundleSelection() {
    if (!isDataSelected) return const SizedBox();
    return FutureBuilder<DataBundleList?>(
      future: _dataBundleList,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text("Error loading data bundles: ${snapshot.error}");
        } else if (snapshot.hasData && phoneIsValid) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText.body("Data Bundle", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                  if (!isSelectingDataBundle)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          isSelectingDataBundle = true;
                          selectedDataBundle = null;
                        });
                      },
                      child: Text("Change", style: TextStyle(color: colorScheme.primary)),
                    ),
                ],
              ),
              SizedBox(height: 16.h),
              if (isSelectingDataBundle)SizedBox( height: 300.h,
                child: GridView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    physics: ScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.2,
                      crossAxisSpacing: 16.w,
                      mainAxisSpacing: 16.h,
                    ),
                    itemCount: snapshot.data!.dataBundles.length,
                    itemBuilder: (context, index) {
                      final item = snapshot.data!.dataBundles[index];
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
              )
              else if (selectedDataBundle != null)
                _buildDataBundleCard(selectedDataBundle!, true),
            ],
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildDataBundleCard(DataBundle item, bool isSelected) {
    return Container(
      padding: EdgeInsets.all(12.sp),
      width: double.maxFinite,
      decoration: BoxDecoration(
        color: isSelected ? _getProviderColor(serviceProviderNetwork??"") : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: isSelectingDataBundle?MainAxisAlignment.center:MainAxisAlignment.spaceBetween,
        children: [
          Column(
             mainAxisAlignment: MainAxisAlignment.center,
             crossAxisAlignment: !isSelectingDataBundle?CrossAxisAlignment.start: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.data_usage,
                size: 32.sp,
                color: isSelected ? Colors.white : _getProviderColor(serviceProviderNetwork??"") ,
              ),
              SizedBox(height: 8.h),
              Text(
                item.dataBundle,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4.h),
              Text(
                '₦${item.amount}',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: isSelected ? Colors.white70 : Colors.grey[600],
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                item.validity,
                style: TextStyle(
                  fontSize: 10.sp,
                  color: isSelected ? Colors.white70 : Colors.grey[600],
                ),
              ),
            ],
          ),
          isSelectingDataBundle?const SizedBox():GestureDetector(
              onTap: (){
                setState(() {
                  isSelectingDataBundle = true;
                  selectedDataBundle = null;
                });
              },
              child: Icon(Icons.arrow_forward_outlined, color: Colors.grey.shade200,))
        ],
      ),
    );
  }

  Widget _buildTopUpButton() {
    return CustomButton(
      height: 48.h,
      text: "Top Up",
      width: double.infinity,
      onPressed: () {
        // Check if phone number is valid
        if (!phoneIsValid) {
          CustomPopup.show(
              context: context, message: "Please enter a valid phone number",title: "invalid phone number",
          );
          return;
        }

        // Check if service provider network is available
        if (serviceProviderNetwork == null || serviceProviderNetwork!.isEmpty) {
          CustomPopup.show(
            context: context, message: "Unable to determine service provider. Please try again.", title: 'No serviceProvider',
          );
          return;
        }

        // Check if amount is entered for airtime top-up
        if (!isDataSelected && (amountController.text.isEmpty || double.tryParse(amountController.text) == null)) {
          CustomPopup.show(
              context: context, message: "Please enter a valid amount for airtime top-up",title: "please enter a valid amount",
          );
          return;
        }

        // Check if data bundle is selected for data top-up
        if (isDataSelected && selectedDataBundle == null) {
          CustomPopup.show(
              context: context, message: "Please select a data bundle",title: 'missing data-bundle',
          );
          return;
        }

        // Create TopUpPayload
        TopUpPayload topup = TopUpPayload(
          phoneNumber: phoneNumberValue!,
          amount: isDataSelected ? selectedDataBundle!.amount! : amountController.text,
          network: serviceProviderNetwork!,
          productId: isDataSelected ? selectedDataBundle!.productId ?? "" : "",
        );

        // Show bottom sheet for confirmation
        _showBottomSheet(
          context,
          topup,
          userProvider,
              () async {
            try {
              bool? correctPass = await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return Dialog(
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
                  if(correctPass !=null){
              if (correctPass) {
                ResponseResult? resp = await userProvider.buyAirtime(context, topup);
                if (resp?.status == ResponseStatus.failed) {
                  if (!mounted) return;
                  CustomPopup.show(
                    context: context,
                    title: "Error occurred: ${resp?.status.toString()}",
                    message: "${resp?.message.toString()}",
                  );
                } else {
                  if (!mounted) return;
                  Navigator.pop(context); // Close the bottom sheet
                  CustomPopup.show(
                      context: context, message:"Top-up successful", title: "Success"
                  );
                }
              } else {
                if (!mounted) return;
                CustomPopup.show(
                  context: context,
                  title: "Wrong passcode entered",
                  message: "Please use the correct passcode",
                );
              }
              }
            } catch (e) {
              print("Error during top-up: $e");
              CustomPopup.show(
                  context: context, message: "Top-up failed: $e", title: "failed",
              );
            }
          },
        );
      },
    );
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