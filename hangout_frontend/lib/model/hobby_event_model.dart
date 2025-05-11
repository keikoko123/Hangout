import 'dart:convert';

class HobbyEventModel {
  final String id;
  final String title;
  final String description;
  final String difficulty;
  final String location;
  final String organizer;
  final String category;
  final List<String> tags;
  final int quotaAmount;
  final int joinedAmount;
  final DateTime hostDateTime;
  final int duration; // In minutes
  final String status;
  final double price;
  final DateTime? registrationDeadline;
  final String hobbyId;
  final String hostId;
  final bool isPost;
  final DateTime createdAt;
  final DateTime updatedAt;

  HobbyEventModel({
    required this.id,
    required this.title,
    required this.description,
    this.difficulty = 'medium',
    required this.location,
    required this.organizer,
    required this.category,
    required this.tags,
    this.quotaAmount = 20,
    this.joinedAmount = 0,
    required this.hostDateTime,
    required this.duration,
    this.status = 'upcoming',
    this.price = 0,
    this.registrationDeadline,
    required this.hobbyId,
    required this.hostId,
    this.isPost = false,
    required this.createdAt,
    required this.updatedAt,
  });

  HobbyEventModel copyWith({
    String? id,
    String? title,
    String? description,
    String? difficulty,
    String? location,
    String? organizer,
    String? category,
    List<String>? tags,
    int? quotaAmount,
    int? joinedAmount,
    DateTime? hostDateTime,
    int? duration,
    String? status,
    double? price,
    DateTime? registrationDeadline,
    String? hobbyId,
    String? hostId,
    bool? isPost,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HobbyEventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      difficulty: difficulty ?? this.difficulty,
      location: location ?? this.location,
      organizer: organizer ?? this.organizer,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      quotaAmount: quotaAmount ?? this.quotaAmount,
      joinedAmount: joinedAmount ?? this.joinedAmount,
      hostDateTime: hostDateTime ?? this.hostDateTime,
      duration: duration ?? this.duration,
      status: status ?? this.status,
      price: price ?? this.price,
      registrationDeadline: registrationDeadline ?? this.registrationDeadline,
      hobbyId: hobbyId ?? this.hobbyId,
      hostId: hostId ?? this.hostId,
      isPost: isPost ?? this.isPost,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'difficulty': difficulty,
      'location': location,
      'organizer': organizer,
      'category': category,
      'tags': tags,
      'quotaAmount': quotaAmount,
      'joinedAmount': joinedAmount,
      'hostDateTime': hostDateTime.toIso8601String(),
      'duration': duration,
      'status': status,
      'price': price,
      'registrationDeadline': registrationDeadline?.toIso8601String(),
      'hobbyId': hobbyId,
      'hostId': hostId,
      'isPost': isPost,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory HobbyEventModel.fromMap(Map<String, dynamic> map) {
    return HobbyEventModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      difficulty: map['difficulty'] ?? 'medium',
      location: map['location'] ?? '',
      organizer: map['organizer'] ?? '',
      category: map['category'] ?? '',
      tags: List<String>.from(map['tags'] ?? []),
      quotaAmount: map['quotaAmount'] ?? 20,
      joinedAmount: map['joinedAmount'] ?? 0,
      hostDateTime: map['hostDateTime'] != null
          ? DateTime.parse(map['hostDateTime'])
          : DateTime.now(),
      duration: map['duration'] ?? 60,
      status: map['status'] ?? 'upcoming',
      price: map['price']?.toDouble() ?? 0.0,
      registrationDeadline: map['registrationDeadline'] != null
          ? DateTime.parse(map['registrationDeadline'])
          : null,
      hobbyId: map['hobbyId'] ?? '',
      hostId: map['hostId'] ?? '',
      isPost: map['isPost'] ?? false,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory HobbyEventModel.fromJson(String source) =>
      HobbyEventModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'HobbyEventModel(id: $id, title: $title, description: $description, hostDateTime: $hostDateTime, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HobbyEventModel &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.difficulty == difficulty &&
        other.location == location &&
        other.organizer == organizer &&
        other.category == category &&
        other.hostDateTime == hostDateTime &&
        other.hobbyId == hobbyId &&
        other.hostId == hostId;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        description.hashCode ^
        difficulty.hashCode ^
        location.hashCode ^
        organizer.hashCode ^
        category.hashCode ^
        hostDateTime.hashCode ^
        hobbyId.hashCode ^
        hostId.hashCode;
  }
}
