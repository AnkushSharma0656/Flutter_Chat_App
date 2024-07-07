import 'package:chatty/utilities/assets_manager.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
      children: [
        const SizedBox(height: 50,),
        SizedBox(
          height: 200,
          width: 200,
          child: Lottie.asset(AssetsManager.chatBubble),
        ),
        Text('Chatty Chat',style: GoogleFonts.openSans(fontSize: 28, fontWeight: FontWeight.w500),)
      ],
    ),);
  }
}
