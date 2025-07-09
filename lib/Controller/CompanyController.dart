import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../Model/ProfileModel.dart';
import '../Model/QRModel.dart';
import '../Model/SingleCompanyModel.dart';
import '../Model/CompanyModel.dart';
import '../Model/SummaryModel.dart';
import '../Service/GraphqlService/Graphql_Service.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class CompanyController {
  final GraphQLService graphqlService;

  CompanyController(this.graphqlService);

  Future<List<LogDetails>?> fetchLogs({required int adminId}) async {
    const String query = r'''
    query GetLogs($adminId: Int!) {
      logs(adminId: $adminId, searchText: "", date: null) {
        availableSlots
        occupiedSlots
        todayRevenue
        totalSlots
        logs {
          entryDate
          entryId
          entrytime
          exittime
          isExit
          logid
          paymentMethod
          paymentStatus
          totalamount
          vehiclenumber
        }
      }
    }
  ''';

    try {
      final QueryResult result = await graphqlService.performQuery(
        query,
        variables: {'adminId': adminId},
      );

      if (result.hasException) {
        print("GraphQL exception: ${result.exception.toString()}");
        return null;
      }

      final logsWrapper = result.data?['logs'];
      final logList = logsWrapper?['logs'];

      if (logList != null) {
        final List<LogDetails> parsedLogs =
            (logList as List).map((json) => LogDetails.fromJson(json)).toList();
        return parsedLogs;
      } else {
        print("No logs found inside logs object.");
        return null;
      }
    } catch (e) {
      print("Exception in fetchLogs: $e");
      return null;
    }
  }

  Future<String?> fetchNewLogId() async {
    const query = '''
    query {
      newLogId
    }
  ''';

    try {
      final result = await graphqlService.performQuery(query);

      if (result.hasException) {
        print("GraphQL Error: ${result.exception}");
        return null;
      }

      final data = result.data;
      if (data != null) {
        final newLogIdResponse = NewLogId.fromJson({'data': data});
        return newLogIdResponse.data?.newLogId;
      }

      print("newLogId not found in response");
      return null;
    } catch (e) {
      print("Exception during newLogId fetch: $e");
      return null;
    }
  }

  Future<LogSummaryData?> fetchLogSummary({
    required int adminId,
    required String date,
  }) async {
    final String query = '''
    query {
      logSummary(adminId: $adminId, date: "$date") {
        cashRevenue
        parkedVehicles
        totalRevenue
        upiCardRevenue
        logs {
          entryDate
          entryId
          entrytime
          exittime
          isExit
          logid
          paymentMethod
          paymentStatus
          totalamount
          vehiclenumber
        }
      }
    }
  ''';

    try {
      final QueryResult result = await graphqlService.performQuery(query);

      if (result.hasException) {
        print("GraphQL Exception: ${result.exception.toString()}");
        return null;
      }

      final data = result.data;
      if (data != null && data['logSummary'] != null) {
        return LogSummaryData.fromJson(data['logSummary']);
      } else {
        print("logSummary is null.");
        return null;
      }
    } catch (e) {
      print("Exception in fetchLogSummary: $e");
      return null;
    }
  }

  Future<LogResponseWrapper?> fetchLogsWithSummary({
    required int adminId,
  }) async {
    const String query = r'''
    
    
    query GetLogs($adminId: Int!) {
      logs(adminId: $adminId, searchText: "", date: null) {
        availableSlots
        occupiedSlots
        todayRevenue
        totalSlots
        logs {
          entryDate
          entryId
          entrytime
          exittime
          isExit
          logid
          paymentMethod
          paymentStatus
          totalamount
          vehiclenumber
        }
      }
    }
  ''';

    try {
      final QueryResult result = await graphqlService.performQuery(
        query,
        variables: {'adminId': adminId},
      );

      if (result.hasException) {
        print("GraphQL exception: ${result.exception}");
        return null;
      }

      final logsWrapper = result.data?['logs'];
      final logList = logsWrapper?['logs'];

      if (logsWrapper != null && logList != null) {
        final List<LogDetails> parsedLogs =
            (logList as List).map((json) => LogDetails.fromJson(json)).toList();

        return LogResponseWrapper(
          availableSlots: (logsWrapper['availableSlots'] as num?)?.toInt() ?? 0,
          totalSlots: (logsWrapper['totalSlots'] as num?)?.toInt() ?? 0,
          occupiedSlots: (logsWrapper['occupiedSlots'] as num?)?.toInt() ?? 0,
          todayRevenue: (logsWrapper['todayRevenue'] as num?)?.toInt() ?? 0,
          logs: parsedLogs,
        );
      } else {
        print("Logs or counts are missing in the response.");
        return null;
      }
    } catch (e) {
      print("Exception in fetchLogs: $e");
      return null;
    }
  }

  Future<EntryResponse> createEntry({
    required int adminId,
    String? customerPhone,
    required String entryDate,
    required String entryTime,
    String? exitTime,
    String? imageUrl,
    required String logId,
    String? paymentMethod,
    String? paymentStatus,
    double? totalAmount,
    required String vehicleNumber,
  }) async {
    const String mutation = r'''
    
mutation CreateEntry(
  $adminId: Int!,
  $customerPhone: String,
  $entryDate: LocalDate!,
  $entryTime: String!,
  $exitTime: String,
  $imageUrl: String,
  $logId: String!,
  $paymentMethod: String,
  $paymentStatus: String,
  $totalAmount: Decimal,
  $vehicleNumber: String!
) {
  createEntry(
    input: {
      adminId: $adminId,
      customerPhone: $customerPhone,
      entryDate: $entryDate,
      entryTime: $entryTime,
      exitTime: $exitTime,
      imageUrl: $imageUrl,
      logId: $logId,
      paymentMethod: $paymentMethod,
      paymentStatus: $paymentStatus,
      totalAmount: $totalAmount,
      vehicleNumber: $vehicleNumber
    }
  ) {
    message
    success
  }
}

''';

    final variables = {
      "adminId": adminId,
      "customerPhone": customerPhone,
      "entryDate": entryDate,
      "entryTime": entryTime,
      "exitTime": exitTime,
      "imageUrl": imageUrl,
      "logId": logId,
      "paymentMethod": paymentMethod,
      "paymentStatus": paymentStatus,
      "totalAmount": totalAmount,
      "vehicleNumber": vehicleNumber,
    };

    try {
      final QueryResult result = await graphqlService.performMutation(
        mutation,
        variables: variables,
      );

      if (result.hasException) {
        final errorMessage =
            result.exception?.graphqlErrors.isNotEmpty == true
                ? result.exception!.graphqlErrors.first.message
                : "An unknown error occurred.";
        print("GraphQL exception: $errorMessage");
        throw errorMessage;
      }

      final response = result.data?['createEntry'];
      if (response != null && response['success'] == true) {
        return EntryResponse.fromJson(response);
      } else {
        final errorMessage = response?['message'] ?? "Failed to create entry.";
        print("Mutation failed: $errorMessage");
        throw errorMessage;
      }
    } catch (e) {
      print("Exception in createEntry: $e");
      rethrow;
    }
  }

  // Fetch  Single Entry by id  Query
  Future<LogDetails?> getLogByVehicle(int entryId) async {
    const String query = r'''
    query GetLogByVehicle($entryid: Int!) {
      logByVehicle(entryid: $entryid) {
        adminid
        createdat
        entrydate
        entryid
        entrytime
        exittime
        isexit
        logid
        notes
        parkinglotid
        paymentstatus
        qrcodedata
        qrcodeurl
        totalamount
        totalhours
        updatedat
        paymentdetails {
          createdat
          entryid
          paymentamount
          paymentid
          paymentmethod
          paymenttime
          status
        }
        vehicledetails {
          createdat
          customername
          customerphone
          entryid
          imageurl
          updatedat
          vehicledetailsid
          vehiclenumber
        }
      }
    }
  ''';

    final Map<String, dynamic> variables = {'entryid': entryId};

    try {
      final QueryResult result = await graphqlService.performQuery(
        query,
        variables: variables,
      );

      if (result.hasException) {
        print("GraphQL exception: ${result.exception.toString()}");
        return null;
      }

      final data = result.data?['logByVehicle'];
      if (data != null) {
        return LogDetails.fromJson(data);
      } else {
        print("Query returned null data.");
        return null;
      }
    } catch (e) {
      print("Exception in getLogByVehicle: $e");
      return null;
    }
  }

  Future<LogDetails?> updateEntry({
    required int entryId,
    String? exitTime,
    String? imageUrl,
    bool? isExit,
    String? paymentMethod,
    String? paymentStatus,
    double? totalAmount,
  }) async {
    const String mutation = r'''
  mutation UpdateEntry(
    $entryId: Int!,
    $exitTime: String,
    $imageUrl: String,
    $isexit: Boolean,
    $paymentMethod: String,
    $paymentStatus: String,
    $totalAmount: Decimal
  ) {
    updateEntry(
      entryId: $entryId,
      input: {
        exitTime: $exitTime,
        imageUrl: $imageUrl,
        isexit: $isexit,
        paymentMethod: $paymentMethod,
        paymentStatus: $paymentStatus,
        totalAmount: $totalAmount
      }
    ) {
      message
      success
      data {
        adminid
        createdat
        entrydate
        entryid
        entrytime
        exittime
        isexit
        logid
        notes
        paymentstatus
        totalamount
        updatedat
      }
    }
  }
  ''';

    final variables = {
      "entryId": entryId,
      "exitTime": exitTime,
      "imageUrl": imageUrl,
      "isexit": isExit,
      "paymentMethod": paymentMethod,
      "paymentStatus": paymentStatus,
      "totalAmount": totalAmount,
    };

    try {
      final QueryResult result = await graphqlService.performMutation(
        mutation,
        variables: variables,
      );

      if (result.hasException) {
        print("GraphQL exception: ${result.exception.toString()}");
        return null;
      }

      final response = result.data?['updateEntry'];
      if (response != null && response['success'] == true) {
        final entryJson = response['data'];
        return LogDetails.fromJson(entryJson);
      } else {
        print("Mutation failed: ${response?['message']}");
        return null;
      }
    } catch (e) {
      print("Exception in updateEntry: $e");
      return null;
    }
  }

  // Future<QrCodeDetails?> generateQrCode(int entryId) async {
  //   const String mutation = r'''
  //   mutation GenerateQrCode($entryId: Int!) {
  //     generateQrCodeForEntry(entryId: $entryId) {
  //       message
  //       success
  //       data {
  //         amount
  //         entryId
  //         qrCodeUrl
  //       }
  //     }
  //   }
  // ''';
  //
  //   final variables = {"entryId": entryId};
  //
  //   try {
  //     final QueryResult result = await graphqlService.performMutation(
  //       mutation,
  //       variables: variables,
  //     );
  //
  //     // ✅ STEP 1: Add this line to debug raw response
  //     print("Raw QR response: ${result.data}");
  //
  //     if (result.hasException) {
  //       final errorMessage =
  //           result.exception?.graphqlErrors.isNotEmpty == true
  //               ? result.exception!.graphqlErrors.first.message
  //               : "Unknown error while generating QR.";
  //       print("QR Mutation error: $errorMessage");
  //       throw errorMessage;
  //     }
  //
  //     // ✅ STEP 2: Handle success flag properly
  //     final qrResponse = QR.fromJson(result.data ?? {});
  //     final response = qrResponse.data?.generateQrCodeForEntry;
  //
  //     if (response?.success == true) {
  //       return response!.data;
  //     } else {
  //       print("GraphQL reported failure: ${response?.message}");
  //       return null;
  //     }
  //   } catch (e) {
  //     print("Exception in generateQrCode: $e");
  //     return null;
  //   }
  // }

  Future<QrCodeDetails?> generateQrCode(int entryId) async {
    const String mutation = r'''
    mutation GenerateQrCode($entryId: Int!) {
      generateQrCodeForEntry(entryId: $entryId) {
        message
        success
        data {
          amount
          entryId
          qrCodeUrl
        }
      }
    }
  ''';

    final variables = {"entryId": entryId};

    try {
      final QueryResult result = await graphqlService.performMutation(
        mutation,
        variables: variables,
      );

      print("Raw QR response: ${result.data}");

      if (result.hasException) {
        final errorMessage =
            result.exception?.graphqlErrors.isNotEmpty == true
                ? result.exception!.graphqlErrors.first.message
                : "Unknown error while generating QR.";
        print("QR Mutation error: $errorMessage");
        throw errorMessage;
      }

      final data = result.data?['generateQrCodeForEntry'];
      if (data == null) {
        print("GraphQL: generateQrCodeForEntry is null");
        return null;
      }

      if (data['success'] == true && data['data'] != null) {
        final qrDetails = QrCodeDetails.fromJson(data['data']);
        return qrDetails;
      } else {
        print("GraphQL reported failure: ${data['message']}");
        return null;
      }
    } catch (e) {
      print("Exception in generateQrCode: $e");
      return null;
    }
  }
}
