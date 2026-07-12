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
    required this.success,
    required this.warning,
    required this.danger,
    required this.successSoft,
    required this.warningSoft,
    required this.dangerSoft,
  });

  // Dark theme — cool charcoal surfaces with a bright emerald-teal accent.
  // Text colours are tuned to clear WCAG AA (>=4.5:1) on `surface`.
  const AppColors.dark()
    : background = const Color(0xFF0A0F0E),
      surface = const Color(0xFF141A18),
      surfaceElevated = const Color(0xFF1C2320),
      border = const Color(0xFF27302C),
      borderStrong = const Color(0xFF37423D),
      textPrimary = const Color(0xFFECF2EF),
      textSecondary = const Color(0xFF9FAAA5),
      textMuted = const Color(0xFF7F8B85),
      // Bright mint reads best with near-black text on top (onAccent).
      accent = const Color(0xFF23CCAF),
      onAccent = const Color(0xFF04231D),
      accentSoft = const Color(0x2623CCAF),
      success = const Color(0xFF3DD68C),
      warning = const Color(0xFFF6B93B),
      danger = const Color(0xFFED5C5C),
      successSoft = const Color(0x263DD68C),
      warningSoft = const Color(0x26F6B93B),
      dangerSoft = const Color(0x26ED5C5C);

  // Light theme — soft off-white surfaces with a deep teal accent that keeps
  // white text legible (AA) on primary buttons.
  const AppColors.light()
    : background = const Color(0xFFF3F6F5),
      surface = const Color(0xFFFFFFFF),
      surfaceElevated = const Color(0xFFFFFFFF),
      border = const Color(0xFFE4EAE7),
      borderStrong = const Color(0xFFD0D9D5),
      textPrimary = const Color(0xFF14201C),
      textSecondary = const Color(0xFF55625E),
      textMuted = const Color(0xFF6C7873),
      accent = const Color(0xFF0C8175),
      onAccent = const Color(0xFFFFFFFF),
      accentSoft = const Color(0x1A0C8175),
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
