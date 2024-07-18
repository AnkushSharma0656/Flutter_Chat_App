import 'package:chatty/constants.dart';
import 'package:chatty/models/user_model.dart';
import 'package:chatty/providers/authentication_provider.dart';
import 'package:chatty/utilities/global_methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ChatAppBar extends StatefulWidget {
  const ChatAppBar({Key? key,required this.contactId}) : super(key: key);
  final String contactId;

  @override
  State<ChatAppBar> createState() => _ChatAppBarState();
}

class _ChatAppBarState extends State<ChatAppBar> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: context.read<AuthenticationProvider>().userStream(userID: widget.contactId),
      builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final userModel = UserModel.fromMap(snapshot.data!.data() as Map<String,dynamic>);

        return Row(
          children: [
            userImageWidget(imageUrl: userModel.image, radius: 20, onTap: (){
              Navigator.pushNamed(context, Constants.profileScreen,arguments: userModel.uid);
            }),
            const SizedBox(width: 10,),
            Column(
              children: [
                Text(userModel.name,style: GoogleFonts.openSans(fontSize: 16),),
                 Text('Online',style: GoogleFonts.openSans(fontSize: 12),)
              ],
            )
          ],
        );
      },
    );
  }
}

