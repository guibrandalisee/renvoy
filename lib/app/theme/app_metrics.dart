import 'package:flutter/material.dart';

/// Semantic layout and geometry tokens shared by product UI.
///
/// Material and Cupertino themes adapt these values, but do not own them.
@immutable
class AppMetrics extends ThemeExtension<AppMetrics> {
  const AppMetrics({
    this.screenGutter = 20,
    this.spaceRelated = 8,
    this.spaceContent = 12,
    this.spaceGroup = 20,
    this.spaceSection = 28,
    this.radiusControl = 14,
    this.radiusContainer = 22,
    this.radiusHero = 28,
  });

  final double screenGutter;
  final double spaceRelated;
  final double spaceContent;
  final double spaceGroup;
  final double spaceSection;
  final double radiusControl;
  final double radiusContainer;
  final double radiusHero;

  @override
  AppMetrics copyWith({
    double? screenGutter,
    double? spaceRelated,
    double? spaceContent,
    double? spaceGroup,
    double? spaceSection,
    double? radiusControl,
    double? radiusContainer,
    double? radiusHero,
  }) {
    return AppMetrics(
      screenGutter: screenGutter ?? this.screenGutter,
      spaceRelated: spaceRelated ?? this.spaceRelated,
      spaceContent: spaceContent ?? this.spaceContent,
      spaceGroup: spaceGroup ?? this.spaceGroup,
      spaceSection: spaceSection ?? this.spaceSection,
      radiusControl: radiusControl ?? this.radiusControl,
      radiusContainer: radiusContainer ?? this.radiusContainer,
      radiusHero: radiusHero ?? this.radiusHero,
    );
  }

  @override
  AppMetrics lerp(covariant AppMetrics? other, double t) {
    if (other == null) return this;
    return AppMetrics(
      screenGutter: lerpDouble(screenGutter, other.screenGutter, t),
      spaceRelated: lerpDouble(spaceRelated, other.spaceRelated, t),
      spaceContent: lerpDouble(spaceContent, other.spaceContent, t),
      spaceGroup: lerpDouble(spaceGroup, other.spaceGroup, t),
      spaceSection: lerpDouble(spaceSection, other.spaceSection, t),
      radiusControl: lerpDouble(radiusControl, other.radiusControl, t),
      radiusContainer: lerpDouble(radiusContainer, other.radiusContainer, t),
      radiusHero: lerpDouble(radiusHero, other.radiusHero, t),
    );
  }

  static double lerpDouble(double a, double b, double t) => a + (b - a) * t;
}

extension AppMetricsBuildContext on BuildContext {
  AppMetrics get metrics => Theme.of(this).extension<AppMetrics>()!;
}
