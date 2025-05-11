import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hangout_frontend/core/constants/utils.dart';
import 'package:hangout_frontend/features/auth/cubit/auth_cubit.dart';
import 'package:hangout_frontend/features/auth/pages/welcome_page.dart';
import 'package:hangout_frontend/features/home/cubit/tasks_cubit.dart';
// import 'package:hangout_frontend/features/home/pages/HobbyPage.dart';
import 'package:hangout_frontend/features/hobby/pages/hobby_page.dart';
import 'package:hangout_frontend/features/home/pages/canvas_page.dart';

import 'package:hangout_frontend/features/home/pages/add_new_task_page.dart';
import 'package:hangout_frontend/features/home/widgets/date_selector.dart';
import 'package:hangout_frontend/features/home/widgets/task_card.dart';
import 'package:hangout_frontend/features/home/widgets/date_selector.dart';
import 'package:intl/intl.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hangout_frontend/features/dashboard/pages/dashboard_page.dart';

class HomePage extends StatefulWidget {
  static MaterialPageRoute route() => MaterialPageRoute(
        builder: (context) => const HomePage(),
      );
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();

    // Safely handle AuthState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthCubit>().state;
      if (authState is AuthLoggedIn) {
        // Add try-catch block to handle JWT errors
        try {
          // Only attempt to get tasks if token is valid
          if (authState.user.token.isNotEmpty) {
            context.read<TasksCubit>().getAllTasks(token: authState.user.token);
          }

          // Sync tasks when wifi is available
          Connectivity().onConnectivityChanged.listen((data) async {
            if (data.contains(ConnectivityResult.wifi)) {
              print("we are on wifi now, just sync tasks~!");
              try {
                final currentAuthState = context.read<AuthCubit>().state;
                if (currentAuthState is AuthLoggedIn &&
                    currentAuthState.user.token.isNotEmpty) {
                  await context
                      .read<TasksCubit>()
                      .syncTasks(currentAuthState.user.token);
                }
              } catch (e) {
                print("Error syncing tasks: $e");
                // Do not show error to user, just log it
              }
            }
          });
        } catch (e) {
          print("Error in HomePage initialization: $e");
          // We handle auth errors in the build method, so just log here
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        if (authState is AuthLoggedIn) {
          // Add token validation check
          if (authState.user.token.isEmpty) {
            // Handle invalid token
            print("Token is empty in HomePage build method");
            // Attempt to refresh token
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.read<AuthCubit>().refreshToken();
            });

            // Show loading while refreshing
            return const Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 20),
                    Text("Refreshing session..."),
                  ],
                ),
              ),
            );
          }

          // User has MBTI type, show home page
          return _buildScaffold(context, width, height);
        } else if (authState is AuthError) {
          // Show error with retry button
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    "Authentication error: ${authState.error}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      context.read<AuthCubit>().refreshToken();
                    },
                    child: const Text("Retry"),
                  ),
                ],
              ),
            ),
          );
        } else if (authState is AuthInitial) {
          // Not logged in, redirect to welcome/login
          WidgetsBinding.instance.addPostFrameCallback((_) {
            // Navigator.pushReplacementNamed(context, '/login');
            // Since we don't have the route, just show the message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Please log in again to continue"),
                duration: Duration(seconds: 5),
              ),
            );
          });

          return const Scaffold(
            body: Center(
              child: Text("Please log in to continue"),
            ),
          );
        } else {
          // Loading or other state, show loading
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }

  Widget _buildScaffold(BuildContext context, double width, double height) {
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
          leading: IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {
              Navigator.push(context, DashboardPage.route());
            },
          ),
          title: const Text("Tasks Schedule",
              style: TextStyle(color: Colors.white)),
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(context, AddNewTaskPage.route());
              },
              icon: const Icon(
                CupertinoIcons.add,
                color: Colors.white,
              ),
            )
          ],
        ),
        body: BlocBuilder<TasksCubit, TasksState>(
          builder: (context, state) {
            if (state is TasksLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (state is TasksError) {
              return Center(child: Text(state.error));
            }

            if (state is GetTasksSuccess) {
              final tasks = state.tasks.where((task) {
                return (DateFormat('d').format(task.dueAt) ==
                        DateFormat('d').format(selectedDate) &&
                    selectedDate.month == task.dueAt.month &&
                    selectedDate.year == task.dueAt.year);
              }).toList();

              return Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DateSelector(
                      selectedDate: selectedDate,
                      onTap: (date) {
                        setState(() {
                          selectedDate = date;
                        });
                      },
                    ),
                    Expanded(
                      child: ListView.builder(
                          itemCount: tasks.length,
                          itemBuilder: (context, index) {
                            final task = tasks[index];
                            return Row(
                              children: [
                                Expanded(
                                  child: TaskCard(
                                    color: task.color,
                                    headerText: task.title,
                                    descriptionText: task.description,
                                  ),
                                ),
                                Container(
                                  height: 10,
                                  width: 10,
                                  decoration: BoxDecoration(
                                    color: strengthenColor(task.color, 0.7),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Text(
                                    DateFormat.jm().format(task.dueAt),
                                    style: const TextStyle(
                                      fontSize: 17,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }),
                    ),
                  ],
                ),
              );
            }

            return const SizedBox();
          },
        ),
        floatingActionButton: Container(
          height: height * 0.09,
          width: height * 0.10,
          child: FloatingActionButton(
              heroTag: "btn1_Home",
              shape: CircleBorder(),
              child: Icon(
                Icons.brush,
                size: width * 0.14,
              ),
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue[400],
              onPressed: () {
                Navigator.push(context, CanvasPage.route());
              }),
        ),
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
        ));
  }
}
