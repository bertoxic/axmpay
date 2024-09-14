

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
      amount: double.parse(json['amount'].toString().replaceAll(",", "")),
      fee: double.parse(json['fee'].toString().replaceAll(",", "")),
      totalAmount: double.parse(json['totalAmount'].toString().replaceAll(",", "")),
      balAfter: json['balAfter'].toString().replaceAll(",", ""),
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
class Address {
  String street;
  String city;
  String state;
  String zip;

  Address({
    required this.street,
    required this.city,
    required this.state,
    required this.zip,
  });

  Address.fromJSON(Map<String, dynamic> json)
      : street = json["street"] as String? ?? '',
        city = json["city"] as String? ?? '',
        state = json["state"] as String? ?? '',
        zip = json["zip"] as String? ?? '';

  Map<String, dynamic> toJSON() {
    return {
      "street": street,
      "city": city,
      "state": state,
      "zip": zip,
    };
  }

  @override
  String toString() {
    return '$street, $city, $state zip: $zip';
  }
}

class WalletPayload {
  String firstName;
  String lastName;
  String userName;
  String dateOfBirth;
  String? refby;
  String BVN;
  String gender;
  String phone;
  String country;
  String placeOfBirth;
  Address address;

  WalletPayload({
    required this.firstName,
    required this.lastName,
    required this.userName,
    required this.dateOfBirth,
    this.refby,
    required this.gender,
    required this.BVN ,
    required this.phone ,
    required this.country,
    required this.placeOfBirth,
    required this.address,
  });

  WalletPayload.fromJSON(Map<String, dynamic> json)
      : firstName = json['firstName'] as String? ?? '',
        lastName = json['lastName'] as String? ?? '',
        userName = json['userName'] as String? ?? '',
        dateOfBirth = json['dateOfBirth'] as String? ?? '',
        refby = json['refby'] as String? ?? '',
        BVN = json['BVN'] as String? ?? '',
        gender = json['gender'] as String? ?? '',
        phone = json['phone'] as String? ?? '',
        country = json['country'] as String? ?? '',
        placeOfBirth = json['placeOfBirth'] as String? ?? '',
        address = Address.fromJSON(json['address'] as Map<String, dynamic>? ?? {});

  Map<String, dynamic> toJSON() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'userName': userName,
      'dateOfBirth': dateOfBirth,
      'refby': refby,
      'gender': gender,
      'phone': phone,
      "BVN": BVN,
      'country': country,
      'placeOfBirth': placeOfBirth,
      'address': address.toString(),
    };
  }

  @override
  String toString() {
    return 'WalletPayload(firstName: $firstName, lastName: $lastName, userName: $userName, dateOfBirth: $dateOfBirth, refby: $refby, gender: $gender, phone: $phone, country: $country, placeOfBirth: $placeOfBirth, address: $address)';
  }
}

class UpgradeWalletPayload {
  String accountNumber;
  String bvn;
  String accountName;
  String phoneNumber;
  String? tier;
  String? email;
  String userPhoto;
  String? idType;
  String idNumber;
  String idIssueDate;
  String idExpiryDate;
  String idCardFront;
  String idCardBack;
  String houseNumber;
  String streetName;
  String state;
  String city;
  String localGovernment;
  String? pep;
  String customerSignature;
  String utilityBill;
  String nearestLandMark;
  String placeOfBirth;
  String proofOfAddress;

  UpgradeWalletPayload({
    required this.accountNumber,
    required this.bvn,
    required this.accountName,
    required this.phoneNumber,
    this.tier = "",
    required this.email,
    required this.userPhoto,
    this.idType = "1",
    required this.idNumber,
    required this.idIssueDate,
    required this.idExpiryDate,
    required this.idCardFront,
    required this.idCardBack,
    required this.houseNumber,
    required this.streetName,
    required this.state,
    required this.city,
    required this.localGovernment,
    this.pep = "NO",
    required this.customerSignature,
    required this.utilityBill,
    required this.nearestLandMark,
    required this.placeOfBirth,
    required this.proofOfAddress,
  });

  Map<String, dynamic> toJson() {
    return {
      'accountNumber': accountNumber,
      'bvn': bvn,
      'accountName': accountName,
      'phoneNumber': phoneNumber,
      'tier': tier,
      'email': email,
      'userPhoto': userPhoto,
      'idType': idType,
      'idNumber': idNumber,
      'idIssueDate': idIssueDate,
      'idExpiryDate': idExpiryDate,
      'idCardFront': idCardFront,
      'idCardBack': idCardBack,
      'houseNumber': houseNumber,
      'streetName': streetName,
      'state': state,
      'city': city,
      'localGovernment': localGovernment,
      'pep': pep,
      'customerSignature': customerSignature,
      'utilityBill': utilityBill,
      'nearestLandMark': nearestLandMark,
      'placeOfBirth': placeOfBirth,
      'proofOfAddress': proofOfAddress,
    };
  }

  // Create a UpgradeWalletPayload instance from a JSON map
  factory UpgradeWalletPayload.fromJson(Map<String, dynamic> json) {
    return UpgradeWalletPayload(
      accountNumber: json['accountNumber'],
      bvn: json['bvn'],
      accountName: json['accountName'],
      phoneNumber: json['phoneNumber'],
      tier: json['tier'],
      email: json['email'],
      userPhoto: json['userPhoto'],
      idType: json['idType'],
      idNumber: json['idNumber'],
      idIssueDate: json['idIssueDate'],
      idExpiryDate: json['idExpiryDate'],
      idCardFront: json['idCardFront'],
      idCardBack: json['idCardBack'],
      houseNumber: json['houseNumber'],
      streetName: json['streetName'],
      state: json['state'],
      city: json['city'],
      localGovernment: json['localGovernment'],
      pep: json['pep'],
      customerSignature: json['customerSignature'],
      utilityBill: json['utilityBill'],
      nearestLandMark: json['nearestLandMark'],
      placeOfBirth: json['placeOfBirth'],
      proofOfAddress: json['proofOfAddress'],
    );
  }
}

class ReceiptData {
  final Transaction transaction;
  final Customer customer;
  final Order order;
  final String narration;
  final Merchant merchant;
  final String code;
  final String message;

  ReceiptData({
    required this.transaction,
    required this.customer,
    required this.order,
    required this.narration,
    required this.merchant,
    required this.code,
    required this.message,
  });

  factory ReceiptData.fromJson(Map<String, dynamic> json) {
    return ReceiptData(
      transaction: Transaction.fromJson(json['transaction']),
      customer: Customer.fromJson(json['customer']),
      order: Order.fromJson(json['order']),
      narration: json['narration'],
      merchant: Merchant.fromJson(json['merchant']),
      code: json['code'],
      message: json['message'],
    );
  }
}

class Transaction {
  final String reference;

  Transaction({required this.reference});

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(reference: json['reference']);
  }
}

class Customer {
  final Account account;

  Customer({required this.account});

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(account: Account.fromJson(json['account']));
  }
}

class Account {
  final String number;
  final String bank;
  final String name;
  final String senderaccountnumber;
  final String sendername;

  Account({
    required this.number,
    required this.bank,
    required this.name,
    required this.senderaccountnumber,
    required this.sendername,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      number: json['number'],
      bank: json['bank'],
      name: json['name'],
      senderaccountnumber: json['senderaccountnumber'],
      sendername: json['sendername'],
    );
  }
}

class Order {
  final String amount;
  final String currency;
  final String description;
  final String country;

  Order({
    required this.amount,
    required this.currency,
    required this.description,
    required this.country,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      amount: json['amount'],
      currency: json['currency'],
      description: json['description'],
      country: json['country'],
    );
  }
}

class Merchant {
  final bool isFee;
  final String merchantFeeAccount;
  final String merchantFeeAmount;

  Merchant({
    required this.isFee,
    required this.merchantFeeAccount,
    required this.merchantFeeAmount,
  });

  factory Merchant.fromJson(Map<String, dynamic> json) {
    return Merchant(
      isFee: json['isFee'],
      merchantFeeAccount: json['merchantFeeAccount'],
      merchantFeeAmount: json['merchantFeeAmount'],
    );
  }
}