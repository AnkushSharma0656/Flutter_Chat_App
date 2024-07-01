import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:chatty/main_screen/home_screen.dart';
import 'package:flutter/material.dart';

void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  final savedThemeMode = await AdaptiveTheme.getThemeMode();
  runApp(MyApp(savedThemeMode: savedThemeMode));
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
        home: const HomeScreen(),
      ),
    );
  }
}

