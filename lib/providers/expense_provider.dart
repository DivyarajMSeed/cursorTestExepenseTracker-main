import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction.dart';
import '../models/category.dart';

class ExpenseProvider extends ChangeNotifier {
  List<Transaction> _transactions = [];
  String _selectedCurrency = 'USD';
  ThemeMode _themeMode = ThemeMode.system;
  bool _isFirstLaunch = true;

  List<Transaction> get transactions => _transactions;
  String get selectedCurrency => _selectedCurrency;
  ThemeMode get themeMode => _themeMode;
  bool get isFirstLaunch => _isFirstLaunch;

  double get totalIncome {
    return _transactions
        .where((t) => t.type == 'income')
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get totalExpenses {
    return _transactions
        .where((t) => t.type == 'expense')
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get balance => totalIncome - totalExpenses;

  List<Transaction> getTransactionsByDateRange(DateTime start, DateTime end) {
    return _transactions.where((t) {
      return t.date.isAfter(start.subtract(const Duration(days: 1))) &&
          t.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  List<Transaction> getTransactionsByCategory(String category) {
    return _transactions.where((t) => t.category == category).toList();
  }

  Map<String, double> getCategoryTotals() {
    Map<String, double> categoryTotals = {};
    for (var transaction in _transactions) {
      if (transaction.type == 'expense') {
        categoryTotals[transaction.category] =
            (categoryTotals[transaction.category] ?? 0) + transaction.amount;
      }
    }
    return categoryTotals;
  }

  Map<String, double> getMonthlyData(int year) {
    Map<String, double> monthlyData = {};
    for (int month = 1; month <= 12; month++) {
      double monthTotal = 0;
      for (var transaction in _transactions) {
        if (transaction.date.year == year &&
            transaction.date.month == month &&
            transaction.type == 'expense') {
          monthTotal += transaction.amount;
        }
      }
      monthlyData[month.toString()] = monthTotal;
    }
    return monthlyData;
  }

  Future<void> initialize() async {
    await Hive.initFlutter();
    Hive.registerAdapter(TransactionAdapter());
    await _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedCurrency = prefs.getString('currency') ?? 'USD';
    _themeMode = ThemeMode.values[prefs.getInt('themeMode') ?? 0];
    _isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;

    final box = await Hive.openBox<Transaction>('transactions');
    _transactions = box.values.toList();
    _transactions.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  Future<void> addTransaction(Transaction transaction) async {
    _transactions.add(transaction);
    _transactions.sort((a, b) => b.date.compareTo(a.date));
    
    final box = await Hive.openBox<Transaction>('transactions');
    await box.add(transaction);
    notifyListeners();
  }

  Future<void> updateTransaction(Transaction transaction) async {
    final index = _transactions.indexWhere((t) => t.id == transaction.id);
    if (index != -1) {
      _transactions[index] = transaction;
      _transactions.sort((a, b) => b.date.compareTo(a.date));
      
      final box = await Hive.openBox<Transaction>('transactions');
      await box.putAt(index, transaction);
      notifyListeners();
    }
  }

  Future<void> deleteTransaction(String id) async {
    _transactions.removeWhere((t) => t.id == id);
    
    final box = await Hive.openBox<Transaction>('transactions');
    final index = box.values.toList().indexWhere((t) => t.id == id);
    if (index != -1) {
      await box.deleteAt(index);
    }
    notifyListeners();
  }

  Future<void> setCurrency(String currency) async {
    _selectedCurrency = currency;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currency', currency);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', mode.index);
    notifyListeners();
  }

  Future<void> setFirstLaunch(bool value) async {
    _isFirstLaunch = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstLaunch', value);
    notifyListeners();
  }

  Future<void> clearAllData() async {
    _transactions.clear();
    final box = await Hive.openBox<Transaction>('transactions');
    await box.clear();
    notifyListeners();
  }

  List<Transaction> getRecentTransactions({int limit = 5}) {
    return _transactions.take(limit).toList();
  }

  List<Transaction> getTransactionsByType(String type) {
    return _transactions.where((t) => t.type == type).toList();
  }

  double getTotalByCategory(String category, String type) {
    return _transactions
        .where((t) => t.category == category && t.type == type)
        .fold(0.0, (sum, t) => sum + t.amount);
  }
}