import 'package:flutter/services.dart';

enum HapticType { none, light, medium, selection, success, warning, error }

class Haptics {
  const Haptics._();

  static Future<void> light() => HapticFeedback.lightImpact();

  static Future<void> medium() => HapticFeedback.mediumImpact();

  static Future<void> selection() => HapticFeedback.selectionClick();

  static Future<void> success() => HapticFeedback.mediumImpact();

  static Future<void> warning() => HapticFeedback.heavyImpact();

  static Future<void> error() => HapticFeedback.vibrate();

  static Future<void> play(HapticType type) {
    return switch (type) {
      HapticType.none => Future<void>.value(),
      HapticType.light => light(),
      HapticType.medium => medium(),
      HapticType.selection => selection(),
      HapticType.success => success(),
      HapticType.warning => warning(),
      HapticType.error => error(),
    };
  }
}
