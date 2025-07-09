import 'package:decimal/decimal.dart';

class LogSummaryResponse {
  Data? data;

  LogSummaryResponse({this.data});

  LogSummaryResponse.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> jsonData = {};
    if (data != null) {
      jsonData['data'] = data!.toJson();
    }
    return jsonData;
  }
}

class Data {
  LogSummaryData? logSummary;

  Data({this.logSummary});

  Data.fromJson(Map<String, dynamic> json) {
    logSummary =
        json['logSummary'] != null
            ? LogSummaryData.fromJson(json['logSummary'])
            : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> jsonData = {};
    if (logSummary != null) {
      jsonData['logSummary'] = logSummary!.toJson();
    }
    return jsonData;
  }
}

class LogSummaryData {
  Decimal? cashRevenue;
  int? parkedVehicles;
  Decimal? totalRevenue;
  Decimal? upiCardRevenue;
  List<Logs>? logs;

  LogSummaryData({
    this.cashRevenue,
    this.parkedVehicles,
    this.totalRevenue,
    this.upiCardRevenue,
    this.logs,
  });

  LogSummaryData.fromJson(Map<String, dynamic> json) {
    final cr = json['cashRevenue'];
    final tr = json['totalRevenue'];
    final upr = json['upiCardRevenue'];

    cashRevenue = cr != null ? Decimal.parse(cr.toString()) : null;
    totalRevenue = tr != null ? Decimal.parse(tr.toString()) : null;
    upiCardRevenue = upr != null ? Decimal.parse(upr.toString()) : null;

    parkedVehicles = (json['parkedVehicles'] as num?)?.toInt();

    if (json['logs'] != null) {
      logs = List<Logs>.from(json['logs'].map((x) => Logs.fromJson(x)));
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> jsonData = {};
    jsonData['cashRevenue'] = cashRevenue?.toString();
    jsonData['parkedVehicles'] = parkedVehicles;
    jsonData['totalRevenue'] = totalRevenue?.toString();
    jsonData['upiCardRevenue'] = upiCardRevenue?.toString();

    if (logs != null) {
      jsonData['logs'] = logs!.map((x) => x.toJson()).toList();
    }

    return jsonData;
  }
}

class Logs {
  String? entryDate;
  String? entryId;
  String? entrytime;
  String? exittime;
  bool? isExit;
  String? logid;
  String? paymentMethod;
  String? paymentStatus;
  Decimal? totalamount;
  String? vehiclenumber;

  Logs({
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
  });

  Logs.fromJson(Map<String, dynamic> json) {
    entryDate = json['entryDate']?.toString();
    entryId = json['entryId']?.toString();
    entrytime = json['entrytime'];
    exittime = json['exittime'];
    isExit = json['isExit'];
    logid = json['logid'];
    paymentMethod = json['paymentMethod'];
    paymentStatus = json['paymentStatus'];

    // ✅ Proper Decimal parsing
    totalamount =
        json['totalamount'] != null
            ? Decimal.parse(json['totalamount'].toString())
            : null;

    vehiclenumber = json['vehiclenumber'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> jsonData = {};
    jsonData['entryDate'] = entryDate;
    jsonData['entryId'] = entryId;
    jsonData['entrytime'] = entrytime;
    jsonData['exittime'] = exittime;
    jsonData['isExit'] = isExit;
    jsonData['logid'] = logid;
    jsonData['paymentMethod'] = paymentMethod;
    jsonData['paymentStatus'] = paymentStatus;
    jsonData['totalamount'] = totalamount?.toString();
    jsonData['vehiclenumber'] = vehiclenumber;
    return jsonData;
  }
}
