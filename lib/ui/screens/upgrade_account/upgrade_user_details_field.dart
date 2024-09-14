import 'package:AXMPAY/ui/screens/upgrade_account/upgrade_account_controller.dart';
import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/text_constants.dart';
import '../../../models/user_model.dart';
import '../../widgets/custom_textfield.dart';

class UpdateUserDetailsField extends StatelessWidget {
   UpdateUserDetailsField({
    super.key,
     this.labelText,
     this.hintText,
     this.prefixIcon,
     this.suffixIcon,
     required this.fieldName,
     this.fieldController,
     this.validator,
     this.onChanged,
     this.keyboardType,
     this.readOnly,

  });

  final TextEditingController? fieldController;
  final String? labelText;
  final String? hintText;
  final String fieldName;
  final TextInputType? keyboardType;
  String? Function(String?)? validator;
  Widget? prefixIcon;
  Widget? suffixIcon;
  bool? readOnly;
  void Function(String)? onChanged;

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      labelText: labelText,
    hintText: labelText,
      validator: validator,
      prefixIcon:prefixIcon,
      fieldName: fieldName,
      onChanged: onChanged,
      readOnly: readOnly??false,
      controller: fieldController,
      keyboardType: TextInputType.text,
      // decoration: InputDecoration(
      //
      //     enabledBorder: OutlineInputBorder(
      //       borderRadius: BorderRadius.circular(20.0),
      //       borderSide: const BorderSide(color: AppColors.lightgrey),
      //     ),
      //     focusedBorder: OutlineInputBorder(
      //       borderRadius: BorderRadius.circular(20.0),
      //       borderSide: const BorderSide(color: Colors.green),
      //     ),
      //     errorBorder: OutlineInputBorder(
      //       borderRadius: BorderRadius.circular(20.0),
      //       borderSide: const BorderSide(color: Colors.red),
      //     ),
      //     fillColor: AppColors.lightgrey,
      //     filled: true
      // ),
    );
  }
}
