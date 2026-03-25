import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WalletService {
  WalletService._();

  static const String _keyCoins = 'wallet_coins';
  static const String _keyBalanceLegacy = 'wallet_balance';
  static const String _keyNewUserBonusGranted = 'wallet_new_user_bonus_granted_v1';

  static const int newUserBonusCoins = 20;
  static const int costMagicVideoCoins = 50;
  static const int costCreateImageCoins = 10;

  static final ValueNotifier<int> coinNotifier = ValueNotifier<int>(0);

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    var coins = prefs.getInt(_keyCoins);
    if (coins == null && prefs.containsKey(_keyBalanceLegacy)) {
      coins = (prefs.getDouble(_keyBalanceLegacy) ?? 0).floor();
      if (coins < 0) coins = 0;
      await prefs.setInt(_keyCoins, coins);
    }
    coins = prefs.getInt(_keyCoins) ?? 0;

    if (!(prefs.getBool(_keyNewUserBonusGranted) ?? false)) {
      coins += newUserBonusCoins;
      await prefs.setInt(_keyCoins, coins);
      await prefs.setBool(_keyNewUserBonusGranted, true);
    }

    coinNotifier.value = coins;
  }

  static Future<void> setCoins(int value) async {
    final v = value < 0 ? 0 : value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyCoins, v);
    coinNotifier.value = v;
  }

  static Future<void> addCoins(int delta) async {
    if (delta <= 0) return;
    await setCoins(coinNotifier.value + delta);
  }

  static Future<bool> trySpendCoins(int amount) async {
    if (amount <= 0) return true;
    if (coinNotifier.value < amount) return false;
    await setCoins(coinNotifier.value - amount);
    return true;
  }
}
