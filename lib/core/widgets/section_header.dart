import 'package:flutter/material.dart';

import '../themes/claude_colors.dart';

/// Small uppercase section title used in the sidebar and settings.
class SectionHeader extends StatelessWidget {
  final String label;
  final EdgeInsetsGeometry padding;

  const SectionHeader({
    super.key,
    required this.label,
    this.padding = const EdgeInsets.fromLTRB(16, 16, 16, 8),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: padding,
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
          color: isDark
              ? ClaudeColors.darkTextSecondary
              : ClaudeColors.lightTextSecondary,
        ),
      ),
    );
  }
}
