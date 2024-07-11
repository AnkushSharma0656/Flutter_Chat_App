import 'dart:io';

import 'package:chatty/constants.dart';
import 'package:chatty/models/user_model.dart';
import 'package:chatty/providers/authentication_provider.dart';
import 'package:chatty/utilities/assets_manager.dart';
import 'package:chatty/utilities/global_methods.dart';
import 'package:chatty/widgets/app_bar_back_button.dart';
import 'package:chatty/widgets/display_user_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';

class UserInformationScreen extends StatefulWidget {
  const UserInformationScreen({super.key});

  @override
  State<UserInformationScreen> createState() => _UserInformationScreenState();
}

class _UserInformationScreenState extends State<UserInformationScreen> {
  final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();
  final _nameController = TextEditingController();
  File? finalFileImage;
  String userImage = '';

  @override
  void dispose(){
    _btnController.stop();
    _nameController.dispose();
    super.dispose();
  }

  void selectImage(bool fromCamera)async{
    finalFileImage = await pickImage(
        fromCamera: fromCamera,
        onFail: (String message){
          showSnackBar(context, message);
        }
    );

    //crop image
  await cropImage(finalFileImage?.path);
  popContext();
  }

 Future<void> cropImage(filePath)async{
    if(filePath != null ){
     CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: filePath,
        maxHeight: 800,
        maxWidth: 800,
        compressQuality: 90
      );

     if(croppedFile != null){
       setState(() {
         finalFileImage = File(croppedFile.path);
       });
     }
    }

  }


  void showBottomSheet(){
    showModalBottomSheet(
        context: context,
        builder: (context) => SizedBox(
          height: MediaQuery.of(context).size.height/7,
          child: Column(
            children: [
              ListTile(
                onTap: (){
                  selectImage(true);
                },
                leading: const Icon(Icons.camera),
                title: const Text('Camera'),
              ),
              ListTile(
                onTap: (){
                  selectImage(false);
                },
                leading: const Icon(Icons.image),
                title: const Text('Gallery'),
              )
            ],
          ),
        )
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: AppBarBackButton(onPressed: (){
          Navigator.pop(context);
        },),
        centerTitle: true,title: Text('User Information'),),
      body: Center(
        child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 20),
        child: Column(
          children: [
            DisplayUserImage(finalFileImage: finalFileImage,radius: 60,onPressed: (){
              showBottomSheet();
            },),
            const SizedBox(height: 30,),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                  hintText: 'Enter your name',
                  labelText: 'Enter your name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8))
                  )
              ),
            ),
            const SizedBox(height: 30,),
            SizedBox(
              width: double.infinity,
              child: RoundedLoadingButton(
                controller: _btnController,
                successIcon: Icons.check,
                successColor: Colors.green,
                errorColor: Colors.red,
                color: Theme.of(context).primaryColor,
                onPressed: (){
                  if(_nameController.text.isEmpty || _nameController.text.length < 3){
                    showSnackBar(context, 'Please enter your name');
                    _btnController.reset();
                    return;
                  }
                  // save the user data to firestore
                  saveUserDataToFireStore();
                },
                child: const Text(
                    'Continue',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500
                  ),
                ),
              ),
            )

          ],
        ),
      ),),
    );
  }

  // save user data to fireStore
  void saveUserDataToFireStore()async{
    final authProvider = context.read<AuthenticationProvider>();
    UserModel userModel = UserModel(
        uid: authProvider.uid!,
        name: _nameController.text.trim(),
        phoneNumber: authProvider.phoneNumber!,
        image: '',
        token: '',
        aboutMe: 'Hey there, I\'m using Chatty Chat',
        lastSeen: '',
        createdAt: '',
        isOnline: true,
        friendsUIDs: [],
        friendRequestUIDS: [],
        sendFriendRequests: []
    );
    authProvider.saveUserDataToFireStore(
        userModel: userModel,
        fileImage: finalFileImage,
        onSuccess: ()async {
          _btnController.success();
          // save user data to shared preferences
          await authProvider.saveUserDataToSharedPreferences();
          navigateToHomeScreen();
        },
        onFail: ()async{
          _btnController.error();
          showSnackBar(context, 'Failed to save the user data');
           await Future.delayed(const Duration(seconds: 1));
          _btnController.reset();

        }
    );
  }

  void navigateToHomeScreen() {
    Navigator.of(context).pushNamedAndRemoveUntil(Constants.homeScreen, (route) => false);
  }

  void popContext() {
    Navigator.pop(context);
  }
}
