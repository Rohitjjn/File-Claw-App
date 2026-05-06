import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/themes/claude_colors.dart';

/// Markdown preview using flutter_markdown with Claude-styled typography.
class MarkdownPreview extends StatelessWidget {
  final String content;
  final double fontScale;

  const MarkdownPreview({
    super.key,
    required this.content,
    this.fontScale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg = isDark
        ? ClaudeColors.darkTextPrimary
        : ClaudeColors.lightTextPrimary;
    final secondary = isDark
        ? ClaudeColors.darkTextSecondary
        : ClaudeColors.lightTextSecondary;
    final codeBg = isDark
        ? ClaudeColors.darkSurfaceMuted
        : ClaudeColors.lightSurfaceMuted;

    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 5.0,
      child: Markdown(
        data: content,
        selectable: true,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      styleSheet: MarkdownStyleSheet(
        p: GoogleFonts.inter(fontSize: 16 * fontScale, height: 1.6, color: fg),
        h1: GoogleFonts.inter(
            fontSize: 24 * fontScale, fontWeight: FontWeight.w700, color: fg),
        h2: GoogleFonts.inter(
            fontSize: 20 * fontScale, fontWeight: FontWeight.w700, color: fg),
        h3: GoogleFonts.inter(
            fontSize: 18 * fontScale, fontWeight: FontWeight.w600, color: fg),
        h4: GoogleFonts.inter(
            fontSize: 16 * fontScale, fontWeight: FontWeight.w600, color: fg),
        em: GoogleFonts.inter(fontStyle: FontStyle.italic, color: fg),
        strong: GoogleFonts.inter(fontWeight: FontWeight.w700, color: fg),
        blockquote: GoogleFonts.inter(color: secondary, fontStyle: FontStyle.italic),
        blockquoteDecoration: const BoxDecoration(
          border: Border(
            left: BorderSide(color: ClaudeColors.primary, width: 3),
          ),
        ),
        blockquotePadding: const EdgeInsets.fromLTRB(12, 4, 4, 4),
        code: GoogleFonts.robotoMono(
          fontSize: 13 * fontScale,
          color: ClaudeColors.primary,
          backgroundColor: codeBg,
        ),
        codeblockDecoration: BoxDecoration(
          color: codeBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? ClaudeColors.darkBorder : ClaudeColors.lightBorder,
            width: 1,
          ),
        ),
        codeblockPadding: const EdgeInsets.all(14),
        listBullet: GoogleFonts.inter(color: fg, fontSize: 16 * fontScale),
        a: GoogleFonts.inter(
          color: ClaudeColors.primary,
          decoration: TextDecoration.underline,
        ),
        horizontalRuleDecoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isDark ? ClaudeColors.darkDivider : ClaudeColors.lightDivider,
              width: 1,
            ),
          ),
        ),
        tableHead: GoogleFonts.inter(fontWeight: FontWeight.w600, color: fg),
        tableBody: GoogleFonts.inter(color: fg),
        tableBorder: TableBorder.all(
          color: isDark ? ClaudeColors.darkBorder : ClaudeColors.lightBorder,
          width: 1,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ));
  }
}
