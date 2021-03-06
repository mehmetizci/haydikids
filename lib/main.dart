// Flutter
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:haydikids/config/languages.dart';
import 'package:haydikids/core/randomString.dart';

// Internal
import 'package:haydikids/intro/introduction.dart';
import 'package:haydikids/provider/downloadsProvider.dart';
import 'package:haydikids/provider/managerProvider.dart';
import 'package:haydikids/provider/configurationProvider.dart';
import 'package:haydikids/lib.dart';
import 'package:haydikids/core/haydiPreferences.dart';
import 'package:haydikids/provider/mediaProvider.dart';

// Packages
import 'package:audio_service/audio_service.dart';
import 'package:provider/provider.dart';
import 'package:haydikids/provider/preferencesProvider.dart';

// UI
import 'package:haydikids/config/themes/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HaydiPreferences preferences = new HaydiPreferences();
  await preferences.initPreferences();
  runApp(Main(preloadedFs: preferences));
}

class Main extends StatefulWidget {
  static void setLocale(BuildContext context, Locale newLocale) {
    var state = context.findAncestorStateOfType<_MainState>();
    state.setLocale(newLocale);
  }

  final HaydiPreferences preloadedFs;
  Main({@required this.preloadedFs});

  @override
  _MainState createState() => _MainState();
}

class _MainState extends State<Main> {
  // Language
  Locale _locale;
  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  void didChangeDependencies() async {
    getLocale().then((locale) {
      setState(() {
        _locale = locale;
      });
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    List lastSearchQuery =
        (jsonDecode(widget.preloadedFs.getSearchHistory()) as List<dynamic>)
            .cast<String>();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ConfigurationProvider>(
            create: (context) =>
                ConfigurationProvider(preferences: widget.preloadedFs)),
        ChangeNotifierProvider<ManagerProvider>(
            create: (context) => ManagerProvider(lastSearchQuery.isNotEmpty
                ? lastSearchQuery[0]
                : RandomString.getRandomLetter())),
        ChangeNotifierProvider<DownloadsProvider>(
            create: (context) => DownloadsProvider()),
        ChangeNotifierProvider<MediaProvider>(
            create: (context) => MediaProvider()),
        ChangeNotifierProvider<PreferencesProvider>(
          create: (context) => PreferencesProvider(),
        )
      ],
      child: Builder(builder: (context) {
        ConfigurationProvider config =
            Provider.of<ConfigurationProvider>(context);
        ThemeData customTheme;
        ThemeData darkTheme;

        darkTheme = config.blackThemeEnabled
            ? AppTheme.black(config.accentColor)
            : AppTheme.dark(config.accentColor);

        customTheme = config.darkThemeEnabled
            ? darkTheme
            : AppTheme.white(config.accentColor);

        List<Locale> supportedLocales = [];
        supportedLanguages.forEach((element) =>
            supportedLocales.add(Locale(element.languageCode, '')));

        return MaterialApp(
          locale: _locale,
          supportedLocales: supportedLocales,
          localizationsDelegates: [
            FallbackLocalizationDelegate(),
            AppLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          localeResolutionCallback: (locale, supportedLocales) {
            for (var supportedLocale in supportedLocales) {
              if (supportedLocale?.languageCode == locale?.languageCode &&
                  supportedLocale?.countryCode == locale?.countryCode) {
                return supportedLocale;
              }
            }
            return supportedLocales?.first;
          },
          title: "HaydiKids",
          theme: config.systemThemeEnabled
              ? AppTheme.white(config.accentColor)
              : customTheme,
          darkTheme: config.systemThemeEnabled ? darkTheme : customTheme,
          initialRoute: config.preferences.showIntroductionPages()
              ? 'introScreen'
              : 'homeScreen',
          routes: {
            'homeScreen': (context) => AudioServiceWidget(child: MainLib()),
            'introScreen': (context) => IntroScreen()
          },
        );
      }),
    );
  }
}
