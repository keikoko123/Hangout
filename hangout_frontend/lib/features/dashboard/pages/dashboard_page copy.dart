// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:hangout_frontend/core/services/sp_service.dart';
// import 'package:hangout_frontend/features/auth/cubit/auth_cubit.dart';
// import 'package:hangout_frontend/features/auth/pages/welcome_page.dart';
// import 'package:hangout_frontend/features/user/cubit/user_cubit.dart';
// import 'package:hangout_frontend/model/user_model.dart';
// import 'package:percent_indicator/circular_percent_indicator.dart';
// import 'package:percent_indicator/linear_percent_indicator.dart';

// class DashboardPage extends StatefulWidget {
//   const DashboardPage({super.key});

//   static MaterialPageRoute route() => MaterialPageRoute(
//         builder: (context) => const DashboardPage(),
//       );

//   @override
//   State<DashboardPage> createState() => _DashboardPageState();
// }

// class _DashboardPageState extends State<DashboardPage>
//     with WidgetsBindingObserver {
//   bool _isRefreshing = false;
//   final FocusNode _pageFocusNode = FocusNode();
//   final String _baseUrl = 'http://10.0.2.2:8000';
//   UserModel? _directUserData;

//   @override
//   void initState() {
//     super.initState();
//     // Register with WidgetsBinding to detect app lifecycle changes
//     WidgetsBinding.instance.addObserver(this);

//     // Focus node listener to detect when page gains focus
//     _pageFocusNode.addListener(_onFocusChange);

//     // Directly fetch user data when the page is initialized
//     // This ensures fresh data every time Dashboard is opened
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _fetchUserDirectly();
//       FocusScope.of(context).requestFocus(_pageFocusNode);
//     });
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();

//     // Always fetch fresh data when page is opened
//     _fetchUserDirectly();

//     // Also request data through the UserCubit as a backup
//     final userCubit = context.read<UserCubit>();
//     if (userCubit.currentUserId != null) {
//       userCubit.fetchUserById(userCubit.currentUserId!);
//     } else {
//       userCubit.refreshCurrentUser();
//     }
//   }

//   @override
//   void dispose() {
//     // Unregister lifecycle observer
//     WidgetsBinding.instance.removeObserver(this);
//     _pageFocusNode.removeListener(_onFocusChange);
//     _pageFocusNode.dispose();
//     super.dispose();
//   }

//   // Handle app lifecycle changes (inactive -> resumed)
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.resumed) {
//       // App came back to the foreground, refresh data
//       _fetchUserDirectly();
//     }
//   }

//   void _onFocusChange() {
//     if (_pageFocusNode.hasFocus) {
//       // Page gained focus, refresh data directly from API
//       _fetchUserDirectly();
//     }
//   }

//   // Method to fetch user directly from the API using the stored ID
//   Future<void> _fetchUserDirectly() async {
//     if (_isRefreshing) return;

//     setState(() {
//       _isRefreshing = true;
//     });

//     try {
//       // Get the saved user ID and token
//       final spService = SpService();
//       final userId = await spService.getId();
//       final token = await spService.getToken();

//       if (userId == null || userId.isEmpty) {
//         throw Exception("No user ID found");
//       }

//       if (token == null || token.isEmpty) {
//         throw Exception("No authentication token found");
//       }

//       print("Fetching user directly from API: $_baseUrl/users/$userId");

//       // Force cache refresh by adding timestamp to URL
//       final timestamp = DateTime.now().millisecondsSinceEpoch;

//       // Make a direct API request to get the latest user data
//       final response = await http.get(
//         Uri.parse('$_baseUrl/users/$userId?_t=$timestamp'),
//         headers: {
//           'Content-Type': 'application/json',
//           'x-auth-token': token,
//           'Cache-Control': 'no-cache, no-store, must-revalidate',
//           'Pragma': 'no-cache',
//         },
//       );

//       if (response.statusCode == 200) {
//         final userData = json.decode(response.body);
//         final userModel = UserModel.fromMap(userData);

//         print("Successfully fetched fresh user data: ${response.body}");

//         // Update the UserCubit as well to keep everything in sync
//         context.read<UserCubit>().fetchUserById(userId);

//         // Update local state with the direct API data
//         setState(() {
//           _directUserData = userModel;
//           _isRefreshing = false;
//         });
//       } else {
//         print("Failed to fetch user by ID: ${response.statusCode}");
//         print("Response body: ${response.body}");

//         // Show error to user
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text("Error fetching data: HTTP ${response.statusCode}"),
//               backgroundColor: Colors.red,
//             ),
//           );
//         }

//         // Fall back to UserCubit
//         await context.read<UserCubit>().refreshCurrentUser();
//         setState(() {
//           _isRefreshing = false;
//         });
//       }
//     } catch (e) {
//       print("Error fetching user directly: $e");

//       // Fall back to UserCubit on error
//       try {
//         await context.read<UserCubit>().refreshCurrentUser();
//       } catch (cubError) {
//         print("Error refreshing user cubit data: $cubError");
//       }

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text("Failed to refresh data: $e"),
//             backgroundColor: Colors.orange,
//           ),
//         );

//         setState(() {
//           _isRefreshing = false;
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Wrap with Focus widget to detect focus
//     return Focus(
//       focusNode: _pageFocusNode,
//       child: BlocBuilder<UserCubit, UserState>(
//         builder: (context, state) {
//           // If we have direct data from API, use it
//           if (_directUserData != null) {
//             return _buildDashboard(_directUserData!);
//           }

//           // Otherwise fall back to UserCubit state
//           if (state is UserLoaded) {
//             return _buildDashboard(state.user);
//           }

//           if (state is UserLoading) {
//             return _buildLoadingScreen();
//           }

//           if (state is UserError) {
//             return _buildErrorScreen(state.message);
//           }

//           // Initial state or not logged in
//           return _buildLoginPrompt();
//         },
//       ),
//     );
//   }

//   // Helper method to build the dashboard with user data
//   Widget _buildDashboard(UserModel user) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text('Dashboard'),
//             // if (_directUserData != null)
//             //   Text(
//             //     'Response: ${jsonEncode(_directUserData!.toMap())}',
//             //     style: const TextStyle(fontSize: 10),
//             //     overflow: TextOverflow.ellipsis,
//             //     maxLines: 2,
//             //   ),
//           ],
//         ),
//         flexibleSpace: Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: [
//                 Colors.blue[400]!,
//                 Colors.green[400]!,
//               ],
//             ),
//           ),
//         ),
//         elevation: 0,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: _isRefreshing ? null : _fetchUserDirectly,
//           ),
//         ],
//       ),
//       body: RefreshIndicator(
//         onRefresh: _fetchUserDirectly,
//         child: SingleChildScrollView(
//           physics: const AlwaysScrollableScrollPhysics(),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _isRefreshing
//                   ? const LinearProgressIndicator()
//                   : const SizedBox(height: 4),
//               _buildUserProfileCard(user),
//               _buildMbtiSection(user),
//               _buildGameCoinSection(user),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // Helper method to build loading screen
//   Widget _buildLoadingScreen() {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Dashboard'),
//         flexibleSpace: Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: [
//                 Colors.blue[400]!,
//                 Colors.green[400]!,
//               ],
//             ),
//           ),
//         ),
//       ),
//       body: const Center(
//         child: CircularProgressIndicator(),
//       ),
//     );
//   }

//   // Helper method to build error screen
//   Widget _buildErrorScreen(String message) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Dashboard'),
//         flexibleSpace: Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: [
//                 Colors.blue[400]!,
//                 Colors.green[400]!,
//               ],
//             ),
//           ),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: _fetchUserDirectly,
//           ),
//         ],
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(
//               Icons.error_outline,
//               color: Colors.red,
//               size: 60,
//             ),
//             const SizedBox(height: 16),
//             Text(
//               message,
//               style: const TextStyle(fontSize: 16),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: _fetchUserDirectly,
//               child: const Text('Retry'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Helper method to build login prompt
//   Widget _buildLoginPrompt() {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Dashboard'),
//         flexibleSpace: Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: [
//                 Colors.blue[400]!,
//                 Colors.green[400]!,
//               ],
//             ),
//           ),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: _fetchUserDirectly,
//           ),
//         ],
//       ),
//       body: const Center(
//         child: Text('Please login to view your dashboard'),
//       ),
//     );
//   }

//   Widget _buildUserProfileCard(UserModel user) {
//     return Card(
//       margin: const EdgeInsets.all(16),
//       elevation: 4,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 CircleAvatar(
//                   radius: 40,
//                   backgroundColor: Colors.grey[200],
//                   backgroundImage: user.profileImage != null
//                       ? NetworkImage(user.profileImage!)
//                       : null,
//                   child: user.profileImage == null
//                       ? Text(
//                           user.name.isNotEmpty
//                               ? user.name[0].toUpperCase()
//                               : '?',
//                           style: const TextStyle(
//                             fontSize: 32,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         )
//                       : null,
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         user.name,
//                         style: const TextStyle(
//                           fontSize: 22,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       if (_directUserData != null)
//                         Text(
//                           'Response: ${jsonEncode(_directUserData!.toMap())}',
//                           style: const TextStyle(fontSize: 12),
//                           overflow: TextOverflow.ellipsis,
//                           maxLines: 5,
//                         ),
//                       // Text(
//                       //   user.email,
//                       //   style: TextStyle(
//                       //     fontSize: 16,
//                       //     color: Colors.grey[600],
//                       //   ),
//                       // ),
//                       const SizedBox(height: 8),
//                       if (user.mbtiType != null && user.mbtiType!.isNotEmpty)
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 12,
//                             vertical: 6,
//                           ),
//                           decoration: BoxDecoration(
//                             color: Colors.blue[100],
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: Text(
//                             user.mbtiType!,
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               color: Colors.blue[800],
//                             ),
//                           ),
//                         ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             if (user.bio != null && user.bio!.isNotEmpty) ...[
//               const SizedBox(height: 16),
//               const Text(
//                 'Bio',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 user.bio!,
//                 style: const TextStyle(fontSize: 16),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildMbtiSection(UserModel user) {
//     // Helper function to convert -100 to 100 score to 0 to 1 percentage
//     double scoreToPercentage(int score) {
//       return (score + 100) / 200;
//     }

//     // Convert scores to percentages for display
//     final eiPercentage = scoreToPercentage(user.mbtiEIScore);
//     final snPercentage = scoreToPercentage(user.mbtiSNScore);
//     final tfPercentage = scoreToPercentage(user.mbtiTFScore);
//     final jpPercentage = scoreToPercentage(user.mbtiJPScore);

//     // Helper function for trait display text
//     String getTraitText(
//         double percentage, String leftTrait, String rightTrait) {
//       if (percentage < 0.4) {
//         return "Strong $leftTrait";
//       } else if (percentage < 0.45) {
//         return "Moderate $leftTrait";
//       } else if (percentage < 0.55) {
//         return "Balanced";
//       } else if (percentage < 0.6) {
//         return "Moderate $rightTrait";
//       } else {
//         return "Strong $rightTrait";
//       }
//     }

//     return Card(
//       margin: const EdgeInsets.all(16),
//       elevation: 4,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text(
//                   'MBTI Personality',
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 if (user.mbtiType != null && user.mbtiType!.isNotEmpty)
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 12,
//                       vertical: 6,
//                     ),
//                     decoration: BoxDecoration(
//                       color: Colors.blue[100],
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Text(
//                       user.mbtiType!,
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: Colors.blue[800],
//                         fontSize: 18,
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//             const SizedBox(height: 10),

//             // Retake MBTI Test Button
//             ElevatedButton.icon(
//               onPressed: () {
//                 Navigator.push(context, WelcomePage.route(user));
//               },
//               icon: const Icon(Icons.quiz, color: Colors.white),
//               label: const Text('Check Your MBTI to Win 50 Coins!',
//                   style: TextStyle(color: Colors.white)),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.blue[700],
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//             ),

//             const SizedBox(height: 24),

//             // E/I Scale
//             _buildPersonalityScale(
//               leftLabel: 'I',
//               leftText: 'Introversion',
//               rightLabel: 'E',
//               rightText: 'Extraversion',
//               percentage: eiPercentage,
//               color: Colors.blue,
//               description:
//                   getTraitText(eiPercentage, "Introversion", "Extraversion"),
//             ),

//             const SizedBox(height: 20),

//             // S/N Scale
//             _buildPersonalityScale(
//               leftLabel: 'S',
//               leftText: 'Sensing',
//               rightLabel: 'N',
//               rightText: 'Intuition',
//               percentage: snPercentage,
//               color: Colors.green,
//               description: getTraitText(snPercentage, "Sensing", "Intuition"),
//             ),

//             const SizedBox(height: 20),

//             // T/F Scale
//             _buildPersonalityScale(
//               leftLabel: 'T',
//               leftText: 'Thinking',
//               rightLabel: 'F',
//               rightText: 'Feeling',
//               percentage: tfPercentage,
//               color: Colors.orange,
//               description: getTraitText(tfPercentage, "Thinking", "Feeling"),
//             ),

//             const SizedBox(height: 20),

//             // J/P Scale
//             _buildPersonalityScale(
//               leftLabel: 'J',
//               leftText: 'Judging',
//               rightLabel: 'P',
//               rightText: 'Perceiving',
//               percentage: jpPercentage,
//               color: Colors.purple,
//               description: getTraitText(jpPercentage, "Judging", "Perceiving"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildPersonalityScale({
//     required String leftLabel,
//     required String leftText,
//     required String rightLabel,
//     required String rightText,
//     required double percentage,
//     required Color color,
//     required String description,
//   }) {
//     // Create darker variations of the input color
//     final darkColor = color.withOpacity(0.8);
//     final mediumColor = color.withOpacity(0.7);

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Text(
//               leftLabel,
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 18,
//                 color: darkColor,
//               ),
//             ),
//             const Spacer(),
//             Text(
//               rightLabel,
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 18,
//                 color: darkColor,
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 4),
//         LinearPercentIndicator(
//           lineHeight: 12,
//           percent: percentage,
//           backgroundColor: Colors.grey[200],
//           progressColor: color,
//           barRadius: const Radius.circular(8),
//           animation: true,
//           animationDuration: 1000,
//         ),
//         const SizedBox(height: 4),
//         Row(
//           children: [
//             Text(
//               leftText,
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Colors.grey[600],
//               ),
//             ),
//             const Spacer(),
//             Text(
//               rightText,
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Colors.grey[600],
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 8),
//         Text(
//           description,
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.w500,
//             color: mediumColor,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildGameCoinSection(UserModel user) {
//     // Calculate level based on game coins
//     final level = (user.gameCoin / 100).floor() + 1;
//     final progressToNextLevel = (user.gameCoin % 100) / 100;
//     final coinsToNextLevel = 100 - (user.gameCoin % 100);

//     return Card(
//       margin: const EdgeInsets.all(16),
//       elevation: 4,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Game Progress',
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 24),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         const Icon(
//                           Icons.monetization_on,
//                           color: Colors.amber,
//                           size: 28,
//                         ),
//                         const SizedBox(width: 8),
//                         Text(
//                           '${user.gameCoin} Coins',
//                           style: const TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       'Level $level',
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.blue[700],
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       '$coinsToNextLevel coins to Level ${level + 1}',
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: Colors.grey[600],
//                       ),
//                     ),
//                   ],
//                 ),
//                 CircularPercentIndicator(
//                   radius: 45.0,
//                   lineWidth: 10.0,
//                   percent: progressToNextLevel,
//                   center: Text(
//                     "${(progressToNextLevel * 100).toInt()}%",
//                     style: const TextStyle(
//                         fontWeight: FontWeight.bold, fontSize: 16),
//                   ),
//                   progressColor: Colors.green,
//                   backgroundColor: Colors.grey[200]!,
//                   circularStrokeCap: CircularStrokeCap.round,
//                   animation: true,
//                   animationDuration: 1200,
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),
//             const Text(
//               'Achievements',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 12),
//             _buildAchievementItem(
//               icon: Icons.star,
//               color: Colors.amber,
//               title: 'Profile Complete',
//               isUnlocked: user.profileImage != null && user.bio != null,
//               reward: 10,
//             ),
//             _buildAchievementItem(
//               icon: Icons.psychology,
//               color: Colors.blue,
//               title: 'MBTI Test Complete',
//               isUnlocked: user.mbtiType != null && user.mbtiType!.isNotEmpty,
//               reward: 50,
//             ),
//             _buildAchievementItem(
//               icon: Icons.emoji_events,
//               color: Colors.orange,
//               title: 'Reach Level 5',
//               isUnlocked: level >= 5,
//               reward: 100,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildAchievementItem({
//     required IconData icon,
//     required Color color,
//     required String title,
//     required bool isUnlocked,
//     required int reward,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: isUnlocked ? color.withOpacity(0.1) : Colors.grey[200],
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Icon(
//               icon,
//               color: isUnlocked ? color : Colors.grey,
//               size: 24,
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Text(
//               title,
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: isUnlocked ? FontWeight.bold : FontWeight.normal,
//                 color: isUnlocked ? Colors.black : Colors.grey,
//               ),
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//             decoration: BoxDecoration(
//               color: isUnlocked ? Colors.green[100] : Colors.grey[200],
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Row(
//               children: [
//                 Icon(
//                   Icons.monetization_on,
//                   color: isUnlocked ? Colors.amber : Colors.grey,
//                   size: 16,
//                 ),
//                 const SizedBox(width: 4),
//                 Text(
//                   '+$reward',
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     color: isUnlocked ? Colors.green[800] : Colors.grey,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
