// ignore_for_file: type=lint

import 'package:flutter/widgets.dart';
import 'custom_localization.dart';

export 'generated/custom_localizations_ar.dart';
export 'generated/custom_localizations_be.dart';
export 'generated/custom_localizations_bn.dart';
export 'generated/custom_localizations_cs.dart';
export 'generated/custom_localizations_da.dart';
export 'generated/custom_localizations_de.dart';
export 'generated/custom_localizations_el.dart';
export 'generated/custom_localizations_en.dart';
export 'generated/custom_localizations_es.dart';
export 'generated/custom_localizations_fa.dart';
export 'generated/custom_localizations_fr.dart';
export 'generated/custom_localizations_gu.dart';
export 'generated/custom_localizations_he.dart';
export 'generated/custom_localizations_hi.dart';
export 'generated/custom_localizations_hu.dart';
export 'generated/custom_localizations_id.dart';
export 'generated/custom_localizations_it.dart';
export 'generated/custom_localizations_ja.dart';
export 'generated/custom_localizations_km.dart';
export 'generated/custom_localizations_kn.dart';
export 'generated/custom_localizations_ko.dart';
export 'generated/custom_localizations_ml.dart';
export 'generated/custom_localizations_mn.dart';
export 'generated/custom_localizations_mr.dart';
export 'generated/custom_localizations_ne.dart';
export 'generated/custom_localizations_nl.dart';
export 'generated/custom_localizations_or.dart';
export 'generated/custom_localizations_pa.dart';
export 'generated/custom_localizations_fa_PAL.dart';
export 'generated/custom_localizations_pl.dart';
export 'generated/custom_localizations_pt.dart';
export 'generated/custom_localizations_ru.dart';
export 'generated/custom_localizations_sq.dart';
export 'generated/custom_localizations_sv.dart';
export 'generated/custom_localizations_ta.dart';
export 'generated/custom_localizations_te.dart';
export 'generated/custom_localizations_tr.dart';
export 'generated/custom_localizations_uk.dart';
export 'generated/custom_localizations_ur.dart';
export 'generated/custom_localizations_vi.dart';
export 'generated/custom_localizations_zh_Hans.dart';
export 'generated/custom_localizations_zh_Hant.dart';

final List<Locale> LocaleList = <Locale>[
  Locale('ar'),
  Locale('be'),
  Locale('bn'),
  Locale('cs'),
  Locale('da'),
  Locale('de'),
  Locale('el'),
  Locale('en'),
  Locale('es'),
  Locale('fa'),
  Locale('fr'),
  Locale('gu'),
  Locale('he'),
  Locale('hi'),
  Locale('hu'),
  Locale('id'),
  Locale('it'),
  Locale('ja'),
  Locale('km'),
  Locale('kn'),
  Locale('ko'),
  Locale('ml'),
  Locale('mn'),
  Locale('mr'),
  Locale('ne'),
  Locale('nl'),
  Locale('or'),
  Locale('pa'),
  Locale('fa', 'PAL'),
  Locale('pl'),
  Locale('pt'),
  Locale('ru'),
  Locale('sq'),
  Locale('sv'),
  Locale('ta'),
  Locale('te'),
  Locale('tr'),
  Locale('uk'),
  Locale('ur'),
  Locale('vi'),
  Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
  Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
];

const List<String> supportedLocaleCodes = <String>[
  'ar',
  'be',
  'bn',
  'cs',
  'da',
  'de',
  'el',
  'en',
  'es',
  'fa',
  'fr',
  'gu',
  'he',
  'hi',
  'hu',
  'id',
  'it',
  'ja',
  'km',
  'kn',
  'ko',
  'ml',
  'mn',
  'mr',
  'ne',
  'nl',
  'or',
  'pa',
  'fa_PAL',
  'pl',
  'pt',
  'ru',
  'sq',
  'sv',
  'ta',
  'te',
  'tr',
  'uk',
  'ur',
  'vi',
  'zh_Hans',
  'zh_Hant',
];

final Map<String, CustomLocalization Function()> localeSpecificLoaders = {
  'ar': () => CustomLocalizationAr(),
  'be': () => CustomLocalizationBe(),
  'bn': () => CustomLocalizationBn(),
  'cs': () => CustomLocalizationCs(),
  'da': () => CustomLocalizationDa(),
  'de': () => CustomLocalizationDe(),
  'el': () => CustomLocalizationEl(),
  'en': () => CustomLocalizationEn(),
  'es': () => CustomLocalizationEs(),
  'fa': () => CustomLocalizationFa(),
  'fr': () => CustomLocalizationFr(),
  'gu': () => CustomLocalizationGu(),
  'he': () => CustomLocalizationHe(),
  'hi': () => CustomLocalizationHi(),
  'hu': () => CustomLocalizationHu(),
  'id': () => CustomLocalizationId(),
  'it': () => CustomLocalizationIt(),
  'ja': () => CustomLocalizationJa(),
  'km': () => CustomLocalizationKm(),
  'kn': () => CustomLocalizationKn(),
  'ko': () => CustomLocalizationKo(),
  'ml': () => CustomLocalizationMl(),
  'mn': () => CustomLocalizationMn(),
  'mr': () => CustomLocalizationMr(),
  'ne': () => CustomLocalizationNe(),
  'nl': () => CustomLocalizationNl(),
  'or': () => CustomLocalizationOr(),
  'pa': () => CustomLocalizationPa(),
  'fa_PAL': () => CustomLocalizationFaPAL(),
  'pl': () => CustomLocalizationPl(),
  'pt': () => CustomLocalizationPt(),
  'ru': () => CustomLocalizationRu(),
  'sq': () => CustomLocalizationSq(),
  'sv': () => CustomLocalizationSv(),
  'ta': () => CustomLocalizationTa(),
  'te': () => CustomLocalizationTe(),
  'tr': () => CustomLocalizationTr(),
  'uk': () => CustomLocalizationUk(),
  'ur': () => CustomLocalizationUr(),
  'vi': () => CustomLocalizationVi(),
  'zh_Hans': () => CustomLocalizationZhHans(),
  'zh_Hant': () => CustomLocalizationZhHant(),
};

