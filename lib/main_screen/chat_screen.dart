import 'package:chatty/constants.dart';
import 'package:chatty/widgets/bottom_chat_field.dart';
import 'package:chatty/widgets/chat_app_bar.dart';
import 'package:flutter/material.dart';

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
    final contactId = arguments[Constants.contactId];
    final contactName = arguments[Constants.contactName];
    final contactImages = arguments[Constants.contactImages];
    final groupId = arguments[Constants.groupId];
    // check if the groupId is empty - then its a chat with a friend else its a group chat
    final isGroupChat = groupId.isNotEmpty ? true : false;

    return Scaffold(
      appBar: AppBar(
        title: ChatAppBar(contactId: contactId),
      ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
               Expanded(
                   child: ListView.builder(
                     itemCount: 20,
                   itemBuilder: (context,index){
                 return ListTile(title: Text('message $index'),);
               })),
              BottomChatField(contactId: contactId, contactName: contactName, contactImage: contactImages, groupId: groupId,)
            ],
          ),
        ),
    );
  }
}
