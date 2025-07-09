import 'dart:convert';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Model/CompanyModel.dart';
import '../Model/ProfileModel.dart';
import '../Model/UserModel.dart';
import '../Service/GraphqlService/Graphql_Service.dart';

class UserController extends GetxController {
  var userData = UserData().obs;

  void setUserData(UserData data) {
    userData.value = data;
  }

  final GraphQLService graphqlService;

  UserController(this.graphqlService);

  Map<String, dynamic>? lastResponseData;

  String loginMutation = r'''
    mutation Login($username: String!, $password: String!) {
      loginUser(username: $username, password: $password) {
        message
        success
        data {
          createdat
          email
          fullname
          isactive
          isadmin
          passwordhash
          phonenumber
          userid
          username
          parkinglots {
            location
          }
        }
      }
    }
  ''';

  Future<LoginResponse?> loginUser(String username, String password) async {
    final variables = {"username": username, "password": password};

    try {
      final result = await graphqlService.performMutation(
        loginMutation,
        variables: variables,
      );

      if (result.hasException) {
        print("Login Error: ${result.exception}");
        return null;
      }

      final data = result.data?['loginUser'];
      if (data == null) {
        print("Login response missing.");
        return null;
      }

      final loginResponse = LoginResponse.fromJson(data);

      // ✅ Save nested user data
      final prefs = await SharedPreferences.getInstance();
      final user = loginResponse.data;

      if (user != null) {
        await prefs.setInt('userId', user.userid ?? 0);
        await prefs.setString('username', user.username ?? '');
        await prefs.setString('email', user.email ?? '');
        await prefs.setString('fullname', user.fullname ?? '');
      }

      // Save entire user object as JSON (optional)
      await prefs.setString('loginData', jsonEncode(loginResponse.toJson()));

      return loginResponse;
    } catch (e) {
      print("Login Exception: $e");
      return null;
    }
  }

  Future<bool> createCompanyProfile({
    required int companyuserId,
    required String name,
    required String role,
    String? imageUrl,
  }) async {
    const String mutation = r'''
    mutation CreateCompanyProfile(
      $companyuserId: Int!,
      $name: String!,
      $role: String!,
      $imageUrl: String
    ) {
      createCompanyProfile(
        companyuserId: $companyuserId,
        name: $name,
        role: $role,
        imageUrl: $imageUrl
      ) {
        message
        success
        data {
          companyprofileId
          companyuserid
          createdAt
          email
          imageUrl
          role
          updatedAt
        }
      }
    }
  ''';

    final variables = {
      "companyuserId": companyuserId,
      "name": name,
      "role": role,
      "imageUrl": imageUrl,
    };

    try {
      final result = await graphqlService.performMutation(
        mutation,
        variables: variables,
      );

      if (result.hasException) {
        print("GraphQL exception: ${result.exception.toString()}");
        return false;
      }

      final companyProfileResponse = result.data?['createCompanyProfile'];
      if (companyProfileResponse != null &&
          companyProfileResponse['success'] == true) {
        final companyProfileJson = companyProfileResponse['data'];

        // Parse the response into a CompanyProfileData object
        final profileData = CompanyProfileData.fromJson(companyProfileJson);

        // Save to SharedPreferences or any storage
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('companyProfile', jsonEncode(profileData.toJson()));

        return true;
      } else {
        print("Mutation failed: ${companyProfileResponse?['message']}");
        return false;
      }
    } catch (e) {
      print("Exception in createCompanyProfile: $e");
      return false;
    }
  }

  Future<bool> updateCompanyProfile({
    required int companyuserId,
    required String name,
    required String role,
    String? imageUrl,
  }) async {
    const String mutation = r'''
    mutation UpdateCompanyProfile(
      $companyuserId: Int!,
      $name: String!,
      $role: String!,
      $imageUrl: String
    ) {
      updateCompanyProfile(
        companyuserId: $companyuserId,
        name: $name,
        role: $role,
        imageUrl: $imageUrl
      ) {
        message
        success
        data {
          companyprofileId
          companyuserid
          createdAt
          role
          imageUrl
          name
          updatedAt
        }
      }
    }
  ''';

    final variables = {
      'companyuserId': companyuserId,
      'name': name,
      'role': role,
      'imageUrl': imageUrl,
    };

    try {
      final result = await graphqlService.performMutation(
        mutation,
        variables: variables,
      );

      if (result.hasException) {
        print('GraphQL Error: ${result.exception.toString()}');
        return false;
      }

      final updateResponse = result.data?['updateCompanyProfile'];
      if (updateResponse != null && updateResponse['success'] == true) {
        final companyProfileJson = updateResponse['data'];

        final profileData = CompanyProfileData.fromJson(companyProfileJson);

        final prefs = await SharedPreferences.getInstance();
        prefs.setString('companyProfile', jsonEncode(profileData.toJson()));

        return true;
      } else {
        print("Mutation failed: ${updateResponse?['message']}");
        return false;
      }
    } catch (e) {
      print('Exception in updateCompanyProfile: $e');
      return false;
    }
  }

  Future<ForgotPasswordOtpResponse?> sendForgotPasswordOtp(
    String emailOrPhone,
  ) async {
    final variables = {"email": emailOrPhone};

    const String mutation = r'''
    mutation($email: String!) {
      forgotPasswordOtp(email: $email) {
        message
        success
        data {
          createdAt
          expiresAt
          isUsed
          otpcode
          otpid
          purpose
          userid
        }
      }
    }
  ''';

    try {
      final result = await graphqlService.performMutation(
        mutation,
        variables: variables,
      );

      if (result.hasException) {
        print("ForgotPasswordOtp Error: ${result.exception}");
        return null;
      }

      final data = result.data?['forgotPasswordOtp'];
      if (data == null) return null;

      return ForgotPasswordOtpResponse.fromJson({"forgotPasswordOtp": data});
    } catch (e) {
      print("ForgotPasswordOtp Exception: $e");
      return null;
    }
  }

  Future<OtpVerification?> verifyOtp(int userId, String enteredOtp) async {
    final variables = {"userId": userId, "enteredOtp": enteredOtp};

    const String mutation = r'''
    mutation($userId: Int!, $enteredOtp: String!) {
      verifyOtp(userId: $userId, enteredOtp: $enteredOtp) {
        message
        success
        data {
          createdAt
          userid
          otpcode
        }
      }
    }
  ''';

    try {
      final result = await graphqlService.performMutation(
        mutation,
        variables: variables,
      );

      if (result.hasException) {
        print("verifyOtp Error: ${result.exception}");
        return null;
      }

      final data = result.data?['verifyOtp'];
      if (data == null) return null;

      // Wrap response under the expected structure
      return OtpVerification.fromJson({
        "data": {"verifyOtp": data},
      });
    } catch (e) {
      print("verifyOtp Exception: $e");
      return null;
    }
  }

  Future<OtpSuccess?> updateUserPassword(int userId, String newPassword) async {
    final variables = {
      "userid": userId,
      "input": {
        "passwordhash": newPassword,
      },
    };

    const String mutation = r'''
    mutation($userid: Int!, $input: UpdateUserInput!) {
      updateUser(userid: $userid, input: $input) {
        message
        success
      }
    }
  ''';

    try {
      final result = await graphqlService.performMutation(
        mutation,
        variables: variables,
      );

      if (result.hasException) {
        print("updateUser Error: ${result.exception}");
        return null;
      }

      final data = result.data?['updateUser'];
      if (data == null) return null;

      return OtpSuccess.fromJson({
        "data": {
          "updateUser": data,
        }
      });
    } catch (e) {
      print("updateUser Exception: $e");
      return null;
    }
  }


}
