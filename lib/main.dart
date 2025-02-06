import 'package:flutter/material.dart';
import 'package:flutter_inspirational_calendar/ui/screens/calendar.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() {
  //Initialize the timezone
  tz.initializeTimeZones();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daily Inspirational Calendar',
      theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity),
      home: const DailyCalendarPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}


