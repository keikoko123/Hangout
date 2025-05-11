import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hangout_frontend/core/services/sp_service.dart';
import 'package:hangout_frontend/features/user/repository/user_repository.dart';
import 'package:hangout_frontend/model/user_model.dart';

part 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  final UserRepository _userRepository;
  final SpService _spService;
  String? _currentUserId;

  UserCubit({
    UserRepository? userRepository,
    SpService? spService,
  })  : _userRepository = userRepository ?? UserRepository(),
        _spService = spService ?? SpService(),
        super(UserInitial()) {
    // Initialize by loading the saved user ID
    _loadSavedUserId();
  }

  // Load the user ID from persistent storage when the cubit is created
  Future<void> _loadSavedUserId() async {
    _currentUserId = await _spService.getId();

    // If we have a saved ID, try to load the user data
    if (_currentUserId != null && _currentUserId!.isNotEmpty) {
      await fetchUserById(_currentUserId!);
    }
  }

  // Getter for current user ID
  String? get currentUserId => _currentUserId;

  // Save the user ID to persistent storage
  Future<void> _saveUserId(String userId) async {
    _currentUserId = userId;
    await _spService.setId(userId);
  }

  // Fetch user data from remote API
  Future<void> fetchUserData() async {
    try {
      emit(UserLoading());

      // First try to get user data from repository
      final userModel = await _userRepository.getUserData();

      if (userModel != null) {
        // Store user ID for future direct queries
        await _saveUserId(userModel.id);
        emit(UserLoaded(userModel));
      } else {
        emit(UserError("Failed to load user data"));
      }
    } catch (e) {
      print("Error fetching user data: $e");
      emit(UserError("Failed to load user data: $e"));
    }
  }

  // Fetch user by ID directly (useful for refreshing dashboard data)
  Future<void> fetchUserById(String userId) async {
    if (userId.isEmpty) {
      print("UserCubit: Empty user ID provided to fetchUserById");
      await fetchUserData();
      return;
    }

    try {
      emit(UserLoading());
      print("UserCubit: Fetching user by ID: $userId (forced refresh)");

      // Get user directly from API by ID with forced refresh
      final userModel = await _userRepository.getUserById(userId);

      if (userModel != null) {
        print("UserCubit: Successfully fetched user by ID: $userId");
        print(
            "UserCubit: MBTI scores - E/I: ${userModel.mbtiEIScore}, S/N: ${userModel.mbtiSNScore}, T/F: ${userModel.mbtiTFScore}, J/P: ${userModel.mbtiJPScore}");

        _currentUserId = userModel.id; // Update current ID
        await _saveUserId(userModel.id);
        emit(UserLoaded(userModel));
      } else {
        print("UserCubit: User not found by ID: $userId, falling back");
        // Fall back to general fetch method if direct fetch fails
        await fetchUserData();
      }
    } catch (e) {
      print("UserCubit: Error fetching user by ID: $e");
      emit(UserError("Failed to load user data by ID: $e"));

      // Try to recover with fresh data fetch
      try {
        print("UserCubit: Attempting recovery with general fetch");
        await fetchUserData();
      } catch (fallbackError) {
        print("UserCubit: Recovery failed: $fallbackError");
        // Error state already emitted above
      }
    }
  }

  // Refresh current user data
  Future<void> refreshCurrentUser() async {
    if (_currentUserId != null) {
      await fetchUserById(_currentUserId!);
    } else {
      // Try to load saved ID first
      final savedId = await _spService.getId();
      if (savedId != null && savedId.isNotEmpty) {
        await fetchUserById(savedId);
      } else {
        await fetchUserData();
      }
    }
  }

  // Update MBTI scores
  Future<void> updateMbtiProfile({
    required int eiScore,
    required int snScore,
    required int tfScore,
    required int jpScore,
    required String mbtiType,
    required int gameCoin,
  }) async {
    try {
      emit(UserLoading());

      final userModel = await _userRepository.updateMbtiProfile(
        eiScore: eiScore,
        snScore: snScore,
        tfScore: tfScore,
        jpScore: jpScore,
        mbtiType: mbtiType,
        gameCoin: gameCoin,
      );

      // Store user ID
      await _saveUserId(userModel.id);

      // Emit updated user
      emit(UserLoaded(userModel));
    } catch (e) {
      print("UserCubit ERROR: Failed to update MBTI profile: $e");
      emit(UserError("Failed to update MBTI profile"));
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
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
      emit(UserLoading());

      final userModel = await _userRepository.updateUserProfile(
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

      // Store user ID
      await _saveUserId(userModel.id);

      // Emit updated user
      emit(UserLoaded(userModel));
    } catch (e) {
      print("UserCubit ERROR: Failed to update user profile: $e");
      emit(UserError("Failed to update user profile"));
    }
  }

  // Clear user data (for logout)
  Future<void> clearUserData() async {
    _currentUserId = null;
    await _spService.setId('');
    emit(UserInitial());
  }
}
