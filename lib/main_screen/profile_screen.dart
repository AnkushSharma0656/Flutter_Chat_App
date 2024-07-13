import 'package:chatty/constants.dart';
import 'package:chatty/models/user_model.dart';
import 'package:chatty/providers/authentication_provider.dart';
import 'package:chatty/widgets/app_bar_back_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
    return Scaffold(
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
                // create a dialog to confirm logout
                showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Logout'),
                      content: const Text('Are you sure want to logout?'),
                      actions: [
                        TextButton(
                            onPressed: (){
                              Navigator.pop(context);
                            }, child: const Text('Cancel')),
                        TextButton(
                            onPressed: ()async{

                              await context.read<AuthenticationProvider>().logoutUser().whenComplete(() => (){
                                Navigator.pop(context);
                                Navigator.pushNamedAndRemoveUntil(
                                    context, Constants.loginScreen, (route) => false);
                              });
                            },
                            child: const Text('Logout'))
                      ],
                    )
                );

              },
              icon: const Icon(Icons.logout))
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

          return ListTile(
            leading: CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(userModel.image),
            ),
            title: Text(userModel.name),
            subtitle: Text(userModel.aboutMe),
          );
        },
             )
    );
  }
}
