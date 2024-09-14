

import 'package:AXMPAY/models/ResponseModel.dart';
import 'package:AXMPAY/models/transaction_model.dart';
import 'package:AXMPAY/models/user_model.dart';
import 'package:AXMPAY/ui/screens/registration/registration_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegistrationController {
  final BuildContext context;
  final formKey = GlobalKey<FormState>();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController refby = TextEditingController();
  final TextEditingController country = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController date_of_birth = TextEditingController();
  final TextEditingController first_name = TextEditingController();
  final TextEditingController last_name = TextEditingController();
  final TextEditingController gender = TextEditingController();
  final TextEditingController phone_number = TextEditingController();
  final TextEditingController placeOfBirthController = TextEditingController();
  final TextEditingController bvn = TextEditingController();
  final TextEditingController street_address = TextEditingController();
  final TextEditingController city = TextEditingController();
  final TextEditingController state = TextEditingController();
  final TextEditingController zip_code = TextEditingController();
  late UserDetails? userDetails;
  late WalletPayload? walletPayload;
  RegistrationController(this.context){
    _initializeController();
  }


void _initializeController() {
      final provider = Provider.of<RegistrationProvider>(context, listen: false);
      userDetails = provider.userDetails;
      walletPayload = provider.walletPayload;
}

  Future<void> selectDate(BuildContext context) async {
    final provider = Provider.of<RegistrationProvider>(context, listen: false);
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

  void updateUserDetailsModel(){
     userDetails = UserDetails(
        lastName: last_name.text,
        dateOfBirth: date_of_birth.text,
        email: emailController.text,
        firstName: first_name.text,
        address: Address(street: street_address.text, city: city.text, state: state.text, zip: zip_code.text),
        bvn: bvn.text,
        nin: placeOfBirthController.text,
        phone: phone_number.text,
        gender: gender.text,
    );
     print("userDetails");
    final provider = Provider.of<RegistrationProvider>(context, listen: false);
  }
  void createUserWalletPayload(){
    var address = Address(street: street_address.text, city: city.text, state: state.text, zip: zip_code.text);
    walletPayload = WalletPayload(
        lastName: last_name.text,
        dateOfBirth: date_of_birth.text,
        firstName: first_name.text,
        address: address,
        BVN: bvn.text,
        placeOfBirth: placeOfBirthController.text,
        phone: phone_number.text,
        refby: refby.text,
        country: country.text,
        userName: "${first_name.text}${last_name.text}",
        gender: gender.text


    );
    final provider = Provider.of<RegistrationProvider>(context, listen: false);

    print(walletPayload?.toJSON());
  }
  void updateUserDetailsToServer(){
    final provider = Provider.of<RegistrationProvider>(context, listen: false);
    provider.userProvider.updateUserRegistrationDetails(context,userDetails!);

  }

  Future<ResponseResult?> createNewUserWallet() async {
    createUserWalletPayload();
    ResponseResult? responseResult;
    final provider = Provider.of<RegistrationProvider>(context, listen: false);
    responseResult = await provider.userProvider.createUserWallet(context,walletPayload!);
    return responseResult;
  }

  void dispose() {
    // Dispose of all the TextEditingController instances
    userNameController.dispose();
    emailController.dispose();
    refby.dispose();
    country.dispose();
    passwordController.dispose();
    date_of_birth.dispose();
    first_name.dispose();
    last_name.dispose();
    gender.dispose();
    phone_number.dispose();
    placeOfBirthController.dispose();
    bvn.dispose();
    street_address.dispose();
    city.dispose();
    state.dispose();
    zip_code.dispose();
    // imageDisplayContoller.dispose();
   // imageInputController.dispose();
  }
}