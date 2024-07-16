import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mycalendar/component/main_calendar.dart';
import 'package:mycalendar/component/schedule_bottom_sheet.dart';
import 'package:mycalendar/component/schedule_card.dart';
import 'package:mycalendar/component/today_banner.dart';
import 'package:mycalendar/const/colors.dart';
import 'package:provider/provider.dart';

import '../database/drift_database.dart';
import '../model/schedule_model.dart';
import '../provider/schedule_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  DateTime selectedDate = DateTime.utc(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  @override
  Widget build(BuildContext context) {
    // final provider = context.watch<ScheduleProvider>();
    //
    // final selectedDate = provider.selectedDate;
    //
    // final schedules = provider.cache[selectedDate] ?? [];

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: PRIMARY_COLOR,
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isDismissible: true,
            builder: (_) => ScheduleBottomSheet(
              selectedDate: selectedDate,
            ),
            isScrollControlled: true,
          );
        },
        child: Icon(
          Icons.add,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            MainCalendar(
              selectedDate: selectedDate,
              onDaySelected: (selectedDate, focusedDate) =>
                  onDaySelected(selectedDate, focusedDate, context),
            ),
            SizedBox(height: 8.0),
            // StreamBuilder<List<Schedule>>(
            //   stream: GetIt.I<LocalDatabase>().watchSchedules(selectedDate),
            //   builder: (context, snapshot) {
            //     return TodayBanner(
            //       selectedDate: selectedDate,
            //       count: snapshot.data?.length ?? 0,
            //     );
            //   }
            // ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('schedule').where('date', isEqualTo:
              '${selectedDate.year}${selectedDate.month.toString().padLeft(2,'0')}${selectedDate.day.toString().padLeft(2,'0')}').snapshots(),
              builder: (context, snapshot) {
                return TodayBanner(
                  selectedDate: selectedDate,
                  count: snapshot.data?.docs.length ?? 0,
                );
              }
            ),
            SizedBox(height: 8.0),
            Expanded(
              // child: StreamBuilder<List<Schedule>>(
              //   stream: GetIt.I<LocalDatabase>().watchSchedules(selectedDate),
              //   builder: (context, snapshot) {
              //     if (!snapshot.hasData) {
              //       return Container();
              //     }

              child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('schedule')
                      .where('date', isEqualTo: '${selectedDate.year}${selectedDate.month.toString().padLeft(2,'0')}${selectedDate.day.toString().padLeft(2,'0')}')
                      .snapshots(),
                builder: (context, snapshot) {


                  if(snapshot.hasError) {

                    return Center(
                      child: Text('일정 정보를 가져오는데 실패했어요'),
                    );
                  }

                  if(snapshot.connectionState == ConnectionState.waiting) {

                    return Container();
                  }

                  final schedules = snapshot.data!.docs.map((QueryDocumentSnapshot e) => ScheduleModel.fromJson(
                    json: (e.data() as Map<String, dynamic>)),
                  )
                  .toList();

                  // if(snapshot.hasData) {
                  //   return Center(
                  //     // child: Text('${schedules.length}'),
                  //     child: ListView.builder(itemCount: schedules.length,
                  //       itemBuilder: (context, index) {
                  //         final schedule = schedules[index];
                  //
                  //         return Dismissible(
                  //           key: ObjectKey(schedule.id),
                  //           direction: DismissDirection.startToEnd,
                  //           onDismissed: (DismissDirection direction) {
                  //             // provider.deleteSchedule(date: selectedDate, id: schedule.id);
                  //           },
                  //           child: Padding(
                  //             padding: const EdgeInsets.only(
                  //                 bottom: 8.0, left: 8.0, right: 8.0),
                  //             child: ScheduleCard(
                  //               startTime: schedule.startTime,
                  //               endTime: schedule.endTime,
                  //               content: schedule.content,
                  //             ),
                  //           ),
                  //         );
                  //       },
                  //     )
                  //   );
                  // }


                  return ListView.builder(
                    itemCount: schedules.length,
                    itemBuilder: (context, index) {
                      final schedule = schedules[index];

                      return Dismissible(
                        key: ObjectKey(schedule.id),
                        direction: DismissDirection.startToEnd,
                        onDismissed: (DismissDirection direction) {
                          // provider.deleteSchedule(date: selectedDate, id: schedule.id);

                          FirebaseFirestore.instance.collection('schedule').doc(schedule.id).delete();

                        },
                        child: Padding(
                          padding: const EdgeInsets.only(
                              bottom: 8.0, left: 8.0, right: 8.0),
                          child: ScheduleCard(
                            startTime: schedule.startTime,
                            endTime: schedule.endTime,
                            content: schedule.content,
                          ),
                        ),
                      );
                    },
                  );
                }
              ),
            ),
          ],
        ),
      ),
    );
  }

  void onDaySelected(
    DateTime selectedDate,
    DateTime focusedDate,
    BuildContext context,
  ) {
    setState(() {
      this.selectedDate = selectedDate;
    });
    // final provider = context.read<ScheduleProvider>();
    // provider.changeSelectedDate(
    //   date: selectedDate,
    // );
    // provider.getSchedules(date: selectedDate);
  }
}
