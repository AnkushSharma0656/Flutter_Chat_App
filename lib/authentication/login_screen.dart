import 'package:chatty/providers/authentication_provider.dart';
import 'package:chatty/utilities/assets_manager.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:country_picker/country_picker.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneNumberController = TextEditingController();
  Country selectedCountry = Country(
    phoneCode: "91",
    countryCode: "IND",
    e164Sc: 0,
    geographic: true,
    level: 1,
    name: "India",
    displayName: 'India',
    displayNameNoCountryCode: 'IND',
    e164Key: '',
    example: '',
  );
  @override
  void dispose(){
    _phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthenticationProvider>();
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 20),
          child: Column(
          children: [
            const SizedBox(height: 50,),
            SizedBox(
              height: 200,
              width: 200,
              child: Lottie.asset(AssetsManager.chatBubble),
            ),
            Text('Chatty Chat',
              style: GoogleFonts.openSans(fontSize: 28, fontWeight: FontWeight.w500),),
            const SizedBox(height: 20,),
             Text("Add your phone number will send you a code to verify" ,
              textAlign: TextAlign.center,
              style: GoogleFonts.openSans(fontSize: 16, fontWeight: FontWeight.w500),),
            const SizedBox(height: 20,),
            TextFormField(
              controller: _phoneNumberController,
              maxLength: 10,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              onChanged: (value){
                setState(() {
                  _phoneNumberController.text = value;
                });
              },
              decoration: InputDecoration(
                counterText: "",
                hintText: "Phone Number",
                hintStyle: GoogleFonts.openSans(fontSize: 16, fontWeight: FontWeight.w500),
                prefixIcon: Container(
                  padding: const EdgeInsets.fromLTRB(8.0, 12.0, 8.0, 12.0),
                  child: InkWell(
                    onTap: () {
                      showCountryPicker(
                      context: context,
                      showPhoneCode: true,
                      countryListTheme: CountryListThemeData(
                        bottomSheetHeight: MediaQuery.of(context).size.height*0.6,
                        textStyle: GoogleFonts.openSans(fontSize: 16, fontWeight: FontWeight.w500)
                      ),
                      onSelect: (Country country){
                      setState(() {
                        selectedCountry = country;
                      });
                      });
                    },
                    child: Text(
                      '${selectedCountry.flagEmoji}+${selectedCountry.phoneCode}',
                      style: GoogleFonts.openSans(fontSize: 16, fontWeight: FontWeight.w500),),
                  ),
                ),
                suffixIcon:  _phoneNumberController.text.length>9
                    ? authProvider.isLoading
                    ? const Padding(
                      padding: EdgeInsets.all(8.0),
                      child:  CircularProgressIndicator(),
                    )
                    :InkWell(
                      onTap: (){
                        // sign in with phone number
                        authProvider.signInWithPhoneNumber(
                            phoneNumber: '+${selectedCountry.phoneCode}${_phoneNumberController.text}',
                            context: context);
                       },
                        child: Container(
                            height: 40,
                            width: 40,
                            margin: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle
                            ),
                          child: const Icon(
                            Icons.send,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                    )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10)
                ),
              ),
            )
                ],
              ),
        ),
      ),);
  }
}
