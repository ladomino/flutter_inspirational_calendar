import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

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
      title: 'Daily Calendar',
      theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity),
      home: const DailyCalendarPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class DailyCalendarPage extends StatelessWidget {
  const DailyCalendarPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Daily Calendar"),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () {
              // Navigate to a screen showing the current date and the daily phrase
            },
          ),
        ],
      ),
      body: const DailyCalendar(),
    );
  }
}

class DailyCalendar extends StatefulWidget {
  const DailyCalendar({Key? key}) : super(key: key);

  @override
  State<DailyCalendar> createState() => _DailyCalendarState();
}

class _DailyCalendarState extends State<DailyCalendar> {
  String _phrase =
      "This is a placeholder for your daily phrase"; // Example phrase
  final DateTime _currentDate = tz.TZDateTime.now(tz.local); // Current date

  @override
  void initState() {
    super.initState();
    _loadPhrase();
  }

  Future<void> _loadPhrase() async {
    // For now, we'll just use a placeholder
    setState(() {
      _phrase = "Your daily inspirational phrase goes here!";
    });
  }

  // void _changeDate(DateTime newDate) {

  //   setState(() {
  //     _currentDate = newDate;
  //   });

  //   _loadPhrase(); // Reload phrase for the new date
  // }

  @override
  Widget build(BuildContext context) {
    // Date formatting using intl package
    String dayOfWeek = DateFormat('EEEE').format(_currentDate);
    String month = DateFormat('MMMM').format(_currentDate);
    String date = DateFormat('d').format(_currentDate);
    String year = DateFormat('y').format(_currentDate);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$dayOfWeek, $month $date, $year',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),

          // Body - Phrase from DB or static for now
          Container(
            margin: const EdgeInsets.symmetric(vertical: 20.0),
            child: Text(
              _phrase,
              style: TextStyle(
                fontSize: 18,
                fontStyle: FontStyle.italic,
                color: Colors.grey[700],
              ),
            ),
          ),

          // Footer - Year
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            alignment: Alignment.centerRight,
            child: Text(
              year,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
