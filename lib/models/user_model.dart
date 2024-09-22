
import 'package:AXMPAY/models/transaction_model.dart';

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


class PreRegisterDetails {
  String firstName;
  String lastName;
  String password;
  String email;

  PreRegisterDetails({required this.firstName,required this.lastName, required this.password, required this.email});

  PreRegisterDetails.fromJSON(Map<String, dynamic> json)
      : firstName = json["firstname"] as String? ?? '',
      lastName = json["lastname"] as String? ?? '',
      email = json["email"] as String? ?? '',
        password = json["password"] as String? ?? '';

  Map<String, dynamic> toJSON() {
    return {
      "firstname": firstName,
      "lastname": lastName,
      "password": password,
      "email": email,
    };
  }
}


class UserDetails {
  String firstName;
  String lastName;
  String? fullName;
  String dateOfBirth;
  String email;
  String? phone;
  String? nin;
  String? bvn;
  String? gender;
  Address? address;
  Address? state;
  Address? city;
  Address? streetAddress;
  Address? zip;


  UserDetails({
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.email,
    this.fullName,
    this.phone,
    this.nin,
    this.bvn,
    this.address,
    this.gender,

  });

  UserDetails.fromJSON(Map<String, dynamic> json)
      : firstName = json["first_name"] as String? ?? '',
        lastName = json["last_name"] as String? ?? '',
        fullName = json["fullName"] as String? ?? '',
        email = json["email"] as String? ?? '',
        dateOfBirth = json["dateofbirth"] as String? ?? '',
        phone = json["phone"] as String? ?? '',
        nin = json["NIN"] as String? ?? '',
        bvn = json["BVN"] as String? ?? '',
        address = json["address"] != null ? Address.fromJSON(json["address"]) : null,
        gender = json["gender"];

  Map<String, dynamic> toJSON() {
    return {
      "firstname": firstName,
      "lastname": lastName,
      "fullname": "$firstName $lastName",
      "DOB": dateOfBirth,
      "email": email,
      "gender": gender,
      "phone": phone,
      //"NIN": nin,
      "BVN": bvn,
      "address": address.toString(),
    };
  }
}


class UserData {
  final String id;
  final String apiKey;
  final String refby;
  final String refLink;
  final String vkey;
  final String refStatus;
  final String earn;
  final String userStatus;
  final String phoneStatus;
  final String emailStatus;
  final String bvn;
  final String nin;
  final String type;
  final String aid;
  final String accountStatus;
  final String fullName;
  final String accountNumber;
  final String customerId;
  final String availableBalance;
  final String tier;
  final String verificationStatus;
  final String idType;
  final String idNumber;
  final String idCardFront;
  final String idCardBack;
  final String idIssueDate;
  final String idExpiryDate;
  final String imageName;
  final String firstname;
  final String lastname;
  final String dob;
  final String gender;
  final String email;
  final String phone;
  final String country;
  final String lga;
  final String houseNumber;
  final String streetName;
  final String state;
  final String city;
  final String nearestLandmark;
  final String placeOfBirth;
  final String address;
  final String userPhoto;
  final String pep;
  final String clientSignature;
  final String utilityBill;
  final String proofOfAddress;
  final String username;
  final String password;
  final String date;

  UserData({
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
    required this.bvn,
    required this.nin,
    required this.type,
    required this.aid,
    required this.accountStatus,
    required this.fullName,
    required this.accountNumber,
    required this.customerId,
    required this.availableBalance,
    required this.tier,
    required this.verificationStatus,
    required this.idType,
    required this.idNumber,
    required this.idCardFront,
    required this.idCardBack,
    required this.idIssueDate,
    required this.idExpiryDate,
    required this.imageName,
    required this.firstname,
    required this.lastname,
    required this.dob,
    required this.gender,
    required this.email,
    required this.phone,
    required this.country,
    required this.lga,
    required this.houseNumber,
    required this.streetName,
    required this.state,
    required this.city,
    required this.nearestLandmark,
    required this.placeOfBirth,
    required this.address,
    required this.userPhoto,
    required this.pep,
    required this.clientSignature,
    required this.utilityBill,
    required this.proofOfAddress,
    required this.username,
    required this.password,
    required this.date,
  });

  factory UserData.fromMap(Map<String, dynamic> map) {
    return UserData(
      id: _parseStringOrNum(map['id']) ?? '0',
      apiKey: map['api_key']?.toString() ?? '',
      refby: map['refby']?.toString() ?? '',
      refLink: map['refLink']?.toString() ?? '',
      vkey: map['vkey']?.toString() ?? '',
      refStatus: map['refStatus']?.toString() ?? '',
      earn: _parseStringOrNum(map['earn']) ?? '',
      userStatus: map['status']?.toString() ?? '',
      phoneStatus: map['phoneStatus']?.toString() ?? '',
      emailStatus: map['emailStatus']?.toString() ?? '',
      bvn: map['BVN']?.toString() ?? '',
      nin: map['NIN']?.toString() ?? '',
      type: map['type']?.toString() ?? '',
      aid: map['AID']?.toString() ?? '',
      accountStatus: map['accountStatus']?.toString() ?? '',
      fullName: map['fullName']?.toString() ?? '',
      accountNumber: map['accountNumber']?.toString() ?? '',
      customerId: map['customerID']?.toString() ?? '',
      availableBalance: _parseStringOrNum(map['availableBalance']) ?? '',
      tier: _parseStringOrNum(map['Tier']) ?? '0',
      verificationStatus: map['verificationStatus']?.toString() ?? '',
      idType: map['IDType']?.toString() ?? '',
      idNumber: map['ID_Number']?.toString() ?? '',
      idCardFront: map['IDCardFront']?.toString() ?? '',
      idCardBack: map['IDCardBack']?.toString() ?? '',
      idIssueDate: map['ID_IssueDate']?.toString() ?? '',
      idExpiryDate: map['ID_ExpiryDate']?.toString() ?? '',
      imageName: map['ImageName']?.toString() ?? '',
      firstname: map['firstname']?.toString() ?? '',
      lastname: map['lastname']?.toString() ?? '',
      dob: map['DOB']?.toString() ?? '',
      gender: map['gender']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      country: map['country']?.toString() ?? '',
      lga: map['LGA']?.toString() ?? '',
      houseNumber: map['houseNumber']?.toString() ?? '',
      streetName: map['streetName']?.toString() ?? '',
      state: map['State']?.toString() ?? '',
      city: map['City']?.toString() ?? '',
      nearestLandmark: map['nearestLandmark']?.toString() ?? '',
      placeOfBirth: map['place_Of_Birth']?.toString() ?? '',
      address: map['address']?.toString() ?? '',
      userPhoto: map['userPhoto']?.toString() ?? '',
      pep: map['PEP']?.toString() ?? '',
      clientSignature: map['clientSignature']?.toString() ?? '',
      utilityBill: map['utilityBill']?.toString() ?? '',
      proofOfAddress: map['proof_of_Address']?.toString() ?? '',
      username: map['username']?.toString() ?? '',
      password: map['password']?.toString() ?? '',
      date: map['Date']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
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
      'BVN': bvn,
      'NIN': nin,
      'type': type,
      'AID': aid,
      'accountStatus': accountStatus,
      'fullName': fullName,
      'accountNumber': accountNumber,
      'customerID': customerId,
      'availableBalance': availableBalance,
      'Tier': tier,
      'verificationStatus': verificationStatus,
      'IDType': idType,
      'ID_Number': idNumber,
      'IDCardFront': idCardFront,
      'IDCardBack': idCardBack,
      'ID_IssueDate': idIssueDate,
      'ID_ExpiryDate': idExpiryDate,
      'ImageName': imageName,
      'firstname': firstname,
      'lastname': lastname,
      'DOB': dob,
      'gender': gender,
      'email': email,
      'phone': phone,
      'country': country,
      'LGA': lga,
      'houseNumber': houseNumber,
      'streetName': streetName,
      'State': state,
      'City': city,
      'nearestLandmark': nearestLandmark,
      'place_Of_Birth': placeOfBirth,
      'address': address,
      'userPhoto': userPhoto,
      'PEP': pep,
      'clientSignature': clientSignature,
      'utilityBill': utilityBill,
      'proof_of_Address': proofOfAddress,
      'username': username,
      'password': password,
      'Date': date,
    };}

  factory UserData.fromJson(Map<String, dynamic> responseData) {
    Map<String, dynamic> json = responseData["data"];
    return UserData(
      id: _parseStringOrNum(json['id']) ?? '0',
      apiKey: json['api_key']?.toString() ?? '',
      refby: json['refby']?.toString() ?? '',
      refLink: json['refLink']?.toString() ?? '',
      vkey: json['vkey']?.toString() ?? '',
      refStatus: json['refStatus']?.toString() ?? '',
      earn: _parseStringOrNum(json['earnBalance']) ?? '0',
      userStatus: json['status']?.toString() ?? '',
      phoneStatus: json['phoneStatus']?.toString() ?? '',
      emailStatus: json['emailStatus']?.toString() ?? '',
      bvn: json['BVN']?.toString() ?? '',
      nin: json['NIN']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      aid: json['AID']?.toString() ?? '',
      accountStatus: json['accountStatus']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      accountNumber: json['accountNumber']?.toString() ?? '',
      customerId: json['customerID']?.toString() ?? '',
      availableBalance: _parseStringOrNum(json['availableBalance']) ?? '0',
      tier: _parseStringOrNum(json['Tier']) ?? '0',
      verificationStatus: json['verificationStatus']?.toString() ?? '',
      idType: json['IDType']?.toString() ?? '',
      idNumber: json['ID_Number']?.toString() ?? '',
      idCardFront: json['IDCardFront']?.toString() ?? '',
      idCardBack: json['IDCardBack']?.toString() ?? '',
      idIssueDate: json['ID_IssueDate']?.toString() ?? '',
      idExpiryDate: json['ID_ExpiryDate']?.toString() ?? '',
      imageName: json['ImageName']?.toString() ?? '',
      firstname: json['firstname']?.toString() ?? '',
      lastname: json['lastname']?.toString() ?? '',
      dob: json['DOB']?.toString() ?? '',
      gender: json['gender']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      lga: json['LGA']?.toString() ?? '',
      houseNumber: json['houseNumber']?.toString() ?? '',
      streetName: json['streetName']?.toString() ?? '',
      state: json['State']?.toString() ?? '',
      city: json['City']?.toString() ?? '',
      nearestLandmark: json['nearestLandmark']?.toString() ?? '',
      placeOfBirth: json['place_Of_Birth']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      userPhoto: json['userPhoto']?.toString() ?? '',
      pep: json['PEP']?.toString() ?? '',
      clientSignature: json['clientSignature']?.toString() ?? '',
      utilityBill: json['utilityBill']?.toString() ?? '',
      proofOfAddress: json['proof_of_Address']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      password: json['password']?.toString() ?? '',
      date: json['Date']?.toString() ?? '',
    );
  }

// Helper method to parse string or numeric values
  static String _parseStringOrNum(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is int || value is double) return value.toString();
    return '';
  }

  Map<String, dynamic> toJson() {
    return {
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
      'BVN': bvn,
      'NIN': nin,
      'type': type,
      'AID': aid,
      'accountStatus': accountStatus,
      'fullName': fullName,
      'accountNumber': accountNumber,
      'customerID': customerId,
      'availableBalance': availableBalance,
      'Tier': tier,
      'verificationStatus': verificationStatus,
      'IDType': idType,
      'ID_Number': idNumber,
      'IDCardFront': idCardFront,
      'IDCardBack': idCardBack,
      'ID_IssueDate': idIssueDate,
      'ID_ExpiryDate': idExpiryDate,
      'ImageName': imageName,
      'firstname': firstname,
      'lastname': lastname,
      'DOB': dob,
      'gender': gender,
      'email': email,
      'phone': phone,
      'country': country,
      'LGA': lga,
      'houseNumber': houseNumber,
      'streetName': streetName,
      'State': state,
      'City': city,
      'nearestLandmark': nearestLandmark,
      'place_Of_Birth': placeOfBirth,
      'address': address,
      'userPhoto': userPhoto,
      'PEP': pep,
      'clientSignature': clientSignature,
      'utilityBill': utilityBill,
      'proof_of_Address': proofOfAddress,
      'username': username,
      'password': password,
      'Date': date,
    };
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
