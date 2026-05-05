import 'package:flutter/material.dart';

import '../themes/claude_colors.dart';

/// AppBar that blends with the scaffold background and only shows a 1px
/// bottom divider when the scrollable content has scrolled.
class ClaudeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? leading;
  final Widget? title;
  final List<Widget>? actions;
  final bool showBottomDivider;
  final double height;
  final bool centerTitle;

  const ClaudeAppBar({
    super.key,
    this.leading,
    this.title,
    this.actions,
    this.showBottomDivider = false,
    this.height = kToolbarHeight,
    this.centerTitle = false,
  });

  @override
  Size get preferredSize => Size.fromHeight(height + (showBottomDivider ? 1 : 0));

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final divider = isDark ? ClaudeColors.darkDivider : ClaudeColors.lightDivider;
    final bg = isDark ? ClaudeColors.darkBackground : ClaudeColors.lightBackground;
    return Container(
      color: bg,
      child: Column(
        children: [
          SizedBox(
            height: height,
            child: AppBar(
              backgroundColor: bg,
              foregroundColor:
                  isDark ? ClaudeColors.darkTextPrimary : ClaudeColors.lightTextPrimary,
              elevation: 0,
              scrolledUnderElevation: 0,
              surfaceTintColor: Colors.transparent,
              leading: leading,
              title: title,
              actions: actions,
              centerTitle: centerTitle,
            ),
          ),
          if (showBottomDivider)
            Container(height: 1, color: divider),
        ],
      ),
    );
  }
}
