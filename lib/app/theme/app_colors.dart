import 'package:flutter/material.dart';

@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.background,
    required this.surface,
    required this.surfaceElevated,
    required this.border,
    required this.borderStrong,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.accent,
    required this.onAccent,
    required this.accentSoft,
    required this.brandWarm,
    required this.brandWarmSoft,
    required this.heroSurface,
    required this.onHero,
    required this.onHeroMuted,
    required this.success,
    required this.warning,
    required this.danger,
    required this.successSoft,
    required this.warningSoft,
    required this.dangerSoft,
  });

  // Dark theme — the app icon's ink, mineral teal, and restrained copper.
  const AppColors.dark()
    : background = const Color(0xFF0E1312),
      surface = const Color(0xFF171D1B),
      surfaceElevated = const Color(0xFF202824),
      border = const Color(0xFF29332F),
      borderStrong = const Color(0xFF3B4842),
      textPrimary = const Color(0xFFF0F4F2),
      textSecondary = const Color(0xFFADB8B3),
      textMuted = const Color(0xFF87938D),
      accent = const Color(0xFF64CFB9),
      onAccent = const Color(0xFF08241F),
      accentSoft = const Color(0x2E64CFB9),
      brandWarm = const Color(0xFFF0A06B),
      brandWarmSoft = const Color(0x2EF0A06B),
      heroSurface = const Color(0xFF1A2521),
      onHero = const Color(0xFFF4F8F6),
      onHeroMuted = const Color(0xFFAAB8B2),
      success = const Color(0xFF3DD68C),
      warning = const Color(0xFFF6B93B),
      danger = const Color(0xFFED5C5C),
      successSoft = const Color(0x263DD68C),
      warningSoft = const Color(0x26F6B93B),
      dangerSoft = const Color(0x26ED5C5C);

  // Light theme — warm paper surfaces balance the financial precision.
  const AppColors.light()
    : background = const Color(0xFFF6F3EE),
      surface = const Color(0xFFFFFCF8),
      surfaceElevated = const Color(0xFFEDE9E2),
      border = const Color(0xFFE2DDD4),
      borderStrong = const Color(0xFFCEC8BE),
      textPrimary = const Color(0xFF17201D),
      textSecondary = const Color(0xFF56625D),
      textMuted = const Color(0xFF66706B),
      accent = const Color(0xFF0B786D),
      onAccent = const Color(0xFFFFFFFF),
      accentSoft = const Color(0x1F0B786D),
      brandWarm = const Color(0xFFD67843),
      brandWarmSoft = const Color(0x24D67843),
      heroSurface = const Color(0xFF17231F),
      onHero = const Color(0xFFF8FAF8),
      onHeroMuted = const Color(0xFFB4C0BB),
      success = const Color(0xFF0E9E6E),
      warning = const Color(0xFFC77A12),
      danger = const Color(0xFFDC4C4C),
      successSoft = const Color(0x1A0E9E6E),
      warningSoft = const Color(0x1AC77A12),
      dangerSoft = const Color(0x1ADC4C4C);

  final Color background;
  final Color surface;
  final Color surfaceElevated;
  final Color border;
  final Color borderStrong;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color accent;
  final Color onAccent;
  final Color accentSoft;
  final Color brandWarm;
  final Color brandWarmSoft;
  final Color heroSurface;
  final Color onHero;
  final Color onHeroMuted;
  final Color success;
  final Color warning;
  final Color danger;
  final Color successSoft;
  final Color warningSoft;
  final Color dangerSoft;

  @override
  AppColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceElevated,
    Color? border,
    Color? borderStrong,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? accent,
    Color? onAccent,
    Color? accentSoft,
    Color? brandWarm,
    Color? brandWarmSoft,
    Color? heroSurface,
    Color? onHero,
    Color? onHeroMuted,
    Color? success,
    Color? warning,
    Color? danger,
    Color? successSoft,
    Color? warningSoft,
    Color? dangerSoft,
  }) {
    return AppColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      border: border ?? this.border,
      borderStrong: borderStrong ?? this.borderStrong,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
      accentSoft: accentSoft ?? this.accentSoft,
      brandWarm: brandWarm ?? this.brandWarm,
      brandWarmSoft: brandWarmSoft ?? this.brandWarmSoft,
      heroSurface: heroSurface ?? this.heroSurface,
      onHero: onHero ?? this.onHero,
      onHeroMuted: onHeroMuted ?? this.onHeroMuted,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      successSoft: successSoft ?? this.successSoft,
      warningSoft: warningSoft ?? this.warningSoft,
      dangerSoft: dangerSoft ?? this.dangerSoft,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) {
      return this;
    }

    return AppColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      brandWarm: Color.lerp(brandWarm, other.brandWarm, t)!,
      brandWarmSoft: Color.lerp(brandWarmSoft, other.brandWarmSoft, t)!,
      heroSurface: Color.lerp(heroSurface, other.heroSurface, t)!,
      onHero: Color.lerp(onHero, other.onHero, t)!,
      onHeroMuted: Color.lerp(onHeroMuted, other.onHeroMuted, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      successSoft: Color.lerp(successSoft, other.successSoft, t)!,
      warningSoft: Color.lerp(warningSoft, other.warningSoft, t)!,
      dangerSoft: Color.lerp(dangerSoft, other.dangerSoft, t)!,
    );
  }
}

extension AppColorsBuildContext on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}
