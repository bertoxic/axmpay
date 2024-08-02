import 'package:flutter/foundation.dart';

class LoginDetails {
  String email;
  String password;

  LoginDetails({required this.email, required this.password});

  LoginDetails.fromJSON(Map<String, dynamic> json)
      : email = json["email"] as String? ?? '',
        password = json["password"] as String? ?? '';

  Map<String, dynamic> toJSON() {
    return {
      "email": email,
      "password": password,
    };
  }
}

class User {
  String name;
  String id;
  String? gender;

  User({required this.name, required this.id, this.gender});

  User.fromJSON(Map<String, dynamic> json)
      : name = json["name"] as String? ?? '',
        gender = json["gender"] as String? ?? '',
        id = json["_id"];

  Map<String, dynamic> toJSON() {
    return {
      "name": name,
      "_id": id,
      "gender": gender,
    };
  }
}


class RegisterDetails {
  String name;
  String password;
  String email;

  RegisterDetails({required this.name, required this.password, required this.email});

  RegisterDetails.fromJSON(Map<String, dynamic> json)
      : name = json["name"] as String? ?? '',
      email = json["email"] as String? ?? '',
        password = json["password"] as String? ?? '';

  Map<String, dynamic> toJSON() {
    return {
      "name": name,
      "password": password,
      "email": email,
    };
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
}
class UserDetails {
  String firstName;
  String lastName;
  String? middleName;
  String dateOfBirth;
  String email;
  String? phone;
  String? nin;
  Address? address;
  int? income;
  String? employmentStatus;
  String? securityQuestion;
  String? securityAnswer;
  bool? termsAccepted;
  bool? privacyAccepted;

  UserDetails({
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.email,
    this.middleName,
    this.phone,
    this.nin,
    this.address,
    this.income,
    this.employmentStatus,
    this.securityQuestion,
    this.securityAnswer,
    this.termsAccepted,
    this.privacyAccepted,
  });

  UserDetails.fromJSON(Map<String, dynamic> json)
      : firstName = json["first_name"] as String? ?? '',
        lastName = json["last_name"] as String? ?? '',
        middleName = json["middle_name"] as String? ?? '',
        email = json["email"] as String? ?? '',
        dateOfBirth = json["DOB"] as String? ?? '',
        phone = json["phone"] as String? ?? '',
        nin = json["NIN"] as String? ?? '',
        address = json["address"] != null ? Address.fromJSON(json["address"]) : null,
        income = json["income"] as int? ?? 0,
        employmentStatus = json["employment"] as String? ?? '',
        securityQuestion = json["security_question"] as String? ?? '',
        securityAnswer = json["security_answer"] as String? ?? '',
        termsAccepted = json["terms"] as bool? ?? false,
        privacyAccepted = json["privacy"] as bool? ?? false;

  Map<String, dynamic> toJSON() {
    return {
      "first_name": firstName,
      "last_name": lastName,
      "middle_name": middleName,
      "DOB": dateOfBirth,
      "email": email,
      "phone": phone,
      "NIN": nin,
      "address": address?.toJSON(),
      "income": income,
      "employment": employmentStatus,
      "security_question": securityQuestion,
      "security_answer": securityAnswer,
      "terms": termsAccepted,
      "privacy": privacyAccepted,
    };
  }
}


class UserData {
 // final String status;
  final int id;
  final String apiKey;
  final String refby;
  final String refLink;
  final String vkey;
  final String refStatus;
  final String earn;
  final String userStatus;
  final String phoneStatus;
  final String emailStatus;
  final String typeId;
  final String bvn;
  final String nin;
  final String type;
  final String aid;
  final String accountStatus;
  final String fullName;
  final String accountNumber;
  final String customerId;
  final String availableBalance;
  final String imageName;
  final String firstname;
  final String lastname;
  final String dob;
  final String gender;
  final String email;
  final String phone;
  final String country;
  final String address;
  final String username;
  final String password;
  final String date;

  UserData({
   // required this.status,
    required this.id,
    required this.apiKey,
    required this.refby,
    required this.refLink,
    required this.vkey,
    required this.refStatus,
    required this.earn,
    required this.userStatus,
    required this.phoneStatus,
    required this.emailStatus,
    required this.typeId,
    required this.bvn,
    required this.nin,
    required this.type,
    required this.aid,
    required this.accountStatus,
    required this.fullName,
    required this.accountNumber,
    required this.customerId,
    required this.availableBalance,
    required this.imageName,
    required this.firstname,
    required this.lastname,
    required this.dob,
    required this.gender,
    required this.email,
    required this.phone,
    required this.country,
    required this.address,
    required this.username,
    required this.password,
    required this.date,
  });
  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      //status: json['status'],
      id: json['data']['id'],
      apiKey: json['data']['api_key'],
      refby: json['data']['refby'],
      refLink: json['data']['refLink'],
      vkey: json['data']['vkey'],
      refStatus: json['data']['refStatus'],
      earn: json['data']['earn'],
      userStatus: json['data']['status'],
      phoneStatus: json['data']['phoneStatus'],
      emailStatus: json['data']['emailStatus'],
      typeId: json['data']['Type_ID'],
      bvn: json['data']['BVN'],
      nin: json['data']['NIN'],
      type: json['data']['type'],
      aid: json['data']['AID'],
      accountStatus: json['data']['accountStatus'],
      fullName: json['data']['fullName'],
      accountNumber: json['data']['accountNumber'],
      customerId: json['data']['customerID'],
      availableBalance: json['data']['availableBalance'],
      imageName: json['data']['ImageName'],
      firstname: json['data']['firstname'],
      lastname: json['data']['lastname'],
      dob: json['data']['DOB'],
      gender: json['data']['gender'],
      email: json['data']['email'],
      phone: json['data']['phone'],
      country: json['data']['country'],
      address: json['data']['address'],
      username: json['data']['username'],
      password: json['data']['password'],
      date: json['data']['Date'],
    );
  }
  factory UserData.fromMap(Map<String, dynamic> json) {
    return UserData(
      //status: json['status'],
      id: json['id'],
      apiKey: json['api_key'],
      refby: json['refby'],
      refLink: json['refLink'],
      vkey: json['vkey'],
      refStatus: json['refStatus'],
      earn: json['earn'],
      userStatus: json['status'],
      phoneStatus: json['phoneStatus'],
      emailStatus: json['emailStatus'],
      typeId: json['Type_ID'],
      bvn: json['BVN'],
      nin: json['NIN'],
      type: json['type'],
      aid: json['AID'],
      accountStatus: json['accountStatus'],
      fullName: json['fullName'],
      accountNumber: json['accountNumber'],
      customerId: json['customerID'],
      availableBalance: json['availableBalance'],
      imageName: json['ImageName'],
      firstname: json['firstname'],
      lastname: json['lastname'],
      dob: json['DOB'],
      gender: json['gender'],
      email: json['email'],
      phone: json['phone'],
      country: json['country'],
      address: json['address'],
      username: json['username'],
      password: json['password'],
      date: json['Date'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      //'status': status,

        'id': id,
        'api_key': apiKey,
        'refby': refby,
        'refLink': refLink,
        'vkey': vkey,
        'refStatus': refStatus,
        'earn': earn,
        'status': userStatus,
        'phoneStatus': phoneStatus,
        'emailStatus': emailStatus,
        'Type_ID': typeId,
        'BVN': bvn,
        'NIN': nin,
        'type': type,
        'AID': aid,
        'accountStatus': accountStatus,
        'fullName': fullName,
        'accountNumber': accountNumber,
        'customerID': customerId,
        'availableBalance': availableBalance,
        'ImageName': imageName,
        'firstname': firstname,
        'lastname': lastname,
        'DOB': dob,
        'gender': gender,
        'email': email,
        'phone': phone,
        'country': country,
        'address': address,
        'username': username,
        'password': password,
        'Date': date,

    };
  }
  Map<String, dynamic> toJson() {
    return {
      //'status': status,
      'data': {
        'id': id,
        'api_key': apiKey,
        'refby': refby,
        'refLink': refLink,
        'vkey': vkey,
        'refStatus': refStatus,
        'earn': earn,
        'status': userStatus,
        'phoneStatus': phoneStatus,
        'emailStatus': emailStatus,
        'Type_ID': typeId,
        'BVN': bvn,
        'NIN': nin,
        'type': type,
        'AID': aid,
        'accountStatus': accountStatus,
        'fullName': fullName,
        'accountNumber': accountNumber,
        'customerID': customerId,
        'availableBalance': availableBalance,
        'ImageName': imageName,
        'firstname': firstname,
        'lastname': lastname,
        'DOB': dob,
        'gender': gender,
        'email': email,
        'phone': phone,
        'country': country,
        'address': address,
        'username': username,
        'password': password,
        'Date': date,
      },
    };
  }
@override
String toString() {
  return 'UserData(id: $id, apiKey: $apiKey, ...)';
}

}

class Wallet {
  final String status;
  final bool isSuccessful;
  final double? maximumDeposit;
  final String phoneNumber;
  final String pndStatus;
  final String accountStatus;
  final String name;
  final String number;
  final String responseCode;
  final String? responseMessage;
  final String? responseStatus;
  final String productCode;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String lienStatus;
  final String bvn;
  final double availableBalance;
  final String freezeStatus;
  final double ledgerBalance;
  final double maximumBalance;
  final String nuban;
  final String tier;
  final String responseDescription;

  Wallet({
    required this.status,
    required this.isSuccessful,
    this.maximumDeposit,
    required this.phoneNumber,
    required this.pndStatus,
    required this.accountStatus,
    required this.name,
    required this.number,
    required this.responseCode,
    this.responseMessage,
    this.responseStatus,
    required this.productCode,
    this.email,
    this.firstName,
    this.lastName,
    required this.lienStatus,
    required this.bvn,
    required this.availableBalance,
    required this.freezeStatus,
    required this.ledgerBalance,
    required this.maximumBalance,
    required this.nuban,
    required this.tier,
    required this.responseDescription,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return Wallet(
      status: json['status'] as String,
      isSuccessful: data['isSuccessful'] as bool,
      maximumDeposit: data['maximumDeposit'] as double?,
      phoneNumber: data['phoneNuber'] as String, // Note: There's a typo in the JSON key
      pndStatus: data['pndstatus'] as String,
      accountStatus: data['status'] as String,
      name: data['name'] as String,
      number: data['number'] as String,
      responseCode: data['responseCode'] as String,
      responseMessage: data['responseMessage'] as String?,
      responseStatus: data['responseStatus'] as String?,
      productCode: data['productCode'] as String,
      email: data['email'] as String?,
      firstName: data['firstName'] as String?,
      lastName: data['lastName'] as String?,
      lienStatus: data['lienStatus'] as String,
      bvn: data['bvn'] as String,
      availableBalance: data['availableBalance'] as double,
      freezeStatus: data['freezeStatus'] as String,
      ledgerBalance: data['ledgerBalance'] as double,
      maximumBalance: data['maximumBalance'] as double,
      nuban: data['nuban'] as String,
      tier: data['tier'] as String,
      responseDescription: data['responseDescription'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': {
        'isSuccessful': isSuccessful,
        'maximumDeposit': maximumDeposit,
        'phoneNuber': phoneNumber, // Note: Keeping the typo as in the original JSON
        'pndstatus': pndStatus,
        'status': accountStatus,
        'name': name,
        'number': number,
        'responseCode': responseCode,
        'responseMessage': responseMessage,
        'responseStatus': responseStatus,
        'productCode': productCode,
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'lienStatus': lienStatus,
        'bvn': bvn,
        'availableBalance': availableBalance,
        'freezeStatus': freezeStatus,
        'ledgerBalance': ledgerBalance,
        'maximumBalance': maximumBalance,
        'nuban': nuban,
        'phoneNo': phoneNumber,
        'tier': tier,
        'responseDescription': responseDescription,
      },
    };
  }
}

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
  String accountNumber;
  String bankCode;
  String senderAccountNumber;
  AccountRequestDetails({
    required this.accountNumber,
    required this.bankCode, required
    this.senderAccountNumber});
  Map<String, dynamic>  toJson(){
    return {
      "accountNumber" : accountNumber,
      "bankCode" : bankCode,
      "senderAccountNumber" : senderAccountNumber,
    };

  }
}