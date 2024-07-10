import 'dart:io';

import 'package:chatty/utilities/assets_manager.dart';
import 'package:chatty/utilities/global_methods.dart';
import 'package:chatty/widgets/app_bar_back_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
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
    cropImage(finalFileImage!.path);

  }

  void cropImage(filePath)async{
    if(filePath != null ){
     CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: filePath,
        maxHeight: 800,
        maxWidth: 800,
        compressQuality: 90
      );
     popTheDialog();

     if(croppedFile != null){
       setState(() {
         finalFileImage = File(croppedFile.path);
       });
     }else{
       popTheDialog();
     }
    }

  }

  popTheDialog(){
    Navigator.of(context).pop();
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
           const Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: AssetImage(AssetsManager.userImage),
                ),
                Positioned(
                  bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.green,
                      child: Icon(Icons.camera_alt,color: Colors.white,size: 20,),
                    )
                ),
              ],
            ),
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
                  // save the user information screen
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
}
