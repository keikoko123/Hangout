import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hangout_frontend/core/services/sp_service.dart';
import 'package:hangout_frontend/features/auth/cubit/auth_cubit.dart';
import 'package:hangout_frontend/features/home/pages/home_page.dart';
import 'package:hangout_frontend/model/user_model.dart';
import 'package:hangout_frontend/features/user/cubit/user_cubit.dart';

class WelcomePage extends StatefulWidget {
  final UserModel user;

  const WelcomePage({super.key, required this.user});

  static MaterialPageRoute route(UserModel user) => MaterialPageRoute(
        builder: (context) => WelcomePage(user: user),
      );

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  int _currentStep = 0;
  String? _token;

  // MBTI trait scores (range from -100 to 100)
  int _eiScore = 0;
  int _snScore = 0;
  int _tfScore = 0;
  int _jpScore = 0;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  // Load and display the token
  Future<void> _loadToken() async {
    try {
      final spService = SpService();
      final token = await spService.getToken();
      if (mounted) {
        setState(() {
          _token = token;
        });
        print("Token loaded: $_token");
      }
    } catch (e) {
      print("Error loading token: $e");
    }
  }

  // Helper method to determine MBTI type based on scores
  String _calculateMbtiType() {
    final e = _eiScore > 0;
    final s = _snScore < 0;
    final t = _tfScore < 0;
    final j = _jpScore < 0;

    String type = '';

    // E or I
    type += e ? 'E' : 'I';

    // S or N
    type += s ? 'S' : 'N';

    // T or F
    type += t ? 'T' : 'F';

    // J or P
    type += j ? 'J' : 'P';

    return type;
  }

  void _submitMbtiForm() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      // First refresh user data to ensure we have the latest token and user data
      print("WelcomePage: Refreshing user data before MBTI submission");
      final dataRefreshed = await context.read<AuthCubit>().getUserData();
      if (!dataRefreshed) {
        throw "Failed to refresh user data, please try again";
      }

      // Get the latest user data from the refreshed state
      final authState = context.read<AuthCubit>().state;
      if (authState is! AuthLoggedIn) {
        throw "Authentication state is invalid";
      }

      final currentUser = authState.user;
      final mbtiType = _calculateMbtiType();

      // Show submission indicator with token info for debugging
      final spService = SpService();
      final token = await spService.getToken();
      if (token == null || token.isEmpty) {
        throw "Invalid token. Please login again.";
      }

      // Display token info in snackbar for debugging
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Token: ${token.substring(0, 10)}... Length: ${token.length}'),
          duration: const Duration(seconds: 3),
        ),
      );

      print(
          "WelcomePage: Using token for update: ${token.substring(0, 10)}...");

      // Calculate new game coin value - add 50 coin bonus for completing MBTI test
      final newGameCoin = currentUser.gameCoin + 50;
      print(
          "WelcomePage: Adding 50 game coins. Old: ${currentUser.gameCoin}, New: $newGameCoin");

      // Show detailed request info in console
      print("""
UPDATE REQUEST DETAILS:
Name: ${currentUser.name}
Email: ${currentUser.email}
Bio: ${currentUser.bio}
mbtiType: $mbtiType
scores: E/I=$_eiScore, S/N=$_snScore, T/F=$_tfScore, J/P=$_jpScore
gameCoin: $newGameCoin
      """);

      // Update the user profile via AuthCubit (this updates the token)
      final updateSuccessful =
          await context.read<AuthCubit>().updateCompleteUserProfile(
                name: currentUser.name,
                email: currentUser.email,
                bio: currentUser.bio,
                profileImage: currentUser.profileImage,
                mbtiEIScore: _eiScore,
                mbtiSNScore: _snScore,
                mbtiTFScore: _tfScore,
                mbtiJPScore: _jpScore,
                mbtiType: mbtiType,
                // gameCoin: newGameCoin,
              );

      if (!updateSuccessful) {
        throw "Failed to update profile";
      }

      // After updating via AuthCubit, also update via UserCubit
      // This directly hits the endpoint with user ID
      final userCubit = context.read<UserCubit>();
      await userCubit.updateMbtiProfile(
        eiScore: _eiScore,
        snScore: _snScore,
        tfScore: _tfScore,
        jpScore: _jpScore,
        mbtiType: mbtiType,
        gameCoin: newGameCoin,
      );

      // Then ensure we get the latest user data by direct ID fetch
      if (userCubit.currentUserId != null) {
        await userCubit.fetchUserById(userCubit.currentUserId!);
      } else {
        // Fall back to regular fetch if we don't have an ID
        await userCubit.fetchUserData();
      }

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated! You earned 50 game coins!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // Wait for the success message to be visible
      await Future.delayed(const Duration(milliseconds: 1000));

      // Go back to the previous screen
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      } else {
        // If we can't pop (somehow), go to HomePage
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } catch (e) {
      // Show error message if something goes wrong
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating profile: $e'),
          backgroundColor: Colors.red,
          duration:
              const Duration(seconds: 10), // Longer duration to read error
        ),
      );
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Welcome to AfterWork!'),
            if (_token != null)
              Text(
                'Token: ${_token!.substring(0, 10)}... (${_token!.length})',
                style: const TextStyle(fontSize: 10),
              ),
          ],
        ),
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
      ),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
            setState(() {
              _isSubmitting = false;
            });
          }
        },
        child: SingleChildScrollView(
          child: Stepper(
            currentStep: _currentStep,
            onStepContinue: () {
              if (_currentStep < 3) {
                setState(() {
                  _currentStep += 1;
                });
              } else {
                _submitMbtiForm();
              }
            },
            onStepCancel: () {
              if (_currentStep > 0) {
                setState(() {
                  _currentStep -= 1;
                });
              }
            },
            controlsBuilder: (context, details) {
              return Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Row(
                  children: [
                    Container(
                      width: 120,
                      child: ElevatedButton(
                        onPressed:
                            _isSubmitting ? null : details.onStepContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                        ),
                        child: Text(
                          _currentStep < 3 ? 'Continue' : 'Submit',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    if (_currentStep > 0) ...[
                      const SizedBox(width: 12),
                      TextButton(
                        onPressed: details.onStepCancel,
                        child: const Text('Back'),
                      ),
                    ],
                  ],
                ),
              );
            },
            steps: [
              // Step 1: Extraversion vs Introversion
              Step(
                title: const Text('Extraversion vs Introversion'),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Where do you get your energy from?',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    Slider(
                      min: -100,
                      max: 100,
                      divisions: 20,
                      value: _eiScore.toDouble(),
                      label: _eiScore < 0
                          ? 'Introversion: ${(-_eiScore / 100 * 100).round()}%'
                          : 'Extraversion: ${(_eiScore / 100 * 100).round()}%',
                      onChanged: (value) {
                        setState(() {
                          _eiScore = value.round();
                        });
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Introversion (I)',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text('• Energized by alone time'),
                              Text('• Prefers deep conversations'),
                              Text('• Thinks before speaking'),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: const [
                              Text(
                                'Extraversion (E)',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text('Energized by social interaction •'),
                              Text('Enjoys group activities •'),
                              Text('Speaks, then thinks •'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Step 2: Sensing vs Intuition
              Step(
                title: const Text('Sensing vs Intuition'),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'How do you perceive information?',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    Slider(
                      min: -100,
                      max: 100,
                      divisions: 20,
                      value: _snScore.toDouble(),
                      label: _snScore < 0
                          ? 'Sensing: ${(-_snScore / 100 * 100).round()}%'
                          : 'Intuition: ${(_snScore / 100 * 100).round()}%',
                      onChanged: (value) {
                        setState(() {
                          _snScore = value.round();
                        });
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Sensing (S)',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text('• Focuses on details'),
                              Text('• Practical and realistic'),
                              Text('• Lives in the present'),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: const [
                              Text(
                                'Intuition (N)',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text('Focuses on possibilities •'),
                              Text('Theoretical and abstract •'),
                              Text('Thinks about the future •'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Step 3: Thinking vs Feeling
              Step(
                title: const Text('Thinking vs Feeling'),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'How do you make decisions?',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    Slider(
                      min: -100,
                      max: 100,
                      divisions: 20,
                      value: _tfScore.toDouble(),
                      label: _tfScore < 0
                          ? 'Thinking: ${(-_tfScore / 100 * 100).round()}%'
                          : 'Feeling: ${(_tfScore / 100 * 100).round()}%',
                      onChanged: (value) {
                        setState(() {
                          _tfScore = value.round();
                        });
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Thinking (T)',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text('• Logical and objective'),
                              Text('• Values consistency'),
                              Text('• Focuses on fairness'),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: const [
                              Text(
                                'Feeling (F)',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text('Empathetic and subjective •'),
                              Text('Values harmony •'),
                              Text('Focuses on compassion •'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Step 4: Judging vs Perceiving
              Step(
                title: const Text('Judging vs Perceiving'),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'How do you approach life and work?',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    Slider(
                      min: -100,
                      max: 100,
                      divisions: 20,
                      value: _jpScore.toDouble(),
                      label: _jpScore < 0
                          ? 'Judging: ${(-_jpScore / 100 * 100).round()}%'
                          : 'Perceiving: ${(_jpScore / 100 * 100).round()}%',
                      onChanged: (value) {
                        setState(() {
                          _jpScore = value.round();
                        });
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Judging (J)',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text('• Organized and structured'),
                              Text('• Plans in advance'),
                              Text('• Likes closure and decisions'),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: const [
                              Text(
                                'Perceiving (P)',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text('Flexible and adaptable •'),
                              Text('Spontaneous •'),
                              Text('Open to new information •'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Center(
                      child: Column(
                        children: [
                          const Text(
                            'Your MBTI Result:',
                            style: TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue[100],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              _calculateMbtiType(),
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[800],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Submit to save your results and earn 50 game coins!',
                            style: TextStyle(fontSize: 16, color: Colors.green),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
