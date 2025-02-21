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

  void getUserData() async {
    try {
      emit(AuthLoading());
      final userModel = await authRemoteRepository.getUserData();
      print('userModel: ${userModel}');
      if (userModel != null) {
        await authLocalRepository.insertUser(userModel);
        // first: SYNC to offline db , then: change state
        emit(AuthLoggedIn(userModel));
      } else {
        emit(AuthInitial());
      }
    } catch (e) {
      // emit(AuthError("27: SomethingWrong !\n" + e.toString()));
      print("27: $e");
      emit(AuthInitial());
      // emit(AuthError("27: SomethingWrong !\n" + e.toString()));
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
        await spService.setToken(userModel.token);
      }

      await authLocalRepository.insertUser(userModel);

      emit(AuthLoggedIn(userModel));
    } catch (e) {
      emit(AuthError("67: Login failed! Pls try again!"));
    }
  }
}
