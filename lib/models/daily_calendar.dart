import 'package:flutter/material.dart';
import 'package:flutter_inspirational_calendar/data/quote.dart';
import 'package:flutter_inspirational_calendar/db_models/quotes_db.dart';

class QuotesModel extends ChangeNotifier {
  QuotesDatabase? _quotesDatabase;
  bool _isInitialized = false;

  QuotesModel();

  Future<void> init() async {
    if (_isInitialized) return;

    _quotesDatabase = QuotesDatabase();
    await _quotesDatabase!.initializeDB();
    _isInitialized = true;
    notifyListeners();
  }

  Future<Quote?> getTodayQuote() async {
    if (!_isInitialized) await init();
    final quoteData = await _quotesDatabase?.getTodayQuote();
    if (quoteData != null) {
      return Quote.fromMap(quoteData);
    }
    return null;
  }

  Future<QuoteRepository?> getAllQuotes() async {
    if (!_isInitialized) await init();
    final quoteRepository = await _quotesDatabase?.getAllQuotes();
    return quoteRepository;
  }

  Future<void> refreshAllQuotes() async {
    if (!_isInitialized) await init();
    await _quotesDatabase?.refreshQuotesDb();
    notifyListeners();
  }
}
