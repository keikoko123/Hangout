part of 'hobbies_cubit.dart';

sealed class HobbiesState {
  const HobbiesState();
}

final class HobbiesInitial extends HobbiesState {}

final class HobbiesLoading extends HobbiesState {}

final class HobbiesError extends HobbiesState {
  final String error;
  HobbiesError(this.error);
}

final class AddNewHobbySuccess extends HobbiesState {
  final HobbyModel hobbyModel;
  const AddNewHobbySuccess(this.hobbyModel);
}

final class GetHobbiesSuccess extends HobbiesState {
  final List<HobbyModel> hobbies;
  const GetHobbiesSuccess(this.hobbies);
}
