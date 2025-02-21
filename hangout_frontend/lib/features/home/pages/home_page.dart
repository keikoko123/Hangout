import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hangout_frontend/core/constants/utils.dart';
import 'package:hangout_frontend/features/auth/cubit/auth_cubit.dart';
import 'package:hangout_frontend/features/home/cubit/tasks_cubit.dart';
import 'package:hangout_frontend/features/home/pages/HobbyPage.dart';
import 'package:hangout_frontend/features/home/pages/add_new_task_page.dart';
import 'package:hangout_frontend/features/home/widgets/date_selector.dart';
import 'package:hangout_frontend/features/home/widgets/task_card.dart';
import 'package:hangout_frontend/features/home/widgets/date_selector.dart';
import 'package:intl/intl.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

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

    final user = context.read<AuthCubit>().state as AuthLoggedIn;
    context.read<TasksCubit>().getAllTasks(token: user.user.token);
    // sync tasks when wifi is available
    Connectivity().onConnectivityChanged.listen((data) async {
      if (data.contains(ConnectivityResult.wifi)) {
        print("we are on wifi now, just sync tasks~!");
        await context.read<TasksCubit>().syncTasks(user.user.token);

        //should be improved, should not setstate every time in loading in home page
        //Exception has occurred. FlutterError (setState() called after dispose(): _HomePageState#e2baa(lifecycle state: defunct, not mounted)
        // setState(() {
        //   print("synced tasks");
        // });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
        appBar: AppBar(
          title: const Text("Tasks Schedule"),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(context, AddNewTaskPage.route());
              },
              icon: const Icon(
                CupertinoIcons.add,
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
              // final tasks = state.tasks;
              final tasks = state.tasks.where((task) {
                return (DateFormat('d').format(task.dueAt) ==
                        DateFormat('d').format(selectedDate) &&
                    selectedDate.month == task.dueAt.month &&
                    selectedDate.year == task.dueAt.year);
              }).toList();

              return Column(
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
                                  //DateFormat('HH:mm').format(task.dueAt),
                                  // DateFormat('HH:mm')
                                  //     .format(task.dueAt),
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
              child: Icon(
                Icons.android,
                size: width * 0.11,
              ),
              onPressed: () {}),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          shape: CircularNotchedRectangle(),
          notchMargin: 5,
          child: Container(
            height: height * 0.1,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //! start
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      MaterialButton(
                        padding: const EdgeInsets.only(left: 40),
                        minWidth: 0,
                        onPressed: () {
                          Navigator.push(context, HomePage.route());
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.calendar_month,
                                size: width * 0.12,

                                //Icons.group,
                                color: Colors.grey),
                            Text(
                              'Community',
                              style: TextStyle(
                                fontSize: 3,
                                fontWeight: FontWeight.w800,
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
                        padding: const EdgeInsets.only(right: 40),
                        minWidth: 0,
                        onPressed: () {
                          Navigator.push(context, Hobbypage.route());
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.downhill_skiing,
                                size: width * 0.12,

                                //Icons.group,
                                color: Colors.grey),
                            Text(
                              'Community',
                              style: TextStyle(
                                fontSize: 3,
                                fontWeight: FontWeight.w800,
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
