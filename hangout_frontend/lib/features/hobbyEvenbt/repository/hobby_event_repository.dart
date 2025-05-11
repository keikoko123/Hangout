import 'dart:convert';
import 'package:hangout_frontend/model/hobby_event_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HobbyEventRepository {
  final String baseUrl = 'http://localhost:8000';

  Future<List<HobbyEventModel>> fetchHobbyEvents({String? hobbyId}) async {
    try {
      // Get the stored token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      // Create URL with optional hobbyId filter
      String url = '$baseUrl/events/hosted';
      if (hobbyId != null && hobbyId.isNotEmpty) {
        url += '?hobbyId=$hobbyId';
      }

      // Make request to the server
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> eventsJson = json.decode(response.body);
        return eventsJson
            .map((event) => HobbyEventModel.fromMap(event))
            .toList();
      } else {
        throw Exception('Failed to load hobby events: ${response.statusCode}');
      }
    } catch (e) {
      // For now, return mock data
      return _getMockHobbyEvents();
    }
  }

  Future<List<HobbyEventModel>> fetchHobbyEventsByCategory(
      String category) async {
    try {
      // First fetch all events
      final events = await fetchHobbyEvents();
      // Then filter by category
      return events
          .where(
              (event) => event.category.toLowerCase() == category.toLowerCase())
          .toList();
    } catch (e) {
      // Filter mock data by category
      return _getMockHobbyEvents()
          .where(
              (event) => event.category.toLowerCase() == category.toLowerCase())
          .toList();
    }
  }

  // Mock data for testing
  List<HobbyEventModel> _getMockHobbyEvents() {
    return [
      HobbyEventModel(
        id: '1',
        title: 'Beginner Painting Workshop',
        description:
            'Learn the basics of acrylic painting in this friendly workshop for beginners.',
        difficulty: 'easy',
        location: 'Art Studio, 123 Creative St',
        hostDateTime: DateTime.now().add(const Duration(days: 7)),
        duration: 120,
        organizer: 'Creative Arts Club',
        category: 'Visual Arts',
        quotaAmount: 15,
        joinedAmount: 8,
        price: 25.0,
        tags: ['beginners', 'painting', 'workshop'],
        hobbyId: '101',
        hostId: 'user123',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      HobbyEventModel(
        id: '2',
        title: 'Weekly Chess Tournament',
        description:
            'Join our weekly chess tournament for players of all skill levels.',
        difficulty: 'medium',
        location: 'Community Center, 456 Game Ave',
        hostDateTime: DateTime.now().add(const Duration(days: 3)),
        duration: 180,
        organizer: 'Chess Masters Club',
        category: 'Gaming',
        quotaAmount: 32,
        joinedAmount: 24,
        price: 5.0,
        tags: ['chess', 'tournament', 'competitive'],
        hobbyId: '102',
        hostId: 'user456',
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      HobbyEventModel(
        id: '3',
        title: 'Online Photography Masterclass',
        description:
            'Learn advanced photography techniques from professional photographers.',
        difficulty: 'hard',
        location: 'Zoom Meeting',
        hostDateTime: DateTime.now().add(const Duration(days: 14)),
        duration: 90,
        organizer: 'Photography Pros',
        category: 'Visual Arts',
        quotaAmount: 50,
        joinedAmount: 35,
        price: 40.0,
        tags: ['photography', 'online', 'masterclass'],
        hobbyId: '103',
        hostId: 'user789',
        isPost: false,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      HobbyEventModel(
        id: '4',
        title: 'Urban Hiking Adventure',
        description:
            'Explore the city\'s hidden gems in this guided urban hiking tour.',
        difficulty: 'medium',
        location: 'City Park Entrance, 789 Nature Blvd',
        hostDateTime: DateTime.now().add(const Duration(days: 5)),
        duration: 240,
        organizer: 'Urban Explorers',
        category: 'Sport',
        quotaAmount: 20,
        joinedAmount: 12,
        price: 15.0,
        tags: ['hiking', 'outdoors', 'adventure'],
        hobbyId: '104',
        hostId: 'user321',
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
        updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      HobbyEventModel(
        id: '5',
        title: 'Yoga in the Park',
        description:
            'Relax and rejuvenate with outdoor yoga classes suitable for all levels.',
        difficulty: 'easy',
        location: 'Sunset Park, 101 Zen Road',
        hostDateTime: DateTime.now().add(const Duration(days: 2)),
        duration: 60,
        organizer: 'Mindful Movement',
        category: 'Relaxation',
        quotaAmount: 30,
        joinedAmount: 22,
        price: 10.0,
        tags: ['yoga', 'outdoors', 'relaxation'],
        hobbyId: '105',
        hostId: 'user654',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      HobbyEventModel(
        id: '6',
        title: 'Virtual Book Club Meeting',
        description:
            'Join our monthly book club discussion, this month featuring "The Midnight Library".',
        difficulty: 'easy',
        location: 'Google Meet',
        hostDateTime: DateTime.now().add(const Duration(days: 10)),
        duration: 120,
        organizer: 'Page Turners Book Club',
        category: 'Relaxation',
        quotaAmount: 25,
        joinedAmount: 18,
        price: 0.0,
        tags: ['books', 'reading', 'discussion', 'free'],
        hobbyId: '106',
        hostId: 'user987',
        isPost: true,
        createdAt: DateTime.now().subtract(const Duration(days: 40)),
        updatedAt: DateTime.now().subtract(const Duration(days: 4)),
      ),
    ];
  }
}
