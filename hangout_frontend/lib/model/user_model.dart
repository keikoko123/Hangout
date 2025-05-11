import 'dart:convert';

class UserModel {
  final String id;
  final String email;
  final String name;
  final String token;
  final String? profileImage;
  final String? bio;
  final int gameCoin;

  // MBTI scores
  final int mbtiEIScore;
  final int mbtiSNScore;
  final int mbtiTFScore;
  final int mbtiJPScore;
  final String? mbtiType;

  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.token,
    this.profileImage,
    this.bio,
    this.gameCoin = 0,
    this.mbtiEIScore = 0,
    this.mbtiSNScore = 0,
    this.mbtiTFScore = 0,
    this.mbtiJPScore = 0,
    this.mbtiType,
    required this.createdAt,
    required this.updatedAt,
  });

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? token,
    String? profileImage,
    String? bio,
    int? gameCoin,
    int? mbtiEIScore,
    int? mbtiSNScore,
    int? mbtiTFScore,
    int? mbtiJPScore,
    String? mbtiType,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      token: token ?? this.token,
      profileImage: profileImage ?? this.profileImage,
      bio: bio ?? this.bio,
      gameCoin: gameCoin ?? this.gameCoin,
      mbtiEIScore: mbtiEIScore ?? this.mbtiEIScore,
      mbtiSNScore: mbtiSNScore ?? this.mbtiSNScore,
      mbtiTFScore: mbtiTFScore ?? this.mbtiTFScore,
      mbtiJPScore: mbtiJPScore ?? this.mbtiJPScore,
      mbtiType: mbtiType ?? this.mbtiType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'email': email,
      'name': name,
      'token': token,
      'profile_image': profileImage,
      'bio': bio,
      'game_coin': gameCoin,
      'mbti_e_i_score': mbtiEIScore,
      'mbti_s_n_score': mbtiSNScore,
      'mbti_t_f_score': mbtiTFScore,
      'mbti_j_p_score': mbtiJPScore,
      'mbti_type': mbtiType,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    // Debug to see all field names coming from the backend
    print("UserModel fields: ${map.keys.toList()}");

    // Check for various possible field names for MBTI scores
    int getIntValue(List<String> possibleKeys, int defaultValue) {
      for (final key in possibleKeys) {
        if (map.containsKey(key) && map[key] != null) {
          final value = map[key];
          if (value is int) return value;
          if (value is String) return int.tryParse(value) ?? defaultValue;
          if (value is double) return value.toInt();
        }
      }
      return defaultValue;
    }

    // Handle different possible field names for MBTI scores
    final eiScore =
        getIntValue(['mbti_e_i_score', 'mbtiE_I_score', 'mbtiEIScore'], 0);
    final snScore =
        getIntValue(['mbti_s_n_score', 'mbtiS_N_score', 'mbtiSNScore'], 0);
    final tfScore =
        getIntValue(['mbti_t_f_score', 'mbtiT_F_score', 'mbtiTFScore'], 0);
    final jpScore =
        getIntValue(['mbti_j_p_score', 'mbtiJ_P_score', 'mbtiJPScore'], 0);

    // Handle different possible field names for MBTI type
    String? mbtiType;
    for (final key in ['mbti_type', 'mbtiType']) {
      if (map.containsKey(key) && map[key] != null) {
        mbtiType = map[key].toString();
        break;
      }
    }

    // Debug MBTI values found
    print(
        "MBTI Values from API - E/I: $eiScore, S/N: $snScore, T/F: $tfScore, J/P: $jpScore, Type: $mbtiType");

    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      token: map['token'] ?? '123',
      profileImage: map['profile_image'] ?? map['profileImage'],
      bio: map['bio'],
      gameCoin: getIntValue(['game_coin', 'gameCoin'], 0),
      mbtiEIScore: eiScore,
      mbtiSNScore: snScore,
      mbtiTFScore: tfScore,
      mbtiJPScore: jpScore,
      mbtiType: mbtiType,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, name: $name, token: $token, profileImage: $profileImage, bio: $bio, gameCoin: $gameCoin, mbtiType: $mbtiType, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(covariant UserModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.email == email &&
        other.name == name &&
        other.token == token &&
        other.profileImage == profileImage &&
        other.bio == bio &&
        other.gameCoin == gameCoin &&
        other.mbtiEIScore == mbtiEIScore &&
        other.mbtiSNScore == mbtiSNScore &&
        other.mbtiTFScore == mbtiTFScore &&
        other.mbtiJPScore == mbtiJPScore &&
        other.mbtiType == mbtiType &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        email.hashCode ^
        name.hashCode ^
        token.hashCode ^
        profileImage.hashCode ^
        bio.hashCode ^
        gameCoin.hashCode ^
        mbtiEIScore.hashCode ^
        mbtiSNScore.hashCode ^
        mbtiTFScore.hashCode ^
        mbtiJPScore.hashCode ^
        mbtiType.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
