import 'package:chatty/constants.dart';
import 'package:chatty/providers/authentication_provider.dart';
import 'package:chatty/widgets/bottom_chat_field.dart';
import 'package:chatty/widgets/chat_app_bar.dart';
import 'package:chatty/widgets/chat_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    //get argument pass from previous screen
    final arguments = ModalRoute.of(context)!.settings.arguments as Map;
    final contactUID = arguments[Constants.contactUID];
    final contactName = arguments[Constants.contactName];
    final contactImages = arguments[Constants.contactImages];
    final groupId = arguments[Constants.groupId];
    // check if the groupId is empty - then its a chat with a friend else its a group chat
    final isGroupChat = groupId.isNotEmpty ? true : false;

    return Scaffold(
      appBar: AppBar(
        title: ChatAppBar(contactUID: contactUID),
      ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
               Expanded(
                 child: ChatList(contactUID: contactUID, groupId: groupId,),
               ),
              BottomChatField(contactUID: contactUID, contactName: contactName, contactImage: contactImages, groupId: groupId,)
            ],
          ),
        ),
    );
  }
}
