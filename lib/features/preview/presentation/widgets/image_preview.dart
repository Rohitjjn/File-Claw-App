import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

import '../../../../core/themes/claude_colors.dart';

/// Pinch-zoomable image preview using photo_view.
class ImagePreview extends StatelessWidget {
  final List<int> bytes;

  const ImagePreview({super.key, required this.bytes});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      color: isDark ? ClaudeColors.darkBackground : ClaudeColors.lightBackground,
      child: PhotoView(
        imageProvider: MemoryImage(Uint8List.fromList(bytes)),
        backgroundDecoration: BoxDecoration(
          color:
              isDark ? ClaudeColors.darkBackground : ClaudeColors.lightBackground,
        ),
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 4,
        loadingBuilder: (_, __) => const Center(
          child: CircularProgressIndicator(color: ClaudeColors.primary),
        ),
        errorBuilder: (_, __, ___) => const Center(
          child: Text('Could not display this image.'),
        ),
      ),
    );
  }
}
