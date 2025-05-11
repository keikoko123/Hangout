import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hangout_frontend/core/services/sp_service.dart';
import 'package:hangout_frontend/features/auth/repository/auth_local_repository.dart';
import 'package:hangout_frontend/features/auth/repository/auth_remote_repository.dart';
import 'package:hangout_frontend/model/user_model.dart';

class UserRepository {
  final AuthRemoteRepository _remoteRepository;
  final AuthLocalRepository _localRepository;
  final SpService _spService;
  final String _baseUrl = 'http://localhost:8000'; // Base URL for API

  UserRepository({
    AuthRemoteRepository? remoteRepository,
    AuthLocalRepository? localRepository,
    SpService? spService,
  })  : _remoteRepository = remoteRepository ?? AuthRemoteRepository(),
        _localRepository = localRepository ?? AuthLocalRepository(),
        _spService = spService ?? SpService();

  // Get current user data, prioritizing remote source
  Future<UserModel?> getUserData() async {
    try {
      // Check if we have a user ID stored
      final userId = await _spService.getId();
      if (userId != null && userId.isNotEmpty) {
        // Try to get user by ID first if we have one
        final userById = await getUserById(userId);
        if (userById != null) {
          return userById;
        }
      }

      // Fall back to regular auth endpoint
      final remoteUser = await _remoteRepository.getUserData();

      if (remoteUser != null) {
        // Save user ID for future use
        await _spService.setId(remoteUser.id);

        // Update local storage
        await _localRepository.insertUser(remoteUser);
        return remoteUser;
      }

      // Fall back to local storage
      return await _localRepository.getUser();
    } catch (e) {
      print("Error in UserRepository.getUserData: $e");
      // Try to get from local storage
      return await _localRepository.getUser();
    }
  }

  // Fetch user by ID directly from server
  Future<UserModel?> getUserById(String userId) async {
    try {
      final token = await _spService.getToken();

      if (token == null || token.isEmpty) {
        throw Exception("No authentication token found");
      }

      // Use the proper emulator URL instead of localhost
      final baseUrl = 'http://10.0.2.2:8000';

      print("UserRepository: Fetching user from $baseUrl/users/$userId");

      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
      );

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        final userModel = UserModel.fromMap(userData);

        // Save user ID
        await _spService.setId(userModel.id);

        // Update local storage with fresh data
        await _localRepository.insertUser(userModel);

        print("UserRepository: Successfully fetched user by ID: $userId");
        return userModel;
      } else {
        print(
            "UserRepository: Failed to fetch user by ID: ${response.statusCode}");
        print("UserRepository: Response body: ${response.body}");
        return null;
      }
    } catch (e) {
      print("UserRepository: Error fetching user by ID: $e");
      // Fall back to local storage
      return await _localRepository.getUser();
    }
  }

  // Update MBTI profile
  Future<UserModel> updateMbtiProfile({
    required int eiScore,
    required int snScore,
    required int tfScore,
    required int jpScore,
    required String mbtiType,
    required int gameCoin,
  }) async {
    final userModel = await _remoteRepository.updateUserMbti(
      eiScore: eiScore,
      snScore: snScore,
      tfScore: tfScore,
      jpScore: jpScore,
      mbtiType: mbtiType,
      // gameCoin: gameCoin,
    );

    // Save user ID
    await _spService.setId(userModel.id);

    // Update local storage
    await _localRepository.insertUser(userModel);

    return userModel;
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
    final userModel = await _remoteRepository.updateUserProfile(
      name: name,
      email: email,
      bio: bio,
      profileImage: profileImage,
      mbtiEIScore: mbtiEIScore,
      mbtiSNScore: mbtiSNScore,
      mbtiTFScore: mbtiTFScore,
      mbtiJPScore: mbtiJPScore,
      mbtiType: mbtiType,
    );

    // Save user ID
    await _spService.setId(userModel.id);

    // Update local storage
    await _localRepository.insertUser(userModel);

    return userModel;
  }
}
