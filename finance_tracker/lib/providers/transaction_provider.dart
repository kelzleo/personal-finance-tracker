import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction.dart';
import '../services/api_service.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

final transactionsProvider = FutureProvider.autoDispose<List<Transaction>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  return api.getTransactions();
});

final summaryProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  return api.getSummary();
});

final filterProvider = StateProvider<String>((ref) => 'All');

final filteredTransactionsProvider = Provider.autoDispose<AsyncValue<List<Transaction>>>((ref) {
  final filter = ref.watch(filterProvider);
  final transactionsAsync = ref.watch(transactionsProvider);

  return transactionsAsync.whenData((transactions) {
    if (filter == 'All') return transactions;
    return transactions
        .where((t) => t.type.toLowerCase() == filter.toLowerCase())
        .toList();
  });
});