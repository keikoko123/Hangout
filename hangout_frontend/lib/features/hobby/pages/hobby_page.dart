import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hangout_frontend/features/auth/cubit/auth_cubit.dart';
import 'package:hangout_frontend/features/hobby/cubit/hobbies_cubit.dart';
import 'package:hangout_frontend/features/hobby/pages/add_new_hobby_page.dart';
import 'package:hangout_frontend/features/hobby/widgets/hobby_card.dart';
import 'package:hangout_frontend/features/home/pages/home_page.dart';
import 'package:hangout_frontend/model/hobby_model.dart';
import 'package:hangout_frontend/features/user/cubit/user_cubit.dart';
import 'package:hangout_frontend/features/home/pages/canvas_page.dart';

class HobbyPage extends StatefulWidget {
  const HobbyPage({super.key});
  static MaterialPageRoute route() => MaterialPageRoute(
        builder: (context) => const HobbyPage(),
      );
  @override
  State<HobbyPage> createState() => _HobbyPageState();
}

class _HobbyPageState extends State<HobbyPage> {
  bool isLoading = true;
  bool isLoaded = false;
  List<HobbyModel> hobbies = [];
  List<HobbyModel> filteredHobbies = [];
  String currentSortAttribute = "popularity"; // Default sort by popularity
  bool isAscending = false;
  String? selectedCategory; // For category filtering
  String?
      selectedAttribute; // For attribute filtering (costLevel, indoorOutdoor, socialLevel)

  // Possible sorting attributes
  final List<Map<String, dynamic>> sortAttributes = [
    {'id': 'popularity', 'label': 'Popularity', 'icon': Icons.trending_up},
    {'id': 'name', 'label': 'Name', 'icon': Icons.sort_by_alpha},
    {'id': 'mbtiMatch', 'label': 'MBTI Match', 'icon': Icons.psychology},
    {'id': 'costLevel', 'label': 'Cost', 'icon': Icons.paid},
    {'id': 'category', 'label': 'Category', 'icon': Icons.category},
    {
      'id': 'categoryByPopularity',
      'label': 'Category+Popularity',
      'icon': Icons.view_list
    },
    {'id': 'indoorOutdoor', 'label': 'Location', 'icon': Icons.location_on},
    {'id': 'socialLevel', 'label': 'Social', 'icon': Icons.people},
  ];

  // Get all unique categories
  List<String> get categories {
    final Set<String> uniqueCategories = hobbies.map((h) => h.category).toSet();
    final List<String> sortedCategories = uniqueCategories.toList()..sort();
    return ['All Categories', ...sortedCategories];
  }

  // Get attribute options for filtering tags
  Map<String, List<String>> get attributeOptions {
    return {
      'costLevel': ['low', 'high'],
      'indoorOutdoor': ['indoor', 'outdoor'],
      'socialLevel': ['solo', 'group'],
    };
  }

  // Format attribute values for display
  String formatAttributeValue(String attribute, String value) {
    switch (attribute) {
      case 'costLevel':
        return value.capitalize();
      case 'indoorOutdoor':
        return value.capitalize();
      case 'socialLevel':
        return value.capitalize();
      default:
        return value;
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchHobbies();
  }

  void _filterAndSortHobbies() {
    // Start with all hobbies
    filteredHobbies = List.from(hobbies);

    // Filter by selected category if any
    if (selectedCategory != null && selectedCategory != 'All Categories') {
      filteredHobbies =
          filteredHobbies.where((h) => h.category == selectedCategory).toList();
    }

    // Filter by selected attribute if any
    if (selectedAttribute != null) {
      final parts = selectedAttribute!.split(':');
      if (parts.length == 2) {
        final attribute = parts[0];
        final value = parts[1];

        filteredHobbies = filteredHobbies.where((h) {
          switch (attribute) {
            case 'costLevel':
              return h.costLevel == value;
            case 'indoorOutdoor':
              return h.indoorOutdoor == value;
            case 'socialLevel':
              return h.socialLevel == value;
            default:
              return true;
          }
        }).toList();
      }
    }

    // Apply sorting
    _sortHobbies();
  }

  void _sortHobbies() {
    if (currentSortAttribute == 'categoryByPopularity') {
      // First sort by category (ascending)
      filteredHobbies.sort((a, b) => a.category.compareTo(b.category));

      // Then sort by popularity within each category (descending)
      Map<String, List<HobbyModel>> hobbiesByCategory = {};

      // Group hobbies by category
      for (var hobby in filteredHobbies) {
        if (!hobbiesByCategory.containsKey(hobby.category)) {
          hobbiesByCategory[hobby.category] = [];
        }
        hobbiesByCategory[hobby.category]!.add(hobby);
      }

      // Sort each category group by popularity
      hobbiesByCategory.forEach((category, hobbiesInCategory) {
        hobbiesInCategory.sort((a, b) => b.popularity.compareTo(a.popularity));
      });

      // Flatten the grouped and sorted hobbies back into a list
      filteredHobbies = [];
      hobbiesByCategory.keys.toList()
        ..sort() // Sort categories alphabetically
        ..forEach((category) {
          filteredHobbies.addAll(hobbiesByCategory[category]!);
        });

      setState(() {});
      return;
    }

    // MBTI sorting - pre-calculate match scores for each hobby
    Map<String, double> mbtiScores = {};
    if (currentSortAttribute == 'mbtiMatch') {
      for (var hobby in filteredHobbies) {
        mbtiScores[hobby.id] = calculateMbtiMatchScore(hobby);
      }
    }

    // Original sorting logic for other attributes
    filteredHobbies.sort((a, b) {
      dynamic valueA;
      dynamic valueB;

      switch (currentSortAttribute) {
        case 'popularity':
          valueA = a.popularity;
          valueB = b.popularity;
          break;
        case 'name':
          valueA = a.name;
          valueB = b.name;
          break;
        case 'mbtiMatch':
          // Sort by MBTI match score (highest first)
          valueA = mbtiScores[a.id] ?? 0.0;
          valueB = mbtiScores[b.id] ?? 0.0;
          // Default to descending order for MBTI match (best matches first)
          return valueB.compareTo(valueA);
        case 'costLevel':
          // Convert cost level to numeric value for sorting
          valueA = _costLevelToValue(a.costLevel);
          valueB = _costLevelToValue(b.costLevel);
          break;
        case 'category':
          valueA = a.category;
          valueB = b.category;
          break;
        case 'indoorOutdoor':
          valueA = a.indoorOutdoor;
          valueB = b.indoorOutdoor;
          break;
        case 'socialLevel':
          valueA = a.socialLevel;
          valueB = b.socialLevel;
          break;
        default:
          valueA = a.popularity;
          valueB = b.popularity;
      }

      // Handle string comparison
      if (valueA is String && valueB is String) {
        int result = valueA.compareTo(valueB);
        return isAscending ? result : -result;
      }

      // Handle numeric comparison
      if (valueA is num && valueB is num) {
        if (isAscending) {
          return valueA.compareTo(valueB);
        } else {
          return valueB.compareTo(valueA);
        }
      }

      return 0;
    });

    setState(() {});
  }

  int _costLevelToValue(String costLevel) {
    switch (costLevel.toLowerCase()) {
      case 'low':
        return 1;
      case 'medium':
        return 2;
      case 'high':
        return 3;
      default:
        return 0;
    }
  }

  Future<void> _fetchHobbies() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Try to fetch with authentication if user is logged in
      final authState = context.read<AuthCubit>().state;
      if (authState is AuthLoggedIn) {
        await context
            .read<HobbiesCubit>()
            .getAllHobbies(token: authState.user.token);
      } else {
        // Fall back to public API if not logged in
        await context.read<HobbiesCubit>().getPublicHobbies();
      }
    } catch (e) {
      // Fall back to public API if authentication fails
      await context.read<HobbiesCubit>().getPublicHobbies();
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue[400]!,
                Colors.green[400]!,
              ],
            ),
          ),
        ),
        title:
            const Text("Hobby Explorer", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                isAscending = !isAscending;
                _filterAndSortHobbies();
              });
            },
            icon: Icon(
              isAscending ? Icons.arrow_upward : Icons.arrow_downward,
              color: Colors.white,
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(context, AddNewHobbyPage.route())
                  .then((_) => _fetchHobbies());
            },
            icon: const Icon(
              CupertinoIcons.add,
              color: Colors.white,
            ),
          ),
          IconButton(
            onPressed: _fetchHobbies,
            icon: const Icon(
              CupertinoIcons.refresh,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: BlocConsumer<HobbiesCubit, HobbiesState>(
        listener: (context, state) {
          if (state is HobbiesError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Error: ${state.error}"),
                action: SnackBarAction(
                  label: 'Retry',
                  onPressed: _fetchHobbies,
                ),
              ),
            );
            setState(() {
              isLoading = false;
            });
          } else if (state is GetHobbiesSuccess) {
            setState(() {
              hobbies = state.hobbies;
              _filterAndSortHobbies(); // Apply initial filtering and sorting
              isLoading = false;
              isLoaded = true;
            });
          }
        },
        builder: (context, state) {
          if (isLoading && !isLoaded) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (hobbies.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "No hobbies found",
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _fetchHobbies,
                    child: const Text("Refresh"),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Combined category dropdown and sort type
              Container(
                padding: const EdgeInsets.only(top: 8, left: 16, right: 16),
                child: Row(
                  children: [
                    const Icon(Icons.category, size: 20, color: Colors.blue),
                    const SizedBox(width: 6),
                    const Text(
                      "Category:",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButton<String>(
                        value: selectedCategory ?? 'All Categories',
                        isExpanded: true,
                        icon: const Icon(Icons.arrow_drop_down),
                        elevation: 16,
                        underline: Container(
                          height: 1,
                          color: Colors.blue[400],
                        ),
                        onChanged: (String? newValue) {
                          setState(() {
                            if (newValue == selectedCategory) return;
                            selectedCategory = newValue;
                            _filterAndSortHobbies();
                          });
                        },
                        items: categories
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    DropdownButton<String>(
                      value: currentSortAttribute,
                      icon: const Icon(Icons.sort),
                      underline: Container(height: 0),
                      onChanged: (String? newValue) {
                        setState(() {
                          if (newValue == currentSortAttribute) return;
                          currentSortAttribute = newValue!;
                          isAscending = newValue != 'popularity';
                          _filterAndSortHobbies();
                        });
                      },
                      items: [
                        {'id': 'popularity', 'label': 'Sort: Popular'},
                        {'id': 'name', 'label': 'Sort: A-Z'},
                        {'id': 'mbtiMatch', 'label': 'Sort: MBTI Match'},
                        {
                          'id': 'categoryByPopularity',
                          'label': 'Sort: Category'
                        },
                      ].map<DropdownMenuItem<String>>(
                          (Map<String, String> item) {
                        return DropdownMenuItem<String>(
                          value: item['id'],
                          child: Text(item['label']!),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              // Attribute tags (Cost, Location, Social)
              Container(
                height: 60, // Reduced height since we have fewer options
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: [
                          // MBTI Match filter - new
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              avatar: Icon(
                                Icons.psychology,
                                size: 16,
                                color: currentSortAttribute == 'mbtiMatch'
                                    ? Colors.white
                                    : Colors.deepPurple,
                              ),
                              label: const Text('MBTI Match'),
                              selected: currentSortAttribute == 'mbtiMatch',
                              onSelected: (selected) {
                                setState(() {
                                  currentSortAttribute =
                                      selected ? 'mbtiMatch' : 'popularity';
                                  isAscending = false; // Best matches first
                                  _filterAndSortHobbies();
                                });
                              },
                              selectedColor: Colors.deepPurple[400],
                              backgroundColor: Colors.grey[200],
                              labelStyle: TextStyle(
                                color: currentSortAttribute == 'mbtiMatch'
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          ),

                          // Cost level filters - simplified
                          ...attributeOptions['costLevel']!.map((value) {
                            final attributeKey = 'costLevel:$value';
                            bool isSelected = selectedAttribute == attributeKey;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                avatar: Icon(
                                  value == 'low'
                                      ? Icons.money_off
                                      : Icons.attach_money,
                                  size: 16,
                                  color:
                                      isSelected ? Colors.white : Colors.blue,
                                ),
                                label:
                                    Text(value == 'low' ? 'Budget' : 'Premium'),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    selectedAttribute =
                                        selected ? attributeKey : null;
                                    _filterAndSortHobbies();
                                  });
                                },
                                selectedColor: Colors.blue[400],
                                backgroundColor: Colors.grey[200],
                                labelStyle: TextStyle(
                                  color:
                                      isSelected ? Colors.white : Colors.black,
                                ),
                              ),
                            );
                          }).toList(),

                          // Indoor/Outdoor filters - simplified
                          ...attributeOptions['indoorOutdoor']!.map((value) {
                            final attributeKey = 'indoorOutdoor:$value';
                            bool isSelected = selectedAttribute == attributeKey;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                avatar: Icon(
                                  value == 'indoor'
                                      ? Icons.home
                                      : Icons.nature_people,
                                  size: 16,
                                  color:
                                      isSelected ? Colors.white : Colors.green,
                                ),
                                label: Text(value.capitalize()),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    selectedAttribute =
                                        selected ? attributeKey : null;
                                    _filterAndSortHobbies();
                                  });
                                },
                                selectedColor: Colors.green[600],
                                backgroundColor: Colors.grey[200],
                                labelStyle: TextStyle(
                                  color:
                                      isSelected ? Colors.white : Colors.black,
                                ),
                              ),
                            );
                          }).toList(),

                          // Social level filters - simplified
                          ...attributeOptions['socialLevel']!.map((value) {
                            final attributeKey = 'socialLevel:$value';
                            bool isSelected = selectedAttribute == attributeKey;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                avatar: Icon(
                                  value == 'solo' ? Icons.person : Icons.groups,
                                  size: 16,
                                  color:
                                      isSelected ? Colors.white : Colors.purple,
                                ),
                                label: Text(value.capitalize()),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    selectedAttribute =
                                        selected ? attributeKey : null;
                                    _filterAndSortHobbies();
                                  });
                                },
                                selectedColor: Colors.purple[400],
                                backgroundColor: Colors.grey[200],
                                labelStyle: TextStyle(
                                  color:
                                      isSelected ? Colors.white : Colors.black,
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Status indicator showing filter/sort info
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                color: Colors.blue[50],
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _getStatusText(),
                        style: const TextStyle(
                            fontStyle: FontStyle.italic, fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: RefreshIndicator(
                  onRefresh: _fetchHobbies,
                  child: ListView.builder(
                    itemCount: currentSortAttribute == 'categoryByPopularity' &&
                            selectedCategory == 'All Categories'
                        ? _calculateItemCountWithHeaders()
                        : filteredHobbies.length,
                    itemBuilder: (context, index) {
                      // If using category+popularity sorting with no specific category filter, show category headers
                      if (currentSortAttribute == 'categoryByPopularity' &&
                          selectedCategory == 'All Categories') {
                        final result = _getItemOrHeaderForIndex(index);

                        // If this is a header
                        if (result['isHeader'] == true) {
                          return Container(
                            margin: const EdgeInsets.only(
                                top: 16, left: 16, right: 16, bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  Colors.blue[400]!,
                                  Colors.blue[100]!,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.category, color: Colors.white),
                                const SizedBox(width: 8),
                                Text(
                                  result['category'] as String,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  "${result['count']} hobbies",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        // This is a hobby item
                        final hobby = result['hobby'] as HobbyModel;
                        // If using MBTI sorting, calculate match score for the hobby
                        double? mbtiMatchScore =
                            currentSortAttribute == 'mbtiMatch'
                                ? calculateMbtiMatchScore(hobby)
                                : null;

                        return HobbyCard(
                          icon: hobby.icon,
                          headerText: hobby.name,
                          descriptionText: hobby.description,
                          category: hobby.category,
                          costLevel: hobby.costLevel,
                          indoorOutdoor: hobby.indoorOutdoor,
                          socialLevel: hobby.socialLevel,
                          popularity: hobby.popularity,
                          mbtiMatchScore: mbtiMatchScore,
                          id: hobby.id,
                        );
                      }

                      // Regular list without headers
                      final hobby = filteredHobbies[index];
                      // If using MBTI sorting, calculate match score for the hobby
                      double? mbtiMatchScore =
                          currentSortAttribute == 'mbtiMatch'
                              ? calculateMbtiMatchScore(hobby)
                              : null;

                      return HobbyCard(
                        icon: hobby.icon,
                        headerText: hobby.name,
                        descriptionText: hobby.description,
                        category: hobby.category,
                        costLevel: hobby.costLevel,
                        indoorOutdoor: hobby.indoorOutdoor,
                        socialLevel: hobby.socialLevel,
                        popularity: hobby.popularity,
                        mbtiMatchScore: mbtiMatchScore,
                        id: hobby.id,
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: Container(
        height: height * 0.09,
        width: height * 0.10,
        child: FloatingActionButton(
          heroTag: "btn1_Hobby",
          shape: const CircleBorder(),
          child: Icon(
            Icons.android,
            size: width * 0.14,
          ),
          backgroundColor: Colors.white,
          foregroundColor: Colors.blue[400],
          onPressed: () {},
        ),
      ),
      // floatingActionButton: Container(
      //   height: height * 0.09,
      //   width: height * 0.10,
      //   child: FloatingActionButton(
      //       heroTag: "btn1_Home",
      //       shape: CircleBorder(),
      //       child: Icon(
      //         Icons.brush,
      //         size: width * 0.14,
      //       ),
      //       backgroundColor: Colors.white,
      //       foregroundColor: Colors.blue[400],
      //       onPressed: () {
      //         Navigator.push(context, CanvasPage.route());
      //       }),
      // ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        height: height * 0.08,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue[400]!,
              Colors.green[400]!,
            ],
          ),
        ),
        child: BottomAppBar(
          elevation: 0,
          padding: EdgeInsets.zero,
          height: height * 0.06,
          color: Colors.transparent,
          shape: CircularNotchedRectangle(),
          notchMargin: 5,
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    MaterialButton(
                      padding: const EdgeInsets.only(left: 60),
                      minWidth: 0,
                      onPressed: () {
                        Navigator.push(context, HomePage.route());
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.calendar_month,
                              size: width * 0.12, color: Colors.white),
                          Text(
                            '',
                            style: TextStyle(
                              fontSize: 1,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    MaterialButton(
                      padding: const EdgeInsets.only(right: 60),
                      minWidth: 0,
                      onPressed: () {
                        Navigator.push(context, HobbyPage.route());
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.downhill_skiing,
                              size: width * 0.12, color: Colors.white),
                          Text(
                            '',
                            style: TextStyle(
                              fontSize: 1,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              ]),
        ),
      ),
    );
  }

  // Helper method to generate status text
  String _getStatusText() {
    List<String> statusParts = [];

    // Add category info
    if (selectedCategory != null && selectedCategory != 'All Categories') {
      statusParts.add('Category: $selectedCategory');
    }

    // Add attribute filter info
    if (selectedAttribute != null) {
      final parts = selectedAttribute!.split(':');
      if (parts.length == 2) {
        final attribute = parts[0];
        final value = parts[1];

        switch (attribute) {
          case 'costLevel':
            statusParts.add('Cost: ${formatAttributeValue(attribute, value)}');
            break;
          case 'indoorOutdoor':
            statusParts
                .add('Location: ${formatAttributeValue(attribute, value)}');
            break;
          case 'socialLevel':
            statusParts
                .add('Social: ${formatAttributeValue(attribute, value)}');
            break;
        }
      }
    }

    // Add sorting info
    switch (currentSortAttribute) {
      case 'popularity':
        statusParts.add('Sorted by popularity');
        break;
      case 'name':
        statusParts.add('Sorted alphabetically');
        break;
      case 'mbtiMatch':
        statusParts.add('Sorted by MBTI compatibility');
        break;
      case 'categoryByPopularity':
        statusParts.add('Grouped by category');
        break;
      default:
        statusParts.add('Sorted by ${currentSortAttribute}');
    }

    // Add count
    statusParts.add('(${filteredHobbies.length} hobbies)');

    return statusParts.join(' • ');
  }

  int _calculateItemCountWithHeaders() {
    if (filteredHobbies.isEmpty) return 0;

    // Count the number of unique categories
    Set<String> categories = filteredHobbies.map((h) => h.category).toSet();

    // Total items = number of hobbies + number of category headers
    return filteredHobbies.length + categories.length;
  }

  Map<String, dynamic> _getItemOrHeaderForIndex(int index) {
    // Get all unique categories in the order they appear in the filtered list
    List<String> categories = [];
    Map<String, int> categoryCounts = {};

    for (var hobby in filteredHobbies) {
      if (!categories.contains(hobby.category)) {
        categories.add(hobby.category);
        categoryCounts[hobby.category] = 1;
      } else {
        categoryCounts[hobby.category] =
            (categoryCounts[hobby.category] ?? 0) + 1;
      }
    }

    // Calculate adjusted index by accounting for headers
    int currentIndex = 0;

    for (var category in categories) {
      // This is a header position
      if (currentIndex == index) {
        return {
          'isHeader': true,
          'category': category,
          'count': categoryCounts[category] ?? 0,
        };
      }

      currentIndex++; // Move past the header

      int categoryItemCount = categoryCounts[category] ?? 0;

      // Check if the index falls within this category's items
      if (index < currentIndex + categoryItemCount) {
        // Calculate which item in this category
        int itemInCategoryIndex = index - currentIndex;

        // Find that specific hobby
        int hobbyIndex =
            filteredHobbies.indexWhere((h) => h.category == category);
        for (int i = 0; i < itemInCategoryIndex; i++) {
          hobbyIndex = filteredHobbies.indexWhere(
              (h) => h.category == category, hobbyIndex + 1);
        }

        if (hobbyIndex >= 0 && hobbyIndex < filteredHobbies.length) {
          return {
            'isHeader': false,
            'hobby': filteredHobbies[hobbyIndex],
          };
        }
      }

      // Skip past all items in this category
      currentIndex += categoryItemCount;
    }

    // Fallback
    return {
      'isHeader': false,
      'hobby': filteredHobbies.last,
    };
  }

  // Add this method to calculate MBTI compatibility score between user and hobby
  double calculateMbtiMatchScore(HobbyModel hobby) {
    // Get user MBTI scores from UserCubit
    final userState = context.read<UserCubit>().state;
    if (userState is! UserLoaded) {
      return 0.0; // Default score if user data isn't available
    }

    final user = userState.user;

    // Calculate the similarity between user's MBTI scores and hobby's MBTI preferences
    // The closer to 0, the better the match (lower difference means higher compatibility)
    double eiDiff = _calculateDimension(user.mbtiEIScore, hobby.mbtiE_I_score);
    double snDiff = _calculateDimension(user.mbtiSNScore, hobby.mbtiS_N_score);
    double tfDiff = _calculateDimension(user.mbtiTFScore, hobby.mbtiT_F_score);
    double jpDiff = _calculateDimension(user.mbtiJPScore, hobby.mbtiJ_P_score);

    // Calculate total compatibility (100% = perfect match)
    // We convert differences to similarity scores (100 - diff percentage)
    double totalMatch = (eiDiff + snDiff + tfDiff + jpDiff) / 4.0;

    // Print for debugging
    print('MBTI Match for ${hobby.name}: $totalMatch%');
    print('  E/I: ${user.mbtiEIScore} vs ${hobby.mbtiE_I_score} = $eiDiff%');
    print('  S/N: ${user.mbtiSNScore} vs ${hobby.mbtiS_N_score} = $snDiff%');
    print('  T/F: ${user.mbtiTFScore} vs ${hobby.mbtiT_F_score} = $tfDiff%');
    print('  J/P: ${user.mbtiJPScore} vs ${hobby.mbtiJ_P_score} = $jpDiff%');

    return totalMatch;
  }

  // Helper method to calculate similarity for a single MBTI dimension
  double _calculateDimension(int userScore, int hobbyScore) {
    // Both scores range from -100 to +100
    // Calculate similarity percentage (100% = perfect match)

    // If hobby doesn't care about this dimension (score = 0), give 100% match
    if (hobbyScore == 0) return 100.0;

    // If user and hobby have the same preference direction (both positive or both negative)
    if ((userScore >= 0 && hobbyScore >= 0) ||
        (userScore <= 0 && hobbyScore <= 0)) {
      // Calculate how closely they match within the same direction
      // We use the absolute values to work with positive numbers
      int userAbs = userScore.abs();
      int hobbyAbs = hobbyScore.abs();

      // Calculate the difference as a percentage (lower is better)
      double diff = (userAbs - hobbyAbs).abs() / 100.0;

      // Convert to similarity (100% - difference%)
      return 100.0 - (diff * 50.0); // Scale the difference
    } else {
      // User and hobby have opposite preferences
      // The further apart they are, the worse the match
      double diff =
          (userScore - hobbyScore).abs() / 200.0; // Max difference is 200
      return 100.0 - (diff * 100.0); // Scale to percentage
    }
  }
}

// Extension to capitalize strings
extension StringExtension on String {
  String capitalize() {
    return this.isEmpty ? this : '${this[0].toUpperCase()}${this.substring(1)}';
  }
}
