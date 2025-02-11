import 'package:flutter/material.dart';
import 'package:flutter_inspirational_calendar/providers/quotes_model_provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_inspirational_calendar/ui/screens/calendar.dart';
import 'package:timezone/data/latest.dart' as tz;


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize the timezone
  tz.initializeTimeZones();

  final container = ProviderContainer();

  // Initialize quotes
  await container.read(quotesModelProvider).init();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<StatefulWidget> createState() {
    return _MainAppState();
  }
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daily Inspirational Calendar',
      theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity),
      home: const Home(),
      //debugShowCheckedModeBanner: false,
    );
  }
}
