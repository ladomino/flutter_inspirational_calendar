import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_inspirational_calendar/providers/quotes_model_provider.dart';
import 'package:flutter_inspirational_calendar/providers/todo_model_provider.dart';
import 'package:flutter_inspirational_calendar/ui/components/linepainter.dart';
import 'package:flutter_inspirational_calendar/ui/components/todo_item.dart';
import 'package:flutter_inspirational_calendar/ui/components/todos_title.dart';
import 'package:flutter_inspirational_calendar/ui/components/todos_toolbar.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

/// Some keys used for testing
final addTodoKey = UniqueKey();
final activeFilterKey = UniqueKey();
final completedFilterKey = UniqueKey();
final allFilterKey = UniqueKey();

class Home extends HookConsumerWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todos = ref.watch(filteredTodos);
    final newTodoController = useTextEditingController();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Daily Inspirational Calendar",
              style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.purple[700],
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh,
                  color: Color.fromRGBO(255, 255, 255, 1)),
              onPressed: () {},
            ),
          ],
        ),
        body: Column(
          children: [
            const DailyCalendar(),
            Expanded(
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                children: [
                  const ToDoTitle(),
                  TextField(
                    key: addTodoKey,
                    controller: newTodoController,
                    decoration: const InputDecoration(
                      labelText: 'What needs to be done?',
                    ),
                    onSubmitted: (value) {
                      ref.read(todoListProvider.notifier).add(value);
                      newTodoController.clear();
                    },
                  ),
                  const SizedBox(height: 42),
                  const ToDoToolbar(),
                  if (todos.isNotEmpty) const Divider(height: 0),
                  for (var i = 0; i < todos.length; i++) ...[
                    if (i > 0) const Divider(height: 0),
                    Dismissible(
                      key: ValueKey(todos[i].id),
                      onDismissed: (_) {
                        ref.read(todoListProvider.notifier).remove(todos[i]);
                      },
                      child: ProviderScope(
                        overrides: [
                          currentTodo.overrideWithValue(todos[i]),
                        ],
                        child: const TodoItem(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DailyCalendar extends ConsumerStatefulWidget {
  const DailyCalendar({Key? key}) : super(key: key);

  @override
  ConsumerState<DailyCalendar> createState() => DailyCalendarState();
}

class DailyCalendarState extends ConsumerState<DailyCalendar> {
  final DateTime _currentDate = tz.TZDateTime.now(tz.local); // Current date
  Color? _cardColor;
  late Future<String> _phraseFuture;

  @override
  void initState() {
    super.initState();

    _generateRandomColor();

    _phraseFuture = _loadPhrases();
  }

  Future<String> _loadPhrases() async {
    try {
      final quotesModel = ref.read(quotesModelProvider);

      final repository = await quotesModel.getAllQuotes();

      if (repository != null) {
        final today = DateTime.now();
        final todaysQuote = repository.getQuoteForDate(today);

        if (todaysQuote != null) {
          return todaysQuote.quote;
        } else {
          return "No quotes found in the database.";
        }
      }
      return "No quotes repository available.";
    } catch (e) {
      return "Error loading today's quote.";
    }
  }

  void refresh() {
    final quotesModel = ref.read(quotesModelProvider);

    quotesModel.refreshAllQuotes();

    _generateRandomColor();
    _loadPhrases();
  }

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

    return Column(
      children: [
        const SizedBox(height: 20),
        Center(
          child: Card(
            color: _cardColor,
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.3,
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
                            size: Size(
                                MediaQuery.of(context).size.width * 0.9, 1),
                            painter: LinePainter(
                              textWidth: 0,
                              hasGap: false,
                            ))),

                    // Body - Phrase
                    Expanded(
                      child: Center(
                        child: FutureBuilder<String>(
                          future: _phraseFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else {
                              return Text(
                                snapshot.data ?? 'No quote available',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              );
                            }
                          },
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
                            size: Size(
                                MediaQuery.of(context).size.width * 0.9, 1),
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
        ),
      ],
    );
  }
}
