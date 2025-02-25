import 'package:AXMPAY/constants/app_colors.dart';
import 'package:AXMPAY/main.dart';
import 'package:AXMPAY/models/ResponseModel.dart';
import 'package:AXMPAY/models/recepients_model.dart';
import 'package:AXMPAY/providers/user_service_provider.dart';
import 'package:AXMPAY/ui/screens/passcode_screen/passcode_screen.dart';
import 'package:AXMPAY/ui/screens/transaction_screen/success_receipt_screen.dart';
import 'package:AXMPAY/ui/screens/transaction_screen/transaction_receipt.dart';
import 'package:AXMPAY/ui/widgets/custom_buttons.dart';
import 'package:AXMPAY/ui/widgets/custom_container.dart';
import 'package:AXMPAY/ui/widgets/custom_pop_up.dart';
import 'package:AXMPAY/ui/widgets/custom_responsive_sizes/responsive_size.dart';
import 'package:AXMPAY/ui/widgets/custom_text/custom_apptext.dart';
import 'package:AXMPAY/ui/widgets/custom_textfield.dart';
import 'package:AXMPAY/utils/form_validator.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../models/transaction_model.dart';
import '../../../models/user_model.dart';
import '../../../providers/Custom_Widget_State_Provider.dart';
import '../../../utils/color_generator.dart';
import '../../widgets/custom_dialog.dart';
import '../../widgets/transaction_butttom_sheet.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final _transactionFormKey = GlobalKey<FormState>();
  final TextEditingController _bankSelectorController = TextEditingController();
  final TextEditingController _accountNumberController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _remarkController = TextEditingController();
  List<Bank> filterSearch = [];
  List<Bank> totalItems = [];
  late Bank? selectedBank;
  late bool accountNumberSet = false;
  RecipientDetails? recipientDetails;
  String? _receiverAccountNumber;
  int? _transactionAmount;
  String? _transactionRemark;
  UserData? userData;
  AccountRequestDetails accountRequestDetails = AccountRequestDetails();

  Future<RecipientDetails?>? _recipientDetailsFuture;
  @override
  void initState() {
    super.initState();
    final userProvider =
    Provider.of<UserServiceProvider>(context, listen: false);
    userProvider.getBankNames(context);
    _bankSelectorController.addListener(_filterItems);
    _accountNumberController.addListener(_accountNumberCheck);
    if (userProvider.bankListResponse?.bankList != null) {
      totalItems = userProvider.bankListResponse!.bankList;
    }
    filterSearch = totalItems;
    selectedBank = totalItems[2];
  }

  @override
  void dispose() {
    _bankSelectorController.removeListener(_filterItems);
    _bankSelectorController.dispose();
    _accountNumberController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _updateRecipientDetailsFuture() {
    if (accountNumberSet && selectedBank != null) {
      final userServiceProvider = Provider.of<UserServiceProvider>(context, listen: false);
      _recipientDetailsFuture = userServiceProvider.getReceiversAccountDetails( context,accountRequestDetails);
    } else {
      _recipientDetailsFuture = null;
    }
  }
  String? bankValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select a bank';
    }
    return null;
  }

  bool isRecipientValid() {
    return selectedBank != null && recipientDetails != null;
  }
  void _filterItems() {
    final query = _bankSelectorController.value.text.toLowerCase();
    setState(() {
      filterSearch = totalItems.where((item) {
        return item.bankName!.toLowerCase().contains(query);
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
        _updateRecipientDetailsFuture();
      });
    } else {
      setState(() {
        accountNumberSet = false;
        _recipientDetailsFuture = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userp = Provider.of<UserServiceProvider>(context);
    totalItems = userp.bankListResponse?.bankList ?? [];
    accountRequestDetails.senderAccountNumber = userp.userdata?.accountNumber.toString();
    userData = userp.userdata;

    return Form(
      key: _transactionFormKey,
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: AppText.subtitle('Send Money', color: colorScheme.primary),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16.h),
                _buildUserInfo(userp),
                SizedBox(height: 24.h),
                _buildTransferForm(),
                SizedBox(height: 32.h),
                _buildConfirmButton(),
                SizedBox(height: 120.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransferForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBankSelection(),
        SizedBox(height: 20.h),
        _buildAccountNumberSection(),
        SizedBox(height: 20.h),
        _buildAmountSection(),
        SizedBox(height: 20.h),
        _buildRemarkSection(),
      ],
    );
  }

  Widget _buildBankSelection() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText.body("Select Bank", color: Colors.grey.shade700),
            SizedBox(height: 12.h),
            GestureDetector(
              onTap: () async {
                Bank? result = await ScrollablePopup.show(
                  context: context,
                  isDismissible: true,
                  child: StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                      return _buildBankSelectionPopup();
                    },
                  ), widgetStateProvider: Provider.of<CustomWidgetStateProvider>(context,listen: false)
                );
                if (result != null) {
                  setState(() {
                    selectedBank = result;
                  });
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.account_balance, color: colorScheme.primary, size: 20.sp),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: AppText.body(
                        selectedBank?.bankName ?? "Select a Bank...",
                        color: selectedBank != null ? Colors.black87 : Colors.grey,
                      ),
                    ),
                    Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountNumberSection() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText.body("Account Number", color: Colors.grey.shade700),
            SizedBox(height: 12.h),
            CustomTextField(
              validator: (value) => bankValidator(value),
              keyboardType: TextInputType.phone,
              controller: _accountNumberController,
              onChanged: (value) => _accountNumberController,
              hintText: "Enter recipient's account number",
              fieldName: "accountNumber",
              prefixIcon: Icon(Icons.account_circle_outlined, color: colorScheme.primary),
            ),
            if (accountNumberSet) ...[
              SizedBox(height: 16.h),
              _buildRecipientDetails(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAmountSection() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AppText.body("Amount", color: Colors.grey.shade700),
                SizedBox(width: 8.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: AppText.caption(
                    "₦100 - ₦50,000,000",
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            CustomTextField(
              validator: (value) => FormValidator.validate(
                value,
                ValidatorType.digits,
                fieldName: "transaction_amount",
              ),
              controller: _amountController,
              hintText: "Enter amount",
              prefix: AppText.body("₦", color: colorScheme.primary),
              fieldName: "transaction_amount",
              onChanged: (value) {
                setState(() {
                  _transactionAmount = int.tryParse(_amountController.value.text);
                });
              },
              prefixIcon: Icon(Icons.account_balance_wallet_outlined, color: colorScheme.primary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRemarkSection() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText.body("Remark", color: Colors.grey.shade700),
            SizedBox(height: 12.h),
            CustomTextField(
              validator: (value) => FormValidator.validate(
                value,
                ValidatorType.remarks,
                fieldName: "remark",
              ),
              controller: _remarkController,
              hintText: "Add a note",
              fieldName: "remark",
              onChanged: (value) {
                setState(() {
                  _transactionRemark = _remarkController.value.text;
                });
              },
              prefixIcon: Icon(Icons.note_alt_outlined, color: colorScheme.primary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipientDetails() {
    if (_recipientDetailsFuture == null) {
      return const SizedBox();
    }

    return FutureBuilder(
      future: _recipientDetailsFuture,
      builder: (context, snapshot) {
        recipientDetails = snapshot.data;
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: SizedBox(
              height: 20.h,
              width: 20.w,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colorScheme.primary,
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              'Unable to verify account',
              style: TextStyle(color: Colors.red.shade400),
            ),
          );
        } else if (snapshot.hasData) {
          return Container(
            padding: EdgeInsets.all(12.sp),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: colorScheme.primary, size: 20.sp),
                SizedBox(width: 8.w),
                Expanded(
                  child: AppText.body(
                    'Account verified: ${snapshot.data?.account?.name}',
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildConfirmButton() {
    return Center(
      child: CustomButton(
        text: "Confirm Transfer",
        type: ButtonType.elevated,
        size: ButtonSize.large,
        width: 280.w,
        onPressed: () {
          if (_transactionFormKey.currentState!.validate() &&
              accountNumberSet &&
              isRecipientValid()) {
            TransactionModel transactionModel = TransactionModel(
              amount: _transactionAmount!,
              recipientAccount: recipientDetails?.account?.number,
              recipientAccountName: recipientDetails?.account?.name,
              recipientBankCode: recipientDetails?.account?.bank,
              recipientBankName: selectedBank?.bankName,
              senderAccountNumber: userData?.accountNumber,
              senderAccountName: "${userData?.username}",
              narration: _transactionRemark!,
            );
            _showBottomSheet(context, transactionModel);
          } else {
            CustomPopup.show(
              type: PopupType.error,
              context: context,
              title: 'Incomplete Details',
              message: "Please ensure all fields are filled correctly",
            );
          }
        },
      ),
    );
  }

  Widget _buildUserInfo(UserServiceProvider userp) {
    return Container(
      padding: EdgeInsets.all(20.sp),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            colorScheme.primary.withOpacity(0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.sp),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.account_circle,
              color: Colors.white,
              size: 32.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.subtitle(
                  "${userp.userdata?.firstname} ${userp.userdata?.lastname}",
                  color: Colors.white,
                ),
                SizedBox(height: 4.h),
                AppText.body(
                  "Account: ${userp.userdata?.accountNumber}",
                  color: Colors.white.withOpacity(0.8),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankSelectionPopup() {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return SizedBox(
          width: 340.h,
          height: 800.h,
          child: Consumer<UserServiceProvider>(
            builder: (context, userServiceProvider, child) {
              return Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(16.sp),
                    child: CustomTextField(
                      controller: _bankSelectorController,
                      onChanged: (value) {
                        setState(() {
                          filterSearch = totalItems.where((item) {
                            return item.bankName!.toLowerCase().contains(value.toLowerCase());
                          }).toList();
                        });
                      },
                      fieldName: "search",
                      hintText: "Search bank",
                      prefixIcon: Icon(Icons.search, color: colorScheme.primary),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filterSearch.length,
                      itemBuilder: (BuildContext context, int index) {
                        final item = filterSearch[index];
                        Color itemColor = getRandomColor();
                        return ListTile(
                          onTap: () {
                            _bankSelectorController.text = item.bankName ?? "";
                            selectedBank = item;
                            _accountNumberCheck();
                            Navigator.pop(context, item);
                          },
                          leading: Container(
                            padding: EdgeInsets.all(8.sp),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: itemColor.withOpacity(0.1),
                            ),
                            child: Icon(
                              Icons.account_balance,
                              size: 20.sp,
                              color: itemColor,
                            ),
                          ),
                          title: AppText.body(
                            item.bankName ?? "",
                            color: Colors.black87,
                          ),
                          subtitle: AppText.caption(
                            "Tap to select",
                            color: Colors.grey.shade600,
                          ),
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
    );
  }

  void _showBottomSheet(BuildContext context, TransactionModel transactionModel) {
    UserServiceProvider userp = Provider.of<UserServiceProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.1,
        maxChildSize: 0.65,
        expand: false,
        builder: (_, controller) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: BottomTransactionConfirmSheetContent(
              onTap: () async {
                bool? correctPass = await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
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

                if (correctPass != null) {
                  if (correctPass) {
                    ResponseResult? resp;
                    if (!mounted) return;
                    resp = await userp.makeBankTransfer(context, transactionModel);

                    if (!mounted) return;

                    if (resp?.status == ResponseStatus.failed) {
                      CustomPopup.show(
                        type: PopupType.error,
                        context: context,
                        title: resp?.status.toString() ?? "Error",
                        message: "${resp?.message}",
                      );
                    } else if (resp?.status == ResponseStatus.success) {
                      ReceiptData? receiptData = ReceiptData.fromJson(resp!.data!);
                      resetFields();
                      context.pushNamed(
                        'top_up_success',
                        extra: receiptData,
                      );
                    }
                  } else {
                    if (!mounted) return;
                    CustomPopup.show(
                      type: PopupType.error,
                      context: context,
                      title: "Incorrect Passcode",
                      message: "Please ensure you enter the correct passcode",
                    );
                  }
                }
              },
              controller: controller,
              transactionModel: transactionModel,
            ),
          );
        },
      ),
    );
  }

  void resetFields() {
    setState(() {
      _transactionAmount = null;
      _transactionRemark = null;
      recipientDetails = null;
      selectedBank = null;
      accountNumberSet = false;
      _receiverAccountNumber = null;
    });

    _amountController.clear();
    _accountNumberController.clear();
    _remarkController.clear();
    _bankSelectorController.clear();

    _transactionFormKey.currentState?.reset();
  }
}
