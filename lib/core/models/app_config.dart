class AppConfig {
  final bool isBeta;
  final Uri stableReleasesUri;
  final Uri allReleasesUri;
  final String codeName;

  AppConfig({
    required this.isBeta,
    required this.stableReleasesUri,
    required this.allReleasesUri,
    required this.codeName,
  });
}
