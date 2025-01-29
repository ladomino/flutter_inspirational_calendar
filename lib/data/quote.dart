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

  List<Quote> getAllQuotes() {
    return _quotes.values.toList();
  }
}
