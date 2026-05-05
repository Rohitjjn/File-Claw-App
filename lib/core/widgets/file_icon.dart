import 'package:flutter/material.dart';

import '../../models/file_type.dart';
import '../themes/claude_colors.dart';

/// Compact rounded badge that displays an appropriate Material icon and
/// orange tint for the given [FileType].
class FileIconBadge extends StatelessWidget {
  final FileType type;
  final double size;
  final String? extensionLabel;

  const FileIconBadge({
    super.key,
    required this.type,
    this.size = 40,
    this.extensionLabel,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = ClaudeColors.primary.withValues(alpha: isDark ? 0.18 : 0.12);
    const fg = ClaudeColors.primary;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      alignment: Alignment.center,
      child: Icon(_iconFor(type), color: fg, size: size * 0.55),
    );
  }

  IconData _iconFor(FileType type) {
    switch (type) {
      case FileType.text:
        return Icons.description_outlined;
      case FileType.markdown:
        return Icons.article_outlined;
      case FileType.code:
        return Icons.code;
      case FileType.pdf:
        return Icons.picture_as_pdf_outlined;
      case FileType.docx:
        return Icons.description;
      case FileType.archive:
        return Icons.folder_zip_outlined;
      case FileType.image:
        return Icons.image_outlined;
      case FileType.spreadsheet:
        return Icons.table_chart_outlined;
      case FileType.unknown:
        return Icons.insert_drive_file_outlined;
    }
  }
}
