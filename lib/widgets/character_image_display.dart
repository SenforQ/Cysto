import 'dart:io';

import 'package:flutter/material.dart';

import '../services/local_character_image_store.dart';

const Color _kThemeColor = Color(0xFF00C5E8);

class CharacterImageDisplay extends StatelessWidget {
  const CharacterImageDisplay({
    super.key,
    required this.imageRef,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.alignment = Alignment.center,
  });

  final String imageRef;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    if (imageRef.startsWith('assets/')) {
      return Image.asset(
        imageRef,
        fit: fit,
        width: width,
        height: height,
        alignment: alignment,
        errorBuilder: (_, __, ___) => _errorBox(),
      );
    }
    if (LocalCharacterImageStore.isLocalStored(imageRef)) {
      return FutureBuilder<File?>(
        future: LocalCharacterImageStore.fileForUrl(imageRef),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return SizedBox(
              width: width,
              height: height,
              child: const Center(
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: _kThemeColor,
                  ),
                ),
              ),
            );
          }
          final f = snapshot.data;
          if (f == null) return _errorBox();
          return Image.file(
            f,
            fit: fit,
            width: width,
            height: height,
            alignment: alignment,
            errorBuilder: (_, __, ___) => _errorBox(),
          );
        },
      );
    }
    return Image.network(
      imageRef,
      fit: fit,
      width: width,
      height: height,
      alignment: alignment,
      loadingBuilder: (_, child, progress) =>
          progress == null
              ? child
              : SizedBox(
                  width: width,
                  height: height,
                  child: const Center(
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: _kThemeColor,
                      ),
                    ),
                  ),
                ),
      errorBuilder: (_, __, ___) => _errorBox(),
    );
  }

  Widget _errorBox() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade300,
      alignment: Alignment.center,
      child: Icon(
        Icons.broken_image_outlined,
        size: height != null && height! < 100 ? 28 : 40,
        color: Colors.grey.shade500,
      ),
    );
  }
}
