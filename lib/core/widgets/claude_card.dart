import 'package:flutter/material.dart';

import '../themes/claude_colors.dart';

/// A zero-elevation, 1px-bordered, rounded-2xl card that matches the
/// Claude aesthetic. Replaces Material's default Card wherever subtle
/// separation is needed without shadows.
class ClaudeCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Color? backgroundColor;
  final BorderRadiusGeometry? borderRadius;
  final Border? border;

  const ClaudeCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.onTap,
    this.onLongPress,
    this.backgroundColor,
    this.borderRadius,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = borderRadius ?? BorderRadius.circular(16);
    final defaultBorder = Border.all(
      color: isDark ? ClaudeColors.darkBorder : ClaudeColors.lightBorder,
      width: 1,
    );

    final container = Container(
      decoration: BoxDecoration(
        color: backgroundColor ??
            (isDark ? ClaudeColors.darkSurface : ClaudeColors.lightSurface),
        borderRadius: radius,
        border: border ?? defaultBorder,
      ),
      child: Padding(padding: padding, child: child),
    );

    if (onTap == null && onLongPress == null) {
      return Padding(
        padding: margin ?? EdgeInsets.zero,
        child: container,
      );
    }

    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        borderRadius: radius is BorderRadius ? radius : null,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: radius is BorderRadius ? radius : BorderRadius.circular(16),
          child: container,
        ),
      ),
    );
  }
}
