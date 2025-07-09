class UserModel {
  LoginResponse? loginUser;

  UserModel({this.loginUser});

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    loginUser:
        json['loginUser'] != null
            ? LoginResponse.fromJson(json['loginUser'])
            : null,
  );

  Map<String, dynamic> toJson() => {
    if (loginUser != null) 'loginUser': loginUser!.toJson(),
  };
}

class LoginResponse {
  String? message;
  bool? success;
  UserData? data;

  LoginResponse({this.message, this.success, this.data});

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
    message: json['message'],
    success: json['success'],
    data: json['data'] != null ? UserData.fromJson(json['data']) : null,
  );

  Map<String, dynamic> toJson() => {
    'message': message,
    'success': success,
    if (data != null) 'data': data!.toJson(),
  };
}

class UserData {
  String? email;
  String? username;
  int? userid;
  String? fullname;
  String? phonenumber;
  bool? isadmin;
  bool? isactive;
  String? passwordhash;
  List<ParkingLot>? parkinglots;

  UserData({
    this.email,
    this.username,
    this.userid,
    this.fullname,
    this.phonenumber,
    this.isadmin,
    this.isactive,
    this.passwordhash,
    this.parkinglots,
  });

  factory UserData.fromJson(Map<String, dynamic> json) => UserData(
    email: json['email'],
    username: json['username'],
    userid: json['userid'],
    fullname: json['fullname'],
    phonenumber: json['phonenumber'],
    isadmin: json['isadmin'],
    isactive: json['isactive'],
    passwordhash: json['passwordhash'],
    parkinglots:
        json['parkinglots'] != null
            ? List<ParkingLot>.from(
              json['parkinglots'].map((x) => ParkingLot.fromJson(x)),
            )
            : null,
  );

  Map<String, dynamic> toJson() => {
    'email': email,
    'username': username,
    'userid': userid,
    'fullname': fullname,
    'phonenumber': phonenumber,
    'isadmin': isadmin,
    'isactive': isactive,
    'passwordhash': passwordhash,
    'parkinglots': parkinglots?.map((x) => x.toJson()).toList(),
  };
}

class ParkingLot {
  String? location;

  ParkingLot({this.location});

  factory ParkingLot.fromJson(Map<String, dynamic> json) =>
      ParkingLot(location: json['location']);

  Map<String, dynamic> toJson() => {'location': location};
}

class VerifyOtpResponse {
  VerifyOtpWrapper? verifyOtp;

  VerifyOtpResponse({this.verifyOtp});

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) =>
      VerifyOtpResponse(
        verifyOtp:
            json['verifyOtp'] != null
                ? VerifyOtpWrapper.fromJson(json['verifyOtp'])
                : null,
      );

  Map<String, dynamic> toJson() => {
    if (verifyOtp != null) 'verifyOtp': verifyOtp!.toJson(),
  };
}

class VerifyOtpWrapper {
  String? message;
  bool? success;
  OtpData? data;

  VerifyOtpWrapper({this.message, this.success, this.data});

  factory VerifyOtpWrapper.fromJson(Map<String, dynamic> json) =>
      VerifyOtpWrapper(
        message: json['message'],
        success: json['success'],
        data: json['data'] != null ? OtpData.fromJson(json['data']) : null,
      );

  Map<String, dynamic> toJson() => {
    'message': message,
    'success': success,
    if (data != null) 'data': data!.toJson(),
  };
}

class OtpData {
  String? createdAt;
  String? expiresAt;
  bool? isUsed;
  String? otpcode;
  int? otpid;
  String? purpose;
  int? userid;

  OtpData({
    this.createdAt,
    this.expiresAt,
    this.isUsed,
    this.otpcode,
    this.otpid,
    this.purpose,
    this.userid,
  });

  factory OtpData.fromJson(Map<String, dynamic> json) => OtpData(
    createdAt: json['createdAt'],
    expiresAt: json['expiresAt'],
    isUsed: json['isUsed'],
    otpcode: json['otpcode'],
    otpid: json['otpid'],
    purpose: json['purpose'],
    userid: json['userid'],
  );

  Map<String, dynamic> toJson() => {
    'createdAt': createdAt,
    'expiresAt': expiresAt,
    'isUsed': isUsed,
    'otpcode': otpcode,
    'otpid': otpid,
    'purpose': purpose,
    'userid': userid,
  };
}

class ForgotPasswordOtpResponse {
  ForgotPasswordOtpWrapper? forgotPasswordOtp;

  ForgotPasswordOtpResponse({this.forgotPasswordOtp});

  factory ForgotPasswordOtpResponse.fromJson(Map<String, dynamic> json) =>
      ForgotPasswordOtpResponse(
        forgotPasswordOtp:
            json['forgotPasswordOtp'] != null
                ? ForgotPasswordOtpWrapper.fromJson(json['forgotPasswordOtp'])
                : null,
      );

  Map<String, dynamic> toJson() => {
    if (forgotPasswordOtp != null)
      'forgotPasswordOtp': forgotPasswordOtp!.toJson(),
  };
}

class ForgotPasswordOtpWrapper {
  String? message;
  bool? success;
  ForgotPasswordOtpData? data;

  ForgotPasswordOtpWrapper({this.message, this.success, this.data});

  factory ForgotPasswordOtpWrapper.fromJson(Map<String, dynamic> json) =>
      ForgotPasswordOtpWrapper(
        message: json['message'],
        success: json['success'],
        data:
            json['data'] != null
                ? ForgotPasswordOtpData.fromJson(json['data'])
                : null,
      );

  Map<String, dynamic> toJson() => {
    'message': message,
    'success': success,
    if (data != null) 'data': data!.toJson(),
  };
}

class ForgotPasswordOtpData {
  int? userid;
  String? otpcode;

  ForgotPasswordOtpData({this.userid, this.otpcode});

  factory ForgotPasswordOtpData.fromJson(Map<String, dynamic> json) =>
      ForgotPasswordOtpData(userid: json['userid'], otpcode: json['otpcode']);

  Map<String, dynamic> toJson() => {'userid': userid, 'otpcode': otpcode};
}

class OtpVerification {
  OtpDataWrapper? data;

  OtpVerification({this.data});

  OtpVerification.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? OtpDataWrapper.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    if (data != null) {
      json['data'] = data!.toJson();
    }
    return json;
  }
}

class OtpDataWrapper {
  VerifyOtp? verifyOtp;

  OtpDataWrapper({this.verifyOtp});

  OtpDataWrapper.fromJson(Map<String, dynamic> json) {
    verifyOtp =
        json['verifyOtp'] != null
            ? VerifyOtp.fromJson(json['verifyOtp'])
            : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    if (verifyOtp != null) {
      json['verifyOtp'] = verifyOtp!.toJson();
    }
    return json;
  }
}

class VerifyOtp {
  String? message;
  bool? success;
  OtpDetails? data;

  VerifyOtp({this.message, this.success, this.data});

  VerifyOtp.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    success = json['success'];
    data = json['data'] != null ? OtpDetails.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    json['message'] = message;
    json['success'] = success;
    if (data != null) {
      json['data'] = data!.toJson();
    }
    return json;
  }
}

class OtpDetails {
  String? createdAt;
  int? userid;
  String? otpcode;

  OtpDetails({this.createdAt, this.userid, this.otpcode});

  OtpDetails.fromJson(Map<String, dynamic> json) {
    createdAt = json['createdAt'];
    userid = json['userid'];
    otpcode = json['otpcode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    json['createdAt'] = createdAt;
    json['userid'] = userid;
    json['otpcode'] = otpcode;
    return json;
  }
}

class OtpSuccess {
  OtpSuccessDataWrapper? data;

  OtpSuccess({this.data});

  OtpSuccess.fromJson(Map<String, dynamic> json) {
    data =
        json['data'] != null
            ? OtpSuccessDataWrapper.fromJson(json['data'])
            : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    if (data != null) {
      json['data'] = data!.toJson();
    }
    return json;
  }
}

class OtpSuccessDataWrapper {
  UpdateUser? updateUser;

  OtpSuccessDataWrapper({this.updateUser});

  OtpSuccessDataWrapper.fromJson(Map<String, dynamic> json) {
    updateUser =
        json['updateUser'] != null
            ? UpdateUser.fromJson(json['updateUser'])
            : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    if (updateUser != null) {
      json['updateUser'] = updateUser!.toJson();
    }
    return json;
  }
}

class UpdateUser {
  String? message;
  bool? success;

  UpdateUser({this.message, this.success});

  UpdateUser.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    success = json['success'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    json['message'] = message;
    json['success'] = success;
    return json;
  }
}
