import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:simple_icons/simple_icons.dart';

/// Displays modern catalog icons while keeping legacy letter avatars intact.
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
    final value = iconName?.trim() ?? '';
    if (value.startsWith('si:')) {
      final icon = SimpleIcons.values[value.substring(3).toLowerCase()];
      if (icon != null) return _iconAvatar(icon);
    }
    if (value.startsWith('fav:')) {
      final domain = value.substring(4).trim();
      if (domain.isNotEmpty) return _faviconAvatar(domain);
    }
    return _letterAvatar(context);
  }

  Widget _iconAvatar(IconData icon) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: color, size: size * 0.5),
    );
  }

  Widget _faviconAvatar(String domain) {
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: 'https://www.google.com/s2/favicons?domain=$domain&sz=128',
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholder: (context, _) => _letterAvatar(context),
        errorWidget: (context, _, _) => _letterAvatar(context),
      ),
    );
  }

  Widget _letterAvatar(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: color,
      fontWeight: FontWeight.w600,
      fontSize: size >= 64 ? size * 0.389 : null,
    );
    return _letterAvatarWithoutContext(style: style);
  }

  Widget _letterAvatarWithoutContext({TextStyle? style}) {
    final initial = name.trim().isEmpty ? '?' : name.trim().characters.first;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.18),
      ),
      alignment: Alignment.center,
      child: Text(initial.toUpperCase(), style: style?.copyWith(color: color)),
    );
  }
}
