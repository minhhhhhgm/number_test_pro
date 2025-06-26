import 'dart:async';
import 'dart:ui';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:numbers/screens/GameScreen/GameScreen.dart';
import 'package:numbers/screens/TurorialScreen.dart';
import 'package:numbers/screens/LoadingScreen.dart';
import 'package:numbers/screens/SplashScreen.dart';
import 'package:numbers/screens/HomeScreen/HomeScreen.dart';
// import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  runZoned<Future<Null>>(() async {
    WidgetsFlutterBinding.ensureInitialized();
    // SystemChrome.setPreferredOrientations([
    //   DeviceOrientation.portraitUp,
    //   DeviceOrientation.portraitDown,
    // ]);
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);

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
      initialRoute: '/',
      routes: <String, WidgetBuilder>{
        '/': (BuildContext context) => SplashScreen(),
        '/home': (BuildContext context) => HomeScreen(),
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
