// ignore_for_file: constant_identifier_names, camel_case_extensions

const hiveBoxes = [
  {'name': 'settings', 'limit': false},
  {'name': 'downloads', 'limit': false},
  {'name': 'stats', 'limit': false},
  {'name': 'Favorite Songs', 'limit': false},
  {'name': 'cache', 'limit': true},
  {'name': 'ytlinkcache', 'limit': true},
];

enum SourceType { Local, Remote }

enum Source { Spotify, YouTube, YouTubeMusic, Saavn, Unknown }

extension getsourceType on Source {
  SourceType get type {
    switch (this) {
      case Source.Spotify:
      case Source.YouTube:
      case Source.YouTubeMusic:
      case Source.Saavn:
        return SourceType.Remote;
      default:
        return SourceType.Local;
    }
  }
}

extension getSourceName on Source {
  String get name {
    switch (this) {
      case Source.Spotify:
        return 'Spotify';
      case Source.YouTube:
        return 'YouTube';
      case Source.YouTubeMusic:
        return 'YouTube Music';
      case Source.Saavn:
        return 'Saavn';
      default:
        return 'Unknown';
    }
  }
}

enum ThemeType { Light, Dark, System }

extension ThemeTypeExtension on ThemeType {
  String get name {
    switch (this) {
      case ThemeType.Light:
        return 'Light';
      case ThemeType.Dark:
        return 'Dark';
      case ThemeType.System:
        return 'System';
    }
  }
}

enum GradientType {
  Simple,
  HalfLight,
  HalfDark,
  FullLight,
  FullDark,
  FullMix,
}

extension GradientTypeExtension on GradientType {
  String get name {
    switch (this) {
      case GradientType.Simple:
        return 'Simple';
      case GradientType.HalfLight:
        return 'HalfLight';
      case GradientType.HalfDark:
        return 'HalfDark';
      case GradientType.FullLight:
        return 'FullLight';
      case GradientType.FullDark:
        return 'FullDark';
      case GradientType.FullMix:
        return 'FullMix';
    }
  }
}

extension GradientTypeToString on String {
  GradientType get gradientType {
    switch (this) {
      case 'simple':
        return GradientType.Simple;
      case 'halfLight':
        return GradientType.HalfLight;
      case 'halfDark':
        return GradientType.HalfDark;
      case 'fullLight':
        return GradientType.FullLight;
      case 'fullDark':
        return GradientType.FullDark;
      case 'fullMix':
        return GradientType.FullMix;
      default:
        throw ArgumentError('Invalid gradient type: $this');
    }
  }
}

// Example usage of the constants in a widget
// class ExampleWidget extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return ValueListenableBuilder<Source>(
//       valueListenable: sourceNotifier,
//       builder: (context, source, child) {
//         return Text('Current source: ${source.name}');
//       },
//     );
//   }
//   final ValueNotifier<Source> sourceNotifier = ValueNotifier<Source>(Source.Unknown);
// }

enum StreamQuality { _96KBPS, _128KBPS, _160KBPS, _192KBPS, _256KBPS, _320KBPS }

extension StreamQualityExtension on StreamQuality {
  String get name {
    switch (this) {
      case StreamQuality._96KBPS:
        return '96 Kbps';
      case StreamQuality._128KBPS:
        return '128 Kbps';
      case StreamQuality._160KBPS:
        return '160 Kbps';
      case StreamQuality._192KBPS:
        return '192 Kbps';
      case StreamQuality._256KBPS:
        return '256 Kbps';
      case StreamQuality._320KBPS:
        return '320 Kbps';
    }
  }
}

extension StreamQualityToString on String {
  StreamQuality get streamQuality {
    switch (this) {
      case '96 Kbps':
        return StreamQuality._96KBPS;
      case '128 Kbps':
        return StreamQuality._128KBPS;
      case '160 Kbps':
        return StreamQuality._160KBPS;
      case '192 Kbps':
        return StreamQuality._192KBPS;
      case '256 Kbps':
        return StreamQuality._256KBPS;
      case '320 Kbps':
        return StreamQuality._320KBPS;
      default:
        throw ArgumentError('Invalid StreamQuality: $this');
    }
  }
}

const String appName = 'Silence Music Player';
const String appVersion = '1.0.0';
const String appDescription =
    'A immersive, feature-rich, and elegant music player for your favorite tracks.';
const String appAuthor = 'Saksham Srivastava';
const String appAuthorEmail = 'the.saksham.srivastava@gmail.com';
const String appRepository =
    'https://github.com/I-Am-Saksham-Srivastavaa/Silence';

const String appLicense = 'MIT License';
const String appLicenseUrl = 'https://opensource.org/license/mit/';

const String appWebsite = 'https://silence.sakshamsrivastava.in';

const String LinkedInProfile =
    'https://www.linkedin.com/in/saksham-srivastavaa/';
const String GitHubProfile = 'https://github.com/I-Am-Saksham-Srivastavaa';
const String UpworkProfile =
    'https://www.upwork.com/freelancers/~01f0b1c3d2e4a5b6c7';
const String UPIProfile = 'https://www.upi.com/sakshamsrivastavaa@upi';
