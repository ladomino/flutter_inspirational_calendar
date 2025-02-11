
import 'package:flutter_inspirational_calendar/models/daily_calendar.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final quotesModelProvider = ChangeNotifierProvider<QuotesModel>((ref) {
  return QuotesModel();
});

