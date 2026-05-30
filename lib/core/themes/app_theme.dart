import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'claude_colors.dart';

/// Files Claw theme — exact Claude aesthetic: zero elevation, 1px borders,
/// rounded-2xl corners, Inter typography.
class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);
    final textTheme = _buildTextTheme(base.textTheme, ClaudeColors.lightTextPrimary, ClaudeColors.lightTextSecondary);

    return base.copyWith(
      brightness: Brightness.light,
      scaffoldBackgroundColor: ClaudeColors.lightBackground,
      canvasColor: ClaudeColors.lightBackground,
      primaryColor: ClaudeColors.primary,
      dividerColor: ClaudeColors.lightDivider,
      colorScheme: const ColorScheme.light(
        primary: ClaudeColors.primary,
        onPrimary: Colors.white,
        secondary: ClaudeColors.primary,
        onSecondary: Colors.white,
        surface: ClaudeColors.lightSurface,
        onSurface: ClaudeColors.lightTextPrimary,
        error: ClaudeColors.error,
        onError: Colors.white,
        outline: ClaudeColors.lightBorder,
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: ClaudeColors.lightBackground,
        foregroundColor: ClaudeColors.lightTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
          systemNavigationBarColor: ClaudeColors.lightBackground,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 20,
          color: ClaudeColors.lightTextPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: ClaudeColors.lightSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: ClaudeColors.lightBorder, width: 1),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: ClaudeColors.lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        contentTextStyle: textTheme.bodyMedium,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: ClaudeColors.lightSurface,
        elevation: 0,
        modalElevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: ClaudeColors.lightSurface,
        elevation: 0,
        scrimColor: Color(0x66000000),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ClaudeColors.lightSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: _outlineBorder(ClaudeColors.lightBorder),
        enabledBorder: _outlineBorder(ClaudeColors.lightBorder),
        focusedBorder: _outlineBorder(ClaudeColors.primary, width: 1.5),
        errorBorder: _outlineBorder(ClaudeColors.error),
        focusedErrorBorder: _outlineBorder(ClaudeColors.error, width: 1.5),
        hintStyle: textTheme.bodyMedium?.copyWith(color: ClaudeColors.lightTextSecondary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ClaudeColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
          minimumSize: const Size(0, 48),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ClaudeColors.primary,
          side: const BorderSide(color: ClaudeColors.lightBorder, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          minimumSize: const Size(0, 48),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ClaudeColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
      ),
      iconTheme: const IconThemeData(color: ClaudeColors.lightTextPrimary, size: 22),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return Colors.white;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return ClaudeColors.primary;
          return ClaudeColors.lightBorder;
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      dividerTheme: const DividerThemeData(
        color: ClaudeColors.lightDivider,
        thickness: 1,
        space: 1,
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: ClaudeColors.lightTextPrimary,
        textColor: ClaudeColors.lightTextPrimary,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: ClaudeColors.lightTextPrimary,
        contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: ClaudeColors.primary,
      ),
      splashFactory: InkRipple.splashFactory,
      splashColor: ClaudeColors.primary.withValues(alpha: 0.10),
      highlightColor: ClaudeColors.primary.withValues(alpha: 0.06),
    );
  }

  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);
    final textTheme = _buildTextTheme(base.textTheme, ClaudeColors.darkTextPrimary, ClaudeColors.darkTextSecondary);

    return base.copyWith(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: ClaudeColors.darkBackground,
      canvasColor: ClaudeColors.darkBackground,
      primaryColor: ClaudeColors.primary,
      dividerColor: ClaudeColors.darkDivider,
      colorScheme: const ColorScheme.dark(
        primary: ClaudeColors.primary,
        onPrimary: Colors.white,
        secondary: ClaudeColors.primary,
        onSecondary: Colors.white,
        surface: ClaudeColors.darkSurface,
        onSurface: ClaudeColors.darkTextPrimary,
        error: ClaudeColors.error,
        onError: Colors.white,
        outline: ClaudeColors.darkBorder,
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: ClaudeColors.darkBackground,
        foregroundColor: ClaudeColors.darkTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
          systemNavigationBarColor: ClaudeColors.darkBackground,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 20,
          color: ClaudeColors.darkTextPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: ClaudeColors.darkSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: ClaudeColors.darkBorder, width: 1),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: ClaudeColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: ClaudeColors.darkSurface,
        elevation: 0,
        modalElevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: ClaudeColors.darkSurface,
        elevation: 0,
        scrimColor: Color(0x99000000),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ClaudeColors.darkSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: _outlineBorder(ClaudeColors.darkBorder),
        enabledBorder: _outlineBorder(ClaudeColors.darkBorder),
        focusedBorder: _outlineBorder(ClaudeColors.primary, width: 1.5),
        errorBorder: _outlineBorder(ClaudeColors.error),
        focusedErrorBorder: _outlineBorder(ClaudeColors.error, width: 1.5),
        hintStyle: textTheme.bodyMedium?.copyWith(color: ClaudeColors.darkTextSecondary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ClaudeColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          minimumSize: const Size(0, 48),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ClaudeColors.primary,
          side: const BorderSide(color: ClaudeColors.darkBorder, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          minimumSize: const Size(0, 48),
        ),
      ),
      iconTheme: const IconThemeData(color: ClaudeColors.darkTextPrimary, size: 22),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all(Colors.white),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return ClaudeColors.primary;
          return ClaudeColors.darkBorder;
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      dividerTheme: const DividerThemeData(
        color: ClaudeColors.darkDivider,
        thickness: 1,
        space: 1,
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: ClaudeColors.darkTextPrimary,
        textColor: ClaudeColors.darkTextPrimary,
      ),
      splashFactory: InkRipple.splashFactory,
      splashColor: ClaudeColors.primary.withValues(alpha: 0.15),
      highlightColor: ClaudeColors.primary.withValues(alpha: 0.08),
    );
  }

  static OutlineInputBorder _outlineBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  static TextTheme _buildTextTheme(TextTheme base, Color primary, Color secondary) {
    final inter = GoogleFonts.interTextTheme(base);
    return inter.copyWith(
      displayLarge: inter.displayLarge?.copyWith(color: primary, fontWeight: FontWeight.w600, letterSpacing: -0.5),
      headlineLarge: inter.headlineLarge?.copyWith(color: primary, fontWeight: FontWeight.w600, letterSpacing: -0.5),
      headlineMedium: inter.headlineMedium?.copyWith(color: primary, fontWeight: FontWeight.w600, letterSpacing: -0.3),
      headlineSmall: inter.headlineSmall?.copyWith(color: primary, fontWeight: FontWeight.w600, fontSize: 20),
      titleLarge: inter.titleLarge?.copyWith(color: primary, fontWeight: FontWeight.w600, fontSize: 20),
      titleMedium: inter.titleMedium?.copyWith(color: primary, fontWeight: FontWeight.w600, fontSize: 18),
      titleSmall: inter.titleSmall?.copyWith(color: primary, fontWeight: FontWeight.w500, fontSize: 16),
      bodyLarge: inter.bodyLarge?.copyWith(color: primary, fontSize: 16, height: 1.5),
      bodyMedium: inter.bodyMedium?.copyWith(color: primary, fontSize: 14, height: 1.5),
      bodySmall: inter.bodySmall?.copyWith(color: secondary, fontSize: 13),
      labelLarge: inter.labelLarge?.copyWith(color: primary, fontWeight: FontWeight.w500, fontSize: 15, letterSpacing: 0.3),
      labelMedium: inter.labelMedium?.copyWith(color: secondary, fontSize: 13),
      labelSmall: inter.labelSmall?.copyWith(color: secondary, fontSize: 11, letterSpacing: 0.5),
    );
  }

  /// Returns Roboto Mono text style for code/editor surfaces.
  static TextStyle monoStyle({double fontSize = 14, Color? color}) {
    return GoogleFonts.robotoMono(
      fontSize: fontSize,
      height: 1.6,
      color: color,
    );
  }
}
