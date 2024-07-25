import 'package:chatty/constants.dart';
import 'package:chatty/models/message_model.dart';
import 'package:chatty/providers/authentication_provider.dart';
import 'package:chatty/providers/chat_provider.dart';
import 'package:chatty/widgets/bottom_chat_field.dart';
import 'package:chatty/widgets/chat_app_bar.dart';
import 'package:date_format/date_format.dart';
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
    // current user id
    final uid = context.read<AuthenticationProvider>().userModel!.uid;
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
                 child: StreamBuilder<List<MessageModel>>(
                   stream: context.read<ChatProvider>()
                       .getMessagesStream(
                       userId: uid,
                       contactUID: contactUID,
                       isGroup: groupId),
                   builder: (context, snapshot){
                     if(snapshot.hasError){
                       return const Center(child: Text('Something went wrong'),);
                     }
                     if(snapshot.connectionState == ConnectionState.waiting){
                       return const Center(child: CircularProgressIndicator());
                     }
                     if(snapshot.hasData){
                       final messageList = snapshot.data!;
                       return ListView.builder(
                           itemCount: messageList.length,
                           itemBuilder: (context,index){
                             final message = messageList[index];
                             final dateTime = formatDate(message.timeSent, [hh,':',nn,' ', am]);
                             final isMe = message.senderUID == uid;
                             return Card(
                               color: isMe? Theme.of(context).primaryColor: Theme.of(context).cardColor,
                               child: ListTile(
                                 title: Text(
                                     message.message,
                                   style: TextStyle(
                                     color: isMe? Theme.of(context).cardColor: Theme.of(context).primaryColor
                                   ),
                                 ),
                                 subtitle:  Text(
                                   dateTime,
                                   style: TextStyle(
                                       color: isMe? Theme.of(context).cardColor: Theme.of(context).primaryColor
                                   ),
                                 )
                               ),
                             );
                           });
                     }
                     return const SizedBox.shrink();
                   },
                 ),

               ),
              BottomChatField(contactUID: contactUID, contactName: contactName, contactImage: contactImages, groupId: groupId,)
            ],
          ),
        ),
    );
  }
}
