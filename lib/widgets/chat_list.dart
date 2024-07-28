import 'package:chatty/models/message_model.dart';
import 'package:chatty/models/message_reply_model.dart';
import 'package:chatty/providers/authentication_provider.dart';
import 'package:chatty/providers/chat_provider.dart';
import 'package:chatty/utilities/global_methods.dart';
import 'package:chatty/widgets/contact_message_widget.dart';
import 'package:chatty/widgets/my_message_widget.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:provider/provider.dart';

class ChatList extends StatefulWidget {
  const ChatList({super.key,required this.contactUID,required this.groupId});
  final String contactUID;
  final String groupId;

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthenticationProvider>().userModel!.uid;
    return StreamBuilder<List<MessageModel>>(
      stream: context.read<ChatProvider>()
          .getMessagesStream(
          userId: uid,
          contactUID: widget.contactUID,
          isGroup: widget.groupId),
      builder: (context, snapshot){
        if(snapshot.hasError){
          return const Center(child: Text('Something went wrong'),);
        }
        if(snapshot.connectionState == ConnectionState.waiting){
          return const Center(child: CircularProgressIndicator());
        }

        if(snapshot.data!.isEmpty){
          return  Center(
            child: Text('Start a conversation',
              textAlign: TextAlign.center,style: GoogleFonts.openSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),),);
        }

        if(snapshot.hasData){
          final messageList = snapshot.data!;
          return GroupedListView<dynamic, DateTime>(
            reverse: true,
            elements: messageList,
            groupBy: (element) {
              return DateTime(
                  element.timeSent!.year,
                  element.timeSent!.month,
                  element.timeSent!.day
              );
            },
            groupHeaderBuilder: (dynamic groupedByValue) => buildDateTime(groupedByValue),
            itemBuilder: (context, dynamic element) {
              final isMe = element.senderUID == uid;
              return isMe ? Padding(
                padding: const EdgeInsets.only(top: 8.0,bottom: 8.0),
                child: MyMessageWidget(
                  message: element,
                  onRightSwipe: () {
                    // set the message reply to true
                    final messageReply = MessageReplyModel(
                        message: element.message,
                        senderUID: element.senderUID,
                        senderName: element.senderName,
                        senderImage: element.senderImage,
                        messageType: element.messageType,
                        isMe: isMe
                    );
                    context.read<ChatProvider>().setMessageReplyModel(messageReply);

                  },),)
                  : Padding(
                    padding: const EdgeInsets.only(top: 8.0,bottom: 8.0),
                    child: ContactMessageWidget(message: element, onRightSwipe: () {
                      // set the message reply to true
                      final messageReply = MessageReplyModel(
                          message: element.message,
                          senderUID: element.senderUID,
                          senderName: element.senderName,
                          senderImage: element.senderImage,
                          messageType: element.messageType,
                          isMe: isMe
                      );
                      context.read<ChatProvider>().setMessageReplyModel(messageReply);
                    },),
                  );
            },
            groupComparator: (value1,value2) => value2.compareTo(value1),
            itemComparator: (item1, item2) {
              var firstItem = item1.timeSent;
              var secondItem = item2.timeSent;
              return secondItem!.compareTo(firstItem!);
            }, // optional
            useStickyGroupSeparators: true, // optional
            floatingHeader: true, // optional
            order: GroupedListOrder.ASC, // optional// optional
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
