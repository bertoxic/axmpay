

class Bank {
  String? bankName;
  int? bankCode;
  int? nibssBankCode;

  Bank({required this.bankCode, required this.bankName,required this.nibssBankCode});

  factory Bank.fromJson(Map<String, dynamic> json){
    return Bank(
        bankCode: json["bankCode"] is int ? json["bankCode"] : int.tryParse(json["bankCode"].toString()),
        //bankCode: json["bankCode"],
        bankName: json["bankName"],
        nibssBankCode: json["nibssBankCode"] is int ? json["nibssBankCode"] : int.tryParse(json["bankCode"].toString()));
  }
  Map<String, dynamic> toJson(){
    return {
      "bankCode":bankCode,
      "bankName": bankName,
      "nibssBankCode" : nibssBankCode
    };
  }
}

class BankListResponse {
  final String status;
  final String message;
  final List<Bank> bankList;

  BankListResponse({
    required this.status,
    required this.message,
    required this.bankList,
  });

  factory BankListResponse.fromJson(Map<String, dynamic> json) {
    return BankListResponse(
      status: json['status'],
      message: json['message'],
      bankList: (json['data']['bankList'] as List)
          .map((bankJson) => Bank.fromJson(bankJson))
          .toList(),
    );
  }
}

class AccountRequestDetails{
  String? accountNumber;
  String? bankCode;
  String? senderAccountNumber;
  AccountRequestDetails({
    this.accountNumber,
    this.bankCode,
    this.senderAccountNumber});
  Map<String, dynamic>  toJson(){
    return {
      "accountNumber" : accountNumber,
      "bankCode" : bankCode,
      "senderAccountNumber" : senderAccountNumber,
    };

  }
}

class TransactionHistoryModel {
  final String trxID;
  final String accountName;
  final String dateCreated;
  final String amount;
  final String action;
  final String type;
  final String status;

  TransactionHistoryModel({
    required this.trxID,
    required this.accountName,
    required this.dateCreated,
    required this.amount,
    required this.action,
    required this.type,
    required this.status,
  });

  factory TransactionHistoryModel.fromJson(Map<String, dynamic> json) {
    return TransactionHistoryModel(
      trxID: json['trxID'],
      accountName: json['accountName'],
      dateCreated: json['dateCreated'],
      //amount: json['amount'],
      amount: json['amount'],
      action: json['action'],
      type: json['type'],
      status: json['status'],
    );
  }
}



class SpecificTransactionData {
  final String trxID;
  final String accountName;
  final DateTime timeCreated;
  final double amount;
  final double fee;
  final double totalAmount;
  final String balAfter;
  final String action;
  final String narration;
  final String type;
  final String status;

  SpecificTransactionData({
    required this.trxID,
    required this.accountName,
    required this.timeCreated,
    required this.amount,
    required this.fee,
    required this.totalAmount,
    required this.balAfter,
    required this.action,
    required this.narration,
    required this.type,
    required this.status,
  });

  factory SpecificTransactionData.fromJson(Map<String, dynamic> data) {
    Map<String, dynamic> json = data["data"];
    return SpecificTransactionData(
      trxID: json['trxID'],
      accountName: json['accountName'],
      timeCreated: DateTime.parse(json['timeCreated']),
      amount: double.parse(json['amount']),
      fee: double.parse(json['fee']),
      totalAmount: double.parse(json['totalAmount']),
      balAfter: json['balAfter'],
      action: json['action'],
      narration: json['narration'],
      type: json['type'],
      status: json['status'],
    );
  }
}

class TopUpPayload{
  String phoneNumber;
  String amount;
  String network;
  String? productId;
  TopUpPayload({required this.phoneNumber, required this.amount, required this.network, this.productId});

  factory TopUpPayload.fromJson(Map<String, dynamic> json){
    return TopUpPayload(
        phoneNumber: json["phoneNumber"],
        amount: json["amount"],
        network: json["network"],
        productId:  json["productId"],  );
  }
    Map<String, dynamic> toJson(){
    return {
      "phoneNumber": phoneNumber,
      "amount": amount,
      "network":network,
      "productId":productId??"",
    };
    }

}

class DataBundle {
  final String productId;
  final String dataBundle;
  final String amount;
  final String validity;

  DataBundle({
    required this.productId,
    required this.dataBundle,
    required this.amount,
    required this.validity,
  });

  factory DataBundle.fromJson(Map<String, dynamic> json) {
    return DataBundle(
      productId: json['productId'] as String,
      dataBundle: json['dataBundle'] as String,
      amount: json['amount'] as String,
      validity: json['validity'] as String,
    );
  }
}

class DataBundleList {
  final List<DataBundle> dataBundles;

  DataBundleList({required this.dataBundles});

  factory DataBundleList.fromJson(Map<String, dynamic> json) {
    var list = json['data'] as List<dynamic>;
    List<DataBundle> bundles = list.map((bundle) => DataBundle.fromJson(bundle)).toList();
    return DataBundleList(dataBundles: bundles);
  }
}
