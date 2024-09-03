import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:fintech_app/main.dart';
import 'package:fintech_app/models/transaction_model.dart';
import 'package:fintech_app/providers/user_service_provider.dart';
import 'package:fintech_app/ui/widgets/custom_buttons.dart';
import 'package:fintech_app/ui/widgets/custom_container.dart';
import 'package:fintech_app/ui/widgets/custom_dropdown.dart';
import 'package:fintech_app/ui/widgets/custom_responsive_sizes/responsive_size.dart';
import 'package:fintech_app/ui/widgets/custom_text/custom_apptext.dart';
import 'package:fintech_app/ui/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../widgets/transaction_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

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

  bool isData = false;

  String? serviceProviderNetwork;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    phoneController = TextEditingController();
    amountController = TextEditingController();
    serviceProviderController = TextEditingController();
    // phoneController.addListener(checkPhoneNumber);
    userProvider = Provider.of<UserServiceProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        color: colorScheme.background,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              margin: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  color: colorScheme.onBackground),
              child: Column(
                children: [
                  SpacedContainer(
                    padding: EdgeInsets.all(8).copyWith(bottom:0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 20.sp,
                                backgroundColor: Colors.grey,
                                child: Text(
                                    "${userProvider.userdata?.username}"),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8.w, vertical: 0),
                                child: Text(
                                    "${userProvider.userdata?.firstname} ${userProvider.userdata?.lastname}"),
                              )
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.help,
                              color: colorScheme.primary,
                            ),
                            Icon(
                              Icons.notification_important,
                              color: colorScheme.onSurface,
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                  SpacedContainer(
                      child: Container(
                          padding: EdgeInsets.zero,
                          margin: EdgeInsets.zero,
                          width: double.maxFinite,
                          height: 100.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: <Color>[
                                  colorScheme.primary,
                                  colorScheme.primary,
                                  const Color(0xB25C4DE5),
                                  //const Color(0xB20C93AB),
                                  // Color(0xB643C036),
                                 // const Color(0xFF5EE862),
                                ]),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    EdgeInsets.all(12.w).copyWith(bottom: 4),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    AppText.caption(
                                      "Available Balance",
                                      color: colorScheme.onPrimary,
                                    ),
                                    AppText.caption(" Transaction details",
                                        color: colorScheme.onPrimary),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(0.w).copyWith(left: 10.w),
                                child: AppText.title(
                                  "\₦ ${userProvider.userdata?.availableBalance}",
                                  color: colorScheme.onPrimary,
                                  style: TextStyle(
                                      fontSize: 24.sp,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              SizedBox(height: 10.h,),
                              Row(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(0.w).copyWith(left: 10.w),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                                      decoration: BoxDecoration(
                                        color: Colors.purple.shade300.withOpacity(0.5),
                                        borderRadius: BorderRadius.circular(8)
                                      ),
                                      child: AppText.caption(
                                        "A/C no: ${userProvider.userdata?.accountNumber}",
                                        color: colorScheme.onPrimary,
                                        style: TextStyle(
                                            fontSize: 9.sp,
                                            color: Colors.white,
                                            fontWeight: FontWeight.normal),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 2.w,),
                                  Container(
                                      padding: EdgeInsets.all( 1.w),
                                      decoration: BoxDecoration(
                                          color: Colors.purple.shade300.withOpacity(0.5),
                                          borderRadius: BorderRadius.circular(4)
                                      ),
                                       child: GestureDetector(
                                         onTap: (){
                                           Clipboard.setData(ClipboardData(text: userProvider.userdata!.accountNumber));
                                           ScaffoldMessenger.of(context).showSnackBar(
                                             const SnackBar(content: Text('Copied to clipboard')),
                                           );
                                         },
                                           child: Icon(Icons.copy, size: 16,color: colorScheme.onPrimary.withOpacity(0.7),)))
                                ],
                              ),
                            ],
                          )))
                ],
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 60.h,
                    padding: EdgeInsets.all(10.w),
                    margin: EdgeInsets.all(8.w).copyWith(bottom: 0,top: 0),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      color: const Color(0xB25C4DE5),
                    ),
                    child: const Text(""),
                  ),
                ),
              ],
            ),
            Container(
              height: 120,
              padding: EdgeInsets.all(2.w),
              margin: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                color: Colors.white.withOpacity(0.9),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                //mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.0.w),
                        child: AppText.body("Services"),
                      )),
                  SizedBox(
                    height: 12.h,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildColumn(Icons.add_box_rounded, "add funds", onTap: () {
                          _showCustomDialog(context);
                        }),
                        _buildColumn(Icons.telegram, "transfer", onTap: () {
                          context.pushNamed("/transferPage");
                        }),
                        _buildColumn(Icons.upload, "recharge", onTap: () {
                          context.pushNamed("top_up");
                        }),
                        _buildColumn(Icons.widgets, "history", onTap: () {
                          context.pushNamed("/transaction_history_page");
                        }),
                        // _buildColumn(Icons.face, "profile", onTap: () {
                        //   context.pushNamed("upgrade_account_page");
                        // }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Container(
            //   padding: EdgeInsets.all(2.w),
            //   margin: EdgeInsets.all(8.w),
            //   decoration: const BoxDecoration(
            //     borderRadius: BorderRadius.all(Radius.circular(8)),
            //     color: Colors.white,
            //   ),
            //   child: Column(
            //     mainAxisSize: MainAxisSize.min,
            //     mainAxisAlignment: MainAxisAlignment.center,
            //     children: [
            //       Align(
            //           alignment: Alignment.topLeft,
            //           child: Padding(
            //             padding: EdgeInsets.symmetric(horizontal: 8.0.w),
            //             child: AppText.body("Mobile Top up "),
            //           )),
            //       SizedBox(
            //         height: 10.h,
            //       ),
            //       Container(
            //         margin: const EdgeInsets.only(bottom: 4, left: 12),
            //         child: Column(
            //           children: [
            //             Row(
            //               mainAxisAlignment: MainAxisAlignment.start,
            //               children: [
            //                 Container(
            //                   height: 40.w,
            //                   width: 62.w,
            //                   decoration: BoxDecoration(
            //                       color: colorScheme.primary,
            //                       borderRadius: const BorderRadius.only(
            //                           topLeft: Radius.circular(8),
            //                           bottomLeft: Radius.circular(8))),
            //                   child: Padding(
            //                     padding: const EdgeInsets.all(8.0),
            //                     child: Center(
            //                         child: AppText.caption(
            //                       "Ng +234",
            //                       color: Colors.grey.shade100,
            //                     )),
            //                   ),
            //                 ),
            //                 SizedBox(
            //                     width: 274.w,
            //                     height: 40.w,
            //                     child: CustomTextField(
            //                       fieldName: "phone",
            //                       // textStyle: TextStyle(height: 20),
            //                       controller: phoneController,
            //                       onChanged: (value) {
            //                         phoneNumberValue = value.toString();
            //                         _checkPhoneNumber();
            //                       },
            //                       cursorHeight: 18.h,
            //
            //                       decoration: InputDecoration(
            //                           fillColor: Colors.grey.shade100,
            //                           filled: true,
            //                           focusedBorder: OutlineInputBorder(
            //                             borderRadius: const BorderRadius.only(
            //                                 topRight: Radius.circular(8),
            //                                 bottomRight: Radius.circular(8)),
            //                             borderSide: BorderSide(
            //                                 color: Colors.grey.shade300),
            //                           ),
            //                           enabledBorder: OutlineInputBorder(
            //                             borderRadius: const BorderRadius.only(
            //                                 topRight: Radius.circular(8),
            //                                 bottomRight: Radius.circular(8)),
            //                             borderSide: BorderSide(
            //                                 color: Colors.grey.shade300),
            //                           )),
            //                     ))
            //               ],
            //             ),
            //             Column(
            //               children: [
            //                 SizedBox(
            //                   height: 10.h,
            //                 ),
            //                 FutureBuilder(
            //                     future: _checkPhoneNumber(),
            //                     builder: (context, snapshot) {
            //                       if (snapshot.connectionState ==
            //                           ConnectionState.waiting) {
            //                         return Center(
            //                           child: SizedBox(
            //                             width: 15.w,
            //                             height: 15.h,
            //                             child:
            //                                 const CircularProgressIndicator(
            //                               strokeWidth: 2,
            //                             ),
            //                           ),
            //                         );
            //                       } else if (snapshot.hasError) {
            //                         String errorMessage =
            //                             "an error occured while verifying number";
            //                         return Text(errorMessage);
            //                       } else if (snapshot.hasData) {
            //                         serviceProviderNetwork = snapshot.data;
            //
            //                         return Text(snapshot.data!);
            //                       } else {
            //                         return const SizedBox();
            //                       }
            //                     })
            //               ],
            //             ),
            //           ],
            //         ),
            //       ),
            //       !isData
            //           ? Container(
            //               margin: const EdgeInsets.only(bottom: 8, left: 12),
            //               child: Row(
            //                 mainAxisAlignment: MainAxisAlignment.start,
            //                 children: [
            //                   Container(
            //                     height: 40.w,
            //                     width: 62.w,
            //                     decoration: BoxDecoration(
            //                         color: colorScheme.onPrimary,
            //                         border: Border.all(
            //                             width: 1, color: colorScheme.primary),
            //                         borderRadius: const BorderRadius.only(
            //                             topLeft: Radius.circular(8),
            //                             bottomLeft: Radius.circular(8))),
            //                     child: Padding(
            //                       padding: const EdgeInsets.all(8.0),
            //                       child: Center(
            //                           child: AppText.caption(
            //                         "amount",
            //                       )),
            //                     ),
            //                   ),
            //                   SizedBox(
            //                       width: 274.w,
            //                       height: 40.w,
            //                       child: CustomTextField(
            //                         fieldName: "amount",
            //                         // textStyle: TextStyle(height: 20),
            //                         cursorHeight: 24.7.h,
            //
            //                         controller: amountController,
            //                         decoration: InputDecoration(
            //                             fillColor: Colors.grey.shade100,
            //                             filled: true,
            //                             focusedBorder: OutlineInputBorder(
            //                               borderRadius:
            //                                   const BorderRadius.only(
            //                                       topRight:
            //                                           Radius.circular(8),
            //                                       bottomRight:
            //                                           Radius.circular(8)),
            //                               borderSide: BorderSide(
            //                                   color: Colors.grey.shade300),
            //                             ),
            //                             enabledBorder: OutlineInputBorder(
            //                               borderRadius:
            //                                   const BorderRadius.only(
            //                                       topRight:
            //                                           Radius.circular(8),
            //                                       bottomRight:
            //                                           Radius.circular(8)),
            //                               borderSide: BorderSide(
            //                                   color: Colors.grey.shade300),
            //                             )),
            //                       ))
            //                 ],
            //               ),
            //             )
            //           : const SizedBox(),
            //       ShaderMask(
            //         shaderCallback: (Rect bounds) {
            //           return LinearGradient(
            //               begin: Alignment.topLeft,
            //               end: Alignment.bottomRight,
            //               colors: <Color>[
            //                 colorScheme.primary,
            //                 const Color(0xB20C93AB),
            //                 // Color(0xB643C036),
            //                 const Color(0xFF5EE862),
            //               ]).createShader(bounds);
            //         },
            //         child: Padding(
            //           padding: const EdgeInsets.all(12.0).copyWith(top: 8,bottom: 8),
            //           child: CustomDropdown<String>(
            //             items: const ['airtime', 'data', 'recharge'],
            //             initialValue: "airtime",
            //             onChanged: (newValue) {
            //               if (newValue == 'data') {
            //                 _getListOfDataBundles();
            //                 setState(() {
            //                   isData = true;
            //                 });
            //               } else {
            //                 setState(() {
            //                   isData = false;
            //                 });
            //               }
            //             },
            //             itemBuilder: (item) => Padding(
            //               padding: const EdgeInsets.all(8.0),
            //               child: Text(item),
            //             ),
            //             selectedItemBuilder: (item) => Text(item),
            //           ),
            //         ),
            //       ),
            //       AnimatedSwitcher(
            //         duration: const Duration(
            //             milliseconds: 5000), // Duration of the transition
            //         child: FutureBuilder(
            //             key: const ValueKey("m"),
            //             future: _dataBundleList,
            //             builder: (context, snapshot) {
            //               if (snapshot.hasError) {
            //                 final error = snapshot.error;
            //                 if (error is DioException) {
            //                   if (error.type ==
            //                       DioExceptionType.connectionError) {
            //                     return const Text("no internet");
            //                   } else if (snapshot.error ==
            //                       DioExceptionType.connectionTimeout) {
            //                     return const Text("poor connection");
            //                   }
            //                   return Text(
            //                       "errox ${snapshot.error.runtimeType}");
            //                 }
            //               } else if (snapshot.hasData &&
            //                   phoneIsValid &&
            //                   isData) {
            //                 return ShaderMask(
            //                   shaderCallback: (Rect bounds) {
            //                     return LinearGradient(
            //                         begin: Alignment.topLeft,
            //                         end: Alignment.bottomRight,
            //                         colors: <Color>[
            //                           colorScheme.primary,
            //                           const Color(0xB20C93AB),
            //                           // Color(0xB643C036),
            //                           const Color(0xFF5EE862),
            //                         ]).createShader(bounds);
            //                   },
            //                   child: Padding(
            //                     padding: const EdgeInsets.all(12.0),
            //                     child: CustomDropdown<DataBundle>(
            //                       items: snapshot.data!.dataBundles,
            //                       initialValue: snapshot.data?.dataBundles[0],
            //                       onChanged: (newValue) {
            //                         setState(() {
            //                           dataBundle = newValue;
            //                           amountController.value =
            //                               TextEditingValue(
            //                                   text: newValue?.amount ?? '');
            //                         });
            //                       },
            //                       itemBuilder: (item) => Padding(
            //                         padding: const EdgeInsets.all(8.0),
            //                         child: ListTile(
            //                           tileColor: Colors.white,
            //                           leading: const Icon(Icons.data_usage,
            //                               color: Colors.blue),
            //                           title: Row(
            //                             children: [
            //                               Text(
            //                                 item.dataBundle,
            //                                 style: const TextStyle(
            //                                     fontWeight: FontWeight.bold),
            //                               ),
            //                               SizedBox(
            //                                 width: 20.w,
            //                               ),
            //                               Text('Amount:   ₦${item.amount} '),
            //                             ],
            //                           ),
            //                           subtitle: Text(
            //                               'Validity:     ${item.validity}'),
            //                           trailing: const Icon(
            //                               Icons.arrow_forward_ios,
            //                               color: Colors.blue),
            //                         ),
            //                       ),
            //                       selectedItemBuilder: (item) => Text(
            //                           "${item.dataBundle}      ₦${item.amount}"),
            //                     ),
            //                   ),
            //                 );
            //               }
            //               return const SizedBox();
            //             }),
            //       ),
            //       Padding(
            //         padding: const EdgeInsets.all(8.0),
            //         child: CustomButton(
            //             height: 40.h,
            //             text: "Top up",
            //             width: double.maxFinite,
            //             onPressed: () {
            //               TopUpPayload topup = TopUpPayload(
            //                 phoneNumber: phoneNumberValue!,
            //                 amount: amountController.text,
            //                 network: serviceProviderNetwork!,
            //                 productId:
            //                     isData ? dataBundle?.productId ?? "" : "",
            //               );
            //               _showBottomSheet(context, topup, onTap: () {
            //                 print(dataBundle);
            //                 print(topup.toJson());
            //               });
            //             }),
            //       )
            //     ],
            //   ),
            // ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(0.w),
                    margin: EdgeInsets.all(10.w).copyWith(bottom: 0,left: 20.w),
                    // decoration: BoxDecoration(
                    //   borderRadius: const BorderRadius.all(Radius.circular(8)),
                    //   color: Colors.white.withOpacity(0.9),
                    // ),
                    child: AppText.body("History",style: TextStyle(fontSize: 14.sp),),
                  ),
                ),
              ],
            ),
            Container(
              height: 300.h,
              padding: EdgeInsets.all(2.w),
              margin: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                color: Colors.white.withOpacity(0.9),
              ),
             //width: 400.w,
              child: SingleChildScrollView(
                child: FutureBuilder(
                  future: userProvider.fetchTransactionHistory(context),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return SizedBox(
                        height: 300.h,
                        child: Scaffold(
                          backgroundColor: colorScheme.onPrimary,
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
                        ),
                      );
                    } else if (snapshot.hasData && snapshot.data != null && snapshot.data!.isNotEmpty) {
                      // Display the transaction history
                      return SizedBox( height: 300.h,
                        child: Scaffold(
                          backgroundColor: colorScheme.onPrimary,
                          body: Column(
                            children: [
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
                                          margin:  EdgeInsets.symmetric(vertical: 4.h, horizontal: 10.h),
                                          child: Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      AppText.body(
                                                        snapshot.data![index].accountName,
                                                        style:  TextStyle(fontWeight: FontWeight.bold, fontSize: 10.sp, color: const Color(0xB25C4DE5)),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                      SizedBox(height: 2.h),
                                                      Row(
                                                        children: [
                                                          AppText.caption('Date: ',
                                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: const Color(0xB25C4DE5),
                                                            ),
                                                          ),
                                                          AppText.caption(snapshot.data![index].dateCreated,
                                                            style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
                                                          ),
                                                        ],
                                                      ),
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
                        ),
                      );
                    } else {
                      // No data or empty list
                      return const Center(child: Text("No transactions found."));
                    }
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
  void _showCustomDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        UserServiceProvider userprovider = Provider.of<UserServiceProvider>(context,listen: false);
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Container(
            height: 200.0.h,
            width: 180.0.w,
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                AppText.display("FUND ACCOUNT"),
                SizedBox(height: 10.0.h),
                AppText.body("${userProvider.userdata?.firstname.toUpperCase()} ${userProvider.userdata?.lastname.toUpperCase()}"),
                SizedBox(height: 4.0.h),
                AppText.title("9 Payment service bank"),
                AppText.title("${userProvider.userdata?.accountNumber}"),

                TextButton(
                  onPressed:() => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  Future<DataBundleList?>? _getListOfDataBundles() async {
    try {
      UserServiceProvider userProvider =
          Provider.of<UserServiceProvider>(context, listen: false);
      if (!phoneIsValid) return null;
      print("in getlistdatabundle");

      setState(() {
        _dataBundleList = userProvider.getDataPlans(context, phoneNumberValue!);
      });
    } catch (e) {
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionError) {
          rethrow;
        } else if (e.type == DioExceptionType.connectionTimeout) {
          rethrow;
        }
      }
    }
  }

  Future<String?> _checkPhoneNumber() async {
    // Retrieve and trim the phone number
    String? data;
    String? phoneNumber = phoneController.value.text.trim();

    if (phoneNumber.isEmpty) return null;

    setState(() {
      phoneIsValid = false;
    });

    // Ensure the phone number has the correct length
    if (phoneNumber.length == 10 && !phoneNumber.startsWith('0')) {
      phoneNumber = '0$phoneNumber';
    }

    if (phoneNumber.length == 11 && phoneNumber.startsWith('0')) {
      setState(() {
        phoneIsValid = true;
      });

      if (phoneIsValid) {
        setState(() {
          phoneNumberValue = phoneNumber;
        });
        try {
          String? status =
              await userProvider.getNetworkProvider(context, phoneNumber);

          // Decode JSON string to a Map oh
          Map<String, dynamic> jsonResponse = jsonDecode(status!);

          // Extract data
          data = jsonResponse['data']['network'];

          return data;
        } catch (e) {
          if (e is DioException) {
            if (e.type == DioExceptionType.connectionError) {
              return "No internet connection";
            } else if (e.type == DioExceptionType.connectionTimeout) {
              return "poor connection";
            } else if (e.type == DioExceptionType.receiveTimeout) {
              return "poor connection";
            } else if (e.type == DioExceptionType.sendTimeout) {
              return "poor connection";
            }
          }
          return "invalid number";
        }
      }
    } else {
      setState(() {
        phoneIsValid = false;
      });
      return null;
    }
    return null;
  }
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

Widget _buildColumn(IconData icon, String text, {void Function()? onTap}) {
  return InkWell(
    onTap: onTap,
    child: Column(
      children: [
        Container(
         // width: 40.w,
          decoration: BoxDecoration(
              color: const Color(0xB25C4DE5),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                    blurRadius: 2,
                    color: Colors.grey.shade200,
                    spreadRadius: 1.7,
                    offset: const Offset(1, 3))
              ]),
          child: Padding(
            padding: const EdgeInsets.all(4.0).copyWith(left: 8, right: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: 28.sp,
                ),
                SizedBox(height: 4.h), // Add some space between icon and text
                // AppText.caption(
                //   text,
                //   style:
                //       const TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
                // ),
              ],
            ),
          ),
        ),
        AppText.caption(
          text,
          style:
              const TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
        ),
      ],
    ),
  );
}

void _showBottomSheet(BuildContext context, TopUpPayload topUpPayload,
    {void Function()? onTap}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.1,
      maxChildSize: 0.65,
      expand: false,
      builder: (_, controller) => BottomSheetContent(topUpPayload,
          controller: controller, onTap: onTap),
    ),
  );
}

class BottomSheetContent extends StatelessWidget {
  final ScrollController controller;
  final Function()? onTap;
  TopUpPayload topUpPayload;
  BottomSheetContent(this.topUpPayload,
      {super.key, required this.controller, this.onTap});
  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: controller,
      children: [
        SizedBox(height: 10.h),
        Center(
          child: Container(
            width: 40.h,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        SizedBox(height: 10.h),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 20.w),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SpacedContainer(
            margin: EdgeInsets.all(12.sp),
            child: Column(
              children: [
                Center(
                  child: AppText.headline("\₦${topUpPayload.amount}"),
                ),
                SizedBox(
                  height: 16.h,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppText.body(
                        "Phone number",
                        color: Colors.grey.shade500,
                      ),
                      AppText.body(topUpPayload.phoneNumber),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.0.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppText.body(
                        "Network's detail",
                        color: Colors.grey.shade500,
                      ),
                      AppText.body(topUpPayload.network),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppText.body(
                        "Amount",
                        color: Colors.grey.shade500,
                      ),
                      AppText.body(topUpPayload.amount),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20.h,
                ),
                Container(
                  decoration: BoxDecoration(
                      color: const Color(0xffdeffe6),
                      borderRadius: BorderRadius.circular(8)),
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 16.w),
                  width: double.maxFinite,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        Icons.wallet_sharp,
                        color: colorScheme.onSecondary,
                      ),
                      //  SizedBox(width: 30.w,),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText.caption("Account to be Debited"),
                          AppText.caption("Azuma nioman"),
                        ],
                      ),
                      // SizedBox(width: 30.w,),
                      Row(
                        children: [
                          AppText.caption(
                            "Top up ",
                            style: const TextStyle(fontSize: 12),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios_outlined,
                            size: 12,
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 40.h,
                ),
                CustomButton(
                  onPressed: onTap,
                  text: "SEND",
                  size: ButtonSize.large,
                  width: double.maxFinite,
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
