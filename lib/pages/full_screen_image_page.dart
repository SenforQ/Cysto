import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gal/gal.dart';
import 'package:http/http.dart' as http;

import '../services/local_character_image_store.dart';
import '../widgets/character_image_display.dart';

const Color _kThemeColor = Color(0xFF00C5E8);

class FullScreenImagePage extends StatelessWidget {
  const FullScreenImagePage({
    super.key,
    required this.imageUrl,
  });

  final String imageUrl;

  Future<Uint8List?> _getImageBytes() async {
    if (imageUrl.startsWith('assets/')) {
      final data = await rootBundle.load(imageUrl);
      return data.buffer.asUint8List();
    }
    if (LocalCharacterImageStore.isLocalStored(imageUrl)) {
      final f = await LocalCharacterImageStore.fileForUrl(imageUrl);
      if (f != null && await f.exists()) {
        return f.readAsBytes();
      }
      return null;
    }
    final response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode == 200) {
      return response.bodyBytes;
    }
    return null;
  }

  Future<void> _saveToAlbum(BuildContext context) async {
    final bytes = await _getImageBytes();
    if (bytes == null || bytes.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to get image')),
        );
      }
      return;
    }
    try {
      await Gal.putImageBytes(bytes, name: 'character_${DateTime.now().millisecondsSinceEpoch}');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Saved to album')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Save failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return CharacterImageDisplay(
                      imageRef: imageUrl,
                      fit: BoxFit.contain,
                      width: constraints.maxWidth,
                      height: constraints.maxHeight,
                    );
                  },
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12, top: 4),
                    child: Material(
                      color: Colors.white,
                      shape: const CircleBorder(),
                      elevation: 3,
                      shadowColor: Colors.black38,
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => Navigator.of(context).pop(),
                        child: const SizedBox(
                          width: 44,
                          height: 44,
                          child: Center(
                            child: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.black87,
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: FloatingActionButton(
                      onPressed: () => _saveToAlbum(context),
                      backgroundColor: _kThemeColor,
                      child: const Icon(Icons.download, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
