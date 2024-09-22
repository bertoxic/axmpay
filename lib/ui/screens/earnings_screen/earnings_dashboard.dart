import 'package:AXMPAY/models/ResponseModel.dart';
import 'package:AXMPAY/ui/widgets/custom_buttons.dart';
import 'package:AXMPAY/ui/widgets/custom_container.dart';
import 'package:AXMPAY/ui/widgets/custom_dialog.dart';
import 'package:AXMPAY/ui/widgets/custom_responsive_sizes/responsive_size.dart';
import 'package:AXMPAY/ui/widgets/custom_textfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../main.dart';
import '../../../models/user_model.dart';
import '../../../providers/user_service_provider.dart';
import '../../widgets/custom_container/wavey_container.dart';
import '../../widgets/custom_text/custom_apptext.dart';

class EarningBalanceDashboard extends StatefulWidget {
  @override
  State<EarningBalanceDashboard> createState() => _EarningBalanceDashboardState();
}

class _EarningBalanceDashboardState extends State<EarningBalanceDashboard> {
  late UserServiceProvider _userServiceProvider;
  late UserData? userData;
  late TextEditingController _amountController;

  final formatter = NumberFormat.currency(locale: 'en_US', symbol: '\₦');

  bool isLoading= false;


  @override
  void initState() {
    _userServiceProvider = Provider.of<UserServiceProvider>(context, listen: false);
    _amountController = TextEditingController();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    userData = _userServiceProvider.userdata;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    double? earningAmt = double.parse(userData?.earn ?? "0.00");
    double? accountAmt = double.parse(userData?.availableBalance ?? "0.00");

    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: [
          // Top container (placed at the top of the stack)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 180.h,
              color: Colors.grey.shade600,
              child: Padding(
                padding:  EdgeInsets.all(12.0.sp),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          child: Icon(Icons.person,size: 34.sp,),
                          backgroundColor: Colors.grey.shade300,
                          radius: 24.sp,
                        ),

                        SizedBox(width: 10.sp,),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText.title("Welcome back", color: Colors.grey.shade200,),
                            SizedBox(width: 10.sp,),
                            AppText.body("${userData?.fullName}",color: Colors.grey.shade200,),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Positioned Wavy Background Container
          Positioned(
            top: 80.h,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8,horizontal: 12),
              child: AnimatedWavyBackgroundContainer(
                height: 160.h,
                backgroundColor: const Color(0xff5d3cf8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color:  const Color(0xff462eb4),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
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
                          Text(
                            '${formatter.format(earningAmt)}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          AppText.caption(
                            '(estimated total of all Earnings)',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 10.sp,
                            ),
                          ),

                        ],
                      ),
                      Column(
                        children: [
                          AppText.caption(
                            "account balance",
                            color: Colors.grey.shade200,
                          ),
                          AppText.caption(
                            formatter.format(accountAmt),
                            color: Colors.grey.shade200,
                          ),
                          Spacer(),
                          GestureDetector(
                            onTap: ()=>_showCustomDialog(context),
                            child: Column(
                              children: [
                                Icon(Icons.add_box_rounded,size: 24.sp,color: Colors.grey.shade200,),
                                SizedBox(height:4.sp),
                                AppText.caption(
                                  "Fund Account",
                                  color: Colors.grey.shade200,
                                ),
                              ],
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
          Positioned(
            top: 280.h,
              left: 0,
              right: 0,
              child: SpacedContainer(
                margin: EdgeInsets.symmetric(vertical: 4.h,horizontal: 12.w),
                padding: EdgeInsets.symmetric(vertical: 12.h,horizontal: 12.w),
                containerColor: colorScheme.primaryContainer,
                borderRadius:BorderRadius.circular(20) ,
                // decoration: const BoxDecoration(
                //   color: Colors.grey
                // ),
                child:  Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.body("Amount to Withdraw"),
                    SizedBox(height: 10.h,),
                    CustomTextField(
                      fieldName: "amount",
                      controller:_amountController ,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        fillColor: Colors.grey.shade100,
                        filled: true,
                        prefixIcon: Icon(Icons.fiber_smart_record_sharp, color: colorScheme.primary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h,),
                   Center(
                     child: CustomButton( size: ButtonSize.large,
                       isLoading: isLoading,
                         onPressed: () async {
                          setState(() {
                            isLoading=true;
                          });
                         try{
                         ResponseResult? resp =  await _userServiceProvider.cashOutEarnings(context, _amountController.text);
                         if (resp?.status == ResponseStatus.failed) {
                           CustomPopup.show(context: context, type:PopupType.error,title: "Failed", message: resp?.message??"failed request");
                         }else if(resp?.status ==ResponseStatus.success){
                           CustomPopup.show(context: context, type: PopupType.success,title: "Success", message: resp?.message??"Withdrawal was successful");
                                  setState(() {
                                  isLoading = false;
                                  });

                         }
                         }catch(e){
                           CustomPopup.show(context: context, type:PopupType.error,title: "Error", message: "an error occured during the process, try again later");
                                      setState(() {
                                      isLoading = false;
                                      });
                         }finally{
                           setState(() {
                             isLoading = false;
                           });
                         }
                         },
                         text: 'Withdraw',
                     ),
                   )
                  ],
                ),
              ))
        ],
      ),
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
                 decoration: BoxDecoration(
                   color: Colors.grey.shade200,
                   borderRadius: BorderRadius.circular(20)
                 ),
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        SizedBox(height: 16.h),
                        Text(
                          "account name",
                          style: TextStyle(fontSize: 9.sp, color: Colors.grey[600]),
                        ),
                        Text(
                          "${_userServiceProvider.userdata?.fullName?.toUpperCase()??"" .toUpperCase()}",
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
                          "${_userServiceProvider.userdata?.accountNumber}",
                          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 16.h),
                        ElevatedButton(
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: _userServiceProvider.userdata!.accountNumber??""));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Account number copied to clipboard')),
                              );
                              Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              primary: colorScheme.primary,
                            ),
                            child: Text('Copy Account Number',style: TextStyle(color: Colors.grey.shade200),)
                        ),
                        Text(
                          "Transfer to this account number",
                          style: TextStyle(fontSize: 9.sp, ),
                        ),


                      ]
                  )));
        });
  }
}
