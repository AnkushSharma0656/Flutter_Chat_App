import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
         appBar: AppBar(
           title: const Text("Chatty Chat"),
           actions: [
             CircleAvatar()
           ],
         ),

    );
  }
}
