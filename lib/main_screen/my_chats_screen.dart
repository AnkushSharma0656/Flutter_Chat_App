import 'package:chatty/constants.dart';
import 'package:chatty/models/last_message_model.dart';
import 'package:chatty/providers/authentication_provider.dart';
import 'package:chatty/providers/chat_provider.dart';
import 'package:chatty/utilities/global_methods.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyChatsScreen extends StatefulWidget {
  const MyChatsScreen({Key? key}) : super(key: key);

  @override
  State<MyChatsScreen> createState() => _MyChatsScreenState();
}

class _MyChatsScreenState extends State<MyChatsScreen> {
  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthenticationProvider>().userModel!.uid;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // cupertino search bar
            CupertinoSearchTextField(
              placeholder: 'Search',
              style: const TextStyle(color: Colors.white),
              onChanged: (value){
                print(value);
              },
            ),
            Expanded(
                child: StreamBuilder<List<LastMessageModel>>(
                  stream: context.read<ChatProvider>().getChatListStream(uid),
                  builder: (context, snapshot){
                    if(snapshot.hasError){
                      return const Center(child:  Text('Something went wrong'),);
                    }
                    if(snapshot.connectionState == ConnectionState.waiting){
                      return const Center(child: CircularProgressIndicator(),);
                    }

                    if(snapshot.hasData){
                      final chatsList = snapshot.data!;
                      return ListView.builder(
                          itemCount: chatsList.length,
                          itemBuilder: (context,index){
                            final chat = chatsList[index];
                            final dateIime = formatDate(chat.timeStamp, [hh,':',nn,'',am]);
                            // check if we sent the last message
                            final isMe = chat.senderUID == uid;
                            // display the last message correctly
                            final lastMessage = isMe
                            ? 'You: ${chat.message}'
                                : chat.message;
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: userImageWidget(
                                  imageUrl: chat.contactImage,
                                  radius: 40,
                                  onTap: (){}
                              ),
                              title: Text(chat.contactName),
                              subtitle: Text(lastMessage,maxLines: 2, overflow: TextOverflow.ellipsis,),
                              trailing: Text(dateIime),
                              onTap: (){
                                Navigator.pushNamed(
                                    context,
                                    Constants.chatScreen,
                                  arguments: {
                                      Constants.contactUID : chat.contactUID,
                                      Constants.contactName : chat.contactName,
                                      Constants.contactImages : chat.contactImage,
                                      Constants.groupId : ''
                                  }
                                );
                              },
                            );
                          }
                      );
                    }
                    return const Center(child: Text('No Chats yet'),);
                  },
                )
            )
          ],
        ),
      )
    );
  }
}
