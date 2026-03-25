import 'package:flutter/material.dart';

import '../pages/user_agreement_page.dart';

const Color _kThemeColor = Color(0xFF00C5E8);

Future<bool> showMagicVideoComplianceDialog(BuildContext context) async {
  var agreed = false;
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            title: const Text('Image-to-video notice'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Follow applicable laws and community standards. Do not create or share videos '
                    'with sexual content, graphic violence, gore, terrorism, gambling, drugs, '
                    'infringement, defamation, or other illegal or harmful material. Violations may '
                    'lead to account restrictions or legal liability.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.45,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'First-frame images you upload or pick from My characters are reference-only. '
                    'They are uploaded to the cloud for processing and are removed from the server '
                    'after about 3 days. Back up anything important yourself.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.45,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: () async {
                      await Navigator.of(ctx).push<void>(
                        MaterialPageRoute<void>(
                          builder: (_) => const UserAgreementPage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.article_outlined, size: 20),
                    label: const Text('View User Agreement'),
                    style: TextButton.styleFrom(
                      foregroundColor: _kThemeColor,
                      padding: EdgeInsets.zero,
                      alignment: Alignment.centerLeft,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Theme(
                    data: Theme.of(ctx).copyWith(
                      checkboxTheme: CheckboxThemeData(
                        fillColor: WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.selected)) {
                            return _kThemeColor;
                          }
                          return null;
                        }),
                      ),
                    ),
                    child: CheckboxListTile(
                      value: agreed,
                      onChanged: (v) {
                        setDialogState(() => agreed = v ?? false);
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'I have read and agree to the User Agreement and will not generate illegal or harmful video content.',
                        style: TextStyle(fontSize: 14, height: 1.35),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: agreed ? () => Navigator.pop(ctx, true) : null,
                style: FilledButton.styleFrom(
                  backgroundColor: _kThemeColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Continue'),
              ),
            ],
          );
        },
      );
    },
  );
  return result == true;
}
