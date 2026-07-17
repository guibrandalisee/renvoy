import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:simple_icons/simple_icons.dart';

/// Displays catalog brand marks while keeping legacy monograms intact.
class SubscriptionAvatar extends StatelessWidget {
  const SubscriptionAvatar({
    required this.name,
    required this.iconName,
    required this.color,
    required this.size,
    super.key,
  });

  final String name;
  final String? iconName;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final assetSlug = subscriptionLogoAssetSlug(iconName);
    if (assetSlug != null) return _assetAvatar(context, assetSlug);

    final icon = resolveSubscriptionIcon(iconName);
    if (icon != null) return _iconAvatar(context, icon);

    return _letterAvatar(context);
  }

  Widget _assetAvatar(BuildContext context, String assetSlug) {
    final palette = _palette(context);
    final isWide = _wideLogoSlugs.contains(assetSlug);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: palette.background,
        shape: BoxShape.circle,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: size * (isWide ? 0.10 : 0.22),
        vertical: size * (isWide ? 0.10 : 0.22),
      ),
      alignment: Alignment.center,
      child: ExcludeSemantics(
        child: SvgPicture.asset(
          'assets/subscription_logos/$assetSlug.svg',
          fit: BoxFit.contain,
          colorFilter: ColorFilter.mode(palette.foreground, BlendMode.srcIn),
          placeholderBuilder: (_) => const SizedBox.shrink(),
          errorBuilder: (_, _, _) => FittedBox(
            child: Text(
              name.trim().isEmpty
                  ? '?'
                  : name.trim().characters.first.toUpperCase(),
              style: TextStyle(
                color: palette.foreground,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _iconAvatar(BuildContext context, IconData icon) {
    final palette = _palette(context);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: palette.background,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: ExcludeSemantics(
        child: Icon(icon, color: palette.foreground, size: size * 0.5),
      ),
    );
  }

  _AvatarPalette _palette(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final tonalBackground = Color.alphaBlend(
      color.withValues(alpha: 0.18),
      scheme.surface,
    );
    final foreground = _foregroundWithContrast(
      color,
      background: tonalBackground,
      contrastTarget: scheme.onSurface,
    );
    return _AvatarPalette(foreground, tonalBackground);
  }

  Widget _letterAvatar(BuildContext context) {
    final initial = name.trim().isEmpty ? '?' : name.trim().characters.first;
    final palette = _palette(context);
    final style = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: palette.foreground,
      fontWeight: FontWeight.w600,
      fontSize: size >= 64 ? size * 0.389 : null,
    );
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: palette.background,
      ),
      alignment: Alignment.center,
      child: Text(initial.toUpperCase(), style: style),
    );
  }
}

class _AvatarPalette {
  const _AvatarPalette(this.foreground, this.background);

  final Color foreground;
  final Color background;
}

double _contrastRatio(Color first, Color second) {
  final firstLuminance = first.computeLuminance();
  final secondLuminance = second.computeLuminance();
  final lighter = firstLuminance > secondLuminance
      ? firstLuminance
      : secondLuminance;
  final darker = firstLuminance > secondLuminance
      ? secondLuminance
      : firstLuminance;
  return (lighter + 0.05) / (darker + 0.05);
}

Color _foregroundWithContrast(
  Color source, {
  required Color background,
  required Color contrastTarget,
}) {
  if (_contrastRatio(source, background) >= 3) return source;

  // Preserve as much of the brand color as possible. Moving only the mark
  // toward the theme's content color keeps the soft tonal avatar treatment.
  var lowerBound = 0.0;
  var upperBound = 1.0;
  for (var iteration = 0; iteration < 10; iteration++) {
    final amount = (lowerBound + upperBound) / 2;
    final candidate = Color.lerp(source, contrastTarget, amount)!;
    if (_contrastRatio(candidate, background) >= 3) {
      upperBound = amount;
    } else {
      lowerBound = amount;
    }
  }
  return Color.lerp(source, contrastTarget, upperBound)!;
}

/// Resolves brand marks provided by the bundled Simple Icons font.
IconData? resolveSubscriptionIcon(String? iconName) {
  final value = iconName?.trim().toLowerCase() ?? '';
  if (value.startsWith('si:')) {
    return SimpleIcons.values[value.substring(3)];
  }
  return null;
}

String? subscriptionIconAssetPath(String? iconName) {
  final slug = subscriptionLogoAssetSlug(iconName);
  return slug == null ? null : 'assets/subscription_logos/$slug.svg';
}

String? subscriptionLogoAssetSlug(String? iconName) {
  final value = iconName?.trim().toLowerCase() ?? '';
  if (!value.startsWith('asset:')) return null;
  final slug = value.substring(6);
  if (!subscriptionBrandAssetSlugs.contains(slug)) return null;
  return slug;
}

const _wideLogoSlugs = <String>{
  'amazon-music',
  'amazon-prime',
  'calm',
  'canva',
  'disney-plus',
  'globoplay',
  'hulu',
  'peacock',
};

const subscriptionBrandAssetSlugs = <String>{
  'adobe-creative-cloud',
  'amazon-music',
  'amazon-prime',
  'babbel',
  'bumble',
  'calm',
  'canva',
  'chatgpt-plus',
  'disney-plus',
  'globoplay',
  'google-one',
  'grindr',
  'hinge',
  'hulu',
  'kindle-unlimited',
  'linkedin-premium',
  'masterclass',
  'meli-plus',
  'microsoft-365',
  'myfitnesspal',
  'nintendo-switch-online',
  'onedrive',
  'peacock',
  'prime-video',
  'slack',
  'xbox-game-pass',
};
