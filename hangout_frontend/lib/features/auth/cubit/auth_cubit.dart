import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hangout_frontend/core/services/sp_service.dart';
import 'package:hangout_frontend/features/auth/repository/auth_local_repository.dart';
import 'package:hangout_frontend/features/auth/repository/auth_remote_repository.dart';
import 'package:hangout_frontend/model/user_model.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());
  final authRemoteRepository = AuthRemoteRepository();
  final authLocalRepository = AuthLocalRepository();
  final spService = SpService();

  Future<bool> getUserData() async {
    try {
      emit(AuthLoading());
      // Always get the latest data from the server
      final userModel = await authRemoteRepository.getUserData();

      if (userModel != null) {
        // Update local database
        await authLocalRepository.insertUser(userModel);

        // Store the user ID for easier access later
        await spService.setId(userModel.id);

        // Update the app state with fresh data
        emit(AuthLoggedIn(userModel));
        return true;
      } else {
        final localUser = await authLocalRepository.getUser();
        if (localUser != null) {
          // If server fetch failed but we have local data, use that
          // Still save the user ID from local data
          await spService.setId(localUser.id);
          emit(AuthLoggedIn(localUser));
          return true;
        } else {
          // No user data available
          emit(AuthInitial());
          return false;
        }
      }
    } catch (e) {
      print("Error fetching user data: $e");

      // Try to get data from local storage as fallback
      try {
        final localUser = await authLocalRepository.getUser();
        if (localUser != null) {
          // Save user ID from local data
          await spService.setId(localUser.id);
          emit(AuthLoggedIn(localUser));
          return true;
        }
      } catch (localError) {
        print("Error accessing local user data: $localError");
      }

      emit(AuthInitial());
      return false;
    }
  }

  void signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      emit(AuthLoading());
      await authRemoteRepository.signUp(
        name: name,
        email: email,
        password: password,
      );

      emit(AuthSignUp());
    } catch (e) {
      emit(AuthError(
          "44: SomethingWrong ! $name $email $password\n" + e.toString()));
    }
  }

  void login({
    required String email,
    required String password,
  }) async {
    try {
      emit(AuthLoading());
      final userModel = await authRemoteRepository.login(
        email: email,
        password: password,
      );

      if (userModel.token.isNotEmpty) {
        // Store token for authentication
        await spService.setToken(userModel.token);
        // Store user ID for direct fetching
        await spService.setId(userModel.id);
      }

      await authLocalRepository.insertUser(userModel);

      emit(AuthLoggedIn(userModel));
    } catch (e) {
      emit(AuthError("67: Login failed! Pls try again!"));
    }
  }

  // Update the user's MBTI profile
  void updateUserMbti({
    required int eiScore,
    required int snScore,
    required int tfScore,
    required int jpScore,
    required String mbtiType,
    required int gameCoin,
  }) async {
    try {
      emit(AuthLoading());
      print("AuthCubit: Starting MBTI update process");

      final userModel = await authRemoteRepository.updateUserMbti(
        eiScore: eiScore,
        snScore: snScore,
        tfScore: tfScore,
        jpScore: jpScore,
        mbtiType: mbtiType,
        // gameCoin: gameCoin,
      );

      print("AuthCubit: Update successful, updating local storage");

      // Update local storage
      await authLocalRepository.insertUser(userModel);

      print("AuthCubit: Local storage updated, emitting updated user state");

      // Emit updated user
      emit(AuthLoggedIn(userModel));

      print("AuthCubit: MBTI update complete");
    } catch (e) {
      print("AuthCubit ERROR: Failed to update MBTI profile: $e");

      // If update fails, we need to restore the previous state
      try {
        final currentUser = await authLocalRepository.getUser();
        if (currentUser != null) {
          print("AuthCubit: Restoring previous user state after error");
          emit(AuthLoggedIn(currentUser));
        } else {
          print("AuthCubit: No previous user state found");
          emit(AuthError("Failed to update MBTI profile: ${e.toString()}"));
        }
      } catch (innerError) {
        print("AuthCubit ERROR: Failed to restore previous state: $innerError");
        emit(AuthError("Failed to update MBTI profile: ${e.toString()}"));
      }
    }
  }

  // Update user profile in welcome form
  void updateUserProfile({
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
      emit(AuthLoading());
      print("AuthCubit: Starting profile update process");

      final userModel = await authRemoteRepository.updateUserProfile(
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

      print("AuthCubit: Update successful, updating local storage");

      // Update local storage
      await authLocalRepository.insertUser(userModel);

      print("AuthCubit: Local storage updated, emitting updated user state");

      // Emit updated user
      emit(AuthLoggedIn(userModel));

      print("AuthCubit: Profile update complete");
    } catch (e) {
      print("AuthCubit ERROR: Failed to update profile: $e");

      // If update fails, we need to restore the previous state
      try {
        final currentUser = await authLocalRepository.getUser();
        if (currentUser != null) {
          print("AuthCubit: Restoring previous user state after error");
          emit(AuthLoggedIn(currentUser));
        } else {
          print("AuthCubit: No previous user state found");
          emit(AuthError("Failed to update profile: ${e.toString()}"));
        }
      } catch (innerError) {
        print("AuthCubit ERROR: Failed to restore previous state: $innerError");
        emit(AuthError("Failed to update profile: ${e.toString()}"));
      }
    }
  }

  // Update the complete user profile including MBTI data
  Future<bool> updateCompleteUserProfile({
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
      emit(AuthLoading());
      print("AuthCubit: Starting complete profile update");

      final userModel = await authRemoteRepository.updateCompleteUserProfile(
        name: name,
        email: email,
        bio: bio,
        profileImage: profileImage,
        mbtiEIScore: mbtiEIScore,
        mbtiSNScore: mbtiSNScore,
        mbtiTFScore: mbtiTFScore,
        mbtiJPScore: mbtiJPScore,
        mbtiType: mbtiType,
        gameCoin: gameCoin,
      );

      print(
          "AuthCubit: Complete profile update successful, updating local storage");

      // Update local storage
      await authLocalRepository.insertUser(userModel);

      print("AuthCubit: Local storage updated, emitting updated user state");

      // Emit updated user
      emit(AuthLoggedIn(userModel));

      print("AuthCubit: Complete profile update process complete");
      return true;
    } catch (e) {
      print("AuthCubit ERROR: Failed to update complete profile: $e");

      // If update fails, we need to restore the previous state
      try {
        final currentUser = await authLocalRepository.getUser();
        if (currentUser != null) {
          print("AuthCubit: Restoring previous user state after error");
          emit(AuthLoggedIn(currentUser));
        } else {
          print("AuthCubit: No previous user state found");
          emit(AuthError("Failed to update profile: ${e.toString()}"));
        }
      } catch (innerError) {
        print("AuthCubit ERROR: Failed to restore previous state: $innerError");
        emit(AuthError("Failed to update profile: ${e.toString()}"));
      }
      return false;
    }
  }

  // Add logout functionality
  Future<void> logout() async {
    try {
      // Clear token
      await spService.setToken('');
      // Clear user ID
      await spService.setId('');

      // Clear local user data
      // Note: In a real app, you might want to keep some data cached

      // Set state to initial
      emit(AuthInitial());
    } catch (e) {
      print("Error during logout: $e");
      // Still try to reset the state even if clearing data fails
      emit(AuthInitial());
    }
  }

  // Method to refresh token and handle JWT issues
  Future<bool> refreshToken() async {
    try {
      emit(AuthLoading());
      print("AuthCubit: Attempting to refresh token");

      // Get the current token from shared preferences
      final token = await spService.getToken();
      if (token == null || token.isEmpty) {
        print("AuthCubit: No token found during refresh");
        emit(AuthInitial());
        return false;
      }

      // Try to validate the token with the server
      final userModel = await authRemoteRepository.getUserData();

      if (userModel != null) {
        // Update local database with fresh data
        await authLocalRepository.insertUser(userModel);

        // Make sure we have the user ID stored
        await spService.setId(userModel.id);

        // Update app state
        emit(AuthLoggedIn(userModel));
        print("AuthCubit: Token refresh successful");
        return true;
      } else {
        // Token validation failed
        print("AuthCubit: Token validation failed during refresh");
        emit(AuthInitial());
        return false;
      }
    } catch (e) {
      print("AuthCubit ERROR: Token refresh failed: $e");

      // Try to recover with local data if possible
      try {
        final localUser = await authLocalRepository.getUser();
        if (localUser != null) {
          // If we have local data, use it but force a re-login soon
          print("AuthCubit: Using local data during token refresh failure");
          emit(AuthLoggedIn(localUser));
          return true;
        }
      } catch (localError) {
        print("AuthCubit ERROR: Failed to access local user data: $localError");
      }

      // If all recovery attempts fail, reset to initial state
      emit(AuthInitial());
      return false;
    }
  }
}
