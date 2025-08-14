// ignore_for_file: type=lint, unused_local_variable
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'custom_localization.dart';

class CustomLocalizationDelegate extends LocalizationsDelegate<CustomLocalization> {
  const CustomLocalizationDelegate();

  @override
  Future<CustomLocalization> load(Locale locale) {
    final String lang = locale.languageCode;
    final String? script = locale.scriptCode;
    final String? country = locale.countryCode;

    if (script != null) {
      final scriptLocale = "${lang}_${script}";
      switch (scriptLocale) {
        case "zh_Hans": return SynchronousFuture(CustomLocalizationZhHans());
        case "zh_Hant": return SynchronousFuture(CustomLocalizationZhHant());
      }
    }
    if (country != null) {
      final countryLocale = "${lang}_${country}";
      switch (countryLocale) {
        case "fa_PAL": return SynchronousFuture(CustomLocalizationFaPAL());
      }
    }
    switch (lang) {
      case "ar": return SynchronousFuture(CustomLocalizationAr());
      case "be": return SynchronousFuture(CustomLocalizationBe());
      case "bn": return SynchronousFuture(CustomLocalizationBn());
      case "cs": return SynchronousFuture(CustomLocalizationCs());
      case "da": return SynchronousFuture(CustomLocalizationDa());
      case "de": return SynchronousFuture(CustomLocalizationDe());
      case "el": return SynchronousFuture(CustomLocalizationEl());
      case "en": return SynchronousFuture(CustomLocalizationEn());
      case "es": return SynchronousFuture(CustomLocalizationEs());
      case "fa": return SynchronousFuture(CustomLocalizationFa());
      case "fr": return SynchronousFuture(CustomLocalizationFr());
      case "gu": return SynchronousFuture(CustomLocalizationGu());
      case "he": return SynchronousFuture(CustomLocalizationHe());
      case "hi": return SynchronousFuture(CustomLocalizationHi());
      case "hu": return SynchronousFuture(CustomLocalizationHu());
      case "id": return SynchronousFuture(CustomLocalizationId());
      case "it": return SynchronousFuture(CustomLocalizationIt());
      case "ja": return SynchronousFuture(CustomLocalizationJa());
      case "km": return SynchronousFuture(CustomLocalizationKm());
      case "kn": return SynchronousFuture(CustomLocalizationKn());
      case "ko": return SynchronousFuture(CustomLocalizationKo());
      case "ml": return SynchronousFuture(CustomLocalizationMl());
      case "mn": return SynchronousFuture(CustomLocalizationMn());
      case "mr": return SynchronousFuture(CustomLocalizationMr());
      case "ne": return SynchronousFuture(CustomLocalizationNe());
      case "nl": return SynchronousFuture(CustomLocalizationNl());
      case "or": return SynchronousFuture(CustomLocalizationOr());
      case "pa": return SynchronousFuture(CustomLocalizationPa());
      case "pl": return SynchronousFuture(CustomLocalizationPl());
      case "pt": return SynchronousFuture(CustomLocalizationPt());
      case "ru": return SynchronousFuture(CustomLocalizationRu());
      case "sq": return SynchronousFuture(CustomLocalizationSq());
      case "sv": return SynchronousFuture(CustomLocalizationSv());
      case "ta": return SynchronousFuture(CustomLocalizationTa());
      case "te": return SynchronousFuture(CustomLocalizationTe());
      case "tr": return SynchronousFuture(CustomLocalizationTr());
      case "uk": return SynchronousFuture(CustomLocalizationUk());
      case "ur": return SynchronousFuture(CustomLocalizationUr());
      case "vi": return SynchronousFuture(CustomLocalizationVi());
    }

    print("⚠️ Localization for ${locale.toString()} not found, falling back to en.");
    return SynchronousFuture(CustomLocalizationEn());
  }

  @override
  bool shouldReload(CustomLocalizationDelegate old) => false;

  @override
  bool isSupported(Locale locale) {
    final localeString = locale.toString().replaceAll('_', '-');
    final langCode = locale.languageCode;
    // First, check for full locale string (e.g., en-US, zh-Hans-CN)
    if (supportedLocaleCodes.contains(localeString)) return true;
    // Then, check for language_script (e.g., zh-Hans)
    if (locale.scriptCode != null && supportedLocaleCodes.contains('${langCode}-${locale.scriptCode}')) return true;
    // Finally, check for language code only (e.g., en)
    return supportedLocaleCodes.contains(langCode);
  }

  static const LocalizationsDelegate<CustomLocalization> delegate = CustomLocalizationDelegate();
}
