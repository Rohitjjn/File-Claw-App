import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../themes/claude_colors.dart';

/// Subtle shimmer placeholder for file lists. Calmer than default shimmer
/// to match the Claude aesthetic.
class ShimmerLoader extends StatelessWidget {
  final int itemCount;
  final double itemHeight;
  final EdgeInsetsGeometry padding;

  const ShimmerLoader({
    super.key,
    this.itemCount = 4,
    this.itemHeight = 72,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? ClaudeColors.darkSurface : ClaudeColors.lightSurfaceMuted;
    final highlight = isDark
        ? ClaudeColors.darkBorder
        : Colors.white.withValues(alpha: 0.6);
    return Padding(
      padding: padding,
      child: Shimmer.fromColors(
        baseColor: base,
        highlightColor: highlight,
        period: const Duration(milliseconds: 1400),
        child: Column(
          children: List.generate(itemCount, (i) {
            return Container(
              height: itemHeight,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            );
          }),
        ),
      ),
    );
  }
}
