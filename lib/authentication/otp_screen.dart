import 'package:chatty/constants.dart';
import 'package:chatty/providers/authentication_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final controller = TextEditingController();
  final focusNode = FocusNode();
  String? otpCode;

  @override
  void dispose(){
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    final verificationId = args[Constants.verificationId] as String;
    final phoneNumber = args[Constants.phoneNumber] as String;
    final authProvider = context.watch<AuthenticationProvider>();

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 60,
      textStyle: GoogleFonts.openSans(fontSize: 22,
      fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.shade200,
        border: Border.all(color: Colors.transparent)
      )
    );
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 20),
            child: Column(children: [
              const SizedBox(height: 50,),
              Text("Verification",style: GoogleFonts.openSans(
                fontSize: 28,
                fontWeight: FontWeight.w500
              ),),
              const SizedBox(height: 50,),
              Text("Enter the 6-digit code sent to the number",
                textAlign: TextAlign.center,
                style: GoogleFonts.openSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w500
              ),),
              const SizedBox(height: 10,),
              Text("+919507390656",
                textAlign: TextAlign.center,
                style: GoogleFonts.openSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w500
                ),),
              const SizedBox(height: 30,),
              SizedBox(height: 68,child: Pinput(
                length: 6,
                controller: controller,
                focusNode: focusNode,
                defaultPinTheme: defaultPinTheme,
                onCompleted: (pin){
                  setState(() {
                    otpCode = pin;
                  });
                  //verify otp code
                  verifyOTPCode(verificationId: verificationId,otpCode: otpCode!);
                },
                focusedPinTheme: defaultPinTheme.copyWith(
                  height: 68,
                  width: 64,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey.shade200,
                    border: Border.all(
                      color: Colors.deepPurple
                    )
                  )
                ),
                errorPinTheme: defaultPinTheme.copyWith(
                    height: 68,
                    width: 64,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey.shade200,
                        border: Border.all(
                            color: Colors.deepPurple
                        )
                    )
                ),
              ),
              ),
              const SizedBox(height: 30,),
              authProvider.isLoading
              ? const CircularProgressIndicator()
              : const SizedBox.shrink(),
              authProvider.isSuccessful
              ? Container(
                height: 50,
                width: 50,
                margin: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 20,
                ),
              ): const SizedBox.shrink(),
              authProvider.isLoading
              ?const SizedBox.shrink()
              :Text(
                  'Didn\'t receive the code?',
                style: GoogleFonts.openSans(
                    fontSize: 16,
                ),
              ),
              const SizedBox(height: 30,),
              authProvider.isLoading ?const SizedBox.shrink()
              :TextButton(onPressed: (){

              },
                  child: Text('Resend Code',
                    style: GoogleFonts.openSans(
                      fontSize: 16,
                      fontWeight : FontWeight.w600
              ),))
            ],
            ),
          ),
        ),
      ),
    );
  }

  void verifyOTPCode({
    required String verificationId,
    required String otpCode
  })async{

    final authProvider = context.read<AuthenticationProvider>();
    authProvider.verifyOTPCode(
        verificationId: verificationId,
        otpCode: otpCode,
        context: context,
        onSuccess: () async {
          // 1. check if the user exists on firestore
          bool userExists = await authProvider.checkUserExists();
          // 2. if user exists
          if(userExists){
            // * get user information from the firestore
            await authProvider.getUserDataFromFireStore();
            // *  save user information to provider/ shared preference
            await authProvider.saveUserDataToSharedPreferences();
            // *  navigate to the home screen
            navigate(userExists : true);
          }else{
            // 3. if the user doesn't exist, navigate to user information screen
            navigate(userExists : false);
          }

        });
  }

  void navigate({required bool userExists}) {
    if(userExists){
      Navigator.pushNamedAndRemoveUntil(context, Constants.homeScreen, (route) => false);
    }else{
      Navigator.pushNamed(context, Constants.userInformationScreen);
    }
  }

}
