import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/themes/claude_colors.dart';
import '../../../../core/utils/size_formatter.dart';

/// Fallback preview for unknown / binary file types.
///
/// Shows a hex dump of the first ~4 KB so the user can still get a sense of
/// what they're looking at without having to leave the app.
class HexPreview extends StatelessWidget {
  final List<int> bytes;
  final String fileName;
  final int maxBytes;

  const HexPreview({
    super.key,
    required this.bytes,
    required this.fileName,
    this.maxBytes = 4096,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondary = isDark
        ? ClaudeColors.darkTextSecondary
        : ClaudeColors.lightTextSecondary;
    final fg = isDark
        ? ClaudeColors.darkTextPrimary
        : ClaudeColors.lightTextPrimary;

    final visibleBytes = bytes.take(maxBytes).toList(growable: false);
    final lines = <_HexLine>[];
    for (var i = 0; i < visibleBytes.length; i += 16) {
      final end = (i + 16).clamp(0, visibleBytes.length);
      final slice = visibleBytes.sublist(i, end);
      final hex = slice
          .map((b) => b.toRadixString(16).padLeft(2, '0'))
          .join(' ')
          .padRight(16 * 3 - 1, ' ');
      final ascii = slice
          .map((b) => (b >= 32 && b < 127) ? String.fromCharCode(b) : '.')
          .join();
      lines.add(_HexLine(offset: i, hex: hex, ascii: ascii));
    }

    final headerStyle = GoogleFonts.robotoMono(
      fontSize: 12,
      color: secondary,
    );
    final lineStyle = GoogleFonts.robotoMono(
      fontSize: 12,
      color: fg,
      height: 1.6,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color:
                isDark ? ClaudeColors.darkSurfaceMuted : ClaudeColors.lightSurfaceMuted,
            border: Border(
              bottom: BorderSide(
                color: isDark
                    ? ClaudeColors.darkBorder
                    : ClaudeColors.lightBorder,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.memory, size: 18, color: ClaudeColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Binary preview · ${SizeFormatter.formatBytes(bytes.length)} total · showing first ${SizeFormatter.formatBytes(visibleBytes.length)}',
                  style: headerStyle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: lines.length,
            itemBuilder: (context, i) {
              final l = lines[i];
              return SelectableText(
                '${l.offset.toRadixString(16).padLeft(8, '0')}  ${l.hex}  ${l.ascii}',
                style: lineStyle,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _HexLine {
  final int offset;
  final String hex;
  final String ascii;
  _HexLine({required this.offset, required this.hex, required this.ascii});
}
