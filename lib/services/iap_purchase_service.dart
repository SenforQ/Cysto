import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_navigator.dart';
import '../data/wallet_coin_products.dart';
import 'wallet_service.dart';

class IapPurchaseService {
  IapPurchaseService._();

  static const String _keyProcessedPurchaseIds = 'iap_processed_purchase_ids';

  static final InAppPurchase _iap = InAppPurchase.instance;
  static StreamSubscription<List<PurchaseDetails>>? _subscription;

  static final ValueNotifier<bool> storeAvailable = ValueNotifier<bool>(false);
  static final ValueNotifier<Map<String, ProductDetails>> productDetailsMap =
      ValueNotifier<Map<String, ProductDetails>>({});
  static final ValueNotifier<bool> queryInProgress = ValueNotifier<bool>(false);
  static final ValueNotifier<String?> queryError = ValueNotifier<String?>(null);

  static Future<void> init() async {
    if (_subscription == null) {
      _subscription = _iap.purchaseStream.listen(
        _onPurchaseUpdate,
        onDone: () {},
        onError: (Object e, StackTrace st) {
          debugPrint('IAP stream error: $e');
        },
      );
    }

    final available = await _iap.isAvailable();
    storeAvailable.value = available;
    if (!available) {
      queryError.value =
          'In-app purchases are unavailable (common on simulators or when not signed in to the store).';
      return;
    }
    queryError.value = null;
    await refreshProducts();
  }

  static Future<void> refreshProducts({bool showQueryProgress = true}) async {
    if (showQueryProgress) {
      queryInProgress.value = true;
    }
    queryError.value = null;

    final available = await _iap.isAvailable();
    storeAvailable.value = available;
    if (!available) {
      if (showQueryProgress) {
        queryInProgress.value = false;
      }
      queryError.value = 'In-app purchases are unavailable.';
      return;
    }

    final ids = kWalletCoinProducts.map((e) => e.productId).toSet();
    final response = await _iap.queryProductDetails(ids);
    if (showQueryProgress) {
      queryInProgress.value = false;
    }

    if (response.error != null) {
      queryError.value = response.error!.message;
      debugPrint('queryProductDetails: ${response.error}');
    }

    final map = <String, ProductDetails>{
      for (final p in response.productDetails) p.id: p,
    };
    productDetailsMap.value = map;

    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('IAP products not found in store: ${response.notFoundIDs}');
    }
  }

  static Future<bool> buyConsumable(String productId) async {
    if (!storeAvailable.value) {
      await init();
      if (!storeAvailable.value) {
        debugPrint('IAP: store unavailable, buy skipped');
        return false;
      }
    }

    ProductDetails? details = productDetailsMap.value[productId];
    if (details == null) {
      await refreshProducts(showQueryProgress: false);
      details = productDetailsMap.value[productId];
    }
    if (details == null) {
      debugPrint('IAP: product $productId not available after refresh');
      return false;
    }

    try {
      final param = PurchaseParam(productDetails: details);
      return await _iap.buyConsumable(purchaseParam: param);
    } catch (e) {
      debugPrint('IAP: buyConsumable error: $e');
      return false;
    }
  }

  static void _showSnack(String message) {
    final ctx = appNavigatorKey.currentContext;
    if (ctx == null || !ctx.mounted) return;
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  static Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.pending) {
        continue;
      }

      if (purchase.status == PurchaseStatus.error) {
        final msg = purchase.error?.message;
        _showSnack(
          msg != null && msg.isNotEmpty ? msg : 'Purchase failed',
        );
        if (purchase.pendingCompletePurchase) {
          await _iap.completePurchase(purchase);
        }
        continue;
      }

      if (purchase.status == PurchaseStatus.purchased) {
        await _deliverIfNew(purchase);
      }

      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }
  }

  static String _dedupeKey(PurchaseDetails p) {
    final id = p.purchaseID;
    if (id != null && id.isNotEmpty) return id;
    final date = p.transactionDate;
    if (date != null && date.isNotEmpty) {
      return '${p.productID}_$date';
    }
    final local = p.verificationData.localVerificationData;
    if (local.isNotEmpty) {
      return '${p.productID}_${local.hashCode}';
    }
    return '${p.productID}_${p.hashCode}';
  }

  static Future<void> _deliverIfNew(PurchaseDetails purchase) async {
    final key = _dedupeKey(purchase);
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyProcessedPurchaseIds) ?? [];
    if (list.contains(key)) {
      return;
    }
    list.add(key);
    while (list.length > 400) {
      list.removeAt(0);
    }
    await prefs.setStringList(_keyProcessedPurchaseIds, list);

    final coins = coinsForProductId(purchase.productID);
    if (coins <= 0) {
      debugPrint('IAP: unknown product ${purchase.productID}');
      return;
    }

    await WalletService.addCoins(coins);
    _showSnack('You received $coins coins');
  }

  static void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}
