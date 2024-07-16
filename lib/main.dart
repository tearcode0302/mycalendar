import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mycalendar/database/drift_database.dart';
import 'package:mycalendar/firebase_options.dart';
import 'package:mycalendar/provider/schedule_provider.dart';
import 'package:mycalendar/repository/schedule_repository.dart';
import 'package:mycalendar/screen/auth_screen.dart';

import 'package:mycalendar/screen/home_screen.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await initializeDateFormatting();

  final database = LocalDatabase();

  // GetIt.I.registerSingleton<LocalDatabase>(database);
  //
  // final repository = ScheduleRepository();
  // final scheduleProvider = ScheduleProvider(repository: repository);

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthScreen(),
    )
  );
}
