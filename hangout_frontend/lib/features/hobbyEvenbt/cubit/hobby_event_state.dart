import 'package:hangout_frontend/model/hobby_event_model.dart';

enum HobbyEventStatus { initial, loading, loaded, error }

class HobbyEventState {
  final HobbyEventStatus status;
  final List<HobbyEventModel> events;
  final List<HobbyEventModel> filteredEvents;
  final String? errorMessage;
  final String? selectedCategory;
  final bool showOnlyPosts;
  final String? statusFilter;
  final String sortBy;
  final bool isAscending;

  const HobbyEventState({
    this.status = HobbyEventStatus.initial,
    this.events = const [],
    this.filteredEvents = const [],
    this.errorMessage,
    this.selectedCategory,
    this.showOnlyPosts = false,
    this.statusFilter,
    this.sortBy = 'hostDateTime',
    this.isAscending = true,
  });

  HobbyEventState copyWith({
    HobbyEventStatus? status,
    List<HobbyEventModel>? events,
    List<HobbyEventModel>? filteredEvents,
    String? errorMessage,
    String? selectedCategory,
    bool? showOnlyPosts,
    String? statusFilter,
    String? sortBy,
    bool? isAscending,
  }) {
    return HobbyEventState(
      status: status ?? this.status,
      events: events ?? this.events,
      filteredEvents: filteredEvents ?? this.filteredEvents,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      showOnlyPosts: showOnlyPosts ?? this.showOnlyPosts,
      statusFilter: statusFilter ?? this.statusFilter,
      sortBy: sortBy ?? this.sortBy,
      isAscending: isAscending ?? this.isAscending,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is HobbyEventState &&
        other.status == status &&
        other.events.length == events.length &&
        other.filteredEvents.length == filteredEvents.length &&
        other.errorMessage == errorMessage &&
        other.selectedCategory == selectedCategory &&
        other.showOnlyPosts == showOnlyPosts &&
        other.statusFilter == statusFilter &&
        other.sortBy == sortBy &&
        other.isAscending == isAscending;
  }

  @override
  int get hashCode {
    return status.hashCode ^
        events.length.hashCode ^
        filteredEvents.length.hashCode ^
        errorMessage.hashCode ^
        selectedCategory.hashCode ^
        showOnlyPosts.hashCode ^
        statusFilter.hashCode ^
        sortBy.hashCode ^
        isAscending.hashCode;
  }
}
