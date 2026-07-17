import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:renvoy/app/theme/app_theme.dart';
import 'package:renvoy/core/widgets/subscription_avatar.dart';
import 'package:simple_icons/simple_icons.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final loader = FontLoader('packages/simple_icons/SimpleIcons')
      ..addFont(rootBundle.load('packages/simple_icons/fonts/SimpleIcons.ttf'));
    await loader.load();
  });

  test('resolves supported brand icons', () {
    expect(resolveSubscriptionIcon('si:netflix'), SimpleIcons.netflix);
  });

  test('resolves bundled brand assets', () {
    expect(
      subscriptionIconAssetPath('asset:prime-video'),
      'assets/subscription_logos/prime-video.svg',
    );
  });

  test('unknown icons fall back to the subscription monogram', () {
    expect(resolveSubscriptionIcon(null), isNull);
    expect(resolveSubscriptionIcon('si:not-a-real-brand'), isNull);
    expect(subscriptionIconAssetPath('asset:not-a-real-brand'), isNull);
  });

  test('every declared brand asset is bundled', () async {
    for (final slug in subscriptionBrandAssetSlugs) {
      final data = await rootBundle.load('assets/subscription_logos/$slug.svg');
      expect(data.lengthInBytes, greaterThan(0), reason: slug);
    }
  });

  testWidgets('every declared brand asset renders in an avatar', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Wrap(
          children: [
            for (final slug in subscriptionBrandAssetSlugs)
              SubscriptionAvatar(
                name: slug,
                iconName: 'asset:$slug',
                color: Colors.black,
                size: 48,
              ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(Image), findsNothing);
    expect(
      find.byType(SvgPicture),
      findsNWidgets(subscriptionBrandAssetSlugs.length),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('light brand marks receive contrast-safe backgrounds', (
    tester,
  ) async {
    final examples = <(String, String, Color)>[
      ('DAZN', 'si:dazn', const Color(0xFFF8F8F5)),
      ('Mercado Livre', 'si:mercadopago', const Color(0xFFFFE600)),
    ];

    for (final example in examples) {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: SubscriptionAvatar(
            name: example.$1,
            iconName: example.$2,
            color: example.$3,
            size: 48,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final background = _avatarBackground(tester);
      final foreground = tester.widget<Icon>(find.byType(Icon)).color!;
      expect(
        _contrastRatio(foreground, background),
        greaterThanOrEqualTo(3),
        reason: example.$1,
      );
      expect(
        background.computeLuminance(),
        greaterThan(0.65),
        reason: '${example.$1} should keep a light tonal background',
      );
    }
  });

  testWidgets('dark brand marks remain visible in dark mode', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: const SubscriptionAvatar(
          name: 'Apple TV+',
          iconName: 'si:appletv',
          color: Colors.black,
          size: 48,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final foreground = tester.widget<Icon>(find.byType(Icon)).color!;
    expect(
      _contrastRatio(foreground, _avatarBackground(tester)),
      greaterThanOrEqualTo(3),
    );
  });

  testWidgets('brand logos share one Renvoy avatar treatment', (tester) async {
    tester.view.physicalSize = const Size(648, 104);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const logos = [
      ('Netflix', 'si:netflix', Color(0xFFE50914)),
      ('Prime Video', 'asset:prime-video', Color(0xFF00A8E1)),
      ('Disney+', 'asset:disney-plus', Color(0xFF113CCF)),
      ('HBO Max', 'si:hbomax', Color(0xFF991EEB)),
      ('Apple TV+', 'si:appletv', Color(0xFF000000)),
      ('YouTube', 'si:youtube', Color(0xFFFF0000)),
      ('Crunchyroll', 'si:crunchyroll', Color(0xFFF47521)),
      ('Paramount+', 'si:paramountplus', Color(0xFF0064FF)),
      ('DAZN', 'si:dazn', Color(0xFFF8F8F5)),
      ('Mercado Livre', 'asset:meli-plus', Color(0xFFFFE600)),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: ColoredBox(
          color: const Color(0xFFF4F0EA),
          child: Center(
            child: RepaintBoundary(
              key: const Key('logo-strip'),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final logo in logos)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: SubscriptionAvatar(
                        name: logo.$1,
                        iconName: logo.$2,
                        color: logo.$3,
                        size: 56,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byKey(const Key('logo-strip')),
      matchesGoldenFile('goldens/subscription_logo_strip.png'),
    );
  });
}

Color _avatarBackground(WidgetTester tester) {
  final avatar = find.byType(SubscriptionAvatar);
  final container = tester.widget<Container>(
    find.descendant(of: avatar, matching: find.byType(Container)).first,
  );
  return (container.decoration! as BoxDecoration).color!;
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
