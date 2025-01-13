import 'package:connectivity_plus/connectivity_plus.dart';
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
        body: Column(
          children: [
            DateSelector(
              selectedDate: selectedDate,
              onTap: (date) {
                setState(() {
                  selectedDate = date;
                });
              },
            ),
            Row(
              children: [
                Expanded(
                  child: TaskCard(
                    headerText: "Business Task 1",
                    descriptionText: "Description 1",
                    color: Colors.red,
                    // dueAt: DateTime.now(),
                  ),
                ),
                Container(
                  height: 10,
                  width: 10,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    "08:00",
                    style: const TextStyle(
                      fontSize: 17,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: TaskCard(
                    headerText: "Business Task 2",
                    descriptionText: "Description 2",
                    color: const Color.fromARGB(255, 177, 54, 244),
                    // dueAt: DateTime.now(),
                  ),
                ),
                Container(
                  height: 10,
                  width: 10,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    "09:00",
                    style: const TextStyle(
                      fontSize: 17,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: TaskCard(
                    headerText: "Business Task 3",
                    descriptionText: "Description 3",
                    color: const Color.fromARGB(255, 125, 110, 255),
                    // dueAt: DateTime.now(),
                  ),
                ),
                Container(
                  height: 10,
                  width: 10,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    "11:00",
                    style: const TextStyle(
                      fontSize: 17,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: TaskCard(
                    headerText: "Business Task 4",
                    descriptionText: "Description 4",
                    color: const Color.fromARGB(255, 0, 190, 114),
                    // dueAt: DateTime.now(),
                  ),
                ),
                Container(
                  height: 10,
                  width: 10,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    "12:30",
                    style: const TextStyle(
                      fontSize: 17,
                    ),
                  ),
                ),
              ],
            ),
            // Row(
            //   children: [
            //     Expanded(
            //       child: TaskCard(
            //         headerText: "Business Task 5",
            //         descriptionText: "Description 5",
            //         color: const Color.fromARGB(255, 162, 255, 81),
            //         // dueAt: DateTime.now(),
            //       ),
            //     ),
            //     Container(
            //       height: 10,
            //       width: 10,
            //       decoration: BoxDecoration(
            //         color: Colors.black,
            //         shape: BoxShape.circle,
            //       ),
            //     ),
            //     Padding(
            //       padding: const EdgeInsets.all(12.0),
            //       child: Text(
            //         "14:00",
            //         style: const TextStyle(
            //           fontSize: 17,
            //         ),
            //       ),
            //     ),
            //   ],
            // ),
          ],
        ),
        //bodyEnd

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
