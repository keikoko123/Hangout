import 'dart:convert';

class HobbyModel {
  final String id;
  final String name;
  final String description;
  final String category;
  final String? subcategory;
  final String icon;
  final List<String> equipment;
  final String costLevel;
  final String indoorOutdoor;
  final String socialLevel;
  final String ageRange;
  final int popularity;
  final String imageUrl;
  final int mbtiE_I_score;
  final int mbtiS_N_score;
  final int mbtiT_F_score;
  final int mbtiJ_P_score;
  final String mbtiE_I;
  final String mbtiS_N;
  final String mbtiT_F;
  final String mbtiJ_P;
  final String? mbtiCompatibility;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int isSynced;

  HobbyModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    this.subcategory,
    required this.icon,
    required this.equipment,
    required this.costLevel,
    required this.indoorOutdoor,
    required this.socialLevel,
    required this.ageRange,
    required this.popularity,
    required this.imageUrl,
    required this.mbtiE_I_score,
    required this.mbtiS_N_score,
    required this.mbtiT_F_score,
    required this.mbtiJ_P_score,
    required this.mbtiE_I,
    required this.mbtiS_N,
    required this.mbtiT_F,
    required this.mbtiJ_P,
    this.mbtiCompatibility,
    required this.createdAt,
    required this.updatedAt,
    required this.isSynced,
  });

  HobbyModel copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    String? subcategory,
    String? icon,
    List<String>? equipment,
    String? costLevel,
    String? indoorOutdoor,
    String? socialLevel,
    String? ageRange,
    int? popularity,
    String? imageUrl,
    int? mbtiE_I_score,
    int? mbtiS_N_score,
    int? mbtiT_F_score,
    int? mbtiJ_P_score,
    String? mbtiE_I,
    String? mbtiS_N,
    String? mbtiT_F,
    String? mbtiJ_P,
    String? mbtiCompatibility,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? isSynced,
  }) {
    return HobbyModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      icon: icon ?? this.icon,
      equipment: equipment ?? this.equipment,
      costLevel: costLevel ?? this.costLevel,
      indoorOutdoor: indoorOutdoor ?? this.indoorOutdoor,
      socialLevel: socialLevel ?? this.socialLevel,
      ageRange: ageRange ?? this.ageRange,
      popularity: popularity ?? this.popularity,
      imageUrl: imageUrl ?? this.imageUrl,
      mbtiE_I_score: mbtiE_I_score ?? this.mbtiE_I_score,
      mbtiS_N_score: mbtiS_N_score ?? this.mbtiS_N_score,
      mbtiT_F_score: mbtiT_F_score ?? this.mbtiT_F_score,
      mbtiJ_P_score: mbtiJ_P_score ?? this.mbtiJ_P_score,
      mbtiE_I: mbtiE_I ?? this.mbtiE_I,
      mbtiS_N: mbtiS_N ?? this.mbtiS_N,
      mbtiT_F: mbtiT_F ?? this.mbtiT_F,
      mbtiJ_P: mbtiJ_P ?? this.mbtiJ_P,
      mbtiCompatibility: mbtiCompatibility ?? this.mbtiCompatibility,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
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
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isSynced': isSynced,
    };
  }

  factory HobbyModel.fromMap(Map<String, dynamic> map) {
    return HobbyModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      subcategory: map['subcategory'] ?? '',
      icon: map['icon'] ?? '',
      equipment: List<String>.from(map['equipment'] ?? []),
      costLevel: map['costLevel'] ?? '',
      indoorOutdoor: map['indoorOutdoor'] ?? '',
      socialLevel: map['socialLevel'] ?? '',
      ageRange: map['ageRange'] ?? '',
      popularity: map['popularity'] ?? 0,
      imageUrl: map['imageUrl'] ?? '',
      mbtiE_I_score: map['mbtiE_I_score'] ?? 0,
      mbtiS_N_score: map['mbtiS_N_score'] ?? 0,
      mbtiT_F_score: map['mbtiT_F_score'] ?? 0,
      mbtiJ_P_score: map['mbtiJ_P_score'] ?? 0,
      mbtiE_I: map['mbtiE_I'] ?? '',
      mbtiS_N: map['mbtiS_N'] ?? '',
      mbtiT_F: map['mbtiT_F'] ?? '',
      mbtiJ_P: map['mbtiJ_P'] ?? '',
      mbtiCompatibility: map['mbtiCompatibility'],
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : DateTime.now(),
      isSynced: map['isSynced'] ?? 1,
    );
  }

  String toJson() => json.encode(toMap());

  factory HobbyModel.fromJson(String source) =>
      HobbyModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'HobbyModel(id: $id, name: $name, description: $description, category: $category, subcategory: $subcategory, icon: $icon, popularity: $popularity)';
  }

  @override
  bool operator ==(covariant HobbyModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.name == name &&
        other.description == description &&
        other.category == category &&
        other.subcategory == subcategory &&
        other.icon == icon &&
        other.popularity == popularity &&
        other.isSynced == isSynced;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        description.hashCode ^
        category.hashCode ^
        subcategory.hashCode ^
        icon.hashCode ^
        popularity.hashCode ^
        isSynced.hashCode;
  }
}
