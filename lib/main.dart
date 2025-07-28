import 'dart:async';

// import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:numbers/new_screens/home_screen/home_screen_new.dart';
import 'package:numbers/service/sound_service.dart';

import 'di/service_locator.dart';
import 'firebase_options.dart';

Future<void> main() async {
  runZoned<Future<Null>>(() async {
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    await EasyLocalization.ensureInitialized();

    // SystemChrome.setPreferredOrientations([
    //   DeviceOrientation.portraitUp,
    //   DeviceOrientation.portraitDown,
    // ]);

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await setupLocator();
    await getIt<MainSoundService>().init();

    // FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);

    // FlutterError.onError = (errorDetails) {
    //   FirebaseCrashlytics.instance.recordFlutterError(errorDetails);
    // };
    // // Async exceptions
    // PlatformDispatcher.instance.onError = (error, stack) {
    //   FirebaseCrashlytics.instance.recordError(
    //     error,
    //     stack,
    //   );
    //   return true;
    // };
    runApp(EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('vi')],
        path: 'assets/translations',
        startLocale: Locale('vi'),
        saveLocale: true,
        fallbackLocale: const Locale('en'),
        child: MyApp()));
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    final soundService = getIt<MainSoundService>();

    switch (state) {
      case AppLifecycleState.resumed:
        await soundService.resumeSounds();
        break;
      case AppLifecycleState.inactive:
        await soundService.pauseSounds();
        break;
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
      theme: ThemeData(
        fontFamily: 'Baloo2',
      ),
      initialRoute: '/home_new',
      routes: <String, WidgetBuilder>{
        // '/': (BuildContext context) => SplashScreen(),
        // '/home': (BuildContext context) => HomeScreen(),
        '/home_new': (BuildContext context) => HomeScreenNew(),
        // '/loading': (BuildContext context) => LoadingScreen(),
        // '/game': (BuildContext context) => GameScreen(),
        // '/tutorial': (BuildContext context) => TurorialScreen(),
      },
      navigatorObservers: [],
    );
  }
}
