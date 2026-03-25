import 'package:flutter/material.dart';
import '../widgets/bubble_background.dart';
import '../widgets/coin_rules_dialog.dart';
import '../widgets/create_image_form.dart';
import 'generated_image_history_page.dart';

class CreateImagePage extends StatelessWidget {
  const CreateImagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBubbleBackgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top,
              left: 4,
              right: 16,
              bottom: 8,
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                  style: IconButton.styleFrom(
                    backgroundColor: kBubbleBackgroundColor,
                    foregroundColor: Colors.black87,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.info_outline_rounded, size: 24),
                  tooltip: 'About coins',
                  onPressed: () => showCoinRulesDialog(context),
                  style: IconButton.styleFrom(
                    backgroundColor: kBubbleBackgroundColor,
                    foregroundColor: Colors.black87,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.history, size: 24),
                  tooltip: 'Image generation history',
                  onPressed: () {
                    Navigator.of(context).push<void>(
                      MaterialPageRoute<void>(
                        builder: (_) => const GeneratedImageHistoryPage(),
                      ),
                    );
                  },
                  style: IconButton.styleFrom(
                    backgroundColor: kBubbleBackgroundColor,
                    foregroundColor: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: CreateImageForm(),
            ),
          ),
        ],
      ),
    );
  }
}
