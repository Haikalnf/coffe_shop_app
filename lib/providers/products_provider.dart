import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/coffee.dart';

class ProductsProvider with ChangeNotifier {
  final String _baseUrl = 'https://6937edcb4618a71d77ce3309.mockapi.io/coffee';

  List<Coffee> _items = [];
  List<Coffee> get items => [..._items];

  Future<void> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));
      if (response.statusCode == 200) {
        final List<dynamic> extractedData = json.decode(response.body);
        _items = extractedData.map((json) => Coffee.fromJson(json)).toList();
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addProduct(Coffee coffee) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        body: json.encode(coffee.toJson()),
        headers: {"Content-Type": "application/json"},
      );
      if (response.statusCode == 201) {
        final newProduct = Coffee.fromJson(json.decode(response.body));
        _items.add(newProduct);
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateProduct(String id, Coffee newCoffee) async {
    final index = _items.indexWhere((prod) => prod.id == id);
    if (index >= 0) {
      final url = '$_baseUrl/$id';
      await http.put(
        Uri.parse(url),
        body: json.encode(newCoffee.toJson()),
        headers: {"Content-Type": "application/json"},
      );
      _items[index] = newCoffee;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String id) async {
    final url = '$_baseUrl/$id';
    final existingIndex = _items.indexWhere((prod) => prod.id == id);
    _items.removeAt(existingIndex);
    notifyListeners();

    final response = await http.delete(Uri.parse(url));
    if (response.statusCode >= 400) {
      await fetchProducts();
    }
  }
}
