import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hangout_frontend/features/auth/cubit/auth_cubit.dart';
import 'package:hangout_frontend/features/hobby/cubit/hobbies_cubit.dart';

class AddNewHobbyPage extends StatefulWidget {
  const AddNewHobbyPage({super.key});
  static MaterialPageRoute route() => MaterialPageRoute(
        builder: (context) => const AddNewHobbyPage(),
      );

  @override
  State<AddNewHobbyPage> createState() => _AddNewHobbyPageState();
}

class _AddNewHobbyPageState extends State<AddNewHobbyPage> {
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  String selectedCategory = 'Relaxation';
  final subcategoryController = TextEditingController();
  String selectedIcon = '🌺';
  final equipmentController = TextEditingController();
  String selectedCostLevel = 'medium';
  String selectedIndoorOutdoor = 'indoor';
  String selectedSocialLevel = 'solo';
  String selectedAgeRange = 'all';
  final popularityController = TextEditingController(text: '75');
  final imageUrlController = TextEditingController();
  final mbtiE_I_scoreController = TextEditingController(text: '0');
  final mbtiS_N_scoreController = TextEditingController(text: '0');
  final mbtiT_F_scoreController = TextEditingController(text: '0');
  final mbtiJ_P_scoreController = TextEditingController(text: '0');
  String selectedMbtiE_I = 'introvert';
  String selectedMbtiS_N = 'intuition';
  String selectedMbtiT_F = 'feeling';
  String selectedMbtiJ_P = 'perceiving';
  final mbtiCompatibilityController = TextEditingController();

  final List<String> categoryOptions = [
    'Relaxation',
    'Sport',
    'Visual Arts',
    'Performance',
    'Gaming',
    'Creation'
  ];

  final List<String> iconOptions = [
    '🌺',
    '🏀',
    '🎨',
    '🎭',
    '🎮',
    '🛠️',
    '🧘‍♀️',
    '🎯'
  ];
  final List<String> costLevelOptions = ['low', 'medium', 'high'];
  final List<String> indoorOutdoorOptions = ['indoor', 'outdoor', 'both'];
  final List<String> socialLevelOptions = ['solo', 'group', 'either'];
  final List<String> ageRangeOptions = [
    'kids',
    'teens',
    'adults',
    'seniors',
    'all'
  ];
  final List<String> mbtiOptions = [
    'introvert',
    'extrovert',
    'sensing',
    'intuition',
    'thinking',
    'feeling',
    'judging',
    'perceiving'
  ];

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Hobby"),
      ),
      body: BlocListener<HobbiesCubit, HobbiesState>(
        listener: (context, state) {
          if (state is AddNewHobbySuccess) {
            Navigator.pop(context);
          } else if (state is HobbiesLoading) {
            setState(() {
              isLoading = true;
            });
          } else if (state is HobbiesError) {
            setState(() {
              isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: "Hobby Name",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: "Description",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: categoryOptions.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedCategory = newValue!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: subcategoryController,
                  decoration: const InputDecoration(
                    labelText: "Subcategory (Optional)",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedIcon,
                  decoration: const InputDecoration(
                    labelText: 'Icon',
                    border: OutlineInputBorder(),
                  ),
                  items: iconOptions.map((String icon) {
                    return DropdownMenuItem<String>(
                      value: icon,
                      child: Text(icon, style: const TextStyle(fontSize: 24)),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedIcon = newValue!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: equipmentController,
                  decoration: const InputDecoration(
                    labelText: "Equipment (comma separated)",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedCostLevel,
                  decoration: const InputDecoration(
                    labelText: 'Cost Level',
                    border: OutlineInputBorder(),
                  ),
                  items: costLevelOptions.map((String level) {
                    return DropdownMenuItem<String>(
                      value: level,
                      child: Text(level),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedCostLevel = newValue!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedIndoorOutdoor,
                  decoration: const InputDecoration(
                    labelText: 'Indoor/Outdoor',
                    border: OutlineInputBorder(),
                  ),
                  items: indoorOutdoorOptions.map((String option) {
                    return DropdownMenuItem<String>(
                      value: option,
                      child: Text(option),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedIndoorOutdoor = newValue!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedSocialLevel,
                  decoration: const InputDecoration(
                    labelText: 'Social Level',
                    border: OutlineInputBorder(),
                  ),
                  items: socialLevelOptions.map((String level) {
                    return DropdownMenuItem<String>(
                      value: level,
                      child: Text(level),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedSocialLevel = newValue!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedAgeRange,
                  decoration: const InputDecoration(
                    labelText: 'Age Range',
                    border: OutlineInputBorder(),
                  ),
                  items: ageRangeOptions.map((String range) {
                    return DropdownMenuItem<String>(
                      value: range,
                      child: Text(range),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedAgeRange = newValue!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: popularityController,
                  decoration: const InputDecoration(
                    labelText: "Popularity (0-100)",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: imageUrlController,
                  decoration: const InputDecoration(
                    labelText: "Image URL",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                const Text("MBTI Scores",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  controller: mbtiE_I_scoreController,
                  decoration: const InputDecoration(
                    labelText: "E/I Score (-100 to 100)",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: mbtiS_N_scoreController,
                  decoration: const InputDecoration(
                    labelText: "S/N Score (-100 to 100)",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: mbtiT_F_scoreController,
                  decoration: const InputDecoration(
                    labelText: "T/F Score (-100 to 100)",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: mbtiJ_P_scoreController,
                  decoration: const InputDecoration(
                    labelText: "J/P Score (-100 to 100)",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedMbtiE_I,
                  decoration: const InputDecoration(
                    labelText: 'MBTI E/I',
                    border: OutlineInputBorder(),
                  ),
                  items: ['introvert', 'extrovert'].map((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedMbtiE_I = newValue!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedMbtiS_N,
                  decoration: const InputDecoration(
                    labelText: 'MBTI S/N',
                    border: OutlineInputBorder(),
                  ),
                  items: ['sensing', 'intuition'].map((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedMbtiS_N = newValue!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedMbtiT_F,
                  decoration: const InputDecoration(
                    labelText: 'MBTI T/F',
                    border: OutlineInputBorder(),
                  ),
                  items: ['thinking', 'feeling'].map((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedMbtiT_F = newValue!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedMbtiJ_P,
                  decoration: const InputDecoration(
                    labelText: 'MBTI J/P',
                    border: OutlineInputBorder(),
                  ),
                  items: ['judging', 'perceiving'].map((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedMbtiJ_P = newValue!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: mbtiCompatibilityController,
                  decoration: const InputDecoration(
                    labelText: "MBTI Compatibility (Optional)",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            final authState = context.read<AuthCubit>().state;
                            if (authState is AuthLoggedIn) {
                              // Parse equipment string to List
                              List<String> equipmentList = equipmentController
                                  .text
                                  .split(',')
                                  .map((e) => e.trim())
                                  .where((e) => e.isNotEmpty)
                                  .toList();

                              context.read<HobbiesCubit>().createNewHobby(
                                    name: nameController.text,
                                    description: descriptionController.text,
                                    category: selectedCategory,
                                    subcategory:
                                        subcategoryController.text.isNotEmpty
                                            ? subcategoryController.text
                                            : null,
                                    icon: selectedIcon,
                                    equipment: equipmentList,
                                    costLevel: selectedCostLevel,
                                    indoorOutdoor: selectedIndoorOutdoor,
                                    socialLevel: selectedSocialLevel,
                                    ageRange: selectedAgeRange,
                                    popularity:
                                        int.parse(popularityController.text),
                                    imageUrl: imageUrlController.text.isNotEmpty
                                        ? imageUrlController.text
                                        : "$selectedCategory.jpg",
                                    mbtiE_I_score:
                                        int.parse(mbtiE_I_scoreController.text),
                                    mbtiS_N_score:
                                        int.parse(mbtiS_N_scoreController.text),
                                    mbtiT_F_score:
                                        int.parse(mbtiT_F_scoreController.text),
                                    mbtiJ_P_score:
                                        int.parse(mbtiJ_P_scoreController.text),
                                    mbtiE_I: selectedMbtiE_I,
                                    mbtiS_N: selectedMbtiS_N,
                                    mbtiT_F: selectedMbtiT_F,
                                    mbtiJ_P: selectedMbtiJ_P,
                                    mbtiCompatibility:
                                        mbtiCompatibilityController
                                                .text.isNotEmpty
                                            ? mbtiCompatibilityController.text
                                            : null,
                                    token: authState.user.token,
                                  );
                            }
                          },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: isLoading
                          ? const CircularProgressIndicator()
                          : const Text("CREATE HOBBY"),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
