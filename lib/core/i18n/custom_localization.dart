// ignore_for_file: type=lint

import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:oryn/core/i18n/supported_locales.dart';
import 'package:oryn/core/i18n/localizations_delegate.dart';

export 'package:oryn/core/i18n/custom_localization.dart';
export 'package:oryn/core/i18n/supported_locales.dart';
export 'package:oryn/core/i18n/localizations_delegate.dart';
export 'package:oryn/core/i18n/custom_localizations_fallback.dart';

/* 
import 'package:flutter/foundation.dart';

class _CustomLocalizationDelegate extends LocalizationsDelegate<CustomLocalization> {
  const _CustomLocalizationDelegate();

  @override
  Future<CustomLocalization> load(Locale locale) {
    return SynchronousFuture<CustomLocalization>(lookupCustomLocalization(locale));
  }

  @override
  bool isSupported(Locale locale) => CustomLocalization.supportedLocales
      .map((l) => l.languageCode)
      .contains(locale.languageCode);

  @override
  bool shouldReload(_CustomLocalizationDelegate old) => false;

  CustomLocalization lookupCustomLocalization(Locale locale) {
    // Lookup logic when language+script codes are specified.
    switch (locale.languageCode) {
      case 'zh':
        {
          switch (locale.scriptCode) {
            case 'Hans':
              return CustomLocalizationZhHans();
            case 'Hant':
              return CustomLocalizationZhHant();
          }
          break;
        }
    }

    // Lookup logic when language+country codes are specified.
    switch (locale.languageCode) {
      case 'fa':
        {
          switch (locale.countryCode) {
            case 'PAL':
              return CustomLocalizationFa();
          }
          break;
        }
    }

    // Lookup logic when only language code is specified.
    switch (locale.languageCode) {
      case 'en':
        return CustomLocalizationEn();
      case 'hi':
        return CustomLocalizationHi();
    }

    throw FlutterError(
        'CustomLocalization.delegate failed to load unsupported locale "$locale". This is likely '
        'an issue with the localizations generation tool. Please file an issue '
        'on GitHub with a reproducible sample app and the gen-l10n configuration '
        'that was used.');
  }
}
 */

/// The main CustomLocalization class that serves as the base for all localizations.
class CustomLocalization {
  CustomLocalization(String locale)
      : localeName = canonicalizedLocale(locale.toString());

  final String localeName;

  static CustomLocalization? of(BuildContext context) {
    return Localizations.of<CustomLocalization>(context, CustomLocalization);
  }

  static const LocalizationsDelegate<CustomLocalization> delegate =
      CustomLocalizationDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static List<Locale> supportedLocales = LocaleList;
}

String systemLocale = 'en_US';

String? _defaultLocale;

set defaultLocale(String? newLocale) {
  _defaultLocale = newLocale;
}

String? get defaultLocale {
  var zoneLocale = Zone.current[#Intl.locale] as String?;
  return zoneLocale ?? _defaultLocale;
}

String getCurrentLocale() {
  defaultLocale ??= systemLocale;
  return defaultLocale!;
}

int _separatorIndex(String locale) {
  if (locale.length < 3) {
    return -1;
  }
  if (locale[2] == '-' || locale[2] == '_') {
    return 2;
  }
  if (locale.length < 4) {
    return -1;
  }
  if (locale[3] == '-' || locale[3] == '_') {
    return 3;
  }
  return -1;
}

String canonicalizedLocale(String? aLocale) {
  if (aLocale == null) return getCurrentLocale();
  if (aLocale == 'C') return 'en_ISO';
  if (aLocale.length < 5) return aLocale;

  var separatorIndex = _separatorIndex(aLocale);
  if (separatorIndex == -1) {
    return aLocale;
  }
  var language = aLocale.substring(0, separatorIndex);
  var region = aLocale.substring(separatorIndex + 1);
  // If it's longer than three it's something odd, so don't touch it.
  if (region.length <= 3) region = region.toUpperCase();
  return '${language}_$region';
}
