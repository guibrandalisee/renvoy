import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:renvoy/l10n/app_localizations.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_metrics.dart';
import '../../app/theme/app_platform.dart';
import '../../core/formatters.dart';
import '../../core/widgets/pressable.dart';
import '../../core/widgets/status_bar_fade.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  static final _updatedAt = DateTime.utc(2026, 7, 16);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    final metrics = context.metrics;
    final sections = [
      (l10n.privacyLocalTitle, l10n.privacyLocalBody),
      (l10n.privacyNetworkTitle, l10n.privacyNetworkBody),
      (l10n.privacyNotificationsTitle, l10n.privacyNotificationsBody),
      (l10n.privacyBackupTitle, l10n.privacyBackupBody),
      (l10n.privacyDeletionTitle, l10n.privacyDeletionBody),
    ];

    return Scaffold(
      backgroundColor: colors.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    metrics.screenGutter,
                    MediaQuery.viewPaddingOf(context).top + 12,
                    metrics.screenGutter,
                    0,
                  ),
                  child: Row(
                    children: [
                      Semantics(
                        button: true,
                        label: MaterialLocalizations.of(
                          context,
                        ).backButtonTooltip,
                        excludeSemantics: true,
                        child: Pressable(
                          onPressed: context.pop,
                          borderRadius: BorderRadius.circular(999),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: colors.surfaceElevated,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isCupertinoPlatform(context)
                                  ? Icons.arrow_back_ios_new_rounded
                                  : Icons.arrow_back_rounded,
                              size: 20,
                              color: colors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          l10n.privacyTitle,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(color: colors.textPrimary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  metrics.screenGutter,
                  28,
                  metrics.screenGutter,
                  MediaQuery.paddingOf(context).bottom + 40,
                ),
                sliver: SliverList.list(
                  children: [
                    Text(
                      l10n.privacyIntro,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: colors.textPrimary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 28),
                    for (final section in sections) ...[
                      Text(
                        section.$1,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: colors.textPrimary),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        section.$2,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colors.textSecondary,
                          height: 1.55,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    Text(
                      l10n.privacyUpdated(
                        Dates.short(_updatedAt, l10n.localeName),
                      ),
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: colors.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const StatusBarFade(),
        ],
      ),
    );
  }
}
