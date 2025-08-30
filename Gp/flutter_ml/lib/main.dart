import 'package:flutter/material.dart';
import 'package:flutter_ml/home_screen.dart';
import 'package:flutter_ml/login_screen.dart';
import 'package:flutter_ml/medication_reminder.dart';
import 'package:flutter_ml/routes/app_routes_name.dart';
import 'package:flutter_ml/signup_screen.dart';
import 'package:flutter_ml/splash_screen.dart';
import 'package:provider/provider.dart'; //  Provider
import 'theme_provider.dart'; //  ThemeProvider
import 'package:timezone/data/latest_all.dart' as tz; //  timezone

void main() {
  tz.initializeTimeZones();
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(), //  ThemeProvider
      child: MlApp(),
    ),
  );
}

class MlApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: themeProvider.getTheme(),
      routes: {
        AppRoutesName.splash: (_) => SplashScreen(),
        AppRoutesName.login: (_) => LoginScreen(),
        AppRoutesName.signUp: (_) => SignupScreen(),
        AppRoutesName.medicationReminder: (_) => MedicationReminder(),
        AppRoutesName.homeScreen: (_) => HomeScreen(),
      }, //    SplashScreen
    );
  }
}
