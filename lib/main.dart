import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'fcm_utils.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/sign-in_screen.dart';
import 'screens/signup_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Report Flutter framework errors to Crashlytics
  FlutterError.onError =
      FirebaseCrashlytics.instance.recordFlutterFatalError;

  // Report uncaught async errors to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(
      error,
      stack,
      fatal: true,
    );
    return true;
  };
  await FcmUtils.initialize();

  print(await FcmUtils.getFcmToken());

  FcmUtils.onRefreshToken();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, asyncSnapshot) {
        print(asyncSnapshot);

        return MaterialApp(
          debugShowCheckedModeBanner: false,

          home: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (snapshot.hasData) {
                return const HomeScreen();
              }

              return const SignInScreen();
            },
          ),

          routes: {
            '/sign-in': (_) => const SignInScreen(),
            '/sign-up': (_) => const SignUpScreen(),
            '/home': (_) => const HomeScreen(),
          },
        );
      },
    );
  }
}