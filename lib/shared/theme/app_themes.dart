import 'package:flutter/material.dart';
import 'package:xorr/shared/extensions/functions.dart';
import 'package:xorr/shared/theme/app_colors.dart';
import 'package:xorr/shared/theme/app_fonts.dart';

abstract class AppThemes {
  static final lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: AppFonts.geist,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.lightSurface,
    colorScheme: ColorScheme(
      brightness: Brightness.light,

      // Primary
      primary: AppColors.primary,
      onPrimary: Functions.textColorFor(AppColors.primary),
      primaryContainer: AppColors.lightSurfaceContainerHigh,
      onPrimaryContainer: AppColors.lightText,

      // Secondary
      secondary: AppColors.secondary,
      onSecondary: Functions.textColorFor(AppColors.secondary),
      secondaryContainer: AppColors.lightSurfaceContainerHigh,
      onSecondaryContainer: AppColors.lightText,

      // Tertiary
      tertiary: AppColors.info,
      onTertiary: Functions.textColorFor(AppColors.info),
      tertiaryContainer: AppColors.lightSurfaceContainerHigh,
      onTertiaryContainer: AppColors.lightText,

      // Error
      error: AppColors.error,
      onError: Functions.textColorFor(AppColors.error),
      errorContainer: AppColors.lightSurfaceContainerHigh,
      onErrorContainer: AppColors.lightText,

      // Surface
      surface: AppColors.lightSurface,
      onSurface: AppColors.lightText,

      surfaceContainerLowest: AppColors.lightSurfaceContainerLowest,
      surfaceContainerLow: AppColors.lightSurfaceContainerLow,
      surfaceContainer: AppColors.lightSurfaceContainer,
      surfaceContainerHigh: AppColors.lightSurfaceContainerHigh,
      surfaceContainerHighest: AppColors.lightSurfaceContainerHighest,

      // Surface variant
      onSurfaceVariant: AppColors.lightTextSecondary,

      // Outline
      outline: AppColors.lightBorder,
      outlineVariant: AppColors.lightSurfaceVariant,

      // Inverse
      inverseSurface: AppColors.darkSurface,
      onInverseSurface: AppColors.darkText,
      inversePrimary: AppColors.secondary,

      // Scrim
      scrim: Colors.black,
    ),
  );

  static final darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: AppFonts.geist,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkSurface,

    colorScheme: ColorScheme(
      brightness: Brightness.dark,

      // Primary
      primary: AppColors.primary,
      onPrimary: Functions.textColorFor(AppColors.primary),
      primaryContainer: AppColors.darkSurfaceContainerHigh,
      onPrimaryContainer: AppColors.darkText,

      // Secondary
      secondary: AppColors.secondary,
      onSecondary: Functions.textColorFor(AppColors.secondary),
      secondaryContainer: AppColors.darkSurfaceContainerHigh,
      onSecondaryContainer: AppColors.darkText,

      // Tertiary
      tertiary: AppColors.info,
      onTertiary: Functions.textColorFor(AppColors.info),
      tertiaryContainer: AppColors.darkSurfaceContainerHigh,
      onTertiaryContainer: AppColors.darkText,

      // Error
      error: AppColors.error,
      onError: Functions.textColorFor(AppColors.error),
      errorContainer: AppColors.darkSurfaceContainerHigh,
      onErrorContainer: AppColors.darkText,

      // Surface
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkText,

      surfaceContainerLowest: AppColors.darkSurfaceContainerLowest,
      surfaceContainerLow: AppColors.darkSurfaceContainerLow,
      surfaceContainer: AppColors.darkSurfaceContainer,
      surfaceContainerHigh: AppColors.darkSurfaceContainerHigh,
      surfaceContainerHighest: AppColors.darkSurfaceContainerHighest,

      // Surface variant
      onSurfaceVariant: AppColors.darkTextSecondary,

      // Outline
      outline: AppColors.darkBorder,
      outlineVariant: AppColors.darkSurfaceVariant,

      // Inverse
      inverseSurface: AppColors.lightSurface,
      onInverseSurface: AppColors.lightText,
      inversePrimary: AppColors.secondary,

      // Scrim
      scrim: Colors.black,
    ),
  );
}
