

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
            Navigator.pushNamed(context, Constants.friendRequestsScreen);
          },
          label: 'View Friend Requests',
          width: MediaQuery.of(context).size.width*0.7,
          backgroundColor:   Theme.of(context).cardColor,
          textColor: Theme.of(context).colorScheme.primary
      );

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
            Navigator.pushNamed(context, Constants.friendsScreen);
          },
          label:'View Friends',
          width: MediaQuery.of(context).size.width*0.7,
          backgroundColor:   Theme.of(context).cardColor,
          textColor: Theme.of(context).colorScheme.primary
      );
    }else if (currentUser.uid != userModel.uid ){
      // show cancel friend request button if the user sent friend request
      if(userModel.friendRequestUIDS.contains(currentUser.uid))
        {
          return  buildElevatedButton(
              onPressed: ()async{
                await context.read<AuthenticationProvider>().cancelFriendRequest(
                    friendID: userModel.uid).whenComplete((){
                  showSnackBar(context, 'Friend request cancelled');
                });
              },
              label: 'Cancel Friend Request',
              width: MediaQuery.of(context).size.width*0.7,
              backgroundColor:   Theme.of(context).cardColor,
              textColor: Theme.of(context).colorScheme.primary
          );
        }else if(userModel.sendFriendRequests.contains(currentUser.uid)){
          return  buildElevatedButton(
          onPressed: ()async{
            await context.read<AuthenticationProvider>().acceptFriendRequest(
            friendID: userModel.uid).whenComplete((){
            showSnackBar(context, 'You are now friend with ${userModel.name}');
            });
            },
            label :'Accept Friend Request',
            width: MediaQuery.of(context).size.width*0.7,
              backgroundColor:  Theme.of(context).cardColor,
              textColor: Theme.of(context).colorScheme.primary
          );
        } else if(userModel.friendsUIDs.contains(currentUser.uid)){
        return  Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            buildElevatedButton(
              onPressed: ()async{
                // show unfriend dialog to ask the user if he is sure to unfriend
                showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Unfriend',textAlign: TextAlign.center,),
                      content:  Text('Are you sure want to Unfriend ${userModel.name}?',textAlign: TextAlign.center,),
                      actions: [
                        TextButton(
                            onPressed: (){
                              Navigator.pop(context);
                            }, child: const Text('Cancel')),
                        TextButton(
                            onPressed: ()async{
                              Navigator.pop(context);
                              await context.read<AuthenticationProvider>().removeFriend(
                                  friendID: userModel.uid).whenComplete((){
                                showSnackBar(context, 'You are no longer friend');
                              });
                            },
                            child: const Text('Unfriend'))
                      ],
                    )
                );

              },
              label :'Unfriend',
              width: MediaQuery.of(context).size.width*0.4,
                backgroundColor: Colors.deepPurple,
                textColor: Colors.white
            ),
            buildElevatedButton(
                onPressed: ()async{
                 //navigate to chat screen
                  Navigator.pushNamed(
                      context,
                      Constants.chatScreen,
                      arguments: {
                        Constants.contactUID : userModel.uid,
                        Constants.contactName  : userModel.name,
                        Constants.contactImages  : userModel.image,
                        Constants.groupId  : ''
                      }
                  );
                },
                label :'Chat',
                width: MediaQuery.of(context).size.width*0.4,
                backgroundColor:  Theme.of(context).cardColor,
                textColor: Theme.of(context).colorScheme.primary
            ),
          ],
        );
          } else{

          return  buildElevatedButton(
              onPressed: ()async{
                await context.read<AuthenticationProvider>().sendFriendRequest(
                    friendID: userModel.uid).whenComplete((){
                  showSnackBar(context, 'Friend request sent');
                });
              },
             label : 'Send Friend Request',
              width: MediaQuery.of(context).size.width*0.7,
              backgroundColor:  Theme.of(context).cardColor,
              textColor: Theme.of(context).colorScheme.primary
          );
        }
    }else {
      return const SizedBox.shrink();
    }
  }

  Widget buildElevatedButton({
  required VoidCallback onPressed,
    required String label,
    required double width,
    required Color backgroundColor,
    required Color textColor
}){
    return SizedBox(
      width: width,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 5,
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8)
          )
        ),
        onPressed: onPressed,
        child: Text(
          label.toUpperCase(),
          style: GoogleFonts.openSans(
              fontWeight: FontWeight.bold,
               color: textColor
          ),
        ),
      ),
    );
  }


}
