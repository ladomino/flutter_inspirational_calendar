import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_inspirational_calendar/ui/components/linepainter.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

class DailyCalendarPage extends StatelessWidget {
  const DailyCalendarPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Daily Inspirational Calendar",
            style: TextStyle(
              color: Colors.white,
            )),
        backgroundColor: Colors.purple[700],
        elevation: 0, // no shadow
        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh,
              color: Colors.white,
            ),
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
  Color? _cardColor;

  @override
  void initState() {
    super.initState();
    _loadPhrase();
    _generateRandomColor();
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

  void _generateRandomColor() {
    final random = Random();
    setState(() {
      _cardColor = Color.fromRGBO(
        random.nextInt(256),
        random.nextInt(256),
        random.nextInt(256),
        0.7, // Opacity set to 0.7 for a softer look
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Date formatting using intl package
    String dayOfWeek = DateFormat('EEEE').format(_currentDate);
    String month = DateFormat('MMMM').format(_currentDate);
    String date = DateFormat('d').format(_currentDate);
    String year = DateFormat('y').format(_currentDate);

    return Center(
      child: Card(
        color: _cardColor,
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.5,
          padding: const EdgeInsets.all(20.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  '$dayOfWeek $month $date',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(
                    height: 20,
                    child: CustomPaint(
                        size: Size(MediaQuery.of(context).size.width * 0.9, 1),
                        painter: LinePainter(
                          textWidth: 0,
                          hasGap: false,
                        ))),

                // Body - Phrase
                Expanded(
                  child: Center(
                    child: Text(
                      _phrase,
                      style: const TextStyle(
                        fontSize: 18,
                        fontStyle: FontStyle.italic,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

                // Footer - Year
                SizedBox(
                  height: 30,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: Size(MediaQuery.of(context).size.width * 0.9, 1),
                        painter: LinePainter(
                          textWidth: 60,
                          hasGap: true,
                        ),
                      ),
                      Text(
                        year,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
