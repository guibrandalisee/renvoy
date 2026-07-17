# Renvoy

Renvoy is a private subscription and renewal tracker for Flutter. Subscription
data is stored locally with Drift; there is no account or remote database sync.

## Development

```sh
fvm flutter pub get
fvm flutter gen-l10n
fvm dart analyze
fvm flutter test
```

Exchange-rate totals use the keyless Frankfurter v2 API and a 24-hour local
cache. The service receives currency codes only; subscription names and prices
are never sent for conversion.

## Android release signing

Copy `android/key.properties.example` to `android/key.properties`, point it to
the private upload keystore, and keep both files outside version control. A
release build is intentionally unsigned when this local file is absent.

## Store release

Before submission, publish the privacy policy, complete Apple App Privacy and
Google Play Data safety, provide store metadata/screenshots, configure signing,
and increment `version` in `pubspec.yaml`.
