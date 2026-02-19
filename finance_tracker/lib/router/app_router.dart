import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../screens/transactions_screen.dart';
import '../screens/add_transaction_screen.dart';
import '../screens/transaction_detail_screen.dart';
import '../screens/edit_transaction_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'transactions',
      builder: (context, state) => const TransactionsScreen(),
    ),
    GoRoute(
      path: '/add',
      name: 'add-transaction',
      builder: (context, state) => const AddTransactionScreen(),
    ),
    GoRoute(
      path: '/transaction/:id',
      name: 'transaction-detail',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return TransactionDetailScreen(transactionId: id);
      },
    ),
    GoRoute(
      path: '/transaction/:id/edit',
      name: 'edit-transaction',
      builder: (context, state) {
        final transaction = state.extra as Transaction;
        return EditTransactionScreen(transaction: transaction);
      },
    ),
  ],
);