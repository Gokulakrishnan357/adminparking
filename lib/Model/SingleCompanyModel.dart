import 'package:decimal/decimal.dart';

class ParkingLogData {
  Data? data;

  ParkingLogData({this.data});

  factory ParkingLogData.fromJson(Map<String, dynamic> json) {
    return ParkingLogData(
      data: json['data'] != null ? Data.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (data != null) 'data': data!.toJson(),
    };
  }
}

class Data {
  LogByVehicle? logByVehicle;

  Data({this.logByVehicle});

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      logByVehicle: json['logByVehicle'] != null
          ? LogByVehicle.fromJson(json['logByVehicle'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (logByVehicle != null) 'logByVehicle': logByVehicle!.toJson(),
    };
  }
}

class LogByVehicle {
  int? adminid;
  String? createdat;
  String? entrydate;
  int? entryid;
  String? entrytime;
  String? exittime;
  bool? isexit;
  String? logid;
  String? notes;
  int? parkinglotid;
  String? paymentstatus;
  String? qrcodedata;
  String? qrcodeurl;
  Decimal? totalamount;
  double? totalhours;
  String? updatedat;
  List<Paymentdetails>? paymentdetails;
  List<Vehicledetails>? vehicledetails;

  LogByVehicle({
    this.adminid,
    this.createdat,
    this.entrydate,
    this.entryid,
    this.entrytime,
    this.exittime,
    this.isexit,
    this.logid,
    this.notes,
    this.parkinglotid,
    this.paymentstatus,
    this.qrcodedata,
    this.qrcodeurl,
    this.totalamount,
    this.totalhours,
    this.updatedat,
    this.paymentdetails,
    this.vehicledetails,
  });

  factory LogByVehicle.fromJson(Map<String, dynamic> json) {
    return LogByVehicle(
      adminid: json['adminid'],
      createdat: json['createdat'],
      entrydate: json['entrydate'],
      entryid: json['entryid'],
      entrytime: json['entrytime'],
      exittime: json['exittime'],
      isexit: json['isexit'],
      logid: json['logid'],
      notes: json['notes'],
      parkinglotid: json['parkinglotid'],
      paymentstatus: json['paymentstatus'],
      qrcodedata: json['qrcodedata'],
      qrcodeurl: json['qrcodeurl'],
      totalamount: json['totalamount'],
      totalhours: (json['totalhours'] is int)
          ? (json['totalhours'] as int).toDouble()
          : json['totalhours'],
      updatedat: json['updatedat'],
      paymentdetails: (json['paymentdetails'] as List<dynamic>?)
          ?.map((v) => Paymentdetails.fromJson(v))
          .toList(),
      vehicledetails: (json['vehicledetails'] as List<dynamic>?)
          ?.map((v) => Vehicledetails.fromJson(v))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'adminid': adminid,
      'createdat': createdat,
      'entrydate': entrydate,
      'entryid': entryid,
      'entrytime': entrytime,
      'exittime': exittime,
      'isexit': isexit,
      'logid': logid,
      'notes': notes,
      'parkinglotid': parkinglotid,
      'paymentstatus': paymentstatus,
      'qrcodedata': qrcodedata,
      'qrcodeurl': qrcodeurl,
      'totalamount': totalamount,
      'totalhours': totalhours,
      'updatedat': updatedat,
      if (paymentdetails != null)
        'paymentdetails': paymentdetails!.map((v) => v.toJson()).toList(),
      if (vehicledetails != null)
        'vehicledetails': vehicledetails!.map((v) => v.toJson()).toList(),
    };
  }
}

class Paymentdetails {
  String? createdat;
  int? entryid;
  int? paymentamount;
  int? paymentid;
  String? paymentmethod;
  String? paymenttime;
  String? status;

  Paymentdetails({
    this.createdat,
    this.entryid,
    this.paymentamount,
    this.paymentid,
    this.paymentmethod,
    this.paymenttime,
    this.status,
  });

  factory Paymentdetails.fromJson(Map<String, dynamic> json) {
    return Paymentdetails(
      createdat: json['createdat'],
      entryid: json['entryid'],
      paymentamount: json['paymentamount'],
      paymentid: json['paymentid'],
      paymentmethod: json['paymentmethod'],
      paymenttime: json['paymenttime'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'createdat': createdat,
      'entryid': entryid,
      'paymentamount': paymentamount,
      'paymentid': paymentid,
      'paymentmethod': paymentmethod,
      'paymenttime': paymenttime,
      'status': status,
    };
  }
}

class Vehicledetails {
  String? createdat;
  String? customername;
  String? customerphone;
  int? entryid;
  String? imageurl;
  String? updatedat;
  int? vehicledetailsid;
  String? vehiclenumber;

  Vehicledetails({
    this.createdat,
    this.customername,
    this.customerphone,
    this.entryid,
    this.imageurl,
    this.updatedat,
    this.vehicledetailsid,
    this.vehiclenumber,
  });

  factory Vehicledetails.fromJson(Map<String, dynamic> json) {
    return Vehicledetails(
      createdat: json['createdat'],
      customername: json['customername'],
      customerphone: json['customerphone'],
      entryid: json['entryid'],
      imageurl: json['imageurl'],
      updatedat: json['updatedat'],
      vehicledetailsid: json['vehicledetailsid'],
      vehiclenumber: json['vehiclenumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'createdat': createdat,
      'customername': customername,
      'customerphone': customerphone,
      'entryid': entryid,
      'imageurl': imageurl,
      'updatedat': updatedat,
      'vehicledetailsid': vehicledetailsid,
      'vehiclenumber': vehiclenumber,
    };
  }
}
