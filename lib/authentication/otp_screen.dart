import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';

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
              Text(
                  'Didn\'t receive the code?',
                style: GoogleFonts.openSans(
                    fontSize: 16,
                ),
              ),
              const SizedBox(height: 30,),
              TextButton(onPressed: (){},
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
}
