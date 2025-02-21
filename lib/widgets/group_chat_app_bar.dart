// import 'package:chatty/constants.dart';
// import 'package:chatty/models/user_model.dart';
// import 'package:chatty/providers/authentication_provider.dart';
// import 'package:chatty/utilities/global_methods.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// class GroupChatAppBar extends StatefulWidget {
//   const GroupChatAppBar({Key? key,required this.groupId}) : super(key: key);
//   final String groupId;
//   @override
//   State<GroupChatAppBar> createState() => _GroupChatAppBarState();
// }
//
// class _GroupChatAppBarState extends State<GroupChatAppBar> {
//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder(
//       stream: context.read<AuthenticationProvider>().userStream(userID: widget.groupId),
//       builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
//         if (snapshot.hasError) {
//           return const Center(child: Text('Something went wrong'));
//         }
//
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }
//         final groupModel = GroupModel.fromMap(snapshot.data!.data() as Map<String,dynamic>);
//
//         return Row(
//           children: [
//             userImageWidget(imageUrl: groupModel.groupImage, radius: 20, onTap: (){
//              // navigate to group setting screen
//             }),
//             const SizedBox(width: 10,),
//             Column(
//               children: [
//                 Text(groupModel.groupName),
//                 const Text('Group description or group members',style: TextStyle(fontSize: 12),)
//               ],
//             )
//           ],
//         );
//       },
//     );;
//   }
// }
