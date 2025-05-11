import 'dart:convert';

// Data Transfer Object for creating a new hobby event
class CreateHobbyEventDto {
  final String title;
  final String description;
  final String? difficulty;
  final String location;
  final String organizer;
  final String category;
  final List<String> tags;
  final int? quotaAmount;
  final DateTime hostDateTime;
  final int duration;
  final String? status;
  final double? price;
  final DateTime? registrationDeadline;
  final String hobbyId;
  final bool? isPost;

  CreateHobbyEventDto({
    required this.title,
    required this.description,
    this.difficulty,
    required this.location,
    required this.organizer,
    required this.category,
    required this.tags,
    this.quotaAmount,
    required this.hostDateTime,
    required this.duration,
    this.status,
    this.price,
    this.registrationDeadline,
    required this.hobbyId,
    this.isPost,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'difficulty': difficulty ?? 'medium',
      'location': location,
      'organizer': organizer,
      'category': category,
      'tags': tags,
      'quotaAmount': quotaAmount ?? 20,
      'hostDateTime': hostDateTime.toIso8601String(),
      'duration': duration,
      'status': status ?? 'upcoming',
      'price': price ?? 0,
      'registrationDeadline': registrationDeadline?.toIso8601String(),
      'hobbyId': hobbyId,
      'isPost': isPost ?? false,
    };
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return 'CreateHobbyEventDto{title: $title, description: $description, hostDateTime: $hostDateTime, hobbyId: $hobbyId}';
  }
}
