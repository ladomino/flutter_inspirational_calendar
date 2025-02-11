import 'package:timezone/timezone.dart' as tz;

class Quote {
  final int id;
  final String text;
  final tz.TZDateTime date;

  Quote({required this.id, required this.text, required this.date});

  factory Quote.fromMap(Map<String, dynamic> map) {
    return Quote(
      id: map['id'] as int,
      text: map['quote'] as String,
      date: tz.TZDateTime.from(DateTime.parse(map['date'] as String), tz.local),
    );
  }

  @override
  String toString() {
    return 'Quote(id: $id, text: $text, date: ${date.toString()})';
  }
}

class QuoteRepository {
  final Map<String, Quote> _quotes = {};

  QuoteRepository();

  factory QuoteRepository.fromDB(List<Map<String, dynamic>> dbData) {
    final quoteStore = QuoteRepository();

    for (var item in dbData) {
      final quote = Quote.fromMap(item);
      quoteStore._quotes[quote.id.toString()] = quote;
    }

    return quoteStore;
  }

  void addQuote(Quote quote) {
    _quotes[quote.id.toString()] = quote;
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
