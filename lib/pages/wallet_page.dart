import 'dart:async';

import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../data/wallet_coin_products.dart';
import '../services/iap_purchase_service.dart';
import '../services/wallet_service.dart';
import '../widgets/bubble_background.dart';
import '../widgets/coin_rules_dialog.dart';

const Color _kThemeColor = Color(0xFF00C5E8);

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  String? _buyingProductId;

  @override
  void initState() {
    super.initState();
    unawaited(WalletService.load());
    unawaited(IapPurchaseService.init());
  }

  Future<void> _onRefresh() async {
    await WalletService.load();
    await IapPurchaseService.refreshProducts();
  }

  Future<void> _buy(WalletCoinProduct product) async {
    if (_buyingProductId != null) return;
    setState(() => _buyingProductId = product.productId);
    try {
      await IapPurchaseService.buyConsumable(product.productId);
    } finally {
      if (mounted) setState(() => _buyingProductId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBubbleBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Wallet',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded),
            tooltip: 'About coins',
            onPressed: () => showCoinRulesDialog(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: _kThemeColor,
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ValueListenableBuilder<int>(
                valueListenable: WalletService.coinNotifier,
                builder: (context, coins, _) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 28,
                      horizontal: 20,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Coin balance',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Icon(
                              Icons.monetization_on_rounded,
                              color: Colors.amber.shade700,
                              size: 36,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '$coins',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Top up',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 10),
              ValueListenableBuilder<bool>(
                valueListenable: IapPurchaseService.queryInProgress,
                builder: (context, loading, _) {
                  if (loading) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: CircularProgressIndicator(color: _kThemeColor),
                      ),
                    );
                  }
                  return ValueListenableBuilder<Map<String, ProductDetails>>(
                    valueListenable: IapPurchaseService.productDetailsMap,
                    builder: (context, productMap, _) {
                      return Column(
                        children: [
                          for (final product in kWalletCoinProducts)
                            _ProductRow(
                              product: product,
                              details: productMap[product.productId],
                              busy: _buyingProductId == product.productId,
                              anyBuying: _buyingProductId != null,
                              onBuy: () => _buy(product),
                            ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductRow extends StatelessWidget {
  const _ProductRow({
    required this.product,
    required this.details,
    required this.busy,
    required this.anyBuying,
    required this.onBuy,
  });

  final WalletCoinProduct product;
  final ProductDetails? details;
  final bool busy;
  final bool anyBuying;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) {
    final priceLabel =
        details != null && details!.price.isNotEmpty
            ? details!.price
            : product.priceText;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _kThemeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.stars_rounded,
                    color: _kThemeColor,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${product.coins} coins',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        priceLabel,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: !anyBuying ? onBuy : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: _kThemeColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: busy
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Buy'),
                ),
              ],
            ),
        ),
      ),
    );
  }
}

