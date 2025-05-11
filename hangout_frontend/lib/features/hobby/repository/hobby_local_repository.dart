import 'package:hangout_frontend/model/hobby_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class HobbyLocalRepository {
  String tableName = "hobbies";

  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, "hobbies.db");
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
            CREATE TABLE $tableName(
              id TEXT PRIMARY KEY,
              name TEXT NOT NULL,
              description TEXT NOT NULL,
              category TEXT NOT NULL,
              subcategory TEXT,
              icon TEXT NOT NULL,
              equipment TEXT NOT NULL,
              costLevel TEXT NOT NULL,
              indoorOutdoor TEXT NOT NULL,
              socialLevel TEXT NOT NULL,
              ageRange TEXT NOT NULL,
              popularity INTEGER NOT NULL,
              imageUrl TEXT NOT NULL,
              mbtiE_I_score INTEGER NOT NULL,
              mbtiS_N_score INTEGER NOT NULL,
              mbtiT_F_score INTEGER NOT NULL,
              mbtiJ_P_score INTEGER NOT NULL,
              mbtiE_I TEXT NOT NULL,
              mbtiS_N TEXT NOT NULL,
              mbtiT_F TEXT NOT NULL,
              mbtiJ_P TEXT NOT NULL,
              mbtiCompatibility TEXT,
              createdAt TEXT NOT NULL,
              updatedAt TEXT NOT NULL,
              isSynced INTEGER NOT NULL
            )
      ''');
      },
    );
  }

  Future<void> insertHobby(HobbyModel hobby) async {
    final db = await database;
    await db.delete(tableName, where: 'id = ?', whereArgs: [hobby.id]);

    // Convert equipment list to JSON string for storage
    final Map<String, dynamic> hobbyMap = hobby.toMap();
    hobbyMap['equipment'] = hobby.equipment.join(',');

    await db.insert(tableName, hobbyMap);
  }

  Future<void> insertHobbies(List<HobbyModel> hobbies) async {
    final db = await database;
    final batch = db.batch();
    for (final hobby in hobbies) {
      // Convert equipment list to JSON string for storage
      final Map<String, dynamic> hobbyMap = hobby.toMap();
      hobbyMap['equipment'] = hobby.equipment.join(',');

      batch.insert(
        tableName,
        hobbyMap,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  Future<List<HobbyModel>> getHobbies() async {
    final db = await database;
    final result = await db.query(tableName);
    if (result.isNotEmpty) {
      List<HobbyModel> hobbies = [];
      for (final hobby in result) {
        // Convert equipment string back to list
        Map<String, dynamic> hobbyMap = Map<String, dynamic>.from(hobby);
        hobbyMap['equipment'] = (hobbyMap['equipment'] as String).split(',');

        hobbies.add(HobbyModel.fromMap(hobbyMap));
      }
      return hobbies;
    }

    return [];
  }

  Future<List<HobbyModel>> getUnsyncedHobbies() async {
    final db = await database;
    final result = await db.query(
      tableName,
      where: 'isSynced = ?',
      whereArgs: [0],
    );

    if (result.isNotEmpty) {
      List<HobbyModel> hobbies = [];
      for (final hobby in result) {
        // Convert equipment string back to list
        Map<String, dynamic> hobbyMap = Map<String, dynamic>.from(hobby);
        hobbyMap['equipment'] = (hobbyMap['equipment'] as String).split(',');

        hobbies.add(HobbyModel.fromMap(hobbyMap));
      }
      return hobbies;
    }

    return [];
  }

  Future<void> updateRowValue(String id, int newValue) async {
    final db = await database;
    await db.update(
      tableName,
      {'isSynced': newValue},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
