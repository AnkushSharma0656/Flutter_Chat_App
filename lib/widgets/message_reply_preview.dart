import 'package:chatty/constants.dart';
import 'package:chatty/providers/chat_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class MessageReplyPreview extends StatelessWidget {
  const MessageReplyPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
        builder: (context,chatProvider,child){
          final messageReply = chatProvider.messageReplyModel;
          final isMe = messageReply!.isMe;
          final type = messageReply.messageType;
          Widget messageToShow(){
            switch(type){
              case MessageEnum.text:
                return Text(
                  messageReply.message,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                );
              case MessageEnum.image:
                return const Row(
                  children: [
                    Icon(Icons.image_outlined),
                    SizedBox(width: 10,),
                    Text(
                      'Image',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  ],
                );
              case MessageEnum.video:
                return const Row(
                  children: [
                    Icon(Icons.video_library_outlined),
                    SizedBox(width: 10,),
                    Text(
                      'Video',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  ],
                );
              case MessageEnum.audio:
                return const Row(
                  children: [
                     Icon(Icons.audiotrack_outlined),
                    SizedBox(width: 10,),
                    Text(
                      'Audio',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  ],
                );
              default:
                return Text(
                  messageReply.message,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                );

            }
          }
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.2),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: ListTile(
              title: Text(isMe ?
              'You' : messageReply.senderName,
                style: GoogleFonts.openSans(
                    fontWeight :  FontWeight.bold,
                    fontSize : 12
                ),),
              subtitle: messageToShow(),
              trailing: IconButton(
                  onPressed: (){
                    chatProvider.setMessageReplyModel(null);
                  },
                  icon: const Icon(Icons.close)),
            ),

          );
        }
    );
  }
}
