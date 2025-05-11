import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hangout_frontend/features/hobbyEvenbt/cubit/hobby_event_state.dart';
import 'package:hangout_frontend/features/hobbyEvenbt/repository/hobby_event_repository.dart';
import 'package:hangout_frontend/model/hobby_event_model.dart';

class HobbyEventCubit extends Cubit<HobbyEventState> {
  final HobbyEventRepository _repository;

  HobbyEventCubit(this._repository) : super(const HobbyEventState());

  Future<void> fetchHobbyEvents() async {
    emit(state.copyWith(status: HobbyEventStatus.loading));

    try {
      final events = await _repository.fetchHobbyEvents();
      emit(state.copyWith(
        status: HobbyEventStatus.loaded,
        events: events,
        filteredEvents: events,
      ));
      _applyFiltersAndSort();
    } catch (e) {
      emit(state.copyWith(
        status: HobbyEventStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> fetchEventsByHobbyId(String hobbyId) async {
    emit(state.copyWith(status: HobbyEventStatus.loading));

    try {
      final events = await _repository.fetchHobbyEvents(hobbyId: hobbyId);
      emit(state.copyWith(
        status: HobbyEventStatus.loaded,
        events: events,
        filteredEvents: events,
      ));
      _applyFiltersAndSort();
    } catch (e) {
      emit(state.copyWith(
        status: HobbyEventStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> fetchEventsByCategory(String category) async {
    emit(state.copyWith(status: HobbyEventStatus.loading));

    try {
      final events = await _repository.fetchHobbyEventsByCategory(category);
      emit(state.copyWith(
        status: HobbyEventStatus.loaded,
        events: events,
        filteredEvents: events,
        selectedCategory: category,
      ));
      _applyFiltersAndSort();
    } catch (e) {
      emit(state.copyWith(
        status: HobbyEventStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void setCategory(String? category) {
    emit(state.copyWith(selectedCategory: category));
    _applyFiltersAndSort();
  }

  void togglePostFilter(bool showOnlyPosts) {
    emit(state.copyWith(showOnlyPosts: showOnlyPosts));
    _applyFiltersAndSort();
  }

  void setStatusFilter(String? status) {
    emit(state.copyWith(statusFilter: status));
    _applyFiltersAndSort();
  }

  void setSortBy(String sortBy) {
    if (state.sortBy == sortBy) {
      // Toggle ascending/descending if same sort criteria is selected
      emit(state.copyWith(isAscending: !state.isAscending));
    } else {
      // Default to ascending for new sort criteria
      emit(state.copyWith(sortBy: sortBy, isAscending: true));
    }
    _applyFiltersAndSort();
  }

  void _applyFiltersAndSort() {
    List<HobbyEventModel> filtered = List.from(state.events);

    // Apply category filter
    if (state.selectedCategory != null &&
        state.selectedCategory != 'All Categories') {
      filtered = filtered
          .where((event) => event.category == state.selectedCategory)
          .toList();
    }

    // Apply post filter
    if (state.showOnlyPosts) {
      filtered = filtered.where((event) => event.isPost).toList();
    }

    // Apply status filter
    if (state.statusFilter != null && state.statusFilter != 'All') {
      filtered = filtered
          .where((event) =>
              event.status.toLowerCase() == state.statusFilter!.toLowerCase())
          .toList();
    }

    // Apply sorting
    filtered.sort((a, b) {
      int result = 0;
      switch (state.sortBy) {
        case 'hostDateTime':
          result = a.hostDateTime.compareTo(b.hostDateTime);
          break;
        case 'price':
          result = a.price.compareTo(b.price);
          break;
        case 'title':
          result = a.title.compareTo(b.title);
          break;
        case 'popularity':
          result = a.joinedAmount.compareTo(b.joinedAmount);
          break;
        case 'duration':
          result = a.duration.compareTo(b.duration);
          break;
        default:
          result = a.hostDateTime.compareTo(b.hostDateTime);
      }
      return state.isAscending ? result : -result;
    });

    emit(state.copyWith(filteredEvents: filtered));
  }
}
