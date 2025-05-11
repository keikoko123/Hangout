import 'package:hangout_frontend/model/user_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AuthLocalRepository {
  String tableName = "users";

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
    final path = join(dbPath, "auth.db");
    return openDatabase(
      path,
      version: 3,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < newVersion) {
          await db.execute(
            'DROP TABLE $tableName',
          );
          db.execute('''
          CREATE TABLE $tableName(
            id TEXT PRIMARY KEY,
            email TEXT NOT NULL,
            token TEXT NOT NULL,
            name TEXT NOT NULL,
            profile_image TEXT,
            bio TEXT,
            game_coin INTEGER NOT NULL DEFAULT 0,
            mbti_e_i_score INTEGER NOT NULL DEFAULT 0,
            mbti_s_n_score INTEGER NOT NULL DEFAULT 0,
            mbti_t_f_score INTEGER NOT NULL DEFAULT 0,
            mbti_j_p_score INTEGER NOT NULL DEFAULT 0,
            mbti_type TEXT,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL
          )
    ''');
        }
      },
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE $tableName(
            id TEXT PRIMARY KEY,
            email TEXT NOT NULL,
            token TEXT NOT NULL,
            name TEXT NOT NULL,
            profile_image TEXT,
            bio TEXT,
            game_coin INTEGER NOT NULL DEFAULT 0,
            mbti_e_i_score INTEGER NOT NULL DEFAULT 0,
            mbti_s_n_score INTEGER NOT NULL DEFAULT 0,
            mbti_t_f_score INTEGER NOT NULL DEFAULT 0,
            mbti_j_p_score INTEGER NOT NULL DEFAULT 0,
            mbti_type TEXT,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL
          )
    ''');
      },
    );
  }

  Future<void> insertUser(UserModel userModel) async {
    final db = await database;

    await db.insert(
      tableName,
      userModel.toMap(), //to json format
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<UserModel?> getUser() async {
    final db = await database;
    final result = await db.query(tableName, limit: 1);

    if (result.isNotEmpty) {
      return UserModel.fromMap(result.first); // from json format
    }
    return null;
  }
}
