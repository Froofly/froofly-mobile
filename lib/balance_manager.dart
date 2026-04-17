import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BalanceManager {
  static final BalanceManager _instance = BalanceManager._internal();
  static BalanceManager get instance => _instance;

  final ValueNotifier<int> balance = ValueNotifier<int>(0);

  BalanceManager._internal() {
    _loadBalance();
  }

  Future<void> _loadBalance() async {
    final prefs = await SharedPreferences.getInstance();
    balance.value = prefs.getInt('currentBalance') ?? 0;
  }

  Future<void> updateBalance(int newBalance) async {
    balance.value = newBalance;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('currentBalance', newBalance);
  }

  Future<void> incrementBalance(int amount) async {
    final newBalance = balance.value + amount;
    await updateBalance(newBalance);
  }
}
