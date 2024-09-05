
import 'package:fintech_app/models/transaction_model.dart';
import 'package:fintech_app/models/user_model.dart';
import 'package:fintech_app/providers/user_service_provider.dart';
import 'package:fintech_app/ui/screens/upgrade_account/upgrade_account_provider.dart';
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
    accountNameController.text = "${providerx.userdata?.firstname} ${providerx.userdata?.lastname}" ?? '';
    accountNumberController.text = "${providerx.userdata?.accountNumber}";
    bvnController.text = "${providerx.userdata?.bvn}" ?? '';
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



  // void updateUserDetailsModel(){
  //    userDetails = UserDetails(
  //       lastName: account_number.text,
  //       dateOfBirth: date_of_birth.text,
  //       email: emailController.text,
  //       firstName: first_name.text,
  //       address: Address(street: streetNameController.text, city: cityController.text, state: stateController.text, zip:""),
  //       bvn: bvn.text,
  //       nin: placeOfBirthController.text,
  //       phone: phone_number.text,
  //       gender: gender.text,
  //
  //
  //   );
  //    print("userDetails");
  //   final provider = Provider.of<UpgradeAccountProvider>(context, listen: false);
  //   createUserWalletPayload();
  //   print(userDetails?.toJSON());
  // }
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
  void upgradeUserWalletInServer(){
    final provider = Provider.of<UpgradeAccountProvider>(context, listen: false);
    provider.userProvider.upgradeUserWallet(context,upgradeWalletPayload!);

  }

  // Future<String?> walletPayloadToServer() async {
  //   String? status;
  //   final provider = Provider.of<UpgradeAccountProvider>(context, listen: false);
  //   status = await provider.userProvider.createUserWallet(context,upgradeWalletPayload!);
  //   return status;
  // }
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