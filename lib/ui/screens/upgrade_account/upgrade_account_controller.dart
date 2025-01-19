
import 'dart:convert';

import 'package:AXMPAY/models/ResponseModel.dart';
import 'package:AXMPAY/models/transaction_model.dart';
import 'package:AXMPAY/models/user_model.dart';
import 'package:AXMPAY/providers/user_service_provider.dart';
import 'package:AXMPAY/ui/screens/upgrade_account/upgrade_account_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UpgradeAccountController {
  final BuildContext context;
  final formKey = GlobalKey<FormState>();
  final TextEditingController accountNumberController = TextEditingController();
  final TextEditingController bvnController = TextEditingController();
  final TextEditingController accountNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController tierController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController userPhotoController = TextEditingController();
  final TextEditingController idTypeController = TextEditingController();
  final TextEditingController idNumberController = TextEditingController();
  final TextEditingController idIssueDateController = TextEditingController();
  final TextEditingController idExpiryDateController = TextEditingController();
  final TextEditingController idCardFrontController = TextEditingController();
  final TextEditingController idCardBackController = TextEditingController();
  final TextEditingController houseNumberController = TextEditingController();
  final TextEditingController streetNameController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController localGovernmentController = TextEditingController();
  final TextEditingController pepController = TextEditingController();
  final TextEditingController customerSignatureController = TextEditingController();
  final TextEditingController utilityBillController = TextEditingController();
  final TextEditingController nearestLandMarkController = TextEditingController();
  final TextEditingController placeOfBirthController = TextEditingController();
  final TextEditingController proofOfAddressController = TextEditingController();

  late UserDetails? userDetails;
  late UserData? preRegDetails;
  late UpgradeWalletPayload? upgradeWalletPayload;
  UpgradeAccountController(this.context){
    _initializeController();
  }

void _initializeController() {
      final provider = Provider.of<UpgradeAccountProvider>(context, listen: false);
      userDetails = provider.userDetails;
      upgradeWalletPayload = provider.walletPayload;
      _initializeFormDetails();

}

  _initializeFormDetails(){
    final providerx = Provider.of<UserServiceProvider>(context, listen: false);
    final email = providerx.userdata?.email;
    emailController.text = email ?? '';
    accountNameController.text = "${providerx.userdata?.fullName}" ?? '';
    accountNumberController.text = "${providerx.userdata?.accountNumber}";
    bvnController.text = "${providerx.userdata?.bvn}" ?? '';
    phoneNumberController.text = "${providerx.userdata?.phone}" ?? '';
    tierController.text = providerx.userdata?.tier.toString()??"";
    bvnController.text = providerx.userdata?.bvn.toString()??"";
    tierController.text = providerx.userdata?.tier.toString()??"";
    tierController.text = providerx.userdata?.tier.toString()??"";

   // email.text = "${providerx.userdata?.firstname} ${providerx.userdata?.lastname}" ?? '';
  }
  Future<void> selectDate(BuildContext context) async {
    final provider = Provider.of<UpgradeAccountProvider>(context, listen: false);
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: provider.selectedDate ?? DateTime.now(),
      firstDate: DateTime(1920),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != provider.selectedDate) {
      provider.updateSelectedDate(pickedDate);
    }
  }

  String? fileSizeValidator(String base64String) {
    const int maxSizeInBytes = 5 * 1024 * 1024;

    int fileSizeInBytes = base64Decode(base64String).length;

    if (fileSizeInBytes > maxSizeInBytes) {
      return 'File size should not exceed 5MB';
    }
    return null;
  }

  void createUserWalletPayload(){
    upgradeWalletPayload = UpgradeWalletPayload(
        accountNumber: accountNumberController.text,
        bvn: bvnController.text,
        accountName: accountNameController.text,
        phoneNumber: phoneNumberController.text,
        email: emailController.text,
        userPhoto: userPhotoController.text,
        idNumber: idNumberController.text,
        idIssueDate: idIssueDateController.text,
        idExpiryDate: idExpiryDateController.text,
        idCardFront: idCardFrontController.text,
        idCardBack: idCardBackController.text,
        houseNumber: houseNumberController.text,
        streetName: streetNameController.text,
        state: stateController.text,
        city: cityController.text,
        localGovernment: localGovernmentController.text,
        customerSignature: customerSignatureController.text,
        utilityBill: utilityBillController.text,
        nearestLandMark: nearestLandMarkController.text,
        placeOfBirth: placeOfBirthController.text,
        proofOfAddress: proofOfAddressController.text);
    final provider = Provider.of<UpgradeAccountProvider>(context, listen: false);

    print(upgradeWalletPayload?.toJson());
  }
  Future<ResponseResult?> upgradeUserWalletInServer() async {
    final provider = Provider.of<UpgradeAccountProvider>(context, listen: false);
   ResponseResult? responseResult = await provider.userProvider.upgradeUserWallet(context,upgradeWalletPayload!);
    return responseResult;
  }


  void dispose() {
    // Dispose all controllers
    accountNumberController.dispose();
    bvnController.dispose();
    accountNameController.dispose();
    phoneNumberController.dispose();
    tierController.dispose();
    emailController.dispose();
    userPhotoController.dispose();
    idTypeController.dispose();
    idNumberController.dispose();
    idIssueDateController.dispose();
    idExpiryDateController.dispose();
    idCardFrontController.dispose();
    idCardBackController.dispose();
    houseNumberController.dispose();
    streetNameController.dispose();
    stateController.dispose();
    cityController.dispose();
    localGovernmentController.dispose();
    pepController.dispose();
    customerSignatureController.dispose();
    utilityBillController.dispose();
    nearestLandMarkController.dispose();
    placeOfBirthController.dispose();
    proofOfAddressController.dispose();
  }
}