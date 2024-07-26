import 'package:chatty/constants.dart';
import 'package:chatty/models/message_model.dart';
import 'package:chatty/providers/authentication_provider.dart';
import 'package:chatty/providers/chat_provider.dart';
import 'package:chatty/widgets/bottom_chat_field.dart';
import 'package:chatty/widgets/chat_app_bar.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grouped_list/grouped_list.dart';
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
                         groupHeaderBuilder: (dynamic groupedByValue) =>
                             SizedBox(
                               child: Card(
                                 elevation: 2,
                                 child: Padding(
                                   padding: const EdgeInsets.all(8.0),
                                   child: Text(
                                     formatDate(groupedByValue.timeSent, [dd,' ',M,', ',yyyy]),
                                     textAlign: TextAlign.center,
                                     style: GoogleFonts.openSans(
                                       fontWeight: FontWeight.bold,
                                     ),
                                   ) ,
                                 ),
                               ),
                             ),
                         itemBuilder: (context, dynamic element) {
                           final dateTime = formatDate(element.timeSent,[hh,':',nn, ' ',am]);
                           final isMe = element.senderUID == uid;
                           return Column(
                             crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                             children: [
                               Container(
                                 margin: const EdgeInsets.symmetric(vertical : 5, horizontal: 10),
                                 padding: const EdgeInsets.all(10),
                                 decoration: BoxDecoration(
                                 color: isMe? Theme.of(context).primaryColor: Theme.of(context).cardColor,
                                 borderRadius: BorderRadius.circular(10)
                                 ),
                                 child: Column(
                                   crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                   children: [
                                   Text(
                                       element.message,
                                       style: GoogleFonts.openSans(
                                       fontSize: 16,
                                       color: isMe? Colors.white : Colors.black
                                      )
                                   ),
                                     const SizedBox(height: 5,),
                                     Text(
                                         dateTime,
                                         style: GoogleFonts.openSans(
                                             fontSize: 12,
                                             color: isMe? Colors.white : Colors.black
                                         )
                                     )
                                 ],),
                               )
                             ],
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
                 ),

               ),
              BottomChatField(contactUID: contactUID, contactName: contactName, contactImage: contactImages, groupId: groupId,)
            ],
          ),
        ),
    );
  }
}
