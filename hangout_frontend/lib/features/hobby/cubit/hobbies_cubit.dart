import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hangout_frontend/features/hobby/repository/hobby_local_repository.dart';
import 'package:hangout_frontend/features/hobby/repository/hobby_remote_repository.dart';
import 'package:hangout_frontend/model/hobby_model.dart';

part 'hobbies_state.dart';

class HobbiesCubit extends Cubit<HobbiesState> {
  HobbiesCubit() : super(HobbiesInitial());
  final hobbyRemoteRepository = HobbyRemoteRepository();
  final hobbyLocalRepository = HobbyLocalRepository();

  Future<void> createNewHobby({
    required String name,
    required String description,
    required String category,
    String? subcategory,
    required String icon,
    required List<String> equipment,
    required String costLevel,
    required String indoorOutdoor,
    required String socialLevel,
    required String ageRange,
    required int popularity,
    required String imageUrl,
    required int mbtiE_I_score,
    required int mbtiS_N_score,
    required int mbtiT_F_score,
    required int mbtiJ_P_score,
    required String mbtiE_I,
    required String mbtiS_N,
    required String mbtiT_F,
    required String mbtiJ_P,
    String? mbtiCompatibility,
    required String token,
  }) async {
    try {
      emit(HobbiesLoading());
      final hobbyModel = await hobbyRemoteRepository.createHobby(
        name: name,
        description: description,
        category: category,
        subcategory: subcategory,
        icon: icon,
        equipment: equipment,
        costLevel: costLevel,
        indoorOutdoor: indoorOutdoor,
        socialLevel: socialLevel,
        ageRange: ageRange,
        popularity: popularity,
        imageUrl: imageUrl,
        mbtiE_I_score: mbtiE_I_score,
        mbtiS_N_score: mbtiS_N_score,
        mbtiT_F_score: mbtiT_F_score,
        mbtiJ_P_score: mbtiJ_P_score,
        mbtiE_I: mbtiE_I,
        mbtiS_N: mbtiS_N,
        mbtiT_F: mbtiT_F,
        mbtiJ_P: mbtiJ_P,
        mbtiCompatibility: mbtiCompatibility,
        token: token,
      );

      // SYNC to offline db
      await hobbyLocalRepository.insertHobby(hobbyModel);

      emit(AddNewHobbySuccess(hobbyModel));
    } catch (e) {
      emit(HobbiesError(e.toString()));
    }
  }

  Future<void> getAllHobbies({required String token}) async {
    try {
      emit(HobbiesLoading());
      final hobbies = await hobbyRemoteRepository.getHobbies(token: token);
      emit(GetHobbiesSuccess(hobbies));
    } catch (e) {
      emit(HobbiesError(e.toString()));
    }
  }

  Future<void> getPublicHobbies() async {
    try {
      emit(HobbiesLoading());
      final hobbies = await hobbyRemoteRepository.getPublicHobbies();
      emit(GetHobbiesSuccess(hobbies));
    } catch (e) {
      print("Error fetching hobbies: ${e.toString()}");
      emit(HobbiesError("Error connecting to server: ${e.toString()}"));
    }
  }

  Future<void> syncHobbies(String token) async {
    // get all unsynced hobbies from our sqlite db
    final unsyncedHobbies = await hobbyLocalRepository.getUnsyncedHobbies();
    if (unsyncedHobbies.isEmpty) {
      return;
    }

    // send them to our server to sync
    final isSynced = await hobbyRemoteRepository.syncHobbies(
      token: token,
      hobbies: unsyncedHobbies,
    );

    if (isSynced) {
      // Update the isSynced value in the local db for each synced task
      for (final hobby in unsyncedHobbies) {
        await hobbyLocalRepository.updateRowValue(hobby.id, 1);
      }
    }
  }
}
