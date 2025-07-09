class QR {
  QRData? data;

  QR({this.data});

  QR.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? QRData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class QRData {
  GenerateQrCodeForEntry? generateQrCodeForEntry;

  QRData({this.generateQrCodeForEntry});

  QRData.fromJson(Map<String, dynamic> json) {
    generateQrCodeForEntry =
        json['generateQrCodeForEntry'] != null
            ? GenerateQrCodeForEntry.fromJson(json['generateQrCodeForEntry'])
            : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (generateQrCodeForEntry != null) {
      data['generateQrCodeForEntry'] = generateQrCodeForEntry!.toJson();
    }
    return data;
  }
}

class GenerateQrCodeForEntry {
  String? message;
  bool? success;
  QrCodeDetails? data;

  GenerateQrCodeForEntry({this.message, this.success, this.data});

  GenerateQrCodeForEntry.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    success = json['success'];
    data = json['data'] != null ? QrCodeDetails.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['message'] = message;
    data['success'] = success;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class QrCodeDetails {
  int? amount;
  int? entryId;
  String? qrCodeUrl;

  QrCodeDetails({this.amount, this.entryId, this.qrCodeUrl});

  QrCodeDetails.fromJson(Map<String, dynamic> json) {
    final rawAmount = json['amount'];
    amount = rawAmount is double ? rawAmount.toInt() : rawAmount;
    entryId = json['entryId'];
    final rawUrl = json['qrCodeUrl'];
    qrCodeUrl =
        rawUrl != null && rawUrl.startsWith('/')
            ? 'https://crestparkzapidev.crestclimbers.com$rawUrl'
            : rawUrl;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['amount'] = amount;
    data['entryId'] = entryId;
    data['qrCodeUrl'] = qrCodeUrl;
    return data;
  }
}

class EntryQRResponse {
  String? message;
  bool? success;
  int? entryId;

  EntryQRResponse({this.message, this.success, this.entryId});

  factory EntryQRResponse.fromJson(Map<String, dynamic> json) {
    return EntryQRResponse(
      message: json['message'],
      success: json['success'],
      entryId: json['entryId'],
    );
  }
}
