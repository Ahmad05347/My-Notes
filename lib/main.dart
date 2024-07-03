import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:my_notes/localization/locals.dart';
import 'package:my_notes/pages/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      // options: DefaultFirebaseOptions.currentPlatform,
      );
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FlutterLocalization localization = FlutterLocalization.instance;

  @override
  void initState() {
    configureLocalization();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      supportedLocales: localization.supportedLocales,
      localizationsDelegates: localization.localizationsDelegates,
      home: // const Welcome(),
          const SplashScreen(),
      // const Tesst(),
    );
  }

  void configureLocalization() {
    localization.init(
      mapLocales: LOCALE,
      initLanguageCode: "en",
    );
    localization.onTranslatedLanguage = onTranslatedLnaguage;
  }

  void onTranslatedLnaguage(Locale? locale) {
    setState(() {});
  }
}
