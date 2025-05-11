// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:hangout_frontend/core/constants/utils.dart';
// import 'package:hangout_frontend/features/auth/cubit/auth_cubit.dart';
// import 'package:hangout_frontend/features/home/cubit/tasks_cubit.dart';
// import 'package:hangout_frontend/features/home/pages/HobbyPage.dart';
// import 'package:hangout_frontend/features/home/pages/add_new_task_page.dart';
// import 'package:hangout_frontend/features/home/pages/home_page.dart';
// import 'package:hangout_frontend/features/home/widgets/date_selector.dart';
// import 'package:hangout_frontend/features/home/widgets/task_card.dart';
// import 'package:hangout_frontend/features/home/widgets/date_selector.dart';
// import 'package:intl/intl.dart';

// class Hobbypage extends StatefulWidget {
//   const Hobbypage({super.key});
//   static MaterialPageRoute route() => MaterialPageRoute(
//         builder: (context) => const Hobbypage(),
//       );
//   @override
//   State<Hobbypage> createState() => _HobbypageState();
// }

// class _HobbypageState extends State<Hobbypage> {
//   @override
//   Widget build(BuildContext context) {
//     double width = MediaQuery.of(context).size.width;
//     double height = MediaQuery.of(context).size.height;

//     return Scaffold(
//         appBar: AppBar(
//           flexibleSpace: Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: [
//                   Colors.blue[400]!,
//                   Colors.green[400]!,
//                 ],
//               ),
//             ),
//           ),
//           title:
//               const Text("Hobby Trend", style: TextStyle(color: Colors.white)),
//           iconTheme: const IconThemeData(color: Colors.white),
//           actions: [
//             IconButton(
//               onPressed: () {
//                 Navigator.push(context, AddNewTaskPage.route());
//               },
//               icon: const Icon(
//                 CupertinoIcons.add,
//                 color: Colors.white,
//               ),
//             )
//           ],
//         ),
//         body: BlocBuilder<TasksCubit, TasksState>(
//           builder: (context, state) {
//             return SingleChildScrollView(
//               child: Column(
//                 children: [
//                   Row(
//                     children: [
//                       Expanded(
//                         child: TaskCard(
//                           headerText: "Visual Arts",
//                           descriptionText: "Description 1",
//                           color: Colors.red,
//                         ),
//                       ),
//                       Container(
//                         height: 10,
//                         width: 10,
//                         decoration: const BoxDecoration(
//                           color: Colors.black,
//                           shape: BoxShape.circle,
//                         ),
//                       ),
//                       const Padding(
//                         padding: EdgeInsets.all(12.0),
//                         child: Text(
//                           "TOP1",
//                           style: TextStyle(
//                             fontSize: 17,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: TaskCard(
//                           headerText: "SPORT",
//                           descriptionText: "Description 2",
//                           color: const Color.fromARGB(255, 177, 54, 244),
//                         ),
//                       ),
//                       Container(
//                         height: 10,
//                         width: 10,
//                         decoration: const BoxDecoration(
//                           color: Colors.black,
//                           shape: BoxShape.circle,
//                         ),
//                       ),
//                       const Padding(
//                         padding: EdgeInsets.all(12.0),
//                         child: Text(
//                           "TOP2",
//                           style: TextStyle(
//                             fontSize: 17,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: TaskCard(
//                           headerText: "Performance",
//                           descriptionText: "Description 3",
//                           color: const Color.fromARGB(255, 125, 110, 255),
//                         ),
//                       ),
//                       Container(
//                         height: 10,
//                         width: 10,
//                         decoration: const BoxDecoration(
//                           color: Colors.black,
//                           shape: BoxShape.circle,
//                         ),
//                       ),
//                       const Padding(
//                         padding: EdgeInsets.all(12.0),
//                         child: Text(
//                           "TOP3",
//                           style: TextStyle(
//                             fontSize: 17,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: TaskCard(
//                           headerText: "Gaming",
//                           descriptionText: "Description 4",
//                           color: const Color.fromARGB(255, 0, 190, 114),
//                         ),
//                       ),
//                       Container(
//                         height: 10,
//                         width: 10,
//                         decoration: const BoxDecoration(
//                           color: Colors.black,
//                           shape: BoxShape.circle,
//                         ),
//                       ),
//                       const Padding(
//                         padding: EdgeInsets.all(12.0),
//                         child: Text(
//                           "TOP4",
//                           style: TextStyle(
//                             fontSize: 17,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: TaskCard(
//                           headerText: "Creation",
//                           descriptionText: "Description 5",
//                           color: const Color.fromARGB(255, 162, 255, 81),
//                         ),
//                       ),
//                       Container(
//                         height: 10,
//                         width: 10,
//                         decoration: const BoxDecoration(
//                           color: Colors.black,
//                           shape: BoxShape.circle,
//                         ),
//                       ),
//                       const Padding(
//                         padding: EdgeInsets.all(12.0),
//                         child: Text(
//                           "TOP5",
//                           style: TextStyle(
//                             fontSize: 17,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             );
//           },
//         ),
//         floatingActionButton: Container(
//           height: height * 0.09,
//           width: height * 0.10,
//           child: FloatingActionButton(
//               heroTag: "btn1_Home",
//               shape: const CircleBorder(),
//               child: Icon(
//                 Icons.android,
//                 size: width * 0.14,
//               ),
//               backgroundColor: Colors.white,
//               foregroundColor: Colors.blue[400],
//               onPressed: () {}),
//         ),
//         floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
//         bottomNavigationBar: Container(
//           height: height * 0.08,
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
//           child: BottomAppBar(
//             elevation: 0,
//             padding: EdgeInsets.zero,
//             height: height * 0.06,
//             color: Colors.transparent,
//             shape: const CircularNotchedRectangle(),
//             notchMargin: 5,
//             child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: <Widget>[
//                   Row(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       MaterialButton(
//                         padding: const EdgeInsets.only(left: 40),
//                         minWidth: 0,
//                         onPressed: () {
//                           Navigator.push(context, HomePage.route());
//                         },
//                         child: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(Icons.calendar_month,
//                                 size: width * 0.12, color: Colors.white),
//                             const Text(
//                               'Community',
//                               style: TextStyle(
//                                 fontSize: 1,
//                                 fontWeight: FontWeight.w800,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                   Row(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       MaterialButton(
//                         padding: const EdgeInsets.only(right: 40),
//                         minWidth: 0,
//                         onPressed: () {
//                           Navigator.push(context, Hobbypage.route());
//                         },
//                         child: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(Icons.downhill_skiing,
//                                 size: width * 0.12, color: Colors.white),
//                             const Text(
//                               'Community',
//                               style: TextStyle(
//                                 fontSize: 1,
//                                 fontWeight: FontWeight.w800,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   )
//                 ]),
//           ),
//         ));
//   }
// }
