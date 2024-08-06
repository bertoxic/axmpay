import 'dart:math';

import 'package:fintech_app/constants/app_colors.dart';
import 'package:fintech_app/main.dart';
import 'package:fintech_app/models/recepients_model.dart';
import 'package:fintech_app/providers/user_service_provider.dart';
import 'package:fintech_app/ui/%20widgets/custom_buttons.dart';
import 'package:fintech_app/ui/%20widgets/custom_container.dart';
import 'package:fintech_app/ui/%20widgets/custom_pop_up.dart';
import 'package:fintech_app/ui/%20widgets/custom_responsive_sizes/responsive_size.dart';
import 'package:fintech_app/ui/%20widgets/custom_text/custom_apptext.dart';
import 'package:fintech_app/ui/%20widgets/custom_textfield.dart';
import 'package:fintech_app/utils/form_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../ widgets/transaction_butttom_sheet.dart';
import '../../models/user_model.dart';
import '../../utils/color_generator.dart';

class TransferScreen extends StatefulWidget {
  TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

final _transactionFormKey = GlobalKey<FormState>();

class _TransferScreenState extends State<TransferScreen> {
  final TextEditingController _bankSelectorcontroller = TextEditingController();
  final TextEditingController _accountNumberController =
      TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _remarkController = TextEditingController();
  List<Bank> filter_search = [];
  List<Bank> total_items = [];
  late Bank? selectedBank;
  late bool accountNumberSet = false;
  RecipientDetails? recipientDetails;
  String? _receiverAccountNumber;
  int? _transactionAmount;
  String? _transactionRemark;
  UserData? userData;
  AccountRequestDetails accountRequestDetails = AccountRequestDetails();

  @override
  void initState() {
    super.initState();
    final userProvider =
        Provider.of<UserServiceProvider>(context, listen: false);
    userProvider.getBankNames(context);
    _bankSelectorcontroller.addListener(_filterItems);
    _accountNumberController.addListener(_accountNumberCheck);
    if (userProvider.bankListResponse?.bankList != null) {
      total_items = userProvider.bankListResponse!.bankList;
    }
    filter_search = total_items;
    selectedBank = total_items[21];
  }

  @override
  void dispose() {
    _bankSelectorcontroller.removeListener(_filterItems);
    _bankSelectorcontroller.dispose();
    _accountNumberController.dispose();
    _amountController.dispose();
    super.dispose();
  }
  String? bankValidator(String? value) {
    if (selectedBank == null || recipientDetails ==null) {
      return 'Please select a valid bank';
    }
    return null;
  }
  void _filterItems() {
    final query = _bankSelectorcontroller.value.text.toLowerCase();
    setState(() {
      filter_search = total_items.where((item) {
        return item.bankName!.toLowerCase()!.contains(query);
      }).toList();
    });
  }

  void _accountNumberCheck() {
    final query = _accountNumberController.value.text;
    if (query.length == 10 && selectedBank != null) {
      setState(() {
        accountNumberSet = true;
        _receiverAccountNumber = query;
        accountRequestDetails.accountNumber = _receiverAccountNumber;
        accountRequestDetails.bankCode = selectedBank!.bankCode.toString();
      });
    } else {
      setState(() {
        accountNumberSet = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userp = Provider.of<UserServiceProvider>(context);
    total_items = userp.bankListResponse?.bankList ?? [];
    accountRequestDetails.senderAccountNumber =
        userp.userdata?.accountNumber.toString();
    userData = userp.userdata;
    return Form(
      key: _transactionFormKey,
      child: Scaffold(

        appBar: AppBar(),
        body: SpacedContainer(
          containerColor: Colors.grey.shade200,
          margin: const EdgeInsets.all(8),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0.sp),
                  child: Row(
                    children: [
                      Padding(
                          padding: EdgeInsets.all(8.sp),
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.grey.shade300,
                            child: const Icon(Icons.person),
                          )),
                      Consumer<UserServiceProvider>(
                          builder: (context, userServiceProvider, child) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText.caption(
                                "${userServiceProvider.userdata?.lastname}"),
                            AppText.body(
                                "${userServiceProvider.userdata?.accountNumber}")
                          ],
                        );
                      })
                    ],
                  ),
                ),
                SpacedContainer(
                    //height: double.maxFinite,
                    containerColor: colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                    padding: EdgeInsets.all(8.sp),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            AppText.subtitle("Select Bank"),
                          ],
                        ),
                        Column(
                          children: [
                            GestureDetector(
                              onTap: () async {
                                Bank? result = await ScrollablePopup.show(
                                    context: context,
                                    isDismissible: true,
                                    child: StatefulBuilder(
                                      builder: (BuildContext context,
                                          StateSetter setState) {
                                        return SizedBox(
                                          width: 340.h,
                                          height: 800.h,
                                          child: Consumer<UserServiceProvider>(
                                            builder: (context,
                                                userServiceProvider, child) {
                                              return Column(
                                                children: [
                                                  SizedBox(
                                                      height: 36.h,
                                                      width: 240.w,
                                                      child: CustomTextField(
                                                        controller:
                                                            _bankSelectorcontroller,
                                                        onChanged: (value) {
                                                          setState(() {
                                                            _filterItems();
                                                            _accountNumberCheck();
                                                          });
                                                        },
                                                        fieldName: "fieldName",
                                                        hintText: "search bank",
                                                      )),
                                                  SizedBox(
                                                    width: 340.h,
                                                    height: 720.h,
                                                    child: ListView.builder(
                                                      itemCount:
                                                          filter_search.length,
                                                      itemBuilder:
                                                          (BuildContext context,
                                                              int index) {
                                                        final item =
                                                            filter_search[
                                                                index];
                                                        Color itemColor =
                                                            getRandomColor();
                                                        return ListTile(
                                                          onTap: () {
                                                            var selectedIndex =
                                                                filter_search.indexWhere(
                                                                    (element) =>
                                                                        element
                                                                            .bankName ==
                                                                        item.bankName);
                                                            setState(() {
                                                              selectedBank =
                                                                  filter_search[
                                                                      selectedIndex];
                                                            });
                                                            _accountNumberCheck();
                                                            Navigator.pop(
                                                                context,
                                                                selectedBank);
                                                          },
                                                          leading: Container(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(
                                                                          8.sp),
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            100),
                                                                color: itemColor
                                                                    .withOpacity(
                                                                        0.2),
                                                              ),
                                                              child: Icon(
                                                                Icons
                                                                    .home_work_outlined,
                                                                size: 12.sp,
                                                              )),
                                                          iconColor: itemColor,
                                                          title: AppText.caption(
                                                              item?.bankName ??
                                                                  ""),
                                                          // Add more widgets (e.g., subtitle, trailing icon) as needed
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          ),
                                        );
                                      },
                                    ));
                                if (result != null) {
                                  setState(() {
                                    selectedBank = result;
                                  });
                                }
                              },
                              child: Consumer<UserServiceProvider>(builder:
                                  (context, userServiceProvider, child) {
                                return Container(
                                  width: double.maxFinite,
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                          color: Colors.grey.shade200,
                                          width: 2)),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                        width: 280.w,
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: SingleChildScrollView(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                physics: const ScrollPhysics(),
                                                child: AppText.caption(
                                                    selectedBank?.bankName ??
                                                        "loading ..."),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(
                                        Icons.arrow_drop_down,
                                        color: Colors.grey,
                                      )
                                    ],
                                  ),
                                );
                              }),
                            ),
                            SizedBox(
                              height: 16.h,
                            ),
                            Container(
                              width: double.maxFinite,
                              decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(8)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppText.body("Account Number"),
                                  SizedBox(
                                    height: 8.sp,
                                  ),
                                  SizedBox(
                                    child: CustomTextField(
                                        validator: (value) =>
                                        bankValidator(value),
                                        keyboardType: TextInputType.phone,
                                        controller: _accountNumberController,
                                        onChanged: (value) {
                                          _accountNumberController;
                                        },
                                        hintText: "Receipient's account number",
                                        fieldName: "accountNumber"),
                                  ),
                                  accountNumberSet
                                      ? Column(
                                          children: [
                                            SizedBox(
                                              height: 10.h,
                                            ),
                                            Consumer<UserServiceProvider>(
                                                builder: (context,
                                                    userServiceProvider,
                                                    child) {
                                              //accountRequestDetails.senderAccountNumber =  userServiceProvider.userdata?.accountNumber.toString();
                                              return FutureBuilder(
                                                  future: userServiceProvider
                                                      .getReceiversAccountDetails(
                                                          accountRequestDetails),
                                                  builder: (context, snapshot) {
                                                    recipientDetails =
                                                        snapshot.data;
                                                    if (snapshot
                                                            .connectionState ==
                                                        ConnectionState
                                                            .waiting) {
                                                      return const Center(
                                                          child: SizedBox(
                                                              height: 20,
                                                              width: 15,
                                                              child:
                                                                  CircularProgressIndicator(
                                                                strokeWidth: 2,
                                                              )));
                                                    } else if (snapshot
                                                        .hasError) {
                                                      String errorMessage =
                                                          'An unexpected error occurred';
                                                      if (snapshot.error
                                                          is Exception) {
                                                        errorMessage = (snapshot
                                                                    .error
                                                                as Exception)
                                                            .toString()
                                                            .replaceFirst(
                                                                'Exception: ',
                                                                '');
                                                      }
                                                      return Center(
                                                          child: Text(
                                                        ' $errorMessage',
                                                        style: const TextStyle(
                                                            color: Colors.red),
                                                      ));
                                                    } else {
                                                      return Center(
                                                          child: Text(
                                                              'Receiver: ${snapshot.data?.account?.name}'));
                                                    }
                                                  });
                                            })
                                          ],
                                        )
                                      : const SizedBox(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    )),
                SizedBox(
                  height: 20.h,
                ),
                Container(
                  padding: EdgeInsets.all(12.sp),
                  decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(8)),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          AppText.body("Amount"),
                          SizedBox(
                            width: 12.sp,
                          ),
                          Container(
                            decoration: BoxDecoration(
                                color: Colors.indigo.shade200,
                                borderRadius: BorderRadius.circular(16)),
                            child: SpacedContainer(
                              padding: EdgeInsets.all(2.sp),
                              child: AppText.caption(
                                "transaction amount",
                                style: TextStyle(fontSize: 9.sp),
                                color: Colors.indigoAccent.shade100,
                              ),
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 8.sp,
                      ),
                      SizedBox(
                        child: CustomTextField(
                          validator: (value) => FormValidator.validate(
                              value, ValidatorType.digits,
                              fieldName: "transaction_amount"),
                          controller: _amountController,
                          hintText: "  100 - 50 000 000",
                          prefix: AppText.body("\$"),
                          fieldName: "transaction_amount",
                          onChanged: (value) {
                            setState(() {
                              _transactionAmount =
                                  int.parse(_amountController.value.text);
                            });
                          },
                        ),
                      ),
                      SizedBox(
                        height: 20.h,
                      ),
                      Container(
                        width: double.maxFinite,
                        decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(8)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText.body("Remark"),
                            SizedBox(
                              height: 8.sp,
                            ),
                            SizedBox(
                              child: CustomTextField(
                                validator: (value) => FormValidator.validate(
                                    value, ValidatorType.remarks,
                                    fieldName: "remark"),
                                controller: _remarkController,
                                hintText: "write anything here",
                                fieldName: "remark",
                                onChanged: (value) {
                                  setState(() {
                                    _transactionRemark =
                                        _remarkController.value.text;
                                  });
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20.h,
                ),
                CustomButton(
                  text: "Confirm",
                  type: ButtonType.elevated,
                  size: ButtonSize.large,
                  width: 220.w,
                  onPressed: () {
                    if (_transactionFormKey.currentState!.validate()) {
                      TransactionModel tranSactionModel = TransactionModel(
                          amount: _transactionAmount!,
                          recipientAccount: recipientDetails?.account?.number,
                          recipientAccountName: recipientDetails?.account?.name,
                          recipientBankCode: recipientDetails?.account?.bank,
                          recipientBankName: selectedBank?.bankName,
                          senderAccountNumber: userp.userdata?.accountNumber,
                          senderAccountName: userp.userdata?.firstname,
                          narration: _transactionRemark!);
                      //  userp.makeBankTransfer(tranSactionModel);
                      _showBottomSheet(context, tranSactionModel);
                    }
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildAccountDetails(int accountNumber, String accountName) {
  return Container(
    decoration: const BoxDecoration(
      color: Colors.grey,
    ),
    child: Column(
      children: [
        Text(
          accountNumber.toString(),
          style: TextStyle(color: colorScheme.primary),
        ),
        Text("$accountName"),
      ],
    ),
  );

}

void _showBottomSheet(BuildContext context, TransactionModel transactionModel) {
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
      builder: (_, controller) {
        return BottomTransactionConfirmSheetContent(
          controller: controller,
          transactionModel: transactionModel, // corrected here
        );
      },
    ),
  );
}




