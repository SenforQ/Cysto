import 'package:flutter/material.dart';

import '../services/wallet_service.dart';

const Color _kThemeColor = Color(0xFF00C5E8);

Future<void> showCoinRulesDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.info_outline_rounded, color: _kThemeColor, size: 26),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'About coins',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _ruleLine(
                '1',
                'New users receive ${WalletService.newUserBonusCoins} Coins',
              ),
              const SizedBox(height: 14),
              _ruleLine(
                '2',
                'Each Magic image-to-video generation costs ${WalletService.costMagicVideoCoins} Coins',
              ),
              const SizedBox(height: 14),
              _ruleLine(
                '3',
                'Each AI character image generation costs ${WalletService.costCreateImageCoins} Coins',
              ),
            ],
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: FilledButton.styleFrom(
              backgroundColor: _kThemeColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Got it'),
          ),
        ],
      );
    },
  );
}

Widget _ruleLine(String index, String text) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: 26,
        height: 26,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _kThemeColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          index,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: _kThemeColor,
            fontSize: 14,
          ),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 15,
            height: 1.45,
            color: Colors.grey.shade800,
          ),
        ),
      ),
    ],
  );
}
