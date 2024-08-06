

import 'package:fintech_app/models/user_model.dart';

class Account {
  String? number;
  String? bank;
  String? name;
  String? bvn;
  Account({
    required this.name,
    required this.number,
    required this.bank,
    required this.bvn,
});
  factory Account.fromJson(Map<String, dynamic> json){
    return Account(
        name: json["name"],
        number: json["number"],
        bank: json["bank"],
        bvn: json["bvn"]
    );}

}
class RecipientDetails {
  Account? account;
  RecipientDetails({
    required this.account,
    });

      factory RecipientDetails.fromJson(Map<String, dynamic> json){
       var data = json["customer"];
        return RecipientDetails(
            account: Account.fromJson(data["account"]),
        );
      }
}

class TransactionModel {
  final int? amount;
  final String? recipientAccount;
  final String? recipientAccountName;
  final String? recipientBankCode;
  final String? recipientBankName;
  final String? senderAccountNumber;
  final String? senderAccountName;
  final String? narration;

  TransactionModel({
     this.amount,
     this.recipientAccount,
     this.recipientAccountName,
     this.recipientBankCode,
     this.recipientBankName,
     this.senderAccountNumber,
     this.senderAccountName,
     this.narration,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      amount: json['amount'],
      recipientAccount: json['recipientAccount'],
      recipientAccountName: json['recipientAccountName'],
      recipientBankCode: json['recipientBankCode'],
      recipientBankName: json['recipientBankName'],
      senderAccountNumber: json['senderAccountNumber'],
      senderAccountName: json['senderAccountName'],
      narration: json['narration'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'recipientAccount': recipientAccount,
      'recipientAccountName': recipientAccountName,
      'recipientBankCode': recipientBankCode,
      'recipientBankName': recipientBankName,
      'senderAccountNumber': senderAccountNumber,
      'senderAccountName': senderAccountName,
      'narration': narration,
    };
  }
}