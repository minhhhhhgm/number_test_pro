import 'dart:async';
import 'dart:ui';

// import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:numbers/new_screens/home_screen/home_screen_new.dart';
import 'package:numbers/screens/GameScreen/GameScreen.dart';
import 'package:numbers/screens/HomeScreen/HomeScreen.dart';
import 'package:numbers/screens/LoadingScreen.dart';
import 'package:numbers/screens/SplashScreen.dart';
import 'package:numbers/screens/TurorialScreen.dart';
import 'package:numbers/service/SoundService.dart';
import 'package:numbers/service/sound_service.dart';
import 'package:numbers/store/SettingsStore.dart';

import 'di/service_locator.dart';
import 'firebase_options.dart';

Future<void> main() async {
  runZoned<Future<Null>>(() async {
    WidgetsFlutterBinding.ensureInitialized();
    setupLocator();
    await getIt<MainSoundService>().init();

    // SystemChrome.setPreferredOrientations([
    //   DeviceOrientation.portraitUp,
    //   DeviceOrientation.portraitDown,
    // ]);
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);

    // Initialize SoundService
    await SoundService().initialize();
    await SettingsStore.instance.init();

    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterError(errorDetails);
    };
    // Async exceptions
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(
        error,
        stack,
      );
      return true;
    };
    runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Baloo2',
        // Các cấu hình theme khác...
      ),
      initialRoute: '/',
      routes: <String, WidgetBuilder>{
        '/': (BuildContext context) => SplashScreen(),
        '/home': (BuildContext context) => HomeScreen(),
        '/home_new': (BuildContext context) => HomeScreenNew(),
        '/loading': (BuildContext context) => LoadingScreen(),
        '/game': (BuildContext context) => GameScreen(),
        '/tutorial': (BuildContext context) => TurorialScreen(),
      },
      navigatorObservers: [
        // FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance)
      ],
    ));
  });
}
