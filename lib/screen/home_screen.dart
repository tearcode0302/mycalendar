import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mycalendar/component/main_calendar.dart';
import 'package:mycalendar/component/schedule_bottom_sheet.dart';
import 'package:mycalendar/component/schedule_card.dart';
import 'package:mycalendar/component/today_banner.dart';
import 'package:mycalendar/const/colors.dart';
import 'package:provider/provider.dart';

import '../database/drift_database.dart';
import '../provider/schedule_provider.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});
//
//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
class HomeScreen extends StatelessWidget {
  // DateTime selectedDate = DateTime.utc(
  //   DateTime.now().year,
  //   DateTime.now().month,
  //   DateTime.now().day,
  // );

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ScheduleProvider>();

    final selectedDate = provider.selectedDate;

    final schedules = provider.cache[selectedDate] ?? [];

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
            TodayBanner(
              selectedDate: selectedDate,
              count: schedules.length,
            ),
            SizedBox(height: 8.0),
            Expanded(
              // child: StreamBuilder<List<Schedule>>(
              //   stream: GetIt.I<LocalDatabase>().watchSchedules(selectedDate),
              //   builder: (context, snapshot) {
              //     if (!snapshot.hasData) {
              //       return Container();
              //     }

              child: ListView.builder(
                itemCount: schedules.length,
                itemBuilder: (context, index) {
                  final schedule = schedules[index];

                  return Dismissible(
                    key: ObjectKey(schedule.id),
                    direction: DismissDirection.startToEnd,
                    onDismissed: (DismissDirection direction) {
                      provider.deleteSchedule(date: selectedDate, id: schedule.id);
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
    // setState(() {
    //   this.selectedDate = selectedDate;
    // });
    final provider = context.read<ScheduleProvider>();
    provider.changeSelectedDate(
      date: selectedDate,
    );
    provider.getSchedules(date: selectedDate);
  }
}
