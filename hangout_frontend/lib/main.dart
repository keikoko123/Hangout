import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hangout_frontend/features/auth/cubit/auth_cubit.dart';
import 'package:hangout_frontend/features/auth/pages/login_page.dart';
import 'package:hangout_frontend/features/auth/pages/signup_page.dart';
import 'package:hangout_frontend/features/auth/pages/welcome_page.dart';
import 'package:hangout_frontend/features/hobby/cubit/hobbies_cubit.dart';
import 'package:hangout_frontend/features/home/cubit/tasks_cubit.dart';
import 'package:hangout_frontend/features/home/pages/home_page.dart';
import 'package:hangout_frontend/features/user/cubit/user_cubit.dart';

void main() {
  runApp(MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (_) => AuthCubit(), //context
      ),
      BlocProvider(create: (_) => TasksCubit()),
      BlocProvider(create: (_) => HobbiesCubit()),
      BlocProvider(create: (_) => UserCubit()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // First authenticate the user
    context.read<AuthCubit>().getUserData().then((_) {
      // Then fetch user data using the UserCubit
      context.read<UserCubit>().fetchUserData();
    });
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FYP-Afterwork',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // input style 1
        inputDecorationTheme: InputDecorationTheme(
          contentPadding: const EdgeInsets.all(20),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey, width: 2),
            borderRadius: BorderRadius.circular(15),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(width: 2),
            borderRadius: BorderRadius.circular(15),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: 2),
            borderRadius: BorderRadius.circular(15),
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey, width: 2),
            borderRadius: BorderRadius.circular(15),
          ),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            minimumSize: const Size(double.infinity, 60),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
      ),
      routes: {
        '/home': (context) => const HomePage(),
        '/login': (context) => const LoginPage(),
      },
      home: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          // Handle state transitions
          if (state is AuthLoggedIn) {
            print("User logged in: ${state.user.name}");
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else if (state is AuthLoggedIn) {
            // Use a more comprehensive check for MBTI assessment completion
            final user = state.user;

            // Check first login by examining whether the MBTI type is empty or null
            // AND whether any of the MBTI scores are at their default values (0)

            // final needsMbtiAssessment =
            //     (user.mbtiType == null || user.mbtiType!.isEmpty) ||
            //         (user.mbtiEIScore == 0 &&
            //             user.mbtiSNScore == 0 &&
            //             user.mbtiTFScore == 0 &&
            //             user.mbtiJPScore == 0);

            // if (needsMbtiAssessment) {
            //   print("Main: User needs to complete MBTI assessment");
            //   return WelcomePage(user: state.user);
            // }

            // Pass the user with valid token to HomePage to avoid JWT errors
            // print("Main: User has completed MBTI assessment, token: ${user.token.substring(0, 10)}...");
            return const HomePage();
          } else {
            return const LoginPage();
          }
        },
      ),
    );
  }
}
