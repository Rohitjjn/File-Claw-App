import 'file_type.dart';

/// Singleton-style application configuration persisted as JSON.
///
/// Stored at: <appDocs>/config/app_config.json
class AppConfig {
  static const String singletonId = 'app_config';
  static const int currentSchemaVersion = 1;

  final String id;
  final int schemaVersion;
  final AppThemeMode themeMode;
  final bool isFloatingWindowEnabled;
  final bool autoFloatOnOpen;
  final double floatingWindowOpacity; // 0.5 - 1.0
  final int historyLimit; // 10 - 100
  final String defaultEncoding;
  final bool showLineNumbers;
  final bool wordWrap;
  final int tabSize; // 2 or 4
  final bool autoSaveDrafts;
  final OpenMode defaultOpenMode;
  final double fontScale; // 0.9 / 1.0 / 1.1
  final bool notificationOnOpen;
  final bool notificationOnSave;
  final bool notificationLowStorage;
  final bool persistentFloatingNotification;

  const AppConfig({
    this.id = singletonId,
    this.schemaVersion = currentSchemaVersion,
    this.themeMode = AppThemeMode.light,
    this.isFloatingWindowEnabled = true,
    this.autoFloatOnOpen = false,
    this.floatingWindowOpacity = 1.0,
    this.historyLimit = 20,
    this.defaultEncoding = 'utf-8',
    this.showLineNumbers = true,
    this.wordWrap = true,
    this.tabSize = 4,
    this.autoSaveDrafts = true,
    this.defaultOpenMode = OpenMode.preview,
    this.fontScale = 1.0,
    this.notificationOnOpen = true,
    this.notificationOnSave = true,
    this.notificationLowStorage = true,
    this.persistentFloatingNotification = true,
  });

  AppConfig copyWith({
    AppThemeMode? themeMode,
    bool? isFloatingWindowEnabled,
    bool? autoFloatOnOpen,
    double? floatingWindowOpacity,
    int? historyLimit,
    String? defaultEncoding,
    bool? showLineNumbers,
    bool? wordWrap,
    int? tabSize,
    bool? autoSaveDrafts,
    OpenMode? defaultOpenMode,
    double? fontScale,
    bool? notificationOnOpen,
    bool? notificationOnSave,
    bool? notificationLowStorage,
    bool? persistentFloatingNotification,
  }) {
    return AppConfig(
      id: id,
      schemaVersion: schemaVersion,
      themeMode: themeMode ?? this.themeMode,
      isFloatingWindowEnabled:
          isFloatingWindowEnabled ?? this.isFloatingWindowEnabled,
      autoFloatOnOpen: autoFloatOnOpen ?? this.autoFloatOnOpen,
      floatingWindowOpacity:
          floatingWindowOpacity ?? this.floatingWindowOpacity,
      historyLimit: historyLimit ?? this.historyLimit,
      defaultEncoding: defaultEncoding ?? this.defaultEncoding,
      showLineNumbers: showLineNumbers ?? this.showLineNumbers,
      wordWrap: wordWrap ?? this.wordWrap,
      tabSize: tabSize ?? this.tabSize,
      autoSaveDrafts: autoSaveDrafts ?? this.autoSaveDrafts,
      defaultOpenMode: defaultOpenMode ?? this.defaultOpenMode,
      fontScale: fontScale ?? this.fontScale,
      notificationOnOpen: notificationOnOpen ?? this.notificationOnOpen,
      notificationOnSave: notificationOnSave ?? this.notificationOnSave,
      notificationLowStorage:
          notificationLowStorage ?? this.notificationLowStorage,
      persistentFloatingNotification:
          persistentFloatingNotification ?? this.persistentFloatingNotification,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'schemaVersion': schemaVersion,
        'themeMode': themeMode.name,
        'isFloatingWindowEnabled': isFloatingWindowEnabled,
        'autoFloatOnOpen': autoFloatOnOpen,
        'floatingWindowOpacity': floatingWindowOpacity,
        'historyLimit': historyLimit,
        'defaultEncoding': defaultEncoding,
        'showLineNumbers': showLineNumbers,
        'wordWrap': wordWrap,
        'tabSize': tabSize,
        'autoSaveDrafts': autoSaveDrafts,
        'defaultOpenMode': defaultOpenMode.name,
        'fontScale': fontScale,
        'notificationOnOpen': notificationOnOpen,
        'notificationOnSave': notificationOnSave,
        'notificationLowStorage': notificationLowStorage,
        'persistentFloatingNotification': persistentFloatingNotification,
      };

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    return AppConfig(
      id: json['id'] as String? ?? singletonId,
      schemaVersion: (json['schemaVersion'] as num?)?.toInt() ?? currentSchemaVersion,
      themeMode: _parseEnum(
          AppThemeMode.values, json['themeMode'] as String?, AppThemeMode.light),
      isFloatingWindowEnabled: json['isFloatingWindowEnabled'] as bool? ?? true,
      autoFloatOnOpen: json['autoFloatOnOpen'] as bool? ?? false,
      floatingWindowOpacity:
          (json['floatingWindowOpacity'] as num?)?.toDouble() ?? 1.0,
      historyLimit: (json['historyLimit'] as num?)?.toInt() ?? 20,
      defaultEncoding: json['defaultEncoding'] as String? ?? 'utf-8',
      showLineNumbers: json['showLineNumbers'] as bool? ?? true,
      wordWrap: json['wordWrap'] as bool? ?? true,
      tabSize: (json['tabSize'] as num?)?.toInt() ?? 4,
      autoSaveDrafts: json['autoSaveDrafts'] as bool? ?? true,
      defaultOpenMode: _parseEnum(
          OpenMode.values, json['defaultOpenMode'] as String?, OpenMode.preview),
      fontScale: (json['fontScale'] as num?)?.toDouble() ?? 1.0,
      notificationOnOpen: json['notificationOnOpen'] as bool? ?? true,
      notificationOnSave: json['notificationOnSave'] as bool? ?? true,
      notificationLowStorage: json['notificationLowStorage'] as bool? ?? true,
      persistentFloatingNotification:
          json['persistentFloatingNotification'] as bool? ?? true,
    );
  }

  static T _parseEnum<T extends Enum>(List<T> values, String? name, T fallback) {
    if (name == null) return fallback;
    for (final v in values) {
      if (v.name == name) return v;
    }
    return fallback;
  }
}
