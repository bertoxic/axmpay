

import 'package:fintech_app/models/user_model.dart';

class RecipientDetails {
  String? name;
  String? accountNumber;
  Bank? bank;
  RecipientDetails({
    required this.name,
    required this.accountNumber,
    required this.bank});
}