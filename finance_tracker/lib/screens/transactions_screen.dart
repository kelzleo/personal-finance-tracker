import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';

class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredAsync = ref.watch(filteredTransactionsProvider);
    final summaryAsync = ref.watch(summaryProvider);
    final filter = ref.watch(filterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Finance Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(transactionsProvider);
              ref.invalidate(summaryProvider);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary Bar
          summaryAsync.when(
            data: (summary) => _SummaryBar(summary: summary),
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Container(
              color: Colors.red.shade100,
              padding: const EdgeInsets.all(8),
              child: const Text(
                'Failed to load summary. Please try again.',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ),

          // Filter Tabs
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: ['All', 'Income', 'Expense'].map((f) {
                final isSelected = filter == f;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(f),
                    selected: isSelected,
                    onSelected: (_) =>
                        ref.read(filterProvider.notifier).state = f,
                  ),
                );
              }).toList(),
            ),
          ),

          // Transaction List
          Expanded(
            child: filteredAsync.when(
              data: (transactions) {
                if (transactions.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox, size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text(
                          'No transactions found.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }
                final sorted = [...transactions]
                  ..sort((a, b) => b.date.compareTo(a.date));
              return RefreshIndicator(
  onRefresh: () async {
    ref.invalidate(transactionsProvider);
    ref.invalidate(summaryProvider);
    await ref.read(transactionsProvider.future);
  },
  child: ListView.builder(
    itemCount: sorted.length,
    itemBuilder: (context, index) {
      return _TransactionTile(transaction: sorted[index]);
    },
  ),
);
              },
              loading: () => const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading transactions...'),
                  ],
                ),
              ),
              error: (e, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.wifi_off, size: 48, color: Colors.red),
                    const SizedBox(height: 8),
                    const Text(
                      'Unable to connect to server.',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Please check your connection and try again.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      onPressed: () {
                        ref.invalidate(transactionsProvider);
                        ref.invalidate(summaryProvider);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.pushNamed('add-transaction'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _SummaryBar extends StatelessWidget {
  final Map<String, dynamic> summary;

  const _SummaryBar({required this.summary});

  @override
  Widget build(BuildContext context) {
    final income = (summary['totalIncome'] as num).toDouble();
    final expenses = (summary['totalExpenses'] as num).toDouble();
    final net = (summary['netBalance'] as num).toDouble();
    final fmt = NumberFormat.currency(symbol: '\$');

    return Container(
      color: Theme.of(context).colorScheme.primaryContainer,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _SummaryItem(
              label: 'Income', amount: fmt.format(income), color: Colors.green),
          _SummaryItem(
              label: 'Expenses',
              amount: fmt.format(expenses),
              color: Colors.red),
          _SummaryItem(
            label: 'Net',
            amount: fmt.format(net),
            color: net >= 0 ? Colors.green : Colors.red,
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String amount;
  final Color color;

  const _SummaryItem({
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Text(amount,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color)),
      ],
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final Transaction transaction;

  const _TransactionTile({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == 'income';
    final fmt = NumberFormat.currency(symbol: '\$');
    final date =
        DateFormat.yMMMd().format(DateTime.parse(transaction.date));

    return ListTile(
      onTap: () => context.pushNamed(
        'transaction-detail',
        pathParameters: {'id': transaction.id},
      ),
      leading: CircleAvatar(
        backgroundColor:
            isIncome ? Colors.green.shade100 : Colors.red.shade100,
        child: Icon(
          isIncome ? Icons.arrow_downward : Icons.arrow_upward,
          color: isIncome ? Colors.green : Colors.red,
        ),
      ),
      title: Text(transaction.title,
          style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text('${transaction.category} • $date'),
      trailing: Text(
        fmt.format(transaction.amount),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isIncome ? Colors.green : Colors.red,
        ),
      ),
    );
  }
}