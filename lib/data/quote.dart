import 'package:timezone/timezone.dart' as tz;

class Quote {
  final String id;
  final String quote;
  final tz.TZDateTime date;

  Quote({
    required this.id,
    required this.quote,
    required this.date,
  });

  factory Quote.fromMap(Map<dynamic, dynamic> map) {
    return Quote(
      id: map['id'],
      quote: map['quote'],
      date: tz.TZDateTime.from(DateTime.parse(map['date'] as String), tz.local),
    );
  }

  @override
  String toString() {
    return 'Quote(id: $id, quote: $quote, date: ${date.toString()})';
  }
}

class QuoteRepository {
  final Map<String, Quote> _quotes = {};

  QuoteRepository();

  factory QuoteRepository.fromDB(List<Map> input) {
    final quoteStore = QuoteRepository();

    for (final item in input) {
      final quote = Quote.fromMap(item);

      quoteStore.addQuote(quote);
    }

    return quoteStore;
  }

  void addQuote(Quote quote) {
    _quotes[quote.id] = quote;
  }

  Quote? getQuote(String id) {
    return _quotes[id];
  }

  List<Quote> getAllQuotesList() {
    return _quotes.values.toList();
  }

  // New method to get quote for a specific date
  Quote? getQuoteForDate(DateTime date) {
    final targetDate = tz.TZDateTime.from(date, tz.local);

    final matchingQuote = _quotes.values.where(
      (quote) =>
          quote.date.year == targetDate.year &&
          quote.date.month == targetDate.month &&
          quote.date.day == targetDate.day,
    );

    return matchingQuote.isNotEmpty ? matchingQuote.first : null;
  }

  @override
  String toString() {
    return 'QuoteRepository(\n  quotes: {\n    ${_quotes.entries.map((e) => '${e.key}: ${e.value}').join(',\n    ')}\n  }\n)';
  }
}
