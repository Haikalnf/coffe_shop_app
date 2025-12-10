import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/transaction_model.dart';

class FinanceProvider with ChangeNotifier {

  final String _baseUrl = 'https://6937edcb4618a71d77ce3309.mockapi.io/transactions';
  List<TransactionModel> _transactions = [];
  List<TransactionModel> get transactions => [..._transactions];

  double get totalIncome => _transactions.where((tx) => tx.type == 'masuk').fold(0.0, (s, i) => s + i.amount);
  double get totalExpense => _transactions.where((tx) => tx.type == 'keluar').fold(0.0, (s, i) => s + i.amount);

  Future<void> fetchTransactions() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _transactions = data.map((json) => TransactionModel.fromJson(json)).toList();
        _transactions.sort((a, b) => b.date.compareTo(a.date));
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addTransaction(String title, double amount, String type) async {
    final newTx = TransactionModel(
      id: '', 
      title: title, 
      amount: amount, 
      type: type, 
      date: DateTime.now()
    );

    try {
      await http.post(
        Uri.parse(_baseUrl),
        body: json.encode(newTx.toJson()),
        headers: {"Content-Type": "application/json"},
      );
      
      await fetchTransactions(); 
    } catch (e) {
      throw e;
    }
  }
}