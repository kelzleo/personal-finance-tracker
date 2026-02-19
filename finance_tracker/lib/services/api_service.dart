import 'package:dio/dio.dart';
import '../models/transaction.dart';

class ApiService {
  final Dio _dio;

  ApiService() : _dio = Dio(BaseOptions(
    baseUrl: 'http://10.0.3.2:3000',
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 5),
    headers: {'Content-Type': 'application/json'},
  )) {
    _dio.interceptors.add(InterceptorsWrapper(
      onError: (DioException e, handler) {
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.connectionError ||
            e.type == DioExceptionType.unknown) {
          handler.reject(DioException(
            requestOptions: e.requestOptions,
            error: 'Unable to connect to server. Please check your connection.',
            type: e.type,
          ));
        } else {
          handler.next(e);
        }
      },
    ));
  }

  Future<List<Transaction>> getTransactions() async {
    final response = await _dio.get('/transactions');
    return (response.data as List)
        .map((json) => Transaction.fromJson(json))
        .toList();
  }

  Future<Transaction> getTransaction(String id) async {
    final response = await _dio.get('/transactions/$id');
    return Transaction.fromJson(response.data);
  }

  Future<Transaction> createTransaction(Map<String, dynamic> data) async {
    final response = await _dio.post('/transactions', data: data);
    return Transaction.fromJson(response.data);
  }

  Future<Transaction> updateTransaction(String id, Map<String, dynamic> data) async {
    final response = await _dio.patch('/transactions/$id', data: data);
    return Transaction.fromJson(response.data);
  }

  Future<void> deleteTransaction(String id) async {
    await _dio.delete('/transactions/$id');
  }

  Future<Map<String, dynamic>> getSummary() async {
    final response = await _dio.get('/summary');
    return response.data;
  }
}