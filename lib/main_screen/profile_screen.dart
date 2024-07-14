

import 'package:chatty/constants.dart';
import 'package:chatty/models/user_model.dart';
import 'package:chatty/providers/authentication_provider.dart';
import 'package:chatty/utilities/global_methods.dart';
import 'package:chatty/widgets/app_bar_back_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthenticationProvider>().userModel!;

    // get user data from arguments
    var uid = ModalRoute.of(context)!.settings.arguments as String;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: AppBarBackButton(onPressed: () {
            Navigator.pop(context);
          },),
          centerTitle: true,
          title: const Text('Profile'),
          actions: [
            currentUser!.uid == uid
            ? IconButton(
                onPressed: ()async{
                  //  Navigate to settings screen with the uid as arguments
                  await Navigator.pushNamed(
                      context,
                      Constants.settingsScreen,
                    arguments: uid
                  );
      
                },
                icon: const Icon(Icons.settings))
                : const SizedBox()
          ],
        ),
        body: StreamBuilder(
          stream: context.read<AuthenticationProvider>().userStream(userID: uid),
          builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('Something went wrong'));
            }
      
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final userModel = UserModel.fromMap(snapshot.data!.data() as Map<String,dynamic>);
      
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 30,
                vertical: 20
              ),
              child: Column(
                children: [
                  Center(
                    child: userImageWidget(
                        imageUrl: userModel.image,
                        radius: 60,
                        onTap: (){
      
                        }),
                  ),
                  const SizedBox(height: 20,),
                  Text(userModel.name,
                  style: GoogleFonts.openSans(fontSize: 20,
                  fontWeight: FontWeight.w500),),
                  const SizedBox(height: 10,),
                  currentUser.uid == uid ?
                  Text(userModel.phoneNumber,
                    style: GoogleFonts.openSans(fontSize: 16,
                        fontWeight: FontWeight.w500),)
                  :const SizedBox.shrink(),
                  const SizedBox(height: 10,),
                  buildFriendRequestButton(currentUser: currentUser, userModel: userModel),
                  const SizedBox(height: 10,),
                  buildFriendsButton(currentUser: currentUser, userModel: userModel),
                  const SizedBox(height: 10,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 40,
                        width: 40,
                        child: Divider(
                          color: Colors.grey,
                          thickness: 1,
                        ),
                      ),
                      const SizedBox(width: 10,),
                      Text(
                          'About Me',
                        style: GoogleFonts.openSans(
                            fontSize: 22,
                          fontWeight: FontWeight.w600
                        ),
      
                      ),
                      const SizedBox(width: 10,),
                      const SizedBox(
                        height: 40,
                        width: 40,
                        child: Divider(
                          color: Colors.grey,
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),
                  Text(userModel.aboutMe,
                    style: GoogleFonts.openSans(fontSize: 16,
                        fontWeight: FontWeight.w500),)
                ],
              ),
            );
          },
        )
      ),
    );
  }
  // friend request button
  Widget buildFriendRequestButton({
    required UserModel currentUser,
    required UserModel userModel}){
    if(currentUser.uid == userModel.uid && userModel.friendRequestUIDS.isNotEmpty){
      return buildElevatedButton(
          onPressed: (){

          },
          label: 'View Friend Requests');
    }else{
      //show send friend request button
      return const SizedBox.shrink();
    }
  }
  // friends button
  Widget buildFriendsButton({required UserModel currentUser, required UserModel userModel}){
    if(currentUser.uid == userModel.uid && userModel.friendsUIDs.isNotEmpty){
      return  buildElevatedButton(
          onPressed: (){
          },
          label:'View Friends'
      );
    }else if (currentUser.uid != userModel.uid ){
      //not in our profile
      return  buildElevatedButton(
          onPressed: (){
          },
          label:'Send Friend Request'
      );
    }else {
      return const SizedBox.shrink();
    }
  }

  Widget buildElevatedButton({
  required VoidCallback onPressed,required String label
}){
    return SizedBox(
      width: MediaQuery.of(context).size.width*0.7,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(
          label.toUpperCase(),
          style: GoogleFonts.openSans(
              fontWeight: FontWeight.w500
          ),
        ),
      ),
    );
  }


}
