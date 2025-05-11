import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hangout_frontend/features/hobbyEvenbt/cubit/hobby_event_cubit.dart';
import 'package:hangout_frontend/features/hobbyEvenbt/cubit/hobby_event_state.dart';
import 'package:hangout_frontend/features/hobbyEvenbt/pages/hobby_event_detail_page.dart';
import 'package:hangout_frontend/features/hobbyEvenbt/repository/hobby_event_repository.dart';
import 'package:hangout_frontend/features/hobbyEvenbt/widgets/hobby_event_card.dart';
import 'package:hangout_frontend/model/hobby_event_model.dart';

class HobbyEventPage extends StatefulWidget {
  final String? hobbyId;

  const HobbyEventPage({
    super.key,
    this.hobbyId,
  });

  static MaterialPageRoute route({String? hobbyId}) => MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => HobbyEventCubit(HobbyEventRepository()),
          child: HobbyEventPage(hobbyId: hobbyId),
        ),
      );

  @override
  State<HobbyEventPage> createState() => _HobbyEventPageState();
}

class _HobbyEventPageState extends State<HobbyEventPage> {
  final List<String> _categories = [
    'All Categories',
    'Visual Arts',
    'Sport',
    'Performance',
    'Gaming',
    'Creation',
    'Relaxation',
  ];

  final List<String> _statusOptions = [
    'All',
    'Upcoming',
    'Ongoing',
    'Completed',
    'Cancelled',
  ];

  final List<Map<String, dynamic>> _sortOptions = [
    {'id': 'hostDateTime', 'label': 'Date', 'icon': Icons.calendar_today},
    {'id': 'price', 'label': 'Price', 'icon': Icons.attach_money},
    {'id': 'title', 'label': 'Name', 'icon': Icons.sort_by_alpha},
    {'id': 'popularity', 'label': 'Popularity', 'icon': Icons.trending_up},
    {'id': 'duration', 'label': 'Duration', 'icon': Icons.timer},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.hobbyId != null) {
      context.read<HobbyEventCubit>().fetchEventsByHobbyId(widget.hobbyId!);
    } else {
      context.read<HobbyEventCubit>().fetchHobbyEvents();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.hobbyId != null ? 'Events' : 'All Hobby Events'),
        elevation: 0,
      ),
      body: BlocBuilder<HobbyEventCubit, HobbyEventState>(
        builder: (context, state) {
          if (state.status == HobbyEventStatus.initial ||
              state.status == HobbyEventStatus.loading &&
                  state.events.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == HobbyEventStatus.error && state.events.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading events',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.errorMessage ?? 'An unknown error occurred',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (widget.hobbyId != null) {
                        context
                            .read<HobbyEventCubit>()
                            .fetchEventsByHobbyId(widget.hobbyId!);
                      } else {
                        context.read<HobbyEventCubit>().fetchHobbyEvents();
                      }
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Filter and sort controls
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Category filter
                    SizedBox(
                      height: 46,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          final category = _categories[index];
                          final isSelected =
                              state.selectedCategory == category ||
                                  (state.selectedCategory == null &&
                                      category == 'All Categories');

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: FilterChip(
                              label: Text(category),
                              selected: isSelected,
                              onSelected: (_) {
                                context.read<HobbyEventCubit>().setCategory(
                                    category == 'All Categories'
                                        ? null
                                        : category);
                              },
                              backgroundColor: Colors.white,
                              selectedColor: Colors.blue[100],
                              checkmarkColor: Colors.blue[800],
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? Colors.blue[800]
                                    : Colors.black87,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // Status filter
                    SizedBox(
                      height: 46,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: _statusOptions.length,
                        itemBuilder: (context, index) {
                          final status = _statusOptions[index];
                          final isSelected = state.statusFilter == status ||
                              (state.statusFilter == null && status == 'All');

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: FilterChip(
                              label: Text(status),
                              selected: isSelected,
                              onSelected: (_) {
                                context.read<HobbyEventCubit>().setStatusFilter(
                                    status == 'All' ? null : status);
                              },
                              backgroundColor: Colors.white,
                              selectedColor:
                                  _getStatusColor(status).withOpacity(0.2),
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? _getStatusColor(status)
                                    : Colors.black87,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // Online/In-person filter and Sort controls
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: Row(
                        children: [
                          // Posts filter
                          Row(
                            children: [
                              const Text(
                                'Show posts only',
                                style: TextStyle(fontSize: 14),
                              ),
                              Switch(
                                value: state.showOnlyPosts,
                                onChanged: (value) {
                                  context
                                      .read<HobbyEventCubit>()
                                      .togglePostFilter(value);
                                },
                              ),
                            ],
                          ),
                          const Spacer(),
                          // Sort button
                          PopupMenuButton<String>(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.sort, size: 16),
                                  const SizedBox(width: 4),
                                  const Text('Sort'),
                                  const SizedBox(width: 4),
                                  Icon(
                                    state.isAscending
                                        ? Icons.arrow_upward
                                        : Icons.arrow_downward,
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                            onSelected: (String sortId) {
                              context.read<HobbyEventCubit>().setSortBy(sortId);
                            },
                            itemBuilder: (BuildContext context) {
                              return _sortOptions.map((option) {
                                final bool isSelected =
                                    state.sortBy == option['id'];
                                return PopupMenuItem<String>(
                                  value: option['id'],
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(option['icon'], size: 16),
                                          const SizedBox(width: 8),
                                          Text(option['label']),
                                        ],
                                      ),
                                      if (isSelected)
                                        Icon(
                                          state.isAscending
                                              ? Icons.arrow_upward
                                              : Icons.arrow_downward,
                                          size: 16,
                                        ),
                                    ],
                                  ),
                                );
                              }).toList();
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Event list
              Expanded(
                child: state.filteredEvents.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.event_busy,
                                  size: 60, color: Colors.grey),
                              onPressed: () {
                                // Create a sample event to view details
                                final sampleEvent = _createSampleEvent();
                                Navigator.of(context).push(
                                  HobbyEventDetailPage.route(sampleEvent),
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No events found',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try changing your filters or tap the icon to see a sample event',
                              style: Theme.of(context).textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          if (widget.hobbyId != null) {
                            await context
                                .read<HobbyEventCubit>()
                                .fetchEventsByHobbyId(widget.hobbyId!);
                          } else {
                            await context
                                .read<HobbyEventCubit>()
                                .fetchHobbyEvents();
                          }
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 16),
                          itemCount: state.filteredEvents.length,
                          itemBuilder: (context, index) {
                            final event = state.filteredEvents[index];
                            return HobbyEventCard(
                              event: event,
                              onTap: () {
                                Navigator.of(context).push(
                                  HobbyEventDetailPage.route(event),
                                );
                              },
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'upcoming':
        return Colors.blue;
      case 'ongoing':
        return Colors.green;
      case 'completed':
        return Colors.grey;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  // Create a sample event for demonstration purposes
  HobbyEventModel _createSampleEvent() {
    return HobbyEventModel(
      id: 'sample-id',
      title: 'Sample Event',
      description:
          'This is a sample event to show what event details look like. '
          'When real events are available, you will be able to view their details here.',
      difficulty: 'medium',
      location: 'Sample Location, 123 Example St',
      hostDateTime: DateTime.now().add(const Duration(days: 7)),
      duration: 120,
      organizer: 'Sample Organizer',
      category: 'Visual Arts',
      quotaAmount: 20,
      joinedAmount: 10,
      price: 15.0,
      tags: ['sample', 'demonstration', 'example'],
      hobbyId: 'sample-hobby-id',
      hostId: 'sample-host-id',
      status: 'upcoming',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
