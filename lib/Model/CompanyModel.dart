import 'package:decimal/decimal.dart';

class LogData {
  Data? data;

  LogData({this.data});

  LogData.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  LogsSummary? logs;

  Data({this.logs});

  Data.fromJson(Map<String, dynamic> json) {
    logs = json['logs'] != null ? LogsSummary.fromJson(json['logs']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (logs != null) {
      data['logs'] = logs!.toJson();
    }
    return data;
  }
}

class LogsSummary {
  int? availableSlots;
  int? occupiedSlots;
  int? todayRevenue;
  int? totalSlots;
  List<LogDetails>? logs;

  LogsSummary({
    this.availableSlots,
    this.occupiedSlots,
    this.todayRevenue,
    this.totalSlots,
    this.logs,
  });

  LogsSummary.fromJson(Map<String, dynamic> json) {
    availableSlots = json['availableSlots'];
    occupiedSlots = json['occupiedSlots'];
    todayRevenue = json['todayRevenue'];
    totalSlots = json['totalSlots'];
    if (json['logs'] != null) {
      logs = <LogDetails>[];
      json['logs'].forEach((v) {
        logs!.add(LogDetails.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['availableSlots'] = availableSlots;
    data['occupiedSlots'] = occupiedSlots;
    data['todayRevenue'] = todayRevenue;
    data['totalSlots'] = totalSlots;
    if (logs != null) {
      data['logs'] = logs!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class LogDetails {
  String? entryDate;
  int? entryId;
  String? entrytime;
  String? exittime;
  bool? isExit;
  String? logid;
  String? paymentMethod;
  String? paymentStatus;
  String? vehiclenumber;
  int? adminid;
  String? createdat;
  String? entrydate;
  int? entryid;
  bool? isexit;
  String? notes;
  int? parkinglotid;
  String? paymentstatus;
  String? qrcodedata;
  String? qrcodeurl;
  int? totalamount;
  double? totalhours;
  String? updatedat;
  List<Paymentdetails>? paymentdetails;
  List<Vehicledetails>? vehicledetails;

  LogDetails({
    this.entryDate,
    this.entryId,
    this.entrytime,
    this.exittime,
    this.isExit,
    this.logid,
    this.paymentMethod,
    this.paymentStatus,
    this.totalamount,
    this.vehiclenumber,
    this.adminid,
    this.createdat,
    this.entrydate,
    this.entryid,
    this.isexit,
    this.notes,
    this.parkinglotid,
    this.paymentstatus,
    this.qrcodedata,
    this.qrcodeurl,
    this.totalhours,
    this.updatedat,
    this.paymentdetails,
    this.vehicledetails,
  });

  factory LogDetails.fromJson(Map<String, dynamic> json) {
    return LogDetails(
      entryDate: json['entryDate'],
      entryId: (json['entryId'] as num?)?.toInt(),
      entrytime: json['entrytime'],
      exittime: json['exittime'],
      isExit: json['isExit'],
      logid: json['logid'],
      paymentMethod: json['paymentMethod'],
      paymentStatus: json['paymentStatus'],
      totalamount: (json['totalamount'] as num?)?.toInt(),
      vehiclenumber: json['vehiclenumber'],
      adminid: (json['adminid'] as num?)?.toInt(),
      createdat: json['createdat'],
      entrydate: json['entrydate'],
      entryid: (json['entryid'] as num?)?.toInt(),
      isexit: json['isexit'],
      notes: json['notes'],
      parkinglotid: (json['parkinglotid'] as num?)?.toInt(),
      paymentstatus: json['paymentstatus'],
      qrcodedata: json['qrcodedata'],
      qrcodeurl: json['qrcodeurl'],
      totalhours: (json['totalhours'] as num?)?.toDouble(),
      updatedat: json['updatedat'],
      paymentdetails:
          (json['paymentdetails'] as List<dynamic>?)
              ?.map((e) => Paymentdetails.fromJson(e))
              .toList(),
      vehicledetails:
          (json['vehicledetails'] as List<dynamic>?)
              ?.map((e) => Vehicledetails.fromJson(e))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'entryDate': entryDate,
      'entryId': entryId,
      'entrytime': entrytime,
      'exittime': exittime,
      'isExit': isExit,
      'logid': logid,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'totalamount': totalamount,
      'vehiclenumber': vehiclenumber,
      'adminid': adminid,
      'createdat': createdat,
      'entrydate': entrydate,
      'entryid': entryid,
      'isexit': isexit,
      'notes': notes,
      'parkinglotid': parkinglotid,
      'paymentstatus': paymentstatus,
      'qrcodedata': qrcodedata,
      'qrcodeurl': qrcodeurl,
      'totalhours': totalhours,
      'updatedat': updatedat,
      'paymentdetails': paymentdetails?.map((e) => e.toJson()).toList(),
      'vehicledetails': vehicledetails?.map((e) => e.toJson()).toList(),
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
      entryid: (json['entryid'] as num?)?.toInt(),
      paymentamount: (json['paymentamount'] as num?)?.toInt(),
      paymentid: (json['paymentid'] as num?)?.toInt(),
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
      entryid: (json['entryid'] as num?)?.toInt(),
      imageurl: json['imageurl'],
      updatedat: json['updatedat'],
      vehicledetailsid: (json['vehicledetailsid'] as num?)?.toInt(),
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

class LogResponseWrapper {
  final int availableSlots;
  final int occupiedSlots;
  final int totalSlots;
  final int todayRevenue;
  final List<LogDetails> logs;

  LogResponseWrapper({
    required this.availableSlots,
    required this.occupiedSlots,
    required this.totalSlots,
    required this.todayRevenue,
    required this.logs,
  });
}

class EntryResponse {
  final String message;
  final bool success;

  EntryResponse({required this.message, required this.success});

  factory EntryResponse.fromJson(Map<String, dynamic> json) {
    return EntryResponse(
      message: json['message'] ?? '',
      success: json['success'] ?? false,
    );
  }
}

class NewLogId {
  final NewLogIdData? data;

  NewLogId({this.data});

  factory NewLogId.fromJson(Map<String, dynamic> json) {
    return NewLogId(
      data: json['data'] != null ? NewLogIdData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {if (data != null) 'data': data!.toJson()};
  }
}

class NewLogIdData {
  final String? newLogId;

  NewLogIdData({this.newLogId});

  factory NewLogIdData.fromJson(Map<String, dynamic> json) {
    return NewLogIdData(newLogId: json['newLogId']);
  }

  Map<String, dynamic> toJson() {
    return {'newLogId': newLogId};
  }
}
