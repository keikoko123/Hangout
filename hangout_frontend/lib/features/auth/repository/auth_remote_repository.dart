import 'dart:convert';

import 'package:hangout_frontend/core/constants/constants.dart';
import 'package:hangout_frontend/core/services/sp_service.dart';
import 'package:hangout_frontend/features/auth/repository/auth_local_repository.dart';
import 'package:hangout_frontend/model/user_model.dart';
import 'package:http/http.dart' as http;

class AuthRemoteRepository {
  final spService = SpService();
  final authLocalRepository = AuthLocalRepository();

  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final res = await http.post(
        Uri.parse(
          '${Constants.backendUri}/auth/signup',
        ),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      if (res.statusCode != 201) {
        throw jsonDecode(res.body)['error'];
      }

      return UserModel.fromJson(res.body);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await http.post(
        Uri.parse(
          '${Constants.backendUri}/auth/login',
        ),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (res.statusCode != 200) {
        throw jsonDecode(res.body)['error'];
      }

      return UserModel.fromJson(res.body);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<UserModel?> getUserData() async {
    try {
      final token = await spService.getToken();

      print("token: ${token}");
      if (token == null) {
        // throw 'Token is null';
        return null;
      }

      final res = await http.post(
        Uri.parse(
          '${Constants.backendUri}/auth/tokenIsValid',
        ),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
      );

      print(res.body);
      if (res.statusCode != 200 || jsonDecode(res.body) == false) {
        return null;
      }

      final userResponse = await http.get(
        Uri.parse(
          '${Constants.backendUri}/auth',
        ),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
      );

      print('userResponse.body' + userResponse.body);

      if (userResponse.statusCode != 200) {
        throw jsonDecode(userResponse.body)['error'];
      }
      return UserModel.fromJson(userResponse.body); //! not res.body
    } catch (e) {
      // print(e);
      final user = await authLocalRepository.getUser();
      print('user in authLocalRepository: $user');
      return user;

      // print(e);
      // return null;
    }
  }

  // Update user's MBTI profile
  Future<UserModel> updateUserMbti({
    required int eiScore,
    required int snScore,
    required int tfScore,
    required int jpScore,
    required String mbtiType,
    int? gameCoin,
  }) async {
    try {
      final token = await spService.getToken();

      if (token == null) {
        throw 'Token is null';
      }

      print('Sending MBTI update to: http://10.0.2.2:8000/users/profile/');
      print(
          'MBTI Data: E/I=$eiScore, S/N=$snScore, T/F=$tfScore, J/P=$jpScore, Type=$mbtiType');

      // Create the request body
      final Map<String, dynamic> requestBody = {
        'mbti_e_i_score': eiScore,
        'mbti_s_n_score': snScore,
        'mbti_t_f_score': tfScore,
        'mbti_j_p_score': jpScore,
        'mbti_type': mbtiType,
      };

      // Only add gameCoin if provided
      if (gameCoin != null) {
        requestBody['game_coin'] = gameCoin;
      }

      final res = await http.post(
        Uri.parse(
          'http://10.0.2.2:8000/users/profile/',
        ),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
        body: jsonEncode(requestBody),
      );

      print('Response status: ${res.statusCode}');
      print('Response body: ${res.body}');

      if (res.statusCode != 200) {
        throw jsonDecode(res.body)['error'] ??
            'Failed to update profile: ${res.statusCode}';
      }

      return UserModel.fromJson(res.body);
    } catch (e) {
      print('Error updating MBTI profile: $e');
      throw e.toString();
    }
  }

  // Update user profile
  Future<UserModel> updateUserProfile({
    String? name,
    String? email,
    String? bio,
    String? profileImage,
    int? mbtiEIScore,
    int? mbtiSNScore,
    int? mbtiTFScore,
    int? mbtiJPScore,
    String? mbtiType,
  }) async {
    try {
      final token = await spService.getToken();

      if (token == null) {
        throw 'Token is null';
      }

      // Create request body with only the fields that are provided
      final Map<String, dynamic> requestBody = {};

      if (name != null) requestBody['name'] = name;
      if (email != null) requestBody['email'] = email;
      if (bio != null) requestBody['bio'] = bio;
      if (profileImage != null) requestBody['profileImage'] = profileImage;
      if (mbtiEIScore != null) requestBody['mbtiE_I_score'] = mbtiEIScore;
      if (mbtiSNScore != null) requestBody['mbtiS_N_score'] = mbtiSNScore;
      if (mbtiTFScore != null) requestBody['mbtiT_F_score'] = mbtiTFScore;
      if (mbtiJPScore != null) requestBody['mbtiJ_P_score'] = mbtiJPScore;
      if (mbtiType != null) requestBody['mbtiType'] = mbtiType;

      print('Sending profile update to: http://10.0.2.2:8000/users/profile');
      print('Request body: $requestBody');
      print('Using token: $token');

      final res = await http.put(
        Uri.parse('http://10.0.2.2:8000/users/profile'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
        body: jsonEncode(requestBody),
      );

      print('Response status: ${res.statusCode}');
      print('Response body: ${res.body}');

      if (res.statusCode != 200) {
        throw jsonDecode(res.body)['error'] ??
            'Failed to update profile: ${res.statusCode}';
      }

      return UserModel.fromJson(res.body);
    } catch (e) {
      print('Error updating user profile: $e');
      throw e.toString();
    }
  }

  // Update complete user profile with MBTI data
  Future<UserModel> updateCompleteUserProfile({
    required String name,
    required String email,
    String? bio,
    String? profileImage,
    required int mbtiEIScore,
    required int mbtiSNScore,
    required int mbtiTFScore,
    required int mbtiJPScore,
    required String mbtiType,
    int? gameCoin,
  }) async {
    try {
      final token = await spService.getToken();
      print('Token from spService: $token');

      if (token == null || token.isEmpty) {
        throw 'Token is null or empty';
      }

      // Create complete user profile request body
      final Map<String, dynamic> requestBody = {
        "name": name,
        "email": email,
        "bio": bio ?? "",
        "profileImage": profileImage ?? "",
        "mbtiE_I_score": mbtiEIScore,
        "mbtiS_N_score": mbtiSNScore,
        "mbtiT_F_score": mbtiTFScore,
        "mbtiJ_P_score": mbtiJPScore,
        "mbtiType": mbtiType,
      };

      // Only add gameCoin if it's provided
      if (gameCoin != null) {
        requestBody["gameCoin"] = gameCoin;
      }

      // Change to match what's working in dashboard_page (use direct URL rather than Constants)
      final baseUrl = 'http://10.0.2.2:8000';
      final url = '$baseUrl/users/profile';

      print('Sending PUT request to: $url');
      print('Complete request body: ${jsonEncode(requestBody)}');
      print('Using token: $token');

      // Make PUT request
      final res = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
        body: jsonEncode(requestBody),
      );

      print('Response status: ${res.statusCode}');
      print('Response body: ${res.body}');

      // Add more detailed error logging
      if (res.statusCode != 200) {
        final errorMsg = res.body.isNotEmpty
            ? 'Error: ${jsonDecode(res.body)['error'] ?? 'Unknown error'}'
            : 'Failed to update profile: HTTP ${res.statusCode}';
        print('PROFILE UPDATE FAILED: $errorMsg');
        throw errorMsg;
      }

      print('PROFILE UPDATE SUCCESSFUL: ${res.body}');
      return UserModel.fromJson(res.body);
    } catch (e) {
      print('Error updating complete user profile: $e');
      throw e.toString();
    }
  }
}
