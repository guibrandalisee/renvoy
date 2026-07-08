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

  const AppColors.dark()
    : background = const Color(0xFF0C0D10),
      surface = const Color(0xFF15171C),
      surfaceElevated = const Color(0xFF1C1F26),
      border = const Color(0xFF262A33),
      borderStrong = const Color(0xFF343A46),
      textPrimary = const Color(0xFFF2F3F5),
      textSecondary = const Color(0xFF9BA1AC),
      textMuted = const Color(0xFF5E6673),
      accent = const Color(0xFF7C5CFC),
      onAccent = const Color(0xFFFFFFFF),
      accentSoft = const Color(0x247C5CFC),
      success = const Color(0xFF34D399),
      warning = const Color(0xFFFBBF24),
      danger = const Color(0xFFF87171),
      successSoft = const Color(0x2434D399),
      warningSoft = const Color(0x24FBBF24),
      dangerSoft = const Color(0x24F87171);

  const AppColors.light()
    : background = const Color(0xFFF6F6F8),
      surface = const Color(0xFFFFFFFF),
      surfaceElevated = const Color(0xFFFFFFFF),
      border = const Color(0xFFE7E8EC),
      borderStrong = const Color(0xFFD5D7DE),
      textPrimary = const Color(0xFF17181C),
      textSecondary = const Color(0xFF5C6270),
      textMuted = const Color(0xFF9AA0AB),
      accent = const Color(0xFF6A4CF5),
      onAccent = const Color(0xFFFFFFFF),
      accentSoft = const Color(0x1A6A4CF5),
      success = const Color(0xFF10B981),
      warning = const Color(0xFFD97706),
      danger = const Color(0xFFEF4444),
      successSoft = const Color(0x1A10B981),
      warningSoft = const Color(0x1AD97706),
      dangerSoft = const Color(0x1AEF4444);

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
