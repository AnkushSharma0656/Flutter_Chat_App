import 'dart:io';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:chatty/authentication/landing_screen.dart';
import 'package:chatty/authentication/otp_screen.dart';
import 'package:chatty/constants.dart';
import 'package:chatty/main_screen/home_screen.dart';
import 'package:chatty/providers/authentication_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'authentication/login_screen.dart';
import 'authentication/user_information_screen.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';

void main()async {
  WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  final savedThemeMode = await AdaptiveTheme.getThemeMode();

  runApp(
    MultiProvider(providers: [
      ChangeNotifierProvider(create: (_)=> AuthenticationProvider()),
    ], child: MyApp(savedThemeMode: savedThemeMode)));
}

class MyApp extends StatelessWidget {
  final AdaptiveThemeMode? savedThemeMode;
 const MyApp({super.key,required this.savedThemeMode });

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: Colors.purple,
      ),
      dark: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.purple,
      ),
      initial: savedThemeMode ?? AdaptiveThemeMode.light,
      builder: (theme,darkTheme) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Chatty Chat',
        theme: theme,
        darkTheme: darkTheme,
        initialRoute: Constants.landingScreen,
        routes: {
          Constants.landingScreen: (context) => const LandingScreen(),
          Constants.loginScreen: (context) => const LoginScreen(),
          Constants.otpScreen: (context) => const OtpScreen(),
          Constants.userInformationScreen: (context) =>  UserInformationScreen(),
          Constants.homeScreen : (context) => HomeScreen()
        },
      ),
    );
  }
}

