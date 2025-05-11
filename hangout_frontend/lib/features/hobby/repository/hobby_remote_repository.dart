import 'dart:convert';

import 'package:hangout_frontend/core/constants/constants.dart';
import 'package:hangout_frontend/features/hobby/repository/hobby_local_repository.dart';
import 'package:hangout_frontend/model/hobby_model.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class HobbyRemoteRepository {
  final hobbyLocalRepository = HobbyLocalRepository();
  final String baseUrl = Constants.backendUri;

  Future<HobbyModel> createHobby({
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
      final res = await http.post(Uri.parse("$baseUrl/hobbies"),
          headers: {
            'Content-Type': 'application/json',
            'x-auth-token': token,
          },
          body: jsonEncode(
            {
              'name': name,
              'description': description,
              'category': category,
              'subcategory': subcategory,
              'icon': icon,
              'equipment': equipment,
              'costLevel': costLevel,
              'indoorOutdoor': indoorOutdoor,
              'socialLevel': socialLevel,
              'ageRange': ageRange,
              'popularity': popularity,
              'imageUrl': imageUrl,
              'mbtiE_I_score': mbtiE_I_score,
              'mbtiS_N_score': mbtiS_N_score,
              'mbtiT_F_score': mbtiT_F_score,
              'mbtiJ_P_score': mbtiJ_P_score,
              'mbtiE_I': mbtiE_I,
              'mbtiS_N': mbtiS_N,
              'mbtiT_F': mbtiT_F,
              'mbtiJ_P': mbtiJ_P,
              'mbtiCompatibility': mbtiCompatibility,
            },
          ));

      if (res.statusCode != 201) {
        throw jsonDecode(res.body)['error'];
      }

      return HobbyModel.fromJson(res.body);
    } catch (e) {
      // if offline, try catch to save to local db
      try {
        final hobbyModel = HobbyModel(
          id: const Uuid().v6(),
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
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isSynced: 0,
        );
        // SYNC to offline db
        await hobbyLocalRepository.insertHobby(hobbyModel);
        return hobbyModel;
      } catch (e) {
        rethrow;
      }
    }
  }

  Future<List<HobbyModel>> getHobbies({required String token}) async {
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/hobbies"),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
      );

      if (res.statusCode != 200) {
        throw jsonDecode(res.body)['error'];
      }

      final listOfHobbies = jsonDecode(res.body);
      List<HobbyModel> hobbiesList = [];

      for (var element in listOfHobbies) {
        hobbiesList.add(HobbyModel.fromMap(element));
      }
      // SYNC to offline db
      await hobbyLocalRepository.insertHobbies(hobbiesList);

      return hobbiesList;
    } catch (e) {
      final hobbies = await hobbyLocalRepository.getHobbies();
      if (hobbies.isNotEmpty) {
        return hobbies; //rethrow a true result to view by local DB
      }
      rethrow;
    }
  }

  // Method to get hobbies without authentication
  Future<List<HobbyModel>> getPublicHobbies() async {
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/hobbies"),
      );

      if (res.statusCode != 200) {
        throw jsonDecode(res.body)['error'];
      }

      final listOfHobbies = jsonDecode(res.body);
      List<HobbyModel> hobbiesList = [];

      for (var element in listOfHobbies) {
        hobbiesList.add(HobbyModel.fromMap(element));
      }

      return hobbiesList;
    } catch (e) {
      print("Error fetching public hobbies: $e");
      rethrow;
    }
  }

  Future<bool> syncHobbies({
    required String token,
    required List<HobbyModel> hobbies,
  }) async {
    try {
      final hobbyListInMap = [];
      for (final hobby in hobbies) {
        hobbyListInMap.add(hobby.toMap());
      }
      final res = await http.post(
        Uri.parse("$baseUrl/hobbies/sync"),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
        body: jsonEncode(hobbyListInMap),
      );

      if (res.statusCode != 201) {
        throw jsonDecode(res.body)['error'];
      }

      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }
}
