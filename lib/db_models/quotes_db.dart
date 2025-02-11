import 'dart:io';
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_inspirational_calendar/data/quote.dart';
import 'package:flutter_inspirational_calendar/shared/quote_data.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

typedef DbFunctions = Future<Database> Function(
  String path, {
  FutureOr<void> Function(Database, int)? onCreate,
  FutureOr<void> Function(Database)? onOpen,
  FutureOr<void> Function(Database)? onConfigure,
  FutureOr<void> Function(Database, int, int)? onUpgrade,
  int? version,
});

abstract class BaseDatabase {
  @protected
  Database? _db;

  @protected
  String filename;

  Database? get database => _db;

  @visibleForTesting
  set database(Database? val) {
    _db = val;
  }

  @protected
  bool initialized = false;

  bool get isInitialized => initialized;

  BaseDatabase({Database? db, required this.filename}) : _db = db;

  Future<void> initializeDB({
    DbFunctions? dbFunctions,
    String? path,
  });

  Future<void> createDbTable(Database db);

  Future<void> rmTable();

  Future<void> deleteDatabaseFile({String? path});
  Future<void> deInit() async {}
}

class QuotesDatabase extends BaseDatabase {
  Database? _quoteDB;

  QuotesDatabase({Database? db})
      : super(
          db: db,
          filename: 'quotes.db',
        );

  @visibleForTesting
  set quoteDb(Database? val) {
    _quoteDB = val;
  }

  @override
  Future<void> initializeDB({
    DbFunctions? dbFunctions,
    String? path,
  }) async {
    final openDataFunction = dbFunctions ?? openDatabase;

    final fullPath = path ?? await getDatabasesPath();

    print('Database path: $fullPath');

    final Database db = await openDataFunction(
      join(fullPath, filename),
      onCreate: (Database db, int version) async {
        await createDbTable(db);
      },
      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        await createDbTable(db);
      },
      version: 1,
    );
    _quoteDB = db;
  }

  @override
  Future<void> createDbTable(Database db) async {
    await db.execute('''
      CREATE TABLE quotes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        quote TEXT NOT NULL,
        date TEXT NOT NULL
      )
    ''');

    await _loadInitialData(db);
  }

  Future<void> _loadInitialData(Database db) async {
    final random = Random();

    final batch = db.batch();
    final now = DateTime.now();

    // Start from the first day of the current year
    final startDate = DateTime(now.year, 1, 1);

    // Create a copy of initialQuotes that we can modify
    final availableQuotes = List<String>.from(initialQuotes);

    for (int i = 0; i < 365; i++) {
      final date = startDate.add(Duration(days: i));

      String quote;

      if (availableQuotes.isNotEmpty) {
        // Randomly select a quote from the available quotes
        final randomIndex = random.nextInt(availableQuotes.length);
        quote = availableQuotes.removeAt(randomIndex);
      } else {
        // If we've used all quotes, start over with a shuffled list
        availableQuotes.addAll(initialQuotes);
        availableQuotes.shuffle(random);
        quote = availableQuotes.removeAt(0);
      }

      batch.insert('quotes', {
        'quote': quote,
        'date': date.toIso8601String(),
      });
    }

    await batch.commit();
  }

  Future<void> insertQuote(String quote, DateTime date) async {
    await database?.insert(
      'quotes',
      {
        'quote': quote,
        'date': date.toIso8601String(),
      },
    );
  }

  Future<void> insertRandomizedQuotes(List<String> quotes) async {
    final batch = database?.batch();
    final now = DateTime.now();

    quotes.asMap().forEach((index, quote) {
      final date = now.add(Duration(days: index));

      batch?.insert('quotes', {
        'quote': quote,
        'date': date.toIso8601String(),
      });
    });

    await batch?.commit();
  }

  Future<QuoteRepository> getAllQuotes() async {
    final list = await _db?.rawQuery(
      '''
      SELECT
        id,
        quote,
        date
      FROM quotes''',
    );

    try {
      return QuoteRepository.fromDB(list ?? []);
    } catch (e) {
      return QuoteRepository();
    }
  }

  Future<Map<String, dynamic>?> getTodayQuote() async {
    final today = DateTime.now();
    final todayString =
        today.toIso8601String().split('T')[0]; // Get just the date part

    print('Searching for quote on date: $todayString');

    // First, let's check if we have any quotes in the database
    final countResult = await database?.rawQuery('SELECT COUNT(*) FROM quotes');
    final count = countResult != null ? Sqflite.firstIntValue(countResult) : 0;
    print('Total quotes in database: $count');

    // Now, let's get all quotes and print their dates
    final allQuotes =
        await database?.query('quotes', columns: ['id', 'date', 'quote']);
    print(
        'All quotes: ${allQuotes?.map((q) => '${q['date']}: ${q['quote']}')}');

    // Try to get today's quote
    final result = await database?.query(
      'quotes',
      where: 'date LIKE ?',
      whereArgs: ['$todayString%'],
    );

    print('Query result for today\'s quote: $result');

    return result?.isNotEmpty == true ? result!.first : null;
  }

  Future<void> updateQuote(int id, String quote, DateTime date) async {
    final data = {
      'quote': quote,
      'date': date.toIso8601String(),
    };

    await _quoteDB?.update(
      'quotes',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteQuote(int id) async {
    await _quoteDB?.delete(
      'quotes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> close() async {
    _quoteDB?.close();
  }

  @override
  Future<void> rmTable() async {
    return _quoteDB?.execute('DROP TABLE IF EXISTS quotes');
  }

  Future<void> clearQuotesDb() async {
    return _quoteDB?.execute('DELETE FROM quotes');
  }

  Future<void> refreshQuotesDb() async {
    await clearQuotesDb();

    final db = _quoteDB;
    if (db != null) {
      await _loadInitialData(db);
    }
  }

  @override
  Future<void> deleteDatabaseFile({
    String? path,
  }) async {
    final fullPath = path ?? await getDatabasesPath();

    final file = File(join(fullPath, 'quotes.db'));

    try {
      await file.delete();
    } catch (e) {
      // print('Failed to delete database file: $e');
    }
  }

  @override
  Future<void> deInit() async {
    _quoteDB?.close();
    _quoteDB = null;
  }
}
